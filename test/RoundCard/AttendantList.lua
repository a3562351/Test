local AttendantList = class("AttendantList")

function AttendantList:ctor()
	self.m_list = {}
end

function AttendantList:AddAttendant(attendant, idx)
	table.insert(self.m_list, idx, attendant)
end

function AttendantList:GetAttendantList()
	return self.m_list
end

function AttendantList:GetSpellPlus()
	local add_value = 0
	for _,v in ipairs(self.m_list) do

	end
	return add_value
end

return AttendantList
