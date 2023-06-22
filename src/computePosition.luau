local computeCoordsFromPlacement = require(script.Parent.computeCoordsFromPlacement)
local getElementRects = require(script.Parent.utils.getElementRects)

local types = require(script.Parent.types)
type Element = types.Element
type ComputePositionConfig = types.ComputePositionConfig
type ComputePositionReturn = types.ComputePositionReturn
type MiddlewareData = types.MiddlewareData

local merge = require(script.Parent.utils.merge)

local MAX_RESET_COUNT = 50 -- some arbitrary amount that the actual library set. not sure why, but im using it anyway.

--[[
	@within FloatingUI

    Computes the final position for a floating object.
]]
local function computePosition(
	reference: Element,
	floating: Element,
	config: ComputePositionConfig
): ComputePositionReturn
	local placement = config.placement or "bottom"
	local middleware = config.middleware or {}

	local rects = getElementRects(reference, floating)
	local x, y = computeCoordsFromPlacement(rects, placement)
	local statefulPlacement = placement
	local middlewareData: MiddlewareData = {}
	local resetCount = 0

	-- we have to use a while loop iteration here so that middleware can reset the lifecycle if needed (index going back to 1)
	local index = 1
	while index <= #middleware do
		local middleware_ = middleware[index]
		local name = middleware_.name

		local result = middleware_.fn({
			x = x,
			y = y,
			initialPlacement = placement,
			placement = statefulPlacement,
			middlewareData = middlewareData,
			rects = rects,
			elements = { reference = reference, floating = floating },
		})

		local nextX = result.x
		local nextY = result.y
		local data = result.data
		local reset = result.reset

		x = nextX or x
		y = nextY or y

		middlewareData = merge(middlewareData, {
			[name] = merge(middlewareData[name], data),
		})

		if reset and resetCount <= MAX_RESET_COUNT then
			resetCount += 1

			if type(reset) == "table" then
				if reset.placement then
					statefulPlacement = reset.placement
				end

				if reset.rects then
					rects = if reset.rects == true then getElementRects(reference, floating) else reset.rects
				end

				x, y = computeCoordsFromPlacement(rects, statefulPlacement)
			end

			index = 1
			continue
		end

		index += 1
	end

	return {
		x = x,
		y = y,
		placement = statefulPlacement,
		middlewareData = middlewareData,
	}
end

return computePosition
