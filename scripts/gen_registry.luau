-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Regenerates docs/REGISTRY.md and docs/REGISTRY.ko.md from document frontmatter.
	문서 frontmatter 로부터 docs/REGISTRY.md 와 docs/REGISTRY.ko.md 를 다시 만든다.

	lune run scripts/gen_registry
]]

local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local Documents = require("./lib/Documents")
local Git = require("./lib/Git")
local Registry = require("./lib/Registry")
local Report = require("./lib/Report")
local Schema = require("./lib/Schema")
local Snapshot = require("./lib/Snapshot")

local foundRoot = Git.root()
if foundRoot == nil then
	stdio.ewrite("gen_registry: not inside a git repository\n")
	process.exit(2)
	return
end
local root: string = foundRoot

-- Document violations are checkpatch's to report; the registry lists whatever can be read.
local index = Documents.check(Snapshot.fromRepository(root), Report.new())
local english, korean = Registry.render(index)

local function write(path: string, content: string)
	local fullPath = root .. "/" .. path
	if fs.isFile(fullPath) and fs.readFile(fullPath) == content then
		print("unchanged " .. path)
	else
		fs.writeFile(fullPath, content)
		print("wrote " .. path)
	end
end

write(Schema.REGISTRY_PATH, english)
write(Schema.REGISTRY_KO_PATH, korean)
if not fs.isDir(root .. "/" .. Schema.DIAGRAMS_FOLDER) then
	fs.writeDir(root .. "/" .. Schema.DIAGRAMS_FOLDER)
end
for _, diagram in Registry.diagrams(index) do
	write(diagram.path, diagram.content)
end
print(string.format("%d documents registered", #index.documents))
