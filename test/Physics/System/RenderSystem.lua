local SystemBase = import(".SystemBase")
local RenderSystem = class("RenderSystem", SystemBase)

function RenderSystem:ctor()

end

function RenderSystem:Update()
	local entity_list = EntityManager:GetEntityList()
	for entity_id, entity in pairs(entity_list) do
		local render = entity["Render"]
		if render then
			self:_Execute(entity_id, render)
		end
	end
end

function RenderSystem:_Execute(entity_id, render)
	local entity = EntityManager:GetEntity(entity_id)
	local transform = entity["Transform"]
	if transform then
		render:setPosition(transform:GetPosition())
		render:setRotation(transform:GetRotation())
		render:setScale(transform:GetScale())
	end
end

return RenderSystem
