local QueueManager = class("QueueManager")

local DIS = 300

function QueueManager:ctor()
	self.m_runner_list = {}
end

function QueueManager:AddEntity(entity)
	local runner = {entity = entity, pos = 0}
	table.insert(self.m_runner_list, runner)
end

function QueueManager:FindNextEntity()
	local max_pos_runner = nil
	for _,v in ipairs(self.m_runner_list) do
		if v.pos >= DIS then
			if not max_pos_runner or (max_pos_runner and v.pos > max_pos_runner.pos) then
				max_pos_runner = v
			end
		end
	end
	return max_pos_runner.entity
end

function QueueManager:UpdateEntityPos()
	local min_time = nil
	for _,v in ipairs(self.m_runner_list) do
		if v.pos < DIS then
			local need_time = (DIS - v.pos)/v.entity:GetScript():GetSpeed()
			if not min_time or need_time < min_time then
				min_time = need_time
			end
		end
	end

	local min_time = (min_time or 0) + 0.01
	for _,v in ipairs(self.m_runner_list) do
		v.pos = v.pos + v.entity:GetScript():GetSpeed() * min_time
	end

	BattleCtrl:UpdateSpeedPos(self.m_runner_list)
end

function QueueManager:ResetPos(entity)
	for i,v in ipairs(self.m_runner_list) do
		if v.entity == entity then
			v.pos = 0
			break
		end
	end

	BattleCtrl:ResetSpeedPos(entity)
end

return QueueManager
