-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The service collection is where a composition root registers services before the provider is built.
	Once built, the collection accepts nothing more.
	서비스 컬렉션은 조립 지점이 제공자를 만들기 전에 서비스를 등록하는 곳이다.
	제공자를 만든 뒤에는 더 이상 아무것도 받지 아니한다.
]]

local ServiceProvider = require(script.Parent.ServiceProvider)
local ServiceToken = require(script.Parent.ServiceToken)

type CollectionState = {
	_descriptors: { [string]: ServiceProvider.ServiceDescriptor },
	_built: boolean,
}

local ServiceCollection = {}
ServiceCollection.__index = ServiceCollection

export type ServiceCollection = typeof(setmetatable({} :: CollectionState, ServiceCollection))

function ServiceCollection.new(): ServiceCollection
	local state: CollectionState = {
		_descriptors = {},
		_built = false,
	}
	return setmetatable(state, ServiceCollection)
end

local function register(
	self: ServiceCollection,
	token: ServiceToken.ServiceToken<any>,
	lifetime: ServiceProvider.Lifetime,
	factory: (provider: any) -> any
)
	if self._built then
		error("the service provider has been built; the collection accepts no more services", 3)
	end
	if self._descriptors[token.name] ~= nil then
		error(string.format("%s is already registered", token.name), 3)
	end
	self._descriptors[token.name] = {
		token = token,
		lifetime = lifetime,
		factory = factory,
	}
end

function ServiceCollection.AddSingleton<T>(
	self: ServiceCollection,
	token: ServiceToken.ServiceToken<T>,
	factory: (provider: ServiceProvider.ServiceProvider) -> T
): ServiceCollection
	register(self, token, "Singleton", factory)
	return self
end

function ServiceCollection.AddTransient<T>(
	self: ServiceCollection,
	token: ServiceToken.ServiceToken<T>,
	factory: (provider: ServiceProvider.ServiceProvider) -> T
): ServiceCollection
	register(self, token, "Transient", factory)
	return self
end

function ServiceCollection.BuildServiceProvider(self: ServiceCollection): ServiceProvider.ServiceProvider
	self._built = true
	return ServiceProvider.new(table.clone(self._descriptors))
end

return ServiceCollection
