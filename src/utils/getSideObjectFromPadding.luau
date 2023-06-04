local Object = require(script.Parent.Parent.Parent.Collections).Object

local types = require(script.Parent.Parent.types)
type Padding = types.Padding
type SideObject = types.SideObject

local function expandPaddingObject(padding: SideObject)
	return Object.assign({
		top = 0,
		left = 0,
		right = 0,
		bottom = 0,
	}, padding)
end

local function getSideObjectFromPadding(padding: Padding): SideObject
	if type(padding) ~= "number" then
		return expandPaddingObject(padding)
	end

	return {
		top = padding,
		left = padding,
		right = padding,
		bottom = padding,
	}
end

return getSideObjectFromPadding
