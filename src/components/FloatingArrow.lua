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

local FloatingArrow = React.forwardRef(function(props: FloatingArrowProps, ref)
	local placement = props.context.placement

	local side, alignment = unpack(string.split(placement, "-"))
	local isVerticalSide = side == "top" or side == "bottom"

	local yOffsetProp = "top"
	local xOffsetProp = "bottom"

	return e("ImageLabel", {
		Size = props.size,
		Position = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1,
		ImageColor3 = props.color,
		Image = props.image,
		Rotation = ROTATION[side],
		ref = ref,
	})
end)

return FloatingArrow
