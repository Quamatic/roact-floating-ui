local React = require(script.Parent.Parent.Parent.Parent.React)
local Timers = require(script.Parent.Parent.Parent.Parent.Timers)

local useDelayGroupContext = require(script.Parent.useDelayGroupContext)

type Delay = number | { open: number?, close: number? }

local function getDelay(value: Delay, prop: "open" | "close")
	if type(value) == "number" then
		return value
	end

	return value[prop]
end

local function useDelayGroup(context, options)
	local onOpenChange = context.onOpenChange
	local open = context.open
	local id = options.id

	local delayGroupContext = useDelayGroupContext()

	local currentId = delayGroupContext.currentId
	local setState = delayGroupContext.setState
	local initialDelay = delayGroupContext.initialDelay
	local timeoutMs = delayGroupContext.timeoutMs
	local setCurrentId = delayGroupContext.setCurrentId

	React.useLayoutEffect(function()
		if currentId then
			setState({
				delay = {
					open = 1,
					close = getDelay(initialDelay, "close"),
				},
			})

			if currentId ~= id then
				onOpenChange(false)
			end
		end
	end, { id, onOpenChange, setState, currentId, initialDelay })

	React.useLayoutEffect(function()
		local function unset()
			onOpenChange(false)
			setState({
				delay = initialDelay,
				currentId = nil,
			})
		end

		if not open and currentId == id then
			if timeoutMs then
				local timeout = Timers.setTimeout(unset, timeoutMs)
				return function()
					Timers.clearTimeout(timeout)
				end
			else
				unset()
			end
		end

		return nil -- This is only here to make Luau shut up
	end, { open, setState, currentId, id, onOpenChange, initialDelay, timeoutMs })

	React.useLayoutEffect(function()
		if open then
			setCurrentId(id)
		end
	end, { open, setCurrentId, id })
end

return useDelayGroup
