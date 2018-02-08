local Hero = import(".Hero")
local HeroManager = class("HeroManager")

function HeroManager:ctor()

end

function HeroManager:CreateHero(profession)
	local hero = Hero.new()
	hero:SetSkillId(self:_GetSkillId(profession))
	return Hero.new()
end

function HeroManager:_GetSkillId(profession)
	return nil
end

return HeroManager
