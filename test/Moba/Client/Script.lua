local Component = import(".Component")
local Script = class("Script", Component)

local STATE = {
	IDLE = 1,
	MOVE = 2,
	ATTACK = 3,
}

local ATTACK_SPEED = 1

function Script:Awake()
	self.m_state = STATE.IDLE
	self.m_last_attack_time = 0
end

function Script:SetInfo(info)
	self.m_info = info
end

function Script:GetRoleId()
	return self.m_info.role_id
end

function Script:CreateCast(start_pos)
	self.m_entity:GetRender():CreateCast(start_pos, function ()
		self:ApplyAttack()
	end)
end

function Script:ApplyAttack()

end

function Script:PrepareIdle()
	Test:GetClient(self:GetRoleId()):GetEventCenter():IdleEvent()
end

function Script:PrepareMove(target_pos)
	Test:GetClient(self:GetRoleId()):GetEventCenter():MoveEvent(target_pos)
end

function Script:PrepareAttack(target_id)
	local now_time = os.clock()
	if now_time - self.m_last_attack_time < 1/ATTACK_SPEED then
		print("Attack Is In Cooling Time")
		return
	end
	self.m_last_attack_time = now_time

	Test:GetClient(self:GetRoleId()):GetEventCenter():AttackEvent(target_id)
end

function Script:Idle()
	self.m_state = STATE.IDLE
	local render = self.m_entity:GetRender()
	render:IdleAction()
end

function Script:Move(data)
	self.m_state = STATE.MOVE
	local render = self.m_entity:GetRender()
	render:MoveAction(data.target_pos)
end

function Script:Attack(data, target_entity)
	self.m_state = STATE.ATTACK
	local render = self.m_entity:GetRender()
	render:AttackAction(target_entity)
end

return Script
