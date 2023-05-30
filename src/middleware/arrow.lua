local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

export type Options = {
	element: any?,
	padding: number?,
}

local getAlignment = require(script.Parent.Parent.utils.getAlignment)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)

local function getSideObjectFromPadding(padding: number)
	return {
		top = padding,
		left = padding,
		right = padding,
		bottom = padding,
	}
end

local function getVector2FromAxis(axis: string, position: Vector2, value: number)
	return if axis == "X" then Vector2.new(value, position.Y) else Vector2.new(position.X, value)
end

local function offset(options: Options): Middleware
	return {
		name = "arrow",
		options = options,
		fn = function(state)
			local position = state.position
			local placement = state.placement
			local rects = state.rects
			local element = options.element
			local padding = options.padding or 0

			if element == nil then
				return {}
			end

			local paddingObject = getSideObjectFromPadding(padding)
			local axis = getMainAxisFromPlacement(placement)
			local isYAxis = axis == "Y"
			local minProp = if isYAxis then "top" else "left"
			local maxProp = if isYAxis then "bottom" else "right"

			local arrowOffsetParent = element.Parent
			local clientSize = if arrowOffsetParent then arrowOffsetParent.AbsoluteSize[axis] else 0

			local endDiff = rects.reference.AbsoluteSize[axis]
				+ rects.reference.AbsolutePosition[axis]
				- position[axis]
				- rects.floating.AbsoluteSize[axis]
			local startDiff = position[axis] - rects.reference.AbsolutePosition[axis]

			local centerToReference = endDiff / 2 - startDiff / 2

			local min = paddingObject[minProp]
			local max = clientSize - element.AbsoluteSize[axis] - paddingObject[maxProp]
			local center = clientSize / 2 - element.AbsoluteSize[axis] / 2 + centerToReference
			local offset = math.clamp(center, min, max)

			local shouldAddOffset = getAlignment(placement) ~= nil
				and center ~= offset
				and rects.reference.AbsoluteSize[axis] / 2
						- (if center < min then paddingObject[minProp] else paddingObject[maxProp])
						- element.AbsoluteSize[axis] / 2
					< 0

			local alignmentOffset = if shouldAddOffset then if center < min then min - center else max - center else 0
			local position_ = getVector2FromAxis(axis, position, position[axis] - alignmentOffset)

			return {
				position = position_,
				data = {
					position = getVector2FromAxis(axis, Vector2.zero, offset),
					centerOffset = center - offset,
				},
			}
		end,
	}
end

return offset
