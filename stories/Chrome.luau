local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.React)

local e = React.createElement

local function Dot(props)
	return e("Frame", {
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = props.color,
		LayoutOrder = props.order,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
end

local function Chrome(props)
	return e("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Color3.fromHex("#334155"),
	}, {
		Corner = e("UICorner"),

		Layout = e("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 25),
		}),

		Padding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 28),
			PaddingRight = UDim.new(0, 28),
			PaddingTop = UDim.new(0, 28),
			PaddingBottom = UDim.new(0, 28),
		}),

		Header = e("Frame", {
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}, {
			Layout = e("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),

			Title = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				Text = props.title,
				TextColor3 = Color3.fromHex("#ffffff"),
				TextSize = 36,
				FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}),

			Description = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				Text = props.description,
				TextColor3 = Color3.fromHex("#ffffff"),
				TextSize = 24,
				FontFace = Font.fromEnum(Enum.Font.SourceSans),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}),
		}),

		Chrome = e("Frame", {
			Size = UDim2.fromOffset(540, 0),
			BackgroundColor3 = Color3.fromHex("#ffffff"),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 3,
		}, {
			Layout = e("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Corner = e("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),

			Header = e("Frame", {
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
				BackgroundColor3 = Color3.fromHex("#4b5563"),
				BorderSizePixel = 0,
				LayoutOrder = 1,
			}, {
				Dots = e("Frame", {
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, 46),
					Position = UDim2.fromOffset(16, 0),
					BackgroundTransparency = 1,
				}, {
					Layout = e("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 8),
					}),

					Close = e(Dot, { color = Color3.fromHex("#ec695e"), order = 1 }),
					Minimize = e(Dot, { color = Color3.fromHex("#f4bf4f"), order = 2 }),
					Fullscreen = e(Dot, { color = Color3.fromHex("#61c653"), order = 3 }),
				}),

				Label = e("TextLabel", {
					Size = UDim2.new(1, 0, 0, 46),
					FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
					TextSize = 20,
					TextColor3 = Color3.fromHex("#ffffff"),
					Text = props.label,
					BackgroundTransparency = 1,
				}),
			}),

			Content = e("Frame", {
				Size = UDim2.new(1, 0, 0, 300),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
			}, {
				--[[Padding = e("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 8),
					PaddingBottom = UDim.new(0, 8),
				}),]]
				--

				Children = e(React.Fragment, nil, props.children),
			}),
		}),
	})
end

return Chrome
