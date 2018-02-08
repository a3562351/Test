local Component = class("Component")

function Component:ctor(entity)
	self.m_entity = entity
	self:Awake()
end

function Component:Awake()

end

function Component:Start()

end

function Component:Update()

end

function Component:UpdateLater()

end

function Component:GetEntity()
	return self.m_entity
end

return Component