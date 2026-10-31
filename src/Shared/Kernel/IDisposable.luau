-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class IDisposable

	The contract of anything that owns a resource and can release it.

	자원을 소유하고 해제할 수 있는 모든 것의 계약.
]=]

--[=[
	@interface IDisposable
	@within IDisposable
	.Dispose (self: any) -> () -- Releases what the object owns.

	The members that every disposable object implements.

	해제 가능한 모든 객체가 구현하는 멤버.
]=]
export type IDisposable = {
	Dispose: (self: any) -> (),
}

return {}
