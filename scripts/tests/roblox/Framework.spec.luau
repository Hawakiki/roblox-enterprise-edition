-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("../Assert")
local FakeRoblox = require("./FakeRoblox")

local ElementFactory = FakeRoblox.require("Presentation/ElementFactory")
local ReconciliationOrchestrator = FakeRoblox.require("Presentation/ReconciliationOrchestrator")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local function newOrchestrator(): any
	return ReconciliationOrchestrator.new({
		Create = function(_: any, className: string): any
			return FakeRoblox.instance(className)
		end,
	})
end

-- A counter whose button adds one, recording when it mounts and unmounts.
local function counterClass(log: { string }): any
	local Counter: any = {}
	Counter.__index = Counter
	function Counter.new(scope: any): any
		return setmetatable({ scope = scope, count = 0 }, Counter)
	end
	function Counter.Render(self: any, props: any): any
		return ElementFactory.CreateElement("Frame", { Size = props.size }, {
			Label = ElementFactory.CreateElement("TextLabel", { Text = "count " .. tostring(self.count) }),
			Button = ElementFactory.CreateElement("TextButton", {
				Text = "+",
				-- A new function on every render.
				OnActivated = function()
					self.count += 1
					self.scope:Invalidate()
				end,
			}),
		})
	end
	function Counter.DidMount(_: any)
		table.insert(log, "mount")
	end
	function Counter.WillUnmount(_: any)
		table.insert(log, "unmount")
	end
	return Counter
end

local function screen(Counter: any, props: any, size: string): any
	return ElementFactory.CreateElement("ScreenGui", props, {
		Counter = ElementFactory.CreateComponent(Counter, { size = size }),
	})
end

-- Mounts a counter screen under a new PlayerGui.
local function mountCounter(): (any, any, any, { string }, any)
	local log = {}
	local Counter = counterClass(log)
	local orchestrator = newOrchestrator()
	local playerGui = FakeRoblox.instance("PlayerGui")
	local tree = orchestrator:Mount(screen(Counter, { ResetOnSpawn = false }, "S"), playerGui, "EnterpriseEdition")
	return orchestrator, tree, playerGui, log, Counter
end

local function frameOf(playerGui: any): any
	return FakeRoblox.child(FakeRoblox.child(playerGui, "EnterpriseEdition"), "Counter")
end

-- A component that renders an empty frame and remembers its scope.
local function plainClass(holder: { scope: any }): any
	local Plain: any = {}
	Plain.__index = Plain
	function Plain.new(scope: any): any
		holder.scope = scope
		return setmetatable({}, Plain)
	end
	function Plain.Render(_: any): any
		return ElementFactory.CreateElement("Frame")
	end
	function Plain.DidMount(_: any) end
	function Plain.WillUnmount(_: any) end
	return Plain
end

case("a tree mounts under its key, with its properties and children", function()
	local _, _, playerGui, log = mountCounter()
	local gui = FakeRoblox.child(playerGui, "EnterpriseEdition")
	Assert.equal(gui.ClassName, "ScreenGui", "the root is named by its key")
	Assert.equal(gui.ResetOnSpawn, false, "its properties are set")
	local frame = frameOf(playerGui)
	Assert.equal(frame.ClassName, "Frame", "a component renders under its own key")
	Assert.equal(frame.Size, "S", "with the properties it was given")
	Assert.equal(FakeRoblox.child(frame, "Label").Text, "count 0", "children are mounted")
	Assert.equal(FakeRoblox.child(frame, "Button").Text, "+", "every child")
	Assert.equal(table.concat(log, ","), "mount", "DidMount runs once")
end)

case("an event re-renders the component in place", function()
	local _, _, playerGui = mountCounter()
	local frame = frameOf(playerGui)
	local label, button = FakeRoblox.child(frame, "Label"), FakeRoblox.child(frame, "Button")
	local before = #FakeRoblox.created
	button.Activated:Fire()
	Assert.equal(label.Text, "count 1", "an event re-renders the component")
	Assert.equal(#FakeRoblox.created, before, "re-rendering creates no instance")
	Assert.equal(FakeRoblox.child(frame, "Label"), label, "re-rendering keeps the instances")
	button.Activated:Fire()
	button.Activated:Fire()
	Assert.equal(label.Text, "count 3", "the current handler runs")
	Assert.equal(button.Activated:Count(), 1, "a new handler on every render costs no reconnection")
end)

case("an update from above keeps the component and its state", function()
	local orchestrator, tree, playerGui, log, Counter = mountCounter()
	local frame = frameOf(playerGui)
	local label = FakeRoblox.child(frame, "Label")
	FakeRoblox.child(frame, "Button").Activated:Fire()
	orchestrator:Update(tree, screen(Counter, { ResetOnSpawn = false }, "L"))
	Assert.equal(frame.Size, "L", "new properties reach the component")
	Assert.equal(frameOf(playerGui), frame, "in the same instance")
	Assert.equal(label.Text, "count 1", "the component keeps its state")
	Assert.equal(#log, 1, "nothing remounts")
end)

case("a property that disappears replaces the instance", function()
	local orchestrator, tree, playerGui, log, Counter = mountCounter()
	local oldGui = FakeRoblox.child(playerGui, "EnterpriseEdition")
	orchestrator:Update(tree, screen(Counter, {}, "L"))
	local gui = FakeRoblox.child(playerGui, "EnterpriseEdition")
	Assert.truthy(gui ~= oldGui and FakeRoblox.isDestroyed(oldGui), "the instance is replaced")
	Assert.equal(table.concat(log, ","), "mount,mount,unmount", "the new component mounts, then the old one unmounts")
	Assert.equal(FakeRoblox.child(frameOf(playerGui), "Label").Text, "count 0", "the new component starts afresh")
	Assert.equal(FakeRoblox.childCount(playerGui), 1, "one root stays under the parent")
end)

case("unmounting releases everything", function()
	local first = #FakeRoblox.created + 1
	local orchestrator, tree, playerGui, log = mountCounter()
	local button = FakeRoblox.child(frameOf(playerGui), "Button")
	orchestrator:Unmount(tree)
	Assert.equal(log[#log], "unmount", "WillUnmount runs")
	Assert.equal(FakeRoblox.childCount(playerGui), 0, "the root leaves the parent")
	Assert.equal(button.Activated:Count(), 0, "events are disconnected")
	for index = first, #FakeRoblox.created do
		local instance = FakeRoblox.created[index]
		if instance ~= playerGui then
			Assert.truthy(FakeRoblox.isDestroyed(instance), "every instance is destroyed: " .. instance.ClassName)
		end
	end
	orchestrator:Unmount(tree)
end)

case("an unmounted component cannot ask to be rendered again", function()
	local orchestrator = newOrchestrator()
	local holder = { scope = nil :: any }
	local tree =
		orchestrator:Mount(ElementFactory.CreateComponent(plainClass(holder)), FakeRoblox.instance("PlayerGui"), "Kept")
	orchestrator:Unmount(tree)
	Assert.raises(function()
		holder.scope:Invalidate()
	end, "unmounted component", "invalidating after unmount")
end)

case("a component that asks to be rendered again while it renders is refused", function()
	local Loop: any = {}
	Loop.__index = Loop
	function Loop.new(scope: any): any
		return setmetatable({ scope = scope, renders = 0 }, Loop)
	end
	function Loop.Render(self: any): any
		self.renders += 1
		if self.renders > 1 then
			self.scope:Invalidate()
		end
		return ElementFactory.CreateElement("Frame")
	end
	function Loop.DidMount(self: any)
		self.scope:Invalidate()
	end
	function Loop.WillUnmount(_: any) end
	Assert.raises(function()
		newOrchestrator():Mount(ElementFactory.CreateComponent(Loop), FakeRoblox.instance("PlayerGui"), "Loop")
	end, "while it renders", "invalidating while rendering")
end)

case("property and child keys are string literals", function()
	Assert.raises(function()
		ElementFactory.CreateElement("Frame", { [{}] = true })
	end, "string literal", "a computed property key")
	Assert.raises(function()
		ElementFactory.CreateElement("Frame", {}, { ElementFactory.CreateElement("Frame") })
	end, "string literal", "a computed child key")
end)

case("Dispose unmounts every tree, and nothing mounts after it", function()
	local orchestrator = newOrchestrator()
	local holder = FakeRoblox.instance("Folder")
	orchestrator:Mount(ElementFactory.CreateElement("Frame"), holder, "A")
	orchestrator:Mount(ElementFactory.CreateElement("Frame"), holder, "B")
	orchestrator:Dispose()
	Assert.equal(FakeRoblox.childCount(holder), 0, "Dispose unmounts every tree")
	Assert.raises(function()
		orchestrator:Mount(ElementFactory.CreateElement("Frame"), holder, "C")
	end, "disposed", "mounting after Dispose")
end)

-- A parent that shows a child, and shows in turn what the child reports once it has mounted. With nagging set,
-- the child reports on every render instead, which no parent can satisfy.
local function reportingParent(record: any): any
	local Child: any = {}
	Child.__index = Child
	function Child.new(scope: any): any
		return setmetatable({ scope = scope }, Child)
	end
	function Child.Render(_: any, props: any): any
		if record.nagging then
			props.report()
		end
		return ElementFactory.CreateElement("TextLabel", { Text = "child" })
	end
	function Child.DidMount(_: any, props: any)
		record.mounted += 1
		props.report()
	end
	function Child.WillUnmount(_: any)
		record.unmounted += 1
	end

	local Parent: any = {}
	Parent.__index = Parent
	function Parent.new(scope: any): any
		record.parent = setmetatable({ scope = scope, showChild = record.showChildAtFirst, reported = false }, Parent)
		return record.parent
	end
	function Parent.Render(self: any): any
		local children: any = {
			Status = ElementFactory.CreateElement("TextLabel", {
				Text = if self.reported then "child mounted" else "waiting",
			}),
		}
		if self.showChild then
			children.Child = ElementFactory.CreateComponent(Child, {
				report = function()
					if record.nagging or not self.reported then
						self.reported = true
						self.scope:Invalidate()
					end
				end,
			})
		end
		return ElementFactory.CreateElement("Frame", {}, children)
	end
	function Parent.DidMount(_: any) end
	function Parent.WillUnmount(_: any) end
	return Parent
end

local function newRecord(showChildAtFirst: boolean, nagging: boolean): any
	return { mounted = 0, unmounted = 0, parent = nil, showChildAtFirst = showChildAtFirst, nagging = nagging }
end

-- Defect 4 of CR-0018: a component invalidated while it updated mounted its child twice.
case("a parent that its child invalidates during the parent's update renders again after it", function()
	local record = newRecord(false, false)
	local orchestrator = newOrchestrator()
	local playerGui = FakeRoblox.instance("PlayerGui")
	local tree = orchestrator:Mount(ElementFactory.CreateComponent(reportingParent(record)), playerGui, "Panel")
	local frame = FakeRoblox.child(playerGui, "Panel")
	record.parent.showChild = true
	record.parent.scope:Invalidate()
	Assert.equal(#FakeRoblox.childrenNamed(frame, "Child"), 1, "the child is mounted once")
	Assert.equal(record.mounted, 1, "and told so once")
	Assert.equal(FakeRoblox.child(frame, "Status").Text, "child mounted", "the parent shows what the child reported")
	orchestrator:Unmount(tree)
	Assert.equal(record.unmounted, record.mounted, "every child that mounted unmounts")
end)

-- Defect 4 of CR-0018, during a mount, when the parent has rendered nothing yet.
case("a parent that its child invalidates during the parent's mount renders again after it", function()
	local record = newRecord(true, false)
	local playerGui = FakeRoblox.instance("PlayerGui")
	newOrchestrator():Mount(ElementFactory.CreateComponent(reportingParent(record)), playerGui, "Panel")
	local frame = FakeRoblox.child(playerGui, "Panel")
	Assert.equal(#FakeRoblox.childrenNamed(frame, "Child"), 1, "the child is mounted once")
	Assert.equal(FakeRoblox.child(frame, "Status").Text, "child mounted", "the parent shows what the child reported")
end)

case("a component that its children invalidate on every render is refused, not rendered forever", function()
	local record = newRecord(true, true)
	Assert.raises(function()
		newOrchestrator():Mount(
			ElementFactory.CreateComponent(reportingParent(record)),
			FakeRoblox.instance("PlayerGui"),
			"Panel"
		)
	end, "kept asking to be rendered again", "a child that reports on every render")
end)

return { name = "Roblox: presentation framework", cases = cases } :: Assert.Suite
