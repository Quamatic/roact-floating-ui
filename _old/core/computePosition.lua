local Promise = require(script.Parent.Parent.Parent.Promise)

local computeCoordsFromPlacement = require(script.Parent.computeCoordsFromPlacement)

local MAX_RESETS = 50

--[=[
	@within RoactPopper
]=]
local function computePosition(reference, floating, config)
	local placement = config.placement or "bottom"
	local middleware = config.middleware or {}

	return Promise.new(function(resolve)
		local rects = {} :: unknown

		local coords = computeCoordsFromPlacement(rects, "bottom")
		local x, y = coords.x, coords.y
		local resetCount = 0

		local promises = table.create(#middleware)
		for _, middleware_ in middleware do
			table.insert(
				promises,
				Promise.resolve(middleware_
					.fn({
						x = x,
						y = y,
						elements = { reference = reference, floating = floating },
					})
					:andThen(function(result)
						local nextX = result.x
						local nextY = result.y

						x = nextX or x
						y = nextY or y

						if result.result and resetCount <= MAX_RESETS then
							resetCount += 1
						end
					end))
			)
		end

		return Promise.all(promises):andThenCall(resolve, {
			x = x,
			y = y,
		})
	end)
end

return computePosition
