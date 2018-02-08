local Queue = import(".Queue")
local MatchManager = class("MatchManager")

local MAX_ROLE = 2

function MatchManager:ctor()
	self.m_wait_list = {}
	self.m_step_list = {}
end

function MatchManager:EnterMatch(role_id, step, group_id)
	if self.m_wait_list[role_id] then
		return
	end

	self.m_wait_list[role_id] = step

	if not self.m_step_list[step] then
		self.m_step_list[step] = Queue.new()
	end

	local role_data = {group_id = group_id, create_time = self:_GetNowTime()}
	local queue = self.m_step_list[step]
	queue:Add(role_id, role_data)

	self:_CheckMatch(queue)
end

function MatchManager:CancelMatch(role_id, step)
	local step = self.m_wait_list[role_id]
	if not step then
		return
	end

	self.m_wait_list[role_id] = nil

	local queue = self.m_step_list[step]
	if queue then
		queue:Remove(role_id)
	end
end

function MatchManager:_CheckMatch(queue)
	if queue:Length() < MAX_ROLE then
		return
	end

	local role_id_list = {}
	local role_id_count = 0
	for i = 1, queue:Length() do
		local role_id, role_data = queue:Pop()
		if role_id and not role_id_list[role_id] then
			role_id_list[role_id] = role_data
			role_id_count = role_id_count + 1
		end
	end

	if role_id_count < MAX_ROLE then
		for role_id, role_data in pairs(role_id_list) do
			queue:Add(role_id, role_data)
		end
		return
	end

	local role_list = {}
	for role_id, role_data in pairs(role_id_list) do
		local role = RoleManager:GetRole(role_id)
		if role and role:IsPrepare() then
			table.insert(role_list, role)
		else
			role_id_list[role_id] = nil
		end
	end

	if #role_list < MAX_ROLE then
		for role_id, role_data in pairs(role_id_list) do
			queue:Add(role_id, role_data)
		end
		return
	end

	local room_id = RoomManager:GetRoomId()
	if not room_id then
		for _, role in ipairs(role_list) do
			role:Free()
			role:Notive()
		end
		return
	end

	for _, role in ipairs(role_list) do
		role:Working(room_id)
		local role_id = role:GetRoleId()
		local role_data = self.m_wait_list[role_id]
		local card_group = role:GetCardGroup(role_data.group_id)

		local role_info = {role_id = role_id, role_name = role:GetRoleName(), step = role:GetStep(), card_group = card_group}
		RoomManager:RoleEnterRoom(room_id, role_info)

		self.m_wait_list[role_id] = nil
	end

	for _, role in ipairs(role_list) do
		role:Working()
		role:GetCardGroup()
	end
end

function MatchManager:_GetNowTime()
	return os.time()
end

return MatchManager
