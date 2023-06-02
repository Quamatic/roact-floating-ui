local function getLayerElement(element: GuiObject)
	return element:FindFirstAncestorWhichIsA("LayerCollector")
end

return getLayerElement
