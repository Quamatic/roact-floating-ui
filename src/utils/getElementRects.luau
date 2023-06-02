local types = require(script.Parent.Parent.types)
type ReferenceElement = types.ReferenceElement
type FloatingElement = types.FloatingElement

local function getBoundingClientRect(element: ReferenceElement)
	if typeof(element) == "Instance" and element:IsA("GuiObject") then
		local size: Vector2 = element.AbsoluteSize
		local position: Vector2 = element.AbsolutePosition

		return {
			x = position.X,
			y = position.Y,
			width = size.X,
			height = size.Y,
			top = position.Y,
			bottom = size.Y + position.Y,
			left = position.X,
			right = size.X + position.X,
		}
	else
		return element.getBoundingClientRect()
	end
end

local function getElementRects(reference: ReferenceElement, floating: FloatingElement)
	return {
		reference = getBoundingClientRect(reference),
		floating = {
			x = 0,
			y = 0,
			width = floating.AbsoluteSize.X,
			height = floating.AbsoluteSize.Y,
		},
	}
end

return getElementRects
