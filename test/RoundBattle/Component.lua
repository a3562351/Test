local Component = class("Component")

function Component:ctor(entity)
	self.m_entity = entity
	self:Awake()
end

function Component:Awake()

end

function Component:Update()

end

return Component