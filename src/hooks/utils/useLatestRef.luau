local React = require(script.Parent.Parent.Parent.Parent.React)

local function useLatestRef<T>(value: T)
	local valueRef = React.useRef(value)

	React.useEffect(function()
		valueRef.current = value
	end, { value })

	return valueRef
end

return useLatestRef
