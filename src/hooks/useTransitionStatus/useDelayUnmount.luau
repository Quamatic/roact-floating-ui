local React = require(script.Parent.Parent.Parent.Parent.React)
local Timers = require(script.Parent.Parent.Parent.Parent.Timers)

local function useDelayUnmount(open: boolean, durationMs: number)
	local isMounted, setIsMounted = React.useState(open)

	if open and not isMounted then
		setIsMounted(true)
	end

	React.useEffect(function()
		if not open then
			local timeout = Timers.setTimeout(setIsMounted, durationMs, false)
			return function()
				Timers.clearTimeout(timeout)
			end
		end
	end, { open, durationMs })

	return isMounted
end

return useDelayUnmount
