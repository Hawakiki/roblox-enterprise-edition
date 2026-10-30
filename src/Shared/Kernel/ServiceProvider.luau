-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The service provider resolves services from their tokens. It creates a singleton once and keeps it,
	creates a transient every time, refuses circular dependencies, and disposes its singletons in reverse.
	서비스 제공자는 토큰으로 서비스를 꺼낸다. 싱글턴은 한 번 만들어 보관하고, 트랜지언트는 매번 만들며,
	순환 의존성을 거부하고, 싱글턴은 생성의 역순으로 해제한다.
]]

local ServiceToken = require(script.Parent.ServiceToken)

export type Lifetime = "Singleton" | "Transient"

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

function ServiceProvider.GetRequiredService<T>(self: ServiceProvider, token: ServiceToken.ServiceToken<T>): T
	if self._disposed then
		error("a disposed service provider cannot resolve services", 2)
	end
	local descriptor = self._descriptors[token.name]
	if descriptor == nil then
		error(string.format("no service is registered for %s", token.name), 2)
	end
	if descriptor.lifetime == "Singleton" and self._singletons[token.name] ~= nil then
		return self._singletons[token.name]
	end
	if table.find(self._resolving, token.name) then
		error(string.format("circular dependency: %s -> %s", table.concat(self._resolving, " -> "), token.name), 2)
	end

	table.insert(self._resolving, token.name)
	local ok, service = pcall(descriptor.factory, self)
	table.remove(self._resolving)
	if not ok then
		error(service, 0)
	end

	if descriptor.lifetime == "Singleton" then
		self._singletons[token.name] = service
		table.insert(self._creationOrder, service)
	end
	return service
end

-- Disposes every singleton that can be disposed, last created first. Transients belong to whoever asked for them.
function ServiceProvider.Dispose(self: ServiceProvider)
	if self._disposed then
		return
	end
	self._disposed = true
	for index = #self._creationOrder, 1, -1 do
		local service: any = self._creationOrder[index]
		if type(service) == "table" and type(service.Dispose) == "function" then
			(service :: any):Dispose()
		end
	end
	table.clear(self._singletons)
	table.clear(self._creationOrder)
end

return ServiceProvider
