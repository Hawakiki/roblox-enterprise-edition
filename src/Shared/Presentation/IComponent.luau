-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class IComponent

	The contract of a component, and the shape of the elements that components render.

	컴포넌트의 계약, 그리고 컴포넌트가 그리는 요소의 모양.
]=]

local ComponentScope = require(script.Parent.ComponentScope)

--[=[
	@type Props { [string]: any }
	@within IComponent
	The properties of an element. Every key is a string literal; a property named On followed by the name of an
	event, such as OnActivated, connects a function to that event.
]=]
export type Props = { [string]: any }

--[=[
	@interface Element
	@within IComponent
	.kind "Host" | "Component" -- Whether the element is an instance of a Roblox class or a component.
	.className string? -- The Roblox class of a host element.
	.component ComponentClass? -- The class of a component element.
	.props Props -- The properties of the element.
	.children { [string]: Element } -- The children of a host element, keyed by the name each one takes.

	A description of something to show. Nothing is created until the reconciler mounts it.

	보여 줄 것의 기술. 조정자가 마운트하기 전에는 아무것도 만들어지지 않는다.
]=]
export type Element = {
	kind: "Host" | "Component",
	className: string?,
	component: ComponentClass?,
	props: Props,
	children: { [string]: Element },
}

--[=[
	@interface IComponent
	@within IComponent
	.Render (self: any, props: Props) -> Element -- Describes what the component shows for its properties.
	.DidMount (self: any) -> () -- Runs once what the component rendered is in the place.
	.WillUnmount (self: any) -> () -- Runs before the component leaves the place; its scope is disposed after.

	The members that every component implements. A component keeps its state in its own fields, and asks its
	scope to render it again when that state changes.

	모든 컴포넌트가 구현하는 멤버. 컴포넌트는 상태를 자기 필드에 두고, 상태가 바뀌면 자신의 범위에 다시
	그려 달라고 요청한다.
]=]
export type IComponent = {
	Render: (self: any, props: Props) -> Element,
	DidMount: (self: any) -> (),
	WillUnmount: (self: any) -> (),
}

--[=[
	@interface ComponentClass
	@within IComponent
	.new (scope: ComponentScope) -> IComponent -- Creates a component that owns the scope it is given.

	What a component element names: a class whose constructor takes the scope of the component.

	컴포넌트 요소가 가리키는 것. 생성자가 컴포넌트의 범위를 받는 클래스이다.
]=]
export type ComponentClass = {
	new: (scope: ComponentScope.ComponentScope) -> IComponent,
}

return {}
