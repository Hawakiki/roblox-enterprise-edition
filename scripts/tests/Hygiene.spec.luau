-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Hygiene = require("../lib/Hygiene")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	Hygiene.check(Snapshot.new(files), report)
	return report
end

case("a clean file passes", function()
	Assert.codes(check({ ["a.md"] = "# Title\n\nText.\n" }), {})
end)

case("an empty file passes", function()
	Assert.codes(check({ ["a.md"] = "" }), {})
end)

case("CRLF line endings are reported once per file", function()
	local report = check({ ["a.md"] = "one\r\ntwo\r\nthree\r\n" })
	Assert.codes(report, { "CRLF_LINE_ENDING" })
	Assert.equal(#report.violations, 1, "violations")
end)

case("a byte order mark is reported", function()
	Assert.codes(check({ ["a.md"] = "\u{FEFF}# Title\n" }), { "UTF8_BOM" })
end)

case("PowerShell with non-ASCII text needs a byte order mark", function()
	Assert.codes(check({ ["tools/a.ps1"] = "# 한글\n" }), { "MISSING_UTF8_BOM" })
	Assert.codes(check({ ["tools/a.ps1"] = "\u{FEFF}# 한글\n" }), {})
	Assert.codes(check({ ["tools/a.ps1"] = "# ascii\n" }), {})
end)

case("trailing spaces and tabs are reported per line", function()
	local report = check({ ["a.md"] = "one \ntwo\t\nthree\n" })
	Assert.codes(report, { "TRAILING_WHITESPACE" })
	Assert.equal(#report.violations, 2, "violations")
end)

case("a missing final newline is reported", function()
	Assert.codes(check({ ["a.md"] = "no newline" }), { "MISSING_FINAL_NEWLINE" })
end)

case("invalid UTF-8 is reported", function()
	Assert.codes(check({ ["a.md"] = "\xFF\xFE broken\n" }), { "INVALID_UTF8" })
end)

case("binary files are skipped", function()
	local report = check({ ["icon.png"] = "\x89PNG\r\n\x1A\n\0\0", ["blob.dat"] = "a\0b" })
	Assert.codes(report, {})
	Assert.equal(report.checked, 0, "checked files")
end)

return { name = "Hygiene", cases = cases } :: Assert.Suite
