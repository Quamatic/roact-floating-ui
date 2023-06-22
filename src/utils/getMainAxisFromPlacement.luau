local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)
local Array = LuauPolyfill.Array

local getSide = require(script.Parent.getSide)

local function getMainAxisFromPlacement(placement)
	return if Array.includes({ "top", "bottom" }, getSide(placement)) then "x" else "y"
end

return getMainAxisFromPlacement
