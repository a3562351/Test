local EffectManager = class("EffectManager")

function EffectManager:ctor()
	self.m_effect_list = {}
end

function EffectManager:AddEffect(trigger_type, effect_id)
	local effect_list = self.m_effect_list[trigger_type] or {}
	self.m_effect_list[trigger_type]  = effect_list

	table.insert(effect_list, effect_id)
end

function EffectManager:TriggerEffect(trigger_type)
	local effect_list = self.m_effect_list[trigger_type] or {}
	for _,v in ipairs(effect_list) do
		
	end
end

return EffectManager
