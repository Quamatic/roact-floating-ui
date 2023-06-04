local Workspace = game:GetService("Workspace")

local function getViewportSize()
	local camera = Workspace.CurrentCamera
	return if camera == nil then Vector2.zero else camera.ViewportSize
end

local function roundByDPR(value: number)
	local viewport = getViewportSize()
	local devicePixelRatio = viewport.X / viewport.Y

	return math.round(value * devicePixelRatio) / devicePixelRatio
end

return roundByDPR
