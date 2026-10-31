-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class LeaderstatsCoinBalanceAdapter

	Implements ICoinBalanceSource on the client, by reading the leaderstats that the server keeps under the
	local player.

	서버가 로컬 플레이어 아래에 두는 leaderstats 를 읽어, 클라이언트에서 ICoinBalanceSource 를 구현한다.
]=]

local CoinConstants = require(script.Parent.Parent.Domain.CoinConstants)
local ICoinBalanceSource = require(script.Parent.Parent.Application.ICoinBalanceSource)
local LeaderstatsConstants = require(script.Parent.LeaderstatsConstants)
local ResourceScope = require(script.Parent.Parent.Kernel.ResourceScope)

type AdapterState = {
	_player: Player,
}

local LeaderstatsCoinBalanceAdapter = {}
LeaderstatsCoinBalanceAdapter.__index = LeaderstatsCoinBalanceAdapter

export type LeaderstatsCoinBalanceAdapter = typeof(setmetatable({} :: AdapterState, LeaderstatsCoinBalanceAdapter))

-- The value that holds the coins of a player, once the server has created it.
local function coinsOf(player: Player): IntValue?
	local folder = player:FindFirstChild(LeaderstatsConstants.FOLDER_NAME)
	local value = if folder then folder:FindFirstChild(LeaderstatsConstants.COINS_STAT_NAME) else nil
	if value and value:IsA("IntValue") then
		return value
	end
	return nil
end

--[=[
	Creates the adapter. Like every constructor, it returns the contract, not the implementation.

	@within LeaderstatsCoinBalanceAdapter
	@param player Player -- The local player.
	@return ICoinBalanceSource -- The adapter, as the contract it implements.
]=]
function LeaderstatsCoinBalanceAdapter.new(player: Player): ICoinBalanceSource.ICoinBalanceSource
	local state: AdapterState = {
		_player = player,
	}
	return setmetatable(state, LeaderstatsCoinBalanceAdapter) :: any
end

--[=[
	Reads the balance of the local player.

	@within LeaderstatsCoinBalanceAdapter
	@method Get
	@return number -- The balance, or the initial balance before the server has shown one.
]=]
function LeaderstatsCoinBalanceAdapter.Get(self: LeaderstatsCoinBalanceAdapter): number
	local value = coinsOf(self._player)
	return if value then value.Value else CoinConstants.INITIAL_BALANCE
end

--[=[
	Calls onChanged when the balance first appears and whenever it changes. The wait for the balance runs in a
	thread of its own, which ending the subscription cancels if it is still waiting.

	@within LeaderstatsCoinBalanceAdapter
	@method Subscribe
	@param onChanged () -> () -- Called on every change.
	@return () -> () -- Stops calling it.
]=]
function LeaderstatsCoinBalanceAdapter.Subscribe(self: LeaderstatsCoinBalanceAdapter, onChanged: () -> ()): () -> ()
	local scope = ResourceScope.new()
	local waiting = task.spawn(function()
		local folder = self._player:WaitForChild(LeaderstatsConstants.FOLDER_NAME)
		local value = folder:WaitForChild(LeaderstatsConstants.COINS_STAT_NAME) :: IntValue
		scope:Adopt(value.Changed:Connect(function()
			onChanged()
		end))
		onChanged()
	end)
	scope:Adopt(function()
		if coroutine.status(waiting) == "suspended" then
			task.cancel(waiting)
		end
	end)
	return function()
		scope:Dispose()
	end
end

-- Declares the contract this class implements. Each entry is written with the signature of the contract and
-- calls the method, so that both type solvers hold the method to it (EE-STD-0006 §6).
local _implements: ICoinBalanceSource.ICoinBalanceSource = {
	Get = function(self: any): number
		return LeaderstatsCoinBalanceAdapter.Get(self)
	end,
	Subscribe = function(self: any, onChanged: () -> ()): () -> ()
		return LeaderstatsCoinBalanceAdapter.Subscribe(self, onChanged)
	end,
}

return LeaderstatsCoinBalanceAdapter
