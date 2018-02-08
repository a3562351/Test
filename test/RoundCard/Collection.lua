local Collection = class("Collection")

function Collection:ctor()
	self.m_group_list = {}
end

function Collection:GetGroup(idx)
	return self.m_group_list[idx]
end

function Collection:AddGroup(card_group)
	table.insert(self.m_group_list, card_group)
end

function Collection:DeleteGroup(idx)
	table.remove(self.m_group_list, idx)
end

return Collection
