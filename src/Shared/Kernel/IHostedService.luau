-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The contract of a service that the application host starts and stops.
	The methods are named Async after the frameworks this one imitates. Nothing about them is asynchronous.
	애플리케이션 호스트가 시작하고 멈추는 서비스의 계약.
	메서드 이름의 Async 는 이 프레임워크가 흉내 내는 원본을 따른 것이며, 비동기인 부분은 없다.
]]

export type IHostedService = {
	StartAsync: (self: any) -> (),
	StopAsync: (self: any) -> (),
}

return {}
