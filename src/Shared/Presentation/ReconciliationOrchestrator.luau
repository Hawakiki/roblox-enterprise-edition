-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ReconciliationOrchestrator

	Keeps the instances of the place in step with what components render. It mounts a tree of elements, updates
	it in place when an element changes, and unmounts it, releasing everything in reverse order. It never calls
	Instance.new: every instance comes from the factory it is given (EE-STD-0003 §5).

	플레이스의 인스턴스를 컴포넌트가 그린 것과 일치시킨다. 요소의 트리를 마운트하고, 요소가 바뀌면 그 자리에서
	갱신하며, 언마운트할 때는 모든 것을 역순으로 해제한다. Instance.new 를 부르지 않으며, 모든 인스턴스는
	주어진 팩토리에서 온다(EE-STD-0003 §5).
]=]

local ComponentScope = require(script.Parent.ComponentScope)
local ErrorLevelConstants = require(script.Parent.Parent.Kernel.ErrorLevelConstants)
local IComponent = require(script.Parent.IComponent)
local IDisposable = require(script.Parent.Parent.Kernel.IDisposable)
local IInstanceFactory = require(script.Parent.Parent.Application.IInstanceFactory)
local ReconciliationConstants = require(script.Parent.ReconciliationConstants)
local ResourceScope = require(script.Parent.Parent.Kernel.ResourceScope)

-- A property named On followed by the name of an event, as in OnActivated, whose value is a function.
local EVENT_PROPERTY = "^On(%u%w*)$"

type Node = {
	element: IComponent.Element,
	key: string,
	parent: Instance,
	-- A host node owns its instance and the connections to its events, and remembers the handler of each event.
	instance: Instance?,
	resources: ResourceScope.ResourceScope?,
	handlers: { [string]: (...any) -> () },
	connected: { [string]: boolean },
	children: { [string]: Node },
	-- A component node owns its component and the scope of the component, and the node of what it rendered.
	component: IComponent.IComponent?,
	scope: ComponentScope.ComponentScope?,
	rendered: Node?,
	rendering: boolean,
	-- Whether the component is mounting or updating what it rendered, and has been invalidated meanwhile (CR-0018).
	updating: boolean,
	pending: boolean,
}

--[=[
	@type MountedTree table
	@within ReconciliationOrchestrator
	A tree that Mount returned, to be updated or unmounted later. Its contents belong to the reconciler.
]=]
export type MountedTree = {
	_root: Node?,
}

type OrchestratorState = {
	_instanceFactory: IInstanceFactory.IInstanceFactory,
	_trees: { MountedTree },
	_disposed: boolean,
}

local ReconciliationOrchestrator = {}
ReconciliationOrchestrator.__index = ReconciliationOrchestrator

export type ReconciliationOrchestrator = typeof(setmetatable({} :: OrchestratorState, ReconciliationOrchestrator))

local mountNode: (self: ReconciliationOrchestrator, element: IComponent.Element, parent: Instance, key: string) -> Node
local updateNode: (self: ReconciliationOrchestrator, node: Node, element: IComponent.Element) -> Node
local unmountNode: (self: ReconciliationOrchestrator, node: Node) -> ()

local function eventOf(key: string, value: any): string?
	if type(value) ~= "function" then
		return nil
	end
	local event: string? = string.match(key, EVENT_PROPERTY)
	return event
end

local function newNode(element: IComponent.Element, parent: Instance, key: string): Node
	return {
		element = element,
		key = key,
		parent = parent,
		instance = nil,
		resources = nil,
		handlers = {},
		connected = {},
		children = {},
		component = nil,
		scope = nil,
		rendered = nil,
		rendering = false,
		updating = false,
		pending = false,
	}
end

-- Sets one property of a host node. An event is connected the first time a handler is given for it, and the
-- connection calls whichever handler is current, so that a new function on every render costs no reconnection.
local function setProperty(node: Node, key: string, value: any)
	local instance: any = node.instance
	local event = eventOf(key, value)
	if event == nil then
		instance[key] = value
		return
	end
	node.handlers[event] = value
	if node.connected[event] then
		return
	end
	node.connected[event] = true
	local resources = node.resources :: ResourceScope.ResourceScope
	resources:Adopt(instance[event]:Connect(function(...)
		local handler = node.handlers[event]
		if handler then
			handler(...)
		end
	end))
end

-- Renders a component, and refuses one that asks to be rendered again while it renders.
local function renderComponent(node: Node): IComponent.Element
	local component = node.component :: IComponent.IComponent
	node.rendering = true
	local ok, result = pcall(function(): any
		return component:Render(node.element.props)
	end)
	node.rendering = false
	if not ok then
		error(result, ErrorLevelConstants.WITHOUT_POSITION)
	end
	return result
end

-- Renders a component again. One invalidated while it mounts or updates what it rendered, as by a child that it
-- is mounting, renders again once that has finished rather than in the middle of it, as React batches updates.
local function rerender(self: ReconciliationOrchestrator, node: Node)
	if node.rendering then
		error("a component cannot ask to be rendered again while it renders", ErrorLevelConstants.CALLER)
	end
	if node.updating then
		node.pending = true
		return
	end
	node.updating = true
	local ok, problem = pcall(function(): any
		local renders = 0
		repeat
			renders += 1
			if renders > ReconciliationConstants.MAXIMUM_RERENDERS then
				error("a component kept asking to be rendered again while it updated", ErrorLevelConstants.CALLER)
			end
			node.pending = false
			local rendered = renderComponent(node)
			node.rendered = updateNode(self, node.rendered :: Node, rendered)
		until not node.pending
		return nil
	end)
	node.updating = false
	if not ok then
		error(problem, ErrorLevelConstants.WITHOUT_POSITION)
	end
end

local function replaceNode(self: ReconciliationOrchestrator, node: Node, element: IComponent.Element): Node
	local replacement = mountNode(self, element, node.parent, node.key)
	unmountNode(self, node)
	return replacement
end

local function mountHost(
	self: ReconciliationOrchestrator,
	element: IComponent.Element,
	parent: Instance,
	key: string
): Node
	local node = newNode(element, parent, key)
	local resources = ResourceScope.new()
	local instance = resources:Adopt(self._instanceFactory:Create(element.className :: string))
	node.instance = instance
	node.resources = resources
	instance.Name = key
	for property, value in element.props do
		setProperty(node, property, value)
	end
	for childKey, child in element.children do
		node.children[childKey] = mountNode(self, child, instance, childKey)
	end
	-- Parented last, so that the place receives the instance whole.
	instance.Parent = parent
	return node
end

local function mountComponent(
	self: ReconciliationOrchestrator,
	element: IComponent.Element,
	parent: Instance,
	key: string
): Node
	local node = newNode(element, parent, key)
	local scope = ComponentScope.new(function()
		rerender(self, node)
	end)
	local class = element.component :: IComponent.ComponentClass
	local component = class.new(scope)
	node.scope = scope
	node.component = component
	node.updating = true
	node.rendered = mountNode(self, renderComponent(node), parent, key)
	node.updating = false
	component:DidMount(element.props)
	if node.pending then
		rerender(self, node)
	end
	return node
end

mountNode = function(self: ReconciliationOrchestrator, element: IComponent.Element, parent: Instance, key: string): Node
	if element.kind == "Component" then
		return mountComponent(self, element, parent, key)
	end
	return mountHost(self, element, parent, key)
end

updateNode = function(self: ReconciliationOrchestrator, node: Node, element: IComponent.Element): Node
	local previous = node.element
	if
		previous.kind ~= element.kind
		or previous.className ~= element.className
		or previous.component ~= element.component
	then
		return replaceNode(self, node, element)
	end
	if element.kind == "Component" then
		node.element = element
		rerender(self, node)
		return node
	end

	-- A property that disappears cannot be returned to its default, so the instance is replaced.
	for property, value in previous.props do
		if element.props[property] == nil and eventOf(property, value) == nil then
			return replaceNode(self, node, element)
		end
	end
	for property, value in previous.props do
		local event = eventOf(property, value)
		if event and element.props[property] == nil then
			node.handlers[event] = nil
		end
	end
	for property, value in element.props do
		if previous.props[property] ~= value then
			setProperty(node, property, value)
		end
	end

	local removed = {}
	for childKey in node.children do
		if element.children[childKey] == nil then
			table.insert(removed, childKey)
		end
	end
	for _, childKey in removed do
		unmountNode(self, node.children[childKey])
		node.children[childKey] = nil
	end
	for childKey, child in element.children do
		local existing = node.children[childKey]
		node.children[childKey] = if existing
			then updateNode(self, existing, child)
			else mountNode(self, child, node.instance :: Instance, childKey)
	end
	node.element = element
	return node
end

unmountNode = function(self: ReconciliationOrchestrator, node: Node)
	local component = node.component
	if component then
		component:WillUnmount()
		unmountNode(self, node.rendered :: Node)
		local scope = node.scope :: ComponentScope.ComponentScope
		scope:Dispose()
		return
	end
	-- Indexed rather than iterated: the old solver instantiates the generic methods of a loop variable's type
	-- apart from the declared Node, and then finds the two unequal.
	for childKey in node.children do
		unmountNode(self, node.children[childKey])
	end
	local resources = node.resources :: ResourceScope.ResourceScope
	resources:Dispose()
end

--[=[
	Creates a reconciler that obtains its instances from a factory.

	@within ReconciliationOrchestrator
	@param instanceFactory IInstanceFactory -- Creates every instance the reconciler mounts.
	@return ReconciliationOrchestrator -- The reconciler, with nothing mounted.
]=]
function ReconciliationOrchestrator.new(instanceFactory: IInstanceFactory.IInstanceFactory): ReconciliationOrchestrator
	local state: OrchestratorState = {
		_instanceFactory = instanceFactory,
		_trees = {},
		_disposed = false,
	}
	return setmetatable(state, ReconciliationOrchestrator)
end

--[=[
	Creates the instances that an element describes, and parents them under parent.

	@within ReconciliationOrchestrator
	@method Mount
	@param element Element -- What to show.
	@param parent Instance -- Where to show it.
	@param key string -- The name of the instance at the top of the tree.
	@return MountedTree -- The tree, to update or unmount later.
]=]
function ReconciliationOrchestrator.Mount(
	self: ReconciliationOrchestrator,
	element: IComponent.Element,
	parent: Instance,
	key: string
): MountedTree
	if self._disposed then
		error("a disposed reconciler cannot mount a tree", ErrorLevelConstants.CALLER)
	end
	local tree: MountedTree = {
		_root = mountNode(self, element, parent, key),
	}
	table.insert(self._trees, tree)
	return tree
end

--[=[
	Brings a mounted tree in step with a new element, changing only what differs.

	@within ReconciliationOrchestrator
	@method Update
	@param tree MountedTree -- A tree that Mount returned.
	@param element Element -- What to show now.
]=]
function ReconciliationOrchestrator.Update(
	self: ReconciliationOrchestrator,
	tree: MountedTree,
	element: IComponent.Element
)
	local root = tree._root
	if root == nil then
		error("an unmounted tree cannot be updated", ErrorLevelConstants.CALLER)
	end
	tree._root = updateNode(self, root, element)
end

--[=[
	Unmounts a tree: every component is told, and every instance and connection is released, last acquired first.
	Unmounting a tree twice does nothing.

	@within ReconciliationOrchestrator
	@method Unmount
	@param tree MountedTree -- A tree that Mount returned.
]=]
function ReconciliationOrchestrator.Unmount(self: ReconciliationOrchestrator, tree: MountedTree)
	local root = tree._root
	if root == nil then
		return
	end
	tree._root = nil
	local index = table.find(self._trees, tree)
	if index then
		table.remove(self._trees, index)
	end
	unmountNode(self, root)
end

--[=[
	Unmounts every tree that is still mounted, the last mounted first. A disposed reconciler mounts nothing.

	@within ReconciliationOrchestrator
	@method Dispose
]=]
function ReconciliationOrchestrator.Dispose(self: ReconciliationOrchestrator)
	if self._disposed then
		return
	end
	self._disposed = true
	while #self._trees > 0 do
		self:Unmount(self._trees[#self._trees])
	end
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: IDisposable.IDisposable = {
	Dispose = ReconciliationOrchestrator.Dispose,
}

return ReconciliationOrchestrator
