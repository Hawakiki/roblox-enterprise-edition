-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class LeaderstatsCoinProjection

	Implements ICoinProjection on the Roblox leaderboard, through a leaderstats folder under each player.
	Every folder belongs to a resource scope, released when its player leaves or the projection is disposed.

	ICoinProjection 을 Roblox 리더보드 위에, 플레이어마다 leaderstats 폴더를 두어 구현한다.
	모든 폴더는 자원 범위가 소유하며, 그 플레이어가 나가거나 프로젝션이 해제될 때 해제된다.
]=]

local ErrorLevelConstants = require(script.Parent.Parent.Kernel.ErrorLevelConstants)
local ICoinProjection = require(script.Parent.Parent.Application.ICoinProjection)
local IDisposable = require(script.Parent.Parent.Kernel.IDisposable)
local IInstanceFactory = require(script.Parent.Parent.Application.IInstanceFactory)
local LeaderstatsConstants = require(script.Parent.LeaderstatsConstants)
local ResourceScope = require(script.Parent.Parent.Kernel.ResourceScope)

type Shown = {
	scope: ResourceScope.ResourceScope,
	value: IntValue,
}

type ProjectionState = {
	_instanceFactory: IInstanceFactory.IInstanceFactory,
	_shown: { [Player]: Shown },
}

local LeaderstatsCoinProjection = {}
LeaderstatsCoinProjection.__index = LeaderstatsCoinProjection

export type LeaderstatsCoinProjection = typeof(setmetatable({} :: ProjectionState, LeaderstatsCoinProjection))

--[=[
	Creates the projection. Like every constructor, it returns the contract, not the implementation.

	@within LeaderstatsCoinProjection
	@param instanceFactory IInstanceFactory -- Creates the folders and values.
	@return ICoinProjection -- The projection, as the contract it implements.
]=]
function LeaderstatsCoinProjection.new(
	instanceFactory: IInstanceFactory.IInstanceFactory
): ICoinProjection.ICoinProjection
	local state: ProjectionState = {
		_instanceFactory = instanceFactory,
		_shown = {},
	}
	return setmetatable(state, LeaderstatsCoinProjection) :: any
end

--[=[
	Puts the balance of a player on the leaderboard.

	@within LeaderstatsCoinProjection
	@method Show
	@param player Player -- The player who joined.
	@param balance number -- Their balance.
]=]
function LeaderstatsCoinProjection.Show(self: LeaderstatsCoinProjection, player: Player, balance: number)
	if self._shown[player] then
		error(string.format("the balance of %s is already shown", player.Name), ErrorLevelConstants.CALLER)
	end
	local scope = ResourceScope.new()
	local folder = scope:Adopt(self._instanceFactory:Create("Folder"))
	folder.Name = LeaderstatsConstants.FOLDER_NAME
	local value = self._instanceFactory:Create("IntValue") :: IntValue
	value.Name = LeaderstatsConstants.COINS_STAT_NAME
	value.Value = balance
	value.Parent = folder
	-- Parented last, so that the leaderboard reads the folder whole.
	folder.Parent = player
	self._shown[player] = {
		scope = scope,
		value = value,
	}
end

--[=[
	Shows a new balance.

	@within LeaderstatsCoinProjection
	@method Update
	@param player Player -- The player.
	@param balance number -- Their new balance.
]=]
function LeaderstatsCoinProjection.Update(self: LeaderstatsCoinProjection, player: Player, balance: number)
	local shown = self._shown[player]
	if shown then
		shown.value.Value = balance
	end
end

--[=[
	Takes the balance of a player off the leaderboard, destroying their leaderstats folder.

	@within LeaderstatsCoinProjection
	@method Remove
	@param player Player -- The player who leaves.
]=]
function LeaderstatsCoinProjection.Remove(self: LeaderstatsCoinProjection, player: Player)
	local shown = self._shown[player]
	if shown then
		self._shown[player] = nil
		shown.scope:Dispose()
	end
end

--[=[
	Takes every balance off the leaderboard.

	@within LeaderstatsCoinProjection
	@method Dispose
]=]
function LeaderstatsCoinProjection.Dispose(self: LeaderstatsCoinProjection)
	for player in self._shown do
		self:Remove(player)
	end
end

-- Declares the contracts this class implements; the type checker holds every method to them.
local _implements: ICoinProjection.ICoinProjection = {
	Show = LeaderstatsCoinProjection.Show,
	Update = LeaderstatsCoinProjection.Update,
	Remove = LeaderstatsCoinProjection.Remove,
}
local _disposes: IDisposable.IDisposable = {
	Dispose = LeaderstatsCoinProjection.Dispose,
}

return LeaderstatsCoinProjection
