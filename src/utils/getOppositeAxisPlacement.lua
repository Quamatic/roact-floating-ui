local Array = require(script.Parent.Parent.Parent.Collections).Array

local types = require(script.Parent.Parent.types)
type Placement = types.Placement

local getSide = require(script.Parent.getSide)
local getAlignment = require(script.Parent.getAlignment)
local getOppositeAlignmentPlacement = require(script.Parent.getOppositeAlignmentPlacement)

local function getSideList(side: string, isStart: boolean)
	local lr: { Placement } = { "left", "right" }
	local rl: { Placement } = { "right", "left" }
	local tb: { Placement } = { "top", "bottom" }
	local bt: { Placement } = { "bottom", "top" }

	if side == "top" or side == "bottom" then
		return if isStart then lr else rl
	elseif side == "left" or side == "right" then
		return if isStart then tb else bt
	else
		return {}
	end
end

local function getOppositeAxisPlacement(
	placement: Placement,
	flipAlignment: boolean,
	direction: "none" | string
): { Placement }
	local alignment = getAlignment(placement)
	local list = getSideList(getSide(placement), direction == "start")

	if alignment then
		list = Array.map(list, function(side)
			return `{side}-{placement}`
		end)

		if flipAlignment then
			list = Array.concat(list, Array.map(list, getOppositeAlignmentPlacement))
		end
	end

	return list
end

return getOppositeAxisPlacement
