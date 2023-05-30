local types = require(script.Parent.types)
type ComputePositionConfig = types.ComputePositionConfig

local computePositionCore = require(script.Parent.core.computePosition)
local merge = require(script.Parent.core.utils.merge)

local function computePosition(reference: GuiObject, floating: GuiObject, options: ComputePositionConfig?)
	return computePositionCore(
		reference,
		floating,
		merge(options, {
			platform = {},
		})
	)
end

return computePosition
