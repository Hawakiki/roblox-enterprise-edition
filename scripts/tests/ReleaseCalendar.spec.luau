-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local ReleaseCalendar = require("../lib/ReleaseCalendar")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

-- Seconds since 1970 for a date and time in UTC, by the civil-from-days algorithm of Howard Hinnant, written
-- apart from the calendar under test so that the two cannot share a mistake.
local function utc(year: number, month: number, day: number, hour: number, minute: number, second: number): number
	local y = if month <= 2 then year - 1 else year
	local era = math.floor(y / 400)
	local yearOfEra = y - era * 400
	local monthFromMarch = (month + 9) % 12
	local dayOfYear = math.floor((153 * monthFromMarch + 2) / 5) + day - 1
	local dayOfEra = yearOfEra * 365 + math.floor(yearOfEra / 4) - math.floor(yearOfEra / 100) + dayOfYear
	local days = era * 146097 + dayOfEra - 719468
	return days * 86400 + hour * 3600 + minute * 60 + second
end

case("the reference dates agree with .NET", function()
	Assert.equal(utc(2026, 10, 29, 10, 0, 0), 1793268000, "a Thursday")
	Assert.equal(utc(2038, 1, 19, 3, 14, 7), 2147483647, "the last signed 32-bit second")
	Assert.equal(utc(2106, 2, 7, 6, 28, 15), 4294967295, "the last unsigned 32-bit second")
end)

case("Friday begins somewhere on Earth on Thursday at 10:00 UTC", function()
	Assert.equal(ReleaseCalendar.freezeAt(utc(2026, 10, 29, 9, 59, 59)), nil, "Thursday 09:59:59")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2026, 10, 29, 10, 0, 0)), "it is Friday somewhere on Earth", "10:00")
end)

case("Friday ends somewhere on Earth on Saturday at 12:00 UTC", function()
	Assert.equal(ReleaseCalendar.freezeAt(utc(2026, 10, 31, 11, 59, 59)), "it is Friday somewhere on Earth", "11:59:59")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2026, 10, 31, 12, 0, 0)), nil, "Saturday 12:00")
end)

case("1.0.0 was released while it was still Friday in parts of the Pacific", function()
	Assert.equal(ReleaseCalendar.freezeAt(utc(2026, 10, 31, 3, 30, 12)), "it is Friday somewhere on Earth", "v1.0.0")
end)

case("the middle of the week is open", function()
	Assert.equal(ReleaseCalendar.freezeAt(utc(2026, 10, 27, 12, 0, 0)), nil, "Tuesday")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2026, 10, 28, 23, 59, 59)), nil, "Wednesday night")
end)

case("a freeze reports when it ends", function()
	local friday = utc(2026, 10, 31, 12, 0, 0)
	Assert.equal(ReleaseCalendar.nextOpening(utc(2026, 10, 29, 10, 0, 0)), friday, "from its first second")
	Assert.equal(ReleaseCalendar.nextOpening(utc(2026, 10, 30, 17, 23, 5)), friday, "from its middle")
	Assert.equal(ReleaseCalendar.nextOpening(utc(2026, 10, 28, 8, 0, 0)), utc(2026, 10, 28, 8, 0, 0), "when open")
end)

case("19 January 2038 is frozen for 50 hours, around the overflow of a signed 32-bit time_t", function()
	local y2k38 = "it is 19 January 2038 somewhere on Earth, where a signed 32-bit time_t overflows"
	Assert.equal(ReleaseCalendar.freezeAt(utc(2038, 1, 18, 9, 59, 59)), nil, "Monday 09:59:59")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2038, 1, 18, 10, 0, 0)), y2k38, "Monday 10:00")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2038, 1, 19, 3, 14, 7)), y2k38, "the last signed 32-bit second")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2038, 1, 20, 11, 59, 59)), y2k38, "Wednesday 11:59:59")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2038, 1, 20, 12, 0, 0)), nil, "Wednesday 12:00")
end)

case("the calendar keeps its weeks after 2038 and after 2106", function()
	Assert.equal(ReleaseCalendar.freezeAt(utc(2038, 1, 22, 0, 0, 0)), "it is Friday somewhere on Earth", "2038")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2106, 2, 5, 0, 0, 0)), "it is Friday somewhere on Earth", "2106")
	Assert.equal(ReleaseCalendar.freezeAt(utc(2106, 2, 7, 12, 0, 0)), nil, "a Sunday in 2106")
end)

return { name = "ReleaseCalendar", cases = cases } :: Assert.Suite
