local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object

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
local getSide = require(script.Parent.Parent.utils.getSide)
local getCrossAxis = require(script.Parent.Parent.utils.getCrossAxis)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)

local defaultLimiter: Limiter = {
	fn = function(state)
		return { x = state.x, y = state.y }
	end,
}

local function within(min, value, max)
	return math.max(min, math.min(value, max))
end

--[=[
	@within Middleware
]=]
local function shift(options: Options?): Middleware
	if options == nil then
		options = {} :: Options
	end

	return {
		name = "shift",
		options = options,
		fn = function(state)
			local x = state.x
			local y = state.y
			local placement = state.placement

			local checkMainAxis = if (options :: Options).mainAxis == nil then true else (options :: Options).mainAxis
			local checkCrossAxis = if (options :: Options).crossAxis == nil
				then false
				else (options :: Options).crossAxis
			local limiter = (options :: Options).limiter or defaultLimiter
			local detectOverflowOptions = Object.assign({}, options, {
				mainAxis = Object.None,
				crossAxis = Object.None,
				limiter = Object.None,
			})

			local coords = { x = x, y = y }
			local overflow = detectOverflow(state, detectOverflowOptions)

			local mainAxis = getMainAxisFromPlacement(getSide(placement))
			local crossAxis = getCrossAxis(mainAxis)

			local mainAxisCoord = coords[mainAxis]
			local crossAxisCoord = coords[crossAxis]

			if checkMainAxis then
				local minSide = if mainAxis == "y" then "top" else "left"
				local maxSide = if mainAxis == "y" then "bottom" else "right"

				local min = math.floor(mainAxisCoord + overflow[minSide])
				local max = math.floor(mainAxisCoord - overflow[maxSide])

				mainAxisCoord = within(min, mainAxisCoord, max)
			end

			if checkCrossAxis then
				local minSide = if crossAxis == "y" then "top" else "left"
				local maxSide = if crossAxis == "y" then "bottom" else "right"
				local min = crossAxisCoord + overflow[minSide]
				local max = crossAxisCoord - overflow[maxSide]

				crossAxisCoord = within(min, crossAxisCoord, max)
			end

			local limitedCoords = limiter.fn(Object.assign({}, state, {
				[mainAxis] = mainAxisCoord,
				[crossAxis] = crossAxisCoord,
			}))

			return Object.assign({}, limitedCoords, {
				data = {
					x = limitedCoords.x - x,
					y = limitedCoords.y - y,
				},
			})
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

local function limitShift(options: LimitShiftOptions?): {
	options: LimitShiftOptions,
	fn: (state: MiddlewareState) -> { x: number, y: number },
}
	if options == nil then
		options = {} :: LimitShiftOptions
	end

	return {
		options = options,
		fn = function(state)
			local x = state.x
			local y = state.y
			local placement = state.placement
			local rects = state.rects
			local middlewareData = state.middlewareData

			local offset = (options :: LimitShiftOptions).offset or 0
			local checkMainAxis = if (options :: LimitShiftOptions).mainAxis == nil
				then true
				else (options :: LimitShiftOptions).mainAxis
			local checkCrossAxis = if (options :: LimitShiftOptions).crossAxis == nil
				then true
				else options :: LimitShiftOptions

			local coords = { x = x, y = y }
			local mainAxis = getMainAxisFromPlacement(placement)
			local crossAxis = getCrossAxis(mainAxis)

			local mainAxisCoord = coords[mainAxis]
			local crossAxisCoord = coords[crossAxis]

			local rawOffset = if type(offset) == "function" then offset(state) else offset
			local computedOffset = if type(rawOffset) == "number"
				then { mainAxis = rawOffset, crossAxis = 0 }
				else Object.assign({ mainAxis = 0, crossAxis = 0 }, rawOffset)

			if checkMainAxis then
				local len = if mainAxis == "y" then "height" else "width"
				local limitMin = rects.reference[mainAxis] - rects.floating[len] + computedOffset.mainAxis
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
