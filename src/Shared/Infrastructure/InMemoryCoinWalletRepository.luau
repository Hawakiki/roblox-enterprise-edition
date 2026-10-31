-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class InMemoryCoinWalletRepository

	Implements ICoinWalletRepository in the memory of the server: a balance outlives its session, but not its
	server. It guards nothing, because no other server can see it, and it needs no published place.

	ICoinWalletRepository 를 서버 메모리로 구현한다. 잔액은 세션보다 오래 남지만 서버보다 오래 남지는 않는다.
	다른 서버가 볼 수 없으므로 지킬 것이 없고, 게시된 플레이스도 필요 없다.
]=]

local CoinConstants = require(script.Parent.Parent.Domain.CoinConstants)
local CoinOverflowPolicy = require(script.Parent.Parent.Domain.CoinOverflowPolicy)
local CoinWalletEntity = require(script.Parent.Parent.Domain.CoinWalletEntity)
local ICoinWalletRepository = require(script.Parent.Parent.Application.ICoinWalletRepository)

type RepositoryState = {
	_balances: { [number]: number },
	_overflowPolicy: CoinOverflowPolicy.CoinOverflowPolicy,
}

local InMemoryCoinWalletRepository = {}
InMemoryCoinWalletRepository.__index = InMemoryCoinWalletRepository

export type InMemoryCoinWalletRepository = typeof(setmetatable({} :: RepositoryState, InMemoryCoinWalletRepository))

--[=[
	Creates an empty repository. Like every constructor, it returns the contract, not the implementation.

	@within InMemoryCoinWalletRepository
	@param overflowPolicy CoinOverflowPolicy -- Given to every wallet the repository loads.
	@return ICoinWalletRepository -- The repository, as the contract it implements.
]=]
function InMemoryCoinWalletRepository.new(
	overflowPolicy: CoinOverflowPolicy.CoinOverflowPolicy
): ICoinWalletRepository.ICoinWalletRepository
	local state: RepositoryState = {
		_balances = {},
		_overflowPolicy = overflowPolicy,
	}
	return setmetatable(state, InMemoryCoinWalletRepository) :: any
end

--[=[
	Loads the wallet of a player, with the balance they had when they last left this server.

	@within InMemoryCoinWalletRepository
	@method Load
	@param userId number -- The player.
	@return CoinWalletEntity -- The wallet.
]=]
function InMemoryCoinWalletRepository.Load(
	self: InMemoryCoinWalletRepository,
	userId: number
): CoinWalletEntity.CoinWalletEntity
	local balance = self._balances[userId] or CoinConstants.INITIAL_BALANCE
	return CoinWalletEntity.new(userId, balance, self._overflowPolicy)
end

--[=[
	Remembers the balance of a wallet.

	@within InMemoryCoinWalletRepository
	@method Save
	@param wallet CoinWalletEntity -- The wallet.
]=]
function InMemoryCoinWalletRepository.Save(
	self: InMemoryCoinWalletRepository,
	wallet: CoinWalletEntity.CoinWalletEntity
)
	self._balances[wallet:GetUserId()] = wallet:GetBalance()
end

--[=[
	Remembers the balance of a wallet whose player leaves. There is no guard to give up.

	@within InMemoryCoinWalletRepository
	@method Release
	@param wallet CoinWalletEntity -- The wallet.
]=]
function InMemoryCoinWalletRepository.Release(
	self: InMemoryCoinWalletRepository,
	wallet: CoinWalletEntity.CoinWalletEntity
)
	self:Save(wallet)
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: ICoinWalletRepository.ICoinWalletRepository = {
	Load = InMemoryCoinWalletRepository.Load,
	Save = InMemoryCoinWalletRepository.Save,
	Release = InMemoryCoinWalletRepository.Release,
}

return InMemoryCoinWalletRepository
