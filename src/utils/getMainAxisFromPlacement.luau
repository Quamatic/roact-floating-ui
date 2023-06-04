local Array = require(script.Parent.Parent.Parent.Collections).Array

local getSide = require(script.Parent.getSide)

local function getMainAxisFromPlacement(placement)
	return if Array.includes({ "top", "bottom" }, getSide(placement)) then "x" else "y"
end

return getMainAxisFromPlacement
