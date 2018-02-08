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

function Script:ApplyAttack()

end

function Script:Idle()
	self.m_state = STATE.IDLE
	return true
end

function Script:Move(data)
	self.m_state = STATE.MOVE
	return true
end

function Script:Attack(data, target_entity)
	local now_time = os.clock()
	if now_time - self.m_last_attack_time < 1/ATTACK_SPEED then
		print("Attack Is In Cooling Time")
		return false
	end
	self.m_last_attack_time = now_time

	self.m_state = STATE.ATTACK
	return true
end

return Script
