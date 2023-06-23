local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object

local types = require(script.Parent.Parent.types)

type Placement = types.Placement
type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

export type Options = {
	crossAxis: boolean?,
	alignment: string?,
	autoAlignment: boolean?,
	allowedPlacements: { Placement }?,
}

local enums = require(script.Parent.Parent.enums)
local allPlacements = enums.allPlacements

local getSide = require(script.Parent.Parent.utils.getSide)
local getAlignment = require(script.Parent.Parent.utils.getAlignment)
local getAlignmentSides = require(script.Parent.Parent.utils.getAlignmentSides)
local detectOverflow = require(script.Parent.Parent.detectOverflow)

local function getPlacementList(alignment: string | nil, autoAlignment: boolean, allowedPlacements: { Placement })
	local allowedPlacementsSortedByAlignment = if alignment
		then Array.concat(
			Array.filter(allowedPlacements, function(placement)
				return getAlignment(placement) == alignment
			end),
			Array.filter(allowedPlacements, function(placement)
				return getAlignment(placement) ~= alignment
			end)
		)
		else Array.filter(allowedPlacements, function(placement)
			return getSide(placement) == placement
		end)

	return Array.filter(allowedPlacementsSortedByAlignment, function(placement)
		if alignment then
			return getAlignment(placement) == alignment or if autoAlignment then true else false
		end

		return true
	end)
end

--[=[
	@within Middleware
]=]
local function autoPlacement(options: Options?): Middleware
	if options == nil then
		options = {} :: Options
	end

	return {
		name = "autoPlacement",
		options = options,
		fn = function(state)
			local middlewareData = state.middlewareData
			local placement = state.placement

			local crossAxis = if (options :: Options).crossAxis == nil then false else (options :: Options).crossAxis
			local alignment = (options :: Options).alignment
			local allowedPlacements = (options :: Options).allowedPlacements or allPlacements
			local autoAlignment = if (options :: Options).autoAlignment == nil
				then true
				else (options :: Options).autoAlignment
			local detectOverflowOptions = Object.assign({}, options, {
				crossAxis = Object.None,
				alignment = Object.None,
				allowedPlacements = Object.None,
				autoAlignment = Object.None,
			})

			local placements = if alignment ~= nil or allowedPlacements == allPlacements
				then getPlacementList(alignment, autoAlignment, allowedPlacements)
				else allowedPlacements

			local overflow = detectOverflow(state, detectOverflowOptions)

			local currentIndex = (middlewareData.autoPlacement and middlewareData.autoPlacement.index) or 1
			local currentPlacement = placements[currentIndex]

			if currentPlacement == nil then
				return {}
			end

			local main, cross = getAlignmentSides(currentPlacement, state.rects)

			if placement ~= currentPlacement then
				return {
					reset = {
						placement = placements[1],
					},
				}
			end

			local currentOverflows = {
				overflow[getSide(currentPlacement)],
				overflow[main],
				overflow[cross],
			}

			local allOverflows =
				table.clone((middlewareData.autoPlacement and middlewareData.autoPlacement.overflows) or {})
			table.insert(allOverflows, { placement = currentPlacement, overflows = currentOverflows })

			local nextPlacement = placements[currentIndex + 1]
			if nextPlacement then
				return {
					data = {
						index = currentIndex + 1,
						overflows = allOverflows,
					},
					reset = {
						placement = nextPlacement,
					},
				}
			end

			local placementsSortedByMostSpace = Array.sort(
				Array.map(allOverflows, function(d)
					local alignment = getAlignment(d.placement)
					return {
						d.placement,
						if alignment and crossAxis
							then Array.reduce(Array.slice(d.overflows, 0, 2), function(acc, v)
								return acc + v
							end, 0)
							else d.overflows[1],
						d.overflows,
					}
				end),
				function(a, b)
					return a[2] - b[2]
				end
			)

			local placementsThatFitOnEachSide = Array.filter(placementsSortedByMostSpace, function(d)
				return Array.every(Array.slice(d[3], 0, if getAlignment(d[1]) then 2 else 3), function(v)
					return v <= 0
				end)
			end)

			local resetPlacement = (placementsThatFitOnEachSide[1] and placementsThatFitOnEachSide[1][1])
				or placementsSortedByMostSpace[1][1]

			if resetPlacement ~= placement then
				return {
					data = {
						index = currentIndex + 1,
						overflows = allOverflows,
					},
					reset = {
						placement = resetPlacement,
					},
				}
			end

			return {}
		end,
	}
end

return autoPlacement
