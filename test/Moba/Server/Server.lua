local BattleField = import(".BattleField")
local Server = class("Server")

local ROLELIMIT = 2
local POINT = {
	RED = 1,
	BLUE = 2
}

function Server:ctor()
	self.m_connect_list = {}

	self.m_search_list = {}
	self.m_wait_list = {}
	self.m_field_list = {}
	self.m_role_id_to_field_id = {}

	self.m_max_field_id = 0
end

function Server:Connect(role_id, client)
	-- print(string.format("Role Connect role_id:%d", role_id))
	self.m_connect_list[role_id] = client
end

function Server:GetRoleFieldId(role_id)
	return self.m_role_id_to_field_id[role_id]
end

function Server:GetFieldId()
	self.m_max_field_id = self.m_max_field_id + 1
	return self.m_max_field_id
end

function Server:SearchOpponent(role_id, step)
	-- print(string.format("Role SearchOpponent role_id:%d step:%d", role_id, step))
	if self.m_search_list[role_id] then
		return
	end

	local role_list = self.m_wait_list[step] or {}
	self.m_wait_list[step] = role_list
	table.insert(role_list, role_id)

	if #role_list >= ROLELIMIT then
		local field_id = self:GetFieldId()
		local battle_field = BattleField.new(field_id)
		self.m_field_list[field_id] = battle_field
		for i = ROLELIMIT, 1, -1 do
			local role_id = table.remove(role_list, i)
			local point = i > ROLELIMIT/2 and POINT.RED or POINT.BLUE
			local idx = (i - ROLELIMIT/2) > 0 and (i - ROLELIMIT/2) or -(i - ROLELIMIT/2 - 1)
			battle_field:AddRole(role_id, point, idx)
			self.m_search_list[role_id] = nil
			self.m_role_id_to_field_id[role_id] = field_id
			self:PrepareField(role_id)
		end
		battle_field:LoadData()
	end
end

function Server:PrepareField(role_id)
	local client = self.m_connect_list[role_id]
	if not client then
		return
	end

	client:PrepareField()
end

function Server:ReleaseField(field_id, role_id_list)
	self.m_field_list[field_id] = nil
	for _, role_id in ipairs(role_id_list) do
		self.m_role_id_to_field_id[role_id] = nil
	end
end

function Server:LoadData(role_id)
	self:LoadDataRet(role_id, {role_id = role_id})
end

function Server:LoadDataRet(role_id, data)
	local field_id = self.m_role_id_to_field_id[role_id]
	local battle_field = self.m_field_list[field_id]
	if not battle_field then
		return
	end

	battle_field:LoadDataRet(role_id, data)
end

function Server:HandleEvent(role_id, event_info)
	local field_id = self.m_role_id_to_field_id[role_id]
	local battle_field = self.m_field_list[field_id]
	if not battle_field then
		return
	end

	event_info.role_id = role_id
	battle_field:HandleEvent(event_info)
end

function Server:SyncState(sync_info, role_id_list)
	for _, role_id in ipairs(role_id_list) do
		local client = self.m_connect_list[role_id]
		if client then
			client:SyncState(sync_info)
		end
	end
end

return Server
