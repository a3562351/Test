local Card = import(".Card")
local CardManager = class("CardManager")

function CardManager:ctor()

end

function CardManager:CreateCard(card_id)
	return Card.new()
end

return CardManager
