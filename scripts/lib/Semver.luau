-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Document versions (MAJOR.MINOR.PATCH) and revisions (MAJOR.MINOR).
	A revision is what a child document cites: editorial PATCH changes never invalidate children.
	문서 버전(MAJOR.MINOR.PATCH)과 개정판(MAJOR.MINOR).
	하위 문서는 개정판을 인용하므로, 자구 수정(PATCH)은 하위 문서를 무효로 만들지 않는다.
]]

export type Revision = {
	major: number,
	minor: number,
}

export type Version = {
	major: number,
	minor: number,
	patch: number,
}

local Semver = {}

function Semver.parse(s: string): Version?
	local major, minor, patch = string.match(s, "^(%d+)%.(%d+)%.(%d+)$")
	if not (major and minor and patch) then
		return nil
	end
	return {
		major = tonumber(major) :: number,
		minor = tonumber(minor) :: number,
		patch = tonumber(patch) :: number,
	}
end

function Semver.parseRevision(s: string): Revision?
	local major, minor = string.match(s, "^(%d+)%.(%d+)$")
	if not (major and minor) then
		return nil
	end
	return {
		major = tonumber(major) :: number,
		minor = tonumber(minor) :: number,
	}
end

function Semver.format(version: Version): string
	return string.format("%d.%d.%d", version.major, version.minor, version.patch)
end

function Semver.formatRevision(revision: Revision): string
	return string.format("%d.%d", revision.major, revision.minor)
end

function Semver.sameRevision(version: Version, revision: Revision): boolean
	return version.major == revision.major and version.minor == revision.minor
end

return Semver
