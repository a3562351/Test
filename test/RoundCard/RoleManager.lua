local Role = import(".Role")
local RoleManager = class("RoleManager")

function RoleManager:ctor()
	self.m_role_list = {}
end

function RoleManager:GetRole(role_id)
	return self.m_role_list[role_id]
end

return RoleManager
