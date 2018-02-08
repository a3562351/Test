local PhysicsWorld = class("PhysicsWorld", ccui.Layout)

function PhysicsWorld:ctor()
	self:setAnchorPoint(0.5, 0.5)
	self:setContentSize(self.m_width, self.m_height)
	self:setBackGroundImage("ui_skin_bg9_blackwindow3.png", 1)
	self:setBackGroundImageScale9Enabled(true)

	self:RegisterEvent()
end

function PhysicsWorld:RegisterEvent()
	self:setTouchEnabled(true)
	self:addTouchEventListener(function (ref, touch_type)
		if touch_type == ccui.TouchEventType.ended then
			local pos = ref:convertToNodeSpace(ref:getTouchEndPosition())
		end
	end)
end

return PhysicsWorld
