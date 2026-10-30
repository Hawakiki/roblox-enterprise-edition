-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Documents = require("../lib/Documents")
local Fixtures = require("./Fixtures")
local Forms = require("../lib/Forms")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local TEMPLATE = "docs/templates/EE-TPL-0002-change-request.md"
local TEMPLATE_KO = "docs/templates/EE-TPL-0002-change-request.ko.md"

local FORM_EN = table.concat({
	"# Change Request Template",
	"",
	"## 1. Usage",
	"",
	"Copy the form.",
	"",
	"## 2. Form",
	"",
	"````markdown",
	"# <Title>",
	"",
	"## 1. Summary",
	"",
	"## 2. <A placeholder heading>",
	"",
	"### 2.1 Not a level-two section",
	"",
	"## 3. Rollback Plan",
	"````",
	"",
	"## Revision History",
	"",
}, "\n")

local FORM_KO = table.concat({
	"# 변경 요청서 양식",
	"",
	"## 1. 사용법",
	"",
	"양식을 복사한다.",
	"",
	"## 2. 양식",
	"",
	"````markdown",
	"## 1. 요약",
	"",
	"## 2. 원복 계획",
	"````",
	"",
}, "\n")

local function request(english: string, korean: string): { [string]: string }
	local files = Fixtures.repository()
	files[TEMPLATE] = Fixtures.document({
		"id: EE-TPL-0002",
		"title: Change Request Template",
		"version: 1.0.0",
		"status: Approved",
		"classification: Internal",
		"owner: Document Control Office",
		"parent: EE-POL-0001@1.0",
	}, FORM_EN)
	files[TEMPLATE_KO] =
		Fixtures.document({ "id: EE-TPL-0002", "title: 변경 요청서 양식", "translation-of: 1.0.0" }, FORM_KO)
	files[Fixtures.REQUEST] = Fixtures.document({
		"id: CR-0001",
		"title: First Request",
		"version: 1.0.0",
		"status: Approved",
		"classification: Internal",
		"owner: Compliance Engineering",
	}, "# First Request\n\n" .. english)
	files[Fixtures.REQUEST_KO] =
		Fixtures.document({ "id: CR-0001", "title: 첫 요청", "translation-of: 1.0.0" }, "# 첫 요청\n\n" .. korean)
	return files
end

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	Forms.check(Documents.check(Snapshot.new(files), Report.new()), report)
	return report
end

local COMPLETE_EN = "## 1. Summary\n\nWhat.\n\n## 2. Rollback Plan\n\nHow.\n"
local COMPLETE_KO = "## 1. 요약\n\n무엇.\n\n## 2. 원복 계획\n\n방법.\n"

case("a record with every section of its form passes, placeholders aside", function()
	Assert.codes(check(request(COMPLETE_EN, COMPLETE_KO)), {})
end)

case("a missing section is reported in either language", function()
	local report = check(request("## 1. Summary\n\nWhat.\n", COMPLETE_KO))
	Assert.codes(report, { "TEMPLATE_SECTION_MISSING" })
	Assert.equal(report.violations[1].path, Fixtures.REQUEST, "path")
	report = check(request(COMPLETE_EN, "## 1. 요약\n\n무엇.\n"))
	Assert.codes(report, { "TEMPLATE_SECTION_MISSING" })
	Assert.equal(report.violations[1].path, Fixtures.REQUEST_KO, "path")
end)

case("sections may be renumbered, reordered and added to", function()
	local english = "## Rollback Plan\n\nHow.\n\n## 7. Summary\n\nWhat.\n\n## 8. Root Cause\n\nWhy.\n"
	Assert.codes(check(request(english, COMPLETE_KO)), {})
end)

case("a heading inside a code block is not a section", function()
	local english = "## 1. Summary\n\nWhat.\n\n```text\n## 2. Rollback Plan\n```\n"
	Assert.codes(check(request(english, COMPLETE_KO)), { "TEMPLATE_SECTION_MISSING" })
end)

case("records whose form is not written yet are not checked", function()
	local files = request("Nothing.\n", "없음.\n")
	files[TEMPLATE] = nil
	files[TEMPLATE_KO] = nil
	Assert.codes(check(files), {})
end)

return { name = "Forms", cases = cases } :: Assert.Suite
