local React = require(script.Parent.Parent.React)
local ReactRoblox = require(script.Parent.Parent.ReactRoblox)

local FloatingArrow = require(script.Parent.components.FloatingArrow)

local useFloating = require(script.Parent.useFloating)
local offset = require(script.Parent.middleware.offset)
local arrow = require(script.Parent.middleware.arrow)
--local flip = require(script.Parent.middleware.flip)
--local shift = require(script.Parent.middleware.shift)
--local size = require(script.Parent.middleware.size)
local hide = require(script.Parent.middleware.hide)
local autoPlacement = require(script.Parent.middleware.autoPlacement)

local e = React.createElement

local function App(props)
	local arrowRef = React.useRef(nil)

	local targetRef, floatingRef, data = useFloating({
		placement = "bottom",
		middleware = {
			offset(10),
			autoPlacement({}),
			hide({}),
			arrow({ element = arrowRef.current }),
		},
	})

	local middlewareData = data.middlewareData or {}
	local hide = middlewareData.hide or {}

	return e("ScrollingFrame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(600, 400),
		CanvasSize = UDim2.fromOffset(1200, 1500),
	}, {
		Trigger = e("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(100, 100),
			ref = targetRef,
		}),

		Container = ReactRoblox.createPortal(
			e("TextLabel", {
				Size = UDim2.fromOffset(200, 35),
				Position = data._pos,
				BackgroundColor3 = Color3.fromRGB(39, 36, 36),
				TextColor3 = Color3.new(1, 1, 1),
				Text = "Amazing Tooltip Text",
				TextSize = 20,
				FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
				ZIndex = 2,
				Visible = not hide.referenceHidden,
				ref = floatingRef,
			}, {
				BorderRadius = e("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),

				Arrow = e(FloatingArrow, {
					size = UDim2.fromOffset(12, 12),
					image = "rbxassetid://10983945016",
					color = Color3.fromRGB(39, 36, 36),
					context = data,
					ref = arrowRef,
				}),
			}),
			props.target
		),
	})
end

return function(target: Frame)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))

	root:render(ReactRoblox.createPortal({
		App = e(App, { target = target }),
	}, target))

	return function()
		root:unmount()
	end
end
