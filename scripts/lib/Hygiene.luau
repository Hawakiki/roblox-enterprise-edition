-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	File hygiene: encoding, byte order marks, line endings and whitespace, for every text file.
	파일 위생: 모든 텍스트 파일의 인코딩, BOM, 개행, 공백.
]]

local Report = require("./Report")
local Snapshot = require("./Snapshot")
local Text = require("./Text")

local BINARY_EXTENSIONS: { [string]: boolean } = {
	gif = true,
	ico = true,
	jpeg = true,
	jpg = true,
	otf = true,
	pdf = true,
	png = true,
	rbxl = true,
	rbxm = true,
	ttf = true,
	webp = true,
	woff = true,
	woff2 = true,
	zip = true,
}

local function extension(path: string): string
	return string.lower(string.match(path, "%.(%w+)$") or "")
end

local function isBinary(path: string, content: string): boolean
	return BINARY_EXTENSIONS[extension(path)] == true or string.find(content, "\0", 1, true) ~= nil
end

local function checkFile(path: string, content: string, report: Report.Report)
	if utf8.len(content) == nil then
		Report.add(report, "INVALID_UTF8", path, nil, "file is not valid UTF-8")
		return
	end

	local hasBom = string.sub(content, 1, 3) == Text.BOM
	local isPowerShell = extension(path) == "ps1"
	if hasBom and not isPowerShell then
		Report.add(report, "UTF8_BOM", path, 1, "byte order mark is not allowed")
	elseif isPowerShell and not hasBom and not Text.isAscii(content) then
		Report.add(
			report,
			"MISSING_UTF8_BOM",
			path,
			1,
			"Windows PowerShell 5.1 reads BOM-less files as ANSI and garbles non-ASCII text"
		)
	end

	local lines = string.split(content, "\n")
	local crlfReported = false
	for number, line in lines do
		if string.find(line, "\r", 1, true) then
			if not crlfReported then
				Report.add(report, "CRLF_LINE_ENDING", path, number, "carriage return found; line endings must be LF")
				crlfReported = true
			end
			line = (string.gsub(line, "\r$", ""))
		end
		if string.find(line, "[ \t]$") then
			Report.add(report, "TRAILING_WHITESPACE", path, number, "trailing whitespace")
		end
	end

	if #content > 0 and string.sub(content, -1) ~= "\n" then
		Report.add(report, "MISSING_FINAL_NEWLINE", path, #lines, "no newline at end of file")
	end
end

local Hygiene = {}

Hygiene.extension = extension
Hygiene.isBinary = isBinary

function Hygiene.check(snapshot: Snapshot.Snapshot, report: Report.Report)
	for _, path in Snapshot.paths(snapshot) do
		local content = snapshot.files[path]
		if not isBinary(path, content) then
			report.checked += 1
			checkFile(path, content, report)
		end
	end
end

return Hygiene
