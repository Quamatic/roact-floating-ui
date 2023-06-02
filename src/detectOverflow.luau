local getSideObjectFromPadding = require(script.Parent.utils.getSideObjectFromPadding)
local getClippingRect = require(script.Parent.utils.getClippingRect)
local getLayerElement = require(script.Parent.utils.getLayerElement)
local rectToClientRect = require(script.Parent.utils.rectToClientRect)
local isElement = require(script.Parent.utils.isElement)
local merge = require(script.Parent.utils.merge)

local types = require(script.Parent.types)

type MiddlewareState = types.MiddlewareState
type Element = types.Element

type Boundary = "parent" | Element
type RootBoundary = Element | "viewport"

export type Options = {
	boundary: Boundary?,
	rootBoundary: RootBoundary?,
	elementContext: "floating" | "reference"?,
	altBoundary: boolean?,
	padding: number?,
}

--[=[
	@within FloatingUI
	@unreleased

	This function computes the overflow offsets of either the reference or floating element relative to any clipping boundaries.
	Almost every middleware provided by the library uses this function, making it useful for your own custom middleware.
		
	The returned value, overflow, is a SideObject containing side properties with numbers representing offsets.

    - A positive number means the element is overflowing the clipping boundary by that number of pixels.
    - A negative number means the element has that number of pixels left before it will overflow the clipping boundary.
    - 0 means the side lies flush with the clipping boundary.
]=]
local function detectOverflow(state: MiddlewareState, options: Options)
	options = options or {} :: Options

	local x = state.x
	local y = state.y
	local rects = state.rects
	local elements = state.elements

	local boundary = options.boundary or "parent"
	local rootBoundary = options.rootBoundary or "viewport"
	local elementContext = options.elementContext or "floating"
	local altBoundary = options.altBoundary or false
	local padding = options.padding or 0

	local paddingObject = getSideObjectFromPadding(padding)
	local altContext = if elementContext == "floating" then "reference" else "floating"
	local element = state.elements[if altBoundary then altContext else elementContext]

	local rawElement = if isElement(element)
		then element
		else element.contextElement or getLayerElement(elements.floating)

	local clippingClientRect = rectToClientRect(getClippingRect({
		element = rawElement,
		boundary = boundary,
		rootBoundary = rootBoundary,
	}))

	local rect = if elementContext == "floating" then merge(rects.floating, { x = x, y = y }) else rects.reference
	local elementClientRect = rectToClientRect(rect)

	local overflows = {
		top = clippingClientRect.top - elementClientRect.top + paddingObject.top,
		bottom = elementClientRect.bottom - clippingClientRect.bottom + paddingObject.bottom,
		left = clippingClientRect.left - elementClientRect.left + paddingObject.left,
		right = elementClientRect.right - clippingClientRect.right + paddingObject.right,
	}

	return overflows
end

return detectOverflow