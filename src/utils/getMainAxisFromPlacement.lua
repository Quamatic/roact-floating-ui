local getSide = require(script.Parent.getSide)

local function getMainAxisFromPlacement(placement)
	return if table.find({ "top", "bottom" }, getSide(placement)) ~= nil then "X" else "Y"
end

return getMainAxisFromPlacement
