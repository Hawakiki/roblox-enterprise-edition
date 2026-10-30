-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Splits a Markdown document into its YAML frontmatter and its body.
	Reads leniently: a byte order mark and CRLF line endings do not break parsing.
	Markdown 문서를 YAML frontmatter 와 본문으로 나눈다.
	관대하게 읽는다: BOM 이나 CRLF 개행이 있어도 파싱은 깨지지 않는다.
]]

local serde = require("@lune/serde")

local Text = require("./Text")

export type Problem = "missing" | "invalid"

export type Parsed = {
	fields: { [string]: any }?,
	-- Field name -> line number in the file, for error locations.
	fieldLines: { [string]: number },
	body: { string },
	-- Line number in the file of body[1].
	bodyLine: number,
	problem: Problem?,
	message: string?,
}

local DELIMITER = "---"

local function decodeYaml(source: string): (boolean, any)
	return pcall(function()
		return serde.decode("yaml", source)
	end)
end

local Frontmatter = {}

function Frontmatter.parse(content: string): Parsed
	local lines = string.split(Text.normalize(content), "\n")
	if lines[1] ~= DELIMITER then
		return {
			fields = nil,
			fieldLines = {},
			body = lines,
			bodyLine = 1,
			problem = "missing",
			message = "document does not start with a '---' frontmatter block",
		}
	end

	local closing: number? = nil
	for number = 2, #lines do
		if lines[number] == DELIMITER then
			closing = number
			break
		end
	end
	if closing == nil then
		return {
			fields = nil,
			fieldLines = {},
			body = {},
			bodyLine = #lines + 1,
			problem = "invalid",
			message = "frontmatter block is never closed with '---'",
		}
	end

	local yamlLines = {}
	local fieldLines: { [string]: number } = {}
	for number = 2, closing - 1 do
		local line = lines[number]
		table.insert(yamlLines, line)
		local key = string.match(line, "^([%w_%-]+):")
		if key and fieldLines[key] == nil then
			fieldLines[key] = number
		end
	end
	local body = table.move(lines, closing + 1, #lines, 1, {})

	local ok, value = decodeYaml(table.concat(yamlLines, "\n"))
	local problem: string? = nil
	if not ok then
		problem = "frontmatter is not valid YAML"
	elseif value == nil then
		value = {}
	elseif type(value) ~= "table" or #value > 0 then
		problem = "frontmatter must be a mapping of fields"
	else
		for key in value do
			if type(key) ~= "string" then
				problem = "frontmatter keys must be strings"
				break
			end
		end
	end
	if problem then
		return {
			fields = nil,
			fieldLines = fieldLines,
			body = body,
			bodyLine = closing + 1,
			problem = "invalid",
			message = problem,
		}
	end

	return {
		fields = value,
		fieldLines = fieldLines,
		body = body,
		bodyLine = closing + 1,
		problem = nil,
		message = nil,
	}
end

return Frontmatter
