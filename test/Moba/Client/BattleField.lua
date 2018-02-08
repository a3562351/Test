local Entity = import(".Entity")
local FieldView = import(".FieldView")
local BattleField = class("BattleField")

local OBSDIS = 10
local EVENT_TYPE = {
	LOADDATA = 1,
	IDLE = 2,
	MOVE = 3,
	ATTACK = 4,
}

function BattleField:ctor(role_id)
	self.m_role_list = {}
	self.m_entity_list = {}
	self.m_handle_event = {}

	self:InitHandleEvent()

	self:Draw(role_id)
end

function BattleField:Draw(role_id)
	self.m_field_view = FieldView.new(role_id)
	self.m_field_view:setPosition(display.width/2, display.height/4 + display.height/2*(role_id - 1))
	MainScene:addChild(self.m_field_view, 100000)
end

function BattleField:InitHandleEvent()
	local function load_data(role_id, data)
		local role_info = self.m_role_list[role_id] or {}
		self.m_role_list[role_id] = role_info

		for k,v in pairs(data) do
			role_info[k] = v
		end

		local entity = Entity.new()
		self.m_entity_list[role_id] = entity

		local script = entity:InitScript()
		script:SetInfo(role_info)

		local render = entity:InitRender()
		self.m_field_view:AddRender(render, role_info.role_id, role_info.point, role_info.idx)

		entity:Start()
	end
	self.m_handle_event[EVENT_TYPE.LOADDATA] = load_data

	local function idle(role_id, data)
		local entity = self.m_entity_list[role_id]
		if not entity then
			return
		end

		local script = entity:GetScript()
		script:Idle()
	end
	self.m_handle_event[EVENT_TYPE.IDLE] = idle

	local function move(role_id, data)
		local entity = self.m_entity_list[role_id]
		if not entity then
			return
		end

		local script = entity:GetScript()
		script:Move(data)
	end
	self.m_handle_event[EVENT_TYPE.MOVE] = move

	local function attack(role_id, data)
		local entity = self.m_entity_list[role_id]
		if not entity then
			return
		end

		local target_entity = self.m_entity_list[data.target_id]
		if not target_entity then
			return
		end

		local script = entity:GetScript()
		script:Attack(data, target_entity)
	end
	self.m_handle_event[EVENT_TYPE.ATTACK] = attack
end

function BattleField:HandleEvent(event_info)
	local func = self.m_handle_event[event_info.event]
	if not func then
		return
	end

	func(event_info.role_id, event_info.data)
end

return BattleField
