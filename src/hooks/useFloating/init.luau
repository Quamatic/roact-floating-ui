local src = script.Parent.Parent.Parent
local React = require(src.React)
local LuauPolyfill = require(src.LuauPolyfill)
local Array = LuauPolyfill.Array
local Object = LuauPolyfill.Object

local createPubSub = require(script.Parent.Parent.utils.createPubSub)
local getBoundingClientRect = require(script.Parent.Parent.utils.getBoundingClientRect)
local isElement = require(script.Parent.Parent.utils.isElement)

local useEffectEvent = require(script.Parent.utils.useEffectEvent)
local useFloatingPosition = require(script.Parent.useFloatingPosition).useFloatingPosition
local useFloatingTree = require(script.Parent.Parent.components.FloatingTree).useFloatingTree

local types = require(script.Parent.useFloatingPosition["types.d"])
type ReferenceType = types.ReferenceType
type UseFloatingPositionOptions<RT = ReferenceType> = types.UseFloatingOptions<RT>
type UseFloatingReturn<RT = ReferenceType> = types.UseFloatingReturn<RT>

type UseFloatingOptions<RT = ReferenceType> = UseFloatingPositionOptions<RT> & {
	open: boolean?,
	onOpenChange: (open: boolean) -> ()?,
	nodeId: string?,
}

--[=[
    @within Hooks
]=]
local function useFloating<RT>(options: UseFloatingOptions<RT>): UseFloatingReturn<RT>
	local open = options.open

	local unstable_onOpenChange = options.onOpenChange
	local nodeId = options.nodeId

	local position = useFloatingPosition(options)
	local tree = useFloatingTree()
	local onOpenChange = useEffectEvent(unstable_onOpenChange)

	local events = React.useState(function()
		return createPubSub()
	end)

	local setPositionReference = React.useCallback(function(node: ReferenceType?)
		local positionReference = if isElement(node)
			then {
				getBoundingClientRect = function()
					return getBoundingClientRect(node)
				end,
				contextElement = node,
			}
			else node

		position.refs.setReference(positionReference :: RT)
	end, { position.refs })

	local refs = React.useMemo(function()
		return Object.assign({}, position.refs, {
			setPositionReference = setPositionReference,
		})
	end, { position.refs, setPositionReference })

	local context = React.useMemo(function()
		return Object.assign({}, position, {
			refs = refs,
			nodeId = nodeId,
			events = events,
			open = open,
			onOpenChange = onOpenChange,
		})
	end, { position, nodeId, events, open, onOpenChange, refs })

	React.useLayoutEffect(function()
		local node = tree and Array.find(tree.nodesRef.current, function(node)
			return node.id == nodeId
		end)

		if node then
			node.context = context
		end
	end)

	return React.useMemo(function()
		return Object.assign({}, position, {
			context = context,
			refs = refs,
		})
	end, { position, refs, context })
end

return useFloating
