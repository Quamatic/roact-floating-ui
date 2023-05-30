local function getSide(placement)
	return string.split(placement, "-")[1]
end

return getSide
