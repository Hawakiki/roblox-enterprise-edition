-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class AcknowledgementRequestHandler

	Hands every acknowledgement that arrives over the network to the use case that rewards it, for as long as
	the application runs.

	애플리케이션이 실행되는 동안, 네트워크로 도착한 모든 확인을 그것을 보상하는 유스케이스에 넘긴다.
]=]

local AcknowledgementRewardUseCase = require(script.Parent.AcknowledgementRewardUseCase)
local IAcknowledgementGateway = require(script.Parent.IAcknowledgementGateway)
local IHostedService = require(script.Parent.Parent.Kernel.IHostedService)
local ResourceScope = require(script.Parent.Parent.Kernel.ResourceScope)

type HandlerState = {
	_gateway: IAcknowledgementGateway.IAcknowledgementGateway,
	_useCase: AcknowledgementRewardUseCase.AcknowledgementRewardUseCase,
	_scope: ResourceScope.ResourceScope?,
}

local AcknowledgementRequestHandler = {}
AcknowledgementRequestHandler.__index = AcknowledgementRequestHandler

export type AcknowledgementRequestHandler = typeof(setmetatable({} :: HandlerState, AcknowledgementRequestHandler))

--[=[
	Creates the handler. Like every constructor, it returns the contract, not the implementation.

	@within AcknowledgementRequestHandler
	@param gateway IAcknowledgementGateway -- Hears acknowledgements from clients.
	@param useCase AcknowledgementRewardUseCase -- Rewards them.
	@return IHostedService -- The handler, as the contract it implements.
]=]
function AcknowledgementRequestHandler.new(
	gateway: IAcknowledgementGateway.IAcknowledgementGateway,
	useCase: AcknowledgementRewardUseCase.AcknowledgementRewardUseCase
): IHostedService.IHostedService
	local state: HandlerState = {
		_gateway = gateway,
		_useCase = useCase,
		_scope = nil,
	}
	return setmetatable(state, AcknowledgementRequestHandler)
end

--[=[
	Starts listening for acknowledgements.

	@within AcknowledgementRequestHandler
	@method StartAsync
]=]
function AcknowledgementRequestHandler.StartAsync(self: AcknowledgementRequestHandler)
	local scope = ResourceScope.new()
	self._scope = scope
	scope:Adopt(self._gateway:Subscribe(function(player: Player)
		self._useCase:Execute(player)
	end))
end

--[=[
	Stops listening for acknowledgements.

	@within AcknowledgementRequestHandler
	@method StopAsync
]=]
function AcknowledgementRequestHandler.StopAsync(self: AcknowledgementRequestHandler)
	local scope = self._scope
	if scope then
		self._scope = nil
		scope:Dispose()
	end
end

-- Declares the contract this class implements. Each entry is written with the signature of the contract and
-- calls the method, so that the type checker holds the method to it (EE-STD-0006 §6).
local _implements: IHostedService.IHostedService = {
	StartAsync = function(self: any)
		AcknowledgementRequestHandler.StartAsync(self)
	end,
	StopAsync = function(self: any)
		AcknowledgementRequestHandler.StopAsync(self)
	end,
}

return AcknowledgementRequestHandler
