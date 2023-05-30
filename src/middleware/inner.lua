local types = require(script.Parent.Parent.types)

type Middleware = types.Middleware
type MiddlewareState = types.MiddlewareState

local getSide = require(script.Parent.Parent.utils.getSide)
local getAlignment = require(script.Parent.Parent.utils.getAlignment)
local getMainAxisFromPlacement = require(script.Parent.Parent.utils.getMainAxisFromPlacement)

export type InnerProps = {
	listRef: { current: { GuiObject } },
	index: number,
	onFallbackChange: (fallback: boolean) -> ()?,
	offset: number?,
	minItemsVisible: number?,
	referenceOverflowThreshold: number?,
}

local function inner(props: InnerProps): Middleware
	return {
		name = "inner",
		options = props,
		fn = function(state)
			local listRef = props.listRef
			local index = props.index

			local item = listRef.current[index]
			if not item then
				return {}
			end

			return {
				position = Vector2.new(),
			}
		end,
	}
end

return inner
