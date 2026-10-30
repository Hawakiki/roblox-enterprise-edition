-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The contract of anything that owns a resource and can release it.
	자원을 소유하고 해제할 수 있는 모든 것의 계약.
]]

export type IDisposable = {
	Dispose: (self: any) -> (),
}

return {}
