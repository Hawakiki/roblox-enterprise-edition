-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ServerCompositionRoot

	The composition root of the server: registers every service, builds the provider and runs the host.
	The only place on the server that knows which implementation stands behind which contract.

	서버의 조립 지점. 모든 서비스를 등록하고, 제공자를 만들고, 호스트를 실행한다.
	서버에서 어느 계약 뒤에 어느 구현이 있는지 아는 유일한 곳이다.
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
	return RobloxOutputLoggerAdapter.new("Server")
end)
services:AddSingleton(ServiceTokenRegistry.StartupAnnouncement, function(provider)
	return StartupAnnouncementService.new(provider:GetRequiredService(ServiceTokenRegistry.Logger), "server")
end)

local host = ApplicationHost.new(services:BuildServiceProvider(), {
	ServiceTokenRegistry.StartupAnnouncement,
})
host:Start()

game:BindToClose(function()
	host:Stop()
end)
