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
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AcknowledgementRequestHandler =
	require(ReplicatedStorage.EnterpriseEdition.Application.AcknowledgementRequestHandler)
local AcknowledgementRewardUseCase =
	require(ReplicatedStorage.EnterpriseEdition.Application.AcknowledgementRewardUseCase)
local AcknowledgementThrottlePolicy = require(ReplicatedStorage.EnterpriseEdition.Domain.AcknowledgementThrottlePolicy)
local ApplicationHost = require(ReplicatedStorage.EnterpriseEdition.Kernel.ApplicationHost)
local CoinConstants = require(ReplicatedStorage.EnterpriseEdition.Domain.CoinConstants)
local CoinOverflowPolicy = require(ReplicatedStorage.EnterpriseEdition.Domain.CoinOverflowPolicy)
local CoinSessionService = require(ReplicatedStorage.EnterpriseEdition.Application.CoinSessionService)
local CoinWalletRegistry = require(ReplicatedStorage.EnterpriseEdition.Application.CoinWalletRegistry)
local InMemoryCoinWalletRepository =
	require(ReplicatedStorage.EnterpriseEdition.Infrastructure.InMemoryCoinWalletRepository)
local LeaderstatsCoinProjection = require(ReplicatedStorage.EnterpriseEdition.Infrastructure.LeaderstatsCoinProjection)
local RemoteEventAcknowledgementGateway =
	require(ReplicatedStorage.EnterpriseEdition.Infrastructure.RemoteEventAcknowledgementGateway)
local RobloxInstanceFactory = require(ReplicatedStorage.EnterpriseEdition.Infrastructure.RobloxInstanceFactory)
local RobloxOutputLoggerAdapter = require(ReplicatedStorage.EnterpriseEdition.Infrastructure.RobloxOutputLoggerAdapter)
local RobloxPlayerSessionAdapter =
	require(ReplicatedStorage.EnterpriseEdition.Infrastructure.RobloxPlayerSessionAdapter)
local ServiceCollection = require(ReplicatedStorage.EnterpriseEdition.Kernel.ServiceCollection)
local ServiceTokenRegistry = require(ReplicatedStorage.EnterpriseEdition.Application.ServiceTokenRegistry)
local StartupAnnouncementService = require(ReplicatedStorage.EnterpriseEdition.Application.StartupAnnouncementService)

local acknowledgePolicy = ReplicatedStorage.EnterpriseEdition.Remotes.AcknowledgePolicy

local services = ServiceCollection.new()
services:AddSingleton(ServiceTokenRegistry.Logger, function()
	return RobloxOutputLoggerAdapter.new("Server")
end)
services:AddSingleton(ServiceTokenRegistry.StartupAnnouncement, function(provider)
	return StartupAnnouncementService.new(provider:GetRequiredService(ServiceTokenRegistry.Logger), "server")
end)
services:AddSingleton(ServiceTokenRegistry.InstanceFactory, function()
	return RobloxInstanceFactory.new()
end)

-- The compliance incentive programme (CR-0011).
services:AddSingleton(ServiceTokenRegistry.CoinOverflowPolicy, function()
	return CoinOverflowPolicy.new(CoinConstants.MAXIMUM_BALANCE)
end)
services:AddSingleton(ServiceTokenRegistry.AcknowledgementThrottlePolicy, function()
	return AcknowledgementThrottlePolicy.new(CoinConstants.MINIMUM_ACKNOWLEDGEMENT_INTERVAL_SECONDS)
end)
services:AddSingleton(ServiceTokenRegistry.CoinWalletRepository, function(provider)
	return InMemoryCoinWalletRepository.new(provider:GetRequiredService(ServiceTokenRegistry.CoinOverflowPolicy))
end)
services:AddSingleton(ServiceTokenRegistry.CoinWalletRegistry, function()
	return CoinWalletRegistry.new()
end)
services:AddSingleton(ServiceTokenRegistry.CoinProjection, function(provider)
	return LeaderstatsCoinProjection.new(provider:GetRequiredService(ServiceTokenRegistry.InstanceFactory))
end)
services:AddSingleton(ServiceTokenRegistry.PlayerSessions, function()
	return RobloxPlayerSessionAdapter.new(Players)
end)
services:AddSingleton(ServiceTokenRegistry.AcknowledgementGateway, function()
	return RemoteEventAcknowledgementGateway.new(acknowledgePolicy)
end)
services:AddSingleton(ServiceTokenRegistry.CoinSession, function(provider)
	return CoinSessionService.new(
		provider:GetRequiredService(ServiceTokenRegistry.PlayerSessions),
		provider:GetRequiredService(ServiceTokenRegistry.CoinWalletRepository),
		provider:GetRequiredService(ServiceTokenRegistry.CoinProjection),
		provider:GetRequiredService(ServiceTokenRegistry.CoinWalletRegistry),
		provider:GetRequiredService(ServiceTokenRegistry.AcknowledgementThrottlePolicy),
		provider:GetRequiredService(ServiceTokenRegistry.Logger)
	)
end)
services:AddSingleton(ServiceTokenRegistry.AcknowledgementReward, function(provider)
	return AcknowledgementRewardUseCase.new(
		provider:GetRequiredService(ServiceTokenRegistry.CoinWalletRegistry),
		provider:GetRequiredService(ServiceTokenRegistry.AcknowledgementThrottlePolicy),
		provider:GetRequiredService(ServiceTokenRegistry.CoinProjection),
		os.clock
	)
end)
services:AddSingleton(ServiceTokenRegistry.AcknowledgementRequests, function(provider)
	return AcknowledgementRequestHandler.new(
		provider:GetRequiredService(ServiceTokenRegistry.AcknowledgementGateway),
		provider:GetRequiredService(ServiceTokenRegistry.AcknowledgementReward)
	)
end)

-- Started in this order and stopped in reverse: requests stop before the wallets they would reward are released.
local host = ApplicationHost.new(services:BuildServiceProvider(), {
	ServiceTokenRegistry.StartupAnnouncement,
	ServiceTokenRegistry.CoinSession,
	ServiceTokenRegistry.AcknowledgementRequests,
})
host:Start()

game:BindToClose(function()
	host:Stop()
end)
