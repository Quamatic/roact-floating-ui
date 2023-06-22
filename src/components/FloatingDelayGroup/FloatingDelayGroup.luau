local src = script.Parent.Parent.Parent.Parent
local React = require(src.React)
local LuauPolyfill = require(src.LuauPolyfill)
local Object = LuauPolyfill.Object

local FloatingDelayGroupContext = require(script.Parent["FloatingDelayGroup.context"])
type GroupState = FloatingDelayGroupContext.GroupState
type GroupContext = FloatingDelayGroupContext.GroupContext

local e = React.createElement

type Delay = number | { open: number?, close: number? }

type FloatingDelayGroupProps = {
	delay: Delay?,
	timeoutMs: number?,
	children: any?,
}

local function FloatingDelayGroup(props: FloatingDelayGroupProps)
	local delay = props.delay
	local timeoutMs = props.timeoutMs or 0

	local state, setState = React.useReducer(function(prev: GroupState, next_: GroupState): GroupState
		return Object.assign({}, prev, next_)
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

	return e(FloatingDelayGroupContext.Provider, {
		value = React.useMemo(function()
			return Object.assign({}, state, {
				setState = setState,
				setCurrentId = setCurrentId,
			})
		end, { state, setState, setCurrentId }),
	}, props.children)
end

return FloatingDelayGroup
