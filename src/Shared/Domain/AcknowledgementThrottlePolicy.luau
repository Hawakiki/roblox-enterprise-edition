-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class AcknowledgementThrottlePolicy

	Decides whether an acknowledgement comes late enough after the last one of the same player to earn a coin.
	It is told the time rather than reading a clock, so that it knows nothing of Roblox.

	같은 플레이어의 마지막 확인으로부터 충분히 지난 확인인지 판단하여 코인을 줄지 정한다.
	시계를 읽지 않고 시각을 전달받으므로 Roblox 에 대해 아무것도 모른다.
]=]

local AcknowledgementThrottlePolicy = {}
AcknowledgementThrottlePolicy.__index = AcknowledgementThrottlePolicy

type PolicyState = {
	_minimumIntervalSeconds: number,
	_lastPermitted: { [number]: number },
}

export type AcknowledgementThrottlePolicy = typeof(setmetatable({} :: PolicyState, AcknowledgementThrottlePolicy))

--[=[
	Creates the policy.

	@within AcknowledgementThrottlePolicy
	@param minimumIntervalSeconds number -- The shortest time between two permitted acknowledgements of one player.
	@return AcknowledgementThrottlePolicy -- The policy, remembering no one.
]=]
function AcknowledgementThrottlePolicy.new(minimumIntervalSeconds: number): AcknowledgementThrottlePolicy
	local state: PolicyState = {
		_minimumIntervalSeconds = minimumIntervalSeconds,
		_lastPermitted = {},
	}
	return setmetatable(state, AcknowledgementThrottlePolicy)
end

--[=[
	Tells whether an acknowledgement is permitted, and remembers it if it is.

	@within AcknowledgementThrottlePolicy
	@method Permits
	@param userId number -- The player who acknowledged.
	@param now number -- The time of the acknowledgement, in seconds, from any clock that only moves forward.
	@return boolean -- True when the acknowledgement earns a coin.
]=]
function AcknowledgementThrottlePolicy.Permits(
	self: AcknowledgementThrottlePolicy,
	userId: number,
	now: number
): boolean
	local last = self._lastPermitted[userId]
	if last ~= nil and now - last < self._minimumIntervalSeconds then
		return false
	end
	self._lastPermitted[userId] = now
	return true
end

--[=[
	Forgets a player, who has left.

	@within AcknowledgementThrottlePolicy
	@method Forget
	@param userId number -- The player to forget.
]=]
function AcknowledgementThrottlePolicy.Forget(self: AcknowledgementThrottlePolicy, userId: number)
	self._lastPermitted[userId] = nil
end

return AcknowledgementThrottlePolicy
