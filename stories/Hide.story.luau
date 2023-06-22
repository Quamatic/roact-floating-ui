local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.React)
local ReactRoblox = require(ReplicatedStorage.ReactRoblox)
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

local FloatingElement = React.forwardRef(function(props, ref)
	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(125, 0),
		BackgroundColor3 = if props.escaped then Color3.fromRGB(224, 12, 12) else Color3.fromRGB(39, 41, 53),
		Position = props.position,
		ZIndex = 10,
		Visible = props.visible,
		ref = ref,
	}, {
		UICorner = e("UICorner"),

		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),

		Header = e("TextLabel", {
			AutomaticSize = Enum.AutomaticSize.XY,
			FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
			TextSize = 24,
			TextColor3 = Color3.fromHex("#ffffff"),
			Text = "Tooltip",
			BackgroundTransparency = 1,
		}),
	})
end)

local function App(props: { target: Frame })
	local boundary, setBoundary = React.useState(nil)

	local floating = FloatingUI.useFloating({
		placement = "bottom",
		middleware = {
			FloatingUI.offset(5),
			FloatingUI.hide(),
			FloatingUI.hide({ strategy = "escaped" }),
		},
		whileElementsMounted = FloatingUI.autoUpdate :: any,
	})

	local hide = floating.middlewareData.hide or {}
	local escaped = hide.escaped or false
	local referenceHidden = hide.referenceHidden or false
	local refs = floating.refs

	local visible = (function()
		if referenceHidden then
			return false
		end

		if not floating.isPositioned then
			return false
		end

		return true
	end)()

	return e(Chrome, {
		title = "Hide",
		description = "Hides the floating element when the reference escapes.",
		label = "Scroll up/down",
	}, {
		Container = e("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			ScrollBarImageColor3 = Color3.fromRGB(140, 140, 140),
			BackgroundTransparency = 1,
			ref = setBoundary,
		}, {
			Reference = e(Reference, {
				ref = refs.setReference,
			}),

			Floater = ReactRoblox.createPortal(
				e(FloatingElement, {
					position = floating.floatingStyles.Position,
					ref = refs.setFloating,
					escaped = escaped,
					visible = visible,
				}),
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
