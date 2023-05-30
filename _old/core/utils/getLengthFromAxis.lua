local types = require(script.Parent.Parent.Parent.types)
type Axis = types.Axis
type Length = types.Length

local function getLengthFromAxis(axis: Axis): Length
	return if axis == "y" then "height" else "width"
end

return getLengthFromAxis
