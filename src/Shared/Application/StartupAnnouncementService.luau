-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class StartupAnnouncementService

	Announces that the application has started and is stopping. The first output in the history of the Company.

	애플리케이션이 시작했고 멈추고 있음을 알린다. 회사 역사상 첫 출력이다.
]=]

local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local ILogger = require(script.Parent.Parent.Kernel.ILogger)

type ServiceState = {
	_logger: ILogger.ILogger,
	_side: string,
}

local StartupAnnouncementService = {}
StartupAnnouncementService.__index = StartupAnnouncementService

export type StartupAnnouncementService = typeof(setmetatable({} :: ServiceState, StartupAnnouncementService))

--[=[
	Creates the service. Like every constructor, it returns the contract, not the implementation.

	@within StartupAnnouncementService
	@param logger ILogger -- The logger to announce through.
	@param side string -- The side the application runs on, as the announcement names it.
	@return IHostedService -- The service, as the contract it implements.
]=]
function StartupAnnouncementService.new(logger: ILogger.ILogger, side: string): IHostedService.IHostedService
	local state: ServiceState = {
		_logger = logger,
		_side = side,
	}
	return setmetatable(state, StartupAnnouncementService) :: any
end

--[=[
	Announces that the application has started on its side.

	@within StartupAnnouncementService
	@method StartAsync
]=]
function StartupAnnouncementService.StartAsync(self: StartupAnnouncementService)
	self._logger:Information(string.format("EnterpriseEdition has started on the %s.", self._side))
end

--[=[
	Announces that the application is stopping on its side.

	@within StartupAnnouncementService
	@method StopAsync
]=]
function StartupAnnouncementService.StopAsync(self: StartupAnnouncementService)
	self._logger:Information(string.format("EnterpriseEdition is stopping on the %s.", self._side))
end

-- Declares the contract this class implements. Each entry is written with the signature of the contract and
-- calls the method, so that both type solvers hold the method to it (EE-STD-0006 §6).
local _implements: IHostedService.IHostedService = {
	StartAsync = function(self: any)
		StartupAnnouncementService.StartAsync(self)
	end,
	StopAsync = function(self: any)
		StartupAnnouncementService.StopAsync(self)
	end,
}

return StartupAnnouncementService
