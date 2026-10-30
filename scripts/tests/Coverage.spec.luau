-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Catalog = require("../lib/Catalog")
local Coverage = require("../lib/Coverage")
local Documents = require("../lib/Documents")
local Fixtures = require("./Fixtures")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local STANDARD = "docs/03-standards/EE-STD-0009-writing.md"

local function codesOf(standard: string, except: string?): { string }
	local codes = {}
	for _, rule in Catalog.rules do
		if rule.standard == standard and rule.code ~= except then
			table.insert(codes, rule.code)
		end
	end
	assert(#codes > 0, "no rules for " .. standard)
	return codes
end

local function annex(codes: { string }): string
	return "\n## Annex A. Enforcement\n\n" .. table.concat(codes, "\n") .. "\n"
end

-- The fixture policy is EE-POL-0001; append an enforcement annex to both of its versions.
local function repository(english: { string }, korean: { string }): { [string]: string }
	local files = Fixtures.repository()
	files[Fixtures.POLICY] ..= annex(english)
	files[Fixtures.POLICY_KO] ..= annex(korean)
	return files
end

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	Coverage.check(Documents.check(Snapshot.new(files), Report.new()), report)
	return report
end

case("a document citing every rule it mandates passes", function()
	local codes = codesOf("EE-POL-0001")
	Assert.codes(check(repository(codes, codes)), {})
end)

case("an uncited rule is reported", function()
	local report = check(repository(codesOf("EE-POL-0001", "STALE_PARENT"), codesOf("EE-POL-0001")))
	Assert.codes(report, { "UNDOCUMENTED_RULE" })
	Assert.equal(#report.violations, 1, "violations")
	Assert.equal(report.violations[1].path, Fixtures.POLICY, "path")
end)

case("the translation must cite every rule too", function()
	local codes = codesOf("EE-POL-0001")
	local report = check(repository(codes, {}))
	Assert.equal(#report.violations, #codes, "violations")
	Assert.equal(report.violations[1].path, Fixtures.POLICY_KO, "path")
end)

case("a longer code does not cite a shorter one", function()
	local codes = codesOf("EE-POL-0001")
	local files = repository(codes, codes)
	Fixtures.add(files, STANDARD, "EE-STD-0009", "Writing", { "parent: EE-POL-0001@1.0" })
	-- MISSING_UTF8_BOM is cited; UTF8_BOM, which it contains, is not.
	local hygiene = codesOf("EE-STD-0009", "UTF8_BOM")
	files[STANDARD] ..= annex(hygiene)
	files[string.sub(STANDARD, 1, -4) .. ".ko.md"] ..= annex(codesOf("EE-STD-0009"))
	local report = check(files)
	Assert.equal(#report.violations, 1, "violations")
	Assert.equal(report.violations[1].path, STANDARD, "path")
	Assert.contains(report.violations[1].message, "UTF8_BOM is enforced", "message")
end)

case("rules of documents that do not exist yet are not checked", function()
	local files = Fixtures.repository()
	files[Fixtures.POLICY] = nil
	files[Fixtures.POLICY_KO] = nil
	Assert.codes(check(files), {})
end)

return { name = "Coverage", cases = cases } :: Assert.Suite
