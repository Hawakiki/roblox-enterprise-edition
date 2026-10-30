-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Commit message and branch rules: Conventional Commits subject in English, a bilingual body,
	and trailers that tie every commit to a signed-off author and a filed change request.
	커밋 메시지와 브랜치 규칙: 영어 Conventional Commits 제목, 한/영 본문,
	그리고 모든 커밋을 서명한 작성자와 등록된 변경 요청에 묶는 trailer.
]]

local Documents = require("./Documents")
local Report = require("./Report")
local Text = require("./Text")

export type Context = {
	-- Where the message came from; used as the location in reports.
	label: string,
	-- "Name <email>". nil skips the sign-off identity check.
	author: string?,
	-- nil skips branch checks (detached HEAD, commit ranges).
	branch: string?,
	isMerge: boolean,
	documents: Documents.Index,
}

type Line = {
	number: number,
	text: string,
}

type Trailer = {
	key: string,
	value: string,
	number: number,
}

local TYPES = { "feat", "fix", "refactor", "perf", "test", "docs", "chore", "build", "ci", "revert" }
local SUBJECT_LIMIT = 72
local BODY_LIMIT = 72
local SCISSORS = "# ------------------------ >8 ------------------------"

-- Lowercased key -> canonical spelling.
local TRAILERS: { [string]: string } = {
	["acked-by"] = "Acked-by",
	["approved-by"] = "Approved-by",
	["change-request"] = "Change-Request",
	["co-authored-by"] = "Co-Authored-By",
	["jira"] = "Jira",
	["reviewed-by"] = "Reviewed-by",
	["signed-off-by"] = "Signed-off-by",
}
local IDENTITY_TRAILERS: { [string]: boolean } = {
	["Acked-by"] = true,
	["Approved-by"] = true,
	["Co-Authored-By"] = true,
	["Reviewed-by"] = true,
	["Signed-off-by"] = true,
}
local IDENTITY = "^[^<>]+ <[^<>%s]+@[^<>%s]+>$"
local TRAILER_LINE = "^(%a[%w%-]*):%s+(.+)$"

local PROTECTED_BRANCHES: { [string]: boolean } = {
	develop = true,
	main = true,
}

local function allowedTrailers(): string
	local names = {}
	for _, name in TRAILERS do
		table.insert(names, name)
	end
	table.sort(names)
	return table.concat(names, ", ")
end

-- Drops what git itself would strip: comment lines, everything below the scissors line,
-- trailing whitespace and surrounding blank lines. Line numbers refer to the original message.
local function clean(message: string): { Line }
	local lines: { Line } = {}
	for number, text in string.split(Text.normalize(message), "\n") do
		if text == SCISSORS then
			break
		end
		if string.sub(text, 1, 1) ~= "#" then
			table.insert(lines, { number = number, text = Text.trimRight(text) })
		end
	end
	while #lines > 0 and lines[1].text == "" do
		table.remove(lines, 1)
	end
	while #lines > 0 and lines[#lines].text == "" do
		table.remove(lines)
	end
	return lines
end

local function paragraphs(lines: { Line }): { { Line } }
	local result: { { Line } } = {}
	local current: { Line } = {}
	for _, line in lines do
		if line.text == "" then
			if #current > 0 then
				table.insert(result, current)
				current = {}
			end
		else
			table.insert(current, line)
		end
	end
	if #current > 0 then
		table.insert(result, current)
	end
	return result
end

-- nil unless every line of the paragraph is "Key: value".
local function parseTrailers(paragraph: { Line }): { Trailer }?
	local trailers: { Trailer } = {}
	for _, line in paragraph do
		local key, value = string.match(line.text, TRAILER_LINE)
		if not (key and value) then
			return nil
		end
		table.insert(trailers, { key = key, value = value, number = line.number })
	end
	return trailers
end

local function checkSubject(subject: Line, context: Context, report: Report.Report)
	local label, text, number = context.label, subject.text, subject.number
	if not Text.isAscii(text) then
		Report.add(report, "COMMIT_SUBJECT_NOT_ENGLISH", label, number, "the subject must be written in English")
	end
	local width = Text.displayWidth(text)
	if width > SUBJECT_LIMIT then
		Report.add(
			report,
			"COMMIT_SUBJECT_TOO_LONG",
			label,
			number,
			string.format("the subject is %d columns; the limit is %d", width, SUBJECT_LIMIT)
		)
	end

	if context.isMerge then
		if not string.match(text, "^Merge branch '[^']+'") then
			Report.add(
				report,
				"COMMIT_SUBJECT_FORMAT",
				label,
				number,
				"merge commit subjects must be \"Merge branch '<source>' into <target>\""
			)
		end
		return
	end

	local kind, description = string.match(text, "^(%l+)%([%l%d%-]+%)!?: (.+)$")
	if not (kind and description) then
		Report.add(
			report,
			"COMMIT_SUBJECT_FORMAT",
			label,
			number,
			"the subject must be '<type>(<scope>): <description>' with a lowercase scope"
		)
		return
	end
	if not Text.contains(TYPES, kind) then
		Report.add(
			report,
			"COMMIT_SUBJECT_FORMAT",
			label,
			number,
			string.format("unknown type '%s'; allowed: %s", kind, table.concat(TYPES, ", "))
		)
	end
	if string.match(description, "^%u%l") then
		Report.add(report, "COMMIT_SUBJECT_STYLE", label, number, "the description must not start in sentence case")
	end
	if string.sub(description, -1) == "." then
		Report.add(report, "COMMIT_SUBJECT_STYLE", label, number, "the description must not end with a period")
	end
end

local function checkBody(body: { Line }, fallbackLine: number, context: Context, report: Report.Report)
	local label = context.label
	for _, line in body do
		local width = Text.displayWidth(line.text)
		if width > BODY_LIMIT and not string.find(line.text, "://", 1, true) then
			Report.add(
				report,
				"COMMIT_BODY_LINE_TOO_LONG",
				label,
				line.number,
				string.format("the line is %d columns; the limit is %d", width, BODY_LIMIT)
			)
		end
	end

	if #body == 0 or body[1].text ~= "[EN]" then
		local number = if #body > 0 then body[1].number else fallbackLine
		Report.add(report, "COMMIT_MISSING_BODY_SECTION", label, number, "the body must open with an [EN] section")
		return
	end
	local korean: number? = nil
	for position = 2, #body do
		if body[position].text == "[KO]" then
			korean = position
			break
		end
	end
	if korean == nil then
		Report.add(
			report,
			"COMMIT_MISSING_BODY_SECTION",
			label,
			body[#body].number,
			"the [EN] section must be followed by a [KO] section"
		)
		return
	end
	if korean == 2 then
		Report.add(report, "COMMIT_MISSING_BODY_SECTION", label, body[1].number, "the [EN] section is empty")
	end
	if korean == #body then
		Report.add(report, "COMMIT_MISSING_BODY_SECTION", label, body[korean].number, "the [KO] section is empty")
		return
	end
	local text = {}
	for position = korean + 1, #body do
		table.insert(text, body[position].text)
	end
	if not Text.hasHangul(table.concat(text, "\n")) then
		Report.add(
			report,
			"COMMIT_SECTION_LANGUAGE",
			label,
			body[korean + 1].number,
			"the [KO] section must be written in Korean"
		)
	end
end

-- Returns the well-formed Change-Request trailers.
local function checkTrailers(
	trailers: { Trailer },
	endLine: number,
	context: Context,
	report: Report.Report
): { Trailer }
	local label = context.label
	local signoffs: { string } = {}
	local changeRequests: { Trailer } = {}
	local approved = false

	for _, trailer in trailers do
		local name = TRAILERS[string.lower(trailer.key)]
		if name == nil then
			Report.add(
				report,
				"COMMIT_UNKNOWN_TRAILER",
				label,
				trailer.number,
				string.format("unknown trailer '%s'; allowed: %s", trailer.key, allowedTrailers())
			)
		elseif IDENTITY_TRAILERS[name] and not string.match(trailer.value, IDENTITY) then
			Report.add(
				report,
				"COMMIT_MALFORMED_TRAILER",
				label,
				trailer.number,
				string.format("%s must be 'Name <email>'", name)
			)
		elseif name == "Signed-off-by" then
			table.insert(signoffs, trailer.value)
		elseif name == "Approved-by" then
			approved = true
		elseif name == "Change-Request" then
			if string.match(trailer.value, "^CR%-%d%d%d%d$") then
				table.insert(changeRequests, trailer)
			else
				Report.add(
					report,
					"COMMIT_MALFORMED_TRAILER",
					label,
					trailer.number,
					"Change-Request must be 'CR-NNNN'"
				)
			end
		elseif name == "Jira" and not string.match(trailer.value, "^%u+%-%d+$") then
			Report.add(
				report,
				"COMMIT_MALFORMED_TRAILER",
				label,
				trailer.number,
				"Jira must be an issue key such as EE-1234"
			)
		end
	end

	local author = context.author
	if #signoffs == 0 then
		Report.add(
			report,
			"COMMIT_MISSING_SIGNOFF",
			label,
			endLine,
			"missing 'Signed-off-by: Name <email>'; commit with git commit -s"
		)
	elseif author and not Text.contains(signoffs, author) then
		Report.add(
			report,
			"COMMIT_SIGNOFF_MISMATCH",
			label,
			endLine,
			string.format("the author %s has not signed off", author)
		)
	end

	if #changeRequests == 0 then
		Report.add(
			report,
			"COMMIT_MISSING_CHANGE_REQUEST",
			label,
			endLine,
			"cite the change request this commit implements: 'Change-Request: CR-NNNN'"
		)
	end
	for _, trailer in changeRequests do
		local document = context.documents.byId[trailer.value]
		local status = if document then document.status else nil
		if document == nil then
			Report.add(
				report,
				"COMMIT_UNKNOWN_CHANGE_REQUEST",
				label,
				trailer.number,
				string.format("%s is not filed under docs/records/change-requests/", trailer.value)
			)
		elseif status == "Rejected" or status == "Closed" then
			Report.add(
				report,
				"COMMIT_CHANGE_REQUEST_CLOSED",
				label,
				trailer.number,
				string.format("%s is %s and accepts no further commits", trailer.value, status)
			)
		elseif status ~= "Approved" and status ~= "Implemented" then
			Report.add(
				report,
				"COMMIT_CHANGE_REQUEST_NOT_APPROVED",
				label,
				trailer.number,
				string.format("%s is %s; commits should wait for its approval", trailer.value, tostring(status))
			)
		end
	end

	if context.isMerge and not approved then
		Report.add(
			report,
			"COMMIT_MISSING_APPROVAL",
			label,
			endLine,
			"merge commits must carry 'Approved-by: Name <email>'"
		)
	end
	return changeRequests
end

local function checkBranch(changeRequests: { Trailer }, context: Context, report: Report.Report)
	local branch = context.branch
	if branch == nil then
		return
	end
	local label = context.label

	if PROTECTED_BRANCHES[branch] then
		if not context.isMerge then
			Report.add(
				report,
				"DIRECT_COMMIT_TO_PROTECTED_BRANCH",
				label,
				nil,
				string.format(
					"%s accepts merge commits only; commit on a feature/CR-NNNN-<slug> branch and merge with --no-ff",
					branch
				)
			)
		end
		return
	end

	local changeRequest = string.match(branch, "^feature/(CR%-%d%d%d%d)%-[a-z0-9][a-z0-9%-]*$")
	if changeRequest then
		for _, trailer in changeRequests do
			if trailer.value == changeRequest then
				return
			end
		end
		Report.add(
			report,
			"BRANCH_CHANGE_REQUEST_MISMATCH",
			label,
			nil,
			string.format("branch %s belongs to %s, which this commit does not cite", branch, changeRequest)
		)
		return
	end

	if
		string.match(branch, "^release/[%w%.%+%-]+$") or string.match(branch, "^hotfix/SEV[1-4]%-[a-z0-9][a-z0-9%-]*$")
	then
		return
	end
	Report.add(
		report,
		"BRANCH_NAME_FORMAT",
		label,
		nil,
		string.format("branch '%s' must be feature/CR-NNNN-<slug>, release/<version> or hotfix/SEV<1-4>-<slug>", branch)
	)
end

local CommitMessage = {}

-- Commits made before EE-STD-0007 took effect. Exempt, and never to be rewritten.
CommitMessage.GRANDFATHERED = {
	["8f2b55999e18142d13cfe586ddd771ca31d0274d"] = "the initial commit predates EE-STD-0007",
} :: { [string]: string }

function CommitMessage.check(message: string, context: Context, report: Report.Report)
	local lines = clean(message)
	if #lines == 0 then
		Report.add(report, "COMMIT_SUBJECT_FORMAT", context.label, 1, "the commit message is empty")
		return
	end
	local blocks = paragraphs(lines)
	local subjectBlock = blocks[1]

	checkSubject(subjectBlock[1], context, report)
	if #subjectBlock > 1 then
		Report.add(
			report,
			"COMMIT_MISSING_BLANK_LINE",
			context.label,
			subjectBlock[2].number,
			"the subject must be followed by a blank line"
		)
	end

	local trailers: { Trailer } = {}
	local lastBodyBlock = #blocks
	if #blocks > 1 then
		local parsed = parseTrailers(blocks[#blocks])
		if parsed then
			trailers = parsed
			lastBodyBlock = #blocks - 1
		end
	end
	local body: { Line } = {}
	for position = 2, lastBodyBlock do
		for _, line in blocks[position] do
			table.insert(body, line)
		end
	end

	checkBody(body, subjectBlock[1].number + 1, context, report)
	local changeRequests = checkTrailers(trailers, lines[#lines].number, context, report)
	checkBranch(changeRequests, context, report)
end

return CommitMessage
