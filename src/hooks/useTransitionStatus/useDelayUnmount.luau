local src = script.Parent.Parent.Parent.Parent
local React = require(src.React)
local LuauPolyfill = require(src.LuauPolyfill)
local setTimeout, clearTimeout = LuauPolyfill.setTimeout, LuauPolyfill.clearTimeout

local function useDelayUnmount(open: boolean, durationMs: number)
	local isMounted, setIsMounted = React.useState(open)

	if open and not isMounted then
		setIsMounted(true)
	end

	React.useEffect(function()
		if not open then
			local timeout = setTimeout(setIsMounted, durationMs, false)
			return function()
				clearTimeout(timeout)
			end
		end
	end, { open, durationMs })

	return isMounted
end

return useDelayUnmount
