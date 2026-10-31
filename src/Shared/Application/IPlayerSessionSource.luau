-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class IPlayerSessionSource

	The contract of whatever tells the application that players join and leave.

	플레이어가 들어오고 나간다는 것을 애플리케이션에 알려 주는 것의 계약.
]=]

--[=[
	@interface IPlayerSessionSource
	@within IPlayerSessionSource
	.Subscribe (self: any, onJoined: (Player) -> (), onLeaving: (Player) -> ()) -> () -> () -- Reports every session, those already under way included, and returns the function that stops reporting.
	.Kick (self: any, userId: number, message: string) -> () -- Ends the session of a player, if they are present, telling them why.

	The members that every source of player sessions implements. A subscriber hears of a player who is already
	present as if they had just joined.

	플레이어 세션의 모든 출처가 구현하는 멤버. 구독자는 이미 들어와 있는 플레이어도 방금 들어온 것처럼 전달받는다.
]=]
export type IPlayerSessionSource = {
	Subscribe: (self: any, onJoined: (player: Player) -> (), onLeaving: (player: Player) -> ()) -> () -> (),
	Kick: (self: any, userId: number, message: string) -> (),
}

return {}
