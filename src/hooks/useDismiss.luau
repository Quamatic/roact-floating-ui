local React = require(script.Parent.Parent.Parent.React)

local useEffectEvent = require(script.Parent.utils.useEffectEvent)

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

type UseDismissProps = {
	enabled: boolean?,
	gamepadBackButton: boolean?,
	referencePress: boolean?,
	referencePressEvent: Enum.UserInputType?,
	outsidePress: boolean | ((input: InputObject) -> ())?,
	outsidePressEvent: Enum.UserInputType?,
	bubbles: boolean | { outsidePress: boolean? }?,
}

local function isGamepadInput(input: InputObject)
	return input.UserInputType.Name:find("Gamepad") ~= nil
end

local function useDismiss<RT>(context: FloatingContext<RT>, props: UseDismissProps)
	local enabled = props.enabled or true
	local unstable_outsidePress = props.outsidePress

	local insideReactTreeRef = React.useRef(false)

	--[[local outsidePress = useEffectEvent(unstable_outsidePress or function()
		return false
	end)

	local closeOnGamepadBackButtonPressed = useEffectEvent(function(input: InputObject)
		if not isGamepadInput(input) then
			return
		end
	end)

	local closeOnPressOutside = useEffectEvent(function(input: InputObject)
		local insideReactTree = insideReactTreeRef.current
		insideReactTreeRef.current = false

		if insideReactTree then
			return
		end

		if type(outsidePress) == "function" and not outsidePress(input) then
			return
		end
	end)]]
	--

	return React.useMemo(function()
		if not enabled then
			return {}
		end

		return {}
	end, { enabled })
end

return useDismiss
