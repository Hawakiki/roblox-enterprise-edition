-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CorporatePaletteConstants

	The corporate colour palette: every colour of the Company, and the only module that makes one.
	It lives in the Kernel, because every layer that draws may require the Kernel, and the Domain draws nothing.

	사내 색상 팔레트. 회사의 모든 색을 담으며, 색을 만드는 유일한 모듈이다.
	그림을 그리는 모든 계층이 Kernel 을 require 할 수 있고 Domain 은 아무것도 그리지 않으므로 Kernel 에 둔다.
]=]

local CorporatePaletteConstants = {}

--[=[
	@prop CORPORATE_GREY Color3
	@within CorporatePaletteConstants
	@readonly
	The grey of the Baseplate, the only colour the Company has used so far.
	default.project.json states it again, because Rojo reads the place from JSON, which cannot require a module.
]=]
CorporatePaletteConstants.CORPORATE_GREY = Color3.new(0.38, 0.37, 0.39)

return table.freeze(CorporatePaletteConstants)
