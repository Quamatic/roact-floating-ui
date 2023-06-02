local getSide = require(script.Parent.getSide)

local function getMainAxisFromPlacement(placement)
	return if table.find({ "top", "bottom" }, getSide(placement)) ~= nil then "x" else "y"
end

return getMainAxisFromPlacement
