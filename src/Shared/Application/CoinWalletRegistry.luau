-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CoinWalletRegistry

	The wallets of the players who are present, by user id.

	지금 들어와 있는 플레이어들의 지갑을 사용자 ID 로 보관한다.
]=]

local CoinWalletEntity = require(script.Parent.Parent.Domain.CoinWalletEntity)
local ErrorLevelConstants = require(script.Parent.Parent.Kernel.ErrorLevelConstants)

type RegistryState = {
	_wallets: { [number]: CoinWalletEntity.CoinWalletEntity },
}

local CoinWalletRegistry = {}
CoinWalletRegistry.__index = CoinWalletRegistry

export type CoinWalletRegistry = typeof(setmetatable({} :: RegistryState, CoinWalletRegistry))

--[=[
	Creates an empty registry.

	@within CoinWalletRegistry
	@return CoinWalletRegistry -- The registry.
]=]
function CoinWalletRegistry.new(): CoinWalletRegistry
	local state: RegistryState = {
		_wallets = {},
	}
	return setmetatable(state, CoinWalletRegistry)
end

--[=[
	Keeps the wallet of a player who has joined. A player has one wallet at a time.

	@within CoinWalletRegistry
	@method Add
	@param wallet CoinWalletEntity -- The wallet.
]=]
function CoinWalletRegistry.Add(self: CoinWalletRegistry, wallet: CoinWalletEntity.CoinWalletEntity)
	local userId = wallet:GetUserId()
	-- Tested for truth: the old solver refuses to compare a metatable type with nil.
	if self._wallets[userId] then
		error(string.format("user %d already has a wallet in the registry", userId), ErrorLevelConstants.CALLER)
	end
	self._wallets[userId] = wallet
end

--[=[
	Finds the wallet of a player.

	@within CoinWalletRegistry
	@method Get
	@param userId number -- The player.
	@return CoinWalletEntity? -- The wallet, or nil if the player has none here.
]=]
function CoinWalletRegistry.Get(self: CoinWalletRegistry, userId: number): CoinWalletEntity.CoinWalletEntity?
	return self._wallets[userId]
end

--[=[
	Gives up the wallet of a player and returns it.

	@within CoinWalletRegistry
	@method Remove
	@param userId number -- The player.
	@return CoinWalletEntity? -- The wallet, or nil if the player had none here.
]=]
function CoinWalletRegistry.Remove(self: CoinWalletRegistry, userId: number): CoinWalletEntity.CoinWalletEntity?
	local wallet = self._wallets[userId]
	self._wallets[userId] = nil
	return wallet
end

--[=[
	Lists every wallet in the registry.

	@within CoinWalletRegistry
	@method All
	@return { CoinWalletEntity } -- The wallets, in no particular order.
]=]
function CoinWalletRegistry.All(self: CoinWalletRegistry): { CoinWalletEntity.CoinWalletEntity }
	local wallets = {}
	for _, wallet in self._wallets do
		table.insert(wallets, wallet)
	end
	return wallets
end

return CoinWalletRegistry
