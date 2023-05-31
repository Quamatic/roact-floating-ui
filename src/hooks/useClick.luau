local React = require(script.Parent.Parent.Parent.React)

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

type UseClickProps = {
	enabled: boolean?,
	toggle: boolean?,
}

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
				[React.Event.InputBegan] = function(input: InputObject)
					if
						input.UserInputType ~= Enum.UserInputType.MouseButton1
						or input.UserInputType ~= Enum.UserInputType.Touch
					then
						return
					end

					if open then
						if toggle then
							onOpenChange(false)
						end
					else
						onOpenChange(true)
					end
				end,
			},
		}
	end, { enabled, open, onOpenChange, toggle })
end

return useClick
