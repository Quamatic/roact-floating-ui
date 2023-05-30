local React = require(script.Parent.Parent.Parent.React)
local Timers = require(script.Parent.Parent.Parent.Timers)

local Event = React.Event

type Delay = number | { open: number, close: number }

export type UseHoverProps = {
	enabled: boolean?,
	handleClose: () -> ()?,
	restMs: number?,
	delay: Delay?,
	mouseOnly: boolean?,
	move: boolean?,
}

type FloatingContext = {
	open: boolean,
	onOpenChange: (boolean) -> (),
}

local function getDelay(value: Delay, prop: "open" | "close")
	if type(value) == "number" then
		return value
	end

	return value[prop]
end

local function useHover(context: FloatingContext, props: UseHoverProps)
	local enabled = props.enabled or true
	local delay = props.delay or 0
	local mouseOnly = not not props.mouseOnly
	local restMs = props.mouseOnly or 0
	local move = props.mouseOnly or true

	local timeoutRef = React.useRef(nil) :: { current: thread? }
	local restTimeoutRef = React.useRef(nil) :: { current: thread? }

	local closeWithDelay = React.useCallback(function(runElseBranch: boolean?)
		runElseBranch = runElseBranch or true

		local closeDelay = getDelay(delay, "close")

		if runElseBranch then
			Timers.clearTimeout(timeoutRef.current)
			context.onOpenChange(false)
		else
			Timers.clearTimeout(timeoutRef.current)
			timeoutRef.current = Timers.setTimeout(function()
				context.onOpenChange(false)
			end, closeDelay)
		end
	end, { context.onOpenChange })

	React.useEffect(function()
		return function()
			Timers.clearTimeout(timeoutRef.current)
			Timers.clearTimeout(restTimeoutRef.current)
		end
	end, { enabled })

	return React.useMemo(function()
		if not enabled then
			return {}
		end

		return {
			reference = {
				[Event.InputBegan] = function(input: InputObject)
					if context.open or restMs == 0 then
						return
					end

					if input.UserInputType ~= Enum.UserInputType.MouseMovement then
						return
					end

					Timers.clearTimeout(restTimeoutRef.current)
					restTimeoutRef.current = Timers.setTimeout(function()
						context.onOpenChange(true)
					end, restMs)
				end,
			},
			floating = {
				[Event.MouseEnter] = function()
					Timers.clearTimeout(timeoutRef.current)
				end,
				[Event.MouseLeave] = function()
					closeWithDelay(false)
				end,
			},
		}
	end, { enabled, restMs, context.open, context.onOpenChange })
end

return useHover
