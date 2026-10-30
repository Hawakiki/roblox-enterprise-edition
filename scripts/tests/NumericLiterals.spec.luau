-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local NumericLiterals = require("../lib/NumericLiterals")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local SERVICE = "src/Shared/Application/CoinService.luau"
local CONSTANTS = "src/Shared/Application/CoinConstants.luau"
local ROOT = "src/Server/init.server.luau"

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	NumericLiterals.check(Snapshot.new(files), report)
	return report
end

local function inService(body: string): Report.Report
	return check({ [SERVICE] = "--!strict\n" .. body .. "\n" })
end

-- Numbers / 숫자

case("-1, 0, 1 and 2 may appear anywhere", function()
	Assert.codes(inService("for i = #t, 1, -1 do end"), {})
	Assert.codes(inService("local first, empty = t[1], #t == 0\nerror(m, 2)"), {})
	Assert.codes(inService("local a = x - 2\nlocal b = f() - 2\nlocal c = t[1] - 2\nlocal d = n-1"), {})
	Assert.codes(check({ [ROOT] = "local half = 1 / 2\n" }), {})
end)

case("every other number is reported, in the composition roots too", function()
	for _, literal in { "3", "0.5", "1e3", "0x10", "1_000", ".5" } do
		Assert.codes(inService("local x = " .. literal), { "NUMERIC_LITERAL" })
	end
	Assert.codes(check({ [ROOT] = "local x = 10\n" }), { "NUMERIC_LITERAL" })
end)

case("the exemption is by spelling", function()
	for _, literal in { "2.0", "0x1", "1e0", "0b10", "0.0" } do
		Assert.codes(inService("local x = " .. literal), { "NUMERIC_LITERAL" })
	end
end)

case("-2 and -0 are not exempt, but a subtraction of 2 is", function()
	for _, body in
		{ "local x = -2", "return -2", "f(-2)", "local t = { -2 }", "if not -0 then end", "local s = `{-2}`" }
	do
		Assert.codes(inService(body), { "NUMERIC_LITERAL" })
	end
	Assert.codes(inService("local x = y -2\nlocal z = (y) - 2"), {})
end)

case("a Constants module may hold any number", function()
	Assert.codes(check({ [CONSTANTS] = "local C = {}\nC.MAXIMUM_COINS = 999\nC.RATE = -0.5\nreturn C\n" }), {})
end)

case("numbers in comments and strings are text", function()
	Assert.codes(inService('-- wait 30 seconds\nlocal s = "404"\n--[[ 3.14 ]]'), {})
end)

case("files outside src are not governed", function()
	Assert.codes(check({ ["scripts/lib/Text.luau"] = "local x = 42\n" }), {})
end)

-- Colours / 색

case("colours come from the palette", function()
	Assert.codes(inService("local red = Color3.new(1, 0, 0)"), { "COLOR_OUTSIDE_PALETTE" })
	Assert.codes(inService('local red = Color3.fromHex("#FF0000")'), { "COLOR_OUTSIDE_PALETTE" })
	Assert.codes(inService('local red = BrickColor.new("Bright red").Color'), { "COLOR_OUTSIDE_PALETTE" })
	Assert.codes(
		check({ [CONSTANTS] = "local C = {}\nC.RED = Color3.fromRGB(255, 0, 0)\nreturn C\n" }),
		{ "COLOR_OUTSIDE_PALETTE" }
	)
end)

case("the palette makes colours", function()
	local palette = "local P = {}\nP.GREY = Color3.new(0.38, 0.37, 0.39)\nP.RED = Color3.fromRGB(255, 0, 0)\nreturn P\n"
	Assert.codes(check({ [NumericLiterals.PALETTE] = palette }), {})
end)

case("naming Color3 as a type, or a field that shares its name, is not making a colour", function()
	Assert.codes(inService("local c: Color3 = Palette.GREY\nlocal d = part.Color3\nlocal e = c:Lerp(d, 0)"), {})
end)

return { name = "NumericLiterals", cases = cases } :: Assert.Suite
