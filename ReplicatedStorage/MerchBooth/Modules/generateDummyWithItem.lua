local Players = game:GetService("Players")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

require(MerchBooth.types)
local generateDescriptionWithItem = require(script.Parent.generateDescriptionWithItem)

local idleAnimation = Instance.new("Animation")
idleAnimation.Name = "IdleAnimation"
idleAnimation.AnimationId = "rbxassetid://616136790"

local function generateDummyWithItem(p, p2)
	local folder = Players:CreateHumanoidModelFromDescription(
		generateDescriptionWithItem(p2, p.assetId, p.assetType),
		Enum.HumanoidRigType.R15
	)

	for _, luaSourceContainer in ipairs(folder:GetDescendants()) do
		if luaSourceContainer:IsA("LuaSourceContainer") then
			luaSourceContainer:Destroy()
		end
	end

	local humanoid = folder:FindFirstChildOfClass("Humanoid")

	humanoid.RootPart.CFrame = CFrame.new(0, 100000, 0)
	humanoid.RootPart.Anchored = true

	folder.Parent = workspace

	humanoid:LoadAnimation(idleAnimation):Play()

	return folder
end

return generateDummyWithItem