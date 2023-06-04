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
	placement: Placement,
	rects: ElementRects,
	elements: Elements,
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
	middlewareData: MiddlewareData,
}

export type ClientRectObject = Rect & SideObject

export type SideObject = {
	top: number,
	bottom: number,
	left: number,
	right: number,
}

export type Padding = number | SideObject

export type VirtualElement = {
	getBoundingClientRect: () -> ClientRectObject,
	contextElement: Element?,
}

export type ReferenceElement = Element | VirtualElement
export type FloatingElement = GuiObject
export type Element = GuiObject

export type Elements = {
	reference: ReferenceElement,
	floating: FloatingElement,
}

export type Rect = {
	x: number,
	y: number,
	width: number,
	height: number,
}

export type ElementRects = {
	reference: Rect,
	floating: Rect,
}

type Position = {
	x: number,
	y: number,
}

type ContextData = {
	[string]: any,
}

type MutableRefObject<T> = {
	current: T,
}

type ReferenceType = GuiObject

type ExtendedRefs<RT> = {
	reference: MutableRefObject<ReferenceType?>,
	floating: MutableRefObject<GuiObject?>,
	setReference: (node: RT?) -> (),
	setFloating: (node: GuiObject) -> (),
	setPositionReference: (node: ReferenceType?) -> (),
}

export type FloatingEvents = {
	emit: (self: FloatingEvents, event: string, data: any?) -> (),
	on: (self: FloatingEvents, listener: (data: any) -> ()) -> (),
	off: (self: FloatingEvents, listener: (data: any) -> ()) -> (),
}

export type FloatingContext<RT> = {
	open: boolean,
	onOpenChange: (open: boolean) -> (),
	events: FloatingEvents,
	dataRef: MutableRefObject<ContextData>,
	nodeId: string?,
	floatingId: string,
	refs: ExtendedRefs<RT>,
}

return {}
