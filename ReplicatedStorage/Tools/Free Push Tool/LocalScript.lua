local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local parent = script.Parent
local freePush = parent:FindFirstChild("FreePush")
	or parent:FindFirstChild("PermPush")
	or parent:WaitForChild("FreePush", 5)
	or parent:WaitForChild("PermPush")

local ClearFreePushToolIndicators = ReplicatedStorage:WaitForChild("ClearFreePushToolIndicators", 5)

local v = false
local v2 = {}

local v3 = 0

local function playPushAnimation()
	local humanoid = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChildOfClass("Humanoid")

	if not humanoid then
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
	for _, v4 in pairs(v2) do
		if v4 then
			v4:Destroy()
		end
	end

	table.clear(v2)

	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")

	if playerGui then
		for _, billboardGui in ipairs(playerGui:GetDescendants()) do
			if billboardGui:IsA("BillboardGui") and billboardGui.Name == "PushToolIndicator" then
				billboardGui:Destroy()
			end
		end
	end
end

local function refreshPushIndicators()
	clearPushIndicators()

	if not v then
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

		local v4 = pianoHasPushImmuneOccupant(descendant)
		local pushToolIndicator = Instance.new("BillboardGui")
		pushToolIndicator.Name = "PushToolIndicator"
		pushToolIndicator.Adornee = indicatorAdornee
		pushToolIndicator.AlwaysOnTop = true
		pushToolIndicator.MaxDistance = 90
		pushToolIndicator.Size = v4 and UDim2.new(0, 190, 0, 34) or UDim2.new(0, 150, 0, 34)
		pushToolIndicator.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)

		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundColor3 = v4 and Color3.fromRGB(45, 12, 18) or Color3.fromRGB(20, 23, 30)
		textLabel.BackgroundTransparency = 0.18
		textLabel.BorderSizePixel = 0
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Text = v4 and "CANNOT BE PUSHED" or "PUSH ENABLED"
		textLabel.TextColor3 = v4 and Color3.fromRGB(255, 78, 92) or Color3.fromRGB(255, 230, 120)
		textLabel.TextScaled = true
		textLabel.Parent = pushToolIndicator

		pushToolIndicator.Parent = playerGui
		v2[descendant] = pushToolIndicator
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
	if player:GetAttribute("PushToolImmune") == true then
		return false
	end

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
	local v4 = 10
	local v5 = nil
	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	for _, v6 in ipairs(Players:GetPlayers()) do
		local character2 = v6.Character
		local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

		if not (v6 ~= LocalPlayer and humanoidRootPart2 and isPlayerOnPiano(v6)) then
			continue
		end

		local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude

		if not (magnitude < v4) then
			continue
		end

		v5 = v6
		v4 = magnitude
	end

	return v5
end

parent.Activated:Connect(function()
	if not v then
		return
	end

	playPushAnimation()

	local targetPlayer = getTargetPlayer()

	if targetPlayer and freePush then
		freePush:FireServer(targetPlayer)
	end
end)

parent.Equipped:Connect(function()
	v = true
	v3 = tick()
	refreshPushIndicators()
end)

parent.Unequipped:Connect(function()
	v = false
	clearPushIndicators()
end)

local function deactivateToolUI() -- 1 equivalent call inferred from this helper
	v = false
	clearPushIndicators()
end

local function toolBelongsToLocalPlayer() -- 1 equivalent call inferred from this helper
	local character = LocalPlayer.Character
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	return character and parent:IsDescendantOf(character) or backpack and parent:IsDescendantOf(backpack)
end

if ClearFreePushToolIndicators then
	ClearFreePushToolIndicators.OnClientEvent:Connect(deactivateToolUI)
end

parent.Destroying:Connect(deactivateToolUI)

parent.AncestryChanged:Connect(function()
	if not toolBelongsToLocalPlayer() then -- inferred equivalent call
		deactivateToolUI() -- inferred equivalent call
	end
end)

RunService.Heartbeat:Connect(function()
	if not v then
		return
	end

	local now = tick()

	if now - v3 >= 0.75 then
		v3 = now
		refreshPushIndicators()
	end
end)