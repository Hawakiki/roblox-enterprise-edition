-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ClientCompositionRoot

	The composition root of the client. The client host is never stopped: the client ends with the session.

	클라이언트의 조립 지점. 클라이언트 호스트는 멈추지 않는다. 클라이언트는 세션과 함께 끝난다.
]=]

-- Composition roots are the only modules that reach a service directly: a static require path starts from one.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ApplicationHost = require(ReplicatedStorage.EnterpriseEdition.Kernel.ApplicationHost)
local RobloxOutputLoggerAdapter = require(ReplicatedStorage.EnterpriseEdition.Infrastructure.RobloxOutputLoggerAdapter)
local ServiceCollection = require(ReplicatedStorage.EnterpriseEdition.Kernel.ServiceCollection)
local ServiceTokenRegistry = require(ReplicatedStorage.EnterpriseEdition.Application.ServiceTokenRegistry)
local StartupAnnouncementService = require(ReplicatedStorage.EnterpriseEdition.Application.StartupAnnouncementService)

local services = ServiceCollection.new()
services:AddSingleton(ServiceTokenRegistry.Logger, function()
	return RobloxOutputLoggerAdapter.new("Client")
end)
services:AddSingleton(ServiceTokenRegistry.StartupAnnouncement, function(provider)
	return StartupAnnouncementService.new(provider:GetRequiredService(ServiceTokenRegistry.Logger), "client")
end)

ApplicationHost.new(services:BuildServiceProvider(), {
	ServiceTokenRegistry.StartupAnnouncement,
}):Start()
