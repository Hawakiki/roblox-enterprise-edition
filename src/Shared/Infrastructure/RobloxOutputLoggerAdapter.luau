-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Implements ILogger on the Roblox output window.
	ILogger 를 Roblox 출력 창으로 구현한다.
]]

local ILogger = require(script.Parent.Parent.Kernel.ILogger)

type AdapterState = {
	_category: string,
}

local RobloxOutputLoggerAdapter = {}
RobloxOutputLoggerAdapter.__index = RobloxOutputLoggerAdapter

export type RobloxOutputLoggerAdapter = typeof(setmetatable({} :: AdapterState, RobloxOutputLoggerAdapter))

-- Constructors return the contract, not the implementation.
function RobloxOutputLoggerAdapter.new(category: string): ILogger.ILogger
	local state: AdapterState = {
		_category = category,
	}
	return setmetatable(state, RobloxOutputLoggerAdapter) :: any
end

function RobloxOutputLoggerAdapter.Information(self: RobloxOutputLoggerAdapter, message: string)
	print(string.format("[EnterpriseEdition][%s] %s", self._category, message))
end

function RobloxOutputLoggerAdapter.Warning(self: RobloxOutputLoggerAdapter, message: string)
	warn(string.format("[EnterpriseEdition][%s] %s", self._category, message))
end

-- Declares the contract this class implements; the type checker holds every method to it.
local _implements: ILogger.ILogger = {
	Information = RobloxOutputLoggerAdapter.Information,
	Warning = RobloxOutputLoggerAdapter.Warning,
}

return RobloxOutputLoggerAdapter
