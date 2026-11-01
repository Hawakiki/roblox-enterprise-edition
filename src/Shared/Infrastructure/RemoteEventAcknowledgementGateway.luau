-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class RemoteEventAcknowledgementGateway

	Implements IAcknowledgementGateway on a RemoteEvent. The client fires it with no arguments; the server reads
	only the player that Roblox attaches, and ignores anything a client adds.

	IAcknowledgementGateway 를 RemoteEvent 위에 구현한다. 클라이언트는 인자 없이 이벤트를 보내고, 서버는 Roblox 가
	붙여 주는 플레이어만 읽으며 클라이언트가 덧붙인 것은 무시한다.
]=]

local IAcknowledgementGateway = require(script.Parent.Parent.Application.IAcknowledgementGateway)

type GatewayState = {
	_remote: RemoteEvent,
}

local RemoteEventAcknowledgementGateway = {}
RemoteEventAcknowledgementGateway.__index = RemoteEventAcknowledgementGateway

export type RemoteEventAcknowledgementGateway = typeof(setmetatable(
	{} :: GatewayState,
	RemoteEventAcknowledgementGateway
))

--[=[
	Creates the gateway. Like every constructor, it returns the contract, not the implementation.

	@within RemoteEventAcknowledgementGateway
	@param remote RemoteEvent -- The remote event that default.project.json places in ReplicatedStorage.
	@return IAcknowledgementGateway -- The gateway, as the contract it implements.
]=]
function RemoteEventAcknowledgementGateway.new(remote: RemoteEvent): IAcknowledgementGateway.IAcknowledgementGateway
	local state: GatewayState = {
		_remote = remote,
	}
	return setmetatable(state, RemoteEventAcknowledgementGateway)
end

--[=[
	Reports one acknowledgement of the local player to the server.

	@within RemoteEventAcknowledgementGateway
	@method Send
]=]
function RemoteEventAcknowledgementGateway.Send(self: RemoteEventAcknowledgementGateway)
	self._remote:FireServer()
end

--[=[
	Hears every acknowledgement that reaches the server.

	@within RemoteEventAcknowledgementGateway
	@method Subscribe
	@param onAcknowledged (Player) -> () -- Called with the player who acknowledged.
	@return () -> () -- Stops listening.
]=]
function RemoteEventAcknowledgementGateway.Subscribe(
	self: RemoteEventAcknowledgementGateway,
	onAcknowledged: (player: Player) -> ()
): () -> ()
	local connection = self._remote.OnServerEvent:Connect(function(player: Player)
		onAcknowledged(player)
	end)
	return function()
		connection:Disconnect()
	end
end

-- Declares the contract this class implements. Each entry is written with the signature of the contract and
-- calls the method, so that the type checker holds the method to it (EE-STD-0006 §6).
local _implements: IAcknowledgementGateway.IAcknowledgementGateway = {
	Send = function(self: any)
		RemoteEventAcknowledgementGateway.Send(self)
	end,
	Subscribe = function(self: any, onAcknowledged: (player: Player) -> ()): () -> ()
		return RemoteEventAcknowledgementGateway.Subscribe(self, onAcknowledged)
	end,
}

return RemoteEventAcknowledgementGateway
