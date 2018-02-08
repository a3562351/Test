local Script = import(".Script")
local Render = import(".Render")
local Entity = class("Entity")

local COMPONENT = {
	SCRIPT = 1,
	RENDER = 2,
}

function Entity:ctor()
	self.m_component = {}
end

function Entity:InitScript()
	local script = Script.new(self)
	self.m_component[COMPONENT.SCRIPT] = script
	return script
end

function Entity:InitRender()
	local render = Render.new(self)
	self.m_component[COMPONENT.RENDER] = render
	return render
end

function Entity:GetComponent(id)
	return self.m_component[id]
end

function Entity:GetScript()
	return self:GetComponent(COMPONENT.SCRIPT)
end

function Entity:GetRender()
	return self:GetComponent(COMPONENT.RENDER)
end

return Entity
