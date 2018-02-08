local Grid = class("Grid", cc.Node)

local GRID_TYPE = {
	ROAD = 1,
	BUILD = 2
	OBSTACLE = 3,
}

local TYPE_TO_PIC = {
	GRID_TYPE.ROAD = "ui_skin_bg9_blackwindow.png",
	GRID_TYPE.BUILD = "ui_skin_bg9_blackwindow2.png",
	GRID_TYPE.OBSTACLE = "ui_skin_bg9_blackwindow3.png",
}

function Grid:ctor(grid_type)
	self.m_grid_type = grid_type
end

function Grid:InitView()
	self.m_bg = ccui.ImageView:create(TYPE_TO_PIC[self.m_grid_type], 1)
	self.m_bg:ignoreContentAdaptWithSize(false)
	self.m_bg:setContentSize(100, 100)
	self.m_bg:setScale9Enabled(true)
	self.m_bg:setTouchEnabled(true)
	self:addChild(self.m_bg)

	self.m_bg:addTouchEventListener(function (ref, touch_type)
		if touch_type == ccui.TouchEventType.ended then

		end
	end)
end

function Grid:CanMove()
	return self.m_grid_type == GRID_TYPE.ROAD
end

return Grid