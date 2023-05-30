local function getCrossAxis(axis)
	return if axis == "X" then "Y" else "X"
end

return getCrossAxis
