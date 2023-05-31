local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

type Limiter = {
	fn: (state: MiddlewareState) -> Vector2,
	options: any?,
}

export type Options = {
	mainAxis: number?,
	crossAxis: number?,
	limiter: Limiter?,
}

local detectOverflow = require(script.Parent.Parent.detectOverflow)
local merge = require(script.Parent.Parent.utils.merge)
local getSide = require(script.Parent.Parent.utils.getSide)
local getCrossAxis = require(script.Parent.Parent.utils.getCrossAxis)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)

local defaultLimiter: Limiter = {
	fn = function(state)
		return state.position
	end,
}

local function within(min, value, max)
	return math.max(min, math.min(value, max))
end

--[=[
	@within Middleware
]=]
local function shift(options: Options): Middleware
	return {
		name = "shift",
		options = options,
		fn = function(state)
			local position = state.position
			local placement = state.placement

			local checkMainAxis = options.mainAxis or true
			local checkCrossAxis = options.crossAxis or false
			local limiter = options.limiter or defaultLimiter

			local overflow = detectOverflow(state, {})
			local mainAxis = getMainAxisFromPlacement(getSide(placement))
			local crossAxis = getCrossAxis(mainAxis)

			local mainAxisCoord = position[mainAxis]
			local crossAxisCoord = position[crossAxis]

			if checkMainAxis then
				local minSide = if mainAxis == "Y" then "top" else "left"
				local maxSide = if mainAxis == "Y" then "bottom" else "right"

				local min = math.floor(mainAxisCoord + overflow[minSide])
				local max = math.floor(mainAxisCoord - overflow[maxSide])

				mainAxisCoord = within(min, mainAxisCoord, max)
			end

			if checkCrossAxis then
				local minSide = if crossAxis == "Y" then "top" else "left"
				local maxSide = if crossAxis == "Y" then "bottom" else "right"
				local min = crossAxisCoord + overflow[minSide]
				local max = crossAxisCoord - overflow[maxSide]

				crossAxisCoord = within(min, crossAxisCoord, max)
			end

			local position_: Vector2
			if mainAxis == "X" and crossAxis == "Y" then
				position_ = Vector2.new(mainAxisCoord, crossAxisCoord)
			elseif mainAxis == "Y" and crossAxis == "X" then
				position_ = Vector2.new(crossAxisCoord, mainAxisCoord)
			end

			local limitedCoords = limiter.fn(merge(state, {
				position = position_,
			}))

			return {
				position = limitedCoords,
				data = {
					x = limitedCoords.X - position.X,
					y = limitedCoords.Y - position.Y,
				},
			}
		end,
	}
end

return shift
