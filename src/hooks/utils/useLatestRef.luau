local React = require(script.Parent.Parent.Parent.Parent.React)

local function useLatestRef<T>(value: T)
	local valueRef = React.useRef(value)

	React.useLayoutEffect(function()
		valueRef.current = value
	end)

	return valueRef
end

return useLatestRef
