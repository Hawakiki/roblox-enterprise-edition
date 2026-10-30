-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Document control. Reads every document under docs/, validates its frontmatter against the schema,
	pairs it with its Korean translation, and checks the hierarchy and cross-references between documents.
	문서 통제. docs/ 아래 모든 문서의 frontmatter 를 스키마로 검증하고, 국문 번역본과 짝을 맞추고,
	문서 위계와 상호 참조를 검사한다.
]]

local Frontmatter = require("./Frontmatter")
local Report = require("./Report")
local Schema = require("./Schema")
local Semver = require("./Semver")
local Snapshot = require("./Snapshot")
local Text = require("./Text")

export type Translation = {
	path: string,
	id: string?,
	idLine: number,
	title: string?,
	translationOf: Semver.Version?,
	translationOfLine: number,
	body: { string },
	bodyLine: number,
}

export type Document = {
	id: string,
	kind: Schema.Kind,
	path: string,
	title: string,
	version: Semver.Version?,
	status: string?,
	classification: string?,
	owner: string?,
	parent: string?,
	parentRevision: Semver.Revision?,
	parentLine: number,
	body: { string },
	bodyLine: number,
	translation: Translation?,
}

export type Index = {
	-- Sorted in registry order.
	documents: { Document },
	byId: { [string]: Document },
}

local EN_SUFFIX = ".md"
local KO_SUFFIX = ".ko.md"

-- Identifiers as they appear in prose. Unregistered kinds are ignored, so examples can use made-up codes.
local CONTROLLED_TOKEN = "%f[%w]EE%-%u%u%u%-%d%d%d%d%f[%W]"
local RECORD_TOKEN = "%f[%w]%u+%-%d%d%d%d%f[%W]"

local function nonEmptyString(value: any): string?
	if type(value) == "string" and Text.trim(value) ~= "" then
		return value
	end
	return nil
end

local function isSlug(s: string): boolean
	return string.find(s, "^[a-z0-9][a-z0-9%-]*$") ~= nil and string.find(s, "%-%-") == nil and string.sub(s, -1) ~= "-"
end

-- Reports a missing or broken frontmatter block. Returns true when the document cannot be read further.
local function reportParseProblem(path: string, parsed: Frontmatter.Parsed, report: Report.Report): boolean
	if parsed.problem == "missing" then
		Report.add(report, "MISSING_FRONTMATTER", path, 1, parsed.message or "missing frontmatter")
		return true
	elseif parsed.problem ~= nil or parsed.fields == nil then
		Report.add(report, "INVALID_FRONTMATTER", path, 1, parsed.message or "invalid frontmatter")
		return true
	end
	return false
end

local function checkHeading(path: string, body: { string }, bodyLine: number, title: string, report: Report.Report)
	local expected = "# " .. title
	for offset, line in body do
		if Text.trim(line) ~= "" then
			if line ~= expected then
				Report.add(
					report,
					"TITLE_HEADING_MISMATCH",
					path,
					bodyLine + offset - 1,
					string.format("the first heading must be '%s'", expected)
				)
			end
			return
		end
	end
	Report.add(
		report,
		"TITLE_HEADING_MISMATCH",
		path,
		bodyLine,
		string.format("the document has no body; the first heading must be '%s'", expected)
	)
end

local function checkLocation(path: string, id: string, kind: Schema.Kind, report: Report.Report)
	local folder, name = string.match(path, "^(.*)/([^/]+)$")
	if folder ~= kind.folder then
		Report.add(
			report,
			"MISPLACED_DOCUMENT",
			path,
			nil,
			string.format("%s documents belong in %s/", kind.code, kind.folder)
		)
	end
	local prefix = id .. "-"
	local slug = ""
	if name and string.sub(name, 1, #prefix) == prefix then
		slug = string.sub(name, #prefix + 1, -#EN_SUFFIX - 1)
	end
	if not isSlug(slug) then
		Report.add(
			report,
			"FILENAME_MISMATCH",
			path,
			nil,
			string.format("the file name must be '%s-<slug>.md' with a lowercase, hyphenated slug", id)
		)
	end
end

local function readDocument(path: string, content: string, report: Report.Report): Document?
	local parsed = Frontmatter.parse(content)
	local fields = parsed.fields
	if reportParseProblem(path, parsed, report) or fields == nil then
		return nil
	end
	local function lineOf(key: string): number
		return parsed.fieldLines[key] or 1
	end

	local id = fields.id
	if id == nil then
		Report.add(report, "MISSING_FIELD", path, 1, "missing required field 'id'")
		return nil
	elseif type(id) ~= "string" then
		Report.add(report, "INVALID_FIELD_VALUE", path, lineOf("id"), "'id' must be a string")
		return nil
	end
	local kind = Schema.kindOf(id)
	if kind == nil then
		Report.add(
			report,
			"UNKNOWN_DOCUMENT_TYPE",
			path,
			lineOf("id"),
			string.format("'%s' does not match any registered document kind", id)
		)
		return nil
	end
	checkLocation(path, id, kind, report)

	for _, key in Text.sortedKeys(fields) do
		if not Text.contains(Schema.FIELDS, key) then
			Report.add(report, "UNKNOWN_FIELD", path, lineOf(key), string.format("unknown field '%s'", key))
		end
	end
	for _, key in Schema.REQUIRED_FIELDS do
		local value = fields[key]
		if value == nil then
			Report.add(report, "MISSING_FIELD", path, 1, string.format("missing required field '%s'", key))
		elseif nonEmptyString(value) == nil then
			Report.add(
				report,
				"INVALID_FIELD_VALUE",
				path,
				lineOf(key),
				string.format("'%s' must be a non-empty string; quote values YAML would read as numbers", key)
			)
		end
	end

	local version: Semver.Version? = nil
	local versionText = nonEmptyString(fields.version)
	if versionText then
		version = Semver.parse(versionText)
		if version == nil then
			Report.add(
				report,
				"INVALID_FIELD_VALUE",
				path,
				lineOf("version"),
				string.format("version '%s' must be MAJOR.MINOR.PATCH", versionText)
			)
		end
	end

	local status = nonEmptyString(fields.status)
	if status and not Text.contains(kind.statuses, status) then
		Report.add(
			report,
			"INVALID_FIELD_VALUE",
			path,
			lineOf("status"),
			string.format(
				"status '%s' is not valid for %s documents; expected one of: %s",
				status,
				kind.code,
				table.concat(kind.statuses, ", ")
			)
		)
		status = nil
	end

	local classification = nonEmptyString(fields.classification)
	if classification and not Text.contains(Schema.CLASSIFICATIONS, classification) then
		Report.add(
			report,
			"INVALID_FIELD_VALUE",
			path,
			lineOf("classification"),
			string.format(
				"classification '%s' is not valid; expected one of: %s",
				classification,
				table.concat(Schema.CLASSIFICATIONS, ", ")
			)
		)
		classification = nil
	end

	if kind.controlled and version and status then
		local draft = status == "Draft" or status == "In Review"
		if draft and version.major ~= 0 then
			Report.add(
				report,
				"VERSION_STATUS_MISMATCH",
				path,
				lineOf("version"),
				string.format("%s documents must be versioned 0.x.y, not %s", status, Semver.format(version))
			)
		elseif not draft and version.major == 0 then
			Report.add(
				report,
				"VERSION_STATUS_MISMATCH",
				path,
				lineOf("version"),
				string.format("%s documents must be versioned 1.0.0 or later, not %s", status, Semver.format(version))
			)
		end
	end

	local parent: string? = nil
	local parentRevision: Semver.Revision? = nil
	local isRoot = id == Schema.ROOT_DOCUMENT
	if fields.parent ~= nil then
		if not kind.controlled then
			Report.add(
				report,
				"UNEXPECTED_PARENT",
				path,
				lineOf("parent"),
				"records sit outside the document hierarchy and take no parent"
			)
		elseif isRoot then
			Report.add(
				report,
				"UNEXPECTED_PARENT",
				path,
				lineOf("parent"),
				"the charter is the root of the hierarchy and takes no parent"
			)
		else
			local reference = nonEmptyString(fields.parent)
			local parentId: string?, revisionText: string? = nil, nil
			if reference then
				parentId, revisionText = string.match(reference, "^(.+)@(%d+%.%d+)$")
			end
			if parentId and revisionText then
				parent = parentId
				parentRevision = Semver.parseRevision(revisionText)
			else
				Report.add(
					report,
					"INVALID_FIELD_VALUE",
					path,
					lineOf("parent"),
					"'parent' must be '<document id>@<MAJOR.MINOR>'"
				)
			end
		end
	elseif kind.controlled and not isRoot then
		Report.add(
			report,
			"MISSING_PARENT",
			path,
			1,
			"controlled documents must cite a parent as 'parent: <document id>@<MAJOR.MINOR>'"
		)
	end

	local title = nonEmptyString(fields.title)
	if title then
		checkHeading(path, parsed.body, parsed.bodyLine, title, report)
	end

	return {
		id = id,
		kind = kind,
		path = path,
		title = title or id,
		version = version,
		status = status,
		classification = classification,
		owner = nonEmptyString(fields.owner),
		parent = parent,
		parentRevision = parentRevision,
		parentLine = lineOf("parent"),
		body = parsed.body,
		bodyLine = parsed.bodyLine,
		translation = nil,
	}
end

local function readTranslation(path: string, content: string, report: Report.Report): Translation?
	local parsed = Frontmatter.parse(content)
	local fields = parsed.fields
	if reportParseProblem(path, parsed, report) or fields == nil then
		return nil
	end
	local function lineOf(key: string): number
		return parsed.fieldLines[key] or 1
	end

	for _, key in Text.sortedKeys(fields) do
		if Text.contains(Schema.TRANSLATION_FIELDS, key) then
			continue
		elseif Text.contains(Schema.FIELDS, key) then
			Report.add(
				report,
				"TRANSLATION_EXTRA_FIELD",
				path,
				lineOf(key),
				string.format("'%s' belongs in the authoritative English document only", key)
			)
		else
			Report.add(report, "UNKNOWN_FIELD", path, lineOf(key), string.format("unknown field '%s'", key))
		end
	end
	for _, key in Schema.TRANSLATION_FIELDS do
		local value = fields[key]
		if value == nil then
			Report.add(report, "MISSING_FIELD", path, 1, string.format("missing required field '%s'", key))
		elseif nonEmptyString(value) == nil then
			Report.add(
				report,
				"INVALID_FIELD_VALUE",
				path,
				lineOf(key),
				string.format("'%s' must be a non-empty string; quote values YAML would read as numbers", key)
			)
		end
	end

	local translationOf: Semver.Version? = nil
	local translationOfText = nonEmptyString(fields["translation-of"])
	if translationOfText then
		translationOf = Semver.parse(translationOfText)
		if translationOf == nil then
			Report.add(
				report,
				"INVALID_FIELD_VALUE",
				path,
				lineOf("translation-of"),
				string.format("translation-of '%s' must be MAJOR.MINOR.PATCH", translationOfText)
			)
		end
	end

	local title = nonEmptyString(fields.title)
	if title then
		checkHeading(path, parsed.body, parsed.bodyLine, title, report)
	end
	-- The title heading alone does not make a translation.
	local prose = {}
	for _, line in parsed.body do
		if string.sub(line, 1, 2) ~= "# " then
			table.insert(prose, line)
		end
	end
	if not Text.hasHangul(table.concat(prose, "\n")) then
		Report.add(report, "TRANSLATION_NOT_KOREAN", path, parsed.bodyLine, "the translation contains no Korean text")
	end

	return {
		path = path,
		id = nonEmptyString(fields.id),
		idLine = lineOf("id"),
		title = title,
		translationOf = translationOf,
		translationOfLine = lineOf("translation-of"),
		body = parsed.body,
		bodyLine = parsed.bodyLine,
	}
end

local function checkTranslation(document: Document, translation: Translation, report: Report.Report)
	local translationId = translation.id
	if translationId and translationId ~= document.id then
		Report.add(
			report,
			"TRANSLATION_ID_MISMATCH",
			translation.path,
			translation.idLine,
			string.format("the translation is labelled %s but translates %s", translationId, document.id)
		)
	end
	local version, translationOf = document.version, translation.translationOf
	if version and translationOf and Semver.format(version) ~= Semver.format(translationOf) then
		Report.add(
			report,
			"STALE_TRANSLATION",
			translation.path,
			translation.translationOfLine,
			string.format(
				"translation-of %s does not match version %s of %s; update the translation",
				Semver.format(translationOf),
				Semver.format(version),
				document.id
			)
		)
	end
end

local function checkHierarchy(index: Index, report: Report.Report)
	for _, document in index.documents do
		local parentId = document.parent
		if parentId == nil then
			continue
		end
		local parent = index.byId[parentId]
		if parent == nil then
			Report.add(
				report,
				"UNKNOWN_PARENT",
				document.path,
				document.parentLine,
				string.format("parent %s does not exist", parentId)
			)
			continue
		end
		if not parent.kind.controlled or parent.kind.level > document.kind.level then
			Report.add(
				report,
				"PARENT_HIERARCHY_VIOLATION",
				document.path,
				document.parentLine,
				string.format(
					"%s cannot cite %s as its parent; a parent must be a controlled document at the same or a higher level",
					document.id,
					parent.id
				)
			)
		end
		local revision, version = document.parentRevision, parent.version
		if revision and version and not Semver.sameRevision(version, revision) then
			Report.add(
				report,
				"STALE_PARENT",
				document.path,
				document.parentLine,
				string.format(
					"cites %s@%s but %s is now at %s; review this document and update the citation",
					parent.id,
					Semver.formatRevision(revision),
					parent.id,
					Semver.formatRevision(version)
				)
			)
		end
	end

	for _, document in index.documents do
		local seen: { [string]: boolean } = {}
		local current: Document? = document
		while current do
			local parentId = current.parent
			if parentId == nil or seen[current.id] then
				break
			end
			seen[current.id] = true
			local nextDocument = index.byId[parentId]
			if nextDocument == document then
				Report.add(
					report,
					"PARENT_CYCLE",
					document.path,
					document.parentLine,
					string.format("the parent chain of %s leads back to itself", document.id)
				)
				break
			end
			current = nextDocument
		end
	end
end

local function referencesIn(line: string): { string }
	local found = {}
	for token in string.gmatch(line, CONTROLLED_TOKEN) do
		if Schema.kindOf(token) then
			table.insert(found, token)
		end
	end
	for token in string.gmatch(line, RECORD_TOKEN) do
		-- Also matches the tail of a controlled identifier ("POL-0001"), which no record kind claims.
		local kind = Schema.kindOf(token)
		if kind and not kind.controlled then
			table.insert(found, token)
		end
	end
	return found
end

local function checkReferences(path: string, body: { string }, bodyLine: number, index: Index, report: Report.Report)
	local reported: { [string]: boolean } = {}
	for offset, line in body do
		for _, token in referencesIn(line) do
			if index.byId[token] == nil and not reported[token] then
				reported[token] = true
				Report.add(
					report,
					"DANGLING_REFERENCE",
					path,
					bodyLine + offset - 1,
					string.format("%s does not exist", token)
				)
			end
		end
	end
end

local Documents = {}

-- The identifiers of registered kinds that a line of prose mentions.
Documents.referencesIn = referencesIn

function Documents.check(snapshot: Snapshot.Snapshot, report: Report.Report): Index
	local index: Index = { documents = {}, byId = {} }
	local englishPaths: { [string]: boolean } = {}
	-- Keyed by the path of the English document they translate.
	local translationPaths: { [string]: string } = {}
	local translations: { [string]: Translation } = {}

	for _, path in Snapshot.paths(snapshot) do
		if string.sub(path, 1, 5) ~= "docs/" or path == Schema.REGISTRY_PATH or path == Schema.REGISTRY_KO_PATH then
			continue
		end
		local content = snapshot.files[path]
		if string.sub(path, -#KO_SUFFIX) == KO_SUFFIX then
			local englishPath = string.sub(path, 1, -#KO_SUFFIX - 1) .. EN_SUFFIX
			translationPaths[englishPath] = path
			local translation = readTranslation(path, content, report)
			if translation then
				translations[englishPath] = translation
			end
		elseif string.sub(path, -#EN_SUFFIX) == EN_SUFFIX then
			englishPaths[path] = true
			local document = readDocument(path, content, report)
			if document then
				local existing = index.byId[document.id]
				if existing then
					Report.add(
						report,
						"DUPLICATE_DOCUMENT_ID",
						path,
						nil,
						string.format("%s is already used by %s", document.id, existing.path)
					)
				else
					index.byId[document.id] = document
					table.insert(index.documents, document)
				end
			end
		else
			Report.add(report, "STRAY_FILE", path, nil, "only Markdown documents belong under docs/")
		end
	end

	for _, englishPath in Text.sortedKeys(translationPaths) do
		if not englishPaths[englishPath] then
			Report.add(
				report,
				"ORPHAN_TRANSLATION",
				translationPaths[englishPath],
				nil,
				string.format("no authoritative English document at %s", englishPath)
			)
		end
	end
	for _, document in index.documents do
		local translationPath = translationPaths[document.path]
		if translationPath == nil then
			Report.add(
				report,
				"MISSING_TRANSLATION",
				document.path,
				nil,
				string.format(
					"no Korean translation; expected %s",
					string.sub(document.path, 1, -#EN_SUFFIX - 1) .. KO_SUFFIX
				)
			)
		else
			local translation = translations[document.path]
			if translation then
				document.translation = translation
				checkTranslation(document, translation, report)
			end
		end
	end

	checkHierarchy(index, report)
	for _, document in index.documents do
		checkReferences(document.path, document.body, document.bodyLine, index, report)
		local translation = document.translation
		if translation then
			checkReferences(translation.path, translation.body, translation.bodyLine, index, report)
		end
	end

	table.sort(index.documents, function(a: Document, b: Document): boolean
		local orderA, orderB = Schema.order(a.kind), Schema.order(b.kind)
		if orderA ~= orderB then
			return orderA < orderB
		end
		return a.id < b.id
	end)
	return index
end

return Documents
