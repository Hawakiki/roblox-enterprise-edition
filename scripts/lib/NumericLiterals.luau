-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Numeric literals and colours in the Roblox code under src/ (EE-STD-0005): a number other than -1, 0, 1 and 2
	lives in a module whose name ends with Constants, and every colour comes from the corporate colour palette.
	src/ 아래 로블록스 코드의 숫자 리터럴과 색(EE-STD-0005): -1, 0, 1, 2 가 아닌 숫자는 이름이 Constants 로
	끝나는 모듈에 두고, 모든 색은 사내 색상 팔레트에서 가져온다.
]]

local Architecture = require("./Architecture")
local Lexer = require("./Lexer")
local Report = require("./Report")
local Snapshot = require("./Snapshot")

local SUFFIX = "Constants"
local PALETTE = "src/Shared/Kernel/CorporatePaletteConstants.luau"

-- The default ignore list of the MagicNumber check of Checkstyle: -1, 0, 1 and 2, as they are written.
local EXEMPT: { [string]: boolean } = { ["0"] = true, ["1"] = true, ["2"] = true }
local EXEMPT_NEGATED: { [string]: boolean } = { ["1"] = true }

-- The globals whose members construct colours.
local COLOR_GLOBALS = { "Color3", "BrickColor" }

-- Keywords after which a minus sign starts an expression, and is therefore unary.
local OPENING_KEYWORDS: { [string]: boolean } = {
	["and"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["if"] = true,
	["in"] = true,
	["not"] = true,
	["or"] = true,
	["return"] = true,
	["then"] = true,
	["until"] = true,
	["while"] = true,
}

local CLOSING_SYMBOLS: { [string]: boolean } = { [")"] = true, ["]"] = true, ["}"] = true, ["..."] = true }

local function isConstantsModule(path: string): boolean
	return string.sub(Architecture.moduleName(path), -#SUFFIX) == SUFFIX
end

local function isSymbol(token: Lexer.Token?, text: string): boolean
	return token ~= nil and token.kind == "symbol" and token.text == text
end

-- Whether the minus sign at index is unary: nothing that ends a value comes before it.
local function isUnaryMinus(code: { Lexer.Token }, index: number): boolean
	local before = code[index - 1]
	if before == nil then
		return true
	elseif before.kind == "number" then
		return false
	elseif before.kind == "string" then
		-- The part of an interpolated string that opens an expression, as in `{-2}`.
		return string.sub(before.text, -1) == "{"
	elseif before.kind == "name" then
		return OPENING_KEYWORDS[before.text] == true
	end
	return not CLOSING_SYMBOLS[before.text]
end

local function checkNumbers(path: string, code: { Lexer.Token }, report: Report.Report)
	for index, token in code do
		if token.kind ~= "number" then
			continue
		end
		local negated = isSymbol(code[index - 1], "-") and isUnaryMinus(code, index - 1)
		local exempt = if negated then EXEMPT_NEGATED[token.text] else EXEMPT[token.text]
		if not exempt then
			Report.add(
				report,
				"NUMERIC_LITERAL",
				path,
				token.line,
				string.format(
					"the numeric literal %s%s belongs in a Constants module of the layer that owns its meaning",
					if negated then "-" else "",
					token.text
				)
			)
		end
	end
end

-- Whether the = at index assigns a type, as in type Colour = Color3 or export type Colour<T> = Color3.
local function assignsType(code: { Lexer.Token }, index: number): boolean
	local cursor = index - 1
	if isSymbol(code[cursor], ">") then
		local depth = 0
		while cursor > 1 do
			if isSymbol(code[cursor], ">") then
				depth += 1
			elseif isSymbol(code[cursor], "<") then
				depth -= 1
				if depth == 0 then
					break
				end
			end
			cursor -= 1
		end
		cursor -= 1
	end
	local name, keyword = code[cursor], code[cursor - 1]
	return name ~= nil and name.kind == "name" and keyword ~= nil and keyword.text == "type"
end

-- Whether the global at index is taken as a value of its own, as in local C = Color3 or return Color3.
local function isAliased(code: { Lexer.Token }, index: number): boolean
	local before = code[index - 1]
	if isSymbol(before, "=") then
		return not assignsType(code, index - 1)
	end
	return before ~= nil and before.kind == "name" and before.text == "return"
end

local function checkColors(path: string, code: { Lexer.Token }, report: Report.Report)
	for index, token in code do
		if token.kind ~= "name" or not table.find(COLOR_GLOBALS, token.text) then
			continue
		end
		local before = code[index - 1]
		if isSymbol(before, ".") or isSymbol(before, ":") then
			continue
		end
		local member = Lexer.memberAt(code, index + 1)
		local problem = if member
			then string.format("%s.%s makes a colour", token.text, member)
			elseif isAliased(code, index) then string.format("an alias of %s makes colours", token.text)
			else nil
		if problem then
			Report.add(
				report,
				"COLOR_OUTSIDE_PALETTE",
				path,
				token.line,
				string.format("%s outside the corporate colour palette, %s", problem, PALETTE)
			)
		end
	end
end

local NumericLiterals = {}

NumericLiterals.PALETTE = PALETTE

function NumericLiterals.check(snapshot: Snapshot.Snapshot, report: Report.Report)
	for _, path in Snapshot.paths(snapshot) do
		if not Architecture.isRobloxCode(path) then
			continue
		end
		local code = Lexer.code(Lexer.tokenize(snapshot.files[path]))
		if not isConstantsModule(path) then
			checkNumbers(path, code, report)
		end
		if path ~= PALETTE then
			checkColors(path, code, report)
		end
	end
end

return NumericLiterals
