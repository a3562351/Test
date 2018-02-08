local Card = class("Card")

function Card:ctor()
	self.m_card_id = 0
	self.m_cast = 0
end

function Card:Use(my_hero, hero_list)
	if not my_hero:ChangeCost(-self.m_cast) then
		return
	end

	
end

return Card
