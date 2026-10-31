-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class InterfaceMountService

	Mounts the user interface of the client when the application starts, and unmounts it when it stops.

	애플리케이션이 시작하면 클라이언트의 사용자 인터페이스를 마운트하고, 멈추면 언마운트한다.
]=]

local ElementFactory = require(script.Parent.ElementFactory)
local IAcknowledgementGateway = require(script.Parent.Parent.Application.IAcknowledgementGateway)
local ICoinBalanceSource = require(script.Parent.Parent.Application.ICoinBalanceSource)
local IComponent = require(script.Parent.IComponent)
local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local PolicyAcknowledgementComponent = require(script.Parent.PolicyAcknowledgementComponent)
local ReconciliationOrchestrator = require(script.Parent.ReconciliationOrchestrator)

-- The name of the ScreenGui that holds the whole interface.
local ROOT_NAME = "EnterpriseEdition"

type ServiceState = {
	_orchestrator: ReconciliationOrchestrator.ReconciliationOrchestrator,
	_parent: Instance,
	_coinBalance: ICoinBalanceSource.ICoinBalanceSource,
	_acknowledgementGateway: IAcknowledgementGateway.IAcknowledgementGateway,
	_tree: ReconciliationOrchestrator.MountedTree?,
}

local InterfaceMountService = {}
InterfaceMountService.__index = InterfaceMountService

export type InterfaceMountService = typeof(setmetatable({} :: ServiceState, InterfaceMountService))

-- The whole interface of the client.
local function interface(self: InterfaceMountService): IComponent.Element
	return ElementFactory.CreateElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		PolicyAcknowledgement = ElementFactory.CreateComponent(PolicyAcknowledgementComponent, {
			CoinBalance = self._coinBalance,
			AcknowledgementGateway = self._acknowledgementGateway,
		}),
	})
end

--[=[
	Creates the service. Like every constructor, it returns the contract, not the implementation.

	@within InterfaceMountService
	@param orchestrator ReconciliationOrchestrator -- Mounts and unmounts the interface.
	@param parent Instance -- Where the interface is shown: the PlayerGui of the local player.
	@param coinBalance ICoinBalanceSource -- The balance of the local player, which the panel shows.
	@param acknowledgementGateway IAcknowledgementGateway -- Where the panel sends an acknowledgement.
	@return IHostedService -- The service, as the contract it implements.
]=]
function InterfaceMountService.new(
	orchestrator: ReconciliationOrchestrator.ReconciliationOrchestrator,
	parent: Instance,
	coinBalance: ICoinBalanceSource.ICoinBalanceSource,
	acknowledgementGateway: IAcknowledgementGateway.IAcknowledgementGateway
): IHostedService.IHostedService
	local state: ServiceState = {
		_orchestrator = orchestrator,
		_parent = parent,
		_coinBalance = coinBalance,
		_acknowledgementGateway = acknowledgementGateway,
		_tree = nil,
	}
	return setmetatable(state, InterfaceMountService) :: any
end

--[=[
	Mounts the interface.

	@within InterfaceMountService
	@method StartAsync
]=]
function InterfaceMountService.StartAsync(self: InterfaceMountService)
	self._tree = self._orchestrator:Mount(interface(self), self._parent, ROOT_NAME)
end

--[=[
	Unmounts the interface, if it is mounted.

	@within InterfaceMountService
	@method StopAsync
]=]
function InterfaceMountService.StopAsync(self: InterfaceMountService)
	local tree = self._tree
	if tree then
		self._tree = nil
		self._orchestrator:Unmount(tree)
	end
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: IHostedService.IHostedService = {
	StartAsync = InterfaceMountService.StartAsync,
	StopAsync = InterfaceMountService.StopAsync,
}

return InterfaceMountService
