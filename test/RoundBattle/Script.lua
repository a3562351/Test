local Component = import(".Component")
local Script = class("Script", Component)

local COMPONENT = {
	SCRIPT = 1,
	RENDER = 2,
}

local STATE = {
	ACTIVE = 1,
	DIE = 2,
}

local ATTR = {
	ID = 1,
	HP = 2,
	ATTACK = 3,
	DEFENSE = 4,
	SPEED = 5,
	SKILL = 6,
}

local PLUS = {
	ATTACK = 1,
	DEFENSE = 2,
	SPEED = 3,
}

local PLUS_TYPE = {
	ATTACK = 1,
	DEFENSE = 2,
	SPEED = 3,
}

local PLUS_PARAM = {
	PLUS_TYPE = 1,
	FIXED = 2,
	PERCENT = 3,
	ROUNDS = 4,
	STARTROUND = 5,
}

function Script:Awake()
	self.m_is_own = false
	self.m_can_handle = false
	self.m_state = STATE.ACTIVE
	self.m_idx = 0
	self.m_cur_hp = 0
	self.m_attr_list = {}
	self.m_plus_list = {}
	self.m_skill_list = {}
	self.m_round = 0
end

function Script:IsOwn()
	return self.m_is_own
end

function Script:SetIsOwn(flag)
	self.m_is_own = flag
end

function Script:CanHandle()
	return self.m_can_handle
end

function Script:SetCanHandle(flag)
	self.m_can_handle = flag
end

function Script:IsActive()
	return self.m_state == STATE.ACTIVE
end

function Script:GetIdx()
	return self.m_idx
end

function Script:SetIdx(idx)
	self.m_idx = idx
end

function Script:GetAttr(attr)
	return self.m_attr_list[attr]
end

function Script:GetAttrList()
	return self.m_attr_list
end

function Script:SetAttrList(attr_list)
	self.m_attr_list = attr_list
	self.m_cur_hp = self.m_attr_list[ATTR.HP]

	for idx, skill_info in ipairs(self.m_attr_list[ATTR.SKILL]) do
		self.m_skill_list[idx] = {skill_name = skill_info.skill_name, level = skill_info.level, release_round = self.m_round}
	end
end

function Script:GetId()
	return self.m_attr_list[ATTR.ID]
end

function Script:GetCurHp()
	return self.m_cur_hp
end

function Script:ApplyInjure(injure)
	self.m_cur_hp = self.m_cur_hp - injure

	if self.m_entity:GetRender() then
		self.m_entity:GetRender():ChangeHp(self.m_cur_hp, injure)
	end
end

function Script:GetPlus(plus_type)
	local fixed, percent = 0, 0
	for _, plus in pairs(self.m_plus_list) do
		if v[PLUS_PARAM.PLUS_TYPE] == plus_type then
			fixed = fixed + (plus[PLUS_PARAM.FIXED] or 0)
			percent = percent + (plus[PLUS_PARAM.PERCENT] or 0)
		end
	end
	return fixed, percent
end

function Script:GetSpeed()
	local fixed, percent = self:GetPlus(PLUS_TYPE.SPEED)
	return (self.m_attr_list[ATTR.SPEED] + fixed) * (1 + percent)
end

function Script:ChangeState(state)
	self.m_state = state
end

function Script:GetSkillList()
	return self.m_skill_list
end

function Script:OnRound()
	self.m_round = self.m_round + 1

	for plus_id, plus in pairs(self.m_plus_list) do
		local rounds = plus[PLUS_PARAM.ROUNDS] or 0
		local start_round = plus[PLUS_PARAM.STARTROUND] or 0
		if rounds + start_round > self.m_round then
			self.m_plus_list[plus_id] = nil
		end
	end

	return true
end

function Script:ReleaseSkill(idx, entity)
	local skill_info = self.m_skill_list[idx]
	skill_info.release_round = self.m_round
	local skill = SkillPool:GetSkill(skill_info.skill_name)

	if self.m_entity:GetRender() then
		local to_call = function ()
			entity:GetScript():ApplySkillEffect(skill, self.m_entity)
		end

		local back_call = function ()
			self.m_entity:GetRender():IdleAction()
			BattleCtrl:EntityActionOver(self.m_entity)
		end

		self.m_entity:GetRender():AttackAction(entity:GetRender(), skill, to_call, back_call)
	else
		entity:GetScript():ApplySkillEffect(skill, self.m_entity)
		BattleCtrl:EntityActionOver(self.m_entity)
	end
end

function Script:ApplySkillEffect(skill, entity)
	skill:Effect(entity, self.m_entity)

	if self.m_cur_hp <= 0 then
		self.m_state = STATE.DIE
		BattleCtrl:EntityDie(self.m_entity)

		if self.m_entity:GetRender() then
			self.m_entity:GetRender():DieAction()
		end
	end
end

return Script
