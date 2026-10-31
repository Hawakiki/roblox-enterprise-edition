-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The calendar of deployments (EE-STD-0008 §7): no release is deployed while it is Friday anywhere on Earth, nor
	while it is 19 January 2038 anywhere on Earth. Times are whole seconds since 1970 in UTC, held in Luau numbers,
	which are 64-bit floating point and do not overflow in 2038, nor in 2106.
	배포 달력(EE-STD-0008 §7): 지구 어딘가가 금요일이거나 2038년 1월 19일인 동안은 배포하지 않는다. 시각은
	1970년 이후의 UTC 초이며, 64비트 부동소수점인 Luau number 에 담기므로 2038년에도 2106년에도 넘치지 않는다.
]]

local SECONDS_PER_HOUR = 3600
local SECONDS_PER_DAY = 86400
local DAYS_PER_WEEK = 7

-- A date begins first at UTC+14 and ends last at UTC-12, so it lasts 50 hours somewhere on Earth.
local EARLIEST_OFFSET = 14 * SECONDS_PER_HOUR
local LATEST_OFFSET = 12 * SECONDS_PER_HOUR

-- 1 January 1970 was a Thursday. With Sunday as 0, Friday is 5.
local THURSDAY = 4
local FRIDAY = 5

-- The last second that a signed 32-bit count of seconds can hold: 2038-01-19T03:14:07Z.
local LAST_SIGNED_32_BIT_SECOND = 2147483647

local ReleaseCalendar = {}

local function dayOf(utc: number): number
	return math.floor(utc / SECONDS_PER_DAY)
end

local function weekdayOf(day: number): number
	return (day + THURSDAY) % DAYS_PER_WEEK
end

local Y2K38_DAY = dayOf(LAST_SIGNED_32_BIT_SECOND)

-- Whether a date, counted in days since 1970, is still the date somewhere on Earth at a moment.
local function isSomewhere(day: number, utc: number): boolean
	local start = day * SECONDS_PER_DAY
	return utc >= start - EARLIEST_OFFSET and utc < start + SECONDS_PER_DAY + LATEST_OFFSET
end

-- The reason a deployment is refused at a moment, or nil when it may proceed.
function ReleaseCalendar.freezeAt(utc: number): string?
	-- Yesterday, today and tomorrow by UTC are the only dates that can be somewhere on Earth at once.
	local today = dayOf(utc)
	for day = today - 1, today + 1 do
		if isSomewhere(day, utc) then
			if weekdayOf(day) == FRIDAY then
				return "it is Friday somewhere on Earth"
			elseif day == Y2K38_DAY then
				return "it is 19 January 2038 somewhere on Earth, where a signed 32-bit time_t overflows"
			end
		end
	end
	return nil
end

-- The moment the freeze in force at a moment ends. Every freeze ends on a whole hour of UTC.
function ReleaseCalendar.nextOpening(utc: number): number
	local moment = utc
	while ReleaseCalendar.freezeAt(moment) do
		moment = (math.floor(moment / SECONDS_PER_HOUR) + 1) * SECONDS_PER_HOUR
	end
	return moment
end

return ReleaseCalendar
