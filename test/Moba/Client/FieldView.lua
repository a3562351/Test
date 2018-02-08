local FieldView = class("FieldView", ccui.Layout)

local POINT = {
	RED = 1,
	BLUE = 2
}

function FieldView:ctor(role_id)
	self.m_role_id = role_id
	self.m_render_list = {}
	self.m_width = display.width - 50
	self.m_height = display.height/2 - 50

	self:setAnchorPoint(0.5, 0.5)
	self:setContentSize(self.m_width, self.m_height)
	self:setBackGroundImage("ui_skin_bg9_blackwindow3.png", 1)
	self:setBackGroundImageScale9Enabled(true)

	self:RegisterEvent()
end

function FieldView:RegisterEvent()
	self:setTouchEnabled(true)
	self:addTouchEventListener(function (ref, touch_type)
		if touch_type == ccui.TouchEventType.ended then
			local pos = ref:convertToNodeSpace(ref:getTouchEndPosition())
			self.m_render_list[self.m_role_id]:GetEntity():GetScript():PrepareMove(pos)
		end
	end)
end

function FieldView:AddRender(render, role_id, point, idx)
	self:addChild(render)
	self.m_render_list[role_id] = render

	local pos = {
		[POINT.RED] = {
			{x = 0, y = 0},
		},
		[POINT.BLUE] = {
			{x = self.m_width, y = self.m_height},
		}
	}
	render:setPosition(pos[point][idx])

	render:AddTouchEvent(function (role_id)
		if role_id ~= self.m_role_id then
			self.m_render_list[self.m_role_id]:GetEntity():GetScript():PrepareAttack(role_id)
		end
	end)
end

return FieldView