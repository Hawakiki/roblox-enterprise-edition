-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Contracts = require("../lib/Contracts")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local MODULE = "src/Shared/Infrastructure/InMemoryCoinWalletRepository.luau"
local TOOL = "scripts/lib/Tool.luau"

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	Contracts.check(Snapshot.new(files), report)
	return report
end

local function code(body: string): string
	return "--!strict\n" .. body .. "\nreturn Class\n"
end

local function implements(entries: string): string
	return code("local _implements: IContract.IContract = {\n" .. entries .. "\n}")
end

-- Wrappers / 래퍼

case("entries written as functions pass", function()
	Assert.codes(
		check({
			[MODULE] = implements([[
	Load = function(self: any, userId: number): Wallet
		return Class.Load(self, userId)
	end,
	Release = function(self: any, wallet: Wallet)
		Class.Release(self, wallet)
	end,]]),
		}),
		{}
	)
end)

case("a wrapper may hold any statement, and the entry after it is still read", function()
	local report = check({
		[MODULE] = implements([[
	Load = function(self: any, userId: number): Wallet
		local first, second = 1, 2
		if userId > first then
			for _, value in { first, second } do
				repeat
					first += value
				until first > second
			end
		elseif userId < 0 then
			do
				second = if userId == 0 then 1 else 2
			end
		end
		local nested = function(a: number, b: number): number
			return a + b
		end, { first, second }
		return Class.Load(self, nested(first, second))
	end;
	Save = Class.Save]]),
	})
	-- Ending the wrapper early would report its statements; never ending it would hide Save.
	Assert.codes(report, { "IMPLEMENTS_NOT_WRAPPED" })
	Assert.equal(#report.violations, 1, "only the bare entry")
	Assert.contains(report.violations[1].message, "Save", "the entry after the wrapper")
end)

case("an entry that refers to a method is reported, once per entry", function()
	local report = check({
		[MODULE] = implements([[
	Load = Class.Load,
	Save = function(self: any, wallet: Wallet): boolean
		return Class.Save(self, wallet)
	end,
	Release = Class.Release,]]),
	})
	Assert.codes(report, { "IMPLEMENTS_NOT_WRAPPED" })
	Assert.equal(#report.violations, 2, "two bare entries")
	Assert.contains(report.violations[1].message, "Load", "the entry is named")
end)

case("an entry in brackets or without a key is still an entry", function()
	Assert.codes(check({ [MODULE] = implements('\t["Load"] = Class.Load,') }), { "IMPLEMENTS_NOT_WRAPPED" })
	Assert.codes(check({ [MODULE] = implements("\tClass.Load,") }), { "IMPLEMENTS_NOT_WRAPPED" })
end)

case("only the table named _implements, and only in the Roblox code, is held to it", function()
	Assert.codes(check({ [MODULE] = code("local handlers = {\n\tLoad = Class.Load,\n}") }), {})
	Assert.codes(check({ [TOOL] = implements("\tLoad = Class.Load,") }), {})
end)

-- Casts through any / any 캐스트

case("a constructor may return its instance as its contract", function()
	Assert.codes(
		check({
			[MODULE] = code(
				"function Class.new(): IContract.IContract\n\tlocal state: State = {}\n\treturn setmetatable(state, Class) :: any\nend"
			),
		}),
		{}
	)
end)

case("every other cast through any is reported", function()
	for _, body in
		{
			"local panel: Props = props :: any",
			"(service :: any):Dispose()",
			"return Instance.new(className :: any)",
			"return setmetatable(state, Class) :: any :: IContract",
			"return setmetatable({}, Class) :: any",
			"local instance = setmetatable(state, Class) :: any",
		}
	do
		Assert.codes(check({ [MODULE] = code(body) }), { "CAST_THROUGH_ANY" })
	end
end)

case("annotations, other casts, comments and strings are not a cast through any", function()
	Assert.codes(
		check({
			[MODULE] = code(
				'local value: any = 1\nlocal count = value :: number\n-- props :: any\nlocal text = "props :: any"'
			),
		}),
		{}
	)
	Assert.codes(check({ [TOOL] = code("local panel: Props = props :: any") }), {})
end)

return { name = "Contracts", cases = cases } :: Assert.Suite
