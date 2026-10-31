-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local ReleaseNotes = require("../lib/ReleaseNotes")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local RECORD = "---\nid: CR-0042\ntitle: Do the Thing\nversion: 1.1.0\n---\n\n# Do the Thing\n\n## 1. Summary\n\n"
	.. "The thing is done.\nCompletely.\n\n## 2. Background\n\nNot in the notes.\n"
local RECORD_KO = "---\nid: CR-0042\ntitle: 그것을 하기\ntranslation-of: 1.1.0\n---\n\n# 그것을 하기\n"

case("cited change requests come from trailers, each once, in order", function()
	local cited = ReleaseNotes.cited({
		"feat(x): b\n\nChange-Request: CR-0012\n",
		"feat(x): a\n\nSigned-off-by: A <a@b>\nChange-Request: CR-0011\n",
		"Merge branch 'feature/CR-0012-x' into develop\n\nChange-Request: CR-0012\nApproved-by: A <a@b>\n",
		"docs(x): mentions CR-0099 in prose only\n\nChange-Request: CR-0011\n",
	})
	Assert.equal(#cited, 2, "count")
	Assert.equal(cited[1], "CR-0011", "first")
	Assert.equal(cited[2], "CR-0012", "second")
end)

case("a request that an earlier release cites is left out, though a merge back into develop cites it again", function()
	local cited = ReleaseNotes.newlyCited({
		"Merge branch 'release/1.0.0' into develop\n\nChange-Request: CR-0014\nApproved-by: A <a@b>\n",
		"feat(x): a\n\nChange-Request: CR-0015\n",
	}, {
		"feat(x): b\n\nChange-Request: CR-0013\n",
		"docs(x): c\n\nChange-Request: CR-0014\n",
	})
	Assert.equal(#cited, 1, "count")
	Assert.equal(cited[1], "CR-0015", "the new request")
	Assert.equal(#ReleaseNotes.newlyCited({ "feat(x): a\n\nChange-Request: CR-0001\n" }, {}), 1, "the first release")
end)

case("a record gives its titles and the first section only", function()
	local request = ReleaseNotes.describe({
		["docs/records/change-requests/CR-0042-do-the-thing.md"] = RECORD,
		["docs/records/change-requests/CR-0042-do-the-thing.ko.md"] = RECORD_KO,
		["docs/records/change-requests/CR-0420-other.md"] = "---\ntitle: Other\n---\n",
	}, "CR-0042")
	assert(request, "the record is found")
	Assert.equal(request.title, "Do the Thing", "title")
	Assert.equal(request.titleKo, "그것을 하기", "Korean title")
	Assert.equal(request.summary, "The thing is done.\nCompletely.", "summary")
end)

case("a change request without a record is reported as missing", function()
	Assert.equal(ReleaseNotes.describe({}, "CR-0042"), nil, "missing")
end)

case("the notes name the release and the one before it", function()
	local request: ReleaseNotes.ChangeRequest =
		{ id = "CR-0042", title = "Do the Thing", titleKo = "그것을 하기", summary = "Done." }
	local notes = ReleaseNotes.render("v1.1.0", "v1.0.0", { request })
	Assert.contains(notes, "## EnterpriseEdition v1.1.0", "heading")
	Assert.contains(notes, "since v1.0.0", "previous release")
	Assert.contains(notes, "### CR-0042: Do the Thing\n\n그것을 하기\n\nDone.", "request")
	Assert.contains(ReleaseNotes.render("v1.0.0", nil, {}), "since the founding of the Company", "first release")
end)

return { name = "ReleaseNotes", cases = cases } :: Assert.Suite
