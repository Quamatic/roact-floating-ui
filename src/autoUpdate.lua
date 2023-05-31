local RunService = game:GetService("RunService")
local Array = require(script.Parent.Parent.Collections).Array

type AutoUpdateOptions = {
	ancestorPosition: boolean?,
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

	if animationFrame then
		RunService:BindToRenderStep(
			`floating_auto_update_{animationFrameId}`,
			Enum.RenderPriority.Camera.Value - 1,
			function()
				local nextRefSize = reference.AbsoluteSize
				local nextRefPosition = reference.AbsolutePosition

				if
					nextRefSize.X ~= nextRefSize.X
					or nextRefSize.Y ~= nextRefSize.Y
					or nextRefPosition.X ~= nextRefPosition.X
					or nextRefPosition.Y ~= nextRefPosition.Y
				then
					update()
				end
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
