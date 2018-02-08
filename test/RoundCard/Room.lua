local Obs = import("Obs")
local Room = class("Room")

local ROUND_TIME = 60

function Room:ctor(room_id)
	self.m_room_id = room_id
	self:Clear()
end

function Room:Clear()
	self.m_is_free = true

	self.m_role_id_to_hero = {}
	self.m_hero_list = {}
	self.m_leave_idx = {}
	self.m_obs_list = {}
	self.m_perform_list = {}
	self.m_attendant_list = {}

	self.m_round = 0
	self.m_turn_idx = 0
	self.m_interval_time = 0
end

function Room:IsFree()
	return self.m_is_free
end

function Room:GetRoomId()
	return self.m_room_id
end

function Room:GetHeroList()
	return self.m_hero_list
end

function Room:Perpare()
	self.m_is_free = false
end

function Room:RoleEnterRoom(role_info)
	local card_group = role_info.card_group
	local hero = HeroManager:CreateHero(card_group.profession)
	hero:SetRoleInfo(role_info)
	hero:SetRoom(self)
	hero:Init()

	table.insert(self.m_hero_list, hero)
	hero:SetIdx(#self.m_hero_list)

	self.m_role_id_to_hero[role_info.role_id] = hero
end

function Room:RoleLeaveRoom(idx)
	self.m_leave_idx[idx] = true
end

function Room:ObsEnterRoom(role_info, target_role_id)
	local obs = Obs.new(role_info)

	for idx, hero in ipairs(self.m_hero_list) do
		if hero:GetRoleId() == target_role_id then
			local obs_list = self.m_obs_list[idx] or {}
			self.m_obs_list[idx] = obs_list

			obs_list[role_info.role_id] = obs
			break
		end
	end
end

function Room:ObsLeaveRoom(idx, role_id)
	
end

function Room:OperationHandle(role_id, data)
	local hero = self.m_role_id_to_hero[role_id]
	if not hero then
		return
	end

	hero:OperationHandle(data)
end

function Room:SyncPublic(exclude_idx, msg)
	for idx, hero in ipairs(self.m_hero_list) do
		if idx ~= exclude_idx then
			local role = RoleManager:GetRole(hero:GetRoleId())
			if role then
				role:SendMsg(msg)
			end
		end
	end

	for idx, obs_list in pairs(self.m_obs_list) do
		if idx ~= exclude_idx then
			for role_id,v in pairs(obs_list) do
				local role = RoleManager:GetRole(role_id)
				if role then
					role:SendMsg(msg)
				end
			end
		end
	end
end

function Room:SyncSelf(idx, msg)
	local hero = self.m_hero_list[idx]
	if hero then
		local role = RoleManager:GetRole(hero:GetRoleId())
		if role then
			role:SendMsg(msg)
		end
	end
	
	local obs_list = self.m_obs_list[idx]
	for role_id,v in pairs(obs_list) do
		local role = RoleManager:GetRole(role_id)
		if role then
			role:SendMsg(msg)
		end
	end
end

function Room:Update(interval)
	self.m_interval_time = self.m_interval_time + interval
	if self.m_interval_time >= ROUND_TIME then
		self.m_interval_time = 0
		self:RoundEnd()
	end
end

function Room:RoundStart()
	for _, hero in ipairs(self.m_hero_list) do
		hero:RoundStart()
	end
end

function Room:RoundEnd()
	for _, hero in ipairs(self.m_hero_list) do
		hero:RoundEnd()
	end
end

return Room
