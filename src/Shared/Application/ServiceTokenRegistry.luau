-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ServiceTokenRegistry

	Every service token of the application, in one registry.

	애플리케이션의 모든 서비스 토큰을 한 대장에 둔다.
]=]

local AcknowledgementRewardUseCase = require(script.Parent.AcknowledgementRewardUseCase)
local AcknowledgementThrottlePolicy = require(script.Parent.Parent.Domain.AcknowledgementThrottlePolicy)
local CoinOverflowPolicy = require(script.Parent.Parent.Domain.CoinOverflowPolicy)
local CoinWalletRegistry = require(script.Parent.CoinWalletRegistry)
local IAcknowledgementGateway = require(script.Parent.IAcknowledgementGateway)
local ICoinBalanceSource = require(script.Parent.ICoinBalanceSource)
local ICoinProjection = require(script.Parent.ICoinProjection)
local ICoinWalletRepository = require(script.Parent.ICoinWalletRepository)
local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local IInstanceFactory = require(script.Parent.IInstanceFactory)
local ILogger = require(script.Parent.Parent.Kernel.ILogger)
local IPlayerSessionSource = require(script.Parent.IPlayerSessionSource)
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

--[=[
	@prop CoinOverflowPolicy ServiceToken<CoinOverflowPolicy>
	@within ServiceTokenRegistry
	The token of the policy that caps a balance (CR-0011).
]=]
ServiceTokenRegistry.CoinOverflowPolicy =
	ServiceToken.new("CoinOverflowPolicy") :: ServiceToken.ServiceToken<CoinOverflowPolicy.CoinOverflowPolicy>

--[=[
	@prop AcknowledgementThrottlePolicy ServiceToken<AcknowledgementThrottlePolicy>
	@within ServiceTokenRegistry
	The token of the policy that refuses acknowledgements that come too fast (CR-0011).
]=]
ServiceTokenRegistry.AcknowledgementThrottlePolicy =
	ServiceToken.new("AcknowledgementThrottlePolicy") :: ServiceToken.ServiceToken<AcknowledgementThrottlePolicy.AcknowledgementThrottlePolicy>

--[=[
	@prop CoinWalletRepository ServiceToken<ICoinWalletRepository>
	@within ServiceTokenRegistry
	The token of the store that keeps wallets between sessions (CR-0011).
]=]
ServiceTokenRegistry.CoinWalletRepository =
	ServiceToken.new("ICoinWalletRepository") :: ServiceToken.ServiceToken<ICoinWalletRepository.ICoinWalletRepository>

--[=[
	@prop CoinWalletRegistry ServiceToken<CoinWalletRegistry>
	@within ServiceTokenRegistry
	The token of the wallets of the players who are present (CR-0011).
]=]
ServiceTokenRegistry.CoinWalletRegistry =
	ServiceToken.new("CoinWalletRegistry") :: ServiceToken.ServiceToken<CoinWalletRegistry.CoinWalletRegistry>

--[=[
	@prop CoinProjection ServiceToken<ICoinProjection>
	@within ServiceTokenRegistry
	The token of the place where balances are shown (CR-0011).
]=]
ServiceTokenRegistry.CoinProjection =
	ServiceToken.new("ICoinProjection") :: ServiceToken.ServiceToken<ICoinProjection.ICoinProjection>

--[=[
	@prop PlayerSessions ServiceToken<IPlayerSessionSource>
	@within ServiceTokenRegistry
	The token of whatever tells when players join and leave (CR-0011).
]=]
ServiceTokenRegistry.PlayerSessions =
	ServiceToken.new("IPlayerSessionSource") :: ServiceToken.ServiceToken<IPlayerSessionSource.IPlayerSessionSource>

--[=[
	@prop AcknowledgementGateway ServiceToken<IAcknowledgementGateway>
	@within ServiceTokenRegistry
	The token of the channel through which a client reports an acknowledgement (CR-0011).
]=]
ServiceTokenRegistry.AcknowledgementGateway = ServiceToken.new("IAcknowledgementGateway") :: ServiceToken.ServiceToken<
	IAcknowledgementGateway.IAcknowledgementGateway
>

--[=[
	@prop CoinBalance ServiceToken<ICoinBalanceSource>
	@within ServiceTokenRegistry
	The token of the balance of the local player, on the client (CR-0011).
]=]
ServiceTokenRegistry.CoinBalance =
	ServiceToken.new("ICoinBalanceSource") :: ServiceToken.ServiceToken<ICoinBalanceSource.ICoinBalanceSource>

--[=[
	@prop AcknowledgementReward ServiceToken<AcknowledgementRewardUseCase>
	@within ServiceTokenRegistry
	The token of the use case that rewards an acknowledgement (CR-0011).
]=]
ServiceTokenRegistry.AcknowledgementReward =
	ServiceToken.new("AcknowledgementRewardUseCase") :: ServiceToken.ServiceToken<AcknowledgementRewardUseCase.AcknowledgementRewardUseCase>

--[=[
	@prop CoinSession ServiceToken<IHostedService>
	@within ServiceTokenRegistry
	The token of the hosted service that loads and releases wallets (CR-0011).
]=]
ServiceTokenRegistry.CoinSession =
	ServiceToken.new("CoinSessionService") :: ServiceToken.ServiceToken<IHostedService.IHostedService>

--[=[
	@prop AcknowledgementRequests ServiceToken<IHostedService>
	@within ServiceTokenRegistry
	The token of the hosted service that hands acknowledgements from the network to their use case (CR-0011).
]=]
ServiceTokenRegistry.AcknowledgementRequests =
	ServiceToken.new("AcknowledgementRequestHandler") :: ServiceToken.ServiceToken<IHostedService.IHostedService>

return ServiceTokenRegistry
