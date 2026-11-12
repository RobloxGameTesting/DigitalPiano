local CoreGui = game:GetService("CoreGui")

local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)

local function withMountedElement(p, callback)
	local rhodiumScreenGui = Instance.new("ScreenGui")
	rhodiumScreenGui.Name = "RhodiumScreenGui"
	rhodiumScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	rhodiumScreenGui.Parent = CoreGui

	local v = nil
	local success, result = pcall(function()
		v = Roact.mount(p, rhodiumScreenGui)
	end)

	if not success then
		rhodiumScreenGui:Destroy()
		error(result)
	end

	local success2, result2 = pcall(function()
		callback(rhodiumScreenGui:FindFirstChildWhichIsA("GuiObject"))
	end)

	Roact.unmount(v)
	rhodiumScreenGui:Destroy()

	if not success2 then
		error(result2)
	end
end

return withMountedElement