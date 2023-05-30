local React = require(script.Parent.Parent.Parent.React)

local serverHandoffComplete = false
local count = 0

local function genId()
	count += 1
	return `floating-ui-{count}`
end

local function useId()
	local id, setId = React.useState(if serverHandoffComplete then genId() else nil)

	React.useLayoutEffect(function()
		if id == nil then
			setId(genId())
		end
	end, {})

	React.useEffect(function()
		if not serverHandoffComplete then
			serverHandoffComplete = true
		end
	end, {})

	return id
end

return useId
