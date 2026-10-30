-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local Report = require("../lib/Report")
local Snapshot = require("../lib/Snapshot")
local Toolchain = require("../lib/Toolchain")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local ROKIT = '[tools]\nrojo = "rojo-rbx/rojo@7.7.0"\nlune = "lune-org/lune@0.10.5"\n'
local LUAURC = '{\n  "aliases": {\n    "lune": "~/.lune/.typedefs/0.10.5/"\n  }\n}\n'

local function check(files: { [string]: string }): Report.Report
	local report = Report.new()
	Toolchain.check(Snapshot.new(files), report)
	return report
end

case("matching versions pass", function()
	Assert.codes(check({ ["rokit.toml"] = ROKIT, ["scripts/.luaurc"] = LUAURC }), {})
end)

case("a stale type definition alias is reported", function()
	local stale = string.gsub(LUAURC, "0%.10%.5", "0.9.0")
	Assert.codes(check({ ["rokit.toml"] = ROKIT, ["scripts/.luaurc"] = stale }), { "TOOLCHAIN_VERSION_MISMATCH" })
end)

case("a manifest without lune is reported", function()
	local manifest = '[tools]\nrojo = "rojo-rbx/rojo@7.7.0"\n'
	Assert.codes(check({ ["rokit.toml"] = manifest, ["scripts/.luaurc"] = LUAURC }), { "TOOLCHAIN_VERSION_MISMATCH" })
end)

return { name = "Toolchain", cases = cases } :: Assert.Suite
