-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The rule catalogue: an index of the rules that every check declares beside itself (CR-0009),
	in the order of the checks and, within a check, of their codes.
	규칙 목록. 각 검사가 자기 옆에 선언한 규칙을 모은 색인이다(CR-0009). 검사의 순서대로, 검사 안에서는 코드 순으로 둔다.
]]

local Architecture = require("./Architecture")
local CommitMessage = require("./CommitMessage")
local Coverage = require("./Coverage")
local DocComments = require("./DocComments")
local Documents = require("./Documents")
local Forms = require("./Forms")
local Headers = require("./Headers")
local Hygiene = require("./Hygiene")
local NumericLiterals = require("./NumericLiterals")
local Onboarding = require("./Onboarding")
local ProhibitedApis = require("./ProhibitedApis")
local Registry = require("./Registry")
local Rule = require("./Rule")
local Toolchain = require("./Toolchain")

-- Files, then the Roblox code, then the documents, then the history.
local CHECKS: { { name: string, rules: any } } = {
	{ name = "Hygiene", rules = Hygiene.RULES },
	{ name = "Toolchain", rules = Toolchain.RULES },
	{ name = "Headers", rules = Headers.RULES },
	{ name = "Architecture", rules = Architecture.RULES },
	{ name = "ProhibitedApis", rules = ProhibitedApis.RULES },
	{ name = "NumericLiterals", rules = NumericLiterals.RULES },
	{ name = "DocComments", rules = DocComments.RULES },
	{ name = "Documents", rules = Documents.RULES },
	{ name = "Forms", rules = Forms.RULES },
	{ name = "Registry", rules = Registry.RULES },
	{ name = "Coverage", rules = Coverage.RULES },
	{ name = "Onboarding", rules = Onboarding.RULES },
	{ name = "CommitMessage", rules = CommitMessage.RULES },
}

local rules: { Rule.Rule } = {}
local byCode: { [string]: Rule.Rule } = {}
local checkOf: { [string]: string } = {}
for _, check in CHECKS do
	local own: { Rule.Rule } = {}
	for key, rule: Rule.Rule in check.rules do
		assert(key == rule.code, string.format("%s declares %s under the key %s", check.name, rule.code, tostring(key)))
		assert(byCode[rule.code] == nil, "duplicate rule " .. rule.code)
		byCode[rule.code] = rule
		checkOf[rule.code] = check.name
		table.insert(own, rule)
	end
	table.sort(own, function(a: Rule.Rule, b: Rule.Rule): boolean
		return a.code < b.code
	end)
	table.move(own, 1, #own, #rules + 1, rules)
end

local Catalog = {}

Catalog.rules = rules

function Catalog.get(code: string): Rule.Rule
	local rule = byCode[code]
	if rule == nil then
		error("unregistered rule " .. code, 2)
	end
	return rule
end

-- The name of the check that declares a rule, which is also the name of its module under scripts/lib.
function Catalog.checkOf(code: string): string
	return checkOf[Catalog.get(code).code]
end

return Catalog
