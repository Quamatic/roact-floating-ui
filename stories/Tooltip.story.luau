local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.React)
local ReactRoblox = require(ReplicatedStorage.ReactRoblox)
local ReactFloating = require(ReplicatedStorage.ReactFloating)
local Object = require(ReplicatedStorage.LuauPolyfill).Object

local e = React.createElement

local function Tooltip(props)
	local groupDelayContext = ReactFloating.useDelayGroupContext()
	local groupDelay = groupDelayContext.delay
	local open, setOpen = React.useState(false)

	local floating = ReactFloating.useFloating({
		placement = "bottom",
		open = open,
		onOpenChange = setOpen,
		middleware = { ReactFloating.offset(10), ReactFloating.flip(), ReactFloating.shift({ padding = 8 }) },
		whileElementsMounted = ReactFloating.autoUpdate :: any,
	})

	local refs = floating.refs
	local context = floating.context
	local floatingStyles = floating.floatingStyles

	local interactions = ReactFloating.useInteractions({
		ReactFloating.useHover(context, {
			delay = if groupDelay == 0 then props.delay else groupDelay,
		}),
		ReactFloating.useFocus(context),
		ReactFloating.useDismiss(context, {}),
	})

	ReactFloating.useDelayGroup(context, { id = "" })

	local getReferenceProps, getFloatingProps = interactions.getReferenceProps, interactions.getFloatingProps
	local children = props.children

	return e(
		React.Fragment,
		nil,
		React.isValidElement(children) and React.cloneElement(children, getReferenceProps({ ref = refs.setReference })),
		open
			and ReactRoblox.createPortal(
				e(
					"TextLabel",
					Object.assign({}, floatingStyles, {
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundColor3 = Color3.new(),
						TextColor3 = Color3.fromHex("#ffffff"),
						Text = props.label,
						TextSize = 12,
						ref = refs.setFloating,
					}),
					e("UIPadding", {
						PaddingLeft = UDim.new(0, 8),
						PaddingRight = UDim.new(0, 8),
						PaddingTop = UDim.new(0, 4),
						PaddingBottom = UDim.new(0, 4),
					}),
					e("UICorner")
				),
				props.target
			)
	)
end

local Button = React.forwardRef(function(props, ref)
	return e(
		"TextButton",
		Object.assign({}, props, {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromHex("#e2e8f0"),
			BackgroundTransparency = 0.1,
			Text = "My button",
			TextSize = 12,
			ref = ref,
		}),
		e("UICorner"),
		e("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		})
	)
end)

local function App(props: { target: Frame })
	return e(
		"Frame",
		{ Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 },
		e("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 16),
		}),
		e(Tooltip, { label = "My tooltip", target = props.target }, e(Button)),
		e(
			"Frame",
			{
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
			},
			e("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
			}),
			e(
				ReactFloating.FloatingDelayGroup,
				{
					delay = { open = 500, close = 200 },
				},
				e(Tooltip, { label = "My toolip", target = props.target }, e(Button)),
				e(Tooltip, { label = "My tooltip 2", target = props.target }, e(Button)),
				e(Tooltip, { label = "My tooltip 3", target = props.target }, e(Button))
			)
		)
	)
end

return function(target: Frame)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))

	root:render(ReactRoblox.createPortal({
		App = e(App, {
			target = target,
		}),
	}, target))

	return function()
		root:unmount()
	end
end
