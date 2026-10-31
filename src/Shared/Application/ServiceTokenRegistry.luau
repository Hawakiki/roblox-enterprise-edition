-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ServiceTokenRegistry

	Every service token of the application, in one registry.

	애플리케이션의 모든 서비스 토큰을 한 대장에 둔다.
]=]

local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local IInstanceFactory = require(script.Parent.IInstanceFactory)
local ILogger = require(script.Parent.Parent.Kernel.ILogger)
local ServiceToken = require(script.Parent.Parent.Kernel.ServiceToken)

local ServiceTokenRegistry = {}

--[=[
	@prop Logger ServiceToken<ILogger>
	@within ServiceTokenRegistry
	The token of the logger.
]=]
ServiceTokenRegistry.Logger = ServiceToken.new("ILogger") :: ServiceToken.ServiceToken<ILogger.ILogger>

--[=[
	@prop StartupAnnouncement ServiceToken<IHostedService>
	@within ServiceTokenRegistry
	The token of the hosted service that announces startup.
]=]
ServiceTokenRegistry.StartupAnnouncement =
	ServiceToken.new("StartupAnnouncementService") :: ServiceToken.ServiceToken<IHostedService.IHostedService>

--[=[
	@prop InstanceFactory ServiceToken<IInstanceFactory>
	@within ServiceTokenRegistry
	The token of the factory through which anything but Infrastructure obtains an instance.
]=]
ServiceTokenRegistry.InstanceFactory =
	ServiceToken.new("IInstanceFactory") :: ServiceToken.ServiceToken<IInstanceFactory.IInstanceFactory>

return ServiceTokenRegistry
