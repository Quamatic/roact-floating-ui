local merge = require(script.Parent.merge)

local types = require(script.Parent.Parent.types)
type Rect = types.Rect

--- Converts a GuiObject's rect into a HTML-like rect
local function rectToClientRect(rect: Rect)
	return merge(rect, {
		top = rect.y,
		left = rect.x,
		right = rect.x + rect.width,
		bottom = rect.y + rect.height,
	})
end

return rectToClientRect
