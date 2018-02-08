local SkillPool = import(".SkillPool")
local Entity = import(".Entity")
local QueueManager = import(".QueueManager")
local BattleView = import(".BattleView")
local BattleCtrl = class("BattleCtrl")

local ONLY_CALCULATE = false

--{id, hp, attack, defense, speed, skill_list},
local DEFAULT_ATTACK_INFO = {
	{1, 100, 100, 50, 100, {{skill_name = "ORDINARY", level = 1}, {skill_name = "STRENGTHEN", level = 1}}},
	{2, 110, 110, 50, 110, {{skill_name = "ORDINARY", level = 1}, {skill_name = "CRI", level = 1}}},
	{3, 120, 100, 50, 210, {{skill_name = "ORDINARY", level = 1}, {skill_name = "STRENGTHEN", level = 1}, {skill_name = "CRI", level = 1}}},
	{4, 130, 110, 50, 120, {{skill_name = "ORDINARY", level = 1}}},
	{5, 140, 110, 50, 130, {{skill_name = "ORDINARY", level = 1}}},
}

local DEFAULT_DEFEND_INFO = {
	{6, 90, 90, 50, 90, {{skill_name = "ORDINARY", level = 1}, {skill_name = "STRENGTHEN", level = 1}}},
	{7, 120, 120, 50, 120, {{skill_name = "ORDINARY", level = 1}, {skill_name = "CRI", level = 1}}},
	{8, 90, 90, 50, 100, {{skill_name = "ORDINARY", level = 1}, {skill_name = "STRENGTHEN", level = 1}, {skill_name = "CRI", level = 1}}},
	{9, 120, 120, 50, 180, {{skill_name = "ORDINARY", level = 1}}},
	{10, 120, 120, 50, 170, {{skill_name = "ORDINARY", level = 1}}},
}

function BattleCtrl:ctor()
	cc.exports["SkillPool"] = SkillPool.new()
end

function BattleCtrl:PerpareBattle(attack_info, defend_info)
	self.m_is_end = false

	self.m_auto = false
	self.m_wait_entity = nil

	self.m_attack_info = {}
	self.m_defend_info = {}

	self.m_attacker_list = {}
	self.m_defenser_list = {}

	self.m_queue_manager = QueueManager.new()

	self.m_attack_info = attack_info or DEFAULT_ATTACK_INFO
	self.m_defend_info = defend_info or DEFAULT_DEFEND_INFO

	for idx, attr_list in ipairs(self.m_attack_info) do
		local entity = Entity.new()
		local script = entity:InitScript()
		script:SetIdx(idx)
		script:SetAttrList(attr_list)
		script:SetIsOwn(true)
		script:SetCanHandle(true)
		table.insert(self.m_attacker_list, entity)

		self.m_queue_manager:AddEntity(entity)
	end

	for idx, attr_list in ipairs(self.m_defend_info) do
		local entity = Entity.new()
		local script = entity:InitScript()
		script:SetIdx(idx)
		script:SetAttrList(attr_list)
		script:SetIsOwn(false)
		script:SetCanHandle(false)
		table.insert(self.m_defenser_list, entity)

		self.m_queue_manager:AddEntity(entity)
	end

	if not ONLY_CALCULATE then
		self:InitView()
	end

	self:UpdateEntityPos()
end

function BattleCtrl:InitView()
	self.m_battle_view = BattleView.new()
	self.m_battle_view:setPosition(MainScene.width/2, MainScene.height/2)
	MainScene:addChild(self.m_battle_view)

	for idx, entity in ipairs(self.m_attacker_list) do
		local render = entity:InitRender()
		render:IdleAction()
		self.m_battle_view:AddRender(render, idx, true)
	end

	for idx, entity in ipairs(self.m_defenser_list) do
		local render = entity:InitRender()
		render:IdleAction()
		self.m_battle_view:AddRender(render, idx, false)
	end

	self.m_battle_view:ChangeAuto(self.m_auto)
end

function BattleCtrl:BattleEnd(flag)
	self.m_is_end = true
	if flag then
		print("######## Attack Is Win ########")
	else
		print("######## Defense Is Win ########")
	end
end

function BattleCtrl:ChangeAuto()
	self.m_auto = not self.m_auto
	local wait_entity = self.m_wait_entity

	if self.m_auto and wait_entity then
		self:EntityResponse()
		self:AIAction(wait_entity)
	end

	self.m_battle_view:ChangeAuto(self.m_auto)
end

function BattleCtrl:CheckBattleEnd()
	local attack_is_all_die = true
	for _,v in ipairs(self.m_attacker_list) do
		if v:GetScript():IsActive() then
			attack_is_all_die = false
			break
		end
	end

	if attack_is_all_die then
		return true, false
	end

	local defense_is_all_die = true
	for _,v in ipairs(self.m_defenser_list) do
		if v:GetScript():IsActive() then
			defense_is_all_die = false
			break
		end
	end

	if defense_is_all_die then
		return true, true
	end

	return false
end

function BattleCtrl:UpdateSpeedPos(runner_list)
	if self.m_battle_view then
		for idx, runner_info in ipairs(runner_list) do
			local entity = runner_info.entity
			local script = entity:GetScript()
			self.m_battle_view:UpdateSpeedPos(script:GetIdx(), script:IsOwn(), runner_info.pos, function ()
				if idx == #runner_list then
					self:HandleNextEntity()
				end
			end)
		end
	end
end

function BattleCtrl:ResetSpeedPos(entity)
	if self.m_battle_view then
		self.m_battle_view:ResetSpeedPos(entity:GetScript():GetIdx(), entity:GetScript():IsOwn())
	end
end

function BattleCtrl:HandleNextEntity()
	if self.m_is_end then
		return
	end

	local entity = self.m_queue_manager:FindNextEntity()
	self:EntityAction(entity)
end

function BattleCtrl:EntityAction(entity)
	print("BattleCtrl:EntityAction", entity:GetScript():GetId())

	if not entity:GetScript():IsActive() or not entity:GetScript():OnRound() then
		self:EntityActionOver(entity)
		return
	end

	if ONLY_CALCULATE or self.m_auto or not entity:GetScript():CanHandle() then
		self:AIAction(entity)
	else
		self:WaitHandle(entity)
	end
end

function BattleCtrl:AIAction(entity)
	local enemy_list = self:GetEnemyList(entity)
	local enemy_entity = self:GetMaxHpEntity(enemy_list)
	if not enemy_entity then
		self:BattleEnd(entity:IsOwn())
		return
	end

	local script = entity:GetScript()
	local skill_list = script:GetSkillList()
	local idx = math.random(1, #skill_list)
	script:ReleaseSkill(idx, enemy_entity)
end

function BattleCtrl:GetEnemyList(entity)
	local enemy_list = entity:GetScript():IsOwn() and self.m_defenser_list or self.m_attacker_list
	return enemy_list
end

function BattleCtrl:GetMaxHpEntity(entity_list)
	local entity
	local max_hp = 0
	for _,v in ipairs(entity_list) do
		local script = v:GetScript()
		if script:IsActive() and (not entity or script:GetCurHp() > max_hp) then
			entity = v
			max_hp = script:GetCurHp()
		end
	end
	return entity
end

function BattleCtrl:WaitHandle(entity)
	self.m_wait_entity = entity

	entity:GetRender():WaitTodoAction()
	self.m_battle_view:ShowEntityInfo(entity, function (idx)
		local enemy_list = self:GetEnemyList(entity)
		for _, v in pairs(enemy_list) do
			if v:GetScript():IsActive() then
				local render = v:GetRender()
				render:SetTouchEnabled(true)
				render:SetTipVisible(true)
				render:AddCallBack(function (enemy_entity)
					self:EntityResponse()
					entity:GetScript():ReleaseSkill(idx, enemy_entity)
				end)
			end
		end
	end)
end

function BattleCtrl:EntityResponse()
	self.m_wait_entity = nil
	self.m_battle_view:CloseEntityInfo()
	self:ResetRenderTouch()
end

function BattleCtrl:ResetRenderTouch()
	for _, v in ipairs(self.m_attacker_list) do
		local render = v:GetRender()
		render:SetTouchEnabled(false)
		render:SetTipVisible(false)
	end

	for _, v in ipairs(self.m_defenser_list) do
		local render = v:GetRender()
		render:SetTouchEnabled(false)
		render:SetTipVisible(false)
	end
end

function BattleCtrl:EntityActionOver(entity)
	print("BattleCtrl:EntityActionOver", entity:GetScript():GetId())

	self.m_queue_manager:ResetPos(entity)
	self:UpdateEntityPos()
end

function BattleCtrl:UpdateEntityPos()
	self.m_queue_manager:UpdateEntityPos()

	if ONLY_CALCULATE then
		self:HandleNextEntity()
	end
end

function BattleCtrl:EntityDie(entity)
	if self.m_battle_view then
		self.m_battle_view:EntityDie(entity)
	end

	local is_end, flag = self:CheckBattleEnd()
	if is_end then
		self:BattleEnd(flag)
		return
	end
end

cc.exports["BattleCtrl"] = BattleCtrl.new()
