local isElement = require(script.Parent.isElement)

local FALLBACK_SCALE = 1

local function getElementScaleFromAncestors(element: GuiObject)
	local current = element

	while current ~= nil and current:IsA("GuiObject") do
		local scale = current:FindFirstChildWhichIsA("UIScale")
		if scale ~= nil then
			return scale
		end

		current = current.Parent
	end

	return nil
end

--- Returns the scale that an element should receive. The scale is found by traversing through the floating element's ancestors.
--- This fixes a bug where the floating element miscalculates its position because UIScale does not actually change AbsoluteSize.
local function getScale(element)
	-- Check if it's not a virtual element first...
	if not isElement(element) then
		return FALLBACK_SCALE
	end

	local scale = getElementScaleFromAncestors(element)
	return if scale ~= nil then scale else FALLBACK_SCALE
end

return getScale
