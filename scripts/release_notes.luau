-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Prints the notes of a release, generated from the change requests that its commits cite and no earlier release
	does (EE-STD-0008 §5): lune run scripts/release_notes <tag>
	릴리스의 커밋이 인용하고 이전 릴리스는 인용하지 않는 변경 요청에서 릴리스 노트를 만들어 출력한다
	(EE-STD-0008 §5): lune run scripts/release_notes <태그>
]]

local process = require("@lune/process")
local stdio = require("@lune/stdio")

local Git = require("./lib/Git")
local ReleaseNotes = require("./lib/ReleaseNotes")
local Snapshot = require("./lib/Snapshot")

-- The messages of the commits in a range, or nil when it cannot be resolved.
local function messagesOf(repository: string, range: string): { string }?
	local commits = Git.commits(repository, range)
	if commits == nil then
		return nil
	end
	local messages = {}
	for _, commit in commits do
		table.insert(messages, commit.message)
	end
	return messages
end

-- Each failure returns after exiting, so that the type checker knows what follows has what it needs.
local tag = process.args[1]
if tag == nil then
	print("usage: lune run scripts/release_notes <tag>")
	process.exit(2)
	return
end

local root = Git.root()
if root == nil then
	print("release_notes: not inside a git repository")
	process.exit(1)
	return
end

local previous = Git.previousReleaseTag(root, tag)
local messages = messagesOf(root, if previous then previous .. ".." .. tag else tag)
-- Everything the previous release holds, earlier releases included / 이전 릴리스가 담은 모든 것, 그 전 릴리스까지
local earlier: { string }? = if previous then messagesOf(root, previous) else {}
if messages == nil or earlier == nil then
	print(string.format("release_notes: %s cannot be resolved", tag))
	process.exit(1)
	return
end

local files = Snapshot.fromRepository(root).files
local requests: { ReleaseNotes.ChangeRequest } = {}
for _, id in ReleaseNotes.newlyCited(messages, earlier) do
	local request = ReleaseNotes.describe(files, id)
	if request == nil then
		print(string.format("release_notes: %s is cited but has no record", id))
		process.exit(1)
		return
	end
	table.insert(requests, request)
end

stdio.write(ReleaseNotes.render(tag, previous, requests))
