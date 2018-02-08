local Map = import(".Map")
local GameCtrl = class("GameCtrl")

function GameCtrl:ctor()

end

function GameCtrl:CreateMap()
	self.m_map = Map.new()
	self.m_map:InitView()
	self.m_map:setPosition(MainScene.width/2, MainScene.height/2)
	MainScene:addChild(self.m_map)
end

function GameCtrl:CreateArmy()

end

cc.exports["GameCtrl"] = GameCtrl.new()
