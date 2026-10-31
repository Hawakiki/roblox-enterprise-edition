-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Text utilities shared by every check.
	모든 검사가 함께 쓰는 텍스트 유틸리티.
]]

local regex = require("@lune/regex")

local HANGUL = regex.new("\\p{Hangul}")

local Text = {}

Text.BOM = "\u{FEFF}"

-- Strips a leading byte order mark and converts CRLF / CR line endings to LF.
-- Parsers read leniently; checkpatch reports the original bytes separately.
function Text.normalize(s: string): string
	if string.sub(s, 1, 3) == Text.BOM then
		s = string.sub(s, 4)
	end
	s = (string.gsub(s, "\r\n", "\n"))
	s = (string.gsub(s, "\r", "\n"))
	return s
end

function Text.trimRight(s: string): string
	return (string.gsub(s, "%s+$", ""))
end

function Text.trim(s: string): string
	return Text.trimRight((string.gsub(s, "^%s+", "")))
end

function Text.hasHangul(s: string): boolean
	return HANGUL:isMatch(s)
end

function Text.isAscii(s: string): boolean
	return string.find(s, "[\128-\255]") == nil
end

local WIDE_RANGES = {
	{ 0x1100, 0x115F }, -- Hangul Jamo
	{ 0x2E80, 0x303E }, -- CJK radicals and symbols
	{ 0x3041, 0x33FF }, -- Kana, Hangul compatibility Jamo, CJK compatibility
	{ 0x3400, 0x4DBF }, -- CJK extension A
	{ 0x4E00, 0x9FFF }, -- CJK unified ideographs
	{ 0xA960, 0xA97F }, -- Hangul Jamo extended A
	{ 0xAC00, 0xD7A3 }, -- Hangul syllables
	{ 0xF900, 0xFAFF }, -- CJK compatibility ideographs
	{ 0xFE30, 0xFE4F }, -- CJK compatibility forms
	{ 0xFF00, 0xFF60 }, -- Fullwidth forms
	{ 0xFFE0, 0xFFE6 }, -- Fullwidth signs
}

local function isWide(code: number): boolean
	for _, range in WIDE_RANGES do
		if code >= range[1] and code <= range[2] then
			return true
		end
	end
	return false
end

-- Width in terminal columns. East Asian wide characters take two columns.
function Text.displayWidth(s: string): number
	if utf8.len(s) == nil then
		return #s
	end
	local width = 0
	for _, code in utf8.codes(s) do
		width += if isWide(code) then 2 else 1
	end
	return width
end

function Text.contains(list: { string }, value: string): boolean
	return table.find(list, value) ~= nil
end

function Text.sortedKeys(map: { [string]: any }): { string }
	local keys = {}
	for key in map do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

return Text
