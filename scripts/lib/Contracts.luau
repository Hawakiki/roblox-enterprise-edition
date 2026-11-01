-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	How the Roblox code declares its contracts: every entry of _implements is a wrapper written with the
	signature of the contract, and a cast through any stands only where a constructor returns its instance as
	its contract (EE-STD-0006 §6, CR-0023).
	로블록스 코드가 계약을 선언하는 방식: _implements 의 모든 항목은 계약의 시그니처로 쓴 래퍼이고, any
	캐스트는 생성자가 인스턴스를 계약으로 반환하는 자리에만 있다(EE-STD-0006 §6, CR-0023).
]]

local Architecture = require("./Architecture")
local Lexer = require("./Lexer")
local Report = require("./Report")
local Rule = require("./Rule")
local Snapshot = require("./Snapshot")

-- The rules this check reports, declared beside it (CR-0009). / 이 검사가 보고하는 규칙. 검사 옆에 선언한다(CR-0009).
local RULES = {
	IMPLEMENTS_NOT_WRAPPED = Rule.new(
		"IMPLEMENTS_NOT_WRAPPED",
		"ERROR",
		"EE-STD-0006",
		"Every entry of _implements is a function that wraps the method it declares."
	),
	CAST_THROUGH_ANY = Rule.new(
		"CAST_THROUGH_ANY",
		"ERROR",
		"EE-STD-0006",
		"A cast through any stands only in return setmetatable(state, Class) :: any."
	),
}

-- Keywords that open a block, and the keywords that close one.
local OPENERS = { "function", "do", "repeat" }
local CLOSERS = { "end", "until" }

-- The tokens after which an if starts an expression, which needs no end, rather than a statement.
local EXPRESSION_BEFORE = {
	"=",
	"(",
	"[",
	"{",
	",",
	"..",
	"+",
	"-",
	"*",
	"/",
	"//",
	"%",
	"^",
	"#",
	"==",
	"~=",
	"<",
	">",
	"<=",
	">=",
	"+=",
	"-=",
	"*=",
	"/=",
	"//=",
	"%=",
	"^=",
	"..=",
	"return",
	"and",
	"or",
	"not",
}

-- The tokens that may follow the value of a return, which is the last statement of its block.
local AFTER_RETURN = { "end", "else", "elseif", "until", ";" }

local function isSymbol(token: Lexer.Token?, text: string): boolean
	return token ~= nil and token.kind == "symbol" and token.text == text
end

local function isName(token: Lexer.Token?, text: string?): boolean
	return token ~= nil and token.kind == "name" and (text == nil or token.text == text)
end

-- Whether the token opens a block that an end or an until closes.
local function opensBlock(code: { Lexer.Token }, index: number): boolean
	local token = code[index]
	if token.kind ~= "name" then
		return false
	elseif table.find(OPENERS, token.text) then
		return true
	elseif token.text ~= "if" then
		return false
	end
	local before = code[index - 1]
	return before == nil or table.find(EXPRESSION_BEFORE, before.text) == nil
end

-- The index of the token that closes the bracket opened at index, or the last index if none does.
local function closingBracket(code: { Lexer.Token }, index: number): number
	local depth = 0
	for position = index, #code do
		local text = if code[position].kind == "symbol" then code[position].text else ""
		if text == "(" or text == "[" or text == "{" then
			depth += 1
		elseif text == ")" or text == "]" or text == "}" then
			depth -= 1
			if depth == 0 then
				return position
			end
		end
	end
	return #code
end

-- The index just past the value that starts at index: at the comma, semicolon or brace that ends its entry.
local function valueEnd(code: { Lexer.Token }, index: number): number
	local brackets, blocks = 0, 0
	for position = index, #code do
		local token = code[position]
		if token.kind == "symbol" then
			local text = token.text
			if text == "(" or text == "[" or text == "{" then
				brackets += 1
			elseif text == ")" or text == "]" or text == "}" then
				if brackets == 0 then
					return position
				end
				brackets -= 1
			elseif (text == "," or text == ";") and brackets == 0 and blocks == 0 then
				return position
			end
		elseif opensBlock(code, position) then
			blocks += 1
		elseif table.find(CLOSERS, token.text) then
			blocks -= 1
		end
	end
	return #code + 1
end

-- Reports every entry of the table constructor that opens at index whose value is not a function.
local function checkEntries(path: string, code: { Lexer.Token }, index: number, report: Report.Report)
	local position = index + 1
	local count = 0
	while position <= #code and not isSymbol(code[position], "}") do
		count += 1
		local name = string.format("#%d", count)
		local valueAt = position
		if isName(code[position]) and isSymbol(code[position + 1], "=") then
			name = code[position].text
			valueAt = position + 2
		elseif isSymbol(code[position], "[") then
			local close = closingBracket(code, position)
			name = Lexer.stringValue(code[position + 1]) or name
			if isSymbol(code[close + 1], "=") then
				valueAt = close + 2
			end
		end
		if not isName(code[valueAt], "function") then
			Report.add(
				report,
				RULES.IMPLEMENTS_NOT_WRAPPED,
				path,
				code[position].line,
				string.format(
					"the entry %s of _implements does not wrap its method; write a function with the signature of "
						.. "the contract that calls the method",
					name
				)
			)
		end
		position = valueEnd(code, valueAt) + 1
		if position - 1 <= #code and isSymbol(code[position - 1], "}") then
			break
		end
	end
end

local function checkImplements(path: string, code: { Lexer.Token }, report: Report.Report)
	for index, token in code do
		if isName(token, "local") and isName(code[index + 1], "_implements") then
			for position = index + 2, #code do
				if isSymbol(code[position], "{") then
					checkEntries(path, code, position, report)
					break
				elseif isSymbol(code[position], "=") and not isSymbol(code[position + 1], "{") then
					break
				end
			end
		end
	end
end

-- Whether the cast at index is the one a constructor makes: return setmetatable(state, Class) :: any.
local function isConstructorReturn(code: { Lexer.Token }, index: number): boolean
	local after = code[index + 2]
	return isName(code[index - 7], "return")
		and isName(code[index - 6], "setmetatable")
		and isSymbol(code[index - 5], "(")
		and isName(code[index - 4])
		and isSymbol(code[index - 3], ",")
		and isName(code[index - 2])
		and isSymbol(code[index - 1], ")")
		and (after == nil or table.find(AFTER_RETURN, after.text) ~= nil)
end

local function checkCasts(path: string, code: { Lexer.Token }, report: Report.Report)
	for index, token in code do
		if isSymbol(token, "::") and isName(code[index + 1], "any") and not isConstructorReturn(code, index) then
			Report.add(
				report,
				RULES.CAST_THROUGH_ANY,
				path,
				token.line,
				"a cast through any stands only where a constructor returns its instance: "
					.. "return setmetatable(state, Class) :: any"
			)
		end
	end
end

local Contracts = {}

Contracts.RULES = RULES

function Contracts.check(snapshot: Snapshot.Snapshot, report: Report.Report)
	for _, path in Snapshot.paths(snapshot) do
		if Architecture.isRobloxCode(path) then
			local code = Lexer.code(Lexer.tokenize(snapshot.files[path]))
			checkImplements(path, code, report)
			checkCasts(path, code, report)
		end
	end
end

return Contracts
