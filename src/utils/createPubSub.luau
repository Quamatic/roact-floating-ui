local Collections = require(script.Parent.Parent.Parent.Collections)
local Map, Array = Collections.Map, Collections.Array

local function createPubSub()
	local map = Map.new()
	local sub = {}

	function sub:emit(event: string, data: any)
		Array.forEach(map:get(event) or {}, function(handler)
			handler(data)
		end)
	end

	function sub:on(event: string, listener: (data: any) -> ())
		map:set(event, Array.concat(map:get(event) or {}, listener))
	end

	function sub:off(event: string, listener: (data: any) -> ())
		map:set(
			event,
			Array.filter(map:get(event) or {}, function(l)
				return l ~= listener
			end)
		)
	end

	return sub
end

return createPubSub
