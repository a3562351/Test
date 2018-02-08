local CardList = import(".CardList")
local AttendantList = import(".AttendantList")
local Entity = import(".Entity")
local Hero = class("Hero", Entity)

local CONST_HP = 30

function Hero:ctor(role_info)
	self.m_hp = 0
	self.m_cur_hp = 0
	self.m_armor = 0
	self.m_cost = 0
	self.m_cur_cost = 0

	self.m_hand = {}
	self.m_deck = CardList.new()
	self.m_dust = CardList.new()
	self.m_attendant = AttendantList.new()

	self.m_idx = 0
	self.m_fatigue_round = 0
end

function Hero:Init()
	self.m_hp = CONST_HP
	self.m_cur_hp = self.m_hp

	self.m_deck:Init(self.m_card_list)
	self.m_deck:Upset()
end

function Hero:GetRoleId()
	return self.m_role_id
end

function Hero:GetRoleName()
	return self.m_role_name
end

function Hero:ChangeCost(value)
	if self.m_cur_cost + value < 0 then
		return false
	end

	self.m_cur_cost = self.m_cur_cost + value
	return true
end

function Hero:SetRoleInfo(role_info)
	self.m_role_id = role_info.role_id
	self.m_role_name = role_info.role_name
	self.m_step = role_info.step
	self.m_card_list = role_info.card_group.card_list
end

function Hero:SetRoom(room)
	self.m_room = room
end

function Hero:SetIdx(idx)
	self.m_idx = idx
end

function Hero:SetSkillId(skill_id)
	self.m_skill_id = skill_id
end

function Hero:OperationHandle()

end

function Hero:PerformSkill(param)
	local skill = self:_GetSkill()
	if skill then

	end
end

function Hero:ApplyInjure(value)
	if value >= 0 then
		self.m_cur_hp = math.min(self.m_cur_hp + value, self.m_hp)
	else
		self.m_armor = self.m_armor + value
		if self.m_armor < 0 then
			self.m_cur_hp = self.m_cur_hp + self.m_armor
			self.m_armor = 0
		end
	end

	self:_CheckAlive()
end

function Hero:AddCardToDeck(card_id)
	self.m_deck:AddCard(card_id)
end

function Hero:AddCardToDust(card_id)
	self.m_dust:AddCard(card_id)
end

function Hero:DrawCard()
	local card_id = self.m_deck:DrawCard()
	if card_id then
		table.insert(self.m_hand, card_id)
	else
		self.m_fatigue_round = self.m_fatigue_round + 1
		self.m_cur_hp = self.m_cur_hp - self.m_fatigue_round
		self:_CheckAlive()
	end
end

function Hero:UseCard(idx, param)
	local card_id = self.m_card_list[idx]
	if not card_id then
		return
	end

	local card = CardManager:CreateCard(card_id)
	card:Use(self, self.m_room:GetHeroList())
end

function Hero:_CheckAlive()
	if self.m_cur_hp <= 0 then

	end
end

function Hero:_GetSkill()
	if not self.m_skill_id then
		return nil
	end

	return SkillManager:CreateSkill(self.m_skill_id)
end

function Hero:_SyncData(msg)
	self.m_room:SyncPublic(self.m_idx, msg)
	self.m_room:SyncSelf(self.m_idx, msg)
end

return Hero
