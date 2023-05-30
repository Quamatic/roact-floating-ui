local types = require(script.Parent.Parent.Parent.types)
type Axis = types.Axis

local function getLengthFromAxis(axis: Axis): Axis
	return if axis == "x" then "y" else "x"
end

return getLengthFromAxis
