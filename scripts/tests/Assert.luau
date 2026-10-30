-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Assertions and suite types for checkpatch's own tests.
	checkpatch 자체 테스트용 단언과 스위트 타입.
]]

local Report = require("../lib/Report")

export type Case = {
	name: string,
	run: () -> (),
}

export type Suite = {
	name: string,
	cases: { Case },
}

local Assert = {}

-- The report must contain exactly the expected rule codes, no more and no fewer.
function Assert.codes(report: Report.Report, expected: { string })
	local sortedExpected = table.clone(expected)
	table.sort(sortedExpected)
	local actual = Report.codes(report)
	if table.concat(actual, ",") == table.concat(sortedExpected, ",") then
		return
	end
	local details = {}
	for _, violation in Report.sorted(report) do
		table.insert(details, "      " .. Report.format(violation))
	end
	error(
		string.format(
			"expected [%s] but got [%s]\n%s",
			table.concat(sortedExpected, ", "),
			table.concat(actual, ", "),
			table.concat(details, "\n")
		),
		0
	)
end

function Assert.equal(actual: any, expected: any, what: string)
	if actual ~= expected then
		error(string.format("%s: expected %s, got %s", what, tostring(expected), tostring(actual)), 0)
	end
end

return Assert
