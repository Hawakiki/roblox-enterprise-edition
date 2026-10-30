-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	A service token names a service in the container and carries its type,
	so that resolving a token returns the type it was registered with.
	서비스 토큰은 컨테이너 안에서 서비스의 이름이 되며 그 타입을 함께 지닌다.
	그래서 토큰으로 꺼낸 서비스는 등록할 때의 타입을 그대로 갖는다.
]]

export type ServiceToken<T> = {
	name: string,
	-- Never set. It exists only to carry T.
	_service: T?,
}

local ServiceToken = {}

function ServiceToken.new<T>(name: string): ServiceToken<T>
	return {
		name = name,
		_service = nil,
	}
end

return ServiceToken
