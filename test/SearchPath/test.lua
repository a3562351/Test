local MAP_WIDTH = 40
local MAP_HEIGHT = 40
local GRID_SIZE = 30
local OBSTACLE_RATIO = 4
local START_GRID_X = 1
local START_GRID_Y = 1
local END_GRID_X = MAP_WIDTH
local END_GRID_Y = MAP_HEIGHT

local Map = class("Map")

function Map:ctor()
	self:Init()
end

function Map:Init()
	self.m_node = cc.Node:create()
	self.m_node:setPosition(MainScene.width/2, MainScene.height/2)
	MainScene:addChild(self.m_node, 100000)

	self.m_bg = ccui.ImageView:create("ui_skin_bg9_blackwindow3.png", 1)
	self.m_bg:ignoreContentAdaptWithSize(false)
	self.m_bg:setContentSize(MainScene.width, MainScene.height)
	self.m_bg:setScale9Enabled(true)
	self.m_node:addChild(self.m_bg)

	self:CreateMap()
end

function Map:CreateMap()
	self.m_map_list = {}
	self:CreateGrid()
	self:CreateObstacle()

	self:DrawMap()
end

function Map:CreateGridId(i, j)
	return (i-1) * MAP_HEIGHT + j
end

function Map:CreateGrid()
	for i = 1, MAP_HEIGHT do
		self.m_map_list[i] = {}
		for j = 1, MAP_WIDTH do
			self.m_map_list[i][j] = {grid_id = self:CreateGridId(i, j), can_move = true}
		end
	end
end

function Map:CreateObstacle()
	for i = 1, MAP_WIDTH * MAP_HEIGHT/OBSTACLE_RATIO do
		local grid_x = math.random(1, MAP_WIDTH)
		local grid_y =  math.random(1, MAP_HEIGHT)
		self.m_map_list[grid_y][grid_x].can_move = false
	end
	self.m_map_list[START_GRID_Y][START_GRID_X].can_move = true
	self.m_map_list[END_GRID_Y][END_GRID_X].can_move = true
end

function Map:MoveMapPos(delta)
	local pos_x = self.m_content:getPositionX() + delta.x
	local pos_y = self.m_content:getPositionY() + delta.y

	self.m_content:setPosition(pos_x, pos_y)
end

function Map:DrawMap()
	-- local str = ""
	-- for _, map_x in ipairs(self.m_map_list) do
	-- 	for _, grid in ipairs(map_x) do
	-- 		str = str..tostring(grid.can_move and 1 or 0)
	-- 	end
	-- 	str = str.."\n"
	-- end
	-- print(str)

	if self.m_content and not tolua.isnull(self.m_content) then
		self.m_content:removeFromParent()
	end

	self.m_content = ccui.ImageView:create("ui_skin_bg41.png", 1)
	self.m_content:ignoreContentAdaptWithSize(false)
	self.m_content:setContentSize(MAP_WIDTH * GRID_SIZE, MAP_HEIGHT * GRID_SIZE)
	self.m_content:setScale9Enabled(true)
	self.m_node:addChild(self.m_content)

	self.m_content:setTouchEnabled(true)
	self.m_content:addTouchEventListener(function (ref, touch_type)
		if touch_type == ccui.TouchEventType.began then
			self.m_touch_start_pos = ref:getTouchBeganPosition()
		elseif touch_type == ccui.TouchEventType.moved then
			local pos = ref:getTouchMovePosition()
			local delta = {}
			delta.x = pos.x - self.m_touch_start_pos.x
			delta.y = pos.y - self.m_touch_start_pos.y
			self.m_touch_start_pos = pos

			self:MoveMapPos(delta)
		end
	end)

	for grid_y, map_x in ipairs(self.m_map_list) do
		for grid_x, grid in ipairs(map_x) do
			local mImageView = ccui.ImageView:create()
			if grid.can_move then
				mImageView:loadTexture("ui_skin_bg40.png", 1)
			else
				mImageView:loadTexture("ui_skin_bg41.png", 1)
			end
			mImageView:setContentSize(GRID_SIZE*9/10, GRID_SIZE*9/10)
			mImageView:setScale9Enabled(true)
			mImageView:setPosition(self:ConvertToPos(grid_x, grid_y))
			self.m_content:addChild(mImageView)
		end
	end
end

function Map:DrawPath(move_pos_list, search_pos_list)
	-- local str = ""
	-- for _,v in ipairs(pos_list) do
	-- 	str = str..string.format("(%d,%d)", v.x, v.y)
	-- end
	-- print(str)

	for _,v in ipairs(search_pos_list) do
		local path_root = ccui.ImageView:create("ui_skin_bg87_line_pianzhang.png", 1)
		path_root:setContentSize(GRID_SIZE*4/5, GRID_SIZE*4/5)
		path_root:setScale9Enabled(true)
		path_root:setPosition(v.x, v.y)
		self.m_content:addChild(path_root)
	end

	for _,v in ipairs(move_pos_list) do
		local path_root = ccui.ImageView:create("ui_skin_bg48.png", 1)
		path_root:setContentSize(GRID_SIZE/2, GRID_SIZE/2)
		path_root:setScale9Enabled(true)
		path_root:setPosition(v.x, v.y)
		self.m_content:addChild(path_root)
	end
end

function Map:GetGrid(grid_x, grid_y)
	if self.m_map_list[grid_y] then
		local grid = self.m_map_list[grid_y][grid_x]
		if grid then
			return {grid_id = grid.grid_id, grid_x = grid_x, grid_y = grid_y, can_move = grid.can_move}
		end
	end
	return nil
end

function Map:GetNearbyGridList(grid_x, grid_y)
	local grid_list = {}

	local grid_top = self:GetGrid(grid_x, grid_y + 1)
	if grid_top then
		table.insert(grid_list, grid_top)
	end

	local grid_right = self:GetGrid(grid_x + 1, grid_y)
	if grid_right then
		table.insert(grid_list, grid_right)
	end

	local grid_bottom = self:GetGrid(grid_x, grid_y - 1)
	if grid_bottom then
		table.insert(grid_list, grid_bottom)
	end

	local grid_left = self:GetGrid(grid_x - 1, grid_y)
	if grid_left then
		table.insert(grid_list, grid_left)
	end

	return grid_list
end

function Map:GetDistance(start_x, start_y, end_x, end_y)
	-- return math.sqrt(math.pow(2, (end_x - start_x)) + math.pow(2, (end_y - start_y)))
	return math.pow(2, (end_x - start_x)) + math.pow(2, (end_y - start_y))
end

function Map:ConvertToPos(grid_x, grid_y)
	return grid_x * GRID_SIZE - GRID_SIZE/2, grid_y * GRID_SIZE - GRID_SIZE/2
end


local Grid = class("Grid")

function Grid:ctor(grid_x, grid_y, parent)
	self.m_grid_x = grid_x
	self.m_grid_y = grid_y
	self.m_parent = parent
end

function Grid:GetGridPos()
	return self.m_grid_x, self.m_grid_y
end

function Grid:GetParent()
	return self.m_parent
end


local PathSearch = class("PathSearch")

function PathSearch:ctor()

end

function PathSearch:FindPath(map, start_x, start_y, end_x, end_y)
	local grid_list = {}
	local search_list = {}
	local is_search = {}

	if start_x == end_x and start_y == end_y then
		return grid_list
	end
	
	local mNativeGrid = Grid.new(start_x, start_y, nil)

	local function flash_back(grid)
		table.insert(grid_list, grid)
		local parent_grid = grid:GetParent()
		if parent_grid then
			flash_back(parent_grid)
		end
	end

	local function search_grid(parent_grid)
		local grid_x, grid_y = parent_grid:GetGridPos()
		local grid_list = map:GetNearbyGridList(grid_x, grid_y)

		if not next(grid_list) then
			return false
		end

		local parent_grid_x, parent_grid_y = parent_grid:GetGridPos()
		local parent_dis = map:GetDistance(parent_grid_x, parent_grid_y, end_x, end_y)
		local check_grid_list = {}
		for _,v in ipairs(grid_list) do
			local mGrid = Grid.new(v.grid_x, v.grid_y, parent_grid)
			if v.grid_x == end_x and v.grid_y == end_y then
				flash_back(mGrid)
				return true
			else
				if v.can_move and not is_search[v.grid_id] then
					table.insert(check_grid_list, mGrid)
					is_search[v.grid_id] = true
				end
			end
		end

		table.sort(check_grid_list, function (grid_a, grid_b)
			local a_grid_x, a_grid_y = grid_a:GetGridPos()
			local b_grid_x, b_grid_y = grid_b:GetGridPos()
			local dis_a = map:GetDistance(a_grid_x, a_grid_y, end_x, end_y)
			local dis_b = map:GetDistance(b_grid_x, b_grid_y, end_x, end_y)

			if dis_a == dis_b then
				if a_grid_y == b_grid_y then
					return a_grid_x > b_grid_x
				else
					return a_grid_y > b_grid_y
				end
			else
				return dis_a < dis_b
			end
		end)

		for _,v in ipairs(check_grid_list) do
			table.insert(search_list, v)
			if search_grid(v) then
				return true
			end
		end
	end

	if search_grid(mNativeGrid) then
		local move_pos_list = {}
		local search_pos_list = {}

		for i = #grid_list, 1, -1 do
			local pos_x, pos_y = map:ConvertToPos(grid_list[i]:GetGridPos())
			table.insert(move_pos_list, {x = pos_x, y = pos_y})
		end

		for i = #search_list, 1, -1 do
			local pos_x, pos_y = map:ConvertToPos(search_list[i]:GetGridPos())
			table.insert(search_pos_list, {x = pos_x, y = pos_y})
		end

		return move_pos_list, search_pos_list
	else
		return false
	end
end


local Test = class("Test")

function Test:ctor()
	self.m_map = Map.new()
	self.m_path_search = PathSearch.new()

	local create_btn = ccui.ImageView:create("ui_skin_btn_bluemid.png", 1)
	create_btn:setTouchEnabled(true)
	create_btn:setPosition(MainScene.width - 100, 50)
	MainScene:addChild(create_btn)

	local desc = ccui.Text:create()
	desc:setFontSize(22)
	desc:setString("重新生成")
	desc:setPosition(create_btn:getContentSize().width/2, create_btn:getContentSize().height/2)
	create_btn:addChild(desc)

	create_btn:addTouchEventListener(function (ref, touch_type)
		if touch_type == ccui.TouchEventType.began then
			SoundManager:PlayEffect("click_1")
			ref:setScale(1.1)
		elseif touch_type == ccui.TouchEventType.canceled then
			ref:setScale(1)
		elseif touch_type == ccui.TouchEventType.ended then
			ref:setScale(1)

			self.m_map:CreateMap()
			self:FindPath()
		end
	end)

	self:FindPath()
end

function Test:FindPath()
	local move_pos_list, search_pos_list = self.m_path_search:FindPath(self.m_map, START_GRID_X, START_GRID_Y, END_GRID_X, END_GRID_Y)
	if not move_pos_list then
		return
	end
	self.m_map:DrawPath(move_pos_list, search_pos_list)
end

return Test
