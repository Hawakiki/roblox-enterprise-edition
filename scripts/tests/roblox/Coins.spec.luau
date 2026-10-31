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
local AcknowledgementRewardUseCase = FakeRoblox.require("Application/AcknowledgementRewardUseCase")
local AcknowledgementRequestHandler = FakeRoblox.require("Application/AcknowledgementRequestHandler")
local InMemoryCoinWalletRepository = FakeRoblox.require("Infrastructure/InMemoryCoinWalletRepository")
local LeaderstatsCoinProjection = FakeRoblox.require("Infrastructure/LeaderstatsCoinProjection")
local RobloxPlayerSessionAdapter = FakeRoblox.require("Infrastructure/RobloxPlayerSessionAdapter")
local RemoteEventAcknowledgementGateway = FakeRoblox.require("Infrastructure/RemoteEventAcknowledgementGateway")
local LeaderstatsCoinBalanceAdapter = FakeRoblox.require("Infrastructure/LeaderstatsCoinBalanceAdapter")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local policy = CoinOverflowPolicy.new(CoinConstants.MAXIMUM_BALANCE)

local factory = {
	Create = function(_: any, className: string): any
		return FakeRoblox.instance(className)
	end,
}

local function newPlayers(): any
	local players = FakeRoblox.instance("Players")
	players.GetPlayers = function(self: any): { any }
		return FakeRoblox.children(self)
	end
	return players
end

local function newPlayer(userId: number, name: string): any
	local player = FakeRoblox.instance("Player")
	player.UserId = userId
	player.Name = name
	return player
end

local function coinsOf(player: any): number?
	local folder = FakeRoblox.child(player, "leaderstats")
	local value = folder and FakeRoblox.child(folder, "Coins")
	return value and value.Value
end

-- The server, assembled as the composition root assembles it, with Alice present before it starts.
local function newServer(): any
	local server: any = { now = 0, logs = {} }
	server.players = newPlayers()
	server.alice = newPlayer(1, "Alice")
	server.alice.Parent = server.players
	server.logger = {
		Information = function(_: any, message: string)
			table.insert(server.logs, message)
		end,
		Warning = function(_: any) end,
	}
	server.remote = FakeRoblox.instance("RemoteEvent")
	server.throttle = AcknowledgementThrottlePolicy.new(CoinConstants.MINIMUM_ACKNOWLEDGEMENT_INTERVAL_SECONDS)
	server.registry = CoinWalletRegistry.new()
	server.repository = InMemoryCoinWalletRepository.new(policy)
	server.projection = LeaderstatsCoinProjection.new(factory)
	server.sessions = CoinSessionService.new(
		RobloxPlayerSessionAdapter.new(server.players),
		server.repository,
		server.projection,
		server.registry,
		server.throttle,
		server.logger
	)
	local reward = AcknowledgementRewardUseCase.new(
		server.registry,
		server.throttle,
		server.projection,
		function(): number
			return server.now
		end
	)
	server.handler = AcknowledgementRequestHandler.new(RemoteEventAcknowledgementGateway.new(server.remote), reward)
	server.sessions:StartAsync()
	server.handler:StartAsync()
	return server
end

case("a wallet holds whole coins up to its maximum", function()
	local full = CoinWalletEntity.new(1, CoinConstants.MAXIMUM_BALANCE, policy)
	Assert.equal(full:Deposit(1), false, "a full wallet refuses a coin")
	Assert.equal(full:GetBalance(), CoinConstants.MAXIMUM_BALANCE, "and keeps its balance")
	local nearly = CoinWalletEntity.new(1, CoinConstants.MAXIMUM_BALANCE - 1, policy)
	Assert.equal(nearly:Deposit(1), true, "the last coin fits")
	Assert.equal(nearly:Deposit(1), false, "then the wallet is full")
	Assert.raises(function()
		CoinWalletEntity.new(1, CoinConstants.MAXIMUM_BALANCE + 1, policy)
	end, nil, "a balance above the maximum")
	Assert.raises(function()
		CoinWalletEntity.new(1, -1, policy)
	end, nil, "a negative balance")
	Assert.raises(function()
		CoinWalletEntity.new(1, 0, policy):Deposit(0)
	end, nil, "a deposit of no coins")
	Assert.raises(function()
		CoinWalletEntity.new(1, 0, policy):Deposit(0.5)
	end, nil, "a deposit of half a coin")
end)

case("an acknowledgement earns a coin, one per interval for each player", function()
	local server = newServer()
	local alice, remote = server.alice, server.remote
	Assert.equal(coinsOf(alice), 0, "a player already present gets a wallet")
	Assert.equal(FakeRoblox.child(alice, "leaderstats").ClassName, "Folder", "the leaderstats is a Folder")
	remote.OnServerEvent:Fire(alice, "a client may add anything", 999)
	Assert.equal(coinsOf(alice), 1, "an acknowledgement earns a coin, whatever the client adds")
	server.now = 0.1
	remote.OnServerEvent:Fire(alice)
	Assert.equal(coinsOf(alice), 1, "an acknowledgement too soon earns nothing")
	server.now = 0.3
	remote.OnServerEvent:Fire(alice)
	Assert.equal(coinsOf(alice), 2, "an acknowledgement after the interval earns a coin")

	local bob = newPlayer(2, "Bob")
	bob.Parent = server.players
	server.players.PlayerAdded:Fire(bob)
	Assert.equal(coinsOf(bob), 0, "a player who joins gets a wallet")
	remote.OnServerEvent:Fire(bob)
	Assert.equal(coinsOf(bob), 1, "players are throttled apart")
end)

case("a player who leaves keeps their coins for the next visit", function()
	local server = newServer()
	local bob = newPlayer(2, "Bob")
	bob.Parent = server.players
	server.players.PlayerAdded:Fire(bob)
	server.remote.OnServerEvent:Fire(bob)
	server.players.PlayerRemoving:Fire(bob)
	bob.Parent = nil
	Assert.equal(FakeRoblox.child(bob, "leaderstats"), nil, "a player who leaves loses their leaderstats")
	Assert.equal(server.registry:Get(2), nil, "their wallet is released")
	server.now = 1
	server.remote.OnServerEvent:Fire(bob)
	Assert.equal(server.registry:Get(2), nil, "a player who has left earns nothing")
	bob.Parent = server.players
	server.players.PlayerAdded:Fire(bob)
	Assert.equal(coinsOf(bob), 1, "a player who comes back has their coins")
end)

case("a wallet loaded for a player who left is released at once", function()
	local players = newPlayers()
	local carol = newPlayer(3, "Carol")
	local released = false
	local repository = {
		Load = function(_: any, userId: number): any
			carol.Parent = nil -- left during the load
			return CoinWalletEntity.new(userId, 0, policy)
		end,
		Save = function(_: any): boolean
			return true
		end,
		Release = function(_: any)
			released = true
		end,
	}
	local registry = CoinWalletRegistry.new()
	local service = CoinSessionService.new(
		RobloxPlayerSessionAdapter.new(players),
		repository,
		LeaderstatsCoinProjection.new(factory),
		registry,
		AcknowledgementThrottlePolicy.new(0),
		Fakes.logger()
	)
	service:StartAsync()
	carol.Parent = players
	players.PlayerAdded:Fire(carol)
	Assert.truthy(released, "the wallet is released at once")
	Assert.equal(registry:Get(3), nil, "and never registered")
	Assert.equal(FakeRoblox.child(carol, "leaderstats"), nil, "nor shown")
	service:StopAsync()
end)

case("stopping, in the order the host stops, releases every wallet and follows no one", function()
	local server = newServer()
	local bob = newPlayer(2, "Bob")
	bob.Parent = server.players
	server.players.PlayerAdded:Fire(bob)
	server.remote.OnServerEvent:Fire(server.alice)
	server.handler:StopAsync()
	server.now = 5
	server.remote.OnServerEvent:Fire(server.alice)
	Assert.equal(coinsOf(server.alice), 1, "a stopped handler rewards nothing")
	server.sessions:StopAsync()
	Assert.truthy(server.registry:Get(1) == nil and server.registry:Get(2) == nil, "every wallet is released")
	Assert.equal(server.repository:Load(1):GetBalance(), 1, "released balances are kept")
	server.players.PlayerAdded:Fire(newPlayer(4, "Dave"))
	Assert.equal(server.registry:Get(4), nil, "a stopped service follows no one")
	server.projection:Dispose()
	Assert.equal(FakeRoblox.child(server.alice, "leaderstats"), nil, "disposing the projection clears the leaderboard")
	Assert.truthy(#server.logs >= 4, "loads and releases are logged")
end)

case("the client reads its balance from the leaderstats", function()
	local projection = LeaderstatsCoinProjection.new(factory)
	local eve = newPlayer(5, "Eve")
	local balance = LeaderstatsCoinBalanceAdapter.new(eve)
	Assert.equal(balance:Get(), 0, "no balance before the server shows one")
	local changes = 0
	local unsubscribe = balance:Subscribe(function()
		changes += 1
	end)
	projection:Show(eve, 7)
	task.wait()
	task.wait()
	Assert.equal(balance:Get(), 7, "the balance appears")
	Assert.equal(changes, 1, "and is reported")
	projection:Update(eve, 8)
	Assert.equal(balance:Get(), 8, "a change is read")
	Assert.equal(changes, 2, "and reported")
	unsubscribe()
	projection:Update(eve, 9)
	Assert.equal(changes, 2, "no change is reported after unsubscribing")

	local frank = newPlayer(6, "Frank")
	local unsubscribeEarly = LeaderstatsCoinBalanceAdapter.new(frank):Subscribe(function()
		changes += 1
	end)
	unsubscribeEarly()
	projection:Show(frank, 1)
	task.wait()
	task.wait()
	Assert.equal(changes, 2, "unsubscribing while waiting cancels the wait")
end)

return { name = "Roblox: compliance coins", cases = cases } :: Assert.Suite
