local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)
local Object = LuauPolyfill.Object

local types = require(script.Parent.Parent.types)
type Rect = types.Rect

--- Converts a GuiObject's rect into a HTML-like rect
local function rectToClientRect(rect: Rect)
	return Object.assign({}, rect, {
		top = rect.y,
		left = rect.x,
		right = rect.x + rect.width,
		bottom = rect.y + rect.height,
	})
end

return rectToClientRect
