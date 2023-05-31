local React = require(script.Parent.Parent.React)
local ReactRoblox = require(script.Parent.Parent.ReactRoblox)
local ReactSpring = require(script.Parent.Parent.ReactSpring)

local types = require(script.Parent.types)
local merge = require(script.Parent.utils.merge)
local computePosition = require(script.Parent.computePosition)

type Placement = types.Placement
type Middleware = types.Middleware

type UseFloatingOptions = {
	open: boolean?,
	onOpenChanged: (opened: boolean) -> ()?,
	placement: Placement,
	middleware: { Middleware }?,
}

local function useFloating(options: UseFloatingOptions)
	local containerAbsoluteSize, setContainerAbsoluteSize = React.useState(Vector2.zero)
	local containerAbsolutePosition, setContainerAbsolutePosition = React.useState(Vector2.zero)

	local styles, api = ReactSpring.useSpring(function()
		return {
			position = UDim2.fromOffset(0, 0),
			config = {
				bounce = 3,
			},
		}
	end)

	local computedData, setComputedData = React.useState({
		_pos = styles.position,
		position = Vector2.zero,
		placement = options.placement,
		middlewareData = {},
	})

	local targetRef = React.useRef(nil) :: { current: GuiObject? }
	local floatingRef = React.useRef(nil) :: { current: GuiObject? }
	local isMountedRef = React.useRef(false)

	React.useLayoutEffect(function()
		if not targetRef.current or not floatingRef.current then
			return
		end

		local instance = targetRef.current

		ReactRoblox.unstable_batchedUpdates(function()
			setContainerAbsoluteSize(instance.AbsoluteSize)
			setContainerAbsolutePosition(instance.AbsolutePosition)
		end)

		local connections: { RBXScriptConnection } = {}

		table.insert(
			connections,
			instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				setContainerAbsoluteSize(instance.AbsoluteSize)
			end)
		)

		table.insert(
			connections,
			targetRef.current:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				setContainerAbsolutePosition(instance.AbsolutePosition)
			end)
		)

		return function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, { targetRef, floatingRef })

	React.useLayoutEffect(function()
		local floatingRef = floatingRef.current
		local targetRef = targetRef.current

		if not floatingRef or not targetRef then
			return
		end

		local placement = options.placement or "bottom"
		local data = computePosition(targetRef, floatingRef, {
			placement = placement,
			middleware = options.middleware,
		})

		setComputedData(merge(data, { _pos = styles.position }))

		local position = data.position
		api.start({ position = UDim2.fromOffset(position.X, position.Y) })
	end, { containerAbsoluteSize, containerAbsolutePosition })

	return targetRef, floatingRef, computedData
end

return useFloating
