local CardList = class("CardList")

function CardList:ctor()
	self.m_list = {}
end

function CardList:Init(init_list)
	self.m_list = init_list
end

function CardList:Upset()
	for i = 1, #self.m_list do
		local j = math.random(i, #self.m_list)
		self.m_list[i], self.m_list[j] = self.m_list[j], self.m_list[i]
	end
end

function CardList:Clear()
	self.m_list = {}
end

function CardList:DrawCard()
	local card_id = table.remove(self.m_list, math.random(1, #self.m_list))
	return card_id
end

function CardList:AddCard(card_id)
	table.insert(self.m_list, math.random(1, #self.m_list), card_id)
end

function CardList:HaveSameCard()

end

return CardList
