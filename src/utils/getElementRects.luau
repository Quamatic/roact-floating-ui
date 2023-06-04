local getBoundingClientRect = require(script.Parent.getBoundingClientRect)

local types = require(script.Parent.Parent.types)
type ReferenceElement = types.ReferenceElement
type FloatingElement = types.FloatingElement

local function getRectRelativeToOffsetParent(reference, offset)
	local rect = getBoundingClientRect(reference)
	local offsetRect = getBoundingClientRect(offset)

	return {
		x = rect.x - offsetRect.x,
		y = rect.y - offsetRect.y,
		width = rect.width,
		height = rect.height,
	}
end

local function getElementRects(reference: ReferenceElement, floating: FloatingElement)
	return {
		reference = getRectRelativeToOffsetParent(reference, floating.Parent),
		floating = {
			x = 0,
			y = 0,
			width = floating.AbsoluteSize.X,
			height = floating.AbsoluteSize.Y,
		},
	}
end

return getElementRects
