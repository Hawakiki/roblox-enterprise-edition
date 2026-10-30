-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local CommitMessage = require("../lib/CommitMessage")
local Documents = require("../lib/Documents")
local Fixtures = require("./Fixtures")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local AUTHOR = "Jane Doe <jane@enterprise-edition.example>"

local VALID = table.concat({
	"feat(output): deliver the value",
	"",
	"[EN]",
	"Deliver the value through the approved channel.",
	"",
	"[KO]",
	"승인된 경로로 값을 전달한다.",
	"",
	"Signed-off-by: " .. AUTHOR,
	"Change-Request: CR-0001",
	"",
}, "\n")

local MERGE = table.concat({
	"Merge branch 'feature/CR-0001-output' into develop",
	"",
	"[EN]",
	"Deliver the value.",
	"",
	"[KO]",
	"값을 전달한다.",
	"",
	"Signed-off-by: " .. AUTHOR,
	"Change-Request: CR-0001",
	"Approved-by: " .. AUTHOR,
	"",
}, "\n")

local function documents(): Documents.Index
	local files = Fixtures.repository()
	Fixtures.add(files, "docs/records/change-requests/CR-0002-closed.md", "CR-0002", "Closed")
	Fixtures.replace(files, "docs/records/change-requests/CR-0002-closed.md", "status: Approved", "status: Closed")
	Fixtures.add(files, "docs/records/change-requests/CR-0003-draft.md", "CR-0003", "Draft")
	Fixtures.replace(files, "docs/records/change-requests/CR-0003-draft.md", "status: Approved", "status: Draft")
	local report = Report.new()
	local index = Documents.check(Snapshot.new(files), report)
	Assert.codes(report, {})
	return index
end

local INDEX = documents()

type Options = {
	author: string?,
	branch: string?,
	isMerge: boolean?,
}

local function check(message: string, options: Options?): Report.Report
	local report = Report.new()
	local given: Options = options or {}
	CommitMessage.check(message, {
		label = "COMMIT_EDITMSG",
		author = given.author or AUTHOR,
		branch = given.branch,
		isMerge = given.isMerge == true,
		documents = INDEX,
	}, report)
	return report
end

local function edit(message: string, old: string, new: string): string
	local first, last = string.find(message, old, 1, true)
	if first == nil or last == nil then
		error(string.format("%q not found in message", old), 2)
	end
	return string.sub(message, 1, first - 1) .. new .. string.sub(message, last + 1)
end

local function withSubject(subject: string): string
	return edit(VALID, "feat(output): deliver the value", subject)
end

case("a compliant message passes", function()
	Assert.codes(check(VALID), {})
	Assert.codes(check(VALID, { branch = "feature/CR-0001-output" }), {})
end)

case("comments and everything below the scissors line are ignored", function()
	local message = VALID
		.. "# Please enter the commit message for your changes.\n"
		.. "# ------------------------ >8 ------------------------\n"
		.. "diff --git a/x b/x\n"
	Assert.codes(check(message), {})
end)

case("an empty message is rejected", function()
	Assert.codes(check("# only a comment\n"), { "COMMIT_SUBJECT_FORMAT" })
end)

-- Subject / 제목

case("a subject without type and scope is rejected", function()
	Assert.codes(check(withSubject("deliver the value")), { "COMMIT_SUBJECT_FORMAT" })
	Assert.codes(check(withSubject("feat: deliver the value")), { "COMMIT_SUBJECT_FORMAT" })
	Assert.codes(check(withSubject("feat(Output): deliver the value")), { "COMMIT_SUBJECT_FORMAT" })
end)

case("an unknown type is rejected", function()
	Assert.codes(check(withSubject("feature(output): deliver the value")), { "COMMIT_SUBJECT_FORMAT" })
end)

case("a subject over 72 columns is rejected", function()
	local subject = "feat(output): " .. string.rep("deliver ", 8) .. "the value"
	Assert.codes(check(withSubject(subject)), { "COMMIT_SUBJECT_TOO_LONG" })
end)

case("a Korean subject is rejected", function()
	Assert.codes(check(withSubject("feat(output): 값을 전달한다")), { "COMMIT_SUBJECT_NOT_ENGLISH" })
end)

case("sentence case and a final period are rejected", function()
	Assert.codes(check(withSubject("feat(output): Deliver the value")), { "COMMIT_SUBJECT_STYLE" })
	Assert.codes(check(withSubject("feat(output): deliver the value.")), { "COMMIT_SUBJECT_STYLE" })
end)

case("acronyms and identifiers may open the description", function()
	Assert.codes(check(withSubject("feat(output): API for the value")), {})
	Assert.codes(check(withSubject("docs(records): CR-0001 approval")), {})
end)

case("a breaking change marker is allowed", function()
	Assert.codes(check(withSubject("feat(output)!: deliver the value")), {})
end)

-- Body / 본문

case("a subject must be followed by a blank line", function()
	local message = edit(VALID, "the value\n\n[EN]", "the value\n[EN]")
	Assert.codes(check(message), { "COMMIT_MISSING_BLANK_LINE", "COMMIT_MISSING_BODY_SECTION" })
end)

case("a message without a body is rejected", function()
	local message = "feat(output): deliver the value\n\nSigned-off-by: " .. AUTHOR .. "\nChange-Request: CR-0001\n"
	Assert.codes(check(message), { "COMMIT_MISSING_BODY_SECTION" })
end)

case("a body without a [KO] section is rejected", function()
	local message = edit(VALID, "[KO]\n승인된 경로로 값을 전달한다.\n\n", "")
	Assert.codes(check(message), { "COMMIT_MISSING_BODY_SECTION" })
end)

case("an empty [EN] section is rejected", function()
	local message = edit(VALID, "Deliver the value through the approved channel.\n\n", "")
	Assert.codes(check(message), { "COMMIT_MISSING_BODY_SECTION" })
end)

case("a [KO] section must be Korean", function()
	local message = edit(VALID, "승인된 경로로 값을 전달한다.", "Deliver the value.")
	Assert.codes(check(message), { "COMMIT_SECTION_LANGUAGE" })
end)

case("long body lines draw a warning, Korean counted double width", function()
	local message = edit(VALID, "승인된 경로로 값을 전달한다.", string.rep("가", 40))
	local report = check(message)
	Assert.codes(report, { "COMMIT_BODY_LINE_TOO_LONG" })
	Assert.equal(Report.count(report, "ERROR"), 0, "errors")
end)

case("long URLs are exempt from the width limit", function()
	local url = "https://jira.enterprise-edition.example/browse/EE-1234?" .. string.rep("x", 60)
	Assert.codes(check(edit(VALID, "approved channel.", "approved channel:\n" .. url)), {})
end)

-- Trailers / trailer

case("a message without trailers is rejected", function()
	local message = edit(VALID, "\nSigned-off-by: " .. AUTHOR .. "\nChange-Request: CR-0001\n", "")
	Assert.codes(check(message), { "COMMIT_MISSING_CHANGE_REQUEST", "COMMIT_MISSING_SIGNOFF" })
end)

case("the author must sign off", function()
	Assert.codes(check(VALID, { author = "John Roe <john@enterprise-edition.example>" }), { "COMMIT_SIGNOFF_MISMATCH" })
end)

case("a sign-off must be a full identity", function()
	local message = edit(VALID, "Signed-off-by: " .. AUTHOR, "Signed-off-by: Jane Doe")
	Assert.codes(check(message), { "COMMIT_MALFORMED_TRAILER", "COMMIT_MISSING_SIGNOFF" })
end)

case("trailer keys are case-insensitive", function()
	Assert.codes(check(edit(VALID, "Signed-off-by:", "signed-off-by:")), {})
end)

case("an unregistered trailer is rejected", function()
	local message = edit(VALID, "Change-Request: CR-0001", "Change-Request: CR-0001\nReported-by: " .. AUTHOR)
	Assert.codes(check(message), { "COMMIT_UNKNOWN_TRAILER" })
end)

case("Jira keys are validated", function()
	Assert.codes(check(edit(VALID, "Change-Request: CR-0001", "Change-Request: CR-0001\nJira: EE-1234")), {})
	Assert.codes(
		check(edit(VALID, "Change-Request: CR-0001", "Change-Request: CR-0001\nJira: someday")),
		{ "COMMIT_MALFORMED_TRAILER" }
	)
end)

-- Change requests / 변경 요청

case("a malformed change request is rejected", function()
	local message = edit(VALID, "Change-Request: CR-0001", "Change-Request: 42")
	Assert.codes(check(message), { "COMMIT_MALFORMED_TRAILER", "COMMIT_MISSING_CHANGE_REQUEST" })
end)

case("an unfiled change request is rejected", function()
	local message = edit(VALID, "Change-Request: CR-0001", "Change-Request: CR-0042")
	Assert.codes(check(message), { "COMMIT_UNKNOWN_CHANGE_REQUEST" })
end)

case("a closed change request accepts no commits", function()
	local message = edit(VALID, "Change-Request: CR-0001", "Change-Request: CR-0002")
	Assert.codes(check(message), { "COMMIT_CHANGE_REQUEST_CLOSED" })
end)

case("an unapproved change request draws a warning", function()
	local message = edit(VALID, "Change-Request: CR-0001", "Change-Request: CR-0003")
	local report = check(message)
	Assert.codes(report, { "COMMIT_CHANGE_REQUEST_NOT_APPROVED" })
	Assert.equal(Report.count(report, "ERROR"), 0, "errors")
end)

-- Branches and merges / 브랜치와 머지

case("a feature branch commit must cite the branch's change request", function()
	Assert.codes(check(VALID, { branch = "feature/CR-0003-output" }), { "BRANCH_CHANGE_REQUEST_MISMATCH" })
end)

case("release and hotfix branches are accepted", function()
	Assert.codes(check(VALID, { branch = "release/2026.10.30-LTS-r1" }), {})
	Assert.codes(check(VALID, { branch = "hotfix/SEV2-output-outage" }), {})
end)

case("branches outside git-flow are rejected", function()
	Assert.codes(check(VALID, { branch = "my-branch" }), { "BRANCH_NAME_FORMAT" })
	Assert.codes(check(VALID, { branch = "feature/output" }), { "BRANCH_NAME_FORMAT" })
end)

case("main and develop accept merge commits only", function()
	Assert.codes(check(VALID, { branch = "develop" }), { "DIRECT_COMMIT_TO_PROTECTED_BRANCH" })
	Assert.codes(check(VALID, { branch = "main" }), { "DIRECT_COMMIT_TO_PROTECTED_BRANCH" })
end)

case("an approved merge passes", function()
	Assert.codes(check(MERGE, { branch = "develop", isMerge = true }), {})
end)

case("a merge without approval is rejected", function()
	local message = edit(MERGE, "Approved-by: " .. AUTHOR .. "\n", "")
	Assert.codes(check(message, { branch = "develop", isMerge = true }), { "COMMIT_MISSING_APPROVAL" })
end)

case("a merge subject must name the merged branch", function()
	local message = edit(MERGE, "Merge branch 'feature/CR-0001-output' into develop", "chore(git): merge output")
	Assert.codes(check(message, { branch = "develop", isMerge = true }), { "COMMIT_SUBJECT_FORMAT" })
end)

return { name = "CommitMessage", cases = cases } :: Assert.Suite
