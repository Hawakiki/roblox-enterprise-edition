-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CoinSessionService

	Loads the wallet of a player who joins and shows it, saves every wallet at a fixed interval, and releases a
	wallet when its player leaves. A player whose wallet cannot be loaded, or is taken over by another server, is
	disconnected. When the application stops, every wallet still held is released, and the service waits for the
	releases already under way.

	플레이어가 들어오면 지갑을 불러와 보여 주고, 일정한 간격으로 모든 지갑을 저장하며, 플레이어가 나가면 지갑을
	놓아 준다. 지갑을 불러올 수 없거나 다른 서버가 지갑을 넘겨받은 플레이어는 연결을 끊는다. 애플리케이션이
	멈추면 아직 쥐고 있는 모든 지갑을 놓아 주고, 이미 진행 중인 해제를 기다린다.
]=]

local AcknowledgementThrottlePolicy = require(script.Parent.Parent.Domain.AcknowledgementThrottlePolicy)
local CoinSessionConstants = require(script.Parent.CoinSessionConstants)
local CoinWalletEntity = require(script.Parent.Parent.Domain.CoinWalletEntity)
local CoinWalletRegistry = require(script.Parent.CoinWalletRegistry)
local ICoinProjection = require(script.Parent.ICoinProjection)
local ICoinWalletRepository = require(script.Parent.ICoinWalletRepository)
local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local ILogger = require(script.Parent.Parent.Kernel.ILogger)
local IPlayerSessionSource = require(script.Parent.IPlayerSessionSource)
local ResourceScope = require(script.Parent.Parent.Kernel.ResourceScope)

type ServiceState = {
	_sessions: IPlayerSessionSource.IPlayerSessionSource,
	_repository: ICoinWalletRepository.ICoinWalletRepository,
	_projection: ICoinProjection.ICoinProjection,
	_registry: CoinWalletRegistry.CoinWalletRegistry,
	_throttle: AcknowledgementThrottlePolicy.AcknowledgementThrottlePolicy,
	_logger: ILogger.ILogger,
	_scope: ResourceScope.ResourceScope?,
	_releasing: number,
}

local CoinSessionService = {}
CoinSessionService.__index = CoinSessionService

export type CoinSessionService = typeof(setmetatable({} :: ServiceState, CoinSessionService))

--[=[
	Creates the service. Like every constructor, it returns the contract, not the implementation.

	@within CoinSessionService
	@param sessions IPlayerSessionSource -- Tells when players join and leave, and disconnects them.
	@param repository ICoinWalletRepository -- Keeps the wallets between sessions.
	@param projection ICoinProjection -- Shows the balances.
	@param registry CoinWalletRegistry -- Holds the wallets of the players who are present.
	@param throttle AcknowledgementThrottlePolicy -- Forgets a player who leaves.
	@param logger ILogger -- Records every wallet that is loaded, released or lost.
	@return IHostedService -- The service, as the contract it implements.
]=]
function CoinSessionService.new(
	sessions: IPlayerSessionSource.IPlayerSessionSource,
	repository: ICoinWalletRepository.ICoinWalletRepository,
	projection: ICoinProjection.ICoinProjection,
	registry: CoinWalletRegistry.CoinWalletRegistry,
	throttle: AcknowledgementThrottlePolicy.AcknowledgementThrottlePolicy,
	logger: ILogger.ILogger
): IHostedService.IHostedService
	local state: ServiceState = {
		_sessions = sessions,
		_repository = repository,
		_projection = projection,
		_registry = registry,
		_throttle = throttle,
		_logger = logger,
		_scope = nil,
		_releasing = 0,
	}
	return setmetatable(state, CoinSessionService) :: any
end

-- Releases a wallet, counting the release while it is under way so that stopping can wait for it.
function CoinSessionService._Release(self: CoinSessionService, wallet: CoinWalletEntity.CoinWalletEntity)
	self._releasing += 1
	local ok, problem = pcall(function(): any
		self._repository:Release(wallet)
		return nil
	end)
	self._releasing -= 1
	if ok then
		self._logger:Information(
			string.format("Released the wallet of user %d: %d coins.", wallet:GetUserId(), wallet:GetBalance())
		)
	else
		self._logger:Warning(
			string.format("Could not release the wallet of user %d: %s", wallet:GetUserId(), tostring(problem))
		)
	end
end

-- Loads the wallet of a player who joined. Loading may yield, and the player may leave meanwhile.
function CoinSessionService._Join(self: CoinSessionService, player: Player)
	local ok, result = pcall(function(): any
		return self._repository:Load(player.UserId)
	end)
	if not ok then
		self._logger:Warning(string.format("Could not load the wallet of user %d: %s", player.UserId, tostring(result)))
		self._sessions:Kick(player.UserId, CoinSessionConstants.UNAVAILABLE_MESSAGE)
		return
	end
	local wallet: CoinWalletEntity.CoinWalletEntity = result
	if player.Parent == nil then
		self:_Release(wallet)
		return
	end
	self._registry:Add(wallet)
	self._projection:Show(player, wallet:GetBalance())
	self._logger:Information(
		string.format("Loaded the wallet of user %d: %d coins.", player.UserId, wallet:GetBalance())
	)
end

-- Releases the wallet of a player who leaves, if this server still holds it.
function CoinSessionService._Leave(self: CoinSessionService, player: Player)
	self._throttle:Forget(player.UserId)
	self._projection:Remove(player)
	local wallet = self._registry:Remove(player.UserId)
	if wallet then
		self:_Release(wallet)
	end
end

-- Saves every wallet. A wallet that another server has taken over is given up, and its player disconnected.
function CoinSessionService._SaveAll(self: CoinSessionService)
	for _, wallet in self._registry:All() do
		local userId = wallet:GetUserId()
		local ok, result = pcall(function(): any
			return self._repository:Save(wallet)
		end)
		if not ok then
			self._logger:Warning(string.format("Could not save the wallet of user %d: %s", userId, tostring(result)))
		elseif not result then
			self._registry:Remove(userId)
			self._logger:Warning(string.format("The wallet of user %d is now held by another server.", userId))
			self._sessions:Kick(userId, CoinSessionConstants.LOST_MESSAGE)
		end
	end
end

--[=[
	Starts following the sessions of players, those already present included, and saving their wallets.

	@within CoinSessionService
	@method StartAsync
]=]
function CoinSessionService.StartAsync(self: CoinSessionService)
	local scope = ResourceScope.new()
	self._scope = scope
	scope:Adopt(self._sessions:Subscribe(function(player: Player)
		self:_Join(player)
	end, function(player: Player)
		self:_Leave(player)
	end))
	scope:Adopt(task.spawn(function()
		while true do
			task.wait(CoinSessionConstants.AUTOSAVE_INTERVAL_SECONDS)
			self:_SaveAll()
		end
	end))
end

--[=[
	Stops following sessions and saving, releases every wallet still held, in parallel, and returns once every
	release has finished, those that players leaving had already started included.

	@within CoinSessionService
	@method StopAsync
]=]
function CoinSessionService.StopAsync(self: CoinSessionService)
	local scope = self._scope
	if scope then
		self._scope = nil
		scope:Dispose()
	end
	for _, wallet in self._registry:All() do
		self._registry:Remove(wallet:GetUserId())
		task.spawn(function()
			self:_Release(wallet)
		end)
	end
	while self._releasing > 0 do
		task.wait()
	end
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: IHostedService.IHostedService = {
	StartAsync = CoinSessionService.StartAsync,
	StopAsync = CoinSessionService.StopAsync,
}

return CoinSessionService
