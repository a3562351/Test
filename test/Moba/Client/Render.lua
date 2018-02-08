local Component = import(".Component")
local Render = class("Render", Component, cc.Node)

local STATE = {
	IDLE = 1,
	MOVE = 2,
	ATTACK = 3,
}

local STATE_STR = {
	[STATE.IDLE] = "站立",
	[STATE.MOVE] = "移动",
	[STATE.ATTACK] = "攻击",
}

local ROTATE_SPEED = 180
local MOVE_SPEED = 300

function Render:Awake()
	self:InitView()
end

function Render:Start()
	local role_id = self.m_entity:GetScript():GetRoleId()
	local pic = "ui_skin_bg22_head"..role_id..".png"

	self.m_pic:loadTexture(pic, 1)
end

function Render:InitView()
	self.m_pic = ccui.ImageView:create("ui_skin_bg22_head.png", 1)
	self:addChild(self.m_pic)

	self.m_desc = ccui.Text:create()
	self.m_desc:setFontSize(22)
	self.m_desc:setString("")
	self.m_desc:setPosition(self.m_pic:getContentSize().width/2, self.m_pic:getContentSize().height + 20)
	self.m_pic:addChild(self.m_desc)
end

function Render:AddTouchEvent(listener)
	self.m_pic:setTouchEnabled(true)
	self.m_pic:addTouchEventListener(function (ref, event_type)
		if event_type == ccui.TouchEventType.ended then
			if listener then
				listener(self.m_entity:GetScript():GetRoleId())
			end
		end
	end)
end

function Render:CreateCast(start_pos, callback)
	local cast = ccui.ImageView:create("ui_skin_sign_zhanli.png", 1)
	cast:setPosition(self.m_pic:convertToNodeSpace(start_pos))
	self.m_pic:addChild(cast)

	local function callfunc()
		callback()
		cast:removeFromParent()
	end

	local move_action = cc.MoveTo:create(1, cc.p(self.m_pic:getContentSize().width/2, self.m_pic:getContentSize().height/2))
	cast:runAction(cc.Sequence:create(move_action, cc.CallFunc:create(function()
		callfunc()
	end)))
end

function Render:ExecutionAction(action)
	print("Render:ExecutionAction:"..STATE_STR[action])
	self.m_desc:setString(STATE_STR[action])
end

function Render:IdleAction()
	self:ExecutionAction(STATE.IDLE)
end

function Render:MoveAction(target_pos)
	self:ExecutionAction(STATE.MOVE)
	self:stopAllActions()

	local pos_x, pos_y = self:getPosition()
	local dis = math.sqrt(math.pow(target_pos.x - pos_x, 2) + math.pow(target_pos.y - pos_y, 2))

	local angle = self:ConvertAngle(math.atan2(target_pos.y - pos_y, target_pos.x - pos_x) * 180 / math.pi)
	local angle_diff = math.abs(self:getRotation() - angle)

	local rotate_action = cc.RotateTo:create(angle_diff/ROTATE_SPEED, angle)
	local move_action = cc.MoveTo:create(dis/MOVE_SPEED, target_pos)
	local action = cc.Spawn:create(rotate_action, move_action)
	self:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
		self.m_entity:GetScript():PrepareIdle()
	end)))
end

function Render:AttackAction(target_entity)
	self:ExecutionAction(STATE.ATTACK)
	self:stopAllActions()

	local function create_cast()
		target_entity:GetScript():CreateCast(self:convertToWorldSpaceAR(cc.p(0, 0)))
		self.m_entity:GetScript():PrepareIdle()
	end

	local attack_action = cc.RotateBy:create(0.2, 360)
	self:runAction(cc.Sequence:create(attack_action, cc.CallFunc:create(function()
		create_cast()
	end)))
end

function Render:ConvertAngle(angle)
	return -(angle - 90)
end

return Render
