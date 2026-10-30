-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Architecture = require("../lib/Architecture")
local Assert = require("./Assert")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	Architecture.check(Snapshot.new(files), report)
	return report
end

local function requiring(path: string): string
	return string.format("local x = require(%s)\nreturn x\n", path)
end

case("a compliant tree passes", function()
	Assert.codes(
		check({
			["src/Shared/Kernel/ServiceToken.luau"] = "return {}\n",
			["src/Shared/Kernel/ILogger.luau"] = requiring("script.Parent.ServiceToken"),
			["src/Shared/Application/GreetingService.luau"] = requiring("script.Parent.Parent.Kernel.ILogger"),
			["src/Shared/Infrastructure/OutputAdapter.luau"] = requiring(
				"script.Parent.Parent.Application.GreetingService"
			),
			["src/Client/Presentation/CoinButtonComponent.luau"] = requiring(
				"ReplicatedStorage.EnterpriseEdition.Application.GreetingService"
			),
			["src/Server/init.server.luau"] = requiring(
				"ReplicatedStorage.EnterpriseEdition.Infrastructure.OutputAdapter"
			),
		}),
		{}
	)
end)

case("dependencies may not point outwards", function()
	Assert.codes(
		check({
			["src/Shared/Application/GreetingService.luau"] = requiring(
				"script.Parent.Parent.Infrastructure.OutputAdapter"
			),
		}),
		{ "LAYER_VIOLATION" }
	)
	Assert.codes(
		check({ ["src/Shared/Domain/CoinEntity.luau"] = requiring("script.Parent.Parent.Application.GreetingService") }),
		{ "LAYER_VIOLATION" }
	)
	Assert.codes(
		check({ ["src/Shared/Kernel/ServiceProvider.luau"] = requiring("script.Parent.Parent.Domain.CoinEntity") }),
		{ "LAYER_VIOLATION" }
	)
end)

case("presentation and infrastructure may not reach each other", function()
	Assert.codes(
		check({
			["src/Client/Presentation/CoinButtonComponent.luau"] = requiring("script.Parent.Parent.Infrastructure.X"),
		}),
		{ "LAYER_VIOLATION" }
	)
end)

case("a require split over several lines is still read, with its line", function()
	local source = "local a = 1\nlocal x = require(\n\tscript.Parent.Parent.Infrastructure.OutputAdapter\n)\nreturn x\n"
	local report = check({ ["src/Shared/Application/GreetingService.luau"] = source })
	Assert.codes(report, { "LAYER_VIOLATION" })
	Assert.equal(report.violations[1].line, 2, "line")
end)

case("requires inside comments are ignored", function()
	local source =
		"-- require(script.Parent.Parent.Infrastructure.X)\n--[[\n\trequire(script.Parent.Parent.Infrastructure.Y)\n]]\nreturn nil\n"
	Assert.codes(check({ ["src/Shared/Application/GreetingService.luau"] = source }), {})
end)

case("a module outside every layer is reported", function()
	Assert.codes(check({ ["src/Shared/Utilities/HelperService.luau"] = "return nil\n" }), { "LAYER_VIOLATION" })
end)

case("composition roots may require anything", function()
	Assert.codes(
		check({ ["src/Client/init.client.luau"] = requiring("ReplicatedStorage.EnterpriseEdition.Infrastructure.X") }),
		{}
	)
end)

case("names end with an approved suffix or are interfaces", function()
	Assert.codes(check({ ["src/Shared/Kernel/ICoinRepository.luau"] = "return {}\n" }), {})
	Assert.codes(check({ ["src/Shared/Kernel/Helpers.luau"] = "return {}\n" }), { "MODULE_NAME_SUFFIX" })
	Assert.codes(check({ ["src/Shared/Kernel/Service.luau"] = "return {}\n" }), { "MODULE_NAME_SUFFIX" })
	Assert.codes(check({ ["src/Shared/Kernel/coinService.luau"] = "return {}\n" }), { "MODULE_NAME_SUFFIX" })
	Assert.codes(check({ ["src/Shared/Kernel/Inventory.luau"] = "return {}\n" }), { "MODULE_NAME_SUFFIX" })
end)

case("a folder module takes the name of its folder", function()
	Assert.codes(check({ ["src/Shared/Kernel/CoinScope/init.luau"] = "return {}\n" }), {})
	Assert.codes(check({ ["src/Shared/Kernel/Coins/init.luau"] = "return {}\n" }), { "MODULE_NAME_SUFFIX" })
end)

case("files outside src are not governed", function()
	Assert.codes(check({ ["scripts/lib/Text.luau"] = requiring("script.Parent.Infrastructure.X") }), {})
end)

return { name = "Architecture", cases = cases } :: Assert.Suite
