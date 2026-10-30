-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The shape of the Roblox code under src/: the layer every module belongs to, the layers it may require,
	and the suffix its name must end with.
	src/ 아래 로블록스 코드의 모양: 모든 모듈이 속하는 계층, 모듈이 require 할 수 있는 계층, 이름이 끝나야 하는 접미사.
]]

local Report = require("./Report")
local Snapshot = require("./Snapshot")
local Text = require("./Text")

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

-- Blanks out comments but keeps their line breaks, so that line numbers stay true.
local function withoutComments(source: string): string
	local function blank(comment: string): string
		return string.rep("\n", select(2, string.gsub(comment, "\n", "")))
	end
	source = (string.gsub(source, "%-%-%[(=*)%[.-%]%1%]", blank))
	return (string.gsub(source, "%-%-[^\n]*", ""))
end

local function lineAt(source: string, position: number): number
	return select(2, string.gsub(string.sub(source, 1, position), "\n", "")) + 1
end

local function checkRequires(path: string, layer: string, content: string, report: Report.Report)
	local source = withoutComments(Text.normalize(content))
	-- Position captures are numbers at run time, though the type checker sees every capture as a string.
	for position: any, argument: any in string.gmatch(source, "()require%s*(%b())") do
		for token in string.gmatch(argument :: string, "[%w_]+") do
			if Text.contains(LAYERS, token) and not Text.contains(ALLOWED[layer], token) then
				Report.add(
					report,
					"LAYER_VIOLATION",
					path,
					lineAt(source, tonumber(position) or 1),
					string.format("the %s layer may not require the %s layer", layer, token)
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
				"LAYER_VIOLATION",
				path,
				nil,
				string.format("every module belongs to a layer: src/<side>/<%s>/", table.concat(LAYERS, "|"))
			)
		end

		local name = moduleName(path)
		if not isApprovedName(name) then
			Report.add(
				report,
				"MODULE_NAME_SUFFIX",
				path,
				nil,
				string.format("'%s' is neither an interface (I...) nor a name ending in an approved suffix", name)
			)
		end
	end
end

return Architecture
