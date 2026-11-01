-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Moonwave doc comments in the Roblox code under src/: a class for every module, an interface for every contract,
	and a doc comment for every public function, described in the languages EE-STD-0001 §6 requires.
	src/ 아래 로블록스 코드의 Moonwave 문서 주석: 모든 모듈의 클래스, 모든 계약의 인터페이스,
	모든 공개 함수의 문서 주석, 그리고 EE-STD-0001 §6 이 요구하는 언어로 쓴 설명.
]]

local Architecture = require("./Architecture")
local Lexer = require("./Lexer")
local Report = require("./Report")
local Rule = require("./Rule")
local Snapshot = require("./Snapshot")
local Text = require("./Text")

-- The rules this check reports, declared beside it (CR-0009). / 이 검사가 보고하는 규칙. 검사 옆에 선언한다(CR-0009).
local RULES = {
	MISSING_MODULE_DOC = Rule.new(
		"MISSING_MODULE_DOC",
		"ERROR",
		"EE-STD-0001",
		"Every module under src/ opens with a Moonwave doc comment with @class; a contract adds @interface."
	),
	MISSING_FUNCTION_DOC = Rule.new(
		"MISSING_FUNCTION_DOC",
		"ERROR",
		"EE-STD-0001",
		"Every public function under src/ carries a Moonwave doc comment directly above it."
	),
	INCOMPLETE_DOC_COMMENT = Rule.new(
		"INCOMPLETE_DOC_COMMENT",
		"ERROR",
		"EE-STD-0001",
		"A function doc comment carries @within, a @param for each parameter, and @return if it returns."
	),
	DOC_COMMENT_LANGUAGE = Rule.new(
		"DOC_COMMENT_LANGUAGE",
		"ERROR",
		"EE-STD-0001",
		"Classes and interfaces are described in English and Korean; other doc comments in English."
	),
}

-- Moonwave reads block comments of level one, --[=[ ... ]=], and no other.
local DOC_LEVEL = 1

type DocComment = {
	line: number,
	-- Tag name without the @ -> the text after each occurrence of the tag.
	tags: { [string]: { string } },
	-- The lines that are neither tags nor interface fields.
	description: { string },
}

type PublicFunction = {
	name: string,
	line: number,
	-- Index into the token list of the first token of the declaration.
	start: number,
	parameters: { string },
	returnsValue: boolean,
}

local function parse(token: Lexer.Token): DocComment?
	if Lexer.blockLevel(token) ~= DOC_LEVEL then
		return nil
	end
	local body = Lexer.blockBody(token)
	-- Moonwave rejects a doc comment whose opening line carries text.
	if body == nil or string.find(string.match(body, "^[^\n]*") or "", "%S") then
		return nil
	end
	local doc: DocComment = { line = token.line, tags = {}, description = {} }
	for _, raw in string.split(body, "\n") do
		local line = Text.trim(raw)
		local tag, value = string.match(line, "^@(%S+)%s*(.*)$")
		if tag and value then
			doc.tags[tag] = doc.tags[tag] or {}
			table.insert(doc.tags[tag], value)
		elseif line ~= "" and string.sub(line, 1, 1) ~= "." then
			table.insert(doc.description, line)
		end
	end
	return doc
end

-- The first word of the first occurrence of a tag, as in the name after @class or @param.
local function firstWord(doc: DocComment, tag: string): string?
	local values = doc.tags[tag]
	if values == nil then
		return nil
	end
	return string.match(values[1], "^(%S+)")
end

local function isEnglish(line: string): boolean
	return string.find(line, "%a") ~= nil and not Text.hasHangul(line)
end

-- English first, then Korean.
local function isBilingual(doc: DocComment): boolean
	local english: number?, korean: number? = nil, nil
	for index, line in doc.description do
		if english == nil and isEnglish(line) then
			english = index
		end
		if korean == nil and Text.hasHangul(line) then
			korean = index
		end
	end
	return english ~= nil and korean ~= nil and english < korean
end

local function hasHangul(doc: DocComment): boolean
	for _, values in doc.tags do
		for _, value in values do
			if Text.hasHangul(value) then
				return true
			end
		end
	end
	for _, line in doc.description do
		if Text.hasHangul(line) then
			return true
		end
	end
	return false
end

local function isSymbol(token: Lexer.Token?, text: string): boolean
	return token ~= nil and token.kind == "symbol" and token.text == text
end

local function isName(token: Lexer.Token?, text: string?): boolean
	return token ~= nil and token.kind == "name" and (text == nil or token.text == text)
end

-- The name of the table that the module returns, if its last statement returns a name, as in return Module,
-- return Module :: Type or return table.freeze(Module) (CR-0018).
local function returnedName(code: { Lexer.Token }): string?
	local index = #code
	while index > 0 and not isName(code[index], "return") do
		index -= 1
	end
	local first = code[index + 1]
	if index == 0 or not isName(first) then
		return nil
	end
	for later = index + 1, #code do
		if isName(code[later], "end") then
			return nil
		end
	end
	local after = code[index + 2]
	if after == nil or isSymbol(after, "::") then
		return first.text
	end
	local frozen = code[index + 5]
	if
		first.text == "table"
		and isSymbol(after, ".")
		and isName(code[index + 3], "freeze")
		and isSymbol(code[index + 4], "(")
		and isName(frozen)
		and isSymbol(code[index + 6], ")")
		and code[index + 7] == nil
	then
		return frozen.text
	end
	return nil
end

local OPENERS = { ["("] = true, ["{"] = true, ["["] = true, ["<"] = true }
local CLOSERS = { [")"] = true, ["}"] = true, ["]"] = true, [">"] = true }

-- Reads the parameter list that opens at index open, and whether a return type follows it.
local function signature(code: { Lexer.Token }, open: number): ({ string }, boolean)
	local parameters = {}
	local depth = 0
	local expectName = false
	local index = open
	while index <= #code do
		local token = code[index]
		if token.kind == "symbol" and OPENERS[token.text] then
			depth += 1
			expectName = depth == 1
		elseif token.kind == "symbol" and CLOSERS[token.text] then
			depth -= 1
			if depth == 0 then
				break
			end
		elseif depth == 1 and isSymbol(token, ",") then
			expectName = true
		elseif depth == 1 and expectName then
			if token.kind == "name" or isSymbol(token, "...") then
				table.insert(parameters, token.text)
			end
			expectName = false
		end
		index += 1
	end
	local colon, after, afterThat, beyond = code[index + 1], code[index + 2], code[index + 3], code[index + 4]
	-- A return type of exactly (), not a function type such as () -> number that begins with it (CR-0018).
	local returnsNothing = isSymbol(after, "(") and isSymbol(afterThat, ")") and not isSymbol(beyond, "->")
	local returnsValue = isSymbol(colon, ":") and not returnsNothing
	return parameters, returnsValue
end

-- Functions declared on the returned table, as in function Module.Name(...) or Module.Name = function(...).
local function publicFunctions(code: { Lexer.Token }, moduleTable: string): { PublicFunction }
	local functions = {}
	for index, token in code do
		local start: number?, name: string?, open: number? = nil, nil, nil
		if
			isName(token, "function")
			and isName(code[index + 1], moduleTable)
			and (isSymbol(code[index + 2], ".") or isSymbol(code[index + 2], ":"))
			and isName(code[index + 3])
		then
			start, name = index, code[index + 3].text
			open = index + 4
		elseif
			isName(token, moduleTable)
			and not isSymbol(code[index - 1], ".")
			and not isSymbol(code[index - 1], ":")
			and isSymbol(code[index + 1], ".")
			and isName(code[index + 2])
			and isSymbol(code[index + 3], "=")
			and isName(code[index + 4], "function")
		then
			start, name = index, code[index + 2].text
			open = index + 5
		end
		if start and name and open and string.sub(name, 1, 1) ~= "_" then
			while open <= #code and not isSymbol(code[open], "(") do
				open += 1
			end
			local parameters, returnsValue = signature(code, open)
			table.insert(functions, {
				name = name,
				line = token.line,
				start = start,
				parameters = parameters,
				returnsValue = returnsValue,
			})
		end
	end
	return functions
end

-- The doc comment directly above a token: the nearest one among the comments that precede it with no code between.
local function docAbove(tokens: { Lexer.Token }, target: Lexer.Token): DocComment?
	local position = table.find(tokens, target)
	if position == nil then
		return nil
	end
	for index = position - 1, 1, -1 do
		local token = tokens[index]
		if token.kind ~= "comment" then
			return nil
		end
		local doc = parse(token)
		if doc then
			return doc
		end
	end
	return nil
end

local function checkFunction(
	path: string,
	tokens: { Lexer.Token },
	code: { Lexer.Token },
	fn: PublicFunction,
	className: string,
	report: Report.Report
)
	local doc = docAbove(tokens, code[fn.start])
	if doc == nil then
		Report.add(
			report,
			RULES.MISSING_FUNCTION_DOC,
			path,
			fn.line,
			string.format("public function %s has no Moonwave doc comment (--[=[ ... ]=]) directly above it", fn.name)
		)
		return
	end

	local problems = {}
	local within = firstWord(doc, "within")
	if within ~= className then
		table.insert(problems, string.format("@within %s", className))
	end
	local documented: { [string]: boolean } = {}
	for _, value in doc.tags.param or ({} :: { string }) do
		local word = string.match(value, "^(%S+)")
		if word then
			-- Moonwave lets an optional parameter be documented as name?.
			local name = string.gsub(word, "%?$", "")
			documented[name] = true
			if not table.find(fn.parameters, name) then
				table.insert(problems, string.format("no @param %s, which is not a parameter", name))
			end
		end
	end
	for _, parameter in fn.parameters do
		if parameter ~= "self" and not documented[parameter] then
			table.insert(problems, string.format("@param %s", parameter))
		end
	end
	if fn.returnsValue and doc.tags["return"] == nil then
		table.insert(problems, "@return")
	end
	if #problems > 0 then
		Report.add(
			report,
			RULES.INCOMPLETE_DOC_COMMENT,
			path,
			doc.line,
			string.format("the doc comment of %s needs: %s", fn.name, table.concat(problems, ", "))
		)
	end
end

local function checkFile(path: string, content: string, report: Report.Report)
	local tokens = Lexer.tokenize(content)
	local code = Lexer.code(tokens)
	local isRoot = Architecture.isCompositionRoot(path)
	local name = Architecture.moduleName(path)

	-- The module doc comment is the first doc comment before any code.
	local moduleDoc: DocComment? = nil
	for _, token in tokens do
		if token.kind ~= "comment" then
			break
		end
		moduleDoc = parse(token)
		if moduleDoc then
			break
		end
	end

	local className = name
	local declared = if moduleDoc then firstWord(moduleDoc, "class") else nil
	if moduleDoc == nil or declared == nil then
		Report.add(
			report,
			RULES.MISSING_MODULE_DOC,
			path,
			1,
			"the module opens, before any code, with a Moonwave doc comment (--[=[ ... ]=]) that carries @class"
		)
	elseif isRoot then
		className = declared
	elseif declared ~= name then
		Report.add(
			report,
			RULES.MISSING_MODULE_DOC,
			path,
			moduleDoc.line,
			string.format("the module doc comment names @class %s, but the module is %s", declared, name)
		)
	end

	local docs: { DocComment } = {}
	for _, token in tokens do
		local doc = parse(token)
		if doc then
			table.insert(docs, doc)
		end
	end

	if not isRoot and Architecture.isContractName(name) then
		local found = false
		for _, doc in docs do
			if firstWord(doc, "interface") == name and firstWord(doc, "within") == name then
				found = true
			end
		end
		if not found then
			Report.add(
				report,
				RULES.MISSING_MODULE_DOC,
				path,
				nil,
				string.format("a contract module documents its contract with @interface %s and @within %s", name, name)
			)
		end
	end

	for _, doc in docs do
		if doc.tags.class or doc.tags.interface then
			if not isBilingual(doc) then
				Report.add(
					report,
					RULES.DOC_COMMENT_LANGUAGE,
					path,
					doc.line,
					"a class or interface is described in English and then in Korean"
				)
			end
		elseif hasHangul(doc) then
			Report.add(
				report,
				RULES.DOC_COMMENT_LANGUAGE,
				path,
				doc.line,
				"this doc comment is written in English only"
			)
		end
	end

	local moduleTable = returnedName(code)
	if moduleTable then
		for _, fn in publicFunctions(code, moduleTable) do
			checkFunction(path, tokens, code, fn, className, report)
		end
	end
end

local DocComments = {}

DocComments.RULES = RULES

function DocComments.check(snapshot: Snapshot.Snapshot, report: Report.Report)
	for _, path in Snapshot.paths(snapshot) do
		if Architecture.isRobloxCode(path) then
			checkFile(path, snapshot.files[path], report)
		end
	end
end

return DocComments
