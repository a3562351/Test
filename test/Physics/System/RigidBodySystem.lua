local SystemBase = import(".SystemBase")
local RigidBodySystem = class("RigidBodySystem", SystemBase)

function RigidBodySystem:ctor()

end

function RigidBodySystem:Update(interval)
	local entity_list = EntityManager:GetEntityList()
	for entity_id, entity in pairs(entity_list) do
		local rigidbody = entity["RigidBody"]
		if rigidbody then
			self:_Execute(entity_id, rigidbody)
		end
	end
end

function RigidBodySystem:_Execute(entity_id, rigidbody)
	local force_info = rigidbody:GetForceInfo()
	local move_speed = rigidbody:GetMoveSpeed()
	local rotate_speed = rigidbody:GetRotateSpeed()


end

return RigidBodySystem
