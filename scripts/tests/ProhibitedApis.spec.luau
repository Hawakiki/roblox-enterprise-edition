-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local ProhibitedApis = require("../lib/ProhibitedApis")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local SERVICE = "src/Shared/Application/CoinService.luau"
local LOGGER = "src/Shared/Infrastructure/RobloxOutputLoggerAdapter.luau"
local FACTORY = "src/Shared/Infrastructure/PartFactory.luau"
local ROOT = "src/Server/init.server.luau"
local TOOL = "scripts/lib/Tool.luau"

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	ProhibitedApis.check(Snapshot.new(files), report)
	return report
end

local function code(body: string): string
	return "--!strict\n" .. body .. "\n"
end

-- Directives / 지시문

case("--!strict alone passes", function()
	Assert.codes(check({ [SERVICE] = code("return nil"), [TOOL] = code("return nil") }), {})
end)

case("every other directive is prohibited, in src and in the tooling", function()
	for _, directive in { "--!nonstrict", "--!nocheck", "--!native", "--!optimize 2", "--!optimize 0", "--!nolint" } do
		Assert.codes(check({ [SERVICE] = directive .. "\n" .. code("return nil") }), { "PROHIBITED_DIRECTIVE" })
		Assert.codes(check({ [TOOL] = code(directive .. "\nreturn nil") }), { "PROHIBITED_DIRECTIVE" })
	end
end)

case("--!strict beside another directive does not pass, whichever comes first", function()
	Assert.codes(check({ [SERVICE] = "--!nocheck\n--!strict\nreturn nil\n" }), { "PROHIBITED_DIRECTIVE" })
	Assert.codes(check({ [SERVICE] = "--!strict\n--!nocheck\nreturn nil\n" }), { "PROHIBITED_DIRECTIVE" })
end)

case("attributes are prohibited", function()
	Assert.codes(check({ [SERVICE] = code("@native\nlocal function f() end") }), { "PROHIBITED_DIRECTIVE" })
	Assert.codes(check({ [TOOL] = code("local f = @native function() end") }), { "PROHIBITED_DIRECTIVE" })
end)

case("directives inside strings and block comments are text", function()
	local source = code('local s = "--!nocheck @native"\n--[[\n--!native\n]]\nreturn s')
	Assert.codes(check({ [SERVICE] = source }), {})
end)

-- APIs / API

case("print and warn are prohibited outside a sanctioned exception", function()
	Assert.codes(check({ [SERVICE] = code('print("hello")') }), { "PROHIBITED_API" })
	Assert.codes(check({ [SERVICE] = code('warn("careful")') }), { "PROHIBITED_API" })
	Assert.codes(check({ [SERVICE] = code("local log = print\nreturn log") }), { "PROHIBITED_API" })
	Assert.codes(check({ [LOGGER] = code('print("hello")\nwarn("careful")') }), {})
end)

case("a sanctioned exception covers only the APIs it names", function()
	Assert.codes(check({ [LOGGER] = code('local part = Instance.new("Part")') }), { "PROHIBITED_API" })
end)

case("Instance.new is allowed only in Infrastructure factories", function()
	Assert.codes(check({ [FACTORY] = code('return Instance.new("Part")') }), {})
	Assert.codes(check({ [SERVICE] = code('return Instance.new("Part")') }), { "PROHIBITED_API" })
	Assert.codes(
		check({ ["src/Shared/Application/PartFactory.luau"] = code('return Instance.new("Part")') }),
		{ "PROHIBITED_API" }
	)
end)

case("game:GetService is allowed only in the composition roots", function()
	local source = code('local ReplicatedStorage = game:GetService("ReplicatedStorage")')
	Assert.codes(check({ [ROOT] = source, ["src/Client/init.client.luau"] = source }), {})
	Assert.codes(check({ [SERVICE] = source }), { "PROHIBITED_API" })
	Assert.codes(check({ [SERVICE] = code('local P = game.GetService(game, "Players")') }), { "PROHIBITED_API" })
	Assert.codes(check({ [SERVICE] = code('local P = game:FindService("Players")') }), { "PROHIBITED_API" })
end)

case("deprecated and unsafe globals are prohibited everywhere", function()
	for _, body in
		{
			"wait(1)",
			"delay(1, f)",
			"spawn(f)",
			"local t = tick()",
			'loadstring("return 1")()',
			"local env = getfenv()",
			"setfenv(1, {})",
			"_G.x = 1",
			"shared.x = 1",
		}
	do
		Assert.codes(check({ [ROOT] = code(body) }), { "PROHIBITED_API" })
	end
end)

case("deprecated scheduler globals are reported only when called", function()
	Assert.codes(check({ [SERVICE] = code("local spawn = workspace.SpawnLocation\nreturn spawn.Position") }), {})
	Assert.codes(check({ [SERVICE] = code("local delay: number = 0\nreturn delay") }), {})
end)

case("fields, methods, keys, comments and strings are not the API", function()
	local body = 'logger.print("x")\nlogger:warn("y")\nlocal t = { print = true, wait = 1 }\n'
		.. 'local n = task.wait()\n-- print("commented")\nlocal s = "print(\'quoted\')"\n'
		.. 'local i = self.Instance.new\nlocal g = other.game:GetService("X")'
	Assert.codes(check({ [SERVICE] = code(body) }), {})
end)

case("a member named in brackets is still the member (CR-0009)", function()
	for _, body in
		{ 'game["GetService"](game, "Players")', "game['FindService'](game, 'Players')", 'Instance[ [[new]] ]("Part")' }
	do
		Assert.codes(check({ [SERVICE] = code(body) }), { "PROHIBITED_API" })
	end
	Assert.codes(check({ [SERVICE] = code('local x = game["Workspace"]') }), {})
	Assert.codes(check({ [ROOT] = code('local P = game["GetService"](game, "Players")') }), {})
end)

case("the tooling may use the APIs", function()
	Assert.codes(check({ [TOOL] = code('print("report")\nlocal t = tick()') }), {})
end)

return { name = "ProhibitedApis", cases = cases } :: Assert.Suite
