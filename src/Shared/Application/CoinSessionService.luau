-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CoinSessionService

	Loads the wallet of a player who joins and shows it, saves every wallet at a fixed interval, and releases a
	wallet when its player leaves. A player whose wallet cannot be loaded, or is taken over by another server, is
	disconnected. The loads and releases of one player's wallet take turns, so that a late one cannot undo a newer
	one. When the application stops, every wallet still held is released, and the service waits for the loads and
	releases already under way.

	플레이어가 들어오면 지갑을 불러와 보여 주고, 일정한 간격으로 모든 지갑을 저장하며, 플레이어가 나가면 지갑을
	놓아 준다. 지갑을 불러올 수 없거나 다른 서버가 지갑을 넘겨받은 플레이어는 연결을 끊는다. 한 플레이어의 지갑을
	불러오고 놓아 주는 일은 차례를 지켜, 늦게 끝난 일이 더 새로운 일을 되돌리지 못하게 한다. 애플리케이션이
	멈추면 아직 쥐고 있는 모든 지갑을 놓아 주고, 이미 진행 중인 불러오기와 해제를 기다린다.
]=]

local AcknowledgementThrottlePolicy = require(script.Parent.Parent.Domain.AcknowledgementThrottlePolicy)
local CoinSessionConstants = require(script.Parent.CoinSessionConstants)
local CoinWalletEntity = require(script.Parent.Parent.Domain.CoinWalletEntity)
local CoinWalletRegistry = require(script.Parent.CoinWalletRegistry)
local ErrorLevelConstants = require(script.Parent.Parent.Kernel.ErrorLevelConstants)
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
	-- The players whose wallet is being loaded or released, and the loads under way (CR-0018).
	_busy: { [number]: boolean },
	_loading: number,
	_stopped: boolean,
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
		_busy = {},
		_loading = 0,
		_stopped = false,
	}
	return setmetatable(state, CoinSessionService) :: any
end

-- Waits until no load or release of the player's wallet is under way, then takes the player's turn.
function CoinSessionService._AwaitTurn(self: CoinSessionService, userId: number)
	while self._busy[userId] do
		task.wait()
	end
	self._busy[userId] = true
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

-- Loads the wallet of a player who joined, in the player's turn. Loading may yield, and meanwhile the player may
-- leave, or the service stop.
function CoinSessionService._Join(self: CoinSessionService, player: Player)
	local userId = player.UserId
	self._loading += 1
	self:_AwaitTurn(userId)
	local ok, problem = pcall(function(): any
		if player.Parent ~= nil and not self._stopped then
			self:_Open(player)
		end
		return nil
	end)
	self._busy[userId] = nil
	self._loading -= 1
	if not ok then
		error(problem, ErrorLevelConstants.WITHOUT_POSITION)
	end
end

-- Loads a wallet and shows it, or gives it up if its player has left or the service has stopped.
function CoinSessionService._Open(self: CoinSessionService, player: Player)
	local ok, result = pcall(function(): any
		return self._repository:Load(player.UserId)
	end)
	if not ok then
		self._logger:Warning(string.format("Could not load the wallet of user %d: %s", player.UserId, tostring(result)))
		-- A player who has left is not disconnected, for the same user may have joined again since.
		if player.Parent ~= nil then
			self._sessions:Kick(player.UserId, CoinSessionConstants.UNAVAILABLE_MESSAGE)
		end
		return
	end
	local wallet: CoinWalletEntity.CoinWalletEntity = result
	if player.Parent == nil or self._stopped then
		self:_Release(wallet)
		return
	end
	self._registry:Add(wallet)
	self._projection:Show(player, wallet:GetBalance())
	self._logger:Information(
		string.format("Loaded the wallet of user %d: %d coins.", player.UserId, wallet:GetBalance())
	)
end

-- Releases the wallet of a player who leaves, in the player's turn, if this server still holds it.
function CoinSessionService._Leave(self: CoinSessionService, player: Player)
	local userId = player.UserId
	self._throttle:Forget(userId)
	self._projection:Remove(player)
	local wallet = self._registry:Remove(userId)
	if wallet then
		self:_AwaitTurn(userId)
		self:_Release(wallet)
		self._busy[userId] = nil
	end
end

-- Saves every wallet. A wallet that another server has taken over is given up, and its player disconnected. A
-- wallet that has left the registry meanwhile is passed over, for its player may have joined again since.
function CoinSessionService._SaveAll(self: CoinSessionService)
	for _, wallet in self._registry:All() do
		local userId = wallet:GetUserId()
		if self._registry:Get(userId) == wallet then
			local ok, result = pcall(function(): any
				return self._repository:Save(wallet)
			end)
			if not ok then
				self._logger:Warning(
					string.format("Could not save the wallet of user %d: %s", userId, tostring(result))
				)
			elseif not result and self._registry:Get(userId) == wallet then
				self._registry:Remove(userId)
				self._logger:Warning(string.format("The wallet of user %d is now held by another server.", userId))
				self._sessions:Kick(userId, CoinSessionConstants.LOST_MESSAGE)
			end
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
	release has finished, those that players leaving had already started included. A load under way is waited
	for, and the wallet it loads is released.

	@within CoinSessionService
	@method StopAsync
]=]
function CoinSessionService.StopAsync(self: CoinSessionService)
	self._stopped = true
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
	while self._releasing > 0 or self._loading > 0 do
		task.wait()
	end
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: IHostedService.IHostedService = {
	StartAsync = CoinSessionService.StartAsync,
	StopAsync = CoinSessionService.StopAsync,
}

return CoinSessionService
