local React = require(script.Parent.Parent.Parent.Parent.React)

local function useEffectEvent<A...>(callback: (A...) -> ())
	local ref = React.useRef(function()
		if _G.__DEV__ then
			error("Cannot call an event handler while rendering.")
		end
	end)

	React.useEffect(function()
		ref.current = callback
	end)

	return React.useCallback(function(...: A...)
		return ref.current and ref.current(...)
	end, {})
end

return useEffectEvent
