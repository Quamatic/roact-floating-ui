local React = require(script.Parent.Parent.Parent.React)
local src = script.Parent.Parent.Parent
local LuauPolyfill = require(src.LuauPolyfill)

local Array, Object = LuauPolyfill.Array, LuauPolyfill.Object
local String = LuauPolyfill.String

local function mergeProps(userProps, propsList, elementKey)
	local eventHandlers = {}

	return Object.assign(
		{},
		userProps,
		Array.reduce(
			Array.concat(
				Array.map(propsList, function(value)
					return if value then value[elementKey] else nil
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

					if String.startsWith(tostring(key), "RoactHost") then
						eventHandlers[key] = eventHandlers[key] or {}

						if typeof(value) == "function" then
							table.insert(eventHandlers[key], value)

							acc[key] = function(...: unknown)
								local args = { ... }
								return Array.find(
									Array.map(eventHandlers[key], function(fn)
										return fn(unpack(args))
									end),
									function(val)
										return val ~= nil
									end
								)
							end
						end
					else
						acc[key] = value
					end
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

	-- TODO: Remove this.
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
