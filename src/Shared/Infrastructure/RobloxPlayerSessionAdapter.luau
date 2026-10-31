-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class RobloxPlayerSessionAdapter

	Implements IPlayerSessionSource on the Players service.

	IPlayerSessionSource 를 Players 서비스 위에 구현한다.
]=]

local IPlayerSessionSource = require(script.Parent.Parent.Application.IPlayerSessionSource)
local ResourceScope = require(script.Parent.Parent.Kernel.ResourceScope)

type AdapterState = {
	_players: Players,
}

local RobloxPlayerSessionAdapter = {}
RobloxPlayerSessionAdapter.__index = RobloxPlayerSessionAdapter

export type RobloxPlayerSessionAdapter = typeof(setmetatable({} :: AdapterState, RobloxPlayerSessionAdapter))

--[=[
	Creates the adapter. Like every constructor, it returns the contract, not the implementation.

	@within RobloxPlayerSessionAdapter
	@param players Players -- The Players service, which only a composition root may reach.
	@return IPlayerSessionSource -- The adapter, as the contract it implements.
]=]
function RobloxPlayerSessionAdapter.new(players: Players): IPlayerSessionSource.IPlayerSessionSource
	local state: AdapterState = {
		_players = players,
	}
	return setmetatable(state, RobloxPlayerSessionAdapter) :: any
end

--[=[
	Reports every player who joins or leaves, and every player already present, each in a thread of its own.

	@within RobloxPlayerSessionAdapter
	@method Subscribe
	@param onJoined (Player) -> () -- Called for a player who joins, or who is already present.
	@param onLeaving (Player) -> () -- Called for a player who leaves.
	@return () -> () -- Stops reporting.
]=]
function RobloxPlayerSessionAdapter.Subscribe(
	self: RobloxPlayerSessionAdapter,
	onJoined: (player: Player) -> (),
	onLeaving: (player: Player) -> ()
): () -> ()
	local scope = ResourceScope.new()
	scope:Adopt(self._players.PlayerAdded:Connect(function(player: Player)
		onJoined(player)
	end))
	-- PlayerRemoving also passes the reason for leaving, which the application does not ask for.
	scope:Adopt(self._players.PlayerRemoving:Connect(function(player: Player)
		onLeaving(player)
	end))
	-- A player who joined before the subscription is reported as if they had just joined.
	for _, player in self._players:GetPlayers() do
		task.spawn(onJoined, player)
	end
	return function()
		scope:Dispose()
	end
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: IPlayerSessionSource.IPlayerSessionSource = {
	Subscribe = RobloxPlayerSessionAdapter.Subscribe,
}

return RobloxPlayerSessionAdapter
