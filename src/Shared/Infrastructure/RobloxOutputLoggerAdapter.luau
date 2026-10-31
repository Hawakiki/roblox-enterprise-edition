-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class RobloxOutputLoggerAdapter

	Implements ILogger on the Roblox output window.

	ILogger 를 Roblox 출력 창으로 구현한다.
]=]

local ILogger = require(script.Parent.Parent.Kernel.ILogger)

type AdapterState = {
	_category: string,
}

local RobloxOutputLoggerAdapter = {}
RobloxOutputLoggerAdapter.__index = RobloxOutputLoggerAdapter

export type RobloxOutputLoggerAdapter = typeof(setmetatable({} :: AdapterState, RobloxOutputLoggerAdapter))

--[=[
	Creates a logger that writes to the output window. Like every constructor, it returns the contract,
	not the implementation.

	@within RobloxOutputLoggerAdapter
	@param category string -- The category that prefixes every message, such as the side the logger runs on.
	@return ILogger -- The logger, as the contract it implements.
]=]
function RobloxOutputLoggerAdapter.new(category: string): ILogger.ILogger
	local state: AdapterState = {
		_category = category,
	}
	return setmetatable(state, RobloxOutputLoggerAdapter) :: any
end

--[=[
	Writes a message that informs, with print.

	@within RobloxOutputLoggerAdapter
	@method Information
	@param message string -- The message.
]=]
function RobloxOutputLoggerAdapter.Information(self: RobloxOutputLoggerAdapter, message: string)
	-- A sanctioned exception to the Prohibited API Registry: this adapter is where the output window is reached.
	print(string.format("[EnterpriseEdition][%s] %s", self._category, message))
end

--[=[
	Writes a message that warns, with warn.

	@within RobloxOutputLoggerAdapter
	@method Warning
	@param message string -- The message.
]=]
function RobloxOutputLoggerAdapter.Warning(self: RobloxOutputLoggerAdapter, message: string)
	-- A sanctioned exception to the Prohibited API Registry: this adapter is where the output window is reached.
	warn(string.format("[EnterpriseEdition][%s] %s", self._category, message))
end

-- Declares the contract this class implements. Each entry is written with the signature of the contract and
-- calls the method, so that both type solvers hold the method to it (EE-STD-0006 §6).
local _implements: ILogger.ILogger = {
	Information = function(self: any, message: string)
		RobloxOutputLoggerAdapter.Information(self, message)
	end,
	Warning = function(self: any, message: string)
		RobloxOutputLoggerAdapter.Warning(self, message)
	end,
}

return RobloxOutputLoggerAdapter
