-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	A rule that checkpatch enforces: its code, its severity, the document that mandates it and a summary.
	Every check declares its rules beside the code that reports them, and reports a rule, not its code,
	so that a misspelt rule is a type error rather than a crash at the moment it fires (CR-0009).
	checkpatch 가 강제하는 규칙: 코드, 심각도, 근거 문서, 요약. 모든 검사는 규칙을 보고하는 코드 옆에 선언하고,
	코드 문자열이 아니라 규칙을 보고하므로, 철자가 틀린 규칙은 발생하는 순간의 오류가 아니라 타입 오류가 된다(CR-0009).
]]

export type Severity = "ERROR" | "WARNING"

export type Rule = {
	code: string,
	severity: Severity,
	standard: string,
	summary: string,
}

local Rule = {}

function Rule.new(code: string, severity: Severity, standard: string, summary: string): Rule
	return { code = code, severity = severity, standard = standard, summary = summary }
end

return Rule
