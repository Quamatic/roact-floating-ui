local Array = require(script.Parent.Parent.Parent.Collections).Array

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
			local x = state.x
			local y = state.y
			local placement = state.placement

			local checkMainAxis = options.mainAxis or true
			local checkCrossAxis = options.crossAxis or false
			local limiter = options.limiter or defaultLimiter

			local coords = { x = x, y = y }
			local overflow = detectOverflow(state, {})
			local mainAxis = getMainAxisFromPlacement(getSide(placement))
			local crossAxis = getCrossAxis(mainAxis)

			local mainAxisCoord = coords[mainAxis]
			local crossAxisCoord = coords[crossAxis]

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

			local limitedCoords = limiter.fn(merge(state, {
				[mainAxis] = mainAxisCoord,
				[crossAxis] = crossAxisCoord,
			}))

			return {
				position = limitedCoords,
				data = {
					x = limitedCoords.X - x,
					y = limitedCoords.Y - y,
				},
			}
		end,
	}
end

type LimitShiftOffset =
	((args: MiddlewareState) -> number | { mainAxis: number?, crossAxis: number? })
	| number
	| { mainAxis: number?, crossAxis: number? }

type LimitShiftOptions = {
	offset: LimitShiftOffset?,
	mainAxis: boolean?,
	crossAxis: boolean?,
}

local function limitShift(options: LimitShiftOptions): {
	options: LimitShiftOptions,
	fn: (state: MiddlewareState) -> { x: number, y: number },
}
	return {
		options = options,
		fn = function(state)
			local x = state.x
			local y = state.y
			local placement = state.placement
			local rects = state.rects
			local middlewareData = state.middlewareData

			local offset = options.offset or 0
			local checkMainAxis = options.mainAxis or true
			local checkCrossAxis = options.crossAxis or true

			local coords = { x = x, y = y }
			local mainAxis = getMainAxisFromPlacement(placement)
			local crossAxis = getCrossAxis(mainAxis)

			local mainAxisCoord = coords[mainAxis]
			local crossAxisCoord = coords[crossAxis]

			local rawOffset = if type(offset) == "function" then offset(state) else offset
			local computedOffset = if type(rawOffset) == "number"
				then { mainAxis = rawOffset, crossAxis = 0 }
				else merge({ mainAxis = 0, crossAxis = 0 }, rawOffset)

			if checkMainAxis then
				local len = if mainAxis == "y" then "height" else "width"
				local limitMin = rects.reference[mainAxis] + rects.floating[len] + computedOffset.mainAxis
				local limitMax = rects.reference[mainAxis] + rects.reference[len] - computedOffset.mainAxis

				if mainAxisCoord < limitMin then
					mainAxisCoord = limitMin
				elseif mainAxisCoord > limitMax then
					mainAxisCoord = limitMax
				end
			end

			if checkCrossAxis then
				local len = if mainAxis == "y" then "width" else "height"
				local isOriginSide = Array.includes({ "top", "left" }, getSide(placement))
				local availableOffset = (middlewareData.offset and middlewareData.offset[crossAxis]) or 0

				local limitMin = rects.reference[crossAxis]
					- rects.floating[len]
					+ (if isOriginSide then availableOffset else 0)
					+ (if isOriginSide then 0 else computedOffset.crossAxis)

				local limitMax = rects.reference[crossAxis]
					+ rects.reference[len]
					+ (if isOriginSide then 0 else availableOffset)
					- (if isOriginSide then computedOffset.crossAxis else 0)

				if crossAxisCoord < limitMin then
					crossAxisCoord = limitMin
				elseif crossAxisCoord > limitMax then
					crossAxisCoord = limitMax
				end
			end

			return {
				[mainAxis] = mainAxisCoord,
				[crossAxis] = crossAxisCoord,
			}
		end,
	}
end

return {
	shift = shift,
	limitShift = limitShift,
}