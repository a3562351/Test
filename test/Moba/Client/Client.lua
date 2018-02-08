local EventCenter = import(".EventCenter")
local BattleField = import(".BattleField")
local Client = class("Client")

local SYNCINTERVAL = 1

function Client:ctor(role_id, step)
	self.m_role_id = role_id
	self.m_step = step

	self.m_event_center = EventCenter.new(self)
end

function Client:GetEventCenter()
	return self.m_event_center
end

function Client:Connect()
	Server:Connect(self.m_role_id, self)
end

function Client:SearchOpponent()
	Server:SearchOpponent(self.m_role_id, self.m_step)
end

function Client:PrepareField()
	self.m_battle_field = BattleField.new(self.m_role_id)
end

function Client:SendEvent(event_info)
	Server:HandleEvent(self.m_role_id, event_info)
end

function Client:SyncState(sync_info)
	if not self.m_battle_field then
		return
	end

	self.m_battle_field:HandleEvent(sync_info)
end

return Client
