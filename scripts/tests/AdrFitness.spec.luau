-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The fitness test of ADR-0003, which superseded ADR-0002 and ADR-0001: holds the facts that the decision rests on
	to the luau-lsp that rokit.toml pins, so that the record is revisited when a newer luau-lsp changes one of them,
	rather than left to rot (CR-0020, CR-0023, CR-0025). The old solver is run only as a witness that a fixture
	holds the mistake it is meant to hold.
	ADR-0002 와 ADR-0001 을 대체한 ADR-0003 의 적합도 테스트: 그 결정이 기대는 사실을 rokit.toml 이 고정한
	luau-lsp 에 대조하여, 새 luau-lsp 가 그중 하나를 바꾸면 기록을 내버려 두지 않고 다시 검토하게 한다
	(CR-0020, CR-0023, CR-0025). 옛 솔버는 예제가 담아야 할 실수를 담고 있음을 증언하는 데에만 돌린다.
]]

local fs = require("@lune/fs")
local process = require("@lune/process")

local AdrFitnessFixtures = require("./AdrFitnessFixtures")
local Assert = require("./Assert")
local Git = require("../lib/Git")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local root = assert(Git.root(), "the tests run inside the repository")

-- Ignored by git, so that the invalid fixtures never become .luau files of the repository (EE-STD-0001 §4.1).
local FOLDER = "build/solver-fixtures"

type Solver = "old" | "new"

type Fixture = {
	name: string,
	source: string,
	-- What a solver reports in the fixture, as in "the new solver now reports <subject>".
	subject: string,
	-- What a change in the fixture's result means for ADR-0003.
	consequence: string,
}

type Expectation = {
	fixture: Fixture,
	solver: Solver,
	reports: boolean,
	-- The number of errors expected, when it is part of the fact.
	errors: number?,
	-- The old solver, run only to bear out that the fixture holds its mistakes.
	witness: boolean?,
}

local REVISIT = "revisit ADR-0003"
local PROVES_NOTHING = "luau-lsp did not check the fixtures, and the fitness test of ADR-0003 proves nothing"
local WITNESS_LOST = "the old solver, kept only as a witness, no longer bears the fixture out: the fixture or luau-lsp "
	.. "has changed, and the fitness test of ADR-0003 proves nothing about it"

local BARE_DRIFT: Fixture = {
	name = "BareDrift",
	source = AdrFitnessFixtures.BareDrift,
	subject = "drift behind an entry of _implements that only names its method",
	consequence = REVISIT .. ": the wrappers may no longer be needed",
}
local WRAPPED_DRIFT: Fixture = {
	name = "WrappedDrift",
	source = AdrFitnessFixtures.WrappedDrift,
	subject = "drift behind a wrapper in _implements",
	consequence = REVISIT .. ": a method that drifts from its contract may go unreported",
}
local MISSING_METHOD: Fixture = {
	name = "MissingMethod",
	source = AdrFitnessFixtures.MissingMethod,
	subject = "a class that lacks a method of its contract, at its constructor",
	consequence = REVISIT .. ": a class that lacks a method may go unreported",
}
local CONFORMING: Fixture = {
	name = "Conforming",
	source = AdrFitnessFixtures.Conforming,
	subject = "an error in the pattern as src/ writes it",
	consequence = REVISIT,
}
local GENERIC_BODY: Fixture = {
	name = "GenericBody",
	source = AdrFitnessFixtures.GenericBody,
	subject = "a mistake that involves the type parameter in the body of a generic function",
	consequence = REVISIT .. ": the loss it accepts may be recovered",
}
local BROKEN: Fixture = {
	name = "Broken",
	source = AdrFitnessFixtures.Broken,
	subject = "an obvious type error",
	consequence = PROVES_NOTHING,
}

-- The facts of ADR-0003 under luau-lsp 1.69.0. The drift fixtures hold three drifted methods, and the generic
-- fixture five mistakes, which the old solver reports one by one.
local EXPECTATIONS: { Expectation } = {
	{ fixture = BARE_DRIFT, solver = "new", reports = false },
	{ fixture = WRAPPED_DRIFT, solver = "new", reports = true, errors = 3 },
	{ fixture = MISSING_METHOD, solver = "new", reports = true, errors = 1 },
	{ fixture = CONFORMING, solver = "new", reports = false },
	{ fixture = GENERIC_BODY, solver = "new", reports = false },
	{ fixture = GENERIC_BODY, solver = "old", reports = true, errors = 5, witness = true },
	{ fixture = BROKEN, solver = "new", reports = true },
	{ fixture = BROKEN, solver = "old", reports = true, witness = true },
}

local FLAGS: { [Solver]: string } = {
	old = "--flag:LuauSolverV2=false",
	new = "--flag:LuauSolverV2=true",
}

type Analysis = {
	code: number,
	output: string,
	-- Lines that report a type error in the fixture itself.
	errors: number,
}

-- Writes a fixture under build/, creating the folder on a fresh checkout and overwriting what an earlier run
-- wrote. Nothing is deleted. Returns the path relative to the root of the repository.
local function write(fixture: Fixture): string
	local path = FOLDER .. "/" .. fixture.name .. ".luau"
	local written, problem = pcall(function()
		if not fs.isDir(root .. "/" .. FOLDER) then
			fs.writeDir(root .. "/" .. FOLDER)
		end
		fs.writeFile(root .. "/" .. path, fixture.source)
	end)
	if not written then
		error(string.format("ADR-0003: %s could not be written (%s): %s", path, tostring(problem), PROVES_NOTHING), 0)
	end
	return path
end

local function analyse(path: string, solver: Solver): Analysis
	local ran, result = pcall(function(): process.ExecResult
		return process.exec("luau-lsp", { "analyze", "--platform=standard", FLAGS[solver], path }, { cwd = root })
	end)
	if not ran then
		error(string.format("ADR-0003: luau-lsp could not be run (%s): %s", tostring(result), PROVES_NOTHING), 0)
	end
	local output = result.stdout .. result.stderr
	-- luau-lsp names the file as it was given: <path>(<line>,<column>): TypeError: <message>
	local prefix = path .. "("
	local errors = 0
	for _, line in string.split(output, "\n") do
		local rest = if string.sub(line, 1, #prefix) == prefix then string.sub(line, #prefix + 1) else ""
		if string.find(rest, "^%d+,%d+%): TypeError") then
			errors += 1
		end
	end
	return { code = result.code, output = output, errors = errors }
end

for _, expectation in EXPECTATIONS do
	local fixture = expectation.fixture
	local solver: Solver = expectation.solver
	local verb = if expectation.reports then "reports" else "accepts"
	local role = if expectation.witness then ", as a witness," else ""
	local consequence = if expectation.witness then WITNESS_LOST else fixture.consequence
	case(string.format("the %s solver%s %s %s", solver, role, verb, fixture.name), function()
		local path = write(fixture)
		local analysis = analyse(path, solver)
		-- A run is judged by its exit code and its output together: luau-lsp also exits 1 for a path that does not
		-- exist, without naming a type error (CR-0015).
		local reported = analysis.code ~= 0 and analysis.errors > 0
		local clean = analysis.code == 0 and analysis.errors == 0
		local message: string? = nil
		if not reported and not clean then
			message = string.format(
				"ADR-0003: luau-lsp exited with %d under the %s solver and named %d type errors in %s: %s",
				analysis.code,
				solver,
				analysis.errors,
				path,
				PROVES_NOTHING
			)
		elseif reported and not expectation.reports then
			message = string.format(
				"ADR-0003: the %s solver now reports %s (%s): %s",
				solver,
				fixture.subject,
				path,
				consequence
			)
		elseif clean and expectation.reports then
			message = string.format(
				"ADR-0003: the %s solver no longer reports %s (%s): %s",
				solver,
				fixture.subject,
				path,
				consequence
			)
		elseif reported and expectation.errors and analysis.errors ~= expectation.errors then
			message = string.format(
				"ADR-0003: the %s solver reports %d errors, not %d, for %s (%s): %s",
				solver,
				analysis.errors,
				expectation.errors :: number,
				fixture.subject,
				path,
				consequence
			)
		end
		if message then
			error(string.format("%s\n    luau-lsp exited with %d:\n%s", message, analysis.code, analysis.output), 0)
		end
	end)
end

return { name = "AdrFitness", cases = cases } :: Assert.Suite
