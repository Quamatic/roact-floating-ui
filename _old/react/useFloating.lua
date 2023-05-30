local React = require(script.Parent.Parent.Parent.React)

local computePosition = require(script.Parent.Parent.core.computePosition)
local merge = require(script.Parent.Parent.core.utils.merge)

type UseFloatingOptions = {
	open: boolean,
	middleware: {},
}

local function useFloating(options: UseFloatingOptions)
	local data, setData = React.useState({
		x = 0,
		y = 0,
		middlewareData = {},
		isPositioned = false,
	})

	local isMountedRef = React.useRef(false)
	local referenceRef = React.useRef(nil)
	local floatingRef = React.useRef(nil)

	local update = React.useCallback(function()
		if not referenceRef.current or not floatingRef.current then
			return
		end

		local config = {}

		computePosition(referenceRef.current, floatingRef.current, config):andThen(function(data)
			if isMountedRef.current then
				setData()
			end
		end)
	end, {})

	React.useLayoutEffect(function()
		isMountedRef.current = true

		return function()
			isMountedRef.current = false
		end
	end, {})

	React.useLayoutEffect(function()
		update()
	end, {})

	local floatingStyles = React.useMemo(function()
		local x = data.x
		local y = data.y

		return {
			Position = UDim2.fromOffset(x, y),
		}
	end, {})

	return React.useMemo(function()
		return merge(data, {
			update = update,
			floatingStyles = floatingStyles,
		})
	end, { data, update, floatingStyles })
end

return useFloating
