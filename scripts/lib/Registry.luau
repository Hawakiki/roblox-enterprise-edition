-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The document registry: docs/REGISTRY.md and docs/REGISTRY.ko.md, rendered from document frontmatter, and the
	diagrams it draws beside itself under diagrams/ (CR-0021).
	No hand-maintained copy exists, so the registry cannot drift from the documents.
	문서 대장: 문서 frontmatter 로부터 docs/REGISTRY.md 와 docs/REGISTRY.ko.md 를 만들고, 함께 그리는 도식을
	diagrams/ 아래에 만든다(CR-0021). 손으로 관리하는 사본이 없으므로 대장과 문서가 어긋날 수 없다.
]]

local Documents = require("./Documents")
local Report = require("./Report")
local Rule = require("./Rule")
local Schema = require("./Schema")
local Semver = require("./Semver")
local Snapshot = require("./Snapshot")
local TreeDiagram = require("./TreeDiagram")

-- The rules this check reports, declared beside it (CR-0009). / 이 검사가 보고하는 규칙. 검사 옆에 선언한다(CR-0009).
local RULES = {
	REGISTRY_OUT_OF_DATE = Rule.new(
		"REGISTRY_OUT_OF_DATE",
		"ERROR",
		"EE-POL-0001",
		"The document registry must match the output of scripts/gen_registry.luau."
	),
}

type Language = {
	title: string,
	intro: { string },
	switch: string,
	summary: string,
	summaryHeader: string,
	total: string,
	empty: string,
	controlledHeader: string,
	recordHeader: string,
	label: (kind: Schema.Kind) -> string,
	status: (status: string) -> string,
	classification: (classification: string) -> string,
	documentTitle: (document: Documents.Document) -> string,
	link: (document: Documents.Document) -> string,
	lineage: string,
	lineageIntro: string,
	lineageAlt: string,
	lineageImage: string,
	lineagePath: string,
	textVersion: string,
	reserved: string,
	inReview: string,
}

type Group = {
	kind: Schema.Kind,
	documents: { Documents.Document },
}

local NONE = "—"

local HEADER = {
	"<!-- SPDX-License-Identifier: MIT -->",
	"<!-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors -->",
	"<!-- GENERATED FILE. DO NOT EDIT. Regenerate with: lune run scripts/gen_registry -->",
	"",
}

local STATUS_KO: { [string]: string } = {
	["Accepted"] = "채택",
	["Approved"] = "승인",
	["Closed"] = "종결",
	["Deprecated"] = "폐지",
	["Discussion"] = "논의 중",
	["Draft"] = "초안",
	["Implemented"] = "시행",
	["In Review"] = "검토 중",
	["Proposed"] = "제안",
	["Rejected"] = "반려",
	["Returned"] = "재작성 요청",
	["Submitted"] = "상신",
	["Superseded"] = "대체됨",
	["Withdrawn"] = "철회",
}

local CLASSIFICATION_KO: { [string]: string } = {
	["Confidential"] = "대외비",
	["Internal"] = "사내 한정",
	["Public"] = "공개",
	["Restricted"] = "극비",
}

-- Registry links are relative to docs/.
local function relative(path: string): string
	return string.sub(path, #"docs/" + 1)
end

local function cell(text: string): string
	return (string.gsub(text, "|", "\\|"))
end

local ENGLISH: Language = {
	title = "Document Registry",
	intro = {
		"Every controlled document and record of EnterpriseEdition, generated from document frontmatter by `scripts/gen_registry.luau`.",
		"Editing this file by hand violates EE-POL-0001, and checkpatch will notice.",
	},
	switch = "[한국어](REGISTRY.ko.md)",
	summary = "Summary",
	summaryHeader = "| Category | Documents |",
	total = "Total",
	empty = "No documents are registered.",
	controlledHeader = "| ID | Title | Version | Status | Classification | Owner | Parent |",
	recordHeader = "| ID | Title | Version | Status | Classification | Owner |",
	label = function(kind: Schema.Kind): string
		return kind.label
	end,
	status = function(status: string): string
		return status
	end,
	classification = function(classification: string): string
		return classification
	end,
	documentTitle = function(document: Documents.Document): string
		return document.title
	end,
	link = function(document: Documents.Document): string
		return relative(document.path)
	end,
	lineage = "Lineage",
	lineageIntro = "Every controlled document, beside the document it cites as its parent. A dashed card is a reserved number, and a bold one a document in review.",
	lineageAlt = "Lineage of the controlled documents",
	lineageImage = "../" .. Schema.LINEAGE_PATH,
	lineagePath = Schema.LINEAGE_PATH,
	textVersion = "Text version",
	reserved = "reserved",
	inReview = "in review",
}

local KOREAN: Language = {
	title = "문서 대장",
	intro = {
		"EnterpriseEdition 의 모든 통제 문서와 기록. `scripts/gen_registry.luau` 가 문서 frontmatter 로부터 생성한다.",
		"이 파일을 손으로 고치는 것은 EE-POL-0001 위반이며, checkpatch 가 알아챈다.",
	},
	switch = "[English](REGISTRY.md)",
	summary = "요약",
	summaryHeader = "| 구분 | 문서 수 |",
	total = "합계",
	empty = "등재된 문서가 없다.",
	controlledHeader = "| ID | 제목 | 버전 | 상태 | 보안 등급 | 소유 부서 | 상위 문서 |",
	recordHeader = "| ID | 제목 | 버전 | 상태 | 보안 등급 | 소유 부서 |",
	label = function(kind: Schema.Kind): string
		return kind.labelKo
	end,
	status = function(status: string): string
		return STATUS_KO[status] or status
	end,
	classification = function(classification: string): string
		return CLASSIFICATION_KO[classification] or classification
	end,
	documentTitle = function(document: Documents.Document): string
		local translation = document.translation
		return if translation and translation.title then translation.title else document.title
	end,
	link = function(document: Documents.Document): string
		local translation = document.translation
		return relative(if translation then translation.path else document.path)
	end,
	lineage = "계보",
	lineageIntro = "모든 통제 문서를, 그 문서가 상위 문서로 인용하는 문서 옆에 그린다. 점선 카드는 확보만 해 둔 번호이고, 굵은 카드는 검토 중인 문서이다.",
	lineageAlt = "통제 문서의 계보",
	lineageImage = "../" .. Schema.LINEAGE_KO_PATH,
	lineagePath = Schema.LINEAGE_KO_PATH,
	textVersion = "텍스트판",
	reserved = "예약",
	inReview = "검토 중",
}

-- The header of every diagram, as the comment lines that precede its root element (EE-STD-0004).
local DIAGRAM_HEADER = {
	"SPDX-License-Identifier: MIT",
	"SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors",
	"GENERATED FILE. DO NOT EDIT. Regenerate with: lune run scripts/gen_registry",
}

-- The controlled documents as a tree, each beside the parent it cites. A reserved number is dashed, and a
-- document in review bold.
local function lineageNodes(index: Documents.Index, language: Language): { TreeDiagram.Node }
	local nodes: { TreeDiagram.Node } = {}
	for _, document in index.documents do
		if document.kind.controlled then
			local style: TreeDiagram.Style = if document.status == "Draft"
				then "dashed"
				elseif document.status == "In Review" then "bold"
				else "solid"
			table.insert(nodes, {
				id = document.id,
				lines = { document.id, language.documentTitle(document) },
				parent = document.parent,
				style = style,
			})
		end
	end
	return nodes
end

local function lineageSection(index: Documents.Index, language: Language): { string }
	local nodes = lineageNodes(index, language)
	if #nodes == 0 then
		return {}
	end
	local text = TreeDiagram.text(nodes, function(node: TreeDiagram.Node): string
		local label = table.concat(node.lines, " ")
		if node.style == "dashed" then
			return label .. " (" .. language.reserved .. ")"
		elseif node.style == "bold" then
			return label .. " (" .. language.inReview .. ")"
		end
		return label
	end)
	return {
		"",
		"## " .. language.lineage,
		"",
		language.lineageIntro,
		"",
		string.format("![%s](%s)", language.lineageAlt, language.lineageImage),
		"",
		"<details>",
		"<summary>" .. language.textVersion .. "</summary>",
		"",
		"```text",
		(string.gsub(text, "\n$", "")),
		"```",
		"",
		"</details>",
	}
end

local function groupByKind(index: Documents.Index): { Group }
	local groups: { Group } = {}
	for _, document in index.documents do
		local last = groups[#groups]
		if last and last.kind == document.kind then
			table.insert(last.documents, document)
		else
			table.insert(groups, { kind = document.kind, documents = { document } })
		end
	end
	return groups
end

local function row(document: Documents.Document, language: Language): string
	local version, status, classification = document.version, document.status, document.classification
	local columns = {
		string.format("[%s](%s)", document.id, language.link(document)),
		cell(language.documentTitle(document)),
		if version then Semver.format(version) else NONE,
		if status then language.status(status) else NONE,
		if classification then language.classification(classification) else NONE,
		cell(document.owner or NONE),
	}
	if document.kind.controlled then
		local parent, revision = document.parent, document.parentRevision
		table.insert(columns, if parent and revision then parent .. "@" .. Semver.formatRevision(revision) else NONE)
	end
	return "| " .. table.concat(columns, " | ") .. " |"
end

local function render(index: Documents.Index, language: Language): string
	local lines = table.clone(HEADER)
	table.insert(lines, "# " .. language.title)
	table.insert(lines, "")
	for _, line in language.intro do
		table.insert(lines, line)
	end
	table.insert(lines, "")
	table.insert(lines, language.switch)
	table.insert(lines, "")
	table.insert(lines, "## " .. language.summary)
	table.insert(lines, "")

	local groups = groupByKind(index)
	if #groups == 0 then
		table.insert(lines, language.empty)
	else
		table.insert(lines, language.summaryHeader)
		table.insert(lines, "|---|---:|")
		for _, group in groups do
			table.insert(lines, string.format("| %s | %d |", language.label(group.kind), #group.documents))
		end
		table.insert(lines, string.format("| **%s** | **%d** |", language.total, #index.documents))
	end
	for _, line in lineageSection(index, language) do
		table.insert(lines, line)
	end

	for _, group in groups do
		table.insert(lines, "")
		table.insert(lines, "## " .. language.label(group.kind))
		table.insert(lines, "")
		if group.kind.controlled then
			table.insert(lines, language.controlledHeader)
			table.insert(lines, "|---|---|---|---|---|---|---|")
		else
			table.insert(lines, language.recordHeader)
			table.insert(lines, "|---|---|---|---|---|---|")
		end
		for _, document in group.documents do
			table.insert(lines, row(document, language))
		end
	end

	table.insert(lines, "")
	return table.concat(lines, "\n")
end

local Registry = {}

Registry.RULES = RULES

-- Korean labels for every status of every kind. EE-POL-0002 lists the same terms.
Registry.STATUS_KO = STATUS_KO

-- Returns the English and the Korean registry.
function Registry.render(index: Documents.Index): (string, string)
	return render(index, ENGLISH), render(index, KOREAN)
end

export type Diagram = {
	path: string,
	content: string,
}

-- The diagrams the registry draws beside itself, in English and in Korean (CR-0021).
function Registry.diagrams(index: Documents.Index): { Diagram }
	local diagrams: { Diagram } = {}
	for _, language in { ENGLISH, KOREAN } do
		local nodes = lineageNodes(index, language)
		if #nodes > 0 then
			table.insert(diagrams, {
				path = language.lineagePath,
				content = TreeDiagram.svg(nodes, { header = DIAGRAM_HEADER, title = language.lineageAlt }),
			})
		end
	end
	return diagrams
end

function Registry.check(snapshot: Snapshot.Snapshot, index: Documents.Index, report: Report.Report)
	local english, korean = Registry.render(index)
	for _, diagram in Registry.diagrams(index) do
		local actual = snapshot.files[diagram.path]
		if actual ~= diagram.content then
			Report.add(
				report,
				RULES.REGISTRY_OUT_OF_DATE,
				diagram.path,
				nil,
				if actual == nil
					then "the diagram of the registry is missing; run lune run scripts/gen_registry"
					else "the diagram of the registry does not match the documents; run lune run scripts/gen_registry"
			)
		end
	end
	local function compare(path: string, expected: string)
		local actual = snapshot.files[path]
		if actual == nil then
			Report.add(
				report,
				RULES.REGISTRY_OUT_OF_DATE,
				path,
				nil,
				"the registry is missing; run lune run scripts/gen_registry"
			)
		elseif actual ~= expected then
			Report.add(
				report,
				RULES.REGISTRY_OUT_OF_DATE,
				path,
				nil,
				"the registry does not match the documents; run lune run scripts/gen_registry"
			)
		end
	end
	compare(Schema.REGISTRY_PATH, english)
	compare(Schema.REGISTRY_KO_PATH, korean)
end

return Registry
