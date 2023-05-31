local React = require(script.Parent.Parent.Parent.Parent.React)

local FloatingDelayGroupContext = require(script.Parent["FloatingDelayGroup.context"])

local function useDelayGroupContext()
	return React.useContext(FloatingDelayGroupContext)
end

return useDelayGroupContext
