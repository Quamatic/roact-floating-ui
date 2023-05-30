export type Middleware = {
	name: string,
	options: any?,
	fn: (state: MiddlewareState) -> Vector2,
}

export type MiddlewareState = Coords & {
	initialPlacement: Placement,
	placement: Placement,
	strategy: Strategy,
	middlewareData: MiddlewareReturn,
}

export type MiddlewareReturn = {
	data: { [string]: any }?,
	reset: true | {}?,
}

export type Alignment = "start" | "end"
export type Side = "top" | "bottom" | "right" | "left"
export type Axis = "x" | "y"
export type Strategy = "absolute" | "fixed"
export type Length = "width" | "height"
export type Placement = Side | Alignment

export type SideObject = { [Side]: number }
export type PartialSideObject = { [Side]: number? }

export type Coords = {
	[Axis]: number,
}

export type Dimensions = {
	[Length]: number,
}

export type Rect = Coords & Dimensions

export type Boundary = "clippingAncestors" | Rect
export type RootBoundary = "viewport" | "container" | Rect
export type ElementContext = "floating" | "reference"
export type Padding = number | PartialSideObject

export type ComputePositionConfig = {}

return {}
