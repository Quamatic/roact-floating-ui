local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)
local Array = LuauPolyfill.Array

local isElement = require(script.Parent.isElement)

local FALLBACK_SCALE = 1

local function getElementScaleFromAncestors(element: GuiObject)
	-- We need to gather all possible element scales, as only trying to get the first
	-- scale can still end up in miscalculations if there is multiple upstream.
	local scales: { number } = {}
	local current = element

	-- TODO: better search
	while current ~= nil and current:IsA("GuiObject") do
		local scale = current:FindFirstChildWhichIsA("UIScale")
		if scale ~= nil then
			table.insert(scales, scale.Scale)
		end

		current = current.Parent
	end

	return Array.reduce(scales, function(acc, scale)
		return acc * scale
	end, FALLBACK_SCALE)
end

--- Returns the scale that an element should receive. The scale is found by traversing through the floating element's ancestors.
--- This fixes a bug where the floating element miscalculates its position because UIScale does not actually change AbsoluteSize.
local function getScale(element)
	-- Check if it's not a virtual element first...
	if not isElement(element) then
		return FALLBACK_SCALE
	end

	local scale = getElementScaleFromAncestors(element)
	return 1 / scale
end

return getScale
