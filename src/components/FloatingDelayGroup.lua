local React = require(script.Parent.Parent.Parent.React)
local Timers = require(script.Parent.Parent.Parent.Timers)

local merge = require(script.Parent.Parent.utils.merge)

local e = React.createElement

type Delay = number | { open: number?, close: number? }

type GroupState = {
	delay: Delay,
	initialDelay: Delay,
	currentId: any,
	timeoutMs: number,
	isInstantPhase: boolean,
}

type GroupContext = GroupState & {
	setCurrentId: (currentId: any) -> (),
	setState: (state: GroupState) -> (),
}

local FloatingGroupDelayContext = React.createContext({
	delay = 0,
	initialDelay = 0,
	timeoutMs = 0,
	setCurrentId = function() end,
	setState = function() end,
	isInstantPhase = false,
} :: GroupContext)

local function useDelayGroupContext()
	return React.useContext(FloatingGroupDelayContext)
end

type FloatingDelayGroupProps = {
	delay: Delay?,
	timeoutMs: number?,
	children: any?,
}

local function FloatingDelayGroup(props: FloatingDelayGroupProps)
	local delay = props.delay
	local timeoutMs = props.timeoutMs or 0

	local state, setState = React.useReducer(function(prev: GroupState, next_: GroupState): GroupState
		return merge(prev, next_)
	end, {
		delay = delay,
		timeoutMs = timeoutMs,
		initialDelay = delay,
		isInstantPhase = false,
	} :: GroupContext)

	local initialCurrentIdRef = React.useRef(nil)

	local setCurrentId = React.useCallback(function(currentId: any)
		setState({
			currentId = currentId,
		})
	end, {})

	React.useLayoutEffect(function()
		if state.currentId then
			if initialCurrentIdRef.current == nil then
				initialCurrentIdRef.current = state.currentId
			else
				setState({ isInstantPhase = true })
			end
		else
			setState({ isInstantPhase = false })
			initialCurrentIdRef.current = nil
		end
	end, { state.currentId })

	return e(FloatingGroupDelayContext.Provider, {
		value = React.useMemo(function()
			return merge(state, {
				setState = setState,
				setCurrentId = setCurrentId,
			})
		end, { state, setState, setCurrentId }),
	}, props.children)
end

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
	end, { open, setState, currentId, id, onOpenChange, initialDelay, timeoutMs })

	React.useLayoutEffect(function()
		if open then
			setCurrentId(id)
		end
	end, { open, setCurrentId, id })
end

return {
	useDelayGroup = useDelayGroup,
	useDelayGroupContext = useDelayGroupContext,
	FloatingDelayGroup = FloatingDelayGroup,
}
