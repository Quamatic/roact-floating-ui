local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)
local Array = LuauPolyfill.Array

local enums = require(script.Parent.Parent.enums)
local sides = enums.sides

local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState
type SideObject = types.SideObject
type Rect = types.Rect

export type Options = {
	strategy: "referenceHidden" | "escaped"?,
}

local detectOverflow = require(script.Parent.Parent.detectOverflow)

local function getSideOffsets(overflow: SideObject, rect: Rect)
	return {
		top = overflow.top - rect.height,
		right = overflow.right - rect.width,
		bottom = overflow.bottom - rect.height,
		left = overflow.left - rect.width,
	}
end

local function isAnySideFullyClipped(overflow: SideObject)
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

			if strategy == "referenceHidden" then
				local overflow = detectOverflow(state, {
					elementContext = "reference",
				})
				local offsets = getSideOffsets(overflow, rects.reference)
				return {
					data = {
						referenceHiddenOffsets = offsets,
						referenceHidden = isAnySideFullyClipped(offsets),
					},
				}
			elseif strategy == "escaped" then
				local overflow = detectOverflow(state, {
					altBoundary = true,
				})
				local offsets = getSideOffsets(overflow, rects.floating)
				return {
					data = {
						escapedOffsets = offsets,
						escaped = isAnySideFullyClipped(offsets),
					},
				}
			end

			return {}
		end,
	}
end

return hide
