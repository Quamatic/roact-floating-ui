local UserInputService = game:GetService("UserInputService")

local React = require(script.Parent.Parent.Parent.React)

local function useClientPoint(context, props)
	local open = context.open

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

	local setReference = React.useCallback(function() end, {})

	local handleReferenceEnterOrMove = React.useCallback(function(input: InputObject)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			or input.UserInputState ~= Enum.UserInputState.Change
		then
			return
		end

		if not open then
			local position = Vector2.new(input.Position.X, input.Position.Y)
			setReference(position)
		end
	end, {})

	return React.useMemo(function()
		return {
			reference = {
				[React.Event.InputBegan] = handleReferenceEnterOrMove,
				[React.Event.InputChanged] = handleReferenceEnterOrMove,
			},
		}
	end, {})
end

return useClientPoint
