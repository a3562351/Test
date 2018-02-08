local Room = import(".Room")
local RoomManager = class("RoomManager")

local MAX_ROOM_ID = 100

function RoomManager:ctor()
	self.m_max_room_id = 0
	self.m_list = {}
	self.m_free_id_list = {}
end

function RoomManager:Update()
	for _, room in pairs(self.m_list) do
		room:Update()
	end
end

function RoomManager:RoleEnterRoom(room_id, role_info)
	local room = self.m_list[room_id]
	room:RoleEnterRoom(role_info)
end

function RoomManager:ObsEnterRoom(room_id)
	local room = self.m_list[room_id]
	if room then
		room
		return true
	end
	return false
end

function RoomManager:GetRoomId()
	local room = self:CreateRoom()
	if not room then
		return nil
	end
	return room:GetRoomId()
end

function RoomManager:CreateRoom()
	if #self.m_free_id_list > 0 then
		local room_id = table.remove(self.m_free_id_list, math.random(1, #self.m_free_id_list))
		local room = self.m_list[room_id]
		if room:IsFree() then
			room:Perpare()
			return room
		end
	end

	local room_id = self:_CreateRoomId()
	if not room_id then
		return nil
	end

	local room = Room.new(room_id)
	room:Perpare()
	self.m_list[room_id] = room
	
	return room
end

function RoomManager:ReleaseRoom(room_id)
	self.m_list[room_id] = nil
end

function RoomManager:_CreateRoomId()
	if self.m_max_room_id >= MAX_ROOM_ID then
		return nil
	end

	self.m_max_room_id = self.m_max_room_id + 1
	return self.m_max_room_id
end

return RoomManager
