-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ICoinProjection

	The contract of a place where the balance of a player is shown to everyone, such as the leaderboard.

	플레이어의 잔액을 모두에게 보여 주는 곳의 계약. 리더보드가 그 예이다.
]=]

--[=[
	@interface ICoinProjection
	@within ICoinProjection
	.Show (self: any, player: Player, balance: number) -> () -- Starts showing the balance of a player who joined.
	.Update (self: any, player: Player, balance: number) -> () -- Shows a new balance.
	.Remove (self: any, player: Player) -> () -- Stops showing the balance of a player who leaves.

	The members that every coin projection implements.

	모든 코인 프로젝션이 구현하는 멤버.
]=]
export type ICoinProjection = {
	Show: (self: any, player: Player, balance: number) -> (),
	Update: (self: any, player: Player, balance: number) -> (),
	Remove: (self: any, player: Player) -> (),
}

return {}
