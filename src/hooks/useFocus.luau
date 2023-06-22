local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local src = script.Parent.Parent.Parent
local React = require(src.React)

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

type UseFocusProps = {
	enabled: boolean?,
}

local function isRobloxElement(x: any)
	return typeof(x) == "Instance" and x:IsA("GuiObject")
end

local function isActiveElement(element: GuiObject)
	return GuiService.SelectedObject == element
end

--[=[
	@within Hooks

	Opens the floating element while the reference is focused. This works
	with both gamepad and keyboard navigation.
]=]
local function useFocus<RT>(context: FloatingContext<RT>, props: UseFocusProps?)
	if props == nil then
		props = {} :: UseFocusProps
	end

	local open = context.open
	local onOpenChange = context.onOpenChange
	local rbxReference = context.elements.rbxReference
	local enabled = (props :: UseFocusProps).enabled or true

	local blockFocusRef = React.useRef(false)

	React.useEffect(function()
		if not enabled then
			return
		end

		local connection = UserInputService.WindowFocusReleased:Connect(function()
			-- If the reference was focused and the user left the window, and the
			-- floating element was not open, the focus should be blocked when they
			-- return to the window.
			if not open and isRobloxElement(rbxReference) and isActiveElement(rbxReference) then
				blockFocusRef.current = true
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, { open, enabled })

	return React.useMemo(function()
		return {
			reference = {
				[React.Event.SelectionGained] = function()
					if blockFocusRef.current then
						return
					end

					onOpenChange(true)
				end,
				[React.Event.SelectionLost] = function()
					blockFocusRef.current = false
					onOpenChange(false)
				end,
			},
		}
	end, { enabled, onOpenChange })
end

return useFocus
