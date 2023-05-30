local Array = require(script.Parent.Parent.Parent.Collections).Array

local function getClientRectFromClippingAncestor() end

local function getClippingElementAncestors(element, cache)
	local cachedResult = cache:get(element)
	if cachedResult then
		return cachedResult
	end
end

local function getClippingRect(options)
	local boundary = options.boundary

	local elementClippingAncestors = if boundary == "clippingAncestors"
		then getClippingElementAncestors()
		else Array.concat({}, boundary)

	local clippingAncestors = Array.concat({ options.rootBoundary }, elementClippingAncestors)
	local firstClippingAncestor = clippingAncestors[1]

	local clippingRect = Array.reduce(clippingAncestors, function(accRect, clippingAncestory)
		local rect = getClientRectFromClippingAncestor()
	end, getClientRectFromClippingAncestor())

	return {
		size = UDim2.fromOffset(0, 0),
		position = clippingRect.position,
	}
end

return getClippingRect
