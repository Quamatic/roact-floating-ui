local React = require(script.Parent.Parent.Parent.React)
local ReactRoblox = require(script.Parent.Parent.Parent.ReactRoblox)

local e = React.createElement

type FloatingPortalProps = {
	root: Instance?,
}

local function FloatingPortal(props: FloatingPortalProps)
	return ReactRoblox.createPortal({}, game)
end

return FloatingPortal
