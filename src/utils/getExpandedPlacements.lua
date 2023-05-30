local getOppositePlacement = require(script.Parent.getOppositePlacement)
local getOppositeAlignmentPlacement = require(script.Parent.getOppositeAlignmentPlacement)

local function getExpandedPlacements(placement: string)
	local oppositePlacement = getOppositePlacement(placement)

	return {
		getOppositeAlignmentPlacement(placement),
		oppositePlacement,
		getOppositeAlignmentPlacement(oppositePlacement),
	}
end

return getExpandedPlacements
