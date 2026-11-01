-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local DocComments = require("../lib/DocComments")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local PATH = "src/Shared/Kernel/CoinService.luau"
local CONTRACT = "src/Shared/Kernel/ICoinRepository.luau"
local ROOT = "src/Server/init.server.luau"

local HEADER = "-- SPDX-License-Identifier: MIT\n--!strict\n"

local function classDoc(name: string): string
	return "--[=[\n\t@class " .. name .. "\n\n\tCounts coins.\n\n\t동전을 센다.\n]=]\n"
end

local function functionDoc(lines: { string }): string
	return "--[=[\n\tAdds coins.\n\n\t" .. table.concat(lines, "\n\t") .. "\n]=]\n"
end

local ADD = "function CoinService.Add(self: CoinService, amount: number): number\n\treturn amount\nend\n"
local ADD_DOC = { "@within CoinService", "@method Add", "@param amount number -- The coins.", "@return number" }

local function module(body: string): string
	return HEADER .. classDoc("CoinService") .. "\nlocal CoinService = {}\n\n" .. body .. "\nreturn CoinService\n"
end

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	DocComments.check(Snapshot.new(files), report)
	return report
end

case("a documented module passes", function()
	Assert.codes(check({ [PATH] = module(functionDoc(ADD_DOC) .. ADD) }), {})
end)

case("a module without a doc comment is reported", function()
	Assert.codes(check({ [PATH] = HEADER .. "local CoinService = {}\nreturn CoinService\n" }), { "MISSING_MODULE_DOC" })
end)

case("a plain block comment is not a doc comment", function()
	local source = HEADER .. "--[[\n\t@class CoinService\n\n\tCounts coins.\n\n\t동전을 센다.\n]]\nreturn {}\n"
	Assert.codes(check({ [PATH] = source }), { "MISSING_MODULE_DOC" })
end)

case("a doc comment opens with a line of its own", function()
	local source = HEADER .. "--[=[ @class CoinService\n\n\tCounts coins.\n\n\t동전을 센다.\n]=]\nreturn {}\n"
	Assert.codes(check({ [PATH] = source }), { "MISSING_MODULE_DOC" })
end)

case("the module doc comment comes before any code", function()
	local source = HEADER .. "local CoinService = {}\n" .. classDoc("CoinService") .. "return CoinService\n"
	Assert.codes(check({ [PATH] = source }), { "MISSING_MODULE_DOC" })
end)

case("the class is named after the module", function()
	local source = HEADER .. classDoc("Coins") .. "return {}\n"
	Assert.codes(check({ [PATH] = source }), { "MISSING_MODULE_DOC" })
end)

case("a contract documents its interface within its class", function()
	local interface = "--[=[\n\t@interface ICoinRepository\n\t@within ICoinRepository\n\t.Load (self: any) -> ()\n\n"
		.. "\tThe members.\n\n\t멤버.\n]=]\n"
	local withInterface = HEADER .. classDoc("ICoinRepository") .. interface .. "return {}\n"
	Assert.codes(check({ [CONTRACT] = withInterface }), {})
	local without = HEADER .. classDoc("ICoinRepository") .. "return {}\n"
	Assert.codes(check({ [CONTRACT] = without }), { "MISSING_MODULE_DOC" })
end)

case("a class is described in English and then in Korean", function()
	local englishOnly = HEADER .. "--[=[\n\t@class CoinService\n\n\tCounts coins.\n]=]\nreturn {}\n"
	Assert.codes(check({ [PATH] = englishOnly }), { "DOC_COMMENT_LANGUAGE" })
	local koreanFirst = HEADER
		.. "--[=[\n\t@class CoinService\n\n\t동전을 센다.\n\n\tCounts coins.\n]=]\nreturn {}\n"
	Assert.codes(check({ [PATH] = koreanFirst }), { "DOC_COMMENT_LANGUAGE" })
end)

case("a function doc comment is written in English only", function()
	local doc = functionDoc({ "동전을 더한다.", "@within CoinService", "@param amount number", "@return number" })
	Assert.codes(check({ [PATH] = module(doc .. ADD) }), { "DOC_COMMENT_LANGUAGE" })
end)

case("a public function without a doc comment is reported", function()
	Assert.codes(check({ [PATH] = module(ADD) }), { "MISSING_FUNCTION_DOC" })
	local assigned = "CoinService.Add = function(amount: number)\nend\n"
	Assert.codes(check({ [PATH] = module(assigned) }), { "MISSING_FUNCTION_DOC" })
end)

case("code between a doc comment and its function breaks the link", function()
	local source = module(functionDoc(ADD_DOC) .. "local _ = nil\n" .. ADD)
	Assert.codes(check({ [PATH] = source }), { "MISSING_FUNCTION_DOC" })
end)

case("local and underscored functions are private", function()
	local body = "local function helper(amount: number): number\n\treturn amount\nend\n"
		.. "function CoinService._reset(self: CoinService)\nend\n"
	Assert.codes(check({ [PATH] = module(body) }), {})
end)

case("@within names the class of the module", function()
	local missing = functionDoc({ "@param amount number", "@return number" })
	Assert.codes(check({ [PATH] = module(missing .. ADD) }), { "INCOMPLETE_DOC_COMMENT" })
	local wrong = functionDoc({ "@within Coins", "@param amount number", "@return number" })
	Assert.codes(check({ [PATH] = module(wrong .. ADD) }), { "INCOMPLETE_DOC_COMMENT" })
end)

case("every parameter but self is documented, and nothing else", function()
	local missing = functionDoc({ "@within CoinService", "@return number" })
	Assert.codes(check({ [PATH] = module(missing .. ADD) }), { "INCOMPLETE_DOC_COMMENT" })
	local extra =
		functionDoc({ "@within CoinService", "@param amount number", "@param bonus number", "@return number" })
	Assert.codes(check({ [PATH] = module(extra .. ADD) }), { "INCOMPLETE_DOC_COMMENT" })
	local optional = "function CoinService.Spend(amount: number?, ...: string)\nend\n"
	local optionalDoc = functionDoc({ "@within CoinService", "@param amount? number", "@param ... string" })
	Assert.codes(check({ [PATH] = module(optionalDoc .. optional) }), {})
end)

case("a declared return type needs @return", function()
	local missing = functionDoc({ "@within CoinService", "@param amount number" })
	Assert.codes(check({ [PATH] = module(missing .. ADD) }), { "INCOMPLETE_DOC_COMMENT" })
	local nothing = "function CoinService.Reset(): ()\nend\n"
	Assert.codes(check({ [PATH] = module(functionDoc({ "@within CoinService" }) .. nothing) }), {})
end)

-- Defect 6 of CR-0018: a return type that begins with () was read as returning nothing.
case("a function that returns a function needs @return", function()
	local maker = "function CoinService.Make(): () -> number\n\treturn function()\n\t\treturn 0\n\tend\nend\n"
	Assert.codes(
		check({ [PATH] = module(functionDoc({ "@within CoinService" }) .. maker) }),
		{ "INCOMPLETE_DOC_COMMENT" }
	)
	local documented = functionDoc({ "@within CoinService", "@return () -> number" })
	Assert.codes(check({ [PATH] = module(documented .. maker) }), {})
end)

-- Defect 6 of CR-0018: a module that did not end with return <name> was not checked at all.
case("a module that returns its table frozen or cast is checked all the same", function()
	local start = HEADER .. classDoc("CoinService") .. "\nlocal CoinService = {}\n\n" .. ADD
	Assert.codes(check({ [PATH] = start .. "\nreturn table.freeze(CoinService)\n" }), { "MISSING_FUNCTION_DOC" })
	Assert.codes(check({ [PATH] = start .. "\nreturn CoinService :: any\n" }), { "MISSING_FUNCTION_DOC" })
end)

case("function types and generics in a signature are read", function()
	local generic = "function CoinService.Map<T, R>(items: { T }, map: (T, number) -> R): { R }\n\treturn {}\nend\n"
	local doc =
		functionDoc({ "@within CoinService", "@param items { T }", "@param map (T, number) -> R", "@return { R }" })
	Assert.codes(check({ [PATH] = module(doc .. generic) }), {})
end)

case("a composition root names its own class and has no public functions", function()
	local source = HEADER .. classDoc("ServerCompositionRoot") .. "local x = 1\n"
	Assert.codes(check({ [ROOT] = source }), {})
	Assert.codes(check({ [ROOT] = HEADER .. "local x = 1\n" }), { "MISSING_MODULE_DOC" })
end)

case("files outside src are not governed", function()
	Assert.codes(check({ ["scripts/lib/Text.luau"] = HEADER .. "return {}\n" }), {})
end)

return { name = "DocComments", cases = cases } :: Assert.Suite
