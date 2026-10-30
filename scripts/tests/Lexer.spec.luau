-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Lexer = require("../lib/Lexer")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

-- Every token as kind:text, joined by spaces.
local function shape(source: string): string
	local parts = {}
	for _, token in Lexer.tokenize(source) do
		table.insert(parts, token.kind .. ":" .. token.text)
	end
	return table.concat(parts, " ")
end

local function only(source: string, kind: Lexer.Kind): string
	local parts = {}
	for _, token in Lexer.tokenize(source) do
		if token.kind == kind then
			table.insert(parts, token.text)
		end
	end
	return table.concat(parts, " ")
end

case("names, numbers and symbols", function()
	Assert.equal(
		shape("local x1 = a.b:c(0x1F, 1e3, 1_000, .5, 2.5)"),
		"name:local name:x1 symbol:= name:a symbol:. name:b symbol:: name:c symbol:( number:0x1F symbol:, "
			.. "number:1e3 symbol:, number:1_000 symbol:, number:.5 symbol:, number:2.5 symbol:)",
		"tokens"
	)
end)

case("multi-character symbols are one token", function()
	Assert.equal(
		shape("a .. b ... :: -> == ~= //="),
		"name:a symbol:.. name:b symbol:... symbol::: symbol:-> " .. "symbol:== symbol:~= symbol://=",
		"tokens"
	)
end)

case("a negative number is a minus and a number", function()
	Assert.equal(only("for i = #t, 1, -1 do end", "number"), "1 1", "numbers")
end)

case("comments hide what they contain", function()
	local source = "-- print(1)\n--[[ print(2) ]]\n--[=[\n\t@class X\n]=]\nreturn 3\n"
	Assert.equal(only(source, "number"), "3", "numbers")
	Assert.equal(only(source, "comment"), "-- print(1) --[[ print(2) ]] --[=[\n\t@class X\n]=]", "comments")
end)

case("strings hide what they contain", function()
	local source = 'local a = "print(1) -- \\" 2"\nlocal b = \'x\' .. [==[ 3 ]] --[[ ]==]\nreturn 4\n'
	Assert.equal(only(source, "number"), "4", "numbers")
	Assert.equal(only(source, "comment"), "", "comments")
	Assert.equal(#Lexer.code(Lexer.tokenize(source)), 12, "code tokens")
end)

case("the expressions of an interpolated string are code", function()
	local source = "local s = `{n} of {1 + count} in {t[{ 2 }]} \\{3}`"
	Assert.equal(only(source, "number"), "1 2", "numbers")
	Assert.equal(only(source, "name"), "local s n count t", "names")
end)

case("an escaped line break continues a string", function()
	local source = 'local s = "a\\z\n\t\tb"\nreturn 1\n'
	local tokens = Lexer.tokenize(source)
	Assert.equal(tokens[4].kind, "string", "kind")
	Assert.equal(tokens[#tokens].line, 3, "line of the number")
end)

case("lines are counted through comments and strings", function()
	local tokens = Lexer.tokenize("--[[\n\n]]\nlocal s = [[\n]]\nreturn 7\n")
	Assert.equal(tokens[1].line, 1, "comment")
	Assert.equal(tokens[2].line, 4, "local")
	Assert.equal(tokens[#tokens].line, 6, "number")
end)

case("hot comments and attributes are tokens", function()
	Assert.equal(
		shape("--!strict\n@native function f() end"),
		"comment:--!strict symbol:@ name:native name:function " .. "name:f symbol:( symbol:) name:end",
		"tokens"
	)
end)

case("block comments report their level and body", function()
	local tokens = Lexer.tokenize("--[=[\n\tdoc\n]=] --[[ plain ]] -- line --[==[ open")
	Assert.equal(Lexer.blockLevel(tokens[1]), 1, "level of --[=[")
	Assert.equal(Lexer.blockBody(tokens[1]), "\n\tdoc\n", "body of --[=[")
	Assert.equal(Lexer.blockLevel(tokens[2]), 0, "level of --[[")
	Assert.equal(Lexer.blockLevel(tokens[3]), nil, "level of a line comment")
	Assert.equal(Lexer.blockBody(tokens[3]), nil, "body of a line comment")
end)

case("an unterminated block comment has no body", function()
	local tokens = Lexer.tokenize("--[=[ never closed")
	Assert.equal(Lexer.blockLevel(tokens[1]), 1, "level")
	Assert.equal(Lexer.blockBody(tokens[1]), nil, "body")
end)

case("carriage returns and a byte order mark are ignored", function()
	local tokens = Lexer.tokenize("\u{FEFF}local a = 1\r\nreturn a\r\n")
	Assert.equal(tokens[1].text, "local", "first token")
	Assert.equal(tokens[#tokens].line, 2, "line")
end)

return { name = "Lexer", cases = cases } :: Assert.Suite
