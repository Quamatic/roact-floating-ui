local function getCrossAxis(axis)
	return if axis == "x" then "y" else "x"
end

return getCrossAxis
