-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Keeps the rule catalog and the documents in agreement. Once the document that mandates a rule exists,
	both of its language versions must cite the rule by its code.
	규칙 목록과 문서를 일치시킨다. 규칙의 근거 문서가 존재하면, 그 문서의 두 언어판 모두 규칙 코드를 인용해야 한다.
]]

local Documents = require("./Documents")
local Report = require("./Report")
local Rule = require("./Rule")

-- The rules this check reports, declared beside it (CR-0009). / 이 검사가 보고하는 규칙. 검사 옆에 선언한다(CR-0009).
local RULES = {
	UNDOCUMENTED_RULE = Rule.new(
		"UNDOCUMENTED_RULE",
		"ERROR",
		"EE-POL-0001",
		"Every rule must be cited, in both languages, by the document that mandates it."
	),
}

-- Whole codes only: MISSING_UTF8_BOM does not cite UTF8_BOM.
local function cites(body: { string }, code: string): boolean
	local pattern = "%f[%w_]" .. code .. "%f[^%w_]"
	for _, line in body do
		if string.find(line, pattern) then
			return true
		end
	end
	return false
end

local Coverage = {}

Coverage.RULES = RULES

-- Takes every rule of the catalogue, which cannot be required here: the catalogue requires this check.
function Coverage.check(index: Documents.Index, rules: { Rule.Rule }, report: Report.Report)
	for _, rule in rules do
		local document = index.byId[rule.standard]
		if document == nil then
			continue
		end
		if not cites(document.body, rule.code) then
			Report.add(
				report,
				RULES.UNDOCUMENTED_RULE,
				document.path,
				nil,
				string.format("%s is enforced under %s, which does not cite it", rule.code, rule.standard)
			)
		end
		local translation = document.translation
		if translation and not cites(translation.body, rule.code) then
			Report.add(
				report,
				RULES.UNDOCUMENTED_RULE,
				translation.path,
				nil,
				string.format("%s is enforced under %s, whose translation does not cite it", rule.code, rule.standard)
			)
		end
	end
end

return Coverage
