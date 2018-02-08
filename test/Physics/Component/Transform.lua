local Component = import(".Component")
local Transform = class("Transform", Component)

function Transform:ctor()
	self.m_position = {}
	self.m_rotation = {}
	self.m_scale = {}
end

function Transform:GetPosition()
	return self.m_position
end

function Transform:SetPosition(position)
	self.m_position = position
end

function Transform:GetRotation()
	return self.m_rotation
end

function Transform:SetRotation(rotation)
	self.m_rotation = rotation
end

function Transform:GetScale()
	return self.m_scale
end

function Transform:SetScale(scale)
	self.m_scale = scale
end

return Transform
