local function getAlignment(placement)
	return string.split(placement, "-")[2]
end

return getAlignment
