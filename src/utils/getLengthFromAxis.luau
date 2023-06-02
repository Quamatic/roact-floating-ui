local function getLengthFromAxis(axis: string)
	return if axis == "y" then "height" else "width"
end

return getLengthFromAxis
