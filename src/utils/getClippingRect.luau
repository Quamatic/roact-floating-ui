local Workspace = game:GetService("Workspace")

local isElement = require(script.Parent.isElement)

local types = require(script.Parent.Parent.types)
type Element = types.Element
type Rect = types.Rect

local function getViewportRect(): Rect
	local viewport = Workspace.CurrentCamera.ViewportSize
	return {
		x = 0,
		y = 0,
		width = viewport.X,
		height = viewport.Y,
	}
end

local function getInnerBoundingClientRect(element: GuiObject): Rect
	local size = element.AbsoluteSize
	local position = element.AbsolutePosition

	return {
		width = size.X,
		height = size.Y,
		x = position.X,
		y = position.Y,
	}
end

local function getClippingElementAncestors(element: Element)
	return element.Parent
end

local function getClippingRect(options: any)
	local element = options.element
	local boundary = options.boundary
	local rootBoundary = options.rootBoundary
	local rect: Rect

	if boundary == "parent" then
		rect = getInnerBoundingClientRect(element.Parent)
	elseif rootBoundary == "viewport" then
		rect = getViewportRect()
	elseif isElement(boundary) then
		rect = getInnerBoundingClientRect(boundary)
	else
		rect = table.clone(boundary)
	end

	return rect
end

return getClippingRect
