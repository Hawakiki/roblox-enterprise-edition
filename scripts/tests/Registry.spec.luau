-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Documents = require("../lib/Documents")
local Fixtures = require("./Fixtures")
local Registry = require("../lib/Registry")
local Report = require("../lib/Report")
local Schema = require("../lib/Schema")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local function index(files: { [string]: string }): Documents.Index
	return Documents.check(Snapshot.new(files), Report.new())
end

case("the registry lists every document in both languages", function()
	local english, korean = Registry.render(index(Fixtures.repository()))
	Assert.contains(
		english,
		"| [EE-POL-0001](01-governance/EE-POL-0001-documents.md) | Documents | 1.0.0 | Approved | Internal | Document Control Office | EE-CHR-0001@1.0 |",
		"English policy row"
	)
	Assert.contains(
		english,
		"| [CR-0001](records/change-requests/CR-0001-first-request.md) | First Request | 1.0.0 | Approved | Internal | Compliance Engineering |",
		"English record row"
	)
	Assert.contains(english, "| **Total** | **3** |", "English total")
	Assert.contains(
		korean,
		"| [EE-POL-0001](01-governance/EE-POL-0001-documents.ko.md) | 문서 | 1.0.0 | 승인 | 사내 한정 | Document Control Office | EE-CHR-0001@1.0 |",
		"Korean policy row"
	)
	Assert.contains(korean, "| **합계** | **3** |", "Korean total")
end)

case("rendering is deterministic", function()
	local firstEnglish, firstKorean = Registry.render(index(Fixtures.repository()))
	local secondEnglish, secondKorean = Registry.render(index(Fixtures.repository()))
	Assert.equal(firstEnglish == secondEnglish and firstKorean == secondKorean, true, "identical output")
end)

case("pipes in titles are escaped", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.REQUEST, "title: First Request", 'title: "First | Request"')
	Fixtures.replace(files, Fixtures.REQUEST, "# First Request", "# First | Request")
	local english = Registry.render(index(files))
	Assert.contains(english, "| First \\| Request |", "escaped title")
end)

case("an up-to-date registry passes", function()
	local files = Fixtures.repository()
	local english, korean = Registry.render(index(files))
	files["docs/REGISTRY.md"] = english
	files["docs/REGISTRY.ko.md"] = korean
	local report = Report.new()
	Registry.check(Snapshot.new(files), index(files), report)
	Assert.codes(report, {})
end)

case("a missing or edited registry is reported", function()
	local files = Fixtures.repository()
	local english = Registry.render(index(files))
	files["docs/REGISTRY.md"] = english .. "Edited by hand.\n"
	local report = Report.new()
	Registry.check(Snapshot.new(files), index(files), report)
	Assert.codes(report, { "REGISTRY_OUT_OF_DATE" })
	Assert.equal(#report.violations, 2, "violations")
end)

case("every status of every kind has a Korean label", function()
	for _, kind in Schema.kinds do
		for _, status in kind.statuses do
			if Registry.STATUS_KO[status] == nil then
				error(string.format("status '%s' of %s has no Korean label", status, kind.code), 0)
			end
		end
	end
end)

return { name = "Registry", cases = cases } :: Assert.Suite
