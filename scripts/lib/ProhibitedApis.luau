-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The Prohibited API Registry (EE-STD-0003): the directives and attributes that no Luau file declares,
	and the APIs that the Roblox code under src/ uses only where the registry allows them.
	금지 API 목록(EE-STD-0003): 어떤 Luau 파일도 선언하지 않는 지시문과 속성, 그리고 src/ 아래의
	로블록스 코드가 목록이 허용하는 곳에서만 쓰는 API.
]]

local Architecture = require("./Architecture")
local Hygiene = require("./Hygiene")
local Lexer = require("./Lexer")
local Report = require("./Report")
local Snapshot = require("./Snapshot")
local Text = require("./Text")

-- The only directive allowed. Every other hot comment, and every attribute, is prohibited without waiver.
local ALLOWED_DIRECTIVE = "--!strict"

type Place = "Nowhere" | "SanctionedExceptions" | "CompositionRoots" | "InfrastructureFactories"

type Api = {
	-- The API as the registry writes it.
	name: string,
	global: string,
	-- For a member of a global, as in Instance.new.
	member: string?,
	-- Deprecated globals that are only ever called are reported only when called,
	-- so that a local variable that happens to share their name, such as spawn, is left alone.
	callsOnly: boolean,
	place: Place,
}

-- The registry of EE-STD-0003 §5, in its order.
local APIS: { Api } = {
	{ name = "print", global = "print", callsOnly = false, place = "SanctionedExceptions" },
	{ name = "warn", global = "warn", callsOnly = false, place = "SanctionedExceptions" },
	{
		name = "Instance.new",
		global = "Instance",
		member = "new",
		callsOnly = false,
		place = "InfrastructureFactories",
	},
	{ name = "game:GetService", global = "game", member = "GetService", callsOnly = false, place = "CompositionRoots" },
	{
		name = "game:FindService",
		global = "game",
		member = "FindService",
		callsOnly = false,
		place = "CompositionRoots",
	},
	{ name = "wait", global = "wait", callsOnly = true, place = "Nowhere" },
	{ name = "delay", global = "delay", callsOnly = true, place = "Nowhere" },
	{ name = "spawn", global = "spawn", callsOnly = true, place = "Nowhere" },
	{ name = "tick", global = "tick", callsOnly = true, place = "Nowhere" },
	{ name = "loadstring", global = "loadstring", callsOnly = false, place = "Nowhere" },
	{ name = "getfenv", global = "getfenv", callsOnly = false, place = "Nowhere" },
	{ name = "setfenv", global = "setfenv", callsOnly = false, place = "Nowhere" },
	{ name = "_G", global = "_G", callsOnly = false, place = "Nowhere" },
	{ name = "shared", global = "shared", callsOnly = false, place = "Nowhere" },
}

-- The register of sanctioned exceptions of EE-STD-0003 §6: module -> the APIs it may use.
local SANCTIONED: { [string]: { string } } = {
	["src/Shared/Infrastructure/RobloxOutputLoggerAdapter.luau"] = { "print", "warn" },
}

local PLACES: { [Place]: string } = {
	Nowhere = "it is allowed nowhere",
	SanctionedExceptions = "it is allowed only in a sanctioned exception",
	CompositionRoots = "it is allowed only in the composition roots",
	InfrastructureFactories = "it is allowed only in Infrastructure modules whose names end with Factory",
}

local function isAllowed(api: Api, path: string): boolean
	if api.place == "SanctionedExceptions" then
		local apis = SANCTIONED[path]
		return apis ~= nil and table.find(apis, api.name) ~= nil
	elseif api.place == "CompositionRoots" then
		return Architecture.isCompositionRoot(path)
	elseif api.place == "InfrastructureFactories" then
		return Architecture.layerOf(path) == "Infrastructure"
			and string.sub(Architecture.moduleName(path), -#"Factory") == "Factory"
	end
	return false
end

local function isSymbol(token: Lexer.Token?, text: string): boolean
	return token ~= nil and token.kind == "symbol" and token.text == text
end

-- A call passes parentheses, a string or a table constructor.
local function isCall(token: Lexer.Token?): boolean
	return token ~= nil and (isSymbol(token, "(") or isSymbol(token, "{") or token.kind == "string")
end

local function matches(api: Api, code: { Lexer.Token }, index: number): boolean
	local token = code[index]
	if token.kind ~= "name" or token.text ~= api.global then
		return false
	end
	local before, after = code[index - 1], code[index + 1]
	-- A field or method of something else that happens to share the name.
	if isSymbol(before, ".") or isSymbol(before, ":") then
		return false
	end
	local member = api.member
	if member then
		return Lexer.memberAt(code, index + 1) == member
	end
	-- A key in a table constructor, as in { print = true }.
	if (isSymbol(before, "{") or isSymbol(before, ",") or isSymbol(before, ";")) and isSymbol(after, "=") then
		return false
	end
	return not api.callsOnly or isCall(after)
end

local function checkDirectives(path: string, tokens: { Lexer.Token }, report: Report.Report)
	for index, token in tokens do
		if token.kind == "comment" and string.sub(token.text, 1, 3) == "--!" then
			local directive = Text.trimRight(token.text)
			if directive ~= ALLOWED_DIRECTIVE then
				Report.add(
					report,
					"PROHIBITED_DIRECTIVE",
					path,
					token.line,
					string.format("%s is prohibited; %s is the only directive allowed", directive, ALLOWED_DIRECTIVE)
				)
			end
		elseif isSymbol(token, "@") then
			local nextToken = tokens[index + 1]
			local attribute = "@" .. (if nextToken then nextToken.text else "")
			Report.add(
				report,
				"PROHIBITED_DIRECTIVE",
				path,
				token.line,
				string.format("the attribute %s is prohibited; no function carries an attribute", attribute)
			)
		end
	end
end

local function checkApis(path: string, tokens: { Lexer.Token }, report: Report.Report)
	local code = Lexer.code(tokens)
	for index, token in code do
		for _, api in APIS do
			if matches(api, code, index) and not isAllowed(api, path) then
				Report.add(
					report,
					"PROHIBITED_API",
					path,
					token.line,
					string.format("%s is prohibited here: %s", api.name, PLACES[api.place])
				)
			end
		end
	end
end

local ProhibitedApis = {}

function ProhibitedApis.check(snapshot: Snapshot.Snapshot, report: Report.Report)
	for _, path in Snapshot.paths(snapshot) do
		if Hygiene.extension(path) ~= "luau" then
			continue
		end
		local tokens = Lexer.tokenize(snapshot.files[path])
		checkDirectives(path, tokens, report)
		if Architecture.isRobloxCode(path) then
			checkApis(path, tokens, report)
		end
	end
end

return ProhibitedApis
