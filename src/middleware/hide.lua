local Array = require(script.Parent.Parent.Parent.Collections).Array

local enums = require(script.Parent.Parent.enums)
local sides = enums.sides

local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

export type Options = {
	strategy: "referenceHidden" | "escaped"?,
}

local getSide = require(script.Parent.Parent.utils.getSide)
local getAlignment = require(script.Parent.Parent.utils.getAlignment)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)
local detectOverflow = require(script.Parent.Parent.detectOverflow)

local function getSideOffsets(overflow, size)
	return {
		top = overflow.top - size.Y,
		right = overflow.right - size.X,
		bottom = overflow.bottom - size.Y,
		left = overflow.left - size.X,
	}
end

local function isAnySideFullyClipped(overflow)
	return Array.some(sides, function(side)
		return overflow[side] >= 0
	end)
end

--[=[
	@within Middleware
]=]
local function hide(options: Options): Middleware
	return {
		name = "hide",
		options = options,
		fn = function(state)
			local strategy = options.strategy or "referenceHidden"
			local rects = state.rects

			local overflow = detectOverflow(state, {})
			local offsets = getSideOffsets(overflow, rects.reference.AbsoluteSize)

			return {
				data = {
					referenceHiddenOffsets = offsets,
					referenceHidden = isAnySideFullyClipped(offsets),
				},
			}
		end,
	}
end

return hide
