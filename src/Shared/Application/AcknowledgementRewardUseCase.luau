-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class AcknowledgementRewardUseCase

	Rewards one acknowledgement of the policies of the Company with one compliance coin, unless it comes too fast,
	the player has no wallet yet, or the wallet is full.

	회사의 정책을 한 번 확인한 데 대해 준법 코인 하나로 보상한다. 단, 너무 빠르거나, 플레이어에게 아직 지갑이
	없거나, 지갑이 가득 찼으면 보상하지 않는다.
]=]

local AcknowledgementThrottlePolicy = require(script.Parent.Parent.Domain.AcknowledgementThrottlePolicy)
local CoinConstants = require(script.Parent.Parent.Domain.CoinConstants)
local CoinWalletRegistry = require(script.Parent.CoinWalletRegistry)
local ICoinProjection = require(script.Parent.ICoinProjection)

type UseCaseState = {
	_registry: CoinWalletRegistry.CoinWalletRegistry,
	_throttle: AcknowledgementThrottlePolicy.AcknowledgementThrottlePolicy,
	_projection: ICoinProjection.ICoinProjection,
	_clock: () -> number,
}

local AcknowledgementRewardUseCase = {}
AcknowledgementRewardUseCase.__index = AcknowledgementRewardUseCase

export type AcknowledgementRewardUseCase = typeof(setmetatable({} :: UseCaseState, AcknowledgementRewardUseCase))

--[=[
	Creates the use case.

	@within AcknowledgementRewardUseCase
	@param registry CoinWalletRegistry -- Holds the wallets of the players who are present.
	@param throttle AcknowledgementThrottlePolicy -- Refuses acknowledgements that come too fast.
	@param projection ICoinProjection -- Shows the new balance.
	@param clock () -> number -- Tells the time in seconds, on a clock that only moves forward.
	@return AcknowledgementRewardUseCase -- The use case.
]=]
function AcknowledgementRewardUseCase.new(
	registry: CoinWalletRegistry.CoinWalletRegistry,
	throttle: AcknowledgementThrottlePolicy.AcknowledgementThrottlePolicy,
	projection: ICoinProjection.ICoinProjection,
	clock: () -> number
): AcknowledgementRewardUseCase
	local state: UseCaseState = {
		_registry = registry,
		_throttle = throttle,
		_projection = projection,
		_clock = clock,
	}
	return setmetatable(state, AcknowledgementRewardUseCase)
end

--[=[
	Rewards an acknowledgement, if it earns a coin.

	@within AcknowledgementRewardUseCase
	@method Execute
	@param player Player -- The player who acknowledged.
	@return boolean -- True when a coin was deposited.
]=]
function AcknowledgementRewardUseCase.Execute(self: AcknowledgementRewardUseCase, player: Player): boolean
	local userId = player.UserId
	if not self._throttle:Permits(userId, self._clock()) then
		return false
	end
	local wallet = self._registry:Get(userId)
	if wallet == nil or not wallet:Deposit(CoinConstants.COINS_PER_ACKNOWLEDGEMENT) then
		return false
	end
	self._projection:Update(player, wallet:GetBalance())
	return true
end

return AcknowledgementRewardUseCase
