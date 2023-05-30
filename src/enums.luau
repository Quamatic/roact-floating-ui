local sides = { "top", "right", "bottom", "left" }
local allPlacements: { string } = {}

for _, side in sides do
	table.insert(allPlacements, side)
	table.insert(allPlacements, `{side}-start`)
	table.insert(allPlacements, `{side}-end`)
end

return {
	sides = sides,
	allPlacements = allPlacements,
}
