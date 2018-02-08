local Queue = class("Queue")

function Queue:ctor()
	self.m_list = {}
	self.m_count = 0
end

function Queue:Add(id, value)
	if not self.m_list[id] then
		self.m_count = self.m_count + 1
	end
	self.m_list[id] = value
end

function Queue:Remove(id)
	if self.m_list[id] then
		self.m_count = self.m_count - 1
	end
	self.m_list[id] = nil
end

function Queue:Pop()
	local id, value = next(self.m_list)
	if not id then
		return
	end

	self:Remove(id)
	return id, value
end

function Queue:Length()
	return self.m_count
end

return Queue
