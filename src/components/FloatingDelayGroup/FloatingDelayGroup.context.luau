local React = require(script.Parent.Parent.Parent.Parent.React)

type Delay = number | { open: number?, close: number? }

export type GroupState = {
	delay: Delay,
	initialDelay: Delay,
	currentId: any,
	timeoutMs: number,
	isInstantPhase: boolean,
}

export type GroupContext = GroupState & {
	setCurrentId: (currentId: any) -> (),
	setState: (state: GroupState) -> (),
}

local FloatingGroupDelayContext = React.createContext({
	delay = 0,
	initialDelay = 0,
	timeoutMs = 0,
	setCurrentId = function() end,
	setState = function() end,
	isInstantPhase = false,
} :: GroupContext)

return FloatingGroupDelayContext
