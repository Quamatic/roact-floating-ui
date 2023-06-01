local UserInputService = game:GetService("UserInputService")

local React = require(script.Parent.Parent.Parent.React)

local types = require(script.Parent.Parent.types)
type FloatingContext<RT> = types.FloatingContext<RT>

local useEffectEvent = require(script.Parent.utils.useEffectEvent)

local function createVirtualElement(rbxRef: { current: GuiObject? }, data)
	local offsetX: number?
	local offsetY: number?

	return {
		contextElement = rbxRef,
		getBoundingClientRect = function()
			local isXAxis = data.axis == "X" or data.axis == "both"
			local isYAxis = data.axis == "Y" or data.axis == "both"

			local size = if rbxRef.current then rbxRef.current.AbsoluteSize else Vector2.zero
			local position = if rbxRef.current then rbxRef.current.AbsolutePosition else Vector2.zero

			local width = size.X
			local height = size.Y
			local x = position.X
			local y = position.Y

			if offsetX == nil and data.x and isXAxis then
				offsetX = x - data.x
			end

			if offsetY == nil and data.y and isYAxis then
				offsetY = y - data.y
			end

			x -= offsetX or 0
			y -= offsetY or 0
			width = 0
			height = 0

			return {
				AbsoluteSize = Vector2.new(width, height),
				AbsolutePosition = Vector2.new(x + width, y + height),
			}
		end,
	}
end

type UseClientPointProps = {
	enabled: boolean?,
	axis: "X" | "Y" | "both"?,
	x: number?,
	y: number?,
}

local function useClientPoint<RT>(context: FloatingContext<RT>, props: UseClientPointProps)
	local open = context.open
	local refs = context.refs
	local enabled = props.enabled or true
	local axis = props.axis or "both"

	local addListener = React.useCallback(function()
		local function handleMouseMove(input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end
		end

		local connection = UserInputService.InputBegan:Connect(handleMouseMove)
		return function()
			connection:Disconnect()
		end
	end, {})

	local setReference = useEffectEvent(function(position: Vector2)
		refs.setPositionReference(createVirtualElement(refs.reference, props))
	end)

	local handleReferenceEnterOrMove = useEffectEvent(function(_rbx: GuiObject, input: InputObject)
		if
			input.UserInputType ~= Enum.UserInputType.MouseMovement
			or input.UserInputState ~= Enum.UserInputState.Change
		then
			return
		end

		if not open then
			setReference(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)

	return React.useMemo(function()
		return {
			reference = {
				[React.Event.InputBegan] = handleReferenceEnterOrMove,
				[React.Event.InputChanged] = handleReferenceEnterOrMove,
			},
		}
	end, { enabled })
end

return useClientPoint
