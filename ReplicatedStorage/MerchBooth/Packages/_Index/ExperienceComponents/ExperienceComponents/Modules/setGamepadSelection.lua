local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local InputType = require(ExperienceComponents.Parent.InputType)

local function setGamepadSelection(instance)
	if InputType.isGamepad(UserInputService:GetLastInputType()) then
		task.spawn(function()
			repeat
				task.wait()
			until instance:IsDescendantOf(game)

			GuiService:Select(instance)
		end)
	end
end

return setGamepadSelection