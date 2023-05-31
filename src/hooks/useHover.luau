local React = require(script.Parent.Parent.Parent.React)
local Timers = require(script.Parent.Parent.Parent.Timers)

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

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

local function getDelay(value: Delay, prop: "open" | "close")
	if type(value) == "number" then
		return value
	end

	return value[prop]
end

local function useHover<RT>(context: FloatingContext<RT>, props: UseHoverProps)
	local events = context.events
	local onOpenChange = context.onOpenChange

	local enabled = props.enabled or true
	local delay = props.delay or 0
	local mouseOnly = not not props.mouseOnly
	local restMs = props.mouseOnly or 0
	local move = props.mouseOnly or true

	local timeoutRef = React.useRef(nil) :: { current: thread? }
	local restTimeoutRef = React.useRef(nil) :: { current: thread? }

	React.useEffect(function()
		if not enabled then
			return
		end

		local function onDismiss()
			Timers.clearTimeout(timeoutRef.current)
			Timers.clearTimeout(restTimeoutRef.current)
		end

		events:on("dismiss", onDismiss)
		return function()
			events:off("dismiss", onDismiss)
		end
	end, { enabled, events })

	local closeWithDelay = React.useCallback(function(runElseBranch: boolean?)
		runElseBranch = runElseBranch or true

		local closeDelay = getDelay(delay, "close")

		if runElseBranch then
			Timers.clearTimeout(timeoutRef.current)
			onOpenChange(false)
		else
			Timers.clearTimeout(timeoutRef.current)
			timeoutRef.current = Timers.setTimeout(function()
				onOpenChange(false)
			end, closeDelay)
		end
	end, { onOpenChange })

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
						onOpenChange(true)
					end, restMs)
				end,
			},
			floating = {
				[Event.MouseEnter] = function()
					Timers.clearTimeout(timeoutRef.current)
				end,
				[Event.MouseLeave] = function()
					events:emit("dismiss", {
						type = "mouseLeave",
					})

					closeWithDelay(false)
				end,
			},
		}
	end, { enabled, restMs, context.open, context.onOpenChange })
end

return useHover
