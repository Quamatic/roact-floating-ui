local React = require(script.Parent.Parent.Parent.Parent.React)

local deepEqual = require(script.Parent.deepEqual)
local roundByDPR = require(script.Parent.roundByDPR)
local merge = require(script.Parent.Parent.Parent.utils.merge)
local computePosition = require(script.Parent.Parent.Parent.computePosition)
local useLatestRef = require(script.Parent.Parent.utils.useLatestRef)

local types = require(script.Parent["types.d"])

type ReferenceType = types.ReferenceType
type UseFloatingOptions<RT = ReferenceType> = types.UseFloatingOptions<RT>
type UseFloatingReturn<RT = ReferenceType> = types.UseFloatingReturn<RT>
type UseFloatingData = types.UseFloatingData

local function useFloating<RT>(options: UseFloatingOptions<RT>): UseFloatingReturn<RT>
	-- Fill out defaults.
	local placement = options.placement or "bottom"
	local middleware = options.middleware or {}
	local _elements = options.elements or {}
	local externalReference = _elements.reference
	local externalFloating = _elements.floating
	local whileElementsMounted = options.whileElementsMounted
	local open = options.open

	local data, setData = React.useState({
		x = 0,
		y = 0,
		placement = placement,
		middlewareData = {},
		isPositioned = false,
	} :: UseFloatingData)

	local latestMiddleware, setLatestMiddleware = React.useState(middleware)

	-- We don't need to have this check in an effect - that would cause an unneccessary re-render.
	if not deepEqual(latestMiddleware, middleware) then
		setLatestMiddleware(middleware)
	end

	local _reference, _setReference = React.useState(nil :: RT?)
	local _floating, _setFloating = React.useState(nil :: GuiObject?)

	local referenceRef = React.useRef(nil :: RT?)
	local floatingRef = React.useRef(nil :: GuiObject?)
	local dataRef = React.useRef(data)

	local referenceEl = (externalReference or _reference) :: RT?
	local floatingEl = externalFloating or _floating

	local whileElementsMountedRef = useLatestRef(whileElementsMounted)

	local setReference = React.useCallback(function(node: RT?)
		if node ~= referenceRef.current then
			referenceRef.current = node
			_setReference(node)
		end
	end, { _setReference })

	local setFloating = React.useCallback(function(node: GuiObject?)
		if node ~= floatingRef.current then
			floatingRef.current = node
			_setFloating(node)
		end
	end, { _setFloating })

	React.useLayoutEffect(function()
		if open == false and dataRef.current.isPositioned then
			dataRef.current.isPositioned = false
			setData(function(data)
				return merge(data, { isPositioned = false })
			end)
		end
	end, { open })

	local isMountedRef = React.useRef(false)
	React.useLayoutEffect(function()
		isMountedRef.current = true
		return function()
			isMountedRef.current = false
		end
	end, {})

	local update = React.useCallback(function()
		if not referenceRef.current or not floatingRef.current then
			return
		end

		local config = {
			placement = placement,
			middleware = latestMiddleware,
		}

		local data = computePosition(referenceRef.current, floatingRef.current, config)
		local fullData = merge(data, { isPositioned = true })

		if isMountedRef.current and not deepEqual(dataRef.current, fullData) then
			dataRef.current = fullData
			-- deviation: can't use flushSync here
			setData(fullData)
		end
	end, { latestMiddleware, placement })

	React.useLayoutEffect(function()
		if referenceEl then
			referenceRef.current = referenceEl
		end

		if floatingEl then
			floatingRef.current = floatingEl
		end

		if referenceEl and floatingEl then
			if whileElementsMountedRef.current then
				return whileElementsMountedRef.current(referenceEl, floatingEl, update)
			else
				update()
			end
		end

		return nil
	end, { referenceEl, floatingEl, update, whileElementsMountedRef })

	local refs = React.useMemo(function()
		return {
			reference = referenceRef,
			floating = floatingRef,
			setReference = setReference,
			setFloating = setFloating,
		}
	end, { setReference, setFloating })

	local elements = React.useMemo(function()
		return {
			reference = referenceEl,
			floating = floatingEl,
		}
	end, { referenceEl, floatingEl })

	local floatingStyles = React.useMemo(function()
		if not elements.floating then
			return {
				Position = UDim2.fromOffset(0, 0),
			}
		end

		local x = roundByDPR(data.x)
		local y = roundByDPR(data.y)

		return {
			Position = UDim2.fromOffset(x, y),
		}
	end, { data.x, data.y, elements.floating })

	return React.useMemo(function()
		return merge(data, {
			update = update,
			refs = refs,
			elements = elements,
			floatingStyles = floatingStyles,
		})
	end, { data, update, refs, elements, floatingStyles })
end

return useFloating
