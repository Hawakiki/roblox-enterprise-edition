-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The contract of a logger. Application code writes to a logger, never to the output directly.
	로거의 계약. 응용 코드는 출력 창이 아니라 로거에 쓴다.
]]

export type ILogger = {
	Information: (self: any, message: string) -> (),
	Warning: (self: any, message: string) -> (),
}

return {}
