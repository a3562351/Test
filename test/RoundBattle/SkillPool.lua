local SkillBase = import(".Skill.SkillBase")
local SkillPool = class("SkillPool")

local SKILL_CONFIG = {
	["ORDINARY"] = {injure = 20, Scope = 1},
	["STRENGTHEN"] = {injure = 50, Scope = 1},
	["CRI"] = {injure = 80, Scope = 1},
}

function SkillPool:ctor()
	self.m_skill_map = {}

	self:InitSkill()
end

function SkillPool:InitSkill()
	for k, v in pairs(SKILL_CONFIG) do
		local skill = SkillBase.new(v)
		self.m_skill_map[k] = skill
	end
end

function SkillPool:GetSkill(skill_name)
	return self.m_skill_map[skill_name]
end

return SkillPool
