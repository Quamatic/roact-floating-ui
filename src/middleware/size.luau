local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)
local Object = LuauPolyfill.Object

local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

type ApplyFn = (args: MiddlewareState & {
	availableWidth: number,
	availableHeight: number,
}) -> ()

export type Options = {
	apply: ApplyFn,
}

local getSide = require(script.Parent.Parent.utils.getSide)
local getAlignment = require(script.Parent.Parent.utils.getAlignment)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)
local detectOverflow = require(script.Parent.Parent.detectOverflow)

local defaultApply = function() end

local function size(options: Options?): Middleware
	if options == nil then
		options = {} :: Options
	end

	return {
		name = "size",
		options = options,
		fn = function(state)
			local rects = state.rects
			local placement = state.placement
			local apply = (options :: Options).apply or defaultApply
			local detectOverflowOptions = Object.assign({}, options, {
				apply = Object.None,
			})

			local overflow = detectOverflow(state, detectOverflowOptions)
			local side = getSide(placement)
			local alignment = getAlignment(placement)
			local axis = getMainAxisFromPlacement(placement)
			local isXAxis = axis == "x"

			local width = rects.floating.width
			local height = rects.floating.height

			local heightSide: "top" | "bottom"
			local widthSide: "left" | "right"

			if side == "top" or side == "bottom" then
				heightSide = side
				widthSide = if alignment == "end" then "left" else "right"
			else
				widthSide = side
				heightSide = if alignment == "end" then "top" else "bottom"
			end

			local overflowAvailableHeight = height - overflow[heightSide]
			local overflowAvailableWidth = width - overflow[widthSide]

			local noShift = not state.middlewareData.shift

			local availableHeight = overflowAvailableHeight
			local availableWidth = overflowAvailableWidth

			if isXAxis then
				local maximumClippingWidth = width - overflow.left - overflow.right
				availableWidth = if alignment or noShift
					then math.min(overflowAvailableWidth, maximumClippingWidth)
					else maximumClippingWidth
			else
				local maximumClippingHeight = height - overflow.top - overflow.bottom
				availableHeight = if alignment or noShift
					then math.min(overflowAvailableHeight, maximumClippingHeight)
					else maximumClippingHeight
			end

			if noShift and not alignment then
				local xMin = math.max(overflow.left, 0)
				local xMax = math.max(overflow.right, 0)
				local yMin = math.max(overflow.top, 0)
				local yMax = math.max(overflow.bottom, 0)

				if isXAxis then
					local applied = if xMin ~= 0 or xMax ~= 0
						then xMin + xMax
						else math.max(overflow.left, overflow.right)

					availableWidth = width - 2 * applied
				else
					local applied = if yMin ~= 0 or yMax ~= 0
						then yMin + yMax
						else math.max(overflow.top, overflow.bottom)

					availableHeight = height - 2 * applied
				end
			end

			apply(Object.assign({}, state, {
				availableWidth = math.max(availableWidth, 0),
				availableHeight = math.max(availableHeight, 0),
			}))

			return {}
		end,
	}
end

return size
