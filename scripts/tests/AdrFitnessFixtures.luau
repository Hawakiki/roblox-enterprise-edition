-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	The fixtures of the fitness test of ADR-0002, which superseded ADR-0001, held as source strings. Four of them
	are wrong on purpose, and EE-STD-0001 §4.1 holds every .luau file in the repository to both solvers, so the
	test writes them under the ignored build/ when it runs (CR-0020, CR-0023).
	ADR-0001 을 대체한 ADR-0002 의 적합도 테스트 예제를 소스 문자열로 둔다. 넷은 일부러 틀렸고 EE-STD-0001
	§4.1 은 저장소의 모든 .luau 파일을 두 솔버에 맞춰 검사하게 하므로, 테스트가 돌 때 무시되는 build/ 아래에
	쓴다(CR-0020, CR-0023).
]]

local AdrFitnessFixtures = {}

-- A class whose methods have drifted from their contract in three ways, declared as ADR-0001 declared them:
-- entries that only name the methods. The old solver reports each drift, and the new solver none.
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
	return setmetatable(state, Repository) :: any
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

-- The same three drifts, declared through wrappers as ADR-0002 decides. Both solvers report each of them.
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
	return setmetatable(state, Repository) :: any
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

-- A conforming class whose constructor returns its instance as its contract without the cast through any.
-- The old solver refuses it, and the new solver accepts it.
AdrFitnessFixtures.NoCast = [[
--!strict
export type IRepository = {
	Load: (self: any, userId: number) -> number,
	Save: (self: any, userId: number) -> boolean,
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

return Repository
]]

-- The pattern as src/ writes it, conforming to its contract: the cast through any, and _implements with a
-- wrapper for each method. Both solvers accept it.
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
	return setmetatable(state, Repository) :: any
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

-- An error that no solver can miss. Both report it, which proves that the analyser checked the fixtures at all.
AdrFitnessFixtures.Broken = [[
--!strict
local count: number = "a"

return count
]]

return AdrFitnessFixtures
