local function isElement(value: any)
	return typeof(value) == "Instance" and value:IsA("GuiObject")
end

return isElement
