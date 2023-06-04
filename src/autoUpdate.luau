local RunService = game:GetService("RunService")
local Array = require(script.Parent.Parent.Collections).Array

local getBoundingClientRect = require(script.Parent.utils.getBoundingClientRect)

type AutoUpdateOptions = {
	--ancestorPosition: boolean?,
	ancestorResize: boolean?,
	elementResize: boolean?,
	animationFrame: boolean?,
}

local nextAnimationFrameId = 0

--[=[
    @within FloatingUI

    The floating element can detach from the reference element if the user scrolls or resizes the screen, 
    so its position needs to be updated again to ensure it stays anchored.

    To solve this, autoUpdate() adds listeners that will automatically call an update function which invokes computePosition() when necessary. 
    Updates typically take only ~1ms.

    Only call this function when the floating element is open on the screen.
]=]
local function autoUpdate(reference: GuiObject, floating: GuiObject, update: () -> (), options: AutoUpdateOptions)
	options = options or {}
	--local ancestorPosition = options.ancestorPosition or true
	local ancestorResize = options.ancestorResize or true
	local elementResize = options.elementResize or true
	local animationFrame = options.animationFrame or false

	local animationFrameId = nextAnimationFrameId
	nextAnimationFrameId += 1

	local connections: { RBXScriptConnection } = {}

	if ancestorResize then
		table.insert(connections, reference:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
		table.insert(connections, reference:GetPropertyChangedSignal("AbsolutePosition"):Connect(update))
	end

	if elementResize then
		table.insert(connections, floating:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
	end

	local prevRefRect = if animationFrame then getBoundingClientRect(reference) else nil

	if animationFrame then
		RunService:BindToRenderStep(
			`floating_auto_update_{animationFrameId}`,
			Enum.RenderPriority.Camera.Value - 1,
			function()
				local nextRefRect = getBoundingClientRect(reference)

				if
					nextRefRect.x ~= prevRefRect.x
					or nextRefRect.y ~= prevRefRect.y
					or nextRefRect.width ~= prevRefRect.width
					or nextRefRect.height ~= prevRefRect.height
				then
					update()
				end

				prevRefRect = nextRefRect
			end
		)
	end

	update()

	return function()
		Array.forEach(connections, function(connection)
			connection:Disconnect()
		end)

		if animationFrame then
			RunService:UnbindFromRenderStep(`floating_auto_update_{animationFrameId}`)
		end
	end
end

return autoUpdate
