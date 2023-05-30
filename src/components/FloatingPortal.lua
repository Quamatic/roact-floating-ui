local React = require(script.Parent.Parent.Parent.React)
local ReactRoblox = require(script.Parent.Parent.Parent.ReactRoblox)

local e = React.createElement

local function FloatingPortal()
	return ReactRoblox.createPortal({}, game)
end

return FloatingPortal
