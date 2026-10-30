-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Documents = require("../lib/Documents")
local Fixtures = require("./Fixtures")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	Documents.check(Snapshot.new(files), report)
	return report
end

local STANDARD = "docs/03-standards/EE-STD-0001-standard.md"
local SECOND_POLICY = "docs/01-governance/EE-POL-0002-second.md"

case("a compliant tree passes", function()
	Assert.codes(check(Fixtures.repository()), {})
end)

case("documents are indexed in registry order", function()
	local index = Documents.check(Snapshot.new(Fixtures.repository()), Report.new())
	local ids = {}
	for _, document in index.documents do
		table.insert(ids, document.id)
	end
	Assert.equal(table.concat(ids, ","), "EE-CHR-0001,EE-POL-0001,CR-0001", "order")
end)

-- Translations / 번역

case("a missing translation is reported", function()
	local files = Fixtures.repository()
	files[Fixtures.POLICY_KO] = nil
	Assert.codes(check(files), { "MISSING_TRANSLATION" })
end)

case("an orphan translation is reported", function()
	local files = Fixtures.repository()
	files[Fixtures.POLICY] = nil
	Assert.codes(check(files), { "ORPHAN_TRANSLATION" })
end)

case("a translation behind its English version is stale", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "version: 1.0.0", "version: 1.1.0")
	Assert.codes(check(files), { "STALE_TRANSLATION" })
end)

case("a translation may not carry metadata", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY_KO, "translation-of: 1.0.0", "translation-of: 1.0.0\nstatus: Approved")
	Assert.codes(check(files), { "TRANSLATION_EXTRA_FIELD" })
end)

case("a translation must carry the id of its English document", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY_KO, "id: EE-POL-0001", "id: EE-POL-0002")
	Assert.codes(check(files), { "TRANSLATION_ID_MISMATCH" })
end)

case("a translation with only a Korean title is not Korean", function()
	local files = Fixtures.repository()
	Fixtures.replace(
		files,
		Fixtures.POLICY_KO,
		"EE-CHR-0001 에 근거하며 CR-0001 로 변경한다.",
		"Not translated yet."
	)
	Assert.codes(check(files), { "TRANSLATION_NOT_KOREAN" })
end)

-- Frontmatter / frontmatter

case("a document without frontmatter is reported", function()
	local files = Fixtures.repository()
	files[Fixtures.POLICY] = "# Documents\n"
	Assert.codes(check(files), { "MISSING_FRONTMATTER" })
end)

case("an unclosed frontmatter block is reported", function()
	local files = Fixtures.repository()
	files[Fixtures.POLICY] = "---\nid: EE-POL-0001\n\n# Documents\n"
	Assert.codes(check(files), { "INVALID_FRONTMATTER" })
end)

case("invalid YAML is reported", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "title: Documents", "title: [Documents")
	Assert.codes(check(files), { "INVALID_FRONTMATTER" })
end)

case("CRLF line endings and a byte order mark do not break parsing", function()
	local files = Fixtures.repository()
	files[Fixtures.POLICY] = "\u{FEFF}" .. string.gsub(files[Fixtures.POLICY], "\n", "\r\n")
	Assert.codes(check(files), {})
end)

case("a missing field is reported", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "\nowner: Document Control Office", "")
	Assert.codes(check(files), { "MISSING_FIELD" })
end)

case("an unknown field is reported", function()
	local files = Fixtures.repository()
	Fixtures.replace(
		files,
		Fixtures.POLICY,
		"owner: Document Control Office",
		"owner: Document Control Office\nmood: optimistic"
	)
	Assert.codes(check(files), { "UNKNOWN_FIELD" })
end)

case("a version YAML reads as a number is rejected", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "version: 1.0.0", "version: 1.0")
	Assert.codes(check(files), { "INVALID_FIELD_VALUE" })
end)

case("an unknown status is rejected", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "status: Approved", "status: Done")
	Assert.codes(check(files), { "INVALID_FIELD_VALUE" })
end)

case("an unknown classification is rejected", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "classification: Internal", "classification: Top Secret")
	Assert.codes(check(files), { "INVALID_FIELD_VALUE" })
end)

case("a draft cannot carry a released version", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "status: Approved", "status: Draft")
	Assert.codes(check(files), { "VERSION_STATUS_MISMATCH" })
end)

case("an approved document cannot carry a draft version", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "version: 1.0.0", "version: 0.9.0")
	Fixtures.replace(files, Fixtures.POLICY_KO, "translation-of: 1.0.0", "translation-of: 0.9.0")
	Assert.codes(check(files), { "VERSION_STATUS_MISMATCH" })
end)

-- Identity and location / 식별자와 위치

case("an unregistered document kind is reported", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "id: EE-POL-0001", "id: EE-XYZ-0001")
	Assert.codes(check(files), { "UNKNOWN_DOCUMENT_TYPE" })
end)

case("a document in the wrong folder is reported", function()
	local files = Fixtures.repository()
	Fixtures.move(files, Fixtures.POLICY, "docs/03-standards/EE-POL-0001-documents.md")
	Fixtures.move(files, Fixtures.POLICY_KO, "docs/03-standards/EE-POL-0001-documents.ko.md")
	Assert.codes(check(files), { "MISPLACED_DOCUMENT" })
end)

case("a file name without a proper slug is reported", function()
	local files = Fixtures.repository()
	Fixtures.move(files, Fixtures.POLICY, "docs/01-governance/EE-POL-0001_Documents.md")
	Fixtures.move(files, Fixtures.POLICY_KO, "docs/01-governance/EE-POL-0001_Documents.ko.md")
	Assert.codes(check(files), { "FILENAME_MISMATCH" })
end)

case("a heading that differs from the title is reported", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "# Documents", "# Document Policy")
	Assert.codes(check(files), { "TITLE_HEADING_MISMATCH" })
end)

case("a duplicate id is reported", function()
	local files = Fixtures.repository()
	files["docs/01-governance/EE-POL-0001-copy.md"] = files[Fixtures.POLICY]
	files["docs/01-governance/EE-POL-0001-copy.ko.md"] = files[Fixtures.POLICY_KO]
	Assert.codes(check(files), { "DUPLICATE_DOCUMENT_ID" })
end)

case("a stray file is reported", function()
	local files = Fixtures.repository()
	files["docs/notes.txt"] = "notes\n"
	Assert.codes(check(files), { "STRAY_FILE" })
end)

case("the generated registry is not a document", function()
	local files = Fixtures.repository()
	files["docs/REGISTRY.md"] = "# Document Registry\n"
	files["docs/REGISTRY.ko.md"] = "# 문서 대장\n"
	Assert.codes(check(files), {})
end)

-- Hierarchy / 위계

case("a controlled document without a parent is reported", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "\nparent: EE-CHR-0001@1.0", "")
	Assert.codes(check(files), { "MISSING_PARENT" })
end)

case("the charter takes no parent", function()
	local files = Fixtures.repository()
	Fixtures.replace(
		files,
		Fixtures.CHARTER,
		"owner: Board of Directors",
		"owner: Board of Directors\nparent: EE-POL-0001@1.0"
	)
	Assert.codes(check(files), { "UNEXPECTED_PARENT" })
end)

case("records take no parent", function()
	local files = Fixtures.repository()
	Fixtures.replace(
		files,
		Fixtures.REQUEST,
		"owner: Compliance Engineering",
		"owner: Compliance Engineering\nparent: EE-CHR-0001@1.0"
	)
	Assert.codes(check(files), { "UNEXPECTED_PARENT" })
end)

case("a parent citation needs a revision", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "parent: EE-CHR-0001@1.0", "parent: EE-CHR-0001")
	Assert.codes(check(files), { "INVALID_FIELD_VALUE" })
end)

case("an unknown parent is reported", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "parent: EE-CHR-0001@1.0", "parent: EE-CHR-0002@1.0")
	Assert.codes(check(files), { "UNKNOWN_PARENT" })
end)

case("a parent may not sit below its child", function()
	local files = Fixtures.repository()
	Fixtures.add(files, STANDARD, "EE-STD-0001", "Standard", { "parent: EE-CHR-0001@1.0" })
	Fixtures.replace(files, Fixtures.POLICY, "parent: EE-CHR-0001@1.0", "parent: EE-STD-0001@1.0")
	Assert.codes(check(files), { "PARENT_HIERARCHY_VIOLATION" })
end)

case("a record cannot be a parent", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "parent: EE-CHR-0001@1.0", "parent: CR-0001@1.0")
	Assert.codes(check(files), { "PARENT_HIERARCHY_VIOLATION" })
end)

case("a parent revised in MAJOR.MINOR makes its children stale", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.CHARTER, "version: 1.0.0", "version: 1.1.0")
	Fixtures.replace(files, Fixtures.CHARTER_KO, "translation-of: 1.0.0", "translation-of: 1.1.0")
	Assert.codes(check(files), { "STALE_PARENT" })
end)

case("an editorial PATCH revision leaves children valid", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.CHARTER, "version: 1.0.0", "version: 1.0.1")
	Fixtures.replace(files, Fixtures.CHARTER_KO, "translation-of: 1.0.0", "translation-of: 1.0.1")
	Assert.codes(check(files), {})
end)

case("a parent cycle is reported", function()
	local files = Fixtures.repository()
	Fixtures.add(files, SECOND_POLICY, "EE-POL-0002", "Second", { "parent: EE-POL-0001@1.0" })
	Fixtures.replace(files, Fixtures.POLICY, "parent: EE-CHR-0001@1.0", "parent: EE-POL-0002@1.0")
	Assert.codes(check(files), { "PARENT_CYCLE" })
end)

-- References / 참조

case("a reference to a missing document is reported", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "changed through CR-0001", "changed through CR-0042")
	Assert.codes(check(files), { "DANGLING_REFERENCE" })
end)

case("references are checked in translations too", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY_KO, "EE-CHR-0001 에", "EE-STD-0042 에")
	Assert.codes(check(files), { "DANGLING_REFERENCE" })
end)

case("identifiers of unregistered kinds are not references", function()
	local files = Fixtures.repository()
	Fixtures.replace(files, Fixtures.POLICY, "Governed by", "Unlike EE-XYZ-0001 and ABC-0001, governed by")
	Assert.codes(check(files), {})
end)

-- Record kinds / 기록 종류

case("approval requests, statements and minutes are records", function()
	local files = Fixtures.repository()
	local statement = "docs/records/statements/STM-0001-late-report.md"
	Fixtures.add(files, "docs/records/approval-requests/APR-0001-meeting-room.md", "APR-0001", "Meeting Room")
	Fixtures.add(files, statement, "STM-0001", "Late Report")
	Fixtures.replace(files, statement, "status: Approved", "status: Accepted")
	Fixtures.add(files, "docs/records/minutes/MIN-0001-kickoff.md", "MIN-0001", "Kickoff")
	local index = Documents.check(Snapshot.new(files), Report.new())
	Assert.codes(check(files), {})
	Assert.equal(index.byId["STM-0001"].kind.controlled, false, "statement is a record")
end)

case("each record kind keeps its own statuses", function()
	local files = Fixtures.repository()
	local minutes = "docs/records/minutes/MIN-0001-kickoff.md"
	Fixtures.add(files, minutes, "MIN-0001", "Kickoff")
	Fixtures.replace(files, minutes, "status: Approved", "status: Implemented")
	Assert.codes(check(files), { "INVALID_FIELD_VALUE" })
end)

return { name = "Documents", cases = cases } :: Assert.Suite
