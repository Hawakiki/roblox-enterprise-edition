-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Fakes of what the coin services work with: a DataStore, players and their sessions, a projection, a logger,
	and gates with which a test decides when a yielding call may go on.
	코인 서비스가 다루는 것의 가짜: DataStore, 플레이어와 세션, 프로젝션, 로거, 그리고 양보한 호출이 언제
	이어질지 테스트가 정하는 게이트.
]]

local task = require("@lune/task")

local FakeRoblox = require("./FakeRoblox")

local Fakes = {}

local function copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, inner in value do
		result[key] = copy(inner)
	end
	return result
end

-- Lets every thread that is ready run, a few frames over.
function Fakes.settle()
	for _ = 1, 10 do
		task.wait()
	end
end

-- Holds whoever waits on it until the test opens it.
function Fakes.gate(): any
	local gate: any = { open = false, waiting = 0 }
	function gate.Wait(self: any)
		self.waiting += 1
		while not self.open do
			task.wait()
		end
		self.waiting -= 1
	end
	function gate.Open(self: any)
		self.open = true
	end
	return gate
end

-- A DataStore that keeps copies of what it is given, as Roblox does, and fails a set number of requests.
function Fakes.dataStore(): any
	local store: any = { records = {}, failures = 0, calls = 0 }
	function store.UpdateAsync(self: any, key: string, transform: (any, any) -> any): any
		self.calls += 1
		if self.failures > 0 then
			self.failures -= 1
			error("the DataStore throttled the request (fake)")
		end
		local result = transform(copy(self.records[key]), {})
		if result ~= nil then
			self.records[key] = copy(result)
		end
		return result
	end
	return store
end

-- A player who is present in a server.
function Fakes.player(userId: number): any
	local player = FakeRoblox.instance("Player")
	player.UserId = userId
	player.Name = "Player" .. tostring(userId)
	player.Parent = FakeRoblox.instance("Players")
	return player
end

-- Sessions that run the handler of each join and leave in a thread of its own, as Roblox runs those of an event.
function Fakes.sessions(): any
	local sessions: any = { kicks = {} }
	function sessions.Subscribe(self: any, onJoined: (any) -> (), onLeaving: (any) -> ()): () -> ()
		self.onJoined, self.onLeaving = onJoined, onLeaving
		return function()
			self.onJoined, self.onLeaving = nil, nil
		end
	end
	function sessions.Kick(self: any, userId: number, message: string)
		table.insert(self.kicks, { userId = userId, message = message })
	end
	function sessions.Join(self: any, player: any)
		if self.onJoined then
			task.spawn(self.onJoined, player)
		end
	end
	function sessions.Leave(self: any, player: any)
		if self.onLeaving then
			task.spawn(self.onLeaving, player)
		end
		player.Parent = nil
	end
	function sessions.Kicked(self: any, userId: number): boolean
		for _, kick in self.kicks do
			if kick.userId == userId then
				return true
			end
		end
		return false
	end
	return sessions
end

function Fakes.projection(): any
	local projection: any = { shown = {} }
	function projection.Show(self: any, player: any, balance: number)
		self.shown[player] = balance
	end
	function projection.Update(self: any, player: any, balance: number)
		if self.shown[player] ~= nil then
			self.shown[player] = balance
		end
	end
	function projection.Remove(self: any, player: any)
		self.shown[player] = nil
	end
	return projection
end

function Fakes.logger(): any
	local logger: any = { lines = {} }
	function logger.Information(self: any, message: string)
		table.insert(self.lines, "INFO " .. message)
	end
	function logger.Warning(self: any, message: string)
		table.insert(self.lines, "WARN " .. message)
	end
	return logger
end

return Fakes
