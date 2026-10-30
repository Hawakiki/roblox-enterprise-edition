-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Announces that the application has started and is stopping. The first output in the history of the Company.
	애플리케이션이 시작했고 멈추고 있음을 알린다. 회사 역사상 첫 출력이다.
]]

local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local ILogger = require(script.Parent.Parent.Kernel.ILogger)

type ServiceState = {
	_logger: ILogger.ILogger,
	_side: string,
}

local StartupAnnouncementService = {}
StartupAnnouncementService.__index = StartupAnnouncementService

export type StartupAnnouncementService = typeof(setmetatable({} :: ServiceState, StartupAnnouncementService))

-- Constructors return the contract, not the implementation.
function StartupAnnouncementService.new(logger: ILogger.ILogger, side: string): IHostedService.IHostedService
	local state: ServiceState = {
		_logger = logger,
		_side = side,
	}
	return setmetatable(state, StartupAnnouncementService) :: any
end

function StartupAnnouncementService.StartAsync(self: StartupAnnouncementService)
	self._logger:Information(string.format("EnterpriseEdition has started on the %s.", self._side))
end

function StartupAnnouncementService.StopAsync(self: StartupAnnouncementService)
	self._logger:Information(string.format("EnterpriseEdition is stopping on the %s.", self._side))
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: IHostedService.IHostedService = {
	StartAsync = StartupAnnouncementService.StartAsync,
	StopAsync = StartupAnnouncementService.StopAsync,
}

return StartupAnnouncementService
