-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class PolicyAcknowledgementComponent

	The first user interface of the Company: a panel on which a player acknowledges the policies of the Company
	and sees how often they have done so. Acknowledging changes nothing else.

	회사의 첫 사용자 인터페이스. 플레이어가 회사의 정책을 확인했음을 표시하고 그 횟수를 보는 패널이다.
	확인해도 다른 것은 아무것도 바뀌지 않는다.
]=]

local ComponentScope = require(script.Parent.ComponentScope)
local CorporatePaletteConstants = require(script.Parent.Parent.Kernel.CorporatePaletteConstants)
local ElementFactory = require(script.Parent.ElementFactory)
local IComponent = require(script.Parent.IComponent)
local InterfaceLayoutConstants = require(script.Parent.InterfaceLayoutConstants)

type ComponentState = {
	_scope: ComponentScope.ComponentScope,
	_acknowledgements: number,
}

local PolicyAcknowledgementComponent = {}
PolicyAcknowledgementComponent.__index = PolicyAcknowledgementComponent

export type PolicyAcknowledgementComponent = typeof(setmetatable({} :: ComponentState, PolicyAcknowledgementComponent))

-- The rounded corners of a panel or a button.
local function corner(radius: UDim): IComponent.Element
	return ElementFactory.CreateElement("UICorner", {
		CornerRadius = radius,
	})
end

--[=[
	Creates the panel, with no acknowledgement on record. Like every constructor, it returns the contract,
	not the implementation.

	@within PolicyAcknowledgementComponent
	@param scope ComponentScope -- The scope the component owns, through which it asks to be rendered again.
	@return IComponent -- The component, as the contract it implements.
]=]
function PolicyAcknowledgementComponent.new(scope: ComponentScope.ComponentScope): IComponent.IComponent
	local state: ComponentState = {
		_scope = scope,
		_acknowledgements = 0,
	}
	return setmetatable(state, PolicyAcknowledgementComponent) :: any
end

-- Puts one more acknowledgement on record, and asks to be rendered again.
function PolicyAcknowledgementComponent._Acknowledge(self: PolicyAcknowledgementComponent)
	self._acknowledgements += 1
	self._scope:Invalidate()
end

--[=[
	Describes the panel: a heading, the number of acknowledgements on record, and the button that adds one.

	@within PolicyAcknowledgementComponent
	@method Render
	@param props Props -- The panel takes no properties.
	@return Element -- The panel.
]=]
function PolicyAcknowledgementComponent.Render(
	self: PolicyAcknowledgementComponent,
	props: IComponent.Props
): IComponent.Element
	local count = self._acknowledgements
	return ElementFactory.CreateElement("Frame", {
		AnchorPoint = InterfaceLayoutConstants.PANEL_ANCHOR_POINT,
		Position = InterfaceLayoutConstants.PANEL_POSITION,
		Size = InterfaceLayoutConstants.PANEL_SIZE,
		BackgroundColor3 = CorporatePaletteConstants.CORPORATE_NAVY,
		BorderSizePixel = 0,
	}, {
		Corner = corner(InterfaceLayoutConstants.PANEL_CORNER_RADIUS),
		Padding = ElementFactory.CreateElement("UIPadding", {
			PaddingTop = InterfaceLayoutConstants.PANEL_PADDING,
			PaddingBottom = InterfaceLayoutConstants.PANEL_PADDING,
			PaddingLeft = InterfaceLayoutConstants.PANEL_PADDING,
			PaddingRight = InterfaceLayoutConstants.PANEL_PADDING,
		}),
		Layout = ElementFactory.CreateElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = InterfaceLayoutConstants.ROW_SPACING,
		}),
		Title = ElementFactory.CreateElement("TextLabel", {
			LayoutOrder = InterfaceLayoutConstants.TITLE_ORDER,
			Size = InterfaceLayoutConstants.TITLE_ROW_SIZE,
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			TextSize = InterfaceLayoutConstants.TITLE_TEXT_SIZE_PIXELS,
			TextColor3 = CorporatePaletteConstants.CORPORATE_WHITE,
			Text = "Corporate Policy Acknowledgement\n사내 정책 확인",
		}),
		Status = ElementFactory.CreateElement("TextLabel", {
			LayoutOrder = InterfaceLayoutConstants.STATUS_ORDER,
			Size = InterfaceLayoutConstants.STATUS_ROW_SIZE,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = InterfaceLayoutConstants.STATUS_TEXT_SIZE_PIXELS,
			TextColor3 = CorporatePaletteConstants.CORPORATE_SILVER,
			Text = string.format("Acknowledgements on record: %d\n확인 기록: %d건", count, count),
		}),
		Acknowledge = ElementFactory.CreateElement("TextButton", {
			LayoutOrder = InterfaceLayoutConstants.BUTTON_ORDER,
			Size = InterfaceLayoutConstants.BUTTON_SIZE,
			BackgroundColor3 = CorporatePaletteConstants.APPROVAL_GREEN,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			TextSize = InterfaceLayoutConstants.BUTTON_TEXT_SIZE_PIXELS,
			TextColor3 = CorporatePaletteConstants.CORPORATE_WHITE,
			Text = "I have read and agree\n읽었으며 동의합니다",
			OnActivated = function()
				self:_Acknowledge()
			end,
		}, {
			Corner = corner(InterfaceLayoutConstants.BUTTON_CORNER_RADIUS),
		}),
	})
end

--[=[
	Does nothing: the panel needs nothing once it is shown.

	@within PolicyAcknowledgementComponent
	@method DidMount
]=]
function PolicyAcknowledgementComponent.DidMount(self: PolicyAcknowledgementComponent) end

--[=[
	Does nothing: the panel acquired nothing that its scope does not already release.

	@within PolicyAcknowledgementComponent
	@method WillUnmount
]=]
function PolicyAcknowledgementComponent.WillUnmount(self: PolicyAcknowledgementComponent) end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: IComponent.IComponent = {
	Render = PolicyAcknowledgementComponent.Render,
	DidMount = PolicyAcknowledgementComponent.DidMount,
	WillUnmount = PolicyAcknowledgementComponent.WillUnmount,
}

return PolicyAcknowledgementComponent
