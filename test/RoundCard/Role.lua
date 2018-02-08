local Collection = import(".Collection")
local Friend = import(".Friend")
local Role = class("Role")

local STATE = {
	FREE = 1,
	PREPARE = 2,
	WORKING = 3,
}

function Role:ctor(role_id)
	self.m_role_id = role_id
	self.m_role_name = ""
	self.m_step = 0

	self.m_online = false
	self.m_state = STATE.FREE
	self.m_room_id = 0

	self.m_collection = Collection.new()
	self.m_friend = Friend.new()
end

function Role:GetRoleId()
	return self.m_role_id
end

function Role:GetRoleName()
	return self.m_role_name
end

function Role:GetStep()
	return self.m_step
end

function Role:IsFree()
	return self.m_state == STATE.FREE
end

function Role:IsPrepare()
	return self.m_state == STATE.PREPARE
end

function Role:IsWorking()
	return self.m_state == STATE.WORKING
end

function Role:Free()
	self.m_state = STATE.FREE
end

function Role:Prepare()
	self.m_state == STATE.PREPARE
end

function Role:Working(room_id)
	self.m_state == STATE.WORKING

	self.m_room_id = room_id
end

function Role:GetRoomId()
	return self.m_room_id
end

function Role:GetCardGroup(idx)
	return self.m_collection:GetGroup(idx)
end

function Role:AddCardGroup(card_group)
	self.m_collection:AddGroup(card_group)
end

function Role:DeleteCardGroup(idx)
	self.m_collection:DeleteGroup(idx)
end

function Role:Online()
	self.m_online = true
end

function Role:Offline()
	self.m_online = false
end

function Role:GetProfile()
	local profile = {}
	profile.role_id = self.m_role_id
	profile.role_name = self.m_role_name
	profile.step = self.m_step
	profile.state = self.m_state
	return profile
end

function Role:ObsFriend(role_id)
	if not self.m_friend:HaveFriend(role_id) then
		return
	end

	local role = RoleManager:GetRole(role_id)
	if role and role:IsWorking() and not RoomManager:ObsEnterRoom(role:GetRoomId()) then
		self:Notive()
	end
end

function Role:SendMsg(msg)

end

function Role:Notive(code, param)

end

return Role
