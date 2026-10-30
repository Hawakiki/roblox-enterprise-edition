-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Keeps configuration that names a tool version in step with rokit.toml.
	도구 버전을 적어 둔 설정이 rokit.toml 과 어긋나지 않게 한다.
]]

local serde = require("@lune/serde")

local Report = require("./Report")
local Snapshot = require("./Snapshot")

local ROKIT_PATH = "rokit.toml"
local LUAURC_PATH = "scripts/.luaurc"

local function decode(format: "toml" | "json", source: string): any
	local ok, value = pcall(function()
		return serde.decode(format, source)
	end)
	return if ok then value else nil
end

local Toolchain = {}

function Toolchain.check(snapshot: Snapshot.Snapshot, report: Report.Report)
	local rokitSource = snapshot.files[ROKIT_PATH]
	local luaurcSource = snapshot.files[LUAURC_PATH]
	if rokitSource == nil or luaurcSource == nil then
		return
	end

	local manifest = decode("toml", rokitSource)
	local tools = if type(manifest) == "table" then manifest.tools else nil
	local lune = if type(tools) == "table" then tools.lune else nil
	local version = if type(lune) == "string" then string.match(lune, "@([%w%.%-]+)$") else nil
	if version == nil then
		Report.add(report, "TOOLCHAIN_VERSION_MISMATCH", ROKIT_PATH, nil, "rokit.toml does not pin a lune version")
		return
	end

	local config = decode("json", luaurcSource)
	local aliases = if type(config) == "table" then config.aliases else nil
	local alias = if type(aliases) == "table" then aliases.lune else nil
	local expected = "~/.lune/.typedefs/" .. version .. "/"
	if alias ~= expected then
		Report.add(
			report,
			"TOOLCHAIN_VERSION_MISMATCH",
			LUAURC_PATH,
			nil,
			string.format(
				"the lune alias is %s but rokit.toml pins lune %s; expected %s",
				tostring(alias),
				version,
				expected
			)
		)
	end
end

return Toolchain
