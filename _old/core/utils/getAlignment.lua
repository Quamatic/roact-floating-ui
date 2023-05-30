local types = require(script.Parent.Parent.Parent.types)
type Placement = types.Placement
type Side = types.Side

local function getSide(placement: Placement): Side
	return placement:split("-")[2] :: Side
end

return getSide
