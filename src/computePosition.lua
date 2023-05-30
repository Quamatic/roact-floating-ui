local computeCoordsFromPlacement = require(script.Parent.computeCoordsFromPlacement)

local types = require(script.Parent.types)
type Element = types.Element
type ComputePositionConfig = types.ComputePositionConfig
type ComputePositionReturn = types.ComputePositionReturn

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

	local rects = { reference = reference, floating = floating }
	local position = computeCoordsFromPlacement(rects, placement)
	local statefulPlacement = placement
	local middlewareData = {}
	local resetCount = 0

	-- we have to use a while loop iteration here so that middleware can reset the lifecycle if needed (index going back to 1)
	local index = 1
	while index <= #middleware do
		local middleware_ = middleware[index]
		local result = middleware_.fn({
			position = position,
			initialPlacement = placement,
			placement = statefulPlacement,
			middlewareData = middlewareData,
			rects = rects,
			elements = rects,
		})

		if result.position then
			position = result.position
		end

		middlewareData = merge(middlewareData, {
			[middleware_.name] = merge(middlewareData[middleware_.name], result.data),
		})

		local reset = result.reset
		if reset and resetCount <= MAX_RESET_COUNT then
			resetCount += 1

			if type(reset) == "table" then
				if reset.placement then
					statefulPlacement = reset.placement
				end

				position = computeCoordsFromPlacement(rects, statefulPlacement)
			end

			index = 1
			continue
		end

		index += 1
	end

	return {
		position = position,
		placement = statefulPlacement,
		middlewareData = middlewareData,
	}
end

return computePosition
