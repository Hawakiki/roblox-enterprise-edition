-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class RobloxInstanceFactory

	Implements IInstanceFactory with Instance.new. The only module of the code that creates an instance.

	IInstanceFactory 를 Instance.new 로 구현한다. 코드에서 인스턴스를 만드는 유일한 모듈이다.
]=]

local IInstanceFactory = require(script.Parent.Parent.Application.IInstanceFactory)

type FactoryState = {}

local RobloxInstanceFactory = {}
RobloxInstanceFactory.__index = RobloxInstanceFactory

export type RobloxInstanceFactory = typeof(setmetatable({} :: FactoryState, RobloxInstanceFactory))

--[=[
	Creates the factory. Like every constructor, it returns the contract, not the implementation.

	@within RobloxInstanceFactory
	@return IInstanceFactory -- The factory, as the contract it implements.
]=]
function RobloxInstanceFactory.new(): IInstanceFactory.IInstanceFactory
	local state: FactoryState = {}
	return setmetatable(state, RobloxInstanceFactory)
end

--[=[
	Creates an instance of a class, with no parent. The caller owns it, and adopts it into a resource scope.

	@within RobloxInstanceFactory
	@method Create
	@param className string -- The class of the instance, such as TextButton.
	@return Instance -- The new instance.
]=]
function RobloxInstanceFactory.Create(self: RobloxInstanceFactory, className: string): Instance
	-- An Infrastructure factory is where EE-STD-0003 §5 allows Instance.new.
	return Instance.new(className)
end

-- Declares the contract this class implements. Each entry is written with the signature of the contract and
-- calls the method, so that the type checker holds the method to it (EE-STD-0006 §6).
local _implements: IInstanceFactory.IInstanceFactory = {
	Create = function(self: any, className: string): Instance
		return RobloxInstanceFactory.Create(self, className)
	end,
}

return RobloxInstanceFactory
