-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("../Assert")
local FakeRoblox = require("./FakeRoblox")

local InterfaceMountService = FakeRoblox.require("Presentation/InterfaceMountService")
local ReconciliationOrchestrator = FakeRoblox.require("Presentation/ReconciliationOrchestrator")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

-- A balance that the test sets, and that tells its subscribers.
local function newBalance(): any
	local balance: any = { value = 0, listeners = {} }
	function balance.Get(self: any): number
		return self.value
	end
	function balance.Subscribe(self: any, onChanged: () -> ()): () -> ()
		self.listeners[onChanged] = true
		return function()
			self.listeners[onChanged] = nil
		end
	end
	function balance.Set(self: any, value: number)
		self.value = value
		local listeners: { [() -> ()]: boolean } = self.listeners
		for listener in listeners do
			listener()
		end
	end
	return balance
end

case("the panel shows the balance, asks the server and follows the answer", function()
	local balance = newBalance()
	local gateway: any = { sent = 0 }
	function gateway.Send(self: any)
		self.sent += 1
	end
	local orchestrator = ReconciliationOrchestrator.new({
		Create = function(_: any, className: string): any
			return FakeRoblox.instance(className)
		end,
	})
	local playerGui = FakeRoblox.instance("PlayerGui")
	local service = InterfaceMountService.new(orchestrator, playerGui, balance, gateway)

	service:StartAsync()
	local panel = FakeRoblox.child(FakeRoblox.child(playerGui, "EnterpriseEdition"), "PolicyAcknowledgement")
	local status, button = FakeRoblox.child(panel, "Status"), FakeRoblox.child(panel, "Acknowledge")
	Assert.contains(status.Text, "Compliance coins: 0", "the panel shows the balance")
	Assert.truthy(next(balance.listeners) ~= nil, "the panel follows the balance")

	local before = #FakeRoblox.created
	button.Activated:Fire()
	button.Activated:Fire()
	Assert.equal(gateway.sent, 2, "the button asks the server")
	Assert.contains(status.Text, "coins: 0", "and changes nothing itself")
	balance:Set(5)
	Assert.contains(status.Text, "Compliance coins: 5", "a new balance is shown")
	Assert.equal(#FakeRoblox.created, before, "showing it creates no instance")
	Assert.equal(FakeRoblox.child(panel, "Acknowledge"), button, "the button stays the same instance")

	service:StopAsync()
	Assert.equal(FakeRoblox.childCount(playerGui), 0, "stopping removes the interface")
	Assert.equal(next(balance.listeners), nil, "stopping ends the subscription to the balance")
end)

return { name = "Roblox: policy panel", cases = cases } :: Assert.Suite
