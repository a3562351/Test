local Component = import(".Component")
local RigidBody = class("RigidBody", Component)

function RigidBody:ctor()
	self.m_force_info = {}
	self.m_move_speed = 0
	self.m_rotate_speed = 0
end

function RigidBody:GetForceInfo()
	return self.m_force_info
end

function RigidBody:GetMoveSpeed()
	return self.m_move_speed
end

function RigidBody:SetMoveSpeed(move_speed)
	self.m_move_speed = move_speed
end

function RigidBody:GetRotateSpeed()
	return self.m_rotate_speed
end

function RigidBody:SetRotateSpeed(rotate_speed)
	self.m_rotate_speed = rotate_speed
end

return RigidBody
