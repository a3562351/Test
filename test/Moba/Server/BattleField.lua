local Entity = import(".Entity")
local BattleField = class("BattleField")

local SYNCINTERVAL = 1
local OBSDIS = 10
local EVENT_TYPE = {
	LOADDATA = 1,
	IDLE = 2,
	MOVE = 3,
	ATTACK = 4,
}

function BattleField:ctor(field_id)
	self.m_field_id = field_id
	self.m_role_list = {}
	self.m_role_id_list = {}
	self.m_entity_list = {}
	self.m_handle_event = {}
	self.m_last_sync_time = 0
	self.m_event_list = {}

	self:InitHandleEvent()
end

function BattleField:InitHandleEvent()
	local function idle(role_id, data)
		local entity = self.m_entity_list[role_id]
		if not entity then
			return false
		end

		local script = entity:GetScript()
		return script:Idle()
	end
	self.m_handle_event[EVENT_TYPE.IDLE] = idle

	local function move(role_id, data)
		local entity = self.m_entity_list[role_id]
		if not entity then
			return false
		end

		local script = entity:GetScript()
		return script:Move()
	end
	self.m_handle_event[EVENT_TYPE.MOVE] = move

	local function attack(role_id, data)
		local entity = self.m_entity_list[role_id]
		if not entity then
			return false
		end

		local target_entity = self.m_entity_list[data.target_id]
		if not target_entity then
			return false
		end

		local script = entity:GetScript()
		return script:Attack()
	end
	self.m_handle_event[EVENT_TYPE.ATTACK] = attack
end

function BattleField:AddRole(role_id, point, idx)
	local role_info = {}
	role_info.point = point
	role_info.idx = idx
	self.m_role_list[role_id] = role_info
	table.insert(self.m_role_id_list, role_id)
end

function BattleField:LoadData()
	for role_id,v in pairs(self.m_role_list) do
		Server:LoadData(role_id)
	end
end

function BattleField:LoadDataRet(role_id, data)
	local role_info = self.m_role_list[role_id]
	if not role_info then
		return
	end

	for k,v in pairs(data) do
		role_info[k] = v
	end

	local entity = Entity.new()
	self.m_entity_list[role_id] = entity

	local script = entity:InitScript()
	script:SetInfo(role_info)

	entity:Start()

	data.data = role_info
	data.event = EVENT_TYPE.LOADDATA
	data.role_id = role_id
	self:SyncState(data)
end

function BattleField:HandleEvent(event_info)
	local role_id = event_info.role_id
	local role_info = self.m_role_list[role_id]
	if not role_info then
		return
	end

	local func = self.m_handle_event[event_info.event]
	if not func then
		return
	end

	if not func(role_id, event_info.data) then
		return
	end

	self:SyncState(event_info)
end

function BattleField:SyncState(sync_info)
	dump(sync_info, "BattleField:SyncState")
	-- local now_time = os.clock()
	-- sync_info.time = now_time
	-- table.insert(self.m_event_list, sync_info)

	-- if self.m_last_sync_time - now_time < SYNCINTERVAL then
	-- 	return
	-- end

	-- local event_list = self:MergeEvent(self.m_event_list)
	-- self.m_last_sync_time = now_time
	Server:SyncState(sync_info, self.m_role_id_list)
end

function BattleField:MergeEvent()

end

function BattleField:Update()

end

function BattleField:UpdateObsArea(role_id)
	
end

return BattleField
