local React = require(script.Parent.Parent.Parent.React)

local e = React.createElement

type FloatingArrowProps = {
	size: UDim2,
	context: any,
	color: Color3,
	image: string?,
}

local ROTATION = {
	top = 180,
	left = 90,
	bottom = 0,
	right = -90,
}

local ANCHOR_POINTS = {
	["left"] = {
		position = UDim2.fromScale(1, 0),
		origin = Vector2.new(1, 0),
	},
	["right"] = {
		origin = Vector2.new(0, 0),
		position = UDim2.fromScale(0, 0),
	},
	["top"] = {
		origin = Vector2.new(0, 1),
		position = UDim2.fromScale(0, 1),
	},
	["bottom"] = {
		origin = Vector2.zero,
		position = UDim2.fromScale(0, 0),
	},
}

--[=[
	@within Components
]=]
local FloatingArrow = React.forwardRef(function(props: FloatingArrowProps, ref)
	local placement = props.context.placement
	local arrow = props.context.middlewareData.arrow or {}

	local side, alignment = unpack(string.split(placement, "-"))
	local isVerticalSide = side == "top" or side == "bottom"

	local arrowX = arrow.x or 0
	local arrowY = arrow.y or 0

	if side == "top" then
		arrowY += 8
	elseif side == "bottom" then
		arrowY -= 8
	elseif side == "left" then
		arrowX += 8
	else
		arrowX -= 12
	end

	local anchor = ANCHOR_POINTS[side]

	return e("ImageLabel", {
		AnchorPoint = anchor.origin,
		Size = props.size,
		Position = anchor.position + UDim2.fromOffset(arrowX, arrowY),
		BackgroundTransparency = 1,
		ImageColor3 = props.color,
		Image = props.image,
		Rotation = ROTATION[side],
		ref = ref,
	})
end)

return FloatingArrow
