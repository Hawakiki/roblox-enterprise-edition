-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	A Luau lexer, exactly as good as compliance needs: it splits source into names, numbers, strings, comments
	and symbols, so that rules about code are not fooled by comments and strings, and rules about comments
	are not fooled by code. It never rejects a file; the type checker does that.
	규정 준수에 필요한 만큼의 Luau 어휘 분석기. 소스를 이름, 숫자, 문자열, 주석, 기호로 나누어,
	코드에 관한 규칙이 주석과 문자열에 속지 않고 주석에 관한 규칙이 코드에 속지 않게 한다.
	파일을 거부하는 일은 하지 않는다. 그것은 타입 검사기의 일이다.
]]

local Text = require("./Text")

export type Kind = "name" | "number" | "string" | "comment" | "symbol"

export type Token = {
	kind: Kind,
	-- The exact source text of the token. An interpolated string is split around its expressions.
	text: string,
	-- The line on which the token starts.
	line: number,
}

local SYMBOLS = {
	"...",
	"..=",
	"//=",
	"..",
	"==",
	"~=",
	"<=",
	">=",
	"->",
	"::",
	"//",
	"+=",
	"-=",
	"*=",
	"/=",
	"%=",
	"^=",
}

-- Longest first: an exponent before a plain number, a hexadecimal or binary prefix before both.
local NUMBERS = {
	"^0[xX][%x_]*",
	"^0[bB][01_]*",
	"^%d[%d_]*%.?[%d_]*[eE][%+%-]?[%d_]+",
	"^%d[%d_]*%.?[%d_]*",
	"^%.%d[%d_]*[eE][%+%-]?[%d_]+",
	"^%.%d[%d_]*",
}

local function newlines(s: string): number
	return select(2, string.gsub(s, "\n", ""))
end

local Lexer = {}

function Lexer.tokenize(content: string): { Token }
	local source = Text.normalize(content)
	local length = #source
	local position = 1
	local line = 1
	local tokens: { Token } = {}

	local function emit(kind: Kind, first: number, last: number)
		local text = string.sub(source, first, last)
		table.insert(tokens, { kind = kind, text = text, line = line })
		line += newlines(text)
		position = last + 1
	end

	-- The last position of a long bracket that opens at first, as in [==[, or nil if none opens there.
	local function longBracketEnd(first: number): number?
		local equals = string.match(source, "^%[(=*)%[", first)
		if equals == nil then
			return nil
		end
		local _, last = string.find(source, "]" .. equals .. "]", first + #equals + 2, true)
		return last or length
	end

	-- The last position of a quoted string that opens at first. An unterminated string ends with its line.
	local function quotedEnd(first: number, quote: string): number
		local index = first + 1
		while index <= length do
			local char = string.sub(source, index, index)
			if char == "\\" then
				if string.sub(source, index + 1, index + 1) == "z" then
					local _, last = string.find(source, "^%s*", index + 2)
					index = (last or index + 1) + 1
				else
					index += 2
				end
			elseif char == quote then
				return index
			elseif char == "\n" then
				return index - 1
			else
				index += 1
			end
		end
		return length
	end

	local scanInterpolated: (first: number) -> ()

	-- Scans code until the end of the source, or, inside an interpolated string, until the brace that closes it.
	local function scanCode(insideInterpolation: boolean)
		local depth = 0
		while position <= length do
			local first = position
			local char = string.sub(source, first, first)
			if string.find(char, "^%s") then
				local _, last = string.find(source, "^%s+", first)
				local stop = last or first
				line += newlines(string.sub(source, first, stop))
				position = stop + 1
			elseif string.sub(source, first, first + 1) == "--" then
				local last = longBracketEnd(first + 2)
				if last == nil then
					last = (string.find(source, "\n", first, true) or length + 1) - 1
				end
				emit("comment", first, last :: number)
			elseif char == '"' or char == "'" then
				emit("string", first, quotedEnd(first, char))
			elseif char == "`" then
				scanInterpolated(first)
			elseif char == "[" and longBracketEnd(first) ~= nil then
				emit("string", first, longBracketEnd(first) :: number)
			elseif string.find(char, "^[%a_]") then
				local _, last = string.find(source, "^[%w_]+", first)
				emit("name", first, last or first)
			elseif string.find(source, "^%.?%d", first) then
				for _, pattern in NUMBERS do
					local _, last = string.find(source, pattern, first)
					if last then
						emit("number", first, last)
						break
					end
				end
			else
				if insideInterpolation and char == "}" and depth == 0 then
					return
				end
				if char == "{" then
					depth += 1
				elseif char == "}" then
					depth -= 1
				end
				local last = first
				for _, symbol in SYMBOLS do
					if string.sub(source, first, first + #symbol - 1) == symbol then
						last = first + #symbol - 1
						break
					end
				end
				emit("symbol", first, last)
			end
		end
	end

	-- An interpolated string is a string around expressions: each expression is lexed as code.
	scanInterpolated = function(first: number)
		local partStart = first
		position = first + 1
		while position <= length do
			local char = string.sub(source, position, position)
			if char == "\\" then
				position += 2
			elseif char == "`" then
				emit("string", partStart, position)
				return
			elseif char == "{" then
				emit("string", partStart, position)
				scanCode(true)
				partStart = position
				position += 1
			elseif char == "\n" then
				break
			else
				position += 1
			end
		end
		if partStart < position then
			emit("string", partStart, math.min(position, length + 1) - 1)
		end
	end

	scanCode(false)
	return tokens
end

-- Every token that is not a comment, in order.
function Lexer.code(tokens: { Token }): { Token }
	local code = {}
	for _, token in tokens do
		if token.kind ~= "comment" then
			table.insert(code, token)
		end
	end
	return code
end

-- The text between the quotes or long brackets of a string, escapes left as written. Nil for anything else,
-- an interpolated string with expressions included.
function Lexer.stringValue(token: Token?): string?
	if token == nil or token.kind ~= "string" then
		return nil
	end
	local text = token.text
	return string.match(text, '^"(.*)"$')
		or string.match(text, "^'(.*)'$")
		or string.match(text, "^`([^{]*)`$")
		or string.match(text, "^%[=*%[(.-)%]=*%]$")
end

-- The member that the code tokens from index on name, as .new, :GetService and ["GetService"] do, or nil.
function Lexer.memberAt(code: { Token }, index: number): string?
	local first, second, third = code[index], code[index + 1], code[index + 2]
	if first == nil or first.kind ~= "symbol" or second == nil then
		return nil
	elseif (first.text == "." or first.text == ":") and second.kind == "name" then
		return second.text
	elseif first.text == "[" and third ~= nil and third.kind == "symbol" and third.text == "]" then
		return Lexer.stringValue(second)
	end
	return nil
end

-- The level of a block comment, as the number of equals signs in its bracket, or nil for a line comment.
function Lexer.blockLevel(token: Token): number?
	if token.kind ~= "comment" then
		return nil
	end
	local equals = string.match(token.text, "^%-%-%[(=*)%[")
	return if equals then #equals else nil
end

-- The text between the brackets of a block comment, or nil for anything else, an unterminated comment included.
function Lexer.blockBody(token: Token): string?
	local level = Lexer.blockLevel(token)
	if level == nil then
		return nil
	end
	local equals = string.rep("=", level)
	local opening = "--[" .. equals .. "["
	local closing = "]" .. equals .. "]"
	if #token.text < #opening + #closing or string.sub(token.text, -#closing) ~= closing then
		return nil
	end
	return string.sub(token.text, #opening + 1, -#closing - 1)
end

return Lexer
