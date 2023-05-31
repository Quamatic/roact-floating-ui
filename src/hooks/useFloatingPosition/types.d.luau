local types = require(script.Parent.Parent.Parent.types)

export type ReferenceType = GuiObject | {}

export type UseFloatingData = types.ComputePositionReturn & {
	isPositioned: boolean,
}

type MutableRefObject<T> = {
	current: T,
}

export type UseFloatingReturn<RT = ReferenceType> = UseFloatingData & {
	update: () -> (),
	refs: {
		reference: MutableRefObject<RT?>,
		floating: MutableRefObject<GuiObject?>,
		setReference: (node: RT?) -> (),
		setFloating: (node: GuiObject?) -> (),
	},
	elements: {
		reference: RT?,
		floating: GuiObject?,
	},
}

export type UseFloatingOptions<RT = ReferenceType> = types.ComputePositionConfig & {
	whileElementsMounted: ((reference: RT, floating: GuiObject, update: () -> ()) -> () -> ())?,
	elements: {
		reference: RT?,
		floating: GuiObject?,
	}?,
	open: boolean?,
}

return {}
