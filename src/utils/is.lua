local function isOverflowElement(element: GuiObject)
	return element.ClipsDescendants == true or element:IsA("ScrollingFrame") or element:IsA("CanvasGroup")
end

return {
	isOverflowElement = isOverflowElement,
}
