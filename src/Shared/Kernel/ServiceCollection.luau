-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ServiceCollection

	The service collection is where a composition root registers services before the provider is built.
	Once built, the collection accepts nothing more.

	서비스 컬렉션은 조립 지점이 제공자를 만들기 전에 서비스를 등록하는 곳이다.
	제공자를 만든 뒤에는 더 이상 아무것도 받지 아니한다.
]=]

local ErrorLevelConstants = require(script.Parent.ErrorLevelConstants)
local ServiceProvider = require(script.Parent.ServiceProvider)
local ServiceToken = require(script.Parent.ServiceToken)

type CollectionState = {
	_descriptors: { [string]: ServiceProvider.ServiceDescriptor },
	_built: boolean,
}

local ServiceCollection = {}
ServiceCollection.__index = ServiceCollection

export type ServiceCollection = typeof(setmetatable({} :: CollectionState, ServiceCollection))

--[=[
	Creates an empty collection.

	@within ServiceCollection
	@return ServiceCollection -- The collection, accepting registrations.
]=]
function ServiceCollection.new(): ServiceCollection
	local state: CollectionState = {
		_descriptors = {},
		_built = false,
	}
	return setmetatable(state, ServiceCollection)
end

-- Raises on behalf of the public method that called it, so its errors blame the caller of that method.
local function register(
	self: ServiceCollection,
	token: ServiceToken.ServiceToken<any>,
	lifetime: ServiceProvider.Lifetime,
	factory: (provider: any) -> any
)
	if self._built then
		error(
			"the service provider has been built; the collection accepts no more services",
			ErrorLevelConstants.CALLER_OF_CALLER
		)
	end
	if self._descriptors[token.name] ~= nil then
		error(string.format("%s is already registered", token.name), ErrorLevelConstants.CALLER_OF_CALLER)
	end
	self._descriptors[token.name] = {
		token = token,
		lifetime = lifetime,
		factory = factory,
	}
end

--[=[
	Registers a service that the provider creates once and keeps.
	A token is registered once, and nothing is registered after the provider is built.

	@within ServiceCollection
	@method AddSingleton
	@param token ServiceToken<T> -- The token that names the service.
	@param factory (provider: ServiceProvider) -> T -- Creates the service, resolving its dependencies from the provider.
	@return ServiceCollection -- The collection, so that registrations can be chained.
]=]
function ServiceCollection.AddSingleton<T>(
	self: ServiceCollection,
	token: ServiceToken.ServiceToken<T>,
	factory: (provider: ServiceProvider.ServiceProvider) -> T
): ServiceCollection
	register(self, token, "Singleton", factory)
	return self
end

--[=[
	Registers a service that the provider creates every time it is resolved.
	A token is registered once, and nothing is registered after the provider is built.

	@within ServiceCollection
	@method AddTransient
	@param token ServiceToken<T> -- The token that names the service.
	@param factory (provider: ServiceProvider) -> T -- Creates the service, resolving its dependencies from the provider.
	@return ServiceCollection -- The collection, so that registrations can be chained.
]=]
function ServiceCollection.AddTransient<T>(
	self: ServiceCollection,
	token: ServiceToken.ServiceToken<T>,
	factory: (provider: ServiceProvider.ServiceProvider) -> T
): ServiceCollection
	register(self, token, "Transient", factory)
	return self
end

--[=[
	Builds the provider from the registrations, and closes the collection to further ones.

	@within ServiceCollection
	@method BuildServiceProvider
	@return ServiceProvider -- A provider that resolves every registered service.
]=]
function ServiceCollection.BuildServiceProvider(self: ServiceCollection): ServiceProvider.ServiceProvider
	self._built = true
	return ServiceProvider.new(table.clone(self._descriptors))
end

return ServiceCollection
