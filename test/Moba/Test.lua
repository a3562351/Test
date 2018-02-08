local Client = import(".Client.Client")
local Server = import(".Server.Server")
local Test = class("Test")

local ROLE_LIST = {
	{role_id = 1, step = 1},
	{role_id = 2, step = 1},
}

function Test:ctor()
	self.m_client_list = {}
	self:Test()
end

function Test:Test()
	cc.exports["Server"] = Server.new()

	for _,v in ipairs(ROLE_LIST) do
		local client = Client.new(v.role_id, v.step)
		client:Connect()
		self.m_client_list["Cllent_1"..v.role_id] = client
	end

	for _,v in pairs(self.m_client_list) do
		v:SearchOpponent()
	end
end

function Test:GetClient(role_id)
	return self.m_client_list["Cllent_1"..role_id]
end

cc.exports["Test"] = Test.new()
