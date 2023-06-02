local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

type OffsetValue = number | {
	mainAxis: number?,
	crossAxis: number?,
	alignmentAxis: number?,
}

type OffsetFunction = (state: MiddlewareState) -> OffsetValue

export type Options = OffsetValue | OffsetFunction

local getSide = require(script.Parent.Parent.utils.getSide)
local getAlignment = require(script.Parent.Parent.utils.getAlignment)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)

local function getOffsetFromRawValue(rawValue: OffsetValue)
	if type(rawValue) == "number" then
		return rawValue, 0, nil
	else
		return rawValue.mainAxis or 0, rawValue.crossAxis or 0, rawValue.alignmentAxis or nil
	end
end

local function convertValueToCoords(state: MiddlewareState, value: Options)
	local placement = state.placement

	local side = getSide(placement)
	local alignment = getAlignment(placement)
	local isVertical = getMainAxisFromPlacement(placement) == "x"
	local mainAxisMulti = if side == "left" or side == "top" then -1 else 1
	local crossAxisMulti = 1

	local rawValue = if type(value) == "function" then value(state) else value
	local mainAxis, crossAxis, alignmentAxis = getOffsetFromRawValue(rawValue)

	if alignment and alignmentAxis ~= nil then
		crossAxis = if alignment == "end" then alignmentAxis * -1 else alignmentAxis
	end

	local x, y
	if isVertical then
		x = crossAxis * crossAxisMulti
		y = mainAxis * mainAxisMulti
	else
		x = mainAxis * mainAxisMulti
		y = crossAxis * crossAxisMulti
	end

	return { x = x, y = y }
end

--[=[
	@within Middleware
]=]
local function offset(value: Options): Middleware
	value = value or 0

	return {
		name = "offset",
		options = value,
		fn = function(state)
			local x = state.x
			local y = state.y
			local diffCoords = convertValueToCoords(state, value)

			return {
				x = x + diffCoords.x,
				y = y + diffCoords.y,
				data = diffCoords,
			}
		end,
	}
end

return offset
