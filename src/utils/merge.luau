local function merge<T, U>(...: any)
	local result: { [T]: U } = {}

	for index = 1, select("#", ...) do
		local item = select(index, ...)

		if type(item) ~= "table" then
			continue
		end

		for key, value in pairs(item) do
			result[key] = value
		end
	end

	return result
end

return merge
