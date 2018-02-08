local EffectManager = import(".EffectManager")
local Entity = class("Entity")

function Entity:ctor()
	self.m_effect_manager = EffectManager.new()
end

function Entity:OnAttack()

end

function Entity:OnBeAttack()

end

function Entity:OnCall()

end

function Entity:OnDie()

end

return Entity
