local React = require(script.Parent.Parent.Parent.React)
local Array = require(script.Parent.Parent.Parent.Collections).Array

local useId = require(script.Parent.Parent.hooks.useId)
local createPubSub = require(script.Parent.Parent.utils.createPubSub)

local e = React.createElement

local FloatingTreeContext = React.createContext(nil)
local FloatingNodeContext = React.createContext(nil)

local function useFloatingParentNodeId()
	return React.useContext(FloatingNodeContext).id
end

local function useFloatingTree()
	return React.useContext(FloatingTreeContext)
end

local function useFloatingNodeId(customParentId: string?)
	local id = useId()
	local tree = useFloatingTree()
	local reactParentId = useFloatingParentNodeId()
	local parentId = customParentId or reactParentId

	React.useLayoutEffect(function()
		local node = { id = id, parentId = parentId }
		tree.addNode(node)

		return function()
			tree.removeNode(node)
		end
	end, { tree, id, parentId })

	return id
end

type FloatingNodeProps = {
	id: string,
	children: React.ReactNode?,
}

local function FloatingNode(props: FloatingNodeProps)
	local parentId = useFloatingParentNodeId()

	return e(FloatingNodeContext.Provider, {
		value = React.useMemo(function()
			return { id = props.id, parentId = parentId }
		end, { props.id, parentId }),
	}, props.children)
end

type FloatingTreeProps = {
	children: React.ReactNode?,
}

--[=[
	@within Components

	Provides context for nested floating elements when they are not children of each other on the DOM.
]=]
local function FloatingTree(props: FloatingTreeProps)
	local nodesRef = React.useRef({})

	local addNode = React.useCallback(function(node)
		nodesRef.current = Array.concat(nodesRef.current, node)
	end, {})

	local removeNode = React.useCallback(function(node)
		nodesRef.current = Array.filter(nodesRef.current, function(n)
			return n ~= node
		end)
	end, {})

	local events = React.useState(function()
		return createPubSub()
	end)

	return e(FloatingTreeContext.Provider, {
		value = React.useMemo(function()
			return {
				nodesRef = nodesRef,
				addNode = addNode,
				removeNode = removeNode,
				events = events,
			}
		end, { nodesRef, addNode, removeNode, events }),
	})
end

return {
	useFloatingParentNodeId = useFloatingParentNodeId,
	useFloatingTree = useFloatingTree,
	useFloatingNodeId = useFloatingNodeId,
	FloatingTree = FloatingTree,
	FloatingNode = FloatingNode,
}
