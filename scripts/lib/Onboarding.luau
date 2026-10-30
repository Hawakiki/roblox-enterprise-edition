-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The entrance files: the Markdown files at the repository root, which agents and people read first.
	They cite only documents that exist, CLAUDE.md imports AGENTS.md, and the two stay short.
	입구 파일: 에이전트와 사람이 가장 먼저 읽는 저장소 루트의 Markdown 파일.
	실재하는 문서만 인용하고, CLAUDE.md 는 AGENTS.md 를 불러오며, 두 파일은 짧게 유지한다.
]]

local Documents = require("./Documents")
local Report = require("./Report")
local Snapshot = require("./Snapshot")
local Text = require("./Text")

local AGENTS = "AGENTS.md"
local CLAUDE = "CLAUDE.md"
local IMPORT = "@AGENTS.md"
-- Claude Code advises keeping instructions under 200 lines, and AGENTS.md loads with the CLAUDE.md that imports it.
local LINE_BUDGET = 200

local function isEntranceFile(path: string): boolean
	return string.find(path, "/", 1, true) == nil and string.sub(path, -3) == ".md"
end

local function linesOf(content: string): { string }
	local lines = string.split(Text.normalize(content), "\n")
	if lines[#lines] == "" then
		table.remove(lines)
	end
	return lines
end

local function checkReferences(path: string, content: string, index: Documents.Index, report: Report.Report)
	local reported: { [string]: boolean } = {}
	for number, line in linesOf(content) do
		for _, token in Documents.referencesIn(line) do
			if index.byId[token] == nil and not reported[token] then
				reported[token] = true
				Report.add(report, "DANGLING_ENTRY_REFERENCE", path, number, string.format("%s does not exist", token))
			end
		end
	end
end

-- Claude Code skips code spans and fenced blocks when it expands imports.
local function importsAgents(content: string): boolean
	local inFence = false
	for _, line in linesOf(content) do
		if string.match(line, "^%s*```") or string.match(line, "^%s*~~~") then
			inFence = not inFence
		elseif not inFence and Text.trim(line) == IMPORT then
			return true
		end
	end
	return false
end

local Onboarding = {}

function Onboarding.check(snapshot: Snapshot.Snapshot, index: Documents.Index, report: Report.Report)
	for _, path in Snapshot.paths(snapshot) do
		if isEntranceFile(path) then
			checkReferences(path, snapshot.files[path], index, report)
		end
	end

	local claude = snapshot.files[CLAUDE]
	if claude and not importsAgents(claude) then
		Report.add(
			report,
			"MISSING_AGENTS_IMPORT",
			CLAUDE,
			nil,
			"import the shared entrance with a line that contains only @AGENTS.md, outside code"
		)
	end

	local total = 0
	for _, path in { AGENTS, CLAUDE } do
		local content = snapshot.files[path]
		if content then
			total += #linesOf(content)
		end
	end
	if total > LINE_BUDGET then
		Report.add(
			report,
			"ONBOARDING_TOO_LONG",
			AGENTS,
			nil,
			string.format(
				"AGENTS.md and CLAUDE.md run to %d lines together; keep them within %d and route to the documents instead",
				total,
				LINE_BUDGET
			)
		)
	end
end

return Onboarding
