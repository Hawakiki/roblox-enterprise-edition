-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class IInstanceFactory

	The contract through which anything but Infrastructure obtains an instance (EE-STD-0003 §5).

	Infrastructure 가 아닌 모든 곳이 인스턴스를 얻는 계약(EE-STD-0003 §5).
]=]

--[=[
	@interface IInstanceFactory
	@within IInstanceFactory
	.Create (self: any, className: string) -> Instance -- Creates an instance of a class, with no parent.

	The members that every instance factory implements.

	모든 인스턴스 팩토리가 구현하는 멤버.
]=]
export type IInstanceFactory = {
	Create: (self: any, className: string) -> Instance,
}

return {}
