local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local object = setmetatable({}, { __mode = "k" })

local function isEquippedTitleLabel(label) -- 2 equivalent calls inferred from this helper
	return label:IsA("TextLabel") and label.Name:match("^EquippedTitle_%d+$") ~= nil
end

local function cleanupOverheadGui(instance)
	if not instance or not instance.Parent or instance.Name ~= "OverheadBBGUI" then
		return
	end

	local childrenByName = {}

	for _, child in ipairs(instance:GetChildren()) do
		if not isEquippedTitleLabel(child) then -- inferred equivalent call
			continue
		end

		local v = childrenByName[child.Name]

		if v and v.Parent then
			v:Destroy()
		end

		childrenByName[child.Name] = child
	end
end

local function watchOverheadGui(billboardGui) -- 3 equivalent calls inferred from this helper
	if object[billboardGui] then
		cleanupOverheadGui(billboardGui)
		return
	end

	object[billboardGui] = true
	cleanupOverheadGui(billboardGui)
	billboardGui.ChildAdded:Connect(function(child)
		if isEquippedTitleLabel(child) then -- inferred equivalent call
			task.defer(cleanupOverheadGui, billboardGui)
		end
	end)
end

local function scanCharacter(folder)
	if not folder then
		return
	end

	for _, billboardGui in ipairs(folder:GetDescendants()) do
		if billboardGui:IsA("BillboardGui") and billboardGui.Name == "OverheadBBGUI" then
			watchOverheadGui(billboardGui) -- inferred equivalent call
		end
	end

	folder.DescendantAdded:Connect(function(billboardGui)
		if billboardGui:IsA("BillboardGui") and billboardGui.Name == "OverheadBBGUI" then
			watchOverheadGui(billboardGui) -- inferred equivalent call
		end
	end)
end

for _, v in ipairs(Players:GetPlayers()) do
	scanCharacter(v.Character)
	v.CharacterAdded:Connect(scanCharacter)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(scanCharacter)
end)

Workspace.DescendantAdded:Connect(function(billboardGui)
	if billboardGui:IsA("BillboardGui") and billboardGui.Name == "OverheadBBGUI" then
		watchOverheadGui(billboardGui) -- inferred equivalent call
	end
end)