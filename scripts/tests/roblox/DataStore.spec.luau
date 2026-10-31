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

-- Defect 1 of CR-0018: a late load on the same server cleared the lock of the wallet that replaced it.
case("a player who rejoins while an earlier load still waits keeps every coin", function()
	local world = newWorld()
	world.sleepGate = Fakes.gate()
	world.store.records[keyOf(1)] =
		{ schemaVersion = 1, balance = 10, lock = { sessionId = "server-A", heartbeat = world.now } }
	local server = newSessionServer(world:server("server-B"))
	local first = Fakes.player(1)
	server.sessions:Join(first) -- the first load finds the lock of server A, and waits to try again
	Fakes.settle()
	world.store.records[keyOf(1)].lock = nil -- server A releases the wallet
	server.sessions:Leave(first) -- the player leaves while the first load waits
	server.sessions:Join(Fakes.player(1)) -- and joins again at once
	Fakes.settle()
	world.sleepGate:Open()
	Fakes.settle()
	local wallet = server.registry:Get(1)
	Assert.truthy(wallet ~= nil, "the player who rejoined has a wallet")
	for _ = 1, 5 do
		wallet:Deposit(1)
	end
	server.service:_SaveAll()
	Assert.equal(server.sessions:Kicked(1), false, "the player is not disconnected")
	Assert.equal(world:record(1).balance, 15, "and keeps every coin")
	Assert.equal(world:record(1).lock.sessionId, "server-B", "while the server still holds the wallet")
	server.service:StopAsync()
end)

-- Defect 1 of CR-0018, at the level of the repository.
case("a server opens a wallet once, and saves and releases only the wallet it opened", function()
	local world = newWorld()
	local a = world:server("server-A")
	local wallet = a:Load(51)
	Assert.raises(function()
		a:Load(51)
	end, "already open on this server", "a second load on the same server")
	local impostor = CoinWalletEntity.new(51, 99, policy)
	Assert.equal(a:Save(impostor), false, "a wallet the server did not open is not saved")
	a:Release(impostor)
	Assert.equal(world:record(51).lock.sessionId, "server-A", "nor released")
	Assert.equal(world:record(51).balance, 0, "and writes nothing")
	Assert.equal(a:Save(wallet), true, "the wallet it opened is still held")
end)

-- Defect 2 of CR-0018: stopping did not wait for loads under way.
case("stopping waits for a load under way, and releases the wallet it loads", function()
	local loadGate = Fakes.gate()
	local released: { number } = {}
	local repository = {
		Load = function(_: any, userId: number): any
			loadGate:Wait()
			return CoinWalletEntity.new(userId, 0, policy)
		end,
		Save = function(_: any): boolean
			return true
		end,
		Release = function(_: any, wallet: any)
			local userId: number = wallet:GetUserId()
			table.insert(released, userId)
		end,
	}
	local server = newSessionServer(repository)
	server.sessions:Join(Fakes.player(21))
	local stopped = false
	task.spawn(function()
		server.service:StopAsync()
		stopped = true
	end)
	Fakes.settle()
	Assert.equal(stopped, false, "stopping waits for the load")
	loadGate:Open()
	Fakes.settle()
	Assert.truthy(stopped, "and returns once it has finished")
	Assert.equal(#released, 1, "the wallet loaded after the stop is released")
	Assert.equal(server.registry:Get(21), nil, "and never registered")
end)

-- Defect 3 of CR-0018: an autosave disconnected a player who had rejoined during the pass.
case("an autosave that reaches a wallet already released leaves the rejoined player alone", function()
	local saveGate = Fakes.gate()
	local held: { [number]: any } = {}
	local firstSaved: number? = nil
	local repository = {
		Load = function(_: any, userId: number): any
			local wallet = CoinWalletEntity.new(userId, 0, policy)
			held[userId] = wallet
			return wallet
		end,
		Save = function(_: any, wallet: any): boolean
			if firstSaved == nil then
				firstSaved = wallet:GetUserId()
				saveGate:Wait()
			end
			return held[wallet:GetUserId()] == wallet
		end,
		Release = function(_: any, wallet: any)
			if held[wallet:GetUserId()] == wallet then
				held[wallet:GetUserId()] = nil
			end
		end,
	}
	local server = newSessionServer(repository)
	local players = { [31] = Fakes.player(31), [32] = Fakes.player(32) }
	server.sessions:Join(players[31])
	server.sessions:Join(players[32])
	Fakes.settle()
	task.spawn(function()
		server.service:_SaveAll()
	end)
	Fakes.settle()
	-- The player whose wallet the pass reaches second leaves and joins again while the first is saved.
	local later = if firstSaved == 31 then 32 else 31
	server.sessions:Leave(players[later])
	server.sessions:Join(Fakes.player(later))
	Fakes.settle()
	saveGate:Open()
	Fakes.settle()
	Assert.equal(server.sessions:Kicked(later), false, "the player who rejoined is not disconnected")
	Assert.truthy(server.registry:Get(later) ~= nil, "and keeps the wallet")
	server.service:StopAsync()
end)

-- Defect 7 of CR-0018: an impossible balance was read, and the load failed after it had taken the lock.
case("a record with an impossible balance is refused before any lock is taken", function()
	local world = newWorld()
	local a = world:server("server-A")
	local balances: { [number]: number } = { [41] = -3, [42] = 2.5, [43] = CoinConstants.MAXIMUM_BALANCE + 1 }
	for userId, balance in balances do
		world.store.records[keyOf(userId)] = { schemaVersion = 1, balance = balance }
		Assert.raises(function()
			a:Load(userId)
		end, "impossible balance", "a balance of " .. tostring(balance))
		Assert.equal(world:record(userId).lock, nil, "takes no lock: " .. tostring(balance))
	end
end)

return { name = "Roblox: DataStore wallets", cases = cases } :: Assert.Suite
