-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class SequenceConstants

	The numbers of sequences, by name: where a sequence starts, how it is walked backwards and how long it is when empty.
	Luau counts from one. The Company says so, in writing.

	시퀀스에 쓰는 숫자에 붙인 이름. 시퀀스가 어디서 시작하는지, 어떻게 거꾸로 걷는지, 비었을 때 길이가 얼마인지이다.
	Luau 는 1부터 센다. 회사는 이를 문서로 밝힌다.
]=]

local SequenceConstants = {}

--[=[
	@prop FIRST_INDEX number
	@within SequenceConstants
	@readonly
	The index of the first element of a sequence.
]=]
SequenceConstants.FIRST_INDEX = 1

--[=[
	@prop REVERSE_STEP number
	@within SequenceConstants
	@readonly
	The step of a numeric for loop that walks a sequence from its last element to its first.
]=]
SequenceConstants.REVERSE_STEP = -1

--[=[
	@prop EMPTY_LENGTH number
	@within SequenceConstants
	@readonly
	The length of a sequence that holds no elements.
]=]
SequenceConstants.EMPTY_LENGTH = 0

return table.freeze(SequenceConstants)
