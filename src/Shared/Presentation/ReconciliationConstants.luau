-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ReconciliationConstants

	The limits of the reconciler.

	조정자의 한계.
]=]

local ReconciliationConstants = {}

--[=[
	@prop MAXIMUM_RERENDERS number
	@within ReconciliationConstants
	@readonly
	How many times in a row a component may render again because it was invalidated during its own update, before the reconciler refuses it. Fifty, the maximum update depth of React, which the Numeric Literal Standard does not exempt.
]=]
ReconciliationConstants.MAXIMUM_RERENDERS = 50

return table.freeze(ReconciliationConstants)
