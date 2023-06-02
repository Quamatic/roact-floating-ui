local function getSideObjectFromPadding(padding: number)
	return {
		top = padding,
		left = padding,
		right = padding,
		bottom = padding,
	}
end

return getSideObjectFromPadding
