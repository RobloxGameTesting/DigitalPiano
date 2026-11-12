local UserInputService = game:GetService("UserInputService")

local parent = script.Parent

local v = nil
local v2 = nil
local position = nil
local position2 = nil

local function update(input) -- 1 equivalent call inferred from this helper
	local v3 = input.Position - position
	parent.Position = UDim2.new(
		position2.X.Scale,
		position2.X.Offset + v3.X,
		position2.Y.Scale,
		position2.Y.Offset + v3.Y
	)
end

parent.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v = true
		position = input.Position
		position2 = parent.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				v = false
			end
		end)
	end
end)

parent.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		v2 = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == v2 and v then
		update(input) -- inferred equivalent call
	end
end)