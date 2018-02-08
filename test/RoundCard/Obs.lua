local Obs = class("Obs")

function Obs:ctor(role_info)
	self.m_role_id = role_info.role_id
	self.m_role_name = role_info.role_name
end

function Obs:GetRoleId()
	return self.m_role_id
end

function Obs:GetRoleName()
	return self.m_role_name
end

return Obs
