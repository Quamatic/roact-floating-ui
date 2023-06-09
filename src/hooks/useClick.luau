local React = require(script.Parent.Parent.Parent.React)

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

type UseClickProps = {
	enabled: boolean?,
	toggle: boolean?,
}

--[=[
	@within Hooks
]=]
local function useClick<RT>(context: FloatingContext<RT>, props: UseClickProps)
	props = props or {} :: UseClickProps

	local open = context.open
	local onOpenChange = context.onOpenChange

	local enabled = props.enabled or true
	local toggle = props.toggle or true

	local _pointerTypeRef = React.useRef(nil :: ("mouse" | "touch")?)

	return React.useMemo(function()
		if not enabled then
			return {}
		end

		return {
			reference = {
				[React.Event.InputBegan] = function(_rbx: Instance, input: InputObject)
					if
						input.UserInputType ~= Enum.UserInputType.MouseButton1
						and input.UserInputType ~= Enum.UserInputType.Touch
					then
						return
					end

					onOpenChange(if open then false else true)
				end,
			},
		}
	end, { enabled, open, onOpenChange, toggle })
end

return useClick
