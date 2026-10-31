-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ICoinBalanceSource

	The contract through which a client reads the balance of its own player, as the server last recorded it.

	클라이언트가 서버가 마지막으로 기록한 자기 플레이어의 잔액을 읽는 계약.
]=]

--[=[
	@interface ICoinBalanceSource
	@within ICoinBalanceSource
	.Get (self: any) -> number -- The balance, or zero before the server has recorded one.
	.Subscribe (self: any, onChanged: () -> ()) -> () -> () -- Calls onChanged whenever the balance changes, and returns the function that stops calling it.

	The members that every source of a balance implements.

	잔액의 모든 출처가 구현하는 멤버.
]=]
export type ICoinBalanceSource = {
	Get: (self: any) -> number,
	Subscribe: (self: any, onChanged: () -> ()) -> () -> (),
}

return {}
