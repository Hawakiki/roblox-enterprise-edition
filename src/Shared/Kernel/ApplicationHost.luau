-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ApplicationHost

	The application host starts the hosted services in the order they were given, stops them in reverse,
	and disposes the service provider last.

	애플리케이션 호스트는 호스팅 서비스를 주어진 순서대로 시작하고 역순으로 멈추며, 마지막에 서비스 제공자를 해제한다.
]=]

local ErrorLevelConstants = require(script.Parent.ErrorLevelConstants)
local IHostedService = require(script.Parent.IHostedService)
local ServiceProvider = require(script.Parent.ServiceProvider)
local ServiceToken = require(script.Parent.ServiceToken)

--[=[
	@type HostState "Created" | "Running" | "Stopped"
	@within ApplicationHost
	The state of a host. A host runs once: it is created, it runs, and it stops for good.
]=]
export type HostState = "Created" | "Running" | "Stopped"

type ApplicationHostState = {
	_provider: ServiceProvider.ServiceProvider,
	_hostedServices: { ServiceToken.ServiceToken<IHostedService.IHostedService> },
	_started: { IHostedService.IHostedService },
	_state: HostState,
}

local ApplicationHost = {}
ApplicationHost.__index = ApplicationHost

export type ApplicationHost = typeof(setmetatable({} :: ApplicationHostState, ApplicationHost))

--[=[
	Creates a host for the hosted services that a provider resolves.

	@within ApplicationHost
	@param provider ServiceProvider -- Resolves the hosted services; the host disposes it when it stops.
	@param hostedServices { ServiceToken<IHostedService> } -- The tokens of the hosted services, in starting order.
	@return ApplicationHost -- The host, in the Created state.
]=]
function ApplicationHost.new(
	provider: ServiceProvider.ServiceProvider,
	hostedServices: { ServiceToken.ServiceToken<IHostedService.IHostedService> }
): ApplicationHost
	local state: ApplicationHostState = {
		_provider = provider,
		_hostedServices = hostedServices,
		_started = {},
		_state = "Created",
	}
	return setmetatable(state, ApplicationHost)
end

--[=[
	Returns the state of the host.

	@within ApplicationHost
	@method GetState
	@return HostState -- The state of the host.
]=]
function ApplicationHost.GetState(self: ApplicationHost): HostState
	return self._state
end

--[=[
	Resolves and starts every hosted service, in the order given.
	A host starts only once; starting it again raises an error that blames the caller.

	@within ApplicationHost
	@method Start
]=]
function ApplicationHost.Start(self: ApplicationHost)
	if self._state ~= "Created" then
		error(string.format("a host that is %s cannot start", self._state), ErrorLevelConstants.CALLER)
	end
	self._state = "Running"
	for _, token in self._hostedServices do
		local service = self._provider:GetRequiredService(token)
		service:StartAsync()
		table.insert(self._started, service)
	end
end

--[=[
	Stops every started service in reverse order, then disposes the provider.
	Does nothing unless the host is running.

	@within ApplicationHost
	@method Stop
]=]
function ApplicationHost.Stop(self: ApplicationHost)
	if self._state ~= "Running" then
		return
	end
	self._state = "Stopped"
	for index = #self._started, 1, -1 do
		self._started[index]:StopAsync()
	end
	table.clear(self._started)
	self._provider:Dispose()
end

return ApplicationHost
