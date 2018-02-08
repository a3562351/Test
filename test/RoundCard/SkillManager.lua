local Skill = import(".Skill")
local SkillManager = class("SkillManager")

function SkillManager:ctor()

end

function SkillManager:CreateSkill(skill_id)
	return Skill.new()
end

return SkillManager
