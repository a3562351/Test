local Grid = import(".Grid")
local Map = class("Map", cc.Node)

local MAP_INFO = {
	
}

function Map:ctor()
	self.m_move_pos = {}
end

function Map:InitView()
	self.m_bg = ccui.ImageView:create("ui_skin_bg9_blackwindow3.png", 1)
	self.m_bg:ignoreContentAdaptWithSize(false)
	self.m_bg:setContentSize(MainScene.width, MainScene.height)
	self.m_bg:setScale9Enabled(true)
	self.m_bg:setTouchEnabled(true)
	self:addChild(self.m_bg)

	self:CreateGrid(MAP_INFO)
end

function Map:CreateGrid(map_info)
	for _,v in ipairs(map_info) do
		local mGrid = Grid.new(v)
		mGrid:InitView()

		if mGrid:CanMove() then
			table.insert(self.m_move_pos, mGrid)
		end
	end
end

return Map
