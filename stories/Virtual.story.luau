local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.React)
local ReactRoblox = require(ReplicatedStorage.ReactRoblox)
local ReactSpring = require(ReplicatedStorage.ReactSpring)
local FloatingUI = require(ReplicatedStorage.FloatingUI)

local Chrome = require(script.Parent.Chrome)

local e = React.createElement

local function App(props: { target: Frame })
	local open, setOpen = React.useState(false)
	local boundary, setBoundary = React.useState(nil)

	local styles = ReactSpring.useSpring({
		scale = if open then 1 else 0,
		opacity = if open then 0 else 1,
		rotation = if open then 0 else -270,
		config = ReactSpring.config.wobbly,
	})

	local floating = FloatingUI.useFloating({
		placement = "top",
		middleware = {
			FloatingUI.offset(5),
			FloatingUI.shift({
				crossAxis = true,
				padding = 5,
				boundary = boundary,
			}),
		},
	})

	local refs = floating.refs

	local handleMouseMove = React.useCallback(function(input: InputObject)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local position = input.Position

		local x = position.X
		local y = position.Y

		refs.setReference({
			getBoundingClientRect = function()
				return {
					width = 0,
					height = 0,
					x = x,
					y = y,
					left = x,
					top = y,
					right = x,
					bottom = y,
				}
			end,
		})
	end, { refs })

	return e(Chrome, {
		title = "Virtual",
		description = "Anchor relative to any coordinates, such as your mouse cursor.",
		label = "Move your mouse",
	}, {
		Container = e("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			ScrollBarImageColor3 = Color3.fromRGB(140, 140, 140),
			BackgroundTransparency = 1,
			ref = setBoundary,
			CanvasSize = UDim2.fromScale(0, 0),
			[React.Event.InputBegan] = function(_rbx, input)
				handleMouseMove(input)
				setOpen(true)
			end,
			[React.Event.InputChanged] = function(_rbx, input)
				handleMouseMove(input)
			end,
			[React.Event.MouseLeave] = function()
				setOpen(false)
			end,
		}, {
			Tooltip = e(
				"Frame",
				{
					Position = UDim2.fromOffset(floating.x, floating.y),
					Size = UDim2.fromOffset(125, 45),
					BackgroundTransparency = 1,
					ref = refs.setFloating,
				},
				e("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = styles.opacity,
					TextTransparency = styles.opacity,
					Rotation = styles.rotation,
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

					UIScale = e("UIScale", {
						Scale = styles.scale,
					}),
				})
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
