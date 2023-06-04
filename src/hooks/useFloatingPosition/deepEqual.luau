local function deepEqual(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then
		return a == b
	end

	for k in pairs(a) do
		local av = a[k]
		local bv = b[k]

		if type(av) == "function" or type(bv) == "function" then
			continue
		end

		if type(av) == "table" and type(bv) == "table" then
			local result = deepEqual(av, bv)
			if not result then
				return false
			end
		elseif av ~= bv then
			return false
		end
	end

	-- extra keys in b
	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end

	return true
end

return deepEqual
