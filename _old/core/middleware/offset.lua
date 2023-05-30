local types = require(script.Parent.Parent.types)
type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

type AxesOffsets = {
	mainAxis: number?,
	crossAxis: number?,
	alignmentAxis: number?,
}

type OffsetValue = number | AxesOffsets

export type Options = OffsetValue | ((state: MiddlewareState) -> OffsetValue)

local getSide = require(script.Parent.Parent.utils.getSide)
local getAlignment = require(script.Parent.Parent.utils.getAlignment)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)

local function convertValueToCoords(state: MiddlewareState, value: Options)
	local placement = state.placement

	local side = getSide(placement)
	local alignment = getAlignment(placement)
	local isVertical = getMainAxisFromPlacement(placement) == "x"

	local mainAxisMulti = if table.find({ "left", "top" }, side) ~= nil then -1 else 1
	local crossAxisMulti = 1

	local rawValue = if type(value) == "function" then value(state) else value

	local mainAxis, crossAxis, alignmentAxis
	if type(rawValue) == "number" then
		mainAxis, crossAxis, alignmentAxis = rawValue, 0, nil
	else
		mainAxis, crossAxis, alignment = rawValue.mainAxis or 0, rawValue.crossAxis or 0, rawValue.alignmentAxis or nil
	end

	if alignment and type(alignmentAxis) == "number" then
		crossAxis = if alignment == "end" then alignmentAxis * -1 else alignmentAxis
	end

	return if isVertical
		then {
			x = crossAxis * crossAxisMulti,
			y = mainAxis * mainAxisMulti,
		}
		else {
			x = mainAxis * mainAxisMulti,
			y = crossAxis * crossAxisMulti,
		}
end

local function offset(value: Options): Middleware
	value = value or 0

	return {
		name = "offset",
		options = value,
		fn = function(state)
			local diffCoords = convertValueToCoords(state, value)

			return {
				x = state.x + diffCoords.x,
				y = state.y + diffCoords.y,
				data = diffCoords,
			}
		end,
	}
end

return offset
