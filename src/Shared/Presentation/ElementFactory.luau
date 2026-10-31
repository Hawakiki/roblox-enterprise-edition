-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ElementFactory

	Describes what to show as elements: an instance of a Roblox class, or a component. An element is only a
	description; nothing is created until the reconciler mounts it.

	보여 줄 것을 요소로 기술한다. Roblox 클래스의 인스턴스이거나 컴포넌트이다. 요소는 기술일 뿐이며,
	조정자가 마운트하기 전에는 아무것도 만들어지지 않는다.
]=]

local ErrorLevelConstants = require(script.Parent.Parent.Kernel.ErrorLevelConstants)
local IComponent = require(script.Parent.IComponent)

local ElementFactory = {}

-- Every key is a string literal, so that Studio can type it. A computed key, such as a table, is refused here,
-- on behalf of the public function that received it.
local function requireStringKeys(entries: { [any]: any }, what: string)
	for key in entries do
		if type(key) ~= "string" then
			error(
				string.format("every key of %s is a string literal, but one is a %s", what, typeof(key)),
				ErrorLevelConstants.CALLER_OF_CALLER
			)
		end
	end
end

--[=[
	Describes an instance of a Roblox class, with its properties and its children.

	@within ElementFactory
	@param className string -- The Roblox class, such as TextButton.
	@param props Props? -- The properties; a property named On followed by an event, as in OnActivated, connects to it.
	@param children { [string]: Element }? -- The children, keyed by the name each one takes.
	@return Element -- The description.
]=]
function ElementFactory.CreateElement(
	className: string,
	props: IComponent.Props?,
	children: { [string]: IComponent.Element }?
): IComponent.Element
	local properties: IComponent.Props = props or {}
	local nested: { [string]: IComponent.Element } = children or {}
	requireStringKeys(properties, "the properties of an element")
	requireStringKeys(nested, "the children of an element")
	local element: IComponent.Element = {
		kind = "Host",
		className = className,
		props = properties,
		children = nested,
	}
	return element
end

--[=[
	Describes a component, with the properties it renders from.

	@within ElementFactory
	@param component ComponentClass -- The class of the component.
	@param props Props? -- The properties passed to its Render method.
	@return Element -- The description.
]=]
function ElementFactory.CreateComponent(
	component: IComponent.ComponentClass,
	props: IComponent.Props?
): IComponent.Element
	local properties: IComponent.Props = props or {}
	requireStringKeys(properties, "the properties of a component")
	local element: IComponent.Element = {
		kind = "Component",
		component = component,
		props = properties,
		children = {},
	}
	return element
end

return ElementFactory
