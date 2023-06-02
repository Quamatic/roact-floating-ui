local oppositeSideMap = {
	left = "right",
	right = "left",
	top = "bottom",
	bottom = "top",
}

local function getOppositePlacement(placement: string)
	for _, side in { "left", "right", "bottom", "top" } do
		local result = string.match(placement, side)
		if result then
			return oppositeSideMap[result]
		end
	end

	return placement
end

return getOppositePlacement
