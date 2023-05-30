local types = require(script.Parent.Parent.Parent.types)
type Placement = types.Placement
type Axis = types.Axis

local getSide = require(script.Parent.getSide)

local function getMainAxisFromPlacement(placement: Placement): Axis
	return if table.find({ "top", "bottom" }, getSide(placement)) ~= nil then "x" else "y"
end

return getMainAxisFromPlacement
