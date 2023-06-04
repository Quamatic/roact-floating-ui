local function getBoundingClientRect(element)
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

return getBoundingClientRect
