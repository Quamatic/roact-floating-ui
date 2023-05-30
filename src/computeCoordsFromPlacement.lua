type ElementRects = {
	reference: GuiObject,
	floating: GuiObject,
}

local getSide = require(script.Parent.utils.getSide)
local getMainAxisFromPlacement = require(script.Parent.utils.getMainAxisFromPlacement)
local getAlignment = require(script.Parent.utils.getAlignment)

--[[
    Computes the coordinates for a floating ui based on a provided placement
]]
local function computeCoordsFromPlacement(elements: ElementRects, placement): Vector2
	local reference = elements.reference
	local floating = elements.floating

	-- TODO: Organize.

	local commonX = reference.AbsolutePosition.X + reference.AbsoluteSize.X / 2 - floating.AbsoluteSize.X / 2
	local commonY = reference.AbsolutePosition.Y + reference.AbsoluteSize.Y / 2 - floating.AbsoluteSize.Y / 2
	local axis = getMainAxisFromPlacement(placement)
	local align = reference.AbsoluteSize[axis] / 2 - floating.AbsoluteSize[axis] / 2
	local side = getSide(placement)

	local coords
	if side == "top" then
		coords = { X = commonX, Y = reference.AbsolutePosition.Y - floating.AbsoluteSize.Y }
	elseif side == "bottom" then
		coords = { X = commonX, Y = reference.AbsolutePosition.Y + reference.AbsoluteSize.Y }
	elseif side == "right" then
		coords = { X = reference.AbsolutePosition.X + reference.AbsoluteSize.X, Y = commonY }
	elseif side == "left" then
		coords = { X = reference.AbsolutePosition.X - floating.AbsoluteSize.X, Y = commonY }
	else
		coords = { X = reference.AbsolutePosition.X, Y = reference.AbsolutePosition.Y }
	end

	local alignment = getAlignment(placement)
	if alignment == "start" then
		coords[axis] -= align
	elseif alignment == "end" then
		coords[axis] += align
	end

	return Vector2.new(coords.X, coords.Y)
end

return computeCoordsFromPlacement
