local getAlignment = require(script.Parent.getAlignment)
local getMainAxisFromPlacement = require(script.Parent.getMainAxisFromPlacement)
local getOppositePlacement = require(script.Parent.getOppositePlacement)

local function getAlignmentSides(placement, rects)
	local alignment = getAlignment(placement)
	local mainAxis = getMainAxisFromPlacement(placement)

	local mainAlignmentSide = if mainAxis == "x"
		then if alignment == "start" then "right" else "left"
		else if alignment == "start" then "bottom" else "top"

	if rects.reference[mainAxis] > rects.floating[mainAxis] then
		mainAlignmentSide = getOppositePlacement(mainAlignmentSide)
	end

	return mainAlignmentSide, getOppositePlacement(mainAlignmentSide)
end

return getAlignmentSides
