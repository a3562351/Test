local BattleView = class("BattleView", cc.Node)

local ATTACKER_POS = {
	[1] = {x = MainScene.width* 1/4, y = MainScene.height * (1/10 + (1-1)/5)},
	[2] = {x = MainScene.width* 1/4, y = MainScene.height * (1/10 + (2-1)/5)},
	[3] = {x = MainScene.width* 1/4, y = MainScene.height * (1/10 + (3-1)/5)},
	[4] = {x = MainScene.width* 1/4, y = MainScene.height * (1/10 + (4-1)/5)},
	[5] = {x = MainScene.width* 1/4, y = MainScene.height * (1/10 + (5-1)/5)},
}

local DEFENSER_POS = {
	[1] = {x = MainScene.width* 3/4, y = MainScene.height * (1/10 + (1-1)/5)},
	[2] = {x = MainScene.width* 3/4, y = MainScene.height * (1/10 + (2-1)/5)},
	[3] = {x = MainScene.width* 3/4, y = MainScene.height * (1/10 + (3-1)/5)},
	[4] = {x = MainScene.width* 3/4, y = MainScene.height * (1/10 + (4-1)/5)},
	[5] = {x = MainScene.width* 3/4, y = MainScene.height * (1/10 + (5-1)/5)},
}

local POS_MOVE_TIME = 0.3
local POS_RADIO = 1

function BattleView:ctor()
	self.m_skill_list = {}
	self:InitView()
	self:RegisterEvent()
end

function BattleView:InitView()
	self.m_bg_mask = ccui.ImageView:create("ui_skin_bg9_blackwindow3.png", 1)
	self.m_bg_mask:ignoreContentAdaptWithSize(false)
	self.m_bg_mask:setContentSize(MainScene.width, MainScene.height)
	self.m_bg_mask:setScale9Enabled(true)
	self.m_bg_mask:setTouchEnabled(true)
	self:addChild(self.m_bg_mask)

	self.m_bg = ccui.ImageView:create("ui_skin_bg9_blackwindow3.png", 1)
	self.m_bg:ignoreContentAdaptWithSize(false)
	self.m_bg:setContentSize(MainScene.width, MainScene.height)
	self.m_bg:setScale9Enabled(true)
	self.m_bg:setTouchEnabled(true)
	self:addChild(self.m_bg)

	self.m_auto_btn = ccui.ImageView:create("ui_skin_btn_bluebig.png", 1)
	self.m_auto_btn:setTouchEnabled(true)
	self.m_auto_btn:setPosition(MainScene.width/2 - 100, -MainScene.height/2 + 50)
	self:addChild(self.m_auto_btn)

	local desc = ccui.Text:create()
	desc:setName("Desc")
	desc:setFontSize(22)
	desc:setString("自动")
	desc:setPosition(self.m_auto_btn:getContentSize().width/2, self.m_auto_btn:getContentSize().height/2)
	self.m_auto_btn:addChild(desc)

	for i = 1, 3 do
		local skill_item = ccui.ImageView:create("ui_skin_bg13_color1.png", 1)
		skill_item:ignoreContentAdaptWithSize(false)
		skill_item:setContentSize(100, 100)
		skill_item:setScale9Enabled(true)
		skill_item:setTouchEnabled(true)
		skill_item:setVisible(false)
		skill_item:setPosition(MainScene.width/2 - skill_item:getContentSize().width/2 - 20, -100*(i-1))
		self:addChild(skill_item)

		local desc = ccui.Text:create()
		desc:setName("Desc")
		desc:setPosition(skill_item:getContentSize().width/2, skill_item:getContentSize().height/2)
		skill_item:addChild(desc)

		self.m_skill_list[i] = skill_item
	end

	self.m_speed_pos = ccui.Layout:create()
	self.m_speed_pos:setBackGroundImage("ui_skin_bg75_card2_activity.png",1)
	self.m_speed_pos:setBackGroundImageScale9Enabled(true)
	self.m_speed_pos:setContentSize(30, 300)
	self.m_speed_pos:setAnchorPoint(0.5, 0.5)
	self.m_speed_pos:setPosition(-300, 0)
	self:addChild(self.m_speed_pos)
end

function BattleView:RegisterEvent()
	self.m_auto_btn:addTouchEventListener(function (ref, touch_type)
		if touch_type == ccui.TouchEventType.began then
			ref:setScale(1.1)
		elseif touch_type == ccui.TouchEventType.canceled then
			ref:setScale(1)
		elseif touch_type == ccui.TouchEventType.ended then
			ref:setScale(1)
			BattleCtrl:ChangeAuto()
		end
	end)
end

function BattleView:ChangeAuto(flag)
	self.m_auto_btn:getChildByName("Desc"):setString(flag and "自动" or "手动")
end

function BattleView:AddRender(render, idx, is_attacker)
	self.m_bg:addChild(render)
	local pos = is_attacker and ATTACKER_POS or DEFENSER_POS
	render:setPosition(pos[idx])

	local pic = ccui.ImageView:create("ui_skin_bg87_line_pianzhang.png", 1)
	pic:setContentSize(40, 40)
	pic:setName(is_attacker and "attacker_"..idx or "defenser_"..idx)
	pic:setPosition(self.m_speed_pos:getContentSize().width/2, self.m_speed_pos:getContentSize().height)
	self.m_speed_pos:addChild(pic)

	local desc = ccui.Text:create()
	desc:setName("Desc")
	desc:setPosition(pic:getContentSize().width/2, pic:getContentSize().height/2)
	desc:setString(is_attacker and "attacker_"..idx or "defenser_"..idx)
	pic:addChild(desc)
end

function BattleView:FindSpeedPosPic(idx, is_attacker)
	return self.m_speed_pos:getChildByName(is_attacker and "attacker_"..idx or "defenser_"..idx)
end

function BattleView:UpdateSpeedPos(idx, is_attacker, pos, callback)
	pos = pos > 300 and 300 or pos

	local pic = self:FindSpeedPosPic(idx, is_attacker)
	pic:stopAllActions()

	local move_action = cc.MoveTo:create(POS_MOVE_TIME, cc.p(pic:getPositionX(), (300 - pos)*POS_RADIO))
	local callfunc = cc.CallFunc:create(function()
		callback()
	end)

	pic:runAction(cc.Sequence:create(move_action, callfunc))
end

function BattleView:ResetSpeedPos(idx, is_attacker)
	local pic = self:FindSpeedPosPic(idx, is_attacker)
	pic:stopAllActions()
	pic:setPositionY(self.m_speed_pos:getContentSize().height)
end

function BattleView:EntityDie(entity)
	local idx = entity:GetScript():GetIdx()
	local is_attacker = entity:GetScript():IsOwn()

	local pic = self:FindSpeedPosPic(idx, is_attacker)
	pic:setVisible(false)
end

function BattleView:ShowEntityInfo(entity, callback)
	local script = entity:GetScript()
	local skill_list = script:GetSkillList()
	for idx, skill_info in ipairs(skill_list) do
		local skill_item = self.m_skill_list[idx]
		skill_item:getChildByName("Desc"):setString(skill_info.skill_name)
		skill_item:setVisible(true)

		skill_item:addTouchEventListener(function (ref, touch_type)
			if touch_type == ccui.TouchEventType.began then
				ref:setScale(1.1)
			elseif touch_type == ccui.TouchEventType.canceled then
				ref:setScale(1)
			elseif touch_type == ccui.TouchEventType.ended then
				ref:setScale(1)
				callback(idx)
			end
		end)
	end
end

function BattleView:CloseEntityInfo()
	for _,v in ipairs(self.m_skill_list) do
		v:setVisible(false)
	end
end

return BattleView
