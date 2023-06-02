local UserInputService = game:GetService("UserInputService")

local React = require(script.Parent.Parent.Parent.React)

local useEffectEvent = require(script.Parent.utils.useEffectEvent)
local getBoundingClientRect = require(script.Parent.Parent.utils.getAlignment)

local types = require(script.Parent.Parent.types)
type VirtualElement = types.VirtualElement
type Element = types.Element
type FloatingContext<RT> = types.FloatingContext<RT>

local dummyRect = {
	width = 0,
	height = 0,
	x = 0,
	y = 0,
}

local function createVirtualElement(
	rbxRef: React.ElementRef<{ current: Element? }>,
	data: {
		x: number,
		y: number,
		axis: "x" | "y" | "both",
	}
): VirtualElement
	local offsetX: number?
	local offsetY: number?

	return {
		contextElement = rbxRef.current,
		getBoundingClientRect = function()
			local rbxRect = (rbxRef.current and getBoundingClientRect(rbxRef.current)) or dummyRect

			local isXAxis = data.axis == "x" or data.axis == "both"
			local isYAxis = data.axis == "y" or data.axis == "both"

			local width = rbxRect.width
			local height = rbxRect.height
			local x = rbxRect.x
			local y = rbxRect.y

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
				width = width,
				height = height,
				x = x,
				y = y,
				top = y,
				right = x + width,
				bottom = y + height,
				left = x,
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

	local setReference = useEffectEvent(function(x: number | nil, y: number | nil)
		refs.setPositionReference(createVirtualElement(refs.reference, {
			x = x,
			y = y,
			axis = axis,
		}))
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
