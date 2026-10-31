-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CoinSessionService

	Loads the wallet of a player who joins and shows it, and releases it when they leave. When the application
	stops, every wallet still held is released.

	플레이어가 들어오면 지갑을 불러와 보여 주고, 나가면 놓아 준다. 애플리케이션이 멈추면 아직 쥐고 있는 모든
	지갑을 놓아 준다.
]=]

local AcknowledgementThrottlePolicy = require(script.Parent.Parent.Domain.AcknowledgementThrottlePolicy)
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
}

local CoinSessionService = {}
CoinSessionService.__index = CoinSessionService

export type CoinSessionService = typeof(setmetatable({} :: ServiceState, CoinSessionService))

--[=[
	Creates the service. Like every constructor, it returns the contract, not the implementation.

	@within CoinSessionService
	@param sessions IPlayerSessionSource -- Tells when players join and leave.
	@param repository ICoinWalletRepository -- Keeps the wallets between sessions.
	@param projection ICoinProjection -- Shows the balances.
	@param registry CoinWalletRegistry -- Holds the wallets of the players who are present.
	@param throttle AcknowledgementThrottlePolicy -- Forgets a player who leaves.
	@param logger ILogger -- Records every wallet that is loaded and released.
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
	}
	return setmetatable(state, CoinSessionService) :: any
end

-- Loads the wallet of a player who joined. Loading may yield, and the player may leave meanwhile.
function CoinSessionService._Join(self: CoinSessionService, player: Player)
	local wallet = self._repository:Load(player.UserId)
	if player.Parent == nil then
		self._repository:Release(wallet)
		return
	end
	self._registry:Add(wallet)
	self._projection:Show(player, wallet:GetBalance())
	self._logger:Information(
		string.format("Loaded the wallet of user %d: %d coins.", player.UserId, wallet:GetBalance())
	)
end

-- Releases the wallet of a player who leaves, if it was ever loaded.
function CoinSessionService._Leave(self: CoinSessionService, player: Player)
	self._throttle:Forget(player.UserId)
	local wallet = self._registry:Remove(player.UserId)
	if wallet == nil then
		return
	end
	self._projection:Remove(player)
	self._repository:Release(wallet)
	self._logger:Information(
		string.format("Released the wallet of user %d: %d coins.", player.UserId, wallet:GetBalance())
	)
end

--[=[
	Starts following the sessions of players, those already present included.

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
end

--[=[
	Stops following sessions, and releases every wallet still held.

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
		self._repository:Release(wallet)
	end
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: IHostedService.IHostedService = {
	StartAsync = CoinSessionService.StartAsync,
	StopAsync = CoinSessionService.StopAsync,
}

return CoinSessionService
