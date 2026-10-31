-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class DataStoreCoinWalletRepository

	Implements ICoinWalletRepository in a DataStore, one record per player, read and written only through
	UpdateAsync under a session lock. A server takes the lock when it loads a wallet, renews it with every save
	and gives it up on release; it waits for a lock that another server holds, and takes over one whose
	heartbeat has stopped. Every request waits for budget, and a failed one is retried with exponential backoff.

	ICoinWalletRepository 를 DataStore 에 구현한다. 플레이어마다 기록 하나를 두며, 세션 락 아래에서 오직
	UpdateAsync 로만 읽고 쓴다. 서버는 지갑을 불러올 때 락을 얻고, 저장할 때마다 갱신하며, 놓아 줄 때 내려놓는다.
	다른 서버가 쥔 락은 기다리고, heartbeat 가 멈춘 락은 넘겨받는다. 모든 요청은 예산을 기다리며, 실패한 요청은
	지수 백오프로 재시도한다.
]=]

local CoinConstants = require(script.Parent.Parent.Domain.CoinConstants)
local CoinOverflowPolicy = require(script.Parent.Parent.Domain.CoinOverflowPolicy)
local CoinWalletEntity = require(script.Parent.Parent.Domain.CoinWalletEntity)
local DataStoreConstants = require(script.Parent.DataStoreConstants)
local ErrorLevelConstants = require(script.Parent.Parent.Kernel.ErrorLevelConstants)
local ICoinWalletRepository = require(script.Parent.Parent.Application.ICoinWalletRepository)

--[=[
	@interface Dependencies
	@within DataStoreCoinWalletRepository
	.dataStore GlobalDataStore -- Where the wallets are kept.
	.overflowPolicy CoinOverflowPolicy -- Given to every wallet the repository loads.
	.sessionId string -- Names this server in the locks it takes.
	.clock () -> number -- The time in seconds, on a clock that every server shares.
	.sleep (number) -> () -- Waits for a number of seconds.
	.requestBudget () -> number -- The requests that UpdateAsync may still make.

	What the repository needs from Roblox, passed in so that a fake can stand in for each.

	저장소가 Roblox 에 요구하는 것. 각각을 가짜로 바꿀 수 있도록 주입받는다.
]=]
export type Dependencies = {
	dataStore: GlobalDataStore,
	overflowPolicy: CoinOverflowPolicy.CoinOverflowPolicy,
	sessionId: string,
	clock: () -> number,
	sleep: (seconds: number) -> (),
	requestBudget: () -> number,
}

type LockRecord = {
	sessionId: string,
	heartbeat: number,
}

type WalletRecord = {
	schemaVersion: number,
	balance: number,
	lock: LockRecord?,
}

type Transform = (stored: any, keyInfo: any) -> any

type RepositoryState = {
	_dependencies: Dependencies,
	-- The wallet this server opened for each player, so that a wallet it did not open is never written (CR-0018).
	_held: { [number]: CoinWalletEntity.CoinWalletEntity },
}

local DataStoreCoinWalletRepository = {}
DataStoreCoinWalletRepository.__index = DataStoreCoinWalletRepository

export type DataStoreCoinWalletRepository = typeof(setmetatable({} :: RepositoryState, DataStoreCoinWalletRepository))

local function keyOf(userId: number): string
	return DataStoreConstants.KEY_PREFIX .. tostring(userId)
end

local function newRecord(): WalletRecord
	return {
		schemaVersion = DataStoreConstants.SCHEMA_VERSION,
		balance = CoinConstants.INITIAL_BALANCE,
		lock = nil,
	}
end

-- Reads what UpdateAsync passes in. A malformed record, or one of a newer schema, is refused with the reason.
local function readRecord(stored: any): (WalletRecord, string?)
	if stored == nil then
		return newRecord(), nil
	end
	if type(stored) ~= "table" or type(stored.balance) ~= "number" or type(stored.schemaVersion) ~= "number" then
		return newRecord(), "the record is malformed"
	end
	local written: number = stored.schemaVersion
	local supported: number = DataStoreConstants.SCHEMA_VERSION
	if written > supported then
		return newRecord(), string.format("the record was written by schema %d, newer than %d", written, supported)
	end
	return stored, nil
end

--[=[
	Creates the repository. Like every constructor, it returns the contract, not the implementation.

	@within DataStoreCoinWalletRepository
	@param dependencies Dependencies -- What the repository needs from Roblox.
	@return ICoinWalletRepository -- The repository, as the contract it implements.
]=]
function DataStoreCoinWalletRepository.new(dependencies: Dependencies): ICoinWalletRepository.ICoinWalletRepository
	local state: RepositoryState = {
		_dependencies = dependencies,
		_held = {},
	}
	return setmetatable(state, DataStoreCoinWalletRepository) :: any
end

-- Waits until UpdateAsync has budget, but not forever: past the limit, Roblox queues the request itself.
function DataStoreCoinWalletRepository._AwaitBudget(self: DataStoreCoinWalletRepository)
	local dependencies = self._dependencies
	for _ = 1, DataStoreConstants.BUDGET_POLL_LIMIT do
		if dependencies.requestBudget() >= DataStoreConstants.MINIMUM_REQUEST_BUDGET then
			return
		end
		dependencies.sleep(DataStoreConstants.BUDGET_POLL_SECONDS)
	end
end

-- Calls UpdateAsync, retrying a failed call with exponential backoff, and raises once every attempt has failed.
function DataStoreCoinWalletRepository._Update(self: DataStoreCoinWalletRepository, key: string, transform: Transform)
	local dependencies = self._dependencies
	local problem: any = nil
	for attempt = 1, DataStoreConstants.REQUEST_ATTEMPTS do
		self:_AwaitBudget()
		local ok, result = pcall(function(): any
			dependencies.dataStore:UpdateAsync(key, transform)
			return nil
		end)
		if ok then
			return
		end
		problem = result
		if attempt < DataStoreConstants.REQUEST_ATTEMPTS then
			dependencies.sleep(DataStoreConstants.BACKOFF_BASE_SECONDS * 2 ^ (attempt - 1))
		end
	end
	error(
		string.format(
			"UpdateAsync of %s failed %d times: %s",
			key,
			DataStoreConstants.REQUEST_ATTEMPTS,
			tostring(problem)
		),
		ErrorLevelConstants.CALLER_OF_CALLER
	)
end

--[=[
	Takes the lock on the wallet of a player and loads it. A lock that another server holds is waited for, and
	one whose heartbeat has stopped is taken over. A wallet that this server holds already is not opened again,
	and a record whose balance no wallet can hold is refused before any lock is taken.

	@within DataStoreCoinWalletRepository
	@method Load
	@param userId number -- The player who joins.
	@return CoinWalletEntity -- The wallet, which this server now holds.
]=]
function DataStoreCoinWalletRepository.Load(
	self: DataStoreCoinWalletRepository,
	userId: number
): CoinWalletEntity.CoinWalletEntity
	local dependencies = self._dependencies
	for attempt = 1, DataStoreConstants.ACQUIRE_ATTEMPTS do
		if self._held[userId] then
			error(
				string.format("the wallet of user %d is already open on this server", userId),
				ErrorLevelConstants.CALLER
			)
		end
		local acquired = false
		local balance = CoinConstants.INITIAL_BALANCE
		local refusal: string? = nil
		self:_Update(keyOf(userId), function(stored: any, _keyInfo: any): any
			-- UpdateAsync may call a transform more than once; only the last call counts.
			acquired, refusal = false, nil
			local record, problem = readRecord(stored)
			-- The wallet itself judges the balance, before the lock is taken (CR-0018).
			if
				problem == nil and not pcall(CoinWalletEntity.new, userId, record.balance, dependencies.overflowPolicy)
			then
				problem = string.format("the record holds an impossible balance of %s", tostring(record.balance))
			end
			if problem then
				refusal = problem
				return nil
			end
			local now = dependencies.clock()
			local lock = record.lock
			if
				lock
				and lock.sessionId ~= dependencies.sessionId
				and now - lock.heartbeat < DataStoreConstants.LOCK_EXPIRY_SECONDS
			then
				return nil
			end
			record.lock = {
				sessionId = dependencies.sessionId,
				heartbeat = now,
			}
			balance = record.balance
			acquired = true
			return record
		end)
		if refusal then
			error(
				string.format("the wallet of user %d cannot be read: %s", userId, refusal),
				ErrorLevelConstants.CALLER
			)
		end
		if acquired then
			local wallet = CoinWalletEntity.new(userId, balance, dependencies.overflowPolicy)
			self._held[userId] = wallet
			return wallet
		end
		if attempt < DataStoreConstants.ACQUIRE_ATTEMPTS then
			dependencies.sleep(DataStoreConstants.ACQUIRE_RETRY_SECONDS)
		end
	end
	error(string.format("the wallet of user %d is locked by another server", userId), ErrorLevelConstants.CALLER)
end

--[=[
	Saves the balance of a wallet and renews its lock. A wallet whose lock has passed to another server is not
	written, and is held no longer; nor is a wallet that this server did not open, or has released.

	@within DataStoreCoinWalletRepository
	@method Save
	@param wallet CoinWalletEntity -- A wallet that Load returned.
	@return boolean -- False once this server no longer holds the wallet.
]=]
function DataStoreCoinWalletRepository.Save(
	self: DataStoreCoinWalletRepository,
	wallet: CoinWalletEntity.CoinWalletEntity
): boolean
	local userId = wallet:GetUserId()
	if self._held[userId] ~= wallet then
		return false
	end
	local dependencies = self._dependencies
	local held = false
	local refusal: string? = nil
	self:_Update(keyOf(userId), function(stored: any, _keyInfo: any): any
		held, refusal = false, nil
		local record, problem = readRecord(stored)
		if problem then
			refusal = problem
			return nil
		end
		local lock = record.lock
		if lock == nil or lock.sessionId ~= dependencies.sessionId then
			return nil
		end
		record.balance = wallet:GetBalance()
		lock.heartbeat = dependencies.clock()
		held = true
		return record
	end)
	if refusal then
		error(string.format("the wallet of user %d cannot be read: %s", userId, refusal), ErrorLevelConstants.CALLER)
	end
	if not held and self._held[userId] == wallet then
		self._held[userId] = nil
	end
	return held
end

--[=[
	Saves the balance of a wallet for the last time and gives up its lock. A wallet whose lock has passed to
	another server is left as that server wrote it, and a wallet that this server does not hold is not written.

	@within DataStoreCoinWalletRepository
	@method Release
	@param wallet CoinWalletEntity -- A wallet that Load returned.
]=]
function DataStoreCoinWalletRepository.Release(
	self: DataStoreCoinWalletRepository,
	wallet: CoinWalletEntity.CoinWalletEntity
)
	local userId = wallet:GetUserId()
	if self._held[userId] ~= wallet then
		return
	end
	self._held[userId] = nil
	local dependencies = self._dependencies
	self:_Update(keyOf(userId), function(stored: any, _keyInfo: any): any
		local record, problem = readRecord(stored)
		local lock = record.lock
		if problem or lock == nil or lock.sessionId ~= dependencies.sessionId then
			return nil
		end
		record.balance = wallet:GetBalance()
		record.lock = nil
		return record
	end)
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: ICoinWalletRepository.ICoinWalletRepository = {
	Load = DataStoreCoinWalletRepository.Load,
	Save = DataStoreCoinWalletRepository.Save,
	Release = DataStoreCoinWalletRepository.Release,
}

return DataStoreCoinWalletRepository
