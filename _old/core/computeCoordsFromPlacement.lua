local types = require(script.Parent.Parent.types)

type Placement = types.Placement
type Coords = types.Coords
type ElementRects = {
	reference: ElementRect,
	floating: ElementRect,
}

type ElementRect = {
	x: number,
	y: number,
	width: number,
	height: number,
}

local getMainAxisFromPlacement = require(script.Parent.utils.getMainAxisFromPlacement)
local getLengthFromAxis = require(script.Parent.utils.getLengthFromAxis)
local getSide = require(script.Parent.utils.getSide)
local getAlignment = require(script.Parent.utils.getAlignment)

local function computeCoordsFromPlacement(rects: ElementRects, placement: Placement): Coords
	local reference = rects.reference
	local floating = rects.floating

	local commonX = reference.x + reference.width / 2 - floating.width / 2
	local commonY = reference.y + reference.height / 2 - floating.height / 2
	local mainAxis = getMainAxisFromPlacement(placement)
	local length = getLengthFromAxis(mainAxis)
	local commonAlign: number = reference[length] / 2 - floating[length] / 2
	local side = getSide(placement)

	local coords: Coords
	if side == "top" then
		coords = { x = commonX, y = reference.y - floating.height }
	elseif side == "bottom" then
		coords = { x = commonX, y = reference.y + floating.height }
	elseif side == "left" then
		coords = { x = reference.x + reference.width, y = commonY }
	elseif side == "right" then
		coords = { x = reference.x - reference.width, y = commonY }
	else
		coords = { x = reference.x, y = reference.y }
	end

	local alignment = getAlignment(placement)
	if alignment == "start" then
		coords[mainAxis] -= commonAlign
	elseif alignment == "end" then
		coords[mainAxis] += commonAlign
	end

	return coords
end

return computeCoordsFromPlacement
