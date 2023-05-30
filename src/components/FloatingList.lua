local React = require(script.Parent.Parent.Parent.React)
local Collections = require(script.Parent.Parent.Parent.Collections)

local Array, Map = Collections.Array, Collections.Map

type Node = GuiBase2d

local e = React.createElement

type ListContext = {
	register: (node: Node) -> (),
	unregister: (node: Node) -> (),
	map: { [string]: Node },
	elementsRef: { current: { GuiObject } },
}

local FloatingListContext = React.createContext({
	register = function() end,
	unregister = function() end,
	map = {},
	elementsRef = { current = {} },
} :: ListContext)

local function areMapsEqual(map1, map2)
	if map1.size ~= map2.size then
		return false
	end

	for key, value in map1:entries() do
		if value ~= map2:get(key) then
			return false
		end
	end

	return true
end

type FloatingListProps = {
	children: any,
}

local function FloatingList(props: FloatingListProps)
	local map, setMap = React.useState(Map.new)

	local register = React.useCallback(function(node: Node)
		setMap(function(prevMap)
			return Map.new(prevMap):set(node, nil)
		end)
	end, {})

	local unregister = React.useCallback(function(node: Node)
		setMap(function(prevMap)
			local map = Map.new(prevMap)
			map:delete(node)
			return map
		end)
	end, {})

	React.useLayoutEffect(function()
		local newMap = Map.new(map)
		local nodes = Array.sort(Array.from(newMap:keys()))

		Array.forEach(nodes, function(node, index)
			newMap:set(node, index)
		end)

		if not areMapsEqual(map, newMap) then
			setMap(newMap)
		end
	end, {})

	return e(FloatingListContext.Provider, {
		value = React.useMemo(function()
			return {
				register = register,
				unregister = unregister,
				map = map,
			}
		end, { register, unregister, map }),
	}, props.children)
end

local function useListItem()
	local index, setIndex = React.useState(nil :: number?)
	local componentRef = React.useRef(nil) :: { current: Node? }

	local context = React.useContext(FloatingListContext)
	local register, unregister, map, elementsRef =
		context.register, context.unregister, context.map, context.elementsRef

	local ref = React.useCallback(function(node: GuiObject?)
		componentRef.current = node

		if index ~= nil then
			elementsRef.current[index] = node
		end
	end, { index, elementsRef })

	React.useLayoutEffect(function()
		local node = componentRef.current
		if node then
			register(node)
			return function()
				unregister(node)
			end
		end
	end, { register, unregister })

	React.useLayoutEffect(function()
		local index = if componentRef.current then map:get(componentRef.current) else nil
		if index ~= nil then
			setIndex(index)
		end
	end, { map })

	return React.useMemo(function()
		return {
			ref = ref,
			index = if index == nil then -1 else index,
		}
	end, { index, ref })
end

return {
	useListItem = useListItem,
	FloatingList = FloatingList,
}
