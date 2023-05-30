local oppositeAlignmentMap = {
	start = "end",
	["end"] = "start",
}

local function getOppositeAlignmentPlacement(placement: string)
	for _, alignment in { "start", "end" } do
		local result = string.match(placement, alignment)
		if result then
			return oppositeAlignmentMap[result]
		end
	end

	return placement
end

return getOppositeAlignmentPlacement
