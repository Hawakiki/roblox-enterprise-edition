-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ICoinWalletRepository

	The contract of the store that keeps the wallets of players between their sessions.

	플레이어의 지갑을 세션 사이에 보관하는 저장소의 계약.
]=]

local CoinWalletEntity = require(script.Parent.Parent.Domain.CoinWalletEntity)

--[=[
	@interface ICoinWalletRepository
	@within ICoinWalletRepository
	.Load (self: any, userId: number) -> CoinWalletEntity -- Loads the wallet of a player who joins; it may yield.
	.Save (self: any, wallet: CoinWalletEntity) -> () -- Saves a wallet while its player stays.
	.Release (self: any, wallet: CoinWalletEntity) -> () -- Saves a wallet for the last time, when its player leaves.

	The members that every wallet repository implements. A repository that guards a wallet against two servers
	at once takes the guard in Load and gives it up in Release.

	모든 지갑 저장소가 구현하는 멤버. 두 서버가 한 지갑을 동시에 쓰지 못하게 지키는 저장소는 Load 에서 그 보호를
	얻고 Release 에서 놓는다.
]=]
export type ICoinWalletRepository = {
	Load: (self: any, userId: number) -> CoinWalletEntity.CoinWalletEntity,
	Save: (self: any, wallet: CoinWalletEntity.CoinWalletEntity) -> (),
	Release: (self: any, wallet: CoinWalletEntity.CoinWalletEntity) -> (),
}

return {}
