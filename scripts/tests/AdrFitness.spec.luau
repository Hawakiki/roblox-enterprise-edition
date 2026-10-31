-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The fitness test of ADR-0002, which superseded ADR-0001: holds the facts that the decision rests on to the
	luau-lsp that rokit.toml pins, so that the record is revisited when a newer luau-lsp changes one of them, rather
	than left to rot (CR-0020, CR-0023).
	ADR-0001 을 대체한 ADR-0002 의 적합도 테스트: 그 결정이 기대는 사실을 rokit.toml 이 고정한 luau-lsp 에
	대조하여, 새 luau-lsp 가 그중 하나를 바꾸면 기록을 내버려 두지 않고 다시 검토하게 한다(CR-0020, CR-0023).
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
	-- What a change in the fixture's result means for ADR-0002.
	consequence: string,
}

type Expectation = {
	fixture: Fixture,
	solver: Solver,
	reports: boolean,
	-- The number of errors expected, when it is part of the fact.
	errors: number?,
}

local REVISIT = "revisit ADR-0002"
local PROVES_NOTHING = "luau-lsp did not check the fixtures, and the fitness test of ADR-0002 proves nothing"

local BARE_DRIFT: Fixture = {
	name = "BareDrift",
	source = AdrFitnessFixtures.BareDrift,
	subject = "drift behind an entry of _implements that only names its method",
	consequence = REVISIT,
}
local WRAPPED_DRIFT: Fixture = {
	name = "WrappedDrift",
	source = AdrFitnessFixtures.WrappedDrift,
	subject = "drift behind a wrapper in _implements",
	consequence = REVISIT,
}
local NO_CAST: Fixture = {
	name = "NoCast",
	source = AdrFitnessFixtures.NoCast,
	subject = "an error in a class returned as its contract without the cast",
	consequence = REVISIT,
}
local CONFORMING: Fixture = {
	name = "Conforming",
	source = AdrFitnessFixtures.Conforming,
	subject = "an error in the pattern as src/ writes it",
	consequence = REVISIT,
}
local BROKEN: Fixture = {
	name = "Broken",
	source = AdrFitnessFixtures.Broken,
	subject = "an obvious type error",
	consequence = PROVES_NOTHING,
}

-- The facts of ADR-0002 under luau-lsp 1.69.0. Each drift fixture has three drifted methods: the old solver
-- reports each of them however they are declared, and the new solver only behind a wrapper.
local EXPECTATIONS: { Expectation } = {
	{ fixture = BARE_DRIFT, solver = "old", reports = true, errors = 3 },
	{ fixture = BARE_DRIFT, solver = "new", reports = false },
	{ fixture = WRAPPED_DRIFT, solver = "old", reports = true, errors = 3 },
	{ fixture = WRAPPED_DRIFT, solver = "new", reports = true, errors = 3 },
	{ fixture = NO_CAST, solver = "old", reports = true },
	{ fixture = NO_CAST, solver = "new", reports = false },
	{ fixture = CONFORMING, solver = "old", reports = false },
	{ fixture = CONFORMING, solver = "new", reports = false },
	{ fixture = BROKEN, solver = "old", reports = true },
	{ fixture = BROKEN, solver = "new", reports = true },
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
		error(string.format("ADR-0002: %s could not be written (%s): %s", path, tostring(problem), PROVES_NOTHING), 0)
	end
	return path
end

local function analyse(path: string, solver: Solver): Analysis
	local ran, result = pcall(function(): process.ExecResult
		return process.exec("luau-lsp", { "analyze", "--platform=standard", FLAGS[solver], path }, { cwd = root })
	end)
	if not ran then
		error(string.format("ADR-0002: luau-lsp could not be run (%s): %s", tostring(result), PROVES_NOTHING), 0)
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
	case(string.format("the %s solver %s %s", solver, verb, fixture.name), function()
		local path = write(fixture)
		local analysis = analyse(path, solver)
		-- A run is judged by its exit code and its output together: luau-lsp also exits 1 for a path that does not
		-- exist, without naming a type error (CR-0015).
		local reported = analysis.code ~= 0 and analysis.errors > 0
		local clean = analysis.code == 0 and analysis.errors == 0
		local message: string? = nil
		if not reported and not clean then
			message = string.format(
				"ADR-0002: luau-lsp exited with %d under the %s solver and named %d type errors in %s: %s",
				analysis.code,
				solver,
				analysis.errors,
				path,
				PROVES_NOTHING
			)
		elseif reported and not expectation.reports then
			message = string.format(
				"ADR-0002: the %s solver now reports %s (%s): %s",
				solver,
				fixture.subject,
				path,
				fixture.consequence
			)
		elseif clean and expectation.reports then
			message = string.format(
				"ADR-0002: the %s solver no longer reports %s (%s): %s",
				solver,
				fixture.subject,
				path,
				fixture.consequence
			)
		elseif reported and expectation.errors and analysis.errors ~= expectation.errors then
			message = string.format(
				"ADR-0002: the %s solver reports %d errors, not %d, for %s (%s): %s",
				solver,
				analysis.errors,
				expectation.errors :: number,
				fixture.subject,
				path,
				fixture.consequence
			)
		end
		if message then
			error(string.format("%s\n    luau-lsp exited with %d:\n%s", message, analysis.code, analysis.output), 0)
		end
	end)
end

return { name = "AdrFitness", cases = cases } :: Assert.Suite
