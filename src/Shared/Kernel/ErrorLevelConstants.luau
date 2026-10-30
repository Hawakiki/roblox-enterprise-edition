-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ErrorLevelConstants

	The levels passed to `error`, by name. A level decides whose line an error message blames,
	and a decision of that weight deserves a name.

	`error` 에 넘기는 수준에 붙인 이름. 수준은 오류 메시지가 누구의 줄을 탓할지 정하며,
	그만한 무게의 결정에는 이름이 있어야 한다.
]=]

local ErrorLevelConstants = table.freeze({
	--[=[
		@prop WITHOUT_POSITION number
		@within ErrorLevelConstants
		@readonly
		Adds no position to the message. Used to raise a caught error again exactly as it was caught.
	]=]
	WITHOUT_POSITION = 0,

	--[=[
		@prop CALLER number
		@within ErrorLevelConstants
		@readonly
		Blames the caller of the function that raises the error.
	]=]
	CALLER = 2,

	--[=[
		@prop CALLER_OF_CALLER number
		@within ErrorLevelConstants
		@readonly
		Blames the caller of the caller. Used by a private helper that raises on behalf of a public function.
	]=]
	CALLER_OF_CALLER = 3,
})

return ErrorLevelConstants
