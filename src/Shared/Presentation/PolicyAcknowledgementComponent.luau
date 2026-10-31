-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class PolicyAcknowledgementComponent

	The first user interface of the Company: a panel on which a player acknowledges the policies of the Company,
	and sees the compliance coins the server has rewarded them with (CR-0011). The panel only asks; the server
	decides.

	회사의 첫 사용자 인터페이스. 플레이어가 회사의 정책을 확인했음을 표시하고, 서버가 보상한 준법 코인을 보는
	패널이다(CR-0011). 패널은 요청만 하고, 결정은 서버가 한다.
]=]

local ComponentScope = require(script.Parent.ComponentScope)
local CorporatePaletteConstants = require(script.Parent.Parent.Kernel.CorporatePaletteConstants)
local ElementFactory = require(script.Parent.ElementFactory)
local IAcknowledgementGateway = require(script.Parent.Parent.Application.IAcknowledgementGateway)
local ICoinBalanceSource = require(script.Parent.Parent.Application.ICoinBalanceSource)
local IComponent = require(script.Parent.IComponent)
local InterfaceLayoutConstants = require(script.Parent.InterfaceLayoutConstants)

--[=[
	@interface PolicyAcknowledgementProps
	@within PolicyAcknowledgementComponent
	.CoinBalance ICoinBalanceSource -- The balance of the local player.
	.AcknowledgementGateway IAcknowledgementGateway -- Where an acknowledgement is sent.

	The properties of the panel.

	패널의 속성.
]=]
type PolicyAcknowledgementProps = {
	CoinBalance: ICoinBalanceSource.ICoinBalanceSource,
	AcknowledgementGateway: IAcknowledgementGateway.IAcknowledgementGateway,
}

type ComponentState = {
	_scope: ComponentScope.ComponentScope,
}

local PolicyAcknowledgementComponent = {}
PolicyAcknowledgementComponent.__index = PolicyAcknowledgementComponent

export type PolicyAcknowledgementComponent = typeof(setmetatable({} :: ComponentState, PolicyAcknowledgementComponent))

-- Reads the properties of the panel. Every property is any, so each is taken as the type the panel expects.
local function panelProps(props: IComponent.Props): PolicyAcknowledgementProps
	return {
		CoinBalance = props.CoinBalance,
		AcknowledgementGateway = props.AcknowledgementGateway,
	}
end

-- The rounded corners of a panel or a button.
local function corner(radius: UDim): IComponent.Element
	return ElementFactory.CreateElement("UICorner", {
		CornerRadius = radius,
	})
end

--[=[
	Creates the panel. Like every constructor, it returns the contract, not the implementation.

	@within PolicyAcknowledgementComponent
	@param scope ComponentScope -- The scope the component owns, through which it asks to be rendered again.
	@return IComponent -- The component, as the contract it implements.
]=]
function PolicyAcknowledgementComponent.new(scope: ComponentScope.ComponentScope): IComponent.IComponent
	local state: ComponentState = {
		_scope = scope,
	}
	return setmetatable(state, PolicyAcknowledgementComponent) :: any
end

--[=[
	Describes the panel: a heading, the coins of the player, and the button that acknowledges the policies.

	@within PolicyAcknowledgementComponent
	@method Render
	@param props Props -- A PolicyAcknowledgementProps.
	@return Element -- The panel.
]=]
function PolicyAcknowledgementComponent.Render(
	self: PolicyAcknowledgementComponent,
	props: IComponent.Props
): IComponent.Element
	local panel = panelProps(props)
	local coins = panel.CoinBalance:Get()
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
			Text = string.format("Compliance coins: %d\n준법 코인: %d개", coins, coins),
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
				panel.AcknowledgementGateway:Send()
			end,
		}, {
			Corner = corner(InterfaceLayoutConstants.BUTTON_CORNER_RADIUS),
		}),
	})
end

--[=[
	Follows the balance of the player, and renders the panel again whenever it changes. The subscription belongs
	to the scope of the panel, so it ends when the panel unmounts.

	@within PolicyAcknowledgementComponent
	@method DidMount
	@param props Props -- A PolicyAcknowledgementProps.
]=]
function PolicyAcknowledgementComponent.DidMount(self: PolicyAcknowledgementComponent, props: IComponent.Props)
	local panel = panelProps(props)
	self._scope:Adopt(panel.CoinBalance:Subscribe(function()
		self._scope:Invalidate()
	end))
end

--[=[
	Does nothing: the scope of the panel already releases everything it acquired.

	@within PolicyAcknowledgementComponent
	@method WillUnmount
]=]
function PolicyAcknowledgementComponent.WillUnmount(self: PolicyAcknowledgementComponent) end

-- Declares the contract this class implements. Each entry is written with the signature of the contract and
-- calls the method, so that both type solvers hold the method to it (EE-STD-0006 §6).
local _implements: IComponent.IComponent = {
	Render = function(self: any, props: IComponent.Props): IComponent.Element
		return PolicyAcknowledgementComponent.Render(self, props)
	end,
	DidMount = function(self: any, props: IComponent.Props)
		PolicyAcknowledgementComponent.DidMount(self, props)
	end,
	WillUnmount = function(self: any)
		PolicyAcknowledgementComponent.WillUnmount(self)
	end,
}

return PolicyAcknowledgementComponent
