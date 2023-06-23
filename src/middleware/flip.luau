local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object

local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

export type Options = {
	mainAxis: boolean?,
	crossAxis: boolean?,
	fallbackPlacements: { string }?,
	fallbackStrategy: "bestFit" | "initialPlacement"?,
	fallbackAxisSideDirection: "none" | "start" | "end"?,
	flipAlignment: boolean?,
}

local detectOverflow = require(script.Parent.Parent.detectOverflow)
local getSide = require(script.Parent.Parent.utils.getSide)
local getAlignmentSides = require(script.Parent.Parent.utils.getAlignmentSides)
local getOppositePlacement = require(script.Parent.Parent.utils.getOppositePlacement)
local getExpandedPlacements = require(script.Parent.Parent.utils.getExpandedPlacements)
local getOppositeAxisPlacements = require(script.Parent.Parent.utils.getOppositeAxisPlacement)

--[=[
	@within Middleware
]=]
local function flip(options: Options?): Middleware
	if options == nil then
		options = {} :: Options
	end

	return {
		name = "flip",
		options = options,
		fn = function(state)
			local placement = state.placement
			local initialPlacement = state.initialPlacement
			local middlewareData = state.middlewareData

			local checkMainAxis = if (options :: Options).mainAxis == nil then true else (options :: Options).mainAxis
			local checkCrossAxis = if (options :: Options).crossAxis == nil
				then true
				else (options :: Options).crossAxis
			local specifiedFallbackPlacements = (options :: Options).fallbackPlacements
			local flipAlignment = if (options :: Options).flipAlignment == nil
				then true
				else (options :: Options).flipAlignment
			local fallbackAxisSideDirection = (options :: Options).fallbackAxisSideDirection or "none"
			local fallbackStrategy = (options :: Options).fallbackStrategy or "bestFit"
			local detectOverflowOptions = Object.assign({}, options, {
				mainAxis = Object.None,
				crossAxis = Object.None,
				fallbackPlacements = Object.None,
				flipAlignment = Object.None,
				fallbackAxixSideDirection = Object.None,
				fallbackStrategy = Object.None,
			})

			local side = getSide(placement)
			local isBasePlacement = getSide(initialPlacement) == placement

			local fallbackPlacements = specifiedFallbackPlacements
				or (
					if isBasePlacement or not flipAlignment
						then { getOppositePlacement(initialPlacement) }
						else getExpandedPlacements(initialPlacement)
				)

			if not specifiedFallbackPlacements and fallbackAxisSideDirection ~= "none" then
				for _, alignment in
					getOppositeAxisPlacements(initialPlacement, flipAlignment, fallbackAxisSideDirection)
				do
					table.insert(fallbackPlacements, alignment)
				end
			end

			local placements = { initialPlacement, unpack(fallbackPlacements) }

			local overflow = detectOverflow(state, detectOverflowOptions)
			local overflows = {}
			local overflowsData = if middlewareData.flip then middlewareData.flip.overflows else {}

			if checkMainAxis then
				table.insert(overflows, overflow[side])
			end

			if checkCrossAxis then
				local main, cross = getAlignmentSides(placement, state.rects)
				table.insert(overflows, overflow[main])
				table.insert(overflows, overflow[cross])
			end

			overflowsData = table.clone(overflowsData)
			table.insert(overflowsData, { placement = placement, overflows = overflows })

			if not Array.every(overflows, function(side)
				return side <= 0
			end) then
				local nextIndex = ((middlewareData.flip and middlewareData.flip.index) or 0) + 1
				local nextPlacement = placements[nextIndex]

				if nextPlacement then
					return {
						data = {
							index = nextIndex,
							overflows = overflowsData,
						},
						reset = {
							placement = nextPlacement,
						},
					}
				end

				local resetPlacement = Array.sort(
					Array.filter(overflowsData, function(d)
						return d.overflows[1] <= 0
					end),
					function(a, b)
						return a.overflows[2] - b.overflows[2]
					end
				)[1]

				if resetPlacement then
					resetPlacement = resetPlacement.placement
				end

				if not resetPlacement then
					if fallbackStrategy == "bestFit" then
						local placement_ = Array.sort(
							Array.map(overflowsData, function(d)
								return {
									d.placement,
									Array.reduce(
										Array.filter(d.overflows, function(overflow)
											return overflow > 0
										end),
										function(acc, overflow)
											return acc + overflow
										end,
										0
									),
								}
							end),
							function(a, b)
								return a[2] - b[2]
							end
						)[1]

						if placement_ then
							resetPlacement = placement_[1]
						end
					elseif fallbackStrategy == "initialPlacement" then
						resetPlacement = initialPlacement
					end
				end

				if placement ~= resetPlacement then
					return {
						reset = {
							placement = resetPlacement,
						},
					}
				end
			end

			return {}
		end,
	}
end

return flip
