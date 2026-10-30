-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Collects violations and prints them in the style of the Linux kernel's checkpatch.pl.
	위반 사항을 모아 리눅스 커널 checkpatch.pl 형식으로 출력한다.
]]

local Catalog = require("./Catalog")

export type Violation = {
	code: string,
	severity: Catalog.Severity,
	path: string?,
	line: number?,
	message: string,
}

export type Report = {
	violations: { Violation },
	checked: number,
}

local Report = {}

function Report.new(): Report
	return { violations = {}, checked = 0 }
end

function Report.add(report: Report, code: string, path: string?, line: number?, message: string)
	local rule = Catalog.get(code)
	table.insert(report.violations, {
		code = code,
		severity = rule.severity,
		path = path,
		line = line,
		message = message,
	})
end

function Report.count(report: Report, severity: Catalog.Severity): number
	local count = 0
	for _, violation in report.violations do
		if violation.severity == severity then
			count += 1
		end
	end
	return count
end

function Report.sorted(report: Report): { Violation }
	local sorted = table.clone(report.violations)
	table.sort(sorted, function(a: Violation, b: Violation): boolean
		local pathA, pathB = a.path or "", b.path or ""
		if pathA ~= pathB then
			return pathA < pathB
		end
		local lineA, lineB = a.line or 0, b.line or 0
		if lineA ~= lineB then
			return lineA < lineB
		end
		return a.code < b.code
	end)
	return sorted
end

-- Sorted, without duplicates. Used by tests.
function Report.codes(report: Report): { string }
	local seen: { [string]: boolean } = {}
	local codes = {}
	for _, violation in report.violations do
		if not seen[violation.code] then
			seen[violation.code] = true
			table.insert(codes, violation.code)
		end
	end
	table.sort(codes)
	return codes
end

function Report.format(violation: Violation): string
	local location = ""
	local path = violation.path
	if path then
		location = path
		local line = violation.line
		if line then
			location ..= ":" .. tostring(line)
		end
		location ..= ": "
	end
	return string.format(
		"%s: %s: %s%s [%s]",
		violation.severity,
		violation.code,
		location,
		violation.message,
		Catalog.get(violation.code).standard
	)
end

function Report.print(report: Report, unit: string)
	for _, violation in Report.sorted(report) do
		print(Report.format(violation))
	end
	local errors = Report.count(report, "ERROR")
	local warnings = Report.count(report, "WARNING")
	print(string.format("total: %d errors, %d warnings, %d %s checked", errors, warnings, report.checked, unit))
	if errors > 0 then
		print("checkpatch: has compliance problems, please review. Submission will be rejected.")
	elseif warnings > 0 then
		print("checkpatch: has minor compliance concerns. Submission is permitted, reluctantly.")
	else
		print("checkpatch: no obvious compliance problems. Ready for submission.")
	end
end

return Report
