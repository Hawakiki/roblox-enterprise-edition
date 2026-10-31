-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The notes of a release (EE-STD-0008 §5): every change request that a commit of the release cites and no earlier
	release does, with its title in both languages and the summary of its English version. Generated from the
	records, never written.
	릴리스 노트(EE-STD-0008 §5): 릴리스의 커밋이 인용하고 이전 릴리스는 인용하지 않는 모든 변경 요청을, 두 언어의
	제목과 영문판의 요약과 함께 싣는다. 기록에서 만들어지며, 손으로 쓰지 않는다.
]]

local RECORDS = "docs/records/change-requests/"

export type ChangeRequest = {
	id: string,
	title: string,
	titleKo: string?,
	summary: string,
}

local ReleaseNotes = {}

-- The change requests that commit messages cite in their trailers, in order of number, each once.
function ReleaseNotes.cited(messages: { string }): { string }
	local seen: { [string]: boolean } = {}
	local ids = {}
	for _, message in messages do
		for line in string.gmatch(message, "[^\n]+") do
			-- Keys are matched without regard to case (EE-STD-0007 §6.1, CR-0018).
			local key: string?, id: string? = string.match(line, "^([%w%-]+):%s*(CR%-%d+)%s*$")
			if key and string.lower(key) == "change-request" and id and not seen[id] then
				seen[id] = true
				table.insert(ids, id)
			end
		end
	end
	table.sort(ids)
	return ids
end

-- The change requests that the messages of a release cite and the messages of the earlier releases do not. A
-- request belongs to the first release that cites it: the merge of a release back into develop cites its request
-- again, after its tag, where the next release would find it (CR-0017).
function ReleaseNotes.newlyCited(messages: { string }, earlier: { string }): { string }
	local released: { [string]: boolean } = {}
	for _, id in ReleaseNotes.cited(earlier) do
		released[id] = true
	end
	local ids = {}
	for _, id in ReleaseNotes.cited(messages) do
		if not released[id] then
			table.insert(ids, id)
		end
	end
	return ids
end

local function titleOf(content: string): string?
	local title: string? = string.match(content, "\ntitle: ([^\n]+)")
	return title
end

-- The paragraphs under the first section of a record, which the form calls the summary.
local function summaryOf(content: string): string
	local lines = {}
	local inside = false
	for line in string.gmatch(content .. "\n", "([^\n]*)\n") do
		if string.sub(line, 1, 3) == "## " then
			if inside then
				break
			end
			inside = string.match(line, "^## 1%. ") ~= nil
		elseif inside then
			table.insert(lines, line)
		end
	end
	local text = table.concat(lines, "\n")
	return (string.gsub(string.gsub(text, "^%s+", ""), "%s+$", ""))
end

-- Reads a change request from the files of the repository, or nil when it has no record.
function ReleaseNotes.describe(files: { [string]: string }, id: string): ChangeRequest?
	local prefix = RECORDS .. id .. "-"
	for path, content in files do
		if string.sub(path, 1, #prefix) == prefix and string.sub(path, -6) ~= ".ko.md" then
			local korean = files[string.sub(path, 1, -4) .. ".ko.md"]
			return {
				id = id,
				title = titleOf(content) or id,
				titleKo = if korean then titleOf(korean) else nil,
				summary = summaryOf(content),
			}
		end
	end
	return nil
end

-- The notes, in Markdown.
function ReleaseNotes.render(tag: string, previous: string?, requests: { ChangeRequest }): string
	local out = {
		string.format("## EnterpriseEdition %s", tag),
		"",
		if previous
			then string.format(
				"The change requests released since %s. / %s 이후 릴리스된 변경 요청.",
				previous,
				previous
			)
			else "The change requests released since the founding of the Company. / 회사 창립 이후 릴리스된 변경 요청.",
	}
	for _, request in requests do
		table.insert(out, "")
		table.insert(out, string.format("### %s: %s", request.id, request.title))
		if request.titleKo then
			table.insert(out, "")
			table.insert(out, request.titleKo)
		end
		table.insert(out, "")
		table.insert(out, request.summary)
	end
	return table.concat(out, "\n") .. "\n"
end

return ReleaseNotes
