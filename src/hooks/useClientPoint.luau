local UserInputService = game:GetService("UserInputService")

local React = require(script.Parent.Parent.Parent.React)

local function useClientPoint(context, props)
	local setReference = React.useCallback(function() end)

	local addListener = React.useCallback(function()
		local function handleMouseMove(input: InputObject)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end
		end

		local connection = UserInputService.InputBegan:Connect(handleMouseMove)
		return function()
			connection:Disconnect()
		end
	end, {})
end

return useClientPoint
