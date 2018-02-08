local Component = import(".Component")
local Render = class("Render", Component, cc.Node)

local ATTR = {
	ID = 1,
	HP = 2,
	ATTACK = 3,
	DEFENSE = 4,
	SPEED = 5,
	SKILL = 6,
}

local ACTION = {
	IDLE = 1,
	WAITTODO = 2,
	ATTACK = 3,
	DIE = 4,
}

local ACTION_STR = {
	[ACTION.IDLE] = "站立",
	[ACTION.WAITTODO] = "待机",
	[ACTION.ATTACK] = "攻击",
	[ACTION.DIE] = "死亡",
}

local ATTACK_TIME = 0.5

function Render:Awake()
	self.m_attr_list = self.m_entity:GetScript():GetAttrList()
	self.m_callback = nil

	self:InitView()
	self:RegisterEvent()
end

function Render:InitView()
	local id = self.m_attr_list[ATTR.ID]
	local hp = self.m_attr_list[ATTR.HP]

	self.m_pic = ccui.ImageView:create("ui_skin_pgbar1.png", 1)
	self:addChild(self.m_pic)

	self.m_hp = ccui.Text:create()
	self.m_hp:setFontSize(22)
	self.m_hp:setString(hp)
	self.m_hp:setPosition(self.m_pic:getContentSize().width/2, -20)
	self.m_pic:addChild(self.m_hp)

	self.m_desc = ccui.Text:create()
	self.m_desc:setFontSize(22)
	self.m_desc:setString("")
	self.m_desc:setPosition(self.m_pic:getContentSize().width/2, self.m_pic:getContentSize().height + 20)
	self.m_pic:addChild(self.m_desc)

	self.m_tip = ccui.Text:create()
	self.m_tip:setFontSize(22)
	self.m_tip:setString("目标")
	self.m_tip:setPosition(self.m_pic:getContentSize().width/2, self.m_pic:getContentSize().height/2)
	self.m_tip:setVisible(false)
	self.m_pic:addChild(self.m_tip)
end

function Render:RegisterEvent()
	self.m_pic:addTouchEventListener(function (ref, touch_type)
		if touch_type == ccui.TouchEventType.ended then
			if self.m_callback then
				self.m_callback(self.m_entity)
			end
		end
	end)
end

function Render:ChangeHp(hp, hurt)
	self.m_hp:setString(hp)

	local node = cc.Node:create()
	self:addChild(node)

	local str_list = {}
	local function create_str()
		local str = tostring(hurt%10)
		table.insert(str_list, 1, str)
		hurt = math.floor(hurt/10)
		if hurt >= 1 then
			create_str()
		end
	end
	create_str()
	table.insert(str_list, 1, "-")

	local pos_x = 0
	local delay_time = 0
	for _,v in ipairs(str_list) do
		local str = ccui.Text:create()
		str:setFontSize(30)
		str:setTextColor(cc.c3b(255, 0, 0))
		str:setString(v)
		str:setAnchorPoint(0, 0.5)
		str:setPosition(pos_x, 0)
		node:addChild(str)

		local move = cc.Sequence:create(cc.MoveTo:create(0.12, cc.p(pos_x, 20)), cc.MoveTo:create(0.12, cc.p(pos_x, 0)))  
		str:runAction(cc.Spawn:create(cc.Sequence:create(cc.DelayTime:create(delay_time), move) , cc.FadeOut:create(1.5 - delay_time)))
		
		pos_x = pos_x + str:getContentSize().width + 2
		delay_time = delay_time + 0.1
	end

	node:setPositionX(-pos_x/2)
	node:runAction(cc.Sequence:create(cc.FadeOut:create(2), cc.CallFunc:create(function()
		node:removeFromParent()
	end)))
end

function Render:SetTipVisible(flag)
	self.m_tip:setVisible(flag)
end

function Render:AddCallBack(callback)
	self.m_callback = callback
end

function Render:SetTouchEnabled(flag)
	self.m_pic:setTouchEnabled(flag)
end

function Render:ExecutionAction(action)
	self.m_desc:setString(ACTION_STR[action])
end

function Render:IdleAction()
	self:ExecutionAction(ACTION.IDLE)
end

function Render:WaitTodoAction()
	self:ExecutionAction(ACTION.WAITTODO)
end

function Render:AttackAction(target, skill, to_call, back_call)
	self:ExecutionAction(ACTION.ATTACK)

	local move_to = cc.MoveTo:create(ATTACK_TIME, cc.p(target:getPosition()))
	local move_back = cc.MoveTo:create(ATTACK_TIME, cc.p(self:getPosition()))

	local to_func = cc.CallFunc:create(function()
		to_call()
	end)

	local back_func = cc.CallFunc:create(function()
		back_call()
	end)

	self:runAction(cc.Sequence:create(move_to, to_func, move_back, back_func))
end

function Render:DieAction()
	self:ExecutionAction(ACTION.DIE)
end

return Render
