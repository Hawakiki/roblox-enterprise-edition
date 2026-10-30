-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The application host starts the hosted services in the order they were given, stops them in reverse,
	and disposes the service provider last.
	애플리케이션 호스트는 호스팅 서비스를 주어진 순서대로 시작하고 역순으로 멈추며, 마지막에 서비스 제공자를 해제한다.
]]

local ErrorLevelConstants = require(script.Parent.ErrorLevelConstants)
local IHostedService = require(script.Parent.IHostedService)
local SequenceConstants = require(script.Parent.SequenceConstants)
local ServiceProvider = require(script.Parent.ServiceProvider)
local ServiceToken = require(script.Parent.ServiceToken)

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

function ApplicationHost.GetState(self: ApplicationHost): HostState
	return self._state
end

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

function ApplicationHost.Stop(self: ApplicationHost)
	if self._state ~= "Running" then
		return
	end
	self._state = "Stopped"
	for index = #self._started, SequenceConstants.FIRST_INDEX, SequenceConstants.REVERSE_STEP do
		self._started[index]:StopAsync()
	end
	table.clear(self._started)
	self._provider:Dispose()
end

return ApplicationHost
