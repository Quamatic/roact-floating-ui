local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

export type Options = {
	element: any?,
	padding: number?,
}

local getAlignment = require(script.Parent.Parent.utils.getAlignment)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)
local getLengthFromAxis = require(script.Parent.Parent.utils.getLengthFromAxis)
local getBoundingClientRect = require(script.Parent.Parent.utils.getBoundingClientRect)
local getSideObjectFromPadding = require(script.Parent.Parent.utils.getSideObjectFromPadding)

--[=[
	@within Middleware

	Provides data to position an inner element of the floating element (usually a triangle or caret) 
	so that it appears centered to the reference element.

	This is useful to add an additional visual cue to the floating element about which element it is referring to.

	:::tip
	If you’re using React, the FloatingArrow component renders out a customizable arrow element and applies the positioning styles for you.
	:::
]=]
local function arrow(options: Options?): Middleware
	if options == nil then
		options = {} :: Options
	end

	return {
		name = "arrow",
		options = options,
		fn = function(state)
			local x = state.x
			local y = state.y
			local placement = state.placement
			local rects = state.rects
			local element = (options :: Options).element
			local padding = (options :: Options).padding or 0

			if type(element) == "table" then
				if element.current ~= nil then
					element = element.current
				else
					return {}
				end
			end

			if element == nil then
				return {}
			end

			local paddingObject = getSideObjectFromPadding(padding)
			local coords = { x = x, y = y }
			local axis = getMainAxisFromPlacement(placement)
			local length = getLengthFromAxis(axis)
			local arrowDimensions = getBoundingClientRect(element) -- TODO: getDimensions OR getBoundingClientRect
			local isYAxis = axis == "y"
			local minProp = if isYAxis then "top" else "left"
			local maxProp = if isYAxis then "bottom" else "right"

			local arrowOffsetParent = element.Parent -- todo: getOffsetParent?
			local clientSize = if arrowOffsetParent then arrowOffsetParent.AbsoluteSize[axis] else 0

			local endDiff = rects.reference[axis] + rects.reference[length] - coords[axis] - rects.floating[length]
			local startDiff = coords[axis] - rects.reference[axis]

			local centerToReference = endDiff / 2 - startDiff / 2

			local min = paddingObject[minProp]
			local max = clientSize - arrowDimensions[length] - paddingObject[maxProp]
			local center = clientSize / 2 - arrowDimensions[length] / 2 + centerToReference
			local offset = math.clamp(center, min, max)

			local shouldAddOffset = getAlignment(placement) ~= nil
				and center ~= offset
				and rects.reference[length] / 2
						- (if center < min then paddingObject[minProp] else paddingObject[maxProp])
						- arrowDimensions[length] / 2
					< 0

			local alignmentOffset = if shouldAddOffset then if center < min then min - center else max - center else 0

			return {
				[axis] = coords[axis] - alignmentOffset,
				data = {
					[axis] = offset,
					centerOffset = center - offset,
				},
			}
		end,
	}
end

return arrow
