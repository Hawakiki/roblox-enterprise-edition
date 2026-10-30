-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The rule catalog. Every violation checkpatch can report is registered here,
	with its severity and the standard that mandates it.
	규칙 목록. checkpatch 가 보고하는 모든 위반은 여기에 심각도와 근거 표준이 등록되어 있다.
]]

export type Severity = "ERROR" | "WARNING"

export type Rule = {
	code: string,
	severity: Severity,
	standard: string,
	summary: string,
}

local RULES: { Rule } = {
	-- File hygiene / 파일 위생
	{
		code = "INVALID_UTF8",
		severity = "ERROR",
		standard = "EE-STD-0009",
		summary = "Text files must be valid UTF-8.",
	},
	{
		code = "UTF8_BOM",
		severity = "ERROR",
		standard = "EE-STD-0009",
		summary = "Text files must not start with a byte order mark.",
	},
	{
		code = "MISSING_UTF8_BOM",
		severity = "ERROR",
		standard = "EE-STD-0009",
		summary = "PowerShell scripts containing non-ASCII text must start with a UTF-8 byte order mark.",
	},
	{
		code = "CRLF_LINE_ENDING",
		severity = "ERROR",
		standard = "EE-STD-0009",
		summary = "Line endings must be LF.",
	},
	{
		code = "TRAILING_WHITESPACE",
		severity = "ERROR",
		standard = "EE-STD-0009",
		summary = "Lines must not end with whitespace.",
	},
	{
		code = "MISSING_FINAL_NEWLINE",
		severity = "ERROR",
		standard = "EE-STD-0009",
		summary = "Text files must end with a newline.",
	},

	-- Toolchain / 툴체인
	{
		code = "TOOLCHAIN_VERSION_MISMATCH",
		severity = "ERROR",
		standard = "EE-STD-0001",
		summary = "Tool versions referenced by configuration must match rokit.toml.",
	},

	-- File headers / 파일 헤더
	{
		code = "MISSING_STRICT_MODE",
		severity = "ERROR",
		standard = "EE-STD-0001",
		summary = "Every Luau file declares --!strict before any code.",
	},
	{
		code = "MISSING_SPDX_HEADER",
		severity = "ERROR",
		standard = "EE-STD-0004",
		summary = "Every file that can carry a comment opens with an MIT SPDX header.",
	},

	-- Document control / 문서 통제
	{
		code = "MISSING_FRONTMATTER",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Documents must start with a YAML frontmatter block.",
	},
	{
		code = "INVALID_FRONTMATTER",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Frontmatter must be a closed block containing a YAML mapping.",
	},
	{
		code = "MISSING_FIELD",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Required frontmatter fields must be present.",
	},
	{
		code = "UNKNOWN_FIELD",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Frontmatter must not contain fields outside the schema.",
	},
	{
		code = "INVALID_FIELD_VALUE",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Frontmatter values must match the schema.",
	},
	{
		code = "UNKNOWN_DOCUMENT_TYPE",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Document identifiers must belong to a registered document kind.",
	},
	{
		code = "DUPLICATE_DOCUMENT_ID",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Document identifiers must be unique.",
	},
	{
		code = "MISPLACED_DOCUMENT",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Documents must live in the folder assigned to their kind.",
	},
	{
		code = "FILENAME_MISMATCH",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "File names must be '<id>-<slug>.md'.",
	},
	{
		code = "TITLE_HEADING_MISMATCH",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "The first heading must repeat the frontmatter title.",
	},
	{
		code = "VERSION_STATUS_MISMATCH",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Drafts are versioned 0.x.y; approved, superseded and deprecated documents 1.0.0 or later.",
	},
	{
		code = "MISSING_PARENT",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Controlled documents must cite a parent document.",
	},
	{
		code = "UNEXPECTED_PARENT",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "The charter and records must not cite a parent.",
	},
	{
		code = "UNKNOWN_PARENT",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Cited parent documents must exist.",
	},
	{
		code = "PARENT_HIERARCHY_VIOLATION",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "A parent must be a controlled document at the same or a higher level.",
	},
	{
		code = "STALE_PARENT",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Parent citations must match the parent's current MAJOR.MINOR revision.",
	},
	{
		code = "PARENT_CYCLE",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Parent chains must not loop.",
	},
	{
		code = "DANGLING_REFERENCE",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Referenced documents must exist.",
	},
	{
		code = "STRAY_FILE",
		severity = "WARNING",
		standard = "EE-POL-0001",
		summary = "Only Markdown documents belong under docs/.",
	},
	{
		code = "REGISTRY_OUT_OF_DATE",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "The document registry must match the output of scripts/gen_registry.luau.",
	},
	{
		code = "UNDOCUMENTED_RULE",
		severity = "ERROR",
		standard = "EE-POL-0001",
		summary = "Every rule must be cited, in both languages, by the document that mandates it.",
	},

	-- Entrance files / 입구 파일
	{
		code = "DANGLING_ENTRY_REFERENCE",
		severity = "ERROR",
		standard = "EE-POL-0006",
		summary = "Entrance files at the repository root cite only documents that exist.",
	},
	{
		code = "MISSING_AGENTS_IMPORT",
		severity = "ERROR",
		standard = "EE-POL-0006",
		summary = "CLAUDE.md imports AGENTS.md with a line of its own, outside code.",
	},
	{
		code = "ONBOARDING_TOO_LONG",
		severity = "WARNING",
		standard = "EE-POL-0006",
		summary = "AGENTS.md and CLAUDE.md together stay within 200 lines.",
	},

	-- Translation / 번역
	{
		code = "MISSING_TRANSLATION",
		severity = "ERROR",
		standard = "EE-POL-0002",
		summary = "Every document must have a Korean translation.",
	},
	{
		code = "ORPHAN_TRANSLATION",
		severity = "ERROR",
		standard = "EE-POL-0002",
		summary = "Every translation must have an authoritative English document.",
	},
	{
		code = "TRANSLATION_ID_MISMATCH",
		severity = "ERROR",
		standard = "EE-POL-0002",
		summary = "A translation must carry the id of its English document.",
	},
	{
		code = "TRANSLATION_EXTRA_FIELD",
		severity = "ERROR",
		standard = "EE-POL-0002",
		summary = "Translations carry only id, title and translation-of; metadata lives in the English document.",
	},
	{
		code = "STALE_TRANSLATION",
		severity = "ERROR",
		standard = "EE-POL-0002",
		summary = "translation-of must match the version of the English document.",
	},
	{
		code = "TRANSLATION_NOT_KOREAN",
		severity = "WARNING",
		standard = "EE-POL-0002",
		summary = "Korean translations should contain Korean text.",
	},

	-- Commit messages / 커밋 메시지
	{
		code = "COMMIT_SUBJECT_FORMAT",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Subjects must be '<type>(<scope>): <description>'.",
	},
	{
		code = "COMMIT_SUBJECT_TOO_LONG",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Subjects must fit in 72 columns.",
	},
	{
		code = "COMMIT_SUBJECT_NOT_ENGLISH",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Subjects must be written in English.",
	},
	{
		code = "COMMIT_SUBJECT_STYLE",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Descriptions are not in sentence case and do not end with a period.",
	},
	{
		code = "COMMIT_MISSING_BLANK_LINE",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "The subject must be followed by a blank line.",
	},
	{
		code = "COMMIT_MISSING_BODY_SECTION",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Bodies must contain an [EN] section followed by a [KO] section.",
	},
	{
		code = "COMMIT_SECTION_LANGUAGE",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "The [KO] section must be written in Korean.",
	},
	{
		code = "COMMIT_BODY_LINE_TOO_LONG",
		severity = "WARNING",
		standard = "EE-STD-0007",
		summary = "Body lines should fit in 72 columns.",
	},
	{
		code = "COMMIT_UNKNOWN_TRAILER",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Only registered trailers are allowed.",
	},
	{
		code = "COMMIT_MALFORMED_TRAILER",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Trailer values must match their format.",
	},
	{
		code = "COMMIT_MISSING_SIGNOFF",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Commits must carry a Signed-off-by trailer.",
	},
	{
		code = "COMMIT_SIGNOFF_MISMATCH",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "The commit author must sign off.",
	},
	{
		code = "COMMIT_MISSING_CHANGE_REQUEST",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Commits must cite a change request.",
	},
	{
		code = "COMMIT_UNKNOWN_CHANGE_REQUEST",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Cited change requests must be filed.",
	},
	{
		code = "COMMIT_CHANGE_REQUEST_CLOSED",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Rejected or closed change requests accept no commits.",
	},
	{
		code = "COMMIT_CHANGE_REQUEST_NOT_APPROVED",
		severity = "WARNING",
		standard = "EE-STD-0007",
		summary = "Commits should cite an approved change request.",
	},
	{
		code = "COMMIT_MISSING_APPROVAL",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Merge commits must carry an Approved-by trailer.",
	},

	-- Branches / 브랜치
	{
		code = "BRANCH_NAME_FORMAT",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Branch names must follow git-flow naming.",
	},
	{
		code = "BRANCH_CHANGE_REQUEST_MISMATCH",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "Commits on a feature branch must cite the change request of the branch.",
	},
	{
		code = "DIRECT_COMMIT_TO_PROTECTED_BRANCH",
		severity = "ERROR",
		standard = "EE-STD-0007",
		summary = "main and develop accept merge commits only.",
	},
}

local byCode: { [string]: Rule } = {}
for _, rule in RULES do
	assert(byCode[rule.code] == nil, "duplicate rule " .. rule.code)
	byCode[rule.code] = rule
end

local Catalog = {}

Catalog.rules = RULES

function Catalog.get(code: string): Rule
	local rule = byCode[code]
	if rule == nil then
		error("unregistered rule " .. code, 2)
	end
	return rule
end

return Catalog
