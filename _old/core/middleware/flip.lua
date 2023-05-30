local types = require(script.Parent.Parent.types)
type Middleware = types.Middleware
type Placement = types.Placement

export type Options = {
	mainAxis: boolean?,
	crossAxis: boolean?,
	fallbackPlacements: { Placement }?,
	fallbackStrategy: "bestFit" | "initialPlacement"?,
	fallbackAxisSideDirection: "none" | "start" | "end"?,
	flipAlignment: boolean?,
}

local getSide = require(script.Parent.Parent.utils.getSide)
local detectOverflow = require(script.Parent.Parent.detectOverflow)

local function everyOverflowSatisfies(overflows)
	for _, side in overflows do
		if side > 0 then
			return false
		end
	end
	return true
end

local function flip(options: Options): Middleware
	return {
		name = "flip",
		options = options,
		fn = function(state)
			local placement = state.placement
			local initialPlacement = state.initialPlacement

			local checkMainAxis = options.mainAxis or true
			local checkCrossAxis = options.crossAxis or true
			local specifiedFallbackPlacements = options.fallbackPlacements
			local fallbackStrategy = options.fallbackStrategy or "bestFit"
			local fallbackAxisSidedirection = options.fallbackAxisSideDirection or "none"
			local flipAlignment = options.flipAlignment or true

			local side = getSide(placement)
			local isBasePlacement = getSide(initialPlacement) == initialPlacement

			local fallbackPlacements = {}

			local placements = { initialPlacement, unpack(fallbackPlacements) }
			local overflow = detectOverflow(state, {})
			local overflows = {}

			if checkMainAxis then
				table.insert(overflows, overflow[side])
			end

			if checkCrossAxis then
				local main, cross = getSide(placement)

				table.insert(overflows, overflow[main])
				table.insert(overflows, overflow[cross])
			end

			if not everyOverflowSatisfies(overflows) then
				local nextIndex = 0
			end

			return {}
		end,
	}
end

return flip
