local types = require(script.Parent.Parent.types)

type MiddlewareState = types.MiddlewareState
type Boundary = types.Boundary
type RootBoundary = types.RootBoundary
type ElementContext = types.ElementContext
type Padding = types.Padding

export type Options = {
	boundary: Boundary?,
	rootBoundary: RootBoundary?,
	elementContext: ElementContext?,
	altBoundary: boolean?,
	padding: Padding?,
}

local function detectOverflow(state: MiddlewareState, options: Options)
	local boundary = options.boundary or "clippingAncestors"
	local rootBoundary = options.rootBoundary or "viewport"
	local elementContext = options.elementContext or "floating"
	local altBoundary = not not options.altBoundary
	local padding = options.padding or 0

	return {}
end

return detectOverflow
