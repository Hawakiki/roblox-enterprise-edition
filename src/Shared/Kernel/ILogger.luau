-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ILogger

	The contract of a logger. Application code writes to a logger, never to the output directly.

	로거의 계약. 응용 코드는 출력 창이 아니라 로거에 쓴다.
]=]

--[=[
	@interface ILogger
	@within ILogger
	.Information (self: any, message: string) -> () -- Writes a message that informs.
	.Warning (self: any, message: string) -> () -- Writes a message that warns.

	The members that every logger implements.

	모든 로거가 구현하는 멤버.
]=]
export type ILogger = {
	Information: (self: any, message: string) -> (),
	Warning: (self: any, message: string) -> (),
}

return {}
