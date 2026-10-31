-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Records follow the form of their kind: every level-two section of the form, under the same name.
	Numbers may differ and further sections are allowed; placeholder headings of the form are not required.
	기록은 해당 종류 양식의 2단계 절을 모두 같은 이름으로 갖춘다.
	번호는 달라도 되고 절을 더해도 되며, 양식의 자리 표시자 제목은 요구하지 않는다.
]]

local Documents = require("./Documents")
local Report = require("./Report")
local Rule = require("./Rule")

-- The rules this check reports, declared beside it (CR-0009). / 이 검사가 보고하는 규칙. 검사 옆에 선언한다(CR-0009).
local RULES = {
	TEMPLATE_SECTION_MISSING = Rule.new(
		"TEMPLATE_SECTION_MISSING",
		"ERROR",
		"EE-POL-0001",
		"A record contains every section of the form for its kind."
	),
}

local function sectionName(heading: string): string
	return (string.gsub(heading, "^%d+%.%s+", ""))
end

-- The level-two headings inside the form block of a template.
local function formSections(body: { string }): { string }
	local sections = {}
	local inForm = false
	for _, line in body do
		if not inForm then
			inForm = string.match(line, "^````markdown%s*$") ~= nil
		elseif string.match(line, "^````%s*$") then
			break
		else
			local heading = string.match(line, "^## (.+)$")
			if heading and not string.find(heading, "<", 1, true) then
				table.insert(sections, sectionName(heading))
			end
		end
	end
	return sections
end

-- The level-two headings of a document, outside code blocks.
local function presentSections(body: { string }): { [string]: boolean }
	local present: { [string]: boolean } = {}
	local inCode = false
	for _, line in body do
		if string.match(line, "^```") then
			inCode = not inCode
		elseif not inCode then
			local heading = string.match(line, "^## (.+)$")
			if heading then
				present[sectionName(heading)] = true
			end
		end
	end
	return present
end

local function checkAgainst(path: string, body: { string }, required: { string }, form: string, report: Report.Report)
	local present = presentSections(body)
	for _, name in required do
		if not present[name] then
			Report.add(
				report,
				RULES.TEMPLATE_SECTION_MISSING,
				path,
				nil,
				string.format("the form in %s requires a section named '%s'", form, name)
			)
		end
	end
end

local Forms = {}

Forms.RULES = RULES

function Forms.check(index: Documents.Index, report: Report.Report)
	for _, document in index.documents do
		local form = document.kind.form
		local template = if form then index.byId[form] else nil
		-- Controlled documents have no form, and a form that has not been written yet requires nothing.
		if form == nil or template == nil then
			continue
		end
		checkAgainst(document.path, document.body, formSections(template.body), form, report)
		local translation, templateTranslation = document.translation, template.translation
		if translation and templateTranslation then
			checkAgainst(translation.path, translation.body, formSections(templateTranslation.body), form, report)
		end
	end
end

return Forms
