-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	A snapshot of repository files. Checks read files only through a snapshot,
	so tests can build one in memory instead of touching the disk.
	저장소 파일의 스냅숏. 검사는 스냅숏으로만 파일을 읽으므로, 테스트는 디스크 대신 메모리에서 만든다.
]]

local fs = require("@lune/fs")

local Git = require("./Git")

export type Snapshot = {
	-- Repository-relative path with forward slashes -> raw file content.
	files: { [string]: string },
}

local Snapshot = {}

function Snapshot.new(files: { [string]: string }): Snapshot
	return { files = files }
end

function Snapshot.fromRepository(root: string): Snapshot
	local files = {}
	for _, path in Git.listFiles(root) do
		local fullPath = root .. "/" .. path
		-- Deleted but still tracked files are listed too.
		if fs.isFile(fullPath) then
			files[path] = fs.readFile(fullPath)
		end
	end
	return { files = files }
end

function Snapshot.paths(snapshot: Snapshot): { string }
	local paths = {}
	for path in snapshot.files do
		table.insert(paths, path)
	end
	table.sort(paths)
	return paths
end

return Snapshot
