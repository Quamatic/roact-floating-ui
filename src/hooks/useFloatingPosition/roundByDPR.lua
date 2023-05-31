local Workspace = game:GetService("Workspace")

local function roundByDPR(value: number)
	local viewport = Workspace.CurrentCamera.ViewportSize
	local devicePixelRatio = viewport.X / viewport.Y

	return math.round(value * devicePixelRatio) / devicePixelRatio
end

return roundByDPR
