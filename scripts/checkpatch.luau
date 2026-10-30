-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	checkpatch: the compliance gate of EnterpriseEdition, after the Linux kernel's scripts/checkpatch.pl.
	checkpatch: EnterpriseEdition 의 규정 준수 관문. 리눅스 커널의 scripts/checkpatch.pl 을 따른다.

	lune run scripts/checkpatch                       repository: hygiene, toolchain, documents, registry
	lune run scripts/checkpatch --commit-msg <file>   one commit message (.githooks/commit-msg)
	lune run scripts/checkpatch --commits <range>     every commit in a range (CI)
	lune run scripts/checkpatch --list-rules          the rule catalog
]]

local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local Architecture = require("./lib/Architecture")
local Catalog = require("./lib/Catalog")
local CommitMessage = require("./lib/CommitMessage")
local Coverage = require("./lib/Coverage")
local DocComments = require("./lib/DocComments")
local Documents = require("./lib/Documents")
local Forms = require("./lib/Forms")
local Git = require("./lib/Git")
local Hygiene = require("./lib/Hygiene")
local Onboarding = require("./lib/Onboarding")
local ProhibitedApis = require("./lib/ProhibitedApis")
local Registry = require("./lib/Registry")
local Report = require("./lib/Report")
local Snapshot = require("./lib/Snapshot")
local Toolchain = require("./lib/Toolchain")
local Headers = require("./lib/Headers")

local USAGE = [[
usage: lune run scripts/checkpatch [option]

  (no option)            check the repository: file hygiene, toolchain, documents, registry
  --commit-msg <file>    check one commit message file (used by .githooks/commit-msg)
  --commits <range>      check every commit message in a revision range, e.g. develop..HEAD
  --list-rules           print the rule catalog
  --help                 print this message
]]

local function fail(message: string): never
	stdio.ewrite("checkpatch: " .. message .. "\n")
	return process.exit(2)
end

local function finish(report: Report.Report, unit: string): never
	Report.print(report, unit)
	return process.exit(if Report.count(report, "ERROR") > 0 then 1 else 0)
end

local function repositoryRoot(): string
	local root = Git.root()
	if root == nil then
		return fail("not inside a git repository")
	end
	return root
end

local function checkRepository(): never
	local snapshot = Snapshot.fromRepository(repositoryRoot())
	local report = Report.new()
	Hygiene.check(snapshot, report)
	Toolchain.check(snapshot, report)
	Headers.check(snapshot, report)
	Architecture.check(snapshot, report)
	ProhibitedApis.check(snapshot, report)
	DocComments.check(snapshot, report)
	local index = Documents.check(snapshot, report)
	Coverage.check(index, report)
	Forms.check(index, report)
	Onboarding.check(snapshot, index, report)
	Registry.check(snapshot, index, report)
	return finish(report, "files")
end

local function checkMessageFile(file: string): never
	if not fs.isFile(file) then
		return fail("no such file: " .. file)
	end
	local root = repositoryRoot()
	-- Only the index of change requests is needed here; document violations are the repository check's job.
	local documents = Documents.check(Snapshot.fromRepository(root), Report.new())
	local report = Report.new()
	report.checked = 1
	CommitMessage.check(fs.readFile(file), {
		label = file,
		author = Git.authorIdent(root),
		branch = Git.currentBranch(root),
		isMerge = Git.isMerging(root),
		documents = documents,
	}, report)
	return finish(report, "commit messages")
end

local function checkRange(range: string): never
	local root = repositoryRoot()
	local commits = Git.commits(root, range)
	if commits == nil then
		return fail("cannot resolve revision range " .. range)
	end
	local documents = Documents.check(Snapshot.fromRepository(root), Report.new())
	local report = Report.new()
	for _, commit in commits do
		local exemption = CommitMessage.GRANDFATHERED[commit.hash]
		if exemption then
			print(string.format("skipping %s: %s", string.sub(commit.hash, 1, 12), exemption))
			continue
		end
		report.checked += 1
		CommitMessage.check(commit.message, {
			label = string.sub(commit.hash, 1, 12),
			author = commit.author,
			branch = nil,
			isMerge = commit.parents > 1,
			documents = documents,
		}, report)
	end
	return finish(report, "commits")
end

local function listRules(): never
	for _, rule in Catalog.rules do
		print(string.format("%-36s %-8s %-12s %s", rule.code, rule.severity, rule.standard, rule.summary))
	end
	return process.exit(0)
end

local args = process.args
local option = args[1]
if option == nil then
	checkRepository()
elseif option == "--commit-msg" and args[2] then
	checkMessageFile(args[2])
elseif option == "--commits" and args[2] then
	checkRange(args[2])
elseif option == "--list-rules" then
	listRules()
elseif option == "--help" or option == "-h" then
	print(USAGE)
	process.exit(0)
else
	stdio.ewrite(USAGE)
	process.exit(2)
end
