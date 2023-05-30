export type Placement =
	"top"
	| "top-start"
	| "top-end"
	| "right"
	| "right-start"
	| "right-end"
	| "bottom"
	| "bottom-start"
	| "bottom-end"
	| "left"
	| "left-start"
	| "left-end"

export type Middleware<T = any> = {
	name: string,
	options: T?,
	fn: (state: MiddlewareState) -> MiddlewareReturn,
}

export type MiddlewareState = Position & {
	middlewareData: MiddlewareData,
}

export type MiddlewareReturn = Position & {
	data: { [string]: any }?,
	reset: true? | { placement: Placement },
}

type Overflows = {
	{
		placement: Placement,
		overflows: { number },
	}
}

export type MiddlewareData = {
	[string]: any,
	arrow: (Position & {
		centerOffset: number,
	})?,
	autoPlacement: {
		index: number?,
		overflows: Overflows,
	}?,
	flip: {
		index: number?,
		overflows: Overflows,
	}?,
	hide: {
		referenceHidden: boolean?,
		escaped: boolean?,
		referenceHiddenOffsets: true?,
		escapedOffsets: true?,
	}?,
	offset: Vector2?,
	shift: Vector2?,
}

export type ComputePositionConfig = {
	placement: Placement?,
	middleware: { Middleware }?,
}

export type ComputePositionReturn = Position & {
	placement: Placement,
	middlewareData: MiddlewareData,
}

export type VirtualElement = {}
export type Element = GuiObject | VirtualElement

type Position = {
	position: Vector2,
}

return {}
