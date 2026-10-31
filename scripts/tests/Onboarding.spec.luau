-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Documents = require("../lib/Documents")
local Fixtures = require("./Fixtures")
local Onboarding = require("../lib/Onboarding")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local AGENTS = "# AGENTS.md\n\nRead EE-POL-0001 before changing a document. See CR-0001.\n"
local CLAUDE = "<!-- header -->\n\n@AGENTS.md\n\n# Claude Code\n\nNothing else.\n"

local function check(entrance: { [string]: string }): Report.Report
	local files = Fixtures.repository()
	local index = Documents.check(Snapshot.new(files), Report.new())
	for path, content in entrance do
		files[path] = content
	end
	local report = Report.new()
	Onboarding.check(Snapshot.new(files), index, report)
	return report
end

case("an entrance that imports AGENTS.md and cites existing documents passes", function()
	Assert.codes(check({ ["AGENTS.md"] = AGENTS, ["CLAUDE.md"] = CLAUDE }), {})
end)

case("AGENTS.md alone is enough", function()
	Assert.codes(check({ ["AGENTS.md"] = AGENTS }), {})
end)

case("CLAUDE.md that does not import AGENTS.md is reported", function()
	Assert.codes(check({ ["AGENTS.md"] = AGENTS, ["CLAUDE.md"] = "# Claude Code\n\nRead AGENTS.md.\n" }), {
		"MISSING_AGENTS_IMPORT",
	})
end)

case("an import inside code does not count", function()
	Assert.codes(check({ ["CLAUDE.md"] = "Use `@AGENTS.md` here.\n" }), { "MISSING_AGENTS_IMPORT" })
	Assert.codes(check({ ["CLAUDE.md"] = "```\n@AGENTS.md\n```\n" }), { "MISSING_AGENTS_IMPORT" })
end)

case("a missing document cited by an entrance file is reported", function()
	local report = check({ ["AGENTS.md"] = AGENTS .. "Then read EE-STD-0042.\n" })
	Assert.codes(report, { "DANGLING_ENTRY_REFERENCE" })
	Assert.equal(report.violations[1].line, 4, "line")
end)

case("every Markdown file at the root is an entrance file, and nothing deeper is", function()
	Assert.codes(check({ ["README.md"] = "See CR-0042.\n" }), { "DANGLING_ENTRY_REFERENCE" })
	Assert.codes(check({ ["notes/README.md"] = "See CR-0042.\n" }), {})
end)

case("an entrance longer than 200 lines draws a warning", function()
	local long = string.rep("A line.\n", 190)
	local report = check({ ["AGENTS.md"] = long, ["CLAUDE.md"] = "@AGENTS.md\n" .. string.rep("More.\n", 20) })
	Assert.codes(report, { "ONBOARDING_TOO_LONG" })
	Assert.equal(Report.count(report, "ERROR"), 0, "errors")
end)

return { name = "Onboarding", cases = cases } :: Assert.Suite
