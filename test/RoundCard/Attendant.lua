local Entity = import(".Entity")
local Attendant = class("Attendant", Entity)

function Attendant:ctor()
	self.m_hp = 0
	self.m_cur_hp = 0
	self.m_attack = 0
	self.m_cur_attack = 0
end

return Attendant
