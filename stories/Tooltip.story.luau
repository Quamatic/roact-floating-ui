local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.React)
local ReactRoblox = require(ReplicatedStorage.ReactRoblox)
local FloatingUI = require(ReplicatedStorage.FloatingUI)

local merge = require(ReplicatedStorage.FloatingUI.utils.merge)

local e = React.createElement

local TOOLTIP_PLACEMENT = "bottom"
local TOOLTIP_LABEL = "Tooltip"
local TOOLTIP_DELAY = 0

type TooltipProps = {
	target: Frame,
	children: React.ReactNode,
}

local function Tooltip(props: TooltipProps)
	local _delayGroupContext = FloatingUI.useDelayGroupContext()
	local groupDelay = _delayGroupContext.delay

	local open, setOpen = React.useState(false)
	local id = FloatingUI.useId()

	local floating = FloatingUI.useFloating({
		placement = TOOLTIP_PLACEMENT,
		open = open,
		onOpenChange = setOpen,
		middleware = { FloatingUI.offset(5), FloatingUI.flip({}), FloatingUI.shift({}) },
		whileElementsMounted = FloatingUI.autoUpdate :: any,
	})

	local context = floating.context

	local interactions = FloatingUI.useInteractions({
		FloatingUI.useHover(context, {
			delay = if groupDelay == 0 then TOOLTIP_DELAY else groupDelay,
			move = false,
		}),
		FloatingUI.useDimiss(context, {}),
	})

	FloatingUI.useDelayGroup(context, { id = id })

	local children = props.children

	return e(React.Fragment, nil, {
		Trigger = React.isValidElement(children) and React.cloneElement(
			children,
			interactions.getReferenceProps({
				ref = floating.refs.setReference,
			})
		),
		Tooltip = open and ReactRoblox.createPortal(
			e(
				"Frame",
				merge(floating.floatingStyles, {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					ref = floating.refs.setFloating,
				}),
				e(
					"TextLabel",
					merge({
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						TextColor3 = Color3.fromRGB(255, 255, 255),
						Text = TOOLTIP_LABEL,
						TextSize = 18,
						FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
						ref = floating.refs.setFloating,
					}, interactions.getFloatingProps()),
					{
						BorderRadius = e("UICorner", {
							CornerRadius = UDim.new(0, 8),
						}),

						Padding = e("UIPadding", {
							PaddingLeft = UDim.new(0, 12),
							PaddingRight = UDim.new(0, 12),
							PaddingTop = UDim.new(0, 8),
							PaddingBottom = UDim.new(0, 8),
						}),
					}
				)
			),
			props.target
		),
	})
end

local function App(props: { target: Frame })
	return e(
		Tooltip,
		{ target = props.target },
		e("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(200, 50),
			Text = "Hover me!",
			FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
			TextSize = 30,
		}, {
			BorderRadius = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		})
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
