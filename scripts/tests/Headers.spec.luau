-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Headers = require("../lib/Headers")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local LUAU_HEADER = "-- SPDX-License-Identifier: MIT\n-- SPDX-FileCopyrightText: 2026 Jane Doe\n"
local HASH_HEADER = "# SPDX-License-Identifier: MIT\n# SPDX-FileCopyrightText: 2026 Jane Doe\n"

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	Headers.check(Snapshot.new(files), report)
	return report
end

-- SPDX / SPDX 헤더

case("files with a header pass", function()
	Assert.codes(
		check({
			["scripts/a.luau"] = LUAU_HEADER .. "--!strict\nreturn nil\n",
			["rokit.toml"] = HASH_HEADER .. "[tools]\n",
			["tools/check.sh"] = "#!/usr/bin/env bash\n" .. HASH_HEADER .. "exit 0\n",
			["tools/check.ps1"] = "\u{FEFF}" .. HASH_HEADER .. "exit 0\n",
			["docs/a.md"] = "---\n" .. HASH_HEADER .. "id: CR-0001\n---\n",
			["README.md"] = "<!-- SPDX-License-Identifier: MIT -->\n<!-- SPDX-FileCopyrightText: 2026 Jane Doe -->\n",
		}),
		{}
	)
end)

case("a file without a header is reported", function()
	Assert.codes(check({ ["rokit.toml"] = "[tools]\n" }), { "MISSING_SPDX_HEADER" })
end)

case("a header needs both tags", function()
	Assert.codes(check({ ["rokit.toml"] = "# SPDX-License-Identifier: MIT\n[tools]\n" }), { "MISSING_SPDX_HEADER" })
end)

case("a license other than MIT is reported", function()
	local header = "# SPDX-License-Identifier: GPL-3.0-only\n# SPDX-FileCopyrightText: 2026 Jane Doe\n"
	Assert.codes(check({ ["rokit.toml"] = header }), { "MISSING_SPDX_HEADER" })
end)

case("a header below the first ten lines is reported", function()
	Assert.codes(check({ ["rokit.toml"] = string.rep("\n", 10) .. HASH_HEADER }), { "MISSING_SPDX_HEADER" })
end)

case("JSON, .luaurc, LICENSE and binary files are exempt", function()
	Assert.codes(
		check({
			[".vscode/settings.json"] = "{}\n",
			["scripts/.luaurc"] = "{}\n",
			["LICENSE"] = "MIT License\n",
			["icon.png"] = "\x89PNG\0",
		}),
		{}
	)
end)

-- Strict mode / strict 모드

case("a Luau file without --!strict is reported", function()
	Assert.codes(check({ ["scripts/a.luau"] = LUAU_HEADER .. "return nil\n" }), { "MISSING_STRICT_MODE" })
end)

case("--!strict after code does not count", function()
	local source = LUAU_HEADER .. "local x = 1\n--!strict\nreturn x\n"
	Assert.codes(check({ ["scripts/a.luau"] = source }), { "MISSING_STRICT_MODE" })
end)

case("--!strict after a block comment does not count", function()
	local source = LUAU_HEADER .. "--[[\n\tAbout this module.\n]]\n--!strict\nreturn nil\n"
	Assert.codes(check({ ["scripts/a.luau"] = source }), { "MISSING_STRICT_MODE" })
end)

case("strict mode is required of Luau files only", function()
	Assert.codes(check({ ["tools/a.sh"] = HASH_HEADER .. "echo\n" }), {})
end)

return { name = "Headers", cases = cases } :: Assert.Suite
