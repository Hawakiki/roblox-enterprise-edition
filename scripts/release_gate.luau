-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Refuses a deployment during a change freeze (EE-STD-0008 §7): lune run scripts/release_gate
	A refused deployment is not postponed: re-run the workflow once the freeze has passed.
	변경 동결 중의 배포를 거부한다(EE-STD-0008 §7): lune run scripts/release_gate
	거부된 배포는 미뤄지지 않는다. 동결이 지난 뒤에 워크플로를 다시 실행한다.
]]

local process = require("@lune/process")

local ReleaseCalendar = require("./lib/ReleaseCalendar")

local ISO_8601 = "!%Y-%m-%dT%H:%M:%SZ"

local now = os.time()
local reason = ReleaseCalendar.freezeAt(now)
if reason then
	print(string.format("release_gate: no deployment now: %s (EE-STD-0008 §7).", reason))
	print(
		string.format("release_gate: re-run the workflow from %s.", os.date(ISO_8601, ReleaseCalendar.nextOpening(now)))
	)
	process.exit(1)
end
print("release_gate: no change freeze is in force.")
