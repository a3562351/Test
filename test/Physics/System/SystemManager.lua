local AnimationSystem = import(".AnimationSystem")
local CollisionSystem = import(".CollisionSystem")
local RigidBodySystem = import(".RigidBodySystem")
local RenderSystem = import(".RenderSystem")
local SystemManager = class("SystemManager")

local SYSTEM_ID = {
	ANIMATION = 1,
	TRANSFORM = 2,
	COLLISION = 3,
	RIGIDBODY = 4,
	RENDER = 5,
}
SystemManager.SYSTEM_ID = SYSTEM_ID

function SystemManager:ctor()
	self.m_system_list = {}
end

function SystemManager:Init()
	table.insert(self.m_system_list, AnimationSystem.new())
	table.insert(self.m_system_list, CollisionSystem.new())
	table.insert(self.m_system_list, RigidBodySystem.new())
	table.insert(self.m_system_list, RenderSystem.new())
end

function SystemManager:GetSystem(system_id)
	return self.m_system_list[system_id]
end

function SystemManager:Update()
	for _, system in ipairs(self.m_system_list) do
		system:Update()
	end
end

cc.exports["SystemManager"] = SystemManager.new()
