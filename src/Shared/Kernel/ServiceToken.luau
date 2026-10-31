-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[=[
	@class ServiceToken

	A service token names a service in the container and carries its type,
	so that resolving a token returns the type it was registered with.

	서비스 토큰은 컨테이너 안에서 서비스의 이름이 되며 그 타입을 함께 지닌다.
	그래서 토큰으로 꺼낸 서비스는 등록할 때의 타입을 그대로 갖는다.
]=]

--[=[
	@interface ServiceToken
	@within ServiceToken
	.name string -- The name under which the service is registered.

	A token for a service of type T. The type is carried by a field that is never set.

	타입 T 의 서비스를 가리키는 토큰. 타입은 값이 채워지지 않는 필드가 지닌다.
]=]
export type ServiceToken<T> = {
	name: string,
	-- Never set. It exists only to carry T.
	_service: T?,
}

local ServiceToken = {}

--[=[
	Creates a token for a service of type T.

	@within ServiceToken
	@param name string -- The name under which the service is registered, unique within a container.
	@return ServiceToken<T> -- The token.
]=]
function ServiceToken.new<T>(name: string): ServiceToken<T>
	return {
		name = name,
		_service = nil,
	}
end

return ServiceToken
