-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class CoinSessionConstants

	The timing and the messages of a session with a wallet.

	지갑을 가진 세션의 시간과 안내문.
]=]

local CoinSessionConstants = {}

--[=[
	@prop AUTOSAVE_INTERVAL_SECONDS number
	@within CoinSessionConstants
	@readonly
	How often every wallet is saved while its player stays. Sixty, which the Numeric Literal Standard does not exempt.
]=]
CoinSessionConstants.AUTOSAVE_INTERVAL_SECONDS = 60

--[=[
	@prop UNAVAILABLE_MESSAGE string
	@within CoinSessionConstants
	@readonly
	Shown to a player whose wallet could not be loaded.
]=]
CoinSessionConstants.UNAVAILABLE_MESSAGE =
	"Your compliance wallet could not be opened. Please rejoin in a moment.\n준법 지갑을 열 수 없습니다. 잠시 후 다시 접속해 주세요."

--[=[
	@prop LOST_MESSAGE string
	@within CoinSessionConstants
	@readonly
	Shown to a player whose wallet another server has taken over.
]=]
CoinSessionConstants.LOST_MESSAGE =
	"Your compliance wallet is now held by another server. Please rejoin.\n준법 지갑을 다른 서버가 맡게 되었습니다. 다시 접속해 주세요."

return table.freeze(CoinSessionConstants)
