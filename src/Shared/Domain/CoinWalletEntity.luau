-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CoinWalletEntity

	The compliance coins of one player, identified by their user id. A deposit that the overflow policy refuses
	changes nothing.

	플레이어 한 명의 준법 코인. 사용자 ID 로 식별한다. 넘침 정책이 거부한 입금은 아무것도 바꾸지 않는다.
]=]

local CoinOverflowPolicy = require(script.Parent.CoinOverflowPolicy)
local ErrorLevelConstants = require(script.Parent.Parent.Kernel.ErrorLevelConstants)

local CoinWalletEntity = {}
CoinWalletEntity.__index = CoinWalletEntity

type WalletState = {
	_userId: number,
	_balance: number,
	_overflowPolicy: CoinOverflowPolicy.CoinOverflowPolicy,
}

export type CoinWalletEntity = typeof(setmetatable({} :: WalletState, CoinWalletEntity))

local function isWholeNumber(value: number): boolean
	return value % 1 == 0
end

--[=[
	Creates the wallet of a player with the balance they already have.

	@within CoinWalletEntity
	@param userId number -- The player who owns the wallet.
	@param balance number -- A whole number of coins, from zero to the maximum of the overflow policy.
	@param overflowPolicy CoinOverflowPolicy -- Decides whether a deposit fits.
	@return CoinWalletEntity -- The wallet.
]=]
function CoinWalletEntity.new(
	userId: number,
	balance: number,
	overflowPolicy: CoinOverflowPolicy.CoinOverflowPolicy
): CoinWalletEntity
	if not isWholeNumber(balance) or balance < 0 or balance > overflowPolicy:GetMaximumBalance() then
		error(string.format("a wallet cannot hold a balance of %s", tostring(balance)), ErrorLevelConstants.CALLER)
	end
	local state: WalletState = {
		_userId = userId,
		_balance = balance,
		_overflowPolicy = overflowPolicy,
	}
	return setmetatable(state, CoinWalletEntity)
end

--[=[
	Tells who owns the wallet.

	@within CoinWalletEntity
	@method GetUserId
	@return number -- The user id of the owner.
]=]
function CoinWalletEntity.GetUserId(self: CoinWalletEntity): number
	return self._userId
end

--[=[
	Tells how many coins the wallet holds.

	@within CoinWalletEntity
	@method GetBalance
	@return number -- The balance.
]=]
function CoinWalletEntity.GetBalance(self: CoinWalletEntity): number
	return self._balance
end

--[=[
	Adds coins, unless the overflow policy refuses.

	@within CoinWalletEntity
	@method Deposit
	@param amount number -- A positive whole number of coins.
	@return boolean -- True when the coins were added.
]=]
function CoinWalletEntity.Deposit(self: CoinWalletEntity, amount: number): boolean
	if not isWholeNumber(amount) or amount <= 0 then
		error(string.format("a deposit cannot be %s coins", tostring(amount)), ErrorLevelConstants.CALLER)
	end
	if not self._overflowPolicy:Permits(self._balance, amount) then
		return false
	end
	self._balance += amount
	return true
end

return CoinWalletEntity
