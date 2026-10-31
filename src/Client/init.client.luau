-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ClientCompositionRoot

	The composition root of the client. The client host is never stopped: the client ends with the session.

	클라이언트의 조립 지점. 클라이언트 호스트는 멈추지 않는다. 클라이언트는 세션과 함께 끝난다.
]=]

-- Composition roots are the only modules that reach a service directly: a static require path starts from one.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ApplicationHost = require(ReplicatedStorage.EnterpriseEdition.Kernel.ApplicationHost)
local InterfaceMountService = require(ReplicatedStorage.EnterpriseEdition.Presentation.InterfaceMountService)
local PresentationTokenRegistry = require(ReplicatedStorage.EnterpriseEdition.Presentation.PresentationTokenRegistry)
local ReconciliationOrchestrator = require(ReplicatedStorage.EnterpriseEdition.Presentation.ReconciliationOrchestrator)
local RobloxInstanceFactory = require(ReplicatedStorage.EnterpriseEdition.Infrastructure.RobloxInstanceFactory)
local RobloxOutputLoggerAdapter = require(ReplicatedStorage.EnterpriseEdition.Infrastructure.RobloxOutputLoggerAdapter)
local ServiceCollection = require(ReplicatedStorage.EnterpriseEdition.Kernel.ServiceCollection)
local ServiceTokenRegistry = require(ReplicatedStorage.EnterpriseEdition.Application.ServiceTokenRegistry)
local StartupAnnouncementService = require(ReplicatedStorage.EnterpriseEdition.Application.StartupAnnouncementService)

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local services = ServiceCollection.new()
services:AddSingleton(ServiceTokenRegistry.Logger, function()
	return RobloxOutputLoggerAdapter.new("Client")
end)
services:AddSingleton(ServiceTokenRegistry.StartupAnnouncement, function(provider)
	return StartupAnnouncementService.new(provider:GetRequiredService(ServiceTokenRegistry.Logger), "client")
end)
services:AddSingleton(ServiceTokenRegistry.InstanceFactory, function()
	return RobloxInstanceFactory.new()
end)
services:AddSingleton(PresentationTokenRegistry.Reconciliation, function(provider)
	return ReconciliationOrchestrator.new(provider:GetRequiredService(ServiceTokenRegistry.InstanceFactory))
end)
services:AddSingleton(PresentationTokenRegistry.InterfaceMount, function(provider)
	return InterfaceMountService.new(provider:GetRequiredService(PresentationTokenRegistry.Reconciliation), playerGui)
end)

ApplicationHost.new(services:BuildServiceProvider(), {
	ServiceTokenRegistry.StartupAnnouncement,
	PresentationTokenRegistry.InterfaceMount,
}):Start()
