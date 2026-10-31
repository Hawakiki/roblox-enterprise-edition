-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CoinConstants

	The numbers of the compliance incentive programme.

	준법 인센티브 제도의 숫자.
]=]

local CoinConstants = {}

--[=[
	@prop INITIAL_BALANCE number
	@within CoinConstants
	@readonly
	The balance of a player who has never acknowledged anything.
]=]
CoinConstants.INITIAL_BALANCE = 0

--[=[
	@prop COINS_PER_ACKNOWLEDGEMENT number
	@within CoinConstants
	@readonly
	The reward for one acknowledgement of the policies of the Company.
]=]
CoinConstants.COINS_PER_ACKNOWLEDGEMENT = 1

--[=[
	@prop MAXIMUM_BALANCE number
	@within CoinConstants
	@readonly
	2^53 - 1, the largest whole number a Luau number holds exactly. Beyond it, adding a coin changes nothing.
]=]
CoinConstants.MAXIMUM_BALANCE = 9007199254740991

--[=[
	@prop MINIMUM_ACKNOWLEDGEMENT_INTERVAL_SECONDS number
	@within CoinConstants
	@readonly
	The shortest time between two acknowledgements of one player that both earn a coin.
]=]
CoinConstants.MINIMUM_ACKNOWLEDGEMENT_INTERVAL_SECONDS = 0.25

return table.freeze(CoinConstants)
