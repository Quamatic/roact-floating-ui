local React = require(script.Parent.Parent.Parent.React)
local ReactRoblox = require(script.Parent.Parent.Parent.ReactRoblox)

local useDelayUnmount = require(script.useDelayUnmount)

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

export type UseTransitionStatusProps = {
	duration: number | { open: number, close: number }?,
}

type Status = "unmounted" | "initial" | "open" | "close"

type UseTransitionReturn = {
	isMounted: boolean,
	status: Status,
}

local function useTransitionStatus<RT>(context: FloatingContext<RT>, props: UseTransitionStatusProps): UseTransitionReturn
	local open = context.open
	local floating = context.refs.floating
	local duration = props.duration or 250

	local isNumberDuration = type(duration) == "number"
	local closeDuration = (if isNumberDuration then duration else duration.close) or 0

	local initiated, setInitiated = React.useState(false)
	local status, setStatus = React.useState("unmounted" :: Status)
	local isMounted = useDelayUnmount(open, closeDuration)

	React.useLayoutEffect(function()
		if initiated and not isMounted then
			setStatus("unmounted")
		end
	end, { initiated, isMounted })

	React.useLayoutEffect(function()
		if not floating then
			return
		end

		if open then
			setStatus("initial")

			local frame = task.defer(function()
				setStatus("open")
			end)

			return function()
				task.cancel(frame)
			end
		else
			ReactRoblox.unstable_batchedUpdates(function()
				setInitiated(true)
				setStatus("close")
			end)
		end

		return nil
	end, { open, floating })

	return {
		isMounted = isMounted,
		status = status,
	}
end

return useTransitionStatus
