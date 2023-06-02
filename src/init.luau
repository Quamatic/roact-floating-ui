--[=[
	@class FloatingUI
]=]

--[=[
	@class Components
]=]

--[=[
	@class Hooks
]=]

local _FloatingTree = require(script.components.FloatingTree)
local _FloatingDelayGroup = require(script.components.FloatingDelayGroup)
local _shift = require(script.middleware.shift)

return table.freeze({
	useFloating = require(script.hooks.useFloating),
	useFloatingPosition = require(script.hooks.useFloatingPosition).useFloatingPosition,
	useInteractions = require(script.hooks.useInteractions),
	useClick = require(script.hooks.useClick),
	useHover = require(script.hooks.useHover),
	useDimiss = require(script.hooks.useDismiss),
	useClientPoint = require(script.hooks.useClientPoint),
	useTransitionStatus = require(script.hooks.useTransitionStatus),
	useId = require(script.hooks.useId),

	autoUpdate = require(script.autoUpdate),
	computePosition = require(script.computePosition),
	detectOverflow = require(script.detectOverflow),

	offset = require(script.middleware.offset),
	flip = require(script.middleware.flip),
	shift = _shift.shift,
	limitShift = _shift.limitShift,
	hide = require(script.middleware.hide),
	arrow = require(script.middleware.arrow),
	size = require(script.middleware.size),
	autoPlacement = require(script.middleware.autoPlacement),

	FloatingTree = _FloatingTree.FloatingTree,
	FloatingNode = _FloatingTree.FloatingNode,
	useFloatingNodeId = _FloatingTree.useFloatingNodeId,
	useFloatingParentNodeId = _FloatingTree.useFloatingParentNodeId,
	useFloatingTree = _FloatingTree.useFloatingTree,

	FloatingDelayGroup = _FloatingDelayGroup.FloatingDelayGroup,
	useDelayGroup = _FloatingDelayGroup.useDelayGroup,
	useDelayGroupContext = _FloatingDelayGroup.useDelayGroupContext,

	FloatingArrow = require(script.components.FloatingArrow),
	FloatingList = require(script.components.FloatingList),
	FloatingPortal = require(script.components.FloatingPortal),
})
