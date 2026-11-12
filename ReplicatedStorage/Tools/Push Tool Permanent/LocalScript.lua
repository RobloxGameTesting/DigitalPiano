local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local parent = script.Parent

local cooldownLabel = nil
local v = 0

local v2 = 0
local v3 = 0
local visible = false
local v4 = {}

local v5 = 0

local function createCooldownGUI()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local cooldownGUI = playerGui:FindFirstChild("CooldownGUI")

	if not cooldownGUI then
		cooldownGUI = Instance.new("ScreenGui")
		cooldownGUI.Name = "CooldownGUI"
		cooldownGUI.ResetOnSpawn = false
		cooldownGUI.Parent = playerGui
	end

	cooldownLabel = cooldownGUI:FindFirstChild("CooldownLabel")

	if not cooldownLabel then
		cooldownLabel = Instance.new("TextLabel")
		cooldownLabel.Name = "CooldownLabel"
		cooldownLabel.Size = UDim2.new(0, 260, 0, 44)
		cooldownLabel.Position = UDim2.new(0.5, -130, 0.9, -22)
		cooldownLabel.BackgroundTransparency = 0.25
		cooldownLabel.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
		cooldownLabel.BorderSizePixel = 0
		cooldownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		cooldownLabel.TextScaled = true
		cooldownLabel.Font = Enum.Font.GothamBold
		cooldownLabel.Parent = cooldownGUI
	end

	cooldownLabel.Visible = false
end

createCooldownGUI()

local function formatTime(p) -- 2 equivalent calls inferred from this helper
	local v6 = math.max(0, (math.floor(tonumber(p) or 0)))
	local v7 = math.floor(v6 / 60)
	local v8 = v6 % 60
	return string.format("%d:%02d", v7, v8)
end

local function updateCooldownGUI(p) -- 1 equivalent call inferred from this helper
	v2 = math.max(0, (math.floor(tonumber(p) or 0)))

	if not (v2 > 0) then
		cooldownLabel.Visible = false

		return
	end

	cooldownLabel.Visible = visible
	cooldownLabel.Text = "Push Tool Cooldown: " .. formatTime(v2) -- inferred equivalent call
end

local function playPushAnimation()
	local humanoid = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")

	if not humanoid or v2 > 0 then
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local child = parent:FindFirstChild(humanoid.RigType == Enum.HumanoidRigType.R15 and "PushR15" or "PushR6")

	if child then
		animator:LoadAnimation(child):Play()
	end
end

local function isManagedPianoModel(model, pianos)
	return model
		and model:IsA("Model")
		and model:IsDescendantOf(pianos)
		and (model:FindFirstChild("SeatOccupant") or model:FindFirstChild("SeatOccupants") or model:GetAttribute("AllowMultipleOccupants") == true or model:GetAttribute("PushToolEnabled") == true)
end

local function getManagedPianoFromInstance(seatPart)
	local pianos = Workspace:FindFirstChild("Pianos")

	if not (pianos and seatPart) then
		return nil
	end

	while seatPart and seatPart ~= Workspace do
		if isManagedPianoModel(seatPart, pianos) then
			return seatPart
		end

		seatPart = seatPart.Parent
	end

	return nil
end

local function isPushEnabledPiano(instance) -- 2 equivalent calls inferred from this helper
	return instance and instance:GetAttribute("PushToolEnabled") == true
end

local function getPlayerFromOccupantValue(value) -- 2 equivalent calls inferred from this helper
	if value and value:IsA("Player") then
		return value
	end

	if value and value:IsA("Model") then
		return Players:GetPlayerFromCharacter(value)
	end

	return nil
end

local function isPushImmunePlayer(instance) -- 3 equivalent calls inferred from this helper
	return instance and instance:GetAttribute("PushToolImmune") == true
end

local function pianoHasPushImmuneOccupant(folder): boolean
	if not folder then
		return false
	end

	local seatOccupant = folder:FindFirstChild("SeatOccupant")

	if seatOccupant and seatOccupant:IsA("ObjectValue") then
		local playerFromOccupantValue = getPlayerFromOccupantValue(seatOccupant.Value) -- inferred equivalent call

		if isPushImmunePlayer(playerFromOccupantValue) then -- inferred equivalent call
			return true
		end
	end

	local seatOccupants = folder:FindFirstChild("SeatOccupants")

	if seatOccupants then
		for _, objectValue in ipairs(seatOccupants:GetChildren()) do
			if not objectValue:IsA("ObjectValue") then
				continue
			end

			local playerFromOccupantValue = getPlayerFromOccupantValue(objectValue.Value) -- inferred equivalent call

			if isPushImmunePlayer(playerFromOccupantValue) then -- inferred equivalent call
				return true
			end
		end
	end

	for _, seat in ipairs(folder:GetDescendants()) do
		if not (seat:IsA("Seat") and seat.Occupant) then
			continue
		end

		local parent2 = seat.Occupant.Parent
		local playerFromCharacter = parent2 and Players:GetPlayerFromCharacter(parent2)

		if isPushImmunePlayer(playerFromCharacter) then -- inferred equivalent call
			return true
		end
	end

	return false
end

local function getIndicatorAdornee(descendant) -- 1 equivalent call inferred from this helper
	if not descendant then
		return nil
	end

	local seat = descendant:FindFirstChildWhichIsA("Seat", true)

	if seat then
		return seat
	end

	if descendant.PrimaryPart and descendant.PrimaryPart:IsA("BasePart") then
		return descendant.PrimaryPart
	end

	return descendant:FindFirstChildWhichIsA("BasePart", true)
end

local function clearPushIndicators()
	for _, v6 in pairs(v4) do
		if v6 then
			v6:Destroy()
		end
	end

	table.clear(v4)
end

local function refreshPushIndicators()
	clearPushIndicators()

	if not visible then
		return
	end

	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	local pianos = Workspace:FindFirstChild("Pianos")

	if not (playerGui and pianos) then
		return
	end

	for _, descendant in ipairs(pianos:GetDescendants()) do
		if not (isManagedPianoModel(descendant, pianos) and isPushEnabledPiano(descendant)) then -- inferred equivalent call
			continue
		end

		local indicatorAdornee = getIndicatorAdornee(descendant) -- inferred equivalent call

		if not indicatorAdornee then
			continue
		end

		local v6 = pianoHasPushImmuneOccupant(descendant)
		local pushToolIndicator = Instance.new("BillboardGui")
		pushToolIndicator.Name = "PushToolIndicator"
		pushToolIndicator.Adornee = indicatorAdornee
		pushToolIndicator.AlwaysOnTop = true
		pushToolIndicator.MaxDistance = 90
		pushToolIndicator.Size = v6 and UDim2.new(0, 190, 0, 34) or UDim2.new(0, 150, 0, 34)
		pushToolIndicator.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)

		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundColor3 = v6 and Color3.fromRGB(45, 12, 18) or Color3.fromRGB(20, 23, 30)
		textLabel.BackgroundTransparency = 0.18
		textLabel.BorderSizePixel = 0
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Text = v6 and "CANNOT BE PUSHED" or "PUSH ENABLED"
		textLabel.TextColor3 = v6 and Color3.fromRGB(255, 78, 92) or Color3.fromRGB(255, 230, 120)
		textLabel.TextScaled = true
		textLabel.Parent = pushToolIndicator

		pushToolIndicator.Parent = playerGui
		v4[descendant] = pushToolIndicator
	end
end

local function pianoHasPlayerOccupant(folder, player, humanoid): boolean
	if not isPushEnabledPiano(folder) then -- inferred equivalent call
		return false
	end

	if humanoid.SeatPart and humanoid.SeatPart:IsDescendantOf(folder) then
		return true
	end

	local seatOccupant = folder:FindFirstChild("SeatOccupant")

	if seatOccupant and seatOccupant:IsA("ObjectValue") and seatOccupant.Value == player then
		return true
	end

	local seatOccupants = folder:FindFirstChild("SeatOccupants")

	if seatOccupants then
		for _, objectValue in ipairs(seatOccupants:GetChildren()) do
			if objectValue:IsA("ObjectValue") and objectValue.Value == player then
				return true
			end
		end
	end

	for _, seat in ipairs(folder:GetDescendants()) do
		if seat:IsA("Seat") and seat.Occupant == humanoid then
			return true
		end
	end

	return false
end

local function isPlayerOnPiano(player): boolean
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return false
	end

	if pianoHasPlayerOccupant(getManagedPianoFromInstance(humanoid.SeatPart), player, humanoid) then
		return true
	end

	local pianos = Workspace:FindFirstChild("Pianos")

	if not pianos then
		return false
	end

	for _, child in ipairs(pianos:GetChildren()) do
		if pianoHasPlayerOccupant(child, player, humanoid) then
			return true
		end
	end

	return false
end

local function getTargetPlayer()
	local v6 = 10
	local v7 = nil
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	for _, v8 in ipairs(Players:GetPlayers()) do
		local character2 = v8.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not (v8 ~= LocalPlayer and humanoidRootPart2 and isPlayerOnPiano(v8)) then
			continue
		end

		local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

		if not (magnitude < v6) then
			continue
		end

		v7 = v8
		v6 = magnitude
	end

	return v7
end

parent.Activated:Connect(function()
	local now = tick()

	if now - v >= 5 then
		v = now
		parent.UpdateCooldown:FireServer()
	end

	if v2 > 0 then
		return
	end

	playPushAnimation()

	local targetPlayer = getTargetPlayer()

	if targetPlayer then
		parent.PermPush:FireServer(targetPlayer)
	end
end)

parent:WaitForChild("UpdateCooldown").OnClientEvent:Connect(function(p)
	updateCooldownGUI(p) -- inferred equivalent call
end)

parent.Equipped:Connect(function()
	visible = true
	v5 = tick()
	parent.UpdateCooldown:FireServer()
	refreshPushIndicators()
end)

parent.Unequipped:Connect(function()
	visible = false
	cooldownLabel.Visible = false
	clearPushIndicators()
end)

RunService.Heartbeat:Connect(function()
	local now = tick()

	if now - v3 >= 1 then
		v3 = now

		if v2 > 0 then
			v2 = math.max(0, (math.floor(tonumber(v2 - 1) or 0)))

			if v2 > 0 then
				cooldownLabel.Visible = visible
				cooldownLabel.Text = "Push Tool Cooldown: " .. formatTime(v2) -- inferred equivalent call
			else
				cooldownLabel.Visible = false
			end
		end
	end

	if now - v >= 5 then
		v = now
		parent.UpdateCooldown:FireServer()
	end

	if visible and now - v5 >= 0.75 then
		v5 = now
		refreshPushIndicators()
	end
end)