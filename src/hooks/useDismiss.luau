local React = require(script.Parent.Parent.Parent.React)

local useEffectEvent = require(script.Parent.utils.useEffectEvent)

local useFloatingTree
local useFloatingParentId

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

type UseDismissProps = {
	enabled: boolean?,
	closeOnBackspaceAndGamepadButtonB: boolean?,
	referencePress: boolean?,
	referencePressEvent: Enum.UserInputType?,
	outsidePress: boolean | ((input: InputObject) -> ())?,
	outsidePressEvent: Enum.UserInputType?,
}

local function isGamepadInput(input: InputObject)
	return input.UserInputType.Name:find("Gamepad") ~= nil
end

local function isEscapableKey(keycode: Enum.KeyCode)
	return keycode == Enum.KeyCode.Backspace or keycode == Enum.KeyCode.B
end

local function useDismiss<RT>(context: FloatingContext<RT>, props: UseDismissProps)
	local open = context.open
	local onOpenChange = context.onOpenChange
	local events = context.events
	local elements = context.elements

	local enabled = props.enabled or true
	local escapeKey = props.closeOnBackspaceAndGamepadButtonB or true
	local outsidePress = props.outsidePress
	local unstable_outsidePress = props.outsidePress

	local insideReactTreeRef = React.useRef(false)

	local closeOnBackspaceKeyDown = useEffectEvent(function(_rbx: GuiObject, input: InputObject)
		if not open or not enabled or not escapeKey or not isEscapableKey(input.KeyCode) then
			return
		end

		events:emit("dismiss", {
			type = "escapeKey",
			data = {},
		})

		onOpenChange(false)
	end)

	local closeOnPressOutside = useEffectEvent(function(rbx: GuiObject, input: InputObject)
		local insideReactTree = insideReactTreeRef.current
		insideReactTreeRef.current = false

		if insideReactTree then
			return
		end

		if type(outsidePress) == "function" and not outsidePress(input) then
			return
		end

		events:emit("dismiss", {
			type = "outsidePress",
			data = {},
		})

		onOpenChange(false)
	end)

	return React.useMemo(function()
		if not enabled then
			return {}
		end

		return {
			reference = {
				[React.Event.InputBegan] = closeOnBackspaceKeyDown,
			},
			floating = {
				[React.Event.InputBegan] = closeOnBackspaceKeyDown,
			},
		}
	end, { enabled })
end

return useDismiss
