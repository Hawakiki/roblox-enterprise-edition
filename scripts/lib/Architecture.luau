-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The shape of the Roblox code under src/: the layer every module belongs to, the layers it may require,
	and the suffix its name must end with.
	src/ 아래 로블록스 코드의 모양: 모든 모듈이 속하는 계층, 모듈이 require 할 수 있는 계층, 이름이 끝나야 하는 접미사.
]]

local Lexer = require("./Lexer")
local Report = require("./Report")
local Rule = require("./Rule")
local Snapshot = require("./Snapshot")
local Text = require("./Text")

-- The rules this check reports, declared beside it (CR-0009). / 이 검사가 보고하는 규칙. 검사 옆에 선언한다(CR-0009).
local RULES = {
	LAYER_VIOLATION = Rule.new(
		"LAYER_VIOLATION",
		"ERROR",
		"EE-STD-0006",
		"Every module belongs to a layer and requires only the layers it may depend on."
	),
	MODULE_NAME_SUFFIX = Rule.new(
		"MODULE_NAME_SUFFIX",
		"ERROR",
		"EE-STD-0002",
		"A module is an interface named I..., or its name ends with an approved suffix."
	),
}

local LAYERS = { "Kernel", "Domain", "Application", "Infrastructure", "Presentation" }

-- The layers each layer may require, itself included. Dependencies point inwards, towards the kernel.
local ALLOWED: { [string]: { string } } = {
	Kernel = { "Kernel" },
	Domain = { "Domain", "Kernel" },
	Application = { "Application", "Domain", "Kernel" },
	Infrastructure = { "Infrastructure", "Application", "Domain", "Kernel" },
	Presentation = { "Presentation", "Application", "Domain", "Kernel" },
}

local SUFFIXES = {
	"Adapter",
	"Collection",
	"Component",
	"Constants",
	"Controller",
	"Entity",
	"Factory",
	"Gateway",
	"Handler",
	"Host",
	"Mapper",
	"Options",
	"Orchestrator",
	"Policy",
	"Projection",
	"Provider",
	"Registry",
	"Repository",
	"Scope",
	"Service",
	"Specification",
	"Strategy",
	"Token",
	"UseCase",
	"ValueObject",
}

local Architecture = {}

Architecture.RULES = RULES

Architecture.LAYERS = LAYERS
Architecture.SUFFIXES = SUFFIXES

local function isCompositionRoot(path: string): boolean
	return string.match(path, "^src/[^/]+/init%.[%a]+%.luau$") ~= nil
end

local function layerOf(path: string): string?
	local layer = string.match(path, "^src/[^/]+/([^/]+)/")
	if layer and Text.contains(LAYERS, layer) then
		return layer
	end
	return nil
end

-- The name of the module a file defines: a folder module named init takes the name of its folder.
local function moduleName(path: string): string
	local folder, file = string.match(path, "([^/]+)/([^/]+)%.luau$")
	if file == "init" and folder then
		return folder
	end
	return file or path
end

-- A contract module is named I followed by the name of its contract (EE-STD-0002 §3).
local function isContractName(name: string): boolean
	return string.find(name, "^I%u") ~= nil
end

-- Shared with the other checks of the Roblox code.
Architecture.isCompositionRoot = isCompositionRoot
Architecture.isContractName = isContractName
Architecture.layerOf = layerOf
Architecture.moduleName = moduleName

-- Every Luau file under src/, composition roots included.
function Architecture.isRobloxCode(path: string): boolean
	return string.sub(path, 1, 4) == "src/" and string.sub(path, -5) == ".luau"
end

local function isApprovedName(name: string): boolean
	if string.find(name, "^%u%w*$") == nil then
		return false
	end
	if isContractName(name) then
		return true
	end
	for _, suffix in SUFFIXES do
		if #name > #suffix and string.sub(name, -#suffix) == suffix then
			return true
		end
	end
	return false
end

local function isSymbol(token: Lexer.Token?, text: string): boolean
	return token ~= nil and token.kind == "symbol" and token.text == text
end

-- The layer that a token of a require path names, as a name or as a string in brackets: Parent["Kernel"].
local function namedLayer(token: Lexer.Token): string?
	local name = if token.kind == "name" then token.text else Lexer.stringValue(token)
	return if name and Text.contains(LAYERS, name) then name else nil
end

-- Reads every require through the lexer, so that neither a comment nor a string can hide one or fake one.
local function checkRequires(path: string, layer: string, content: string, report: Report.Report)
	local code = Lexer.code(Lexer.tokenize(content))
	for index, token in code do
		if token.kind ~= "name" or token.text ~= "require" or not isSymbol(code[index + 1], "(") then
			continue
		end
		local depth = 0
		for argument = index + 1, #code do
			local part = code[argument]
			if isSymbol(part, "(") then
				depth += 1
			elseif isSymbol(part, ")") then
				depth -= 1
				if depth == 0 then
					break
				end
			end
			local named = namedLayer(part)
			if named and not Text.contains(ALLOWED[layer], named) then
				Report.add(
					report,
					RULES.LAYER_VIOLATION,
					path,
					token.line,
					string.format("the %s layer may not require the %s layer", layer, named)
				)
			end
		end
	end
end

function Architecture.check(snapshot: Snapshot.Snapshot, report: Report.Report)
	for _, path in Snapshot.paths(snapshot) do
		if not Architecture.isRobloxCode(path) or isCompositionRoot(path) then
			continue
		end

		local layer = layerOf(path)
		if layer then
			checkRequires(path, layer, snapshot.files[path], report)
		else
			Report.add(
				report,
				RULES.LAYER_VIOLATION,
				path,
				nil,
				string.format("every module belongs to a layer: src/<side>/<%s>/", table.concat(LAYERS, "|"))
			)
		end

		local name = moduleName(path)
		if not isApprovedName(name) then
			Report.add(
				report,
				RULES.MODULE_NAME_SUFFIX,
				path,
				nil,
				string.format("'%s' is neither an interface (I...) nor a name ending in an approved suffix", name)
			)
		end
	end
end

return Architecture
