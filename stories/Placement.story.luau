local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.React)
local ReactRoblox = require(ReplicatedStorage.ReactRoblox)
local ReactSpring = require(ReplicatedStorage.ReactSpring)
local FloatingUI = require(ReplicatedStorage.FloatingUI)
local Array = require(ReplicatedStorage.Collections).Array

local Chrome = require(script.Parent.Chrome)

local e = React.createElement

local placements = {
	{
		placement = "top",
		position = UDim2.new(0.5, 0, 0, 15),
		origin = Vector2.new(0.5, 0),
	},
	{
		placement = "top-start",
		position = UDim2.new(0.5, -70, 0, 15),
		origin = Vector2.new(0.5, 0),
	},
	{
		placement = "top-end",
		position = UDim2.new(0.5, 70, 0, 15),
		origin = Vector2.new(0.5, 0),
	},
	{
		placement = "bottom",
		position = UDim2.new(0.5, 0, 1, -15),
		origin = Vector2.new(0.5, 1),
	},
	{
		placement = "bottom-start",
		position = UDim2.new(0.5, -70, 1, -15),
		origin = Vector2.new(0.5, 1),
	},
	{
		placement = "bottom-end",
		position = UDim2.new(0.5, 70, 1, -15),
		origin = Vector2.new(0.5, 1),
	},
	{
		placement = "left",
		position = UDim2.new(0, 25, 0.5, 0),
		origin = Vector2.new(0, 0.5),
	},
	{
		placement = "left-start",
		position = UDim2.new(0, 25, 0.5, -70),
		origin = Vector2.new(0, 0.5),
	},
	{
		placement = "left-end",
		position = UDim2.new(0, 25, 0.5, 70),
		origin = Vector2.new(0, 0.5),
	},
	{
		placement = "right",
		position = UDim2.new(1, -25, 0.5, 0),
		origin = Vector2.new(1, 0.5),
	},
	{
		placement = "right-start",
		position = UDim2.new(1, -25, 0.5, -70),
		origin = Vector2.new(1, 0.5),
	},
	{
		placement = "right-end",
		position = UDim2.new(1, -25, 0.5, 70),
		origin = Vector2.new(1, 0.5),
	},
}

local function PlacementButton(props)
	local hovered, setHovered = React.useState(false)
	local styles = ReactSpring.useSpring({
		scale = if hovered then 1.25 else 1,
		config = { tension = 500, damping = 0.5 },
	})

	local selected = props.selected == props.placement

	return e("ImageButton", {
		AnchorPoint = props.origin,
		Position = props.position,
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = if selected then Color3.fromHex("#030712") else Color3.fromHex("#ffffff"),
		[React.Event.Activated] = props.onClick,
		[React.Event.MouseEnter] = function()
			setHovered(true)
		end,
		[React.Event.MouseLeave] = function()
			setHovered(false)
		end,
	}, {
		UIScale = e("UIScale", {
			Scale = styles.scale,
		}),

		UICorner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),

		UIStroke = e("UIStroke", {
			Color = Color3.fromHex("#030712"),
			Thickness = 1,
		}),
	})
end

local Reference = React.forwardRef(function(props, ref)
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(96, 96),
		BackgroundTransparency = 1,
		ref = ref,
	}, {
		UIStroke = e("UIStroke", {
			Color = Color3.fromHex("#030712"),
			Thickness = 1,
		}),
	})
end)

local function App(props: { target: Frame })
	local placement, setPlacement = React.useState("top")

	local floating = FloatingUI.useFloating({
		placement = placement,
		middleware = {
			FloatingUI.offset(5),
		},
		whileElementsMounted = FloatingUI.autoUpdate :: any,
	})

	local refs = floating.refs

	return e(Chrome, {
		title = "Placement",
		description = "Places your floating element relative to another element.",
		label = "Click the dots",
	}, {
		Placements = e(
			React.Fragment,
			nil,
			Array.map(placements, function(p)
				return e(PlacementButton, {
					key = p.placement,
					selected = placement,
					placement = p.placement,
					position = p.position,
					origin = p.origin,
					onClick = function()
						setPlacement(p.placement)
					end,
				})
			end)
		),

		Reference = e(Reference, {
			ref = refs.setReference,
		}),

		Floater = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			Position = floating.floatingStyles.Position,
			Text = placement,
			FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
			BackgroundColor3 = Color3.fromHex("#030712"),
			TextColor3 = Color3.fromHex("#ffffff"),
			TextSize = 20,
			ZIndex = 10,
			ref = refs.setFloating,
		}, {
			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),

			Padding = e("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
			}),
		}),
	})
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
