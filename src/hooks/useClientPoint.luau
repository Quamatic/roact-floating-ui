local UserInputService = game:GetService("UserInputService")

local src = script.Parent.Parent.Parent
local React = require(src.React)

local useEffectEvent = require(script.Parent.utils.useEffectEvent)
local getBoundingClientRect = require(script.Parent.Parent.utils.getAlignment)

local types = require(script.Parent.Parent.types)
type VirtualElement = types.VirtualElement
type Element = types.Element
type FloatingContext<RT> = types.FloatingContext<RT>
type MutableRefObject<T> = { current: T }

local dummyRect = {
	width = 0,
	height = 0,
	x = 0,
	y = 0,
}

local function createVirtualElement(
	rbxRef: MutableRefObject<Element?>,
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
	axis: "x" | "y" | "both"?,
	x: number?,
	y: number?,
}

local function useClientPoint<RT>(context: FloatingContext<RT>, props: UseClientPointProps)
	local open = context.open
	local refs = context.refs
	local floating = context.elements.floating
	local enabled = props.enabled or true
	local axis = props.axis or "both"
	local x = props.x
	local y = props.y

	local initialRef = React.useRef(false)

	local setReference = useEffectEvent(function(x: number | nil, y: number | nil)
		if initialRef.current then
			return
		end

		refs.setPositionReference(createVirtualElement(refs.reference, {
			x = x,
			y = y,
			axis = axis,
		}))
	end)

	local addListener = React.useCallback(function()
		if not enabled or x ~= nil or y ~= nil then
			return
		end

		local function handleMouseMove(input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end

			refs.setPositionReference(refs.reference.current)
		end

		local connection = UserInputService.InputBegan:Connect(handleMouseMove)
		return function()
			connection:Disconnect()
		end
	end, { enabled, refs, setReference, x, y })

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

	React.useEffect(function()
		return addListener()
	end, { addListener })

	React.useEffect(function()
		if enabled and not floating then
			initialRef.current = false
		end
	end, { enabled, floating })

	React.useEffect(function()
		if not enabled and open then
			initialRef.current = true
		end
	end, { enabled, open })

	React.useLayoutEffect(function()
		if enabled and (x ~= nil or y ~= nil) then
			initialRef.current = false
			setReference(x, y)
		end
	end, { enabled, x, y, setReference })

	return React.useMemo(function()
		if not enabled then
			return {}
		end

		return {
			reference = {
				[React.Event.InputBegan] = handleReferenceEnterOrMove,
				[React.Event.InputChanged] = handleReferenceEnterOrMove,
			},
		}
	end, { enabled })
end

return useClientPoint
