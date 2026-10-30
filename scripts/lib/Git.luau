-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The few git queries checkpatch needs.
	checkpatch 가 쓰는 git 조회 몇 가지.
]]

local process = require("@lune/process")

local Text = require("./Text")

export type Commit = {
	hash: string,
	author: string,
	parents: number,
	message: string,
}

local Git = {}

local function run(root: string?, args: { string }): (boolean, string)
	local result = process.exec("git", args, { cwd = root })
	return result.ok, result.stdout
end

function Git.root(): string?
	local ok, out = run(nil, { "rev-parse", "--show-toplevel" })
	if not ok then
		return nil
	end
	return Text.trim(out)
end

-- Tracked files plus untracked files that are not ignored.
function Git.listFiles(root: string): { string }
	local ok, out = run(root, { "ls-files", "-z", "--cached", "--others", "--exclude-standard" })
	if not ok then
		error("git ls-files failed")
	end
	local paths = {}
	for _, path in string.split(out, "\0") do
		if path ~= "" then
			table.insert(paths, path)
		end
	end
	return paths
end

-- "Name <email>", without the timestamp git appends.
function Git.authorIdent(root: string): string?
	local ok, out = run(root, { "var", "GIT_AUTHOR_IDENT" })
	if not ok then
		return nil
	end
	return string.match(out, "^(.-<[^>]*>)")
end

-- nil on a detached HEAD.
function Git.currentBranch(root: string): string?
	local ok, out = run(root, { "symbolic-ref", "--short", "-q", "HEAD" })
	local branch = Text.trim(out)
	if not ok or branch == "" then
		return nil
	end
	return branch
end

function Git.isMerging(root: string): boolean
	local ok = run(root, { "rev-parse", "-q", "--verify", "MERGE_HEAD" })
	return ok
end

-- Oldest first. nil when the range cannot be resolved.
function Git.commits(root: string, range: string): { Commit }?
	local ok, out = run(root, { "log", "--reverse", "--format=%H%x1f%an <%ae>%x1f%P%x1f%B%x1e", range })
	if not ok then
		return nil
	end
	local commits = {}
	for _, entry in string.split(out, "\30") do
		local fields = string.split(entry, "\31")
		if #fields >= 4 then
			local parents = 0
			for _, parent in string.split(Text.trim(fields[3]), " ") do
				if parent ~= "" then
					parents += 1
				end
			end
			table.insert(commits, {
				hash = Text.trim(fields[1]),
				author = fields[2],
				parents = parents,
				message = fields[4],
			})
		end
	end
	return commits
end

return Git
