-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class LeaderstatsConstants

	The names under which Roblox shows a statistic on its leaderboard, shared by the server that writes them and
	the client that reads them.

	Roblox 가 리더보드에 통계를 보여 주는 이름. 이를 쓰는 서버와 읽는 클라이언트가 함께 쓴다.
]=]

local LeaderstatsConstants = {}

--[=[
	@prop FOLDER_NAME string
	@within LeaderstatsConstants
	@readonly
	The folder under a player that Roblox reads statistics from. Roblox chose the name, in lower case.
]=]
LeaderstatsConstants.FOLDER_NAME = "leaderstats"

--[=[
	@prop COINS_STAT_NAME string
	@within LeaderstatsConstants
	@readonly
	The statistic that holds the compliance coins of a player.
]=]
LeaderstatsConstants.COINS_STAT_NAME = "Coins"

return table.freeze(LeaderstatsConstants)
