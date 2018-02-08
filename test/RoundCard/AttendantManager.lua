local Attendant = import(".Attendant")
local AttendantManager = class("AttendantManager")

function AttendantManager:ctor()

end

function HeroManager:CreateAttendant(card_id)
	return Attendant.new()
end

return AttendantManager
