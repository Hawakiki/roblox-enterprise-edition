-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ResourceScope

	A resource scope owns resources and releases them in reverse order of acquisition, as destructors do.
	Every connection, instance, thread and disposable that a feature creates belongs to exactly one scope.

	자원 범위는 자원을 소유하고, 소멸자처럼 획득의 역순으로 해제한다.
	기능이 만드는 모든 연결, 인스턴스, 스레드, 해제 가능한 객체는 정확히 하나의 범위에 속한다.
]=]

local ErrorLevelConstants = require(script.Parent.ErrorLevelConstants)
local SequenceConstants = require(script.Parent.SequenceConstants)

type ScopeState = {
	_resources: { any },
	_disposed: boolean,
}

local ResourceScope = {}
ResourceScope.__index = ResourceScope

export type ResourceScope = typeof(setmetatable({} :: ScopeState, ResourceScope))

local function isReleasable(resource: any): boolean
	local kind = typeof(resource)
	return kind == "function"
		or kind == "RBXScriptConnection"
		or kind == "Instance"
		or kind == "thread"
		or (kind == "table" and type(resource.Dispose) == "function")
end

local function release(resource: any)
	local kind = typeof(resource)
	if kind == "function" then
		resource()
	elseif kind == "RBXScriptConnection" then
		resource:Disconnect()
	elseif kind == "Instance" then
		resource:Destroy()
	elseif kind == "thread" then
		task.cancel(resource)
	else
		resource:Dispose()
	end
end

--[=[
	Creates an empty scope.

	@within ResourceScope
	@return ResourceScope -- The scope, owning nothing yet.
]=]
function ResourceScope.new(): ResourceScope
	local state: ScopeState = {
		_resources = {},
		_disposed = false,
	}
	return setmetatable(state, ResourceScope)
end

--[=[
	Takes ownership of a resource and returns it, so that acquisition and adoption read as one expression.
	A disposed scope adopts nothing, and a value that cannot be released is refused.

	@within ResourceScope
	@method Adopt
	@param resource T -- A function to call, a connection, an instance, a thread, or a table with a Dispose method.
	@return T -- The same resource.
]=]
function ResourceScope.Adopt<T>(self: ResourceScope, resource: T): T
	if self._disposed then
		error("a disposed resource scope cannot adopt a resource", ErrorLevelConstants.CALLER)
	end
	if not isReleasable(resource) then
		error(
			string.format("a resource scope cannot release a value of type %s", typeof(resource)),
			ErrorLevelConstants.CALLER
		)
	end
	table.insert(self._resources, resource)
	return resource
end

--[=[
	Tells whether the scope has been disposed.

	@within ResourceScope
	@method IsDisposed
	@return boolean -- True once Dispose has been called.
]=]
function ResourceScope.IsDisposed(self: ResourceScope): boolean
	return self._disposed
end

--[=[
	Releases every resource, last acquired first. A failure to release one resource does not stop the others;
	the failures are raised together once every resource has been tried. Disposing twice does nothing.

	@within ResourceScope
	@method Dispose
]=]
function ResourceScope.Dispose(self: ResourceScope)
	if self._disposed then
		return
	end
	self._disposed = true
	local failures = {}
	for index = #self._resources, SequenceConstants.FIRST_INDEX, SequenceConstants.REVERSE_STEP do
		local resource = self._resources[index]
		local ok, problem = pcall(function(): any
			release(resource)
			return nil
		end)
		if not ok then
			table.insert(failures, tostring(problem))
		end
	end
	table.clear(self._resources)
	if #failures > SequenceConstants.EMPTY_LENGTH then
		error("resources failed to release: " .. table.concat(failures, "; "), ErrorLevelConstants.CALLER)
	end
end

--[=[
	Runs body with a resource and releases the resource afterwards, whether body returns or raises.
	An error raised by body is raised again unchanged.

	@within ResourceScope
	@param resource T -- The resource to lend to body.
	@param body (T) -> R -- The function that uses the resource.
	@return R -- What body returned.
]=]
function ResourceScope.Using<T, R>(resource: T, body: (T) -> R): R
	local scope = ResourceScope.new()
	scope:Adopt(resource)
	local ok, result = pcall(body, resource)
	scope:Dispose()
	if not ok then
		error(result, ErrorLevelConstants.WITHOUT_POSITION)
	end
	return result
end

return ResourceScope
