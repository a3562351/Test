local MAP_DEEP = 5
local MAX_ENTITY_PER_NODE = 5
local MAP_WIDTH = 10
local MAP_HEIGHT = 10
local ENTITY_RATE = 50
local NODE = {}
NODE.IDX = {
	LEFT = 1,
	RIGHT = 2,
	TOP = 3,
	BOTTOM = 4,
}
NODE.DIVIDERECT = function (idx, x, y, width, height)
	if idx == NODE.IDX.LEFT then
		return x, y, width/2, height/2
	elseif idx == NODE.IDX.RIGHT then
		return x + width/2, y, width/2, height/2
	elseif idx == NODE.IDX.TOP then
		return x, y + height/2, width/2, height/2
	elseif idx == NODE.IDX.BOTTOM then
		return x + width/2, y + height/2, width/2, height/2
	end
end
	


local Node = class("Node")
function Node:ctor(deep, idx, x, y, width, height)
	self.m_deep = deep
	self.m_idx = idx
	self.m_x = x
	self.m_y = y
	self.m_width = width
	self.m_height = height

	self.m_child_list = {}
	self.m_entity_list = {}
end

function Node:InRect(entity)
	if entity:GetX() >= self.m_x and entity:GetX() <= self.m_x + self.m_width then
		if entity:GetY() >= self.m_y and entity:GetY() <= self.m_y + self.m_height then
			return true
		end
	end
	return false
end

function Node:HaveChild()
	return next(self.m_child_list)
end

function Node:Refresh(root)
	if self:HaveChild() then
		for _, child in pairs(self.m_child_list) do
			child:Refresh(root)
		end
	else
		for i = #self.m_entity_list, 1, -1 do
			local entity = self.m_entity_list[i]
			if not self:InRect(entity) then
				table.remove(self.m_entity_list, i)
				if self ~= root then
					root:Insert(entity)
				end
			end
		end
	end
end

function Node:Insert(entity)
	if self:HaveChild() then
		for _, child in pairs(self.m_child_list) do
			if child:InRect(entity) then
				child:Insert(entity)
			end
		end
	else
		table.insert(self.m_entity_list, entity)
		if #self.m_entity_list > MAX_ENTITY_PER_NODE and self.m_deep < MAP_DEEP then
			self:Divide()
		end
	end
end

function Node:Divide()
	for _, idx in pairs(NODE.IDX) do
		local x, y, width, height = NODE.DIVIDERECT(idx, self.m_x, self.m_y, self.m_width, self.m_height)
		self.m_child_list[idx] = Node.new(self.m_deep + 1, idx, x, y, width, height)
	end

	for _, entity in ipairs(self.m_entity_list) do
		self:Insert(entity)
	end
	self.m_entity_list = {}
end


local QuadTree = class("QuadTree")
function QuadTree:ctor(width, height)
	self.m_root_node = Node.new(0, 0, 0, 0, width, height)
end

function QuadTree:Refresh()
	self.m_root_node:Refresh(self.m_root_node)
end

function QuadTree:Insert(entity)
	self.m_root_node:Insert(entity)
end


local Entity = class("Entity")
function Entity:ctor(x, y)
	self.m_x = x
	self.m_y = y
end

function Entity:GetX()
	return self.m_x
end

function Entity:GetY()
	return self.m_y
end


local map = {}
local entity_list = {}
setmetatable(map, {
	__tostring = function ()
		local str = ""
		for j = 1, MAP_HEIGHT do
			for i = 1, MAP_WIDTH do
				str = string.format("%s%d", str, map[j][i] and 1 or 0)
			end
			str = str.."\n"
		end
		return str
	end
})

for j = 1, MAP_HEIGHT do
	for i = 1, MAP_WIDTH do
		if ENTITY_RATE < math.random(1, 100) then
			local entity = Entity.new(i, j)
			table.insert(entity_list, entity)

			map[j] = map[j] or {}
			map[j][i] = entity
		end
	end
end

print(tostring(map))

local quad_tree = QuadTree.new(MAP_WIDTH, MAP_HEIGHT)
for _, entity in ipairs(entity_list) do
	quad_tree:Insert(entity)
end
