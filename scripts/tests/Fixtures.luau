-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	A minimal, fully compliant document tree. Each test starts from a fresh copy and breaks one thing.
	규정을 모두 지킨 최소 문서 트리. 테스트마다 새 사본에서 한 가지만 망가뜨린다.
]]

local Fixtures = {}

Fixtures.CHARTER = "docs/00-charter/EE-CHR-0001-charter.md"
Fixtures.CHARTER_KO = "docs/00-charter/EE-CHR-0001-charter.ko.md"
Fixtures.POLICY = "docs/01-governance/EE-POL-0001-documents.md"
Fixtures.POLICY_KO = "docs/01-governance/EE-POL-0001-documents.ko.md"
Fixtures.REQUEST = "docs/records/change-requests/CR-0001-first-request.md"
Fixtures.REQUEST_KO = "docs/records/change-requests/CR-0001-first-request.ko.md"

function Fixtures.document(fields: { string }, body: string): string
	return "---\n" .. table.concat(fields, "\n") .. "\n---\n\n" .. body
end

function Fixtures.repository(): { [string]: string }
	return {
		[Fixtures.CHARTER] = Fixtures.document({
			"id: EE-CHR-0001",
			"title: Charter",
			"version: 1.0.0",
			"status: Approved",
			"classification: Internal",
			"owner: Board of Directors",
		}, "# Charter\n\nThe charter of the company.\n"),
		[Fixtures.CHARTER_KO] = Fixtures.document({
			"id: EE-CHR-0001",
			"title: 헌장",
			"translation-of: 1.0.0",
		}, "# 헌장\n\n회사의 헌장이다.\n"),
		[Fixtures.POLICY] = Fixtures.document({
			"id: EE-POL-0001",
			"title: Documents",
			"version: 1.0.0",
			"status: Approved",
			"classification: Internal",
			"owner: Document Control Office",
			"parent: EE-CHR-0001@1.0",
		}, "# Documents\n\nGoverned by EE-CHR-0001 and changed through CR-0001.\n"),
		[Fixtures.POLICY_KO] = Fixtures.document({
			"id: EE-POL-0001",
			"title: 문서",
			"translation-of: 1.0.0",
		}, "# 문서\n\nEE-CHR-0001 에 근거하며 CR-0001 로 변경한다.\n"),
		[Fixtures.REQUEST] = Fixtures.document({
			"id: CR-0001",
			"title: First Request",
			"version: 1.0.0",
			"status: Approved",
			"classification: Internal",
			"owner: Compliance Engineering",
		}, "# First Request\n\nThe first request.\n"),
		[Fixtures.REQUEST_KO] = Fixtures.document({
			"id: CR-0001",
			"title: 첫 요청",
			"translation-of: 1.0.0",
		}, "# 첫 요청\n\n첫 번째 요청이다.\n"),
	}
end

-- Adds an approved document and its translation.
function Fixtures.add(files: { [string]: string }, path: string, id: string, title: string, extraFields: { string }?)
	local fields = {
		"id: " .. id,
		"title: " .. title,
		"version: 1.0.0",
		"status: Approved",
		"classification: Internal",
		"owner: Compliance Engineering",
	}
	if extraFields then
		for _, field in extraFields do
			table.insert(fields, field)
		end
	end
	files[path] = Fixtures.document(fields, "# " .. title .. "\n\nAdded for a test.\n")
	files[string.sub(path, 1, -4) .. ".ko.md"] = Fixtures.document(
		{ "id: " .. id, "title: " .. title, "translation-of: 1.0.0" },
		"# " .. title .. "\n\n테스트용으로 추가한 문서이다.\n"
	)
end

-- Replaces the first occurrence of `old` (plain text) in a fixture file.
function Fixtures.replace(files: { [string]: string }, path: string, old: string, new: string)
	local content = files[path]
	assert(content, "no fixture file " .. path)
	local first, last = string.find(content, old, 1, true)
	if first == nil or last == nil then
		error(string.format("fixture text %q not found in %s", old, path), 2)
	end
	files[path] = string.sub(content, 1, first - 1) .. new .. string.sub(content, last + 1)
end

function Fixtures.move(files: { [string]: string }, from: string, to: string)
	files[to] = files[from]
	files[from] = nil
end

return Fixtures
