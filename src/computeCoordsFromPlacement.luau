local getSide = require(script.Parent.utils.getSide)
local getMainAxisFromPlacement = require(script.Parent.utils.getMainAxisFromPlacement)
local getLengthFromAxis = require(script.Parent.utils.getLengthFromAxis)
local getAlignment = require(script.Parent.utils.getAlignment)

local types = require(script.Parent.types)
type Placement = types.Placement
type ElementRects = types.ElementRects

--[[
    Computes the coordinates for a floating ui based on a provided placement
]]
local function computeCoordsFromPlacement(elements: ElementRects, placement: Placement)
	local reference = elements.reference
	local floating = elements.floating

	-- TODO: Organize.

	local commonX = reference.x + reference.width / 2 - floating.width / 2
	local commonY = reference.y + reference.height / 2 - floating.height / 2
	local mainAxis = getMainAxisFromPlacement(placement)
	local length = getLengthFromAxis(mainAxis)
	local align = reference[length] / 2 - floating[length] / 2
	local side = getSide(placement)

	local coords: { x: number, y: number }
	if side == "top" then
		coords = { x = commonX, y = reference.y - floating.height }
	elseif side == "bottom" then
		coords = { x = commonX, y = reference.y + reference.height }
	elseif side == "right" then
		coords = { x = reference.x + reference.width, y = commonY }
	elseif side == "left" then
		coords = { x = reference.x - floating.width, y = commonY }
	else
		coords = { x = reference.x, y = reference.y }
	end

	-- deviation: RTL does not exist
	local alignment = getAlignment(placement)
	if alignment == "start" then
		coords[mainAxis] -= align
	elseif alignment == "end" then
		coords[mainAxis] += align
	end

	return coords.x, coords.y
end

return computeCoordsFromPlacement
