-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ServiceProvider

	The service provider resolves services from their tokens. It creates a singleton once and keeps it,
	creates a transient every time, refuses circular dependencies, and disposes its singletons in reverse.

	서비스 제공자는 토큰으로 서비스를 꺼낸다. 싱글턴은 한 번 만들어 보관하고, 트랜지언트는 매번 만들며,
	순환 의존성을 거부하고, 싱글턴은 생성의 역순으로 해제한다.
]=]

local ErrorLevelConstants = require(script.Parent.ErrorLevelConstants)
local SequenceConstants = require(script.Parent.SequenceConstants)
local ServiceToken = require(script.Parent.ServiceToken)

--[=[
	@type Lifetime "Singleton" | "Transient"
	@within ServiceProvider
	How long a service lives: a singleton as long as its provider, a transient as long as whoever resolved it.
]=]
export type Lifetime = "Singleton" | "Transient"

--[=[
	@interface ServiceDescriptor
	@within ServiceProvider
	.token ServiceToken<any> -- The token that names the service.
	.lifetime Lifetime -- How long the service lives.
	.factory (provider: any) -> any -- Creates the service.

	The registration of one service, as a service collection hands it to the provider.

	서비스 하나의 등록 내용. 서비스 컬렉션이 제공자에게 넘기는 형태이다.
]=]
export type ServiceDescriptor = {
	token: ServiceToken.ServiceToken<any>,
	lifetime: Lifetime,
	factory: (provider: any) -> any,
}

type ProviderState = {
	_descriptors: { [string]: ServiceDescriptor },
	_singletons: { [string]: any },
	_creationOrder: { any },
	_resolving: { string },
	_disposed: boolean,
}

local ServiceProvider = {}
ServiceProvider.__index = ServiceProvider

export type ServiceProvider = typeof(setmetatable({} :: ProviderState, ServiceProvider))

--[=[
	Creates a provider. Composition roots build one through ServiceCollection instead.

	@within ServiceProvider
	@param descriptors { [string]: ServiceDescriptor } -- The registrations, keyed by the name of their token.
	@return ServiceProvider -- The provider.
]=]
function ServiceProvider.new(descriptors: { [string]: ServiceDescriptor }): ServiceProvider
	local state: ProviderState = {
		_descriptors = descriptors,
		_singletons = {},
		_creationOrder = {},
		_resolving = {},
		_disposed = false,
	}
	return setmetatable(state, ServiceProvider)
end

--[=[
	Resolves the service that a token names, creating it if its lifetime requires.
	Raises an error that blames the caller if the provider is disposed, if nothing is registered for the token,
	or if the service depends on itself; an error raised by a factory is raised again unchanged.

	@within ServiceProvider
	@method GetRequiredService
	@param token ServiceToken<T> -- The token of the service.
	@return T -- The service.
]=]
function ServiceProvider.GetRequiredService<T>(self: ServiceProvider, token: ServiceToken.ServiceToken<T>): T
	if self._disposed then
		error("a disposed service provider cannot resolve services", ErrorLevelConstants.CALLER)
	end
	local descriptor = self._descriptors[token.name]
	if descriptor == nil then
		error(string.format("no service is registered for %s", token.name), ErrorLevelConstants.CALLER)
	end
	if descriptor.lifetime == "Singleton" and self._singletons[token.name] ~= nil then
		return self._singletons[token.name]
	end
	if table.find(self._resolving, token.name) then
		error(
			string.format("circular dependency: %s -> %s", table.concat(self._resolving, " -> "), token.name),
			ErrorLevelConstants.CALLER
		)
	end

	table.insert(self._resolving, token.name)
	local ok, service = pcall(descriptor.factory, self)
	table.remove(self._resolving)
	if not ok then
		error(service, ErrorLevelConstants.WITHOUT_POSITION)
	end

	if descriptor.lifetime == "Singleton" then
		self._singletons[token.name] = service
		table.insert(self._creationOrder, service)
	end
	return service
end

--[=[
	Disposes every singleton that can be disposed, last created first. Transients belong to whoever asked for them.
	Disposing twice does nothing.

	@within ServiceProvider
	@method Dispose
]=]
function ServiceProvider.Dispose(self: ServiceProvider)
	if self._disposed then
		return
	end
	self._disposed = true
	for index = #self._creationOrder, SequenceConstants.FIRST_INDEX, SequenceConstants.REVERSE_STEP do
		local service: any = self._creationOrder[index]
		if type(service) == "table" and type(service.Dispose) == "function" then
			(service :: any):Dispose()
		end
	end
	table.clear(self._singletons)
	table.clear(self._creationOrder)
end

return ServiceProvider
