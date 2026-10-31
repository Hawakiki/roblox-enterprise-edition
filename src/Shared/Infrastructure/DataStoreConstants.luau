-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class DataStoreConstants

	The names, limits and timings of the DataStore that keeps the compliance wallets.

	준법 지갑을 보관하는 DataStore 의 이름, 한도, 시간.
]=]

local DataStoreConstants = {}

--[=[
	@prop DATASTORE_NAME string
	@within DataStoreConstants
	@readonly
	The DataStore that holds every wallet.
]=]
DataStoreConstants.DATASTORE_NAME = "EnterpriseEditionCoinWallets"

--[=[
	@prop KEY_PREFIX string
	@within DataStoreConstants
	@readonly
	Put before the user id of a player to make the key of their wallet.
]=]
DataStoreConstants.KEY_PREFIX = "wallet_"

--[=[
	@prop SCHEMA_VERSION number
	@within DataStoreConstants
	@readonly
	The shape of the records this code writes. A record of a newer shape is refused, never overwritten.
]=]
DataStoreConstants.SCHEMA_VERSION = 1

--[=[
	@prop LOCK_EXPIRY_SECONDS number
	@within DataStoreConstants
	@readonly
	How long a lock whose heartbeat has stopped is respected, before another server may take it over.
]=]
DataStoreConstants.LOCK_EXPIRY_SECONDS = 600

--[=[
	@prop ACQUIRE_ATTEMPTS number
	@within DataStoreConstants
	@readonly
	How many times a server tries to take a lock that another server holds, before it gives up.
]=]
DataStoreConstants.ACQUIRE_ATTEMPTS = 5

--[=[
	@prop ACQUIRE_RETRY_SECONDS number
	@within DataStoreConstants
	@readonly
	The wait between two attempts to take a lock, long enough for the other server to finish a release.
]=]
DataStoreConstants.ACQUIRE_RETRY_SECONDS = 6

--[=[
	@prop REQUEST_ATTEMPTS number
	@within DataStoreConstants
	@readonly
	How many times a failed request is made before the failure is reported.
]=]
DataStoreConstants.REQUEST_ATTEMPTS = 4

--[=[
	@prop BACKOFF_BASE_SECONDS number
	@within DataStoreConstants
	@readonly
	The wait after the first failed request, doubled after each one that follows.
]=]
DataStoreConstants.BACKOFF_BASE_SECONDS = 1

--[=[
	@prop MINIMUM_REQUEST_BUDGET number
	@within DataStoreConstants
	@readonly
	The budget a request waits for.
]=]
DataStoreConstants.MINIMUM_REQUEST_BUDGET = 1

--[=[
	@prop BUDGET_POLL_SECONDS number
	@within DataStoreConstants
	@readonly
	How often the budget is checked while a request waits for it.
]=]
DataStoreConstants.BUDGET_POLL_SECONDS = 1

--[=[
	@prop BUDGET_POLL_LIMIT number
	@within DataStoreConstants
	@readonly
	How many times the budget is checked before the request is made anyway, for Roblox to queue.
]=]
DataStoreConstants.BUDGET_POLL_LIMIT = 30

return table.freeze(DataStoreConstants)
