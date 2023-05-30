local Workspace = game:GetService("Workspace")

local types = require(script.Parent.types)

type MiddlewareState = types.MiddlewareState
type Element = types.Element

type Boundary = "clippingAncestors" | Element
type RootBoundary = Element | "viewport"

export type Options = {
	boundary: Boundary?,
	rootBoundary: RootBoundary?,
	elementContext: "floating" | "reference"?,
	altBoundary: boolean?,
}

local function getViewportRect()
	return {
		AbsolutePosition = Vector2.zero,
		AbsoluteSize = Workspace.CurrentCamera.ViewportSize,
	}
end

--[=[
	@within FloatingUI

	This function computes the overflow offsets of either the reference or floating element relative to any clipping boundaries.
	Almost every middleware provided by the library uses this function, making it useful for your own custom middleware.
]=]
local function detectOverflow(state: MiddlewareState | any, options: Options)
	local element: GuiObject = state.rects.reference
	local tooltip: GuiObject = state.rects.floating

	local container = if options.rootBoundary == "viewport" then getViewportRect() else element.Parent :: GuiObject

	local mainContainerPosition = container.AbsolutePosition
	local mainContainerSize = container.AbsoluteSize
	local tooltipPosition = state.position
	local tooltipSize = tooltip.AbsoluteSize

	local overflowOffsets = {
		left = mainContainerPosition.X - tooltipPosition.X,
		right = tooltipPosition.X + tooltipSize.X - (mainContainerPosition.X + mainContainerSize.X),
		top = mainContainerPosition.Y - tooltipPosition.Y,
		bottom = tooltipPosition.Y + tooltipSize.Y - (mainContainerPosition.Y + mainContainerSize.Y),
	}

	return overflowOffsets
end

return detectOverflow
