-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class PresentationTokenRegistry

	The service tokens of the Presentation layer. They cannot live in ServiceTokenRegistry, which is in the
	Application layer and may not require this one (EE-STD-0006 §4).

	Presentation 계층의 서비스 토큰. Application 계층에 있는 ServiceTokenRegistry 는 이 계층을 require 할 수
	없으므로 그곳에 둘 수 없다(EE-STD-0006 §4).
]=]

local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local ReconciliationOrchestrator = require(script.Parent.ReconciliationOrchestrator)
local ServiceToken = require(script.Parent.Parent.Kernel.ServiceToken)

local PresentationTokenRegistry = {}

--[=[
	@prop Reconciliation ServiceToken<ReconciliationOrchestrator>
	@within PresentationTokenRegistry
	The token of the reconciler.
]=]
PresentationTokenRegistry.Reconciliation = ServiceToken.new("ReconciliationOrchestrator") :: ServiceToken.ServiceToken<
	ReconciliationOrchestrator.ReconciliationOrchestrator
>

--[=[
	@prop InterfaceMount ServiceToken<IHostedService>
	@within PresentationTokenRegistry
	The token of the hosted service that mounts the interface.
]=]
PresentationTokenRegistry.InterfaceMount =
	ServiceToken.new("InterfaceMountService") :: ServiceToken.ServiceToken<IHostedService.IHostedService>

return PresentationTokenRegistry
