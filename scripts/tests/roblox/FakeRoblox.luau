-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Just enough of Roblox to run the modules of src/Shared under Lune: instances with properties, children and
	events, the datatypes and Enum that the modules touch, and a loader that resolves script.Parent requires
	against the folders of src/Shared. Instances are plain tables, so their type is any.
	src/Shared 의 모듈을 Lune 에서 돌릴 만큼만 흉내 낸 Roblox: 속성, 자식, 이벤트를 가진 인스턴스, 모듈이 쓰는
	데이터 타입과 Enum, 그리고 script.Parent 로 쓴 require 를 src/Shared 의 폴더에서 찾아 주는 로더.
	인스턴스는 평범한 테이블이므로 타입은 any 이다.
]]

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local task = require("@lune/task")

local Git = require("../../lib/Git")

local FakeRoblox = {}

-- Every instance created, in order, so that a test can count what an action created.
FakeRoblox.created = {} :: { any }

-- A field read past the metatable. rawget is typed to return an optional value, which these fakes never need.
local function raw(object: any, key: string): any
	return rawget(object, key) :: any
end

-- The children of an instance, in no particular order.
function FakeRoblox.children(parent: any): { any }
	local list = {}
	for instance in raw(parent, "__children") do
		table.insert(list, instance)
	end
	return list
end

local EVENTS = {
	Activated = true,
	Changed = true,
	OnServerEvent = true,
	PlayerAdded = true,
	PlayerRemoving = true,
}

local function newSignal(): any
	local signal: any = { handlers = {} }
	function signal.Connect(self: any, handler: (...any) -> ()): any
		local connection: any = { __kind = "RBXScriptConnection", Connected = true }
		self.handlers[connection] = handler
		function connection.Disconnect(this: any)
			this.Connected = false
			signal.handlers[this] = nil
		end
		return connection
	end
	function signal.Fire(self: any, ...: any)
		for _, handler in self.handlers do
			handler(...)
		end
	end
	function signal.Count(self: any): number
		local count = 0
		for _ in self.handlers do
			count += 1
		end
		return count
	end
	return signal
end

-- The child of an instance with a name, or nil.
function FakeRoblox.child(parent: any, name: string): any
	for instance in raw(parent, "__children") do
		if instance.Name == name then
			return instance
		end
	end
	return nil
end

-- Every child of an instance with a name.
function FakeRoblox.childrenNamed(parent: any, name: string): { any }
	local found = {}
	for instance in raw(parent, "__children") do
		if instance.Name == name then
			table.insert(found, instance)
		end
	end
	return found
end

function FakeRoblox.childCount(parent: any): number
	local count = 0
	for _ in raw(parent, "__children") do
		count += 1
	end
	return count
end

function FakeRoblox.isDestroyed(instance: any): boolean
	return raw(instance, "__destroyed") == true
end

local METHODS: { [string]: any } = {
	FindFirstChild = function(self: any, name: string): any
		return FakeRoblox.child(self, name)
	end,
	WaitForChild = function(self: any, name: string): any
		local found = FakeRoblox.child(self, name)
		while found == nil do
			task.wait()
			found = FakeRoblox.child(self, name)
		end
		return found
	end,
	IsA = function(self: any, className: string): boolean
		return self.ClassName == className
	end,
	Destroy = function(self: any)
		local data = raw(self, "__data")
		if data.Parent then
			raw(data.Parent, "__children")[self] = nil
		end
		data.Parent = nil
		rawset(self, "__destroyed", true)
	end,
}

function FakeRoblox.instance(className: string): any
	local data: { [string]: any } = { ClassName = className, Name = className }
	local instance: any = { __kind = "Instance", __data = data, __children = {}, __signals = {}, __destroyed = false }
	setmetatable(instance, {
		__index = function(self: any, key: string): any
			if EVENTS[key] then
				local signals = raw(self, "__signals")
				if signals[key] == nil then
					signals[key] = newSignal()
				end
				return signals[key]
			end
			local value = raw(self, "__data")[key]
			if value == nil then
				return METHODS[key]
			end
			return value
		end,
		__newindex = function(self: any, key: string, value: any)
			if raw(self, "__destroyed") then
				error(string.format("set %s on a destroyed %s", key, className))
			end
			local own = raw(self, "__data")
			if key == "Parent" then
				if own.Parent then
					raw(own.Parent, "__children")[self] = nil
				end
				if value then
					raw(value, "__children")[self] = true
				end
			end
			own[key] = value
			if key == "Value" then
				local changed = raw(self, "__signals").Changed
				if changed then
					changed:Fire(value)
				end
			end
		end,
	})
	table.insert(FakeRoblox.created, instance)
	return instance
end

local function typeofFake(value: any): string
	if type(value) == "table" and raw(value, "__kind") ~= nil then
		return raw(value, "__kind")
	end
	return typeof(value)
end

-- A datatype such as UDim2, whose constructors record their arguments.
local function datatype(name: string): any
	return setmetatable({}, {
		__index = function(_: any, constructor: string): any
			return function(...: any): any
				return { __type = name .. "." .. constructor, ... }
			end
		end,
	})
end

local Enum = setmetatable({}, {
	__index = function(_: any, group: string): any
		return setmetatable({}, {
			__index = function(_: any, item: string): any
				return "Enum." .. group .. "." .. item
			end,
		})
	end,
})

local repositoryRoot = Git.root()
if repositoryRoot == nil then
	error("the Roblox harness runs inside the repository")
end
local SOURCE = (repositoryRoot :: string) .. "/src/Shared/"

-- Read up front, because a metamethod cannot yield and reading a file does.
local FILES: { [string]: string } = {}
local FOLDERS: { [string]: boolean } = { [""] = true }
local function scan(relative: string)
	for _, name in fs.readDir(SOURCE .. relative) do
		local childRelative = if relative == "" then name else relative .. "/" .. name
		if fs.isDir(SOURCE .. childRelative) then
			FOLDERS[childRelative] = true
			scan(childRelative)
		elseif string.sub(name, -5) == ".luau" then
			FILES[string.sub(childRelative, 1, -6)] = fs.readFile(SOURCE .. childRelative)
		end
	end
end
scan("")

local modules: { [string]: any } = {}
local requireModule: (script: any) -> any

-- Stands in for the script global and its ancestors: indexing it finds a module or a folder of src/Shared.
local function node(relative: string): any
	return setmetatable({ __relative = relative }, {
		__index = function(self: any, key: string): any
			local here: string = raw(self, "__relative")
			if key == "Parent" then
				local above: string? = string.match(here, "^(.*)/[^/]+$")
				return node(above or "")
			end
			local below = if here == "" then key else here .. "/" .. key
			if FILES[below] or FOLDERS[below] then
				return node(below)
			end
			error(string.format("no child %s in /%s", key, here))
		end,
	})
end

requireModule = function(script: any): any
	local relative: string = raw(script, "__relative")
	if modules[relative] == nil then
		local source = FILES[relative]
		if source == nil then
			error("no module " .. relative)
		end
		local chunk = luau.load(source, {
			debugName = relative,
			environment = {
				script = script,
				require = requireModule,
				typeof = typeofFake,
				task = task,
				Enum = Enum,
				UDim = datatype("UDim"),
				UDim2 = datatype("UDim2"),
				Vector2 = datatype("Vector2"),
				Color3 = datatype("Color3"),
			},
		})
		modules[relative] = chunk()
	end
	return modules[relative]
end

-- Requires a module of src/Shared by its path, as in "Domain/CoinConstants".
function FakeRoblox.require(relative: string): any
	return requireModule(node(relative))
end

return FakeRoblox
