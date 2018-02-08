local EventCenter = class("EventCenter")

local EVENT_TYPE = {
	LOADDATA = 1,
	IDLE = 2,
	MOVE = 3,
	ATTACK = 4,
}

function EventCenter:ctor(client)
	self.m_client = client
end

function EventCenter:IdleEvent()
	local data = {}

	local event_info = {}
	event_info.event = EVENT_TYPE.IDLE
	event_info.data = data

	self:CreateEvent(event_info)
end

function EventCenter:MoveEvent(target_pos)
	local data = {}
	data.target_pos = target_pos

	local event_info = {}
	event_info.event = EVENT_TYPE.MOVE
	event_info.data = data

	self:CreateEvent(event_info)
end

function EventCenter:AttackEvent(target_id)
	local data = {}
	data.target_id = target_id

	local event_info = {}
	event_info.event = EVENT_TYPE.ATTACK
	event_info.data = data

	self:CreateEvent(event_info)
end

function EventCenter:CreateEvent(event_info)
	self.m_client:SendEvent(event_info)
end

return EventCenter