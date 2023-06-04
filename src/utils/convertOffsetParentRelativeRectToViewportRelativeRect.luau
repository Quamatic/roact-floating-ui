local getBoundingClientRect = require(script.Parent.getBoundingClientRect)

--- This is used to convert relative coordinates back to their native viewport ones.
local function convertOffsetParentRelativeRectToViewportRelativeRect(rect, element)
	local elementRect = getBoundingClientRect(element)

	return {
		width = rect.width,
		height = rect.height,
		x = rect.x + elementRect.x,
		y = rect.y + elementRect.y,
	}
end

return convertOffsetParentRelativeRectToViewportRelativeRect
