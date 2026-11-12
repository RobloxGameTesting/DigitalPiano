local Players = game:GetService("Players")

local parent = script.Parent
local LocalPlayer = Players.LocalPlayer
local v = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local v2 = false
local flag = true
local set = {}
local v3 = {}
local name = parent.Name

local function getToolContainers() -- 1 equivalent call inferred from this helper
	return { LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack") }
end

local function findPreferredThirdEyeTool()
	local character = LocalPlayer.Character

	if character then
		for _, tool in ipairs(character:GetChildren()) do
			if tool:IsA("Tool") and tool.Name == name then
				return tool
			end
		end
	end

	local backpack = LocalPlayer:FindFirstChild("Backpack")

	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and tool.Name == name then
				return tool
			end
		end
	end

	return parent
end

local function cleanupDuplicateThirdEyeTools()
	local preferredThirdEyeTool = findPreferredThirdEyeTool()

	for _, v4 in ipairs(getToolContainers()) do -- inferred equivalent call
		if not v4 then
			continue
		end

		for _, tool in ipairs(v4:GetChildren()) do
			if tool:IsA("Tool") and tool.Name == name and tool ~= preferredThirdEyeTool then
				tool:Destroy()
			end
		end
	end
end

local function watchToolContainer(instance)
	if instance and not set[instance] then
		set[instance] = true
		instance.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") and tool.Name == name then
				task.defer(cleanupDuplicateThirdEyeTools)
			end
		end)
	end
end

local v4 = {}

local function createClone(part)
	local nightVisionClone = part:Clone()
	nightVisionClone.Color = Color3.fromRGB(255, 0, 0)
	nightVisionClone.Transparency = 0.5
	nightVisionClone.CanCollide = false
	nightVisionClone.Anchored = false
	nightVisionClone.Name = "NightVisionClone"

	for _, child in pairs(nightVisionClone:GetChildren()) do
		if not (child:IsA("SpecialMesh") or child:IsA("Decal")) then
			child:Destroy()
		end
	end

	nightVisionClone.Parent = part.Parent

	local weld = Instance.new("Weld")
	weld.Part0 = part
	weld.Part1 = nightVisionClone
	weld.C0 = CFrame.new()
	weld.C1 = CFrame.new()
	weld.Parent = nightVisionClone

	return nightVisionClone
end

local function createBillboardGui(character, name2)
	local head = character:FindFirstChild("Head")

	if not head then
		return
	end

	local displayNameGui = head:FindFirstChild("DisplayNameGui")

	if displayNameGui then
		displayNameGui:Destroy()
	end

	local displayNameGui2 = Instance.new("BillboardGui")
	displayNameGui2.Name = "DisplayNameGui"
	displayNameGui2.Adornee = head
	displayNameGui2.Size = UDim2.new(4, 0, 1, 0)
	displayNameGui2.StudsOffset = Vector3.new(0, 2, 0)
	displayNameGui2.AlwaysOnTop = true
	displayNameGui2.Parent = head

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	textLabel.TextScaled = true
	textLabel.Text = name2
	textLabel.Parent = displayNameGui2
end

local function applyNightVisionToPlayer(player)
	if not player.Character or v4[player] then
		return
	end

	v4[player] = {}
	createBillboardGui(player.Character, player.Name)

	for _, part in pairs(player.Character:GetChildren()) do
		if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
			continue
		end

		local clone = createClone(part)
		table.insert(v4[player], clone)
	end
end

local function removeNightVisionFromPlayer(player)
	if not v4[player] then
		return
	end

	for _, v5 in pairs(v4[player]) do
		if v5 and v5.Parent then
			v5:Destroy()
		end
	end

	v4[player] = nil

	if player.Character then
		local head = player.Character:FindFirstChild("Head")

		local displayNameGui = head and head:FindFirstChild("DisplayNameGui")

		if displayNameGui then
			displayNameGui:Destroy()
		end
	end
end

local function applyNightVisionEffect(p)
	for _, v5 in pairs(Players:GetPlayers()) do
		if v5 == LocalPlayer then
			continue
		end

		if p then
			applyNightVisionToPlayer(v5)
		else
			removeNightVisionFromPlayer(v5)
		end
	end

	if p then
		if not v3.playerAdded then
			v3.playerAdded = Players.PlayerAdded:Connect(function(player)
				player.CharacterAdded:Connect(function()
					if v2 then
						task.wait(0.1)
						applyNightVisionToPlayer(player)
					end
				end)
			end)
		end

		if not v3.playerRemoving then
			v3.playerRemoving = Players.PlayerRemoving:Connect(function(player)
				removeNightVisionFromPlayer(player)
			end)
		end
	else
		if v3.playerAdded then
			v3.playerAdded:Disconnect()
			v3.playerAdded = nil
		end

		if v3.playerRemoving then
			v3.playerRemoving:Disconnect()
			v3.playerRemoving = nil
		end
	end
end

function onActivated()
	if flag then
		flag = false
		v2 = not v2

		applyNightVisionEffect(v2)
		parent.Name = v2 and name .. " [ON]" or name

		task.wait(1)
		flag = true
	end
end

function onEquipped()
	v = parent.Parent
	LocalPlayer = Players.LocalPlayer
end

local Backpack = LocalPlayer:FindFirstChild("Backpack")

local function onChildAdded(tool)
	if tool:IsA("Tool") and tool.Name == name then
		task.defer(cleanupDuplicateThirdEyeTools)
	end
end

if Backpack and not set[Backpack] then
	set[Backpack] = true
	Backpack.ChildAdded:Connect(onChildAdded)
end

local Character = LocalPlayer.Character

if Character and not set[Character] then
	set[Character] = true
	Character.ChildAdded:Connect(onChildAdded)
end

LocalPlayer.ChildAdded:Connect(function(child)
	if child.Name == "Backpack" then
		if child and not set[child] then
			set[child] = true
			child.ChildAdded:Connect(function(tool)
				if tool:IsA("Tool") and tool.Name == name then
					task.defer(cleanupDuplicateThirdEyeTools)
				end
			end)
		end

		task.defer(cleanupDuplicateThirdEyeTools)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	v = character

	if character and not set[character] then
		set[character] = true
		character.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") and tool.Name == name then
				task.defer(cleanupDuplicateThirdEyeTools)
			end
		end)
	end

	task.defer(cleanupDuplicateThirdEyeTools)
end)

cleanupDuplicateThirdEyeTools()
parent.Equipped:Connect(onEquipped)
parent.Activated:Connect(onActivated)