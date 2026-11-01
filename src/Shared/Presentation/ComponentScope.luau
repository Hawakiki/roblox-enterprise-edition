-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ComponentScope

	Owns everything a component acquires, as a resource scope does, and lets the component ask to be rendered
	again. The reconciler disposes it after the component has unmounted, so nothing a component acquired outlives it.

	컴포넌트가 얻은 모든 것을 자원 범위처럼 소유하고, 컴포넌트가 다시 그려 달라고 요청하게 한다.
	조정자는 컴포넌트가 언마운트된 뒤에 이를 해제하므로, 컴포넌트가 얻은 어떤 것도 컴포넌트보다 오래 남지 않는다.
]=]

local ErrorLevelConstants = require(script.Parent.Parent.Kernel.ErrorLevelConstants)
local IDisposable = require(script.Parent.Parent.Kernel.IDisposable)
local ResourceScope = require(script.Parent.Parent.Kernel.ResourceScope)

type ScopeState = {
	_resources: ResourceScope.ResourceScope,
	_invalidate: () -> (),
}

local ComponentScope = {}
ComponentScope.__index = ComponentScope

export type ComponentScope = typeof(setmetatable({} :: ScopeState, ComponentScope))

--[=[
	Creates the scope of a component. Only the reconciler creates one.

	@within ComponentScope
	@param invalidate () -> () -- Renders the component again; the reconciler supplies it.
	@return ComponentScope -- The scope, owning nothing yet.
]=]
function ComponentScope.new(invalidate: () -> ()): ComponentScope
	local state: ScopeState = {
		_resources = ResourceScope.new(),
		_invalidate = invalidate,
	}
	return setmetatable(state, ComponentScope)
end

--[=[
	Takes ownership of a resource for as long as the component is mounted, and returns it.

	@within ComponentScope
	@method Adopt
	@param resource T -- A function to call, a connection, an instance, a thread, or a table with a Dispose method.
	@return T -- The same resource.
]=]
function ComponentScope.Adopt<T>(self: ComponentScope, resource: T): T
	return self._resources:Adopt(resource)
end

--[=[
	Asks the reconciler to render the component again, because its state has changed.
	A component that has been unmounted cannot ask.

	@within ComponentScope
	@method Invalidate
]=]
function ComponentScope.Invalidate(self: ComponentScope)
	if self._resources:IsDisposed() then
		error("an unmounted component cannot be rendered again", ErrorLevelConstants.CALLER)
	end
	self._invalidate()
end

--[=[
	Tells whether the scope has been disposed, which happens when its component unmounts.

	@within ComponentScope
	@method IsDisposed
	@return boolean -- True once the component has unmounted.
]=]
function ComponentScope.IsDisposed(self: ComponentScope): boolean
	return self._resources:IsDisposed()
end

--[=[
	Releases everything the component acquired, last acquired first. Only the reconciler disposes a scope.

	@within ComponentScope
	@method Dispose
]=]
function ComponentScope.Dispose(self: ComponentScope)
	self._resources:Dispose()
end

-- Declares the contract this class implements. Each entry is written with the signature of the contract and
-- calls the method, so that the type checker holds the method to it (EE-STD-0006 §6).
local _implements: IDisposable.IDisposable = {
	Dispose = function(self: any)
		ComponentScope.Dispose(self)
	end,
}

return ComponentScope
