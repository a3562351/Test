local EntityManager = class("EntityManager")

function EntityManager:ctor()
	self.m_entity_id = 0

	self.m_entity_list = {}
end

function EntityManager:_CreateEntityId()
	self.m_entity_id = self.m_entity_id + 1
	return self.m_entity_id
end

function EntityManager:GetEntity(entity_id)
	return self.m_entity_list[entity_id]
end

function EntityManager:AddEntity(entity)
	self.m_entity_list[self:_CreateEntityId()] = entity
end

function EntityManager:GetEntityList()
	return self.m_entity_list
end

cc.exports["EntityManager"] = EntityManager.new()
