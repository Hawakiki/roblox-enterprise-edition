-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local task = require("@lune/task")

local Assert = require("../Assert")
local FakeRoblox = require("./FakeRoblox")
local Fakes = require("./Fakes")

local CoinConstants = FakeRoblox.require("Domain/CoinConstants")
local CoinOverflowPolicy = FakeRoblox.require("Domain/CoinOverflowPolicy")
local CoinWalletEntity = FakeRoblox.require("Domain/CoinWalletEntity")
local AcknowledgementThrottlePolicy = FakeRoblox.require("Domain/AcknowledgementThrottlePolicy")
local CoinWalletRegistry = FakeRoblox.require("Application/CoinWalletRegistry")
local CoinSessionService = FakeRoblox.require("Application/CoinSessionService")
local DataStoreConstants = FakeRoblox.require("Infrastructure/DataStoreConstants")
local DataStoreCoinWalletRepository = FakeRoblox.require("Infrastructure/DataStoreCoinWalletRepository")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local policy = CoinOverflowPolicy.new(CoinConstants.MAXIMUM_BALANCE)

local function keyOf(userId: number): string
	return DataStoreConstants.KEY_PREFIX .. tostring(userId)
end

-- One DataStore, a clock every server shares, and the sleeps and budget the servers ask for.
local function newWorld(): any
	local world: any = { store = Fakes.dataStore(), now = 1000, sleeps = {}, budget = {}, sleepGate = nil }
	function world.server(self: any, sessionId: string): any
		return DataStoreCoinWalletRepository.new({
			dataStore = self.store,
			overflowPolicy = policy,
			sessionId = sessionId,
			clock = function(): number
				return self.now
			end,
			sleep = function(seconds: number)
				table.insert(self.sleeps, seconds)
				if self.sleepGate then
					self.sleepGate:Wait()
				end
			end,
			requestBudget = function(): number
				local budget = table.remove(self.budget, 1)
				return if budget == nil then 1 else budget
			end,
		})
	end
	function world.record(self: any, userId: number): any
		return self.store.records[keyOf(userId)]
	end
	return world
end

-- A server: the real session service and registry over a repository, with fake sessions.
local function newSessionServer(repository: any): any
	local server: any = {
		sessions = Fakes.sessions(),
		projection = Fakes.projection(),
		logger = Fakes.logger(),
		registry = CoinWalletRegistry.new(),
	}
	server.service = CoinSessionService.new(
		server.sessions,
		repository,
		server.projection,
		server.registry,
		AcknowledgementThrottlePolicy.new(0),
		server.logger
	)
	server.service:StartAsync()
	return server
end

case("loading takes the lock, and saving renews it", function()
	local world = newWorld()
	local a = world:server("server-A")
	local wallet = a:Load(1)
	Assert.equal(wallet:GetBalance(), 0, "a new player starts with nothing")
	Assert.equal(world:record(1).lock.sessionId, "server-A", "loading takes the lock")
	Assert.equal(world:record(1).schemaVersion, DataStoreConstants.SCHEMA_VERSION, "the record carries its schema")
	wallet:Deposit(3)
	world.now += 60
	Assert.equal(a:Save(wallet), true, "saving reports the wallet still held")
	Assert.equal(world:record(1).balance, 3, "saving writes the balance")
	Assert.equal(world:record(1).lock.heartbeat, world.now, "saving renews the heartbeat")
end)

case("another server waits for a held lock, then gives up", function()
	local world = newWorld()
	local a, b = world:server("server-A"), world:server("server-B")
	local wallet = a:Load(1)
	wallet:Deposit(3)
	a:Save(wallet)
	Assert.raises(function()
		b:Load(1)
	end, "locked by another server", "another server cannot load a held wallet")
	Assert.equal(#world.sleeps, DataStoreConstants.ACQUIRE_ATTEMPTS - 1, "it tried every attempt")
	Assert.equal(world.sleeps[1], DataStoreConstants.ACQUIRE_RETRY_SECONDS, "waiting between attempts")
	Assert.equal(world:record(1).lock.sessionId, "server-A", "and wrote nothing")
	Assert.equal(world:record(1).balance, 3, "not even the balance")
end)

case("a release hands the wallet over", function()
	local world = newWorld()
	local a, b = world:server("server-A"), world:server("server-B")
	local wallet = a:Load(1)
	wallet:Deposit(3)
	a:Release(wallet)
	Assert.equal(world:record(1).lock, nil, "release gives up the lock")
	Assert.equal(world:record(1).balance, 3, "and writes the balance")
	Assert.equal(a:Save(wallet), false, "a released wallet is not saved again")
	local moved = b:Load(1)
	Assert.equal(moved:GetBalance(), 3, "the other server loads it")
	Assert.equal(world:record(1).lock.sessionId, "server-B", "and holds it")
end)

case("a lock whose heartbeat has stopped is taken over, and its old holder writes nothing", function()
	local world = newWorld()
	local a, b = world:server("server-A"), world:server("server-B")
	local stale = a:Load(2)
	stale:Deposit(5)
	Assert.truthy(a:Save(stale), "server A saves")
	world.now += DataStoreConstants.LOCK_EXPIRY_SECONDS - 1
	Assert.raises(function()
		b:Load(2)
	end, "locked", "a lock just short of its expiry is respected")
	world.now += 2
	local taken = b:Load(2)
	Assert.equal(taken:GetBalance(), 5, "a lock past its expiry is taken over")
	taken:Deposit(10)
	Assert.truthy(b:Save(taken), "the new holder saves")
	stale:Deposit(100)
	Assert.equal(a:Save(stale), false, "the old holder learns it lost the wallet")
	a:Release(stale)
	Assert.equal(world:record(2).balance, 15, "and overwrites nothing")
	Assert.equal(world:record(2).lock.sessionId, "server-B", "nor the lock")
end)

case("a failed request is retried with backoff, and reported once every attempt has failed", function()
	local world = newWorld()
	local a = world:server("server-A")
	world.store.failures = 2
	local retried = a:Load(3)
	Assert.equal(retried:GetBalance(), 0, "a request that fails twice succeeds on the third attempt")
	Assert.equal(world.sleeps[1], 1, "after waiting one second")
	Assert.equal(world.sleeps[2], 2, "then two")
	world.store.failures = 99
	Assert.raises(function()
		a:Load(4)
	end, "failed " .. tostring(DataStoreConstants.REQUEST_ATTEMPTS) .. " times", "a request that keeps failing")
end)

case("a request waits for budget", function()
	local world = newWorld()
	local a = world:server("server-A")
	world.budget = { 0, 0, 0, 1 }
	a:Load(5)
	Assert.equal(#world.sleeps, 3, "it waits while there is none")
	Assert.equal(world.sleeps[1], DataStoreConstants.BUDGET_POLL_SECONDS, "polling at its interval")
end)

case("a record that the code cannot trust is refused and left alone", function()
	local world = newWorld()
	local a = world:server("server-A")
	world.store.records[keyOf(6)] = { schemaVersion = 99, balance = 1 }
	Assert.raises(function()
		a:Load(6)
	end, "newer", "a record of a newer schema")
	Assert.equal(world:record(6).schemaVersion, 99, "is left alone")
	world.store.records[keyOf(7)] = { schemaVersion = 1, balance = "lots" }
	Assert.raises(function()
		a:Load(7)
	end, "malformed", "a malformed record")
end)

case("the session service disconnects a player it cannot serve, and waits for releases on stop", function()
	local slowReleases = 0
	local repository = {
		Load = function(_: any, userId: number): any
			if userId == 13 then
				error("the DataStore is down (fake)")
			end
			return CoinWalletEntity.new(userId, 0, policy)
		end,
		Save = function(_: any, wallet: any): boolean
			return wallet:GetUserId() ~= 12 -- user 12 has been taken over by another server
		end,
		Release = function(_: any)
			task.wait()
			slowReleases += 1
		end,
	}
	local server = newSessionServer(repository)
	local alice, bob = Fakes.player(11), Fakes.player(12)
	server.sessions:Join(alice)
	server.sessions:Join(bob)
	server.sessions:Join(Fakes.player(13))
	Fakes.settle()
	Assert.truthy(server.sessions:Kicked(13), "a wallet that cannot be loaded disconnects its player")
	Assert.equal(server.registry:Get(13), nil, "and is not registered")
	server.service:_SaveAll()
	Assert.truthy(server.sessions:Kicked(12), "a wallet taken over disconnects its player")
	Assert.equal(server.registry:Get(12), nil, "and is given up")
	Assert.truthy(server.registry:Get(11) ~= nil and not server.sessions:Kicked(11), "a wallet still held stays")
	server.sessions:Leave(alice)
	Assert.equal(slowReleases, 0, "the release is under way")
	server.service:StopAsync()
	Assert.equal(slowReleases, 1, "stopping waits for a release already under way")
end)

return { name = "Roblox: DataStore wallets", cases = cases } :: Assert.Suite
