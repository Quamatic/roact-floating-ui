local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.React)
local ReactRoblox = require(ReplicatedStorage.ReactRoblox)
local ReactSpring = require(ReplicatedStorage.ReactSpring)
local FloatingUI = require(ReplicatedStorage.ReactFloating)

local Chrome = require(script.Parent.Chrome)

local e = React.createElement

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
	local boundary, setBoundary = React.useState(nil)
	local arrowRef = React.useRef(nil)

	local floating = FloatingUI.useFloating({
		placement = "right",
		middleware = {
			FloatingUI.offset(16),
			FloatingUI.shift({
				padding = 5,
				boundary = boundary,
			}),
			FloatingUI.arrow({
				element = arrowRef,
				padding = 5,
			}),
		},
		whileElementsMounted = FloatingUI.autoUpdate :: any,
	})

	local centerOffset = (floating.middlewareData.arrow or {}).centerOffset

	local styles = ReactSpring.useSpring({
		size = if centerOffset ~= 0 then UDim2.fromOffset(0, 0) else UDim2.fromOffset(24, 24),
		config = ReactSpring.config.stiff,
	})

	local refs = floating.refs

	return e(Chrome, {
		title = "Arrow",
		description = "Dynamically positions an arrow element that is center-aware.",
		label = "Scroll the container",
	}, {
		Container = e("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			ScrollBarImageColor3 = Color3.fromRGB(140, 140, 140),
			CanvasSize = UDim2.fromScale(0, 3),
			BackgroundTransparency = 1,
			ref = setBoundary,
		}, {
			Reference = e(Reference, {
				ref = refs.setReference,
			}),

			Tooltip = ReactRoblox.createPortal(
				e(
					"Frame",
					{
						Position = floating.floatingStyles.Position,
						Size = UDim2.fromOffset(125, 290),
						BackgroundTransparency = 1,
						ZIndex = 20,
						ref = refs.setFloating,
					},
					e("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						BackgroundColor3 = Color3.fromRGB(39, 41, 53),
						TextColor3 = Color3.fromHex("#ffffff"),
						FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
						TextSize = 20,
						Text = "Tooltip Text",
						ZIndex = 999,
					}, {
						UICorner = e("UICorner", {
							CornerRadius = UDim.new(0, 8),
						}),

						Arrow = e(FloatingUI.FloatingArrow, {
							context = floating.context,
							size = styles.size,
							image = "rbxassetid://10983945016",
							color = Color3.fromRGB(39, 41, 53),
							ref = arrowRef,
						}),
					})
				),
				props.target
			),
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
