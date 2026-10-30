-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Every service token of the application, in one registry.
	애플리케이션의 모든 서비스 토큰을 한 대장에 둔다.
]]

local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local ILogger = require(script.Parent.Parent.Kernel.ILogger)
local ServiceToken = require(script.Parent.Parent.Kernel.ServiceToken)

local ServiceTokenRegistry = {
	Logger = ServiceToken.new("ILogger") :: ServiceToken.ServiceToken<ILogger.ILogger>,
	StartupAnnouncement = ServiceToken.new("StartupAnnouncementService") :: ServiceToken.ServiceToken<IHostedService.IHostedService>,
}

return ServiceTokenRegistry
