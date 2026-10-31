-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class InterfaceLayoutConstants

	The sizes, positions and orders of the user interface, so that no component holds a number (EE-STD-0005).

	사용자 인터페이스의 크기, 위치, 순서. 어떤 컴포넌트도 숫자를 담지 않게 한다(EE-STD-0005).
]=]

local InterfaceLayoutConstants = {}

--[=[
	@prop PANEL_ANCHOR_POINT Vector2
	@within InterfaceLayoutConstants
	@readonly
	A panel hangs from the middle of its top edge.
]=]
InterfaceLayoutConstants.PANEL_ANCHOR_POINT = Vector2.new(0.5, 0)

--[=[
	@prop PANEL_POSITION UDim2
	@within InterfaceLayoutConstants
	@readonly
	A panel sits at the top of the screen, in the middle, clear of the top bar.
]=]
InterfaceLayoutConstants.PANEL_POSITION = UDim2.new(0.5, 0, 0, 24)

--[=[
	@prop PANEL_SIZE UDim2
	@within InterfaceLayoutConstants
	@readonly
	The size of the policy acknowledgement panel: its padding, three rows and the spacing between them.
]=]
InterfaceLayoutConstants.PANEL_SIZE = UDim2.fromOffset(400, 176)

--[=[
	@prop PANEL_PADDING UDim
	@within InterfaceLayoutConstants
	@readonly
	The space between the edge of a panel and its contents.
]=]
InterfaceLayoutConstants.PANEL_PADDING = UDim.new(0, 16)

--[=[
	@prop PANEL_CORNER_RADIUS UDim
	@within InterfaceLayoutConstants
	@readonly
	The rounding of the corners of a panel.
]=]
InterfaceLayoutConstants.PANEL_CORNER_RADIUS = UDim.new(0, 12)

--[=[
	@prop ROW_SPACING UDim
	@within InterfaceLayoutConstants
	@readonly
	The space between the rows of a panel.
]=]
InterfaceLayoutConstants.ROW_SPACING = UDim.new(0, 8)

--[=[
	@prop TITLE_ROW_SIZE UDim2
	@within InterfaceLayoutConstants
	@readonly
	A heading row, tall enough for a line of English and a line of Korean.
]=]
InterfaceLayoutConstants.TITLE_ROW_SIZE = UDim2.new(1, 0, 0, 44)

--[=[
	@prop STATUS_ROW_SIZE UDim2
	@within InterfaceLayoutConstants
	@readonly
	A row of status text, tall enough for a line of English and a line of Korean.
]=]
InterfaceLayoutConstants.STATUS_ROW_SIZE = UDim2.new(1, 0, 0, 36)

--[=[
	@prop BUTTON_SIZE UDim2
	@within InterfaceLayoutConstants
	@readonly
	A button as wide as its panel, tall enough for a line of English and a line of Korean.
]=]
InterfaceLayoutConstants.BUTTON_SIZE = UDim2.new(1, 0, 0, 48)

--[=[
	@prop BUTTON_CORNER_RADIUS UDim
	@within InterfaceLayoutConstants
	@readonly
	The rounding of the corners of a button.
]=]
InterfaceLayoutConstants.BUTTON_CORNER_RADIUS = UDim.new(0, 8)

--[=[
	@prop TITLE_TEXT_SIZE_PIXELS number
	@within InterfaceLayoutConstants
	@readonly
	The size of the text of a heading.
]=]
InterfaceLayoutConstants.TITLE_TEXT_SIZE_PIXELS = 18

--[=[
	@prop STATUS_TEXT_SIZE_PIXELS number
	@within InterfaceLayoutConstants
	@readonly
	The size of status text.
]=]
InterfaceLayoutConstants.STATUS_TEXT_SIZE_PIXELS = 14

--[=[
	@prop BUTTON_TEXT_SIZE_PIXELS number
	@within InterfaceLayoutConstants
	@readonly
	The size of the text of a button.
]=]
InterfaceLayoutConstants.BUTTON_TEXT_SIZE_PIXELS = 16

--[=[
	@prop TITLE_ORDER number
	@within InterfaceLayoutConstants
	@readonly
	The place of the heading in a panel. One may be written anywhere, but an order deserves a name.
]=]
InterfaceLayoutConstants.TITLE_ORDER = 1

--[=[
	@prop STATUS_ORDER number
	@within InterfaceLayoutConstants
	@readonly
	The place of the status text in a panel.
]=]
InterfaceLayoutConstants.STATUS_ORDER = 2

--[=[
	@prop BUTTON_ORDER number
	@within InterfaceLayoutConstants
	@readonly
	The place of the button in a panel.
]=]
InterfaceLayoutConstants.BUTTON_ORDER = 3

return table.freeze(InterfaceLayoutConstants)
