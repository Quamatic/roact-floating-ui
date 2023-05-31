local React = require(script.Parent.Parent.Parent.React)
local Timers = require(script.Parent.Parent.Parent.Timers)

local useLatestRef = require(script.Parent.utils.useLatestRef)
local useFloatingTree = require(script.Parent.Parent.components.FloatingTree).useFloatingTree
local merge = require(script.Parent.Parent.utils.merge)

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

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
	local handleClose = props.handleClose or nil
	local delay_ = props.delay or 0
	local mouseOnly = not not props.mouseOnly
	local restMs = props.mouseOnly or 0
	local move = props.mouseOnly or true

	local tree = useFloatingTree()
	local timeoutRef = React.useRef(nil) :: { current: thread? }
	local restTimeoutRef = React.useRef(nil) :: { current: thread? }
	local handleRef = React.useRef(nil)
	local handleCloseRef = useLatestRef(handleClose)
	local delayRef = useLatestRef(delay_)

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

		local closeDelay = getDelay(delay_, "close")

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
				[React.Event.InputBegan] = function(_rbx: Instance, input: InputObject)
					if context.open then
						return
					end

					if input.UserInputType ~= Enum.UserInputType.MouseMovement then
						return
					end

					Timers.clearTimeout(timeoutRef.current)

					local openDelay = getDelay(delayRef.current, "open")
					if openDelay then
						timeoutRef.current = Timers.setTimeout(function()
							onOpenChange(true)
						end, openDelay)
					else
						onOpenChange(true)
					end
				end,
				[React.Event.InputEnded] = function(_rbx: Instance, input: InputObject)
					Timers.clearTimeout(timeoutRef.current)

					if handleCloseRef.current then
						if not context.open then
							Timers.clearTimeout(timeoutRef.current)
						end

						handleRef.current = handleCloseRef.current(merge(context, {
							tree = tree,
							position = Vector2.new(input.Position.X, input.Position.Y),
							onClose = function()
								closeWithDelay(false)
							end,
						}))

						return
					end

					local shouldClose = true
					if shouldClose then
						closeWithDelay(false)
					end
				end,
				[React.Event.InputChanged] = function(_rbx: Instance, input: InputObject)
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
				[React.Event.MouseEnter] = function()
					Timers.clearTimeout(timeoutRef.current)
				end,
				[React.Event.MouseLeave] = function()
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
