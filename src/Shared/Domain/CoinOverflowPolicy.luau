-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CoinOverflowPolicy

	Decides whether a deposit keeps a balance within its maximum. The comparison subtracts rather than adds,
	so that it stays exact at the very top of the range.

	입금 뒤에도 잔액이 최댓값 안에 머무는지 판단한다. 범위의 맨 위에서도 정확하도록 더하지 않고 뺀다.
]=]

local CoinOverflowPolicy = {}
CoinOverflowPolicy.__index = CoinOverflowPolicy

type PolicyState = {
	_maximumBalance: number,
}

export type CoinOverflowPolicy = typeof(setmetatable({} :: PolicyState, CoinOverflowPolicy))

--[=[
	Creates the policy.

	@within CoinOverflowPolicy
	@param maximumBalance number -- The largest balance a wallet may hold.
	@return CoinOverflowPolicy -- The policy.
]=]
function CoinOverflowPolicy.new(maximumBalance: number): CoinOverflowPolicy
	local state: PolicyState = {
		_maximumBalance = maximumBalance,
	}
	return setmetatable(state, CoinOverflowPolicy)
end

--[=[
	Tells whether a balance may receive a deposit.

	@within CoinOverflowPolicy
	@method Permits
	@param balance number -- The balance before the deposit.
	@param amount number -- The deposit.
	@return boolean -- True when the balance after the deposit is within the maximum.
]=]
function CoinOverflowPolicy.Permits(self: CoinOverflowPolicy, balance: number, amount: number): boolean
	return balance <= self._maximumBalance - amount
end

--[=[
	Tells the largest balance a wallet may hold.

	@within CoinOverflowPolicy
	@method GetMaximumBalance
	@return number -- The maximum.
]=]
function CoinOverflowPolicy.GetMaximumBalance(self: CoinOverflowPolicy): number
	return self._maximumBalance
end

return CoinOverflowPolicy
