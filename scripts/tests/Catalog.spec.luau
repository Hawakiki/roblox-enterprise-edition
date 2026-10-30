-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Holds the catalogue to the repository it lives in: every declared rule is reported by its check, and every
	Annex A states the severity that checkpatch enforces (CR-0009).
	규칙 목록을 그것이 있는 저장소에 대조한다. 선언된 모든 규칙은 그 검사가 보고하고, 모든 부속서 A 는
	checkpatch 가 강제하는 심각도를 밝힌다(CR-0009).
]]

local Assert = require("./Assert")
local Catalog = require("../lib/Catalog")
local Git = require("../lib/Git")
local Rule = require("../lib/Rule")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local root = assert(Git.root(), "the tests run inside the repository")
local repository = Snapshot.fromRepository(root)

-- The words an Annex A uses for a severity, in either language.
local SEVERITIES: { [string]: Rule.Severity } = {
	Error = "ERROR",
	Warning = "WARNING",
	["오류"] = "ERROR",
	["경고"] = "WARNING",
}

case("every rule a check declares is reported by that check", function()
	for _, rule in Catalog.rules do
		local path = "scripts/lib/" .. Catalog.checkOf(rule.code) .. ".luau"
		local source = assert(repository.files[path], "no source for " .. path)
		local reported = string.find(source, "RULES%." .. rule.code .. "%f[^%w_]") ~= nil
		Assert.equal(reported, true, string.format("%s declares %s but never reports it", path, rule.code))
	end
end)

case("every Annex A states the severity that checkpatch enforces", function()
	local compared = 0
	for _, path in Snapshot.paths(repository) do
		if string.sub(path, 1, 5) ~= "docs/" or string.sub(path, -3) ~= ".md" then
			continue
		end
		local annex = false
		for line in string.gmatch(repository.files[path], "[^\n]+") do
			if string.sub(line, 1, 3) == "## " then
				annex = string.find(line, "^## Annex A") ~= nil or string.find(line, "^## 부속서 A") ~= nil
			elseif annex then
				local code, word = string.match(line, "^| `([%u%d_]+)` | ([^|]-) |")
				local severity = if word then SEVERITIES[word] else nil
				if code and severity then
					Assert.equal(severity, Catalog.get(code).severity, path .. ": " .. code)
					compared += 1
				end
			end
		end
	end
	Assert.equal(compared >= #Catalog.rules, true, "Annex A rows compared")
end)

return { name = "Catalog", cases = cases } :: Assert.Suite
