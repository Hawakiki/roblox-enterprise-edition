-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	File headers: the SPDX license header on every file that can carry a comment,
	and the strict mode hot comment on every Luau file.
	파일 헤더: 주석을 달 수 있는 모든 파일의 SPDX 라이선스 헤더와, 모든 Luau 파일의 strict 모드 선언.
]]

local Hygiene = require("./Hygiene")
local Report = require("./Report")
local Rule = require("./Rule")
local Snapshot = require("./Snapshot")
local Text = require("./Text")

-- The rules this check reports, declared beside it (CR-0009). / 이 검사가 보고하는 규칙. 검사 옆에 선언한다(CR-0009).
local RULES = {
	MISSING_STRICT_MODE = Rule.new(
		"MISSING_STRICT_MODE",
		"ERROR",
		"EE-STD-0001",
		"Every Luau file declares --!strict before any code."
	),
	MISSING_SPDX_HEADER = Rule.new(
		"MISSING_SPDX_HEADER",
		"ERROR",
		"EE-STD-0004",
		"Every file that can carry a comment opens with an MIT SPDX header."
	),
}

-- The header must appear within this many lines, to leave room for a shebang or frontmatter delimiter.
local HEADER_WINDOW = 10
local LICENSE_TAG = "SPDX-License-Identifier: MIT"
local COPYRIGHT_TAG = "SPDX-FileCopyrightText: "

-- Files whose format has no comment syntax, and the license text itself.
local function isExempt(path: string): boolean
	local name = string.match(path, "([^/]+)$") or path
	return Hygiene.extension(path) == "json" or name == ".luaurc" or name == "LICENSE"
end

local function checkSpdx(path: string, lines: { string }, report: Report.Report)
	local license, copyright = false, false
	for number = 1, math.min(#lines, HEADER_WINDOW) do
		local line = lines[number]
		license = license or string.find(line, LICENSE_TAG, 1, true) ~= nil
		copyright = copyright or string.find(line, COPYRIGHT_TAG, 1, true) ~= nil
	end
	if not (license and copyright) then
		Report.add(
			report,
			RULES.MISSING_SPDX_HEADER,
			path,
			1,
			string.format(
				"the first %d lines must carry '%s' and '%s<year> <holder>'",
				HEADER_WINDOW,
				LICENSE_TAG,
				COPYRIGHT_TAG
			)
		)
	end
end

-- Roblox Studio ignores .luaurc, so the hot comment is the only strict mode setting that holds everywhere.
local function checkStrictMode(path: string, lines: { string }, report: Report.Report)
	for _, line in lines do
		if line == "--!strict" then
			return
		end
		if line ~= "" and string.sub(line, 1, 2) ~= "--" then
			break
		end
	end
	Report.add(report, RULES.MISSING_STRICT_MODE, path, 1, "declare --!strict among the leading comment lines")
end

local Headers = {}

Headers.RULES = RULES

function Headers.check(snapshot: Snapshot.Snapshot, report: Report.Report)
	for _, path in Snapshot.paths(snapshot) do
		local content = snapshot.files[path]
		if Hygiene.isBinary(path, content) then
			continue
		end
		local lines = string.split(Text.normalize(content), "\n")
		if not isExempt(path) then
			checkSpdx(path, lines, report)
		end
		if Hygiene.extension(path) == "luau" then
			checkStrictMode(path, lines, report)
		end
	end
end

return Headers
