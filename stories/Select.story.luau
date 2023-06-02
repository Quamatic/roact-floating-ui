local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.React)
local ReactRoblox = require(ReplicatedStorage.ReactRoblox)
local FloatingUI = require(ReplicatedStorage.FloatingUI)

local merge = require(ReplicatedStorage.FloatingUI.utils.merge)

local e = React.createElement

local SelectContext = React.createContext({})

type SelectProps = {
	target: Frame,
	value: string?,
	onChange: (value: string) -> ()?,
	children: React.ReactNode,
}

local function Select(props: SelectProps)
	local controlledValue = props.value
	local onChange = props.onChange or function() end

	local isOpen, setIsOpen = React.useState(false)
	local activeIndex, setActiveIndex = React.useState(nil :: number?)
	local selectedIndex, setSelectedIndex = React.useState(nil :: number?)
	local uncontrolledValue, setUncontrolledValue = React.useState("")

	local selectedValue = controlledValue or uncontrolledValue
	local setSelectedValue = React.useCallback(function(value: string, index: number)
		ReactRoblox.unstable_batchedUpdates(function()
			setSelectedIndex(index)
			setUncontrolledValue(value)
			onChange(value)
			setIsOpen(false)
		end)
	end, { onChange })

	local floating = FloatingUI.useFloating({
		placement = "bottom",
		open = isOpen,
		onOpenChange = setIsOpen,
		whileElementsMounted = FloatingUI.autoUpdate :: any,
		middleware = {
			FloatingUI.offset(10),
			FloatingUI.flip({}),
			FloatingUI.size({
				apply = function(data)
					local elements = data.elements
					local reference, floating = elements.reference, elements.floating

					floating.Size = UDim2.new(UDim.new(0, reference.AbsoluteSize.X), floating.Size.Height)
					floating.UISizeConstraint.MaxSize = Vector2.new(data.availableWidth, data.availableHeight)
				end,
			}),
		},
	})

	local context = floating.context
	local refs = floating.refs

	local interactions = FloatingUI.useInteractions({
		FloatingUI.useClick(context, {}),
		FloatingUI.useDimiss(context, {}),
	})

	return e(React.Fragment, nil, {
		Container = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			Layout = e("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 14),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			Heading = e("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.XY,
				TextSize = 24,
				FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
				Text = "Select Color",
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = 1,
				BackgroundTransparency = 1,
			}),

			Button = e(
				"TextButton",
				merge({
					Size = UDim2.fromOffset(160, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					TextSize = 24,
					FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
					Text = "Select...",
					LayoutOrder = 2,
					ref = refs.setReference,
				}, interactions.getReferenceProps()),
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
			),
		}),

		List = e(SelectContext.Provider, {
			value = {
				activeIndex = activeIndex,
				selectedIndex = selectedIndex,
				setActiveIndex = setActiveIndex,
				setSelectedIndex = setSelectedIndex,
				selectedValue = selectedValue,
				setSelectedValue = setSelectedValue,
			},
		}, isOpen and ReactRoblox.createPortal(
			e(
				"Frame",
				merge({
					Size = UDim2.fromOffset(0, 200),
					ref = refs.setFloating,
				}, floating.floatingStyles, interactions.getFloatingProps()),
				{
					UISizeConstraint = e("UISizeConstraint"),

					BorderRadius = e("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),

					Children = e(React.Fragment, nil, props.children),
				}
			),
			props.target
		)),
	})
end

local function Option(props: { children: React.ReactNode, value: string }) end

local function App(props: { target: Frame })
	return e(Select, { target = props.target }, {
		e(Option, { value = "Red" }),
		e(Option, { value = "Orange" }),
		e(Option, { value = "Yellow" }),
		e(Option, { value = "Green" }),
		e(Option, { value = "Blue" }),
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
