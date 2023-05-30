local React = require(script.Parent.Parent.Parent.React)
local LuauPolyfill = require(script.Parent.Parent.Parent.Collections)

local Array, Object, Map = LuauPolyfill.Array, LuauPolyfill.Object, LuauPolyfill.Map

local function mergeProps(userProps, propsList, elementKey)
	local map = Map.new()

	return Object.assign(
		{},
		userProps,
		Array.reduce(
			Array.concat(
				Array.map(propsList, function(value)
					return if value then value[elementKey] else Object.None
				end),
				userProps
			),
			function(acc, props)
				if not props then
					return acc
				end

				Array.forEach(Object.entries(props), function(entry)
					local key = entry[1]
					local value = entry[2]

					acc[key] = value
				end)

				return acc
			end,
			{}
		)
	)
end

local function useInteractions(propsList)
	local deps = propsList

	local getReferenceProps = React.useCallback(function(userProps)
		return mergeProps(userProps, propsList, "reference")
	end, deps)

	local getFloatingProps = React.useCallback(function(userProps)
		return mergeProps(userProps, propsList, "floating")
	end, deps)

	local getItemProps = React.useCallback(
		function(userProps)
			return mergeProps(userProps, propsList, "item")
		end,
		Array.map(propsList, function(key)
			return key and key.item
		end)
	)

	return React.useMemo(function()
		return {
			getReferenceProps = getReferenceProps,
			getFloatingProps = getFloatingProps,
			getItemProps = getItemProps,
		}
	end, { getReferenceProps, getFloatingProps, getItemProps })
end

return useInteractions
