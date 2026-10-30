-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Runs checkpatch's own test suites: lune run scripts/tests/run
	checkpatch 자체 테스트를 돌린다: lune run scripts/tests/run
]]

local process = require("@lune/process")

local Assert = require("./Assert")

local suites: { Assert.Suite } = {
	require("./Hygiene.spec"),
	require("./Toolchain.spec"),
	require("./Headers.spec"),
	require("./Architecture.spec"),
	require("./Lexer.spec"),
	require("./ProhibitedApis.spec"),
	require("./DocComments.spec"),
	require("./Documents.spec"),
	require("./Coverage.spec"),
	require("./Forms.spec"),
	require("./Onboarding.spec"),
	require("./Registry.spec"),
	require("./CommitMessage.spec"),
}

local passed, failed = 0, 0
for _, suite in suites do
	for _, testCase in suite.cases do
		local ok, problem = pcall(function(): any
			testCase.run()
			return nil
		end)
		if ok then
			passed += 1
		else
			failed += 1
			print(string.format("FAIL %s: %s\n    %s", suite.name, testCase.name, tostring(problem)))
		end
	end
end

print(string.format("%s %d/%d passed", if failed == 0 then "PASS" else "FAIL", passed, passed + failed))
process.exit(if failed == 0 then 0 else 1)
