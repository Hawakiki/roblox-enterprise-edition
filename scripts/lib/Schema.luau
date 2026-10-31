-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The document schema: document kinds, their identifiers, folders and hierarchy levels,
	and the frontmatter fields every document carries.
	문서 스키마: 문서 종류별 식별자, 폴더, 위계, 그리고 모든 문서가 갖는 frontmatter 필드.
]]

export type Kind = {
	code: string,
	-- Controlled documents form the hierarchy (charter > policy > standard > ...).
	-- Records (RFC, ADR, CR) sit outside it and take no parent.
	controlled: boolean,
	folder: string,
	level: number,
	statuses: { string },
	label: string,
	labelKo: string,
	-- The template whose form a record of this kind follows section by section. Controlled documents vary.
	form: string?,
}

local CONTROLLED_STATUSES = { "Draft", "In Review", "Approved", "Superseded", "Deprecated" }

local function controlled(code: string, folder: string, level: number, label: string, labelKo: string): Kind
	return {
		code = code,
		controlled = true,
		folder = folder,
		level = level,
		statuses = CONTROLLED_STATUSES,
		label = label,
		labelKo = labelKo,
		form = nil,
	}
end

local function record(
	code: string,
	folder: string,
	statuses: { string },
	label: string,
	labelKo: string,
	form: string
): Kind
	return {
		code = code,
		controlled = false,
		folder = folder,
		level = math.huge,
		statuses = statuses,
		label = label,
		labelKo = labelKo,
		form = form,
	}
end

-- In registry order / 문서 대장에 실리는 순서
local KINDS: { Kind } = {
	controlled("CHR", "docs/00-charter", 1, "Charter", "헌장"),
	controlled("POL", "docs/01-governance", 2, "Policies", "정책"),
	controlled("ORG", "docs/02-organization", 2, "Organization", "조직"),
	controlled("STD", "docs/03-standards", 3, "Standards", "표준"),
	controlled("SOP", "docs/04-procedures", 4, "Standard Operating Procedures", "표준 운영 절차"),
	controlled("OPS", "docs/06-operations", 4, "Operations", "운영"),
	controlled("GDL", "docs/05-guidelines", 5, "Guidelines", "가이드라인"),
	controlled("TPL", "docs/templates", 6, "Templates", "양식"),
	record(
		"RFC",
		"docs/rfc",
		{ "Draft", "Discussion", "Accepted", "Rejected", "Withdrawn" },
		"Requests for Comments",
		"의견 요청서",
		"EE-TPL-0003"
	),
	record(
		"ADR",
		"docs/adr",
		{ "Proposed", "Accepted", "Superseded", "Deprecated" },
		"Architecture Decision Records",
		"아키텍처 결정 기록",
		"EE-TPL-0004"
	),
	record(
		"CR",
		"docs/records/change-requests",
		{ "Draft", "Submitted", "Approved", "Rejected", "Implemented", "Closed" },
		"Change Requests",
		"변경 요청",
		"EE-TPL-0002"
	),
	record(
		"APR",
		"docs/records/approval-requests",
		{ "Draft", "Submitted", "Approved", "Rejected", "Withdrawn" },
		"Approval Requests",
		"품의서",
		"EE-TPL-0005"
	),
	record(
		"STM",
		"docs/records/statements",
		{ "Draft", "Submitted", "Accepted", "Returned" },
		"Statements of Circumstances",
		"경위서",
		"EE-TPL-0006"
	),
	record("MIN", "docs/records/minutes", { "Draft", "Approved" }, "Meeting Minutes", "회의록", "EE-TPL-0007"),
}

local Schema = {}

Schema.kinds = KINDS

-- The root of the hierarchy and the only controlled document without a parent.
Schema.ROOT_DOCUMENT = "EE-CHR-0001"

Schema.CLASSIFICATIONS = { "Public", "Internal", "Confidential", "Restricted" }

-- Metadata lives in the authoritative English document only.
Schema.FIELDS = { "id", "title", "version", "status", "classification", "owner", "parent" }
Schema.REQUIRED_FIELDS = { "id", "title", "version", "status", "classification", "owner" }
Schema.TRANSLATION_FIELDS = { "id", "title", "translation-of" }

-- Generated from frontmatter, never edited by hand, and not documents themselves.
Schema.REGISTRY_PATH = "docs/REGISTRY.md"
Schema.REGISTRY_KO_PATH = "docs/REGISTRY.ko.md"

-- Images that the registry draws beside itself. They are not documents, so they live outside docs/ (CR-0021).
-- 문서 대장이 함께 그리는 이미지. 문서가 아니므로 docs/ 밖에 둔다(CR-0021).
Schema.DIAGRAMS_FOLDER = "diagrams"
Schema.LINEAGE_PATH = "diagrams/lineage.svg"
Schema.LINEAGE_KO_PATH = "diagrams/lineage.ko.svg"

function Schema.kindOf(id: string): Kind?
	local code = string.match(id, "^EE%-(%u%u%u)%-%d%d%d%d$")
	if code then
		for _, kind in KINDS do
			if kind.controlled and kind.code == code then
				return kind
			end
		end
		return nil
	end
	code = string.match(id, "^(%u+)%-%d%d%d%d$")
	if code then
		for _, kind in KINDS do
			if not kind.controlled and kind.code == code then
				return kind
			end
		end
	end
	return nil
end

function Schema.order(kind: Kind): number
	return table.find(KINDS, kind) or math.huge
end

return Schema
