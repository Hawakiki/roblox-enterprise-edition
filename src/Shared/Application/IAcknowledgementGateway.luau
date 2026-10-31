-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class IAcknowledgementGateway

	The contract of the channel through which a client tells the server that its player acknowledged the
	policies of the Company. The client only sends; the server only listens.

	클라이언트가 자신의 플레이어가 회사의 정책을 확인했다고 서버에 알리는 통로의 계약.
	클라이언트는 보내기만 하고, 서버는 듣기만 한다.
]=]

--[=[
	@interface IAcknowledgementGateway
	@within IAcknowledgementGateway
	.Send (self: any) -> () -- On the client, reports one acknowledgement of the local player.
	.Subscribe (self: any, onAcknowledged: (Player) -> ()) -> () -> () -- On the server, hears every acknowledgement and returns the function that stops listening.

	The members that every acknowledgement gateway implements. Nothing but the player crosses the network:
	what the server does about it is for the server alone to decide.

	모든 확인 게이트웨이가 구현하는 멤버. 네트워크를 건너는 것은 플레이어뿐이며, 그에 대해 무엇을 할지는 서버만이
	정한다.
]=]
export type IAcknowledgementGateway = {
	Send: (self: any) -> (),
	Subscribe: (self: any, onAcknowledged: (player: Player) -> ()) -> () -> (),
}

return {}
