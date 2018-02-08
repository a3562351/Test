local Friend = class("Friend")

function Friend:ctor()
	self.m_friend_list = {}
	self.m_apply_list = {}
end

function Friend:HaveFriend(role_id)
	return self.m_friend_list[role_id]
end

function Friend:SendFriendList(friend_list)

end

return Friend
