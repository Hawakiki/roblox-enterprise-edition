-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The fixtures of the fitness test of ADR-0003, which superseded ADR-0002 and ADR-0001, held as source strings.
	Five of them are wrong on purpose, and EE-STD-0001 §4.1 holds every .luau file in the repository to the type
	checker, so the test writes them under the ignored build/ when it runs (CR-0020, CR-0023, CR-0025).
	ADR-0002 와 ADR-0001 을 대체한 ADR-0003 의 적합도 테스트 예제를 소스 문자열로 둔다. 다섯은 일부러 틀렸고
	EE-STD-0001 §4.1 은 저장소의 모든 .luau 파일을 타입 검사기에 맞춰 검사하게 하므로, 테스트가 돌 때 무시되는
	build/ 아래에 쓴다(CR-0020, CR-0023, CR-0025).
]]

local AdrFitnessFixtures = {}

-- A class whose methods have drifted from their contract in three ways, declared as ADR-0001 declared them:
-- entries that only name the methods. The new solver reports none of the drifts, which is why each is wrapped.
AdrFitnessFixtures.BareDrift = [[
--!strict
export type IRepository = {
	Load: (self: any, userId: number) -> number,
	Save: (self: any, userId: number) -> boolean,
	Release: (self: any, userId: number) -> (),
}

type State = { _base: number }

local Repository = {}
Repository.__index = Repository

export type Repository = typeof(setmetatable({} :: State, Repository))

function Repository.new(): IRepository
	local state: State = { _base = 0 }
	return setmetatable(state, Repository)
end

-- The parameter type has drifted: the contract takes a number.
function Repository.Load(self: Repository, userId: string): number
	return self._base + #userId
end

-- The return type has drifted: the contract returns a boolean.
function Repository.Save(_self: Repository, _userId: number): string
	return "saved"
end

-- One argument more than the contract passes.
function Repository.Release(_self: Repository, _userId: number, _reason: string) end

local _implements: IRepository = {
	Load = Repository.Load,
	Save = Repository.Save,
	Release = Repository.Release,
}

return Repository
]]

-- The same three drifts, declared through wrappers as ADR-0002 decided. The new solver reports each of them.
AdrFitnessFixtures.WrappedDrift = [[
--!strict
export type IRepository = {
	Load: (self: any, userId: number) -> number,
	Save: (self: any, userId: number) -> boolean,
	Release: (self: any, userId: number) -> (),
}

type State = { _base: number }

local Repository = {}
Repository.__index = Repository

export type Repository = typeof(setmetatable({} :: State, Repository))

function Repository.new(): IRepository
	local state: State = { _base = 0 }
	return setmetatable(state, Repository)
end

-- The parameter type has drifted: the contract takes a number.
function Repository.Load(self: Repository, userId: string): number
	return self._base + #userId
end

-- The return type has drifted: the contract returns a boolean.
function Repository.Save(_self: Repository, _userId: number): string
	return "saved"
end

-- One argument more than the contract passes.
function Repository.Release(_self: Repository, _userId: number, _reason: string) end

local _implements: IRepository = {
	Load = function(self: any, userId: number): number
		return Repository.Load(self, userId)
	end,
	Save = function(self: any, userId: number): boolean
		return Repository.Save(self, userId)
	end,
	Release = function(self: any, userId: number)
		Repository.Release(self, userId)
	end,
}

return Repository
]]

-- A class that lacks a method of its contract, behind a wrapper that calls a method of another name. Its
-- constructor returns the instance without a cast, as ADR-0003 decides, and the new solver reports it there.
AdrFitnessFixtures.MissingMethod = [[
--!strict
export type IRepository = {
	Load: (self: any, userId: number) -> number,
	Release: (self: any, userId: number) -> (),
}

type State = { _base: number }

local Repository = {}
Repository.__index = Repository

export type Repository = typeof(setmetatable({} :: State, Repository))

function Repository.new(): IRepository
	local state: State = { _base = 0 }
	return setmetatable(state, Repository)
end

function Repository.Load(self: Repository, userId: number): number
	return self._base + userId
end

-- Renamed: the class no longer has the Release that its contract promises.
function Repository.Release2(_self: Repository, _userId: number) end

local _implements: IRepository = {
	Load = function(self: any, userId: number): number
		return Repository.Load(self, userId)
	end,
	Release = function(self: any, userId: number)
		Repository.Release2(self, userId)
	end,
}

return Repository
]]

-- The pattern as src/ writes it, conforming to its contract: the constructor returns its instance without a cast,
-- and _implements wraps each method. The new solver accepts it.
AdrFitnessFixtures.Conforming = [[
--!strict
export type IRepository = {
	Load: (self: any, userId: number) -> number,
	Save: (self: any, userId: number) -> boolean,
	Release: (self: any, userId: number) -> (),
}

type State = { _base: number }

local Repository = {}
Repository.__index = Repository

export type Repository = typeof(setmetatable({} :: State, Repository))

function Repository.new(): IRepository
	local state: State = { _base = 0 }
	return setmetatable(state, Repository)
end

function Repository.Load(self: Repository, userId: number): number
	return self._base + userId
end

function Repository.Save(_self: Repository, _userId: number): boolean
	return true
end

function Repository.Release(_self: Repository, _userId: number) end

local _implements: IRepository = {
	Load = function(self: any, userId: number): number
		return Repository.Load(self, userId)
	end,
	Save = function(self: any, userId: number): boolean
		return Repository.Save(self, userId)
	end,
	Release = function(self: any, userId: number)
		Repository.Release(self, userId)
	end,
}

return Repository
]]

-- Five mistakes, each of which involves the type parameter of the generic function it stands in: the loss that
-- ADR-0003 accepts. The new solver reports none of them, and the old one, kept as a witness, reports each.
AdrFitnessFixtures.GenericBody = [[
--!strict
-- A value of another type returned as T, from a free function.
local function adopt<T>(_resource: T): T
	return "wrong"
end

-- The same, from a generic method of a class, as ResourceScope.Adopt is written.
type State = { _items: { unknown } }

local Scope = {}
Scope.__index = Scope

type Scope = typeof(setmetatable({} :: State, Scope))

function Scope.Adopt<T>(self: Scope, resource: T): T
	table.insert(self._items, resource)
	return 42
end

-- A T used where a number is required.
local function useAsNumber<T>(resource: T): number
	local count: number = resource
	return count
end

-- A string stored in a local of type T.
local function storeString<T>(resource: T): T
	local held: T = "wrong"
	return if held then resource else resource
end

-- A T passed where a string is required.
local function passOn<T>(resource: T): string
	return string.upper(resource)
end

return { adopt = adopt, Scope = Scope, useAsNumber = useAsNumber, storeString = storeString, passOn = passOn }
]]

-- An error that no solver can miss. It proves that the analyser checked the fixtures at all.
AdrFitnessFixtures.Broken = [[
--!strict
local count: number = "a"

return count
]]

return AdrFitnessFixtures
