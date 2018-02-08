local SkillBase = class("SkillBase")

local ATTR = {
	ID = 1,
	HP = 2,
	ATTACK = 3,
	DEFENSE = 4,
	SPEED = 5,
	SKILL = 6,
}

local PLUS_TYPE = {
	ATTACK = 1,
	DEFENSE = 2,
	SPEED = 3,
}

function SkillBase:ctor(config)
	self.m_config = config
end

function SkillBase:Effect(release_entity, receive_entity)
	local attack = self:GetAttack(release_entity)
	local defense = self:GetDefense(receive_entity)
	local injure = attack * (1 - defense/(defense + 100))
	injure = math.floor(injure * math.random(9, 11)/10)
	receive_entity:GetScript():ApplyInjure(injure)
end

function SkillBase:GetAttack(entity)
	local attack = entity:GetScript():GetAttr(ATTR.ATTACK)
	local fixed, percent = entity:GetScript():GetPlus(PLUS_TYPE.ATTACK)
	local value = (attack + self.m_config.injure + fixed) * (1 + percent/100)
	return value
end

function SkillBase:GetDefense(entity)
	local defense = entity:GetScript():GetAttr(ATTR.DEFENSE)
	local fixed, percent = entity:GetScript():GetPlus(PLUS_TYPE.DEFENSE)
	local value = (defense + fixed) * (1 + percent/100)
	return value
end

return SkillBase
