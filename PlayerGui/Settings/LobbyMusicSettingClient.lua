local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local list = script.Parent:WaitForChild("Settings"):WaitForChild("Center"):WaitForChild("Body"):WaitForChild("Audio"):WaitForChild("List")
local remotes = Workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local savePianoUserSettings = remotes:WaitForChild("SavePianoUserSettings")
local getPianoUserSettings = remotes:WaitForChild("GetPianoUserSettings")
local pianoUserSettingsLoaded = remotes:WaitForChild("PianoUserSettingsLoaded")

local lobbyMusicVolume = math.clamp(math.floor(tonumber(LocalPlayer:GetAttribute("LobbyMusicVolume")) or 100), 0, 100)
local v = false
local parent = nil
local fill = nil
local knob = nil
local count = 0

local function getLobbySound()
	local lobby = Workspace:FindFirstChild("Lobby")
	local spectatorArea = lobby and lobby:FindFirstChild("Spectator Area")
	local podium2 = spectatorArea and spectatorArea:FindFirstChild("Podium2")
	local soundPart = podium2 and podium2:FindFirstChild("SoundPart")
	local audio = soundPart and soundPart:FindFirstChild("Audio")
	return if audio and audio:IsA("Sound") then audio else nil
end

local function applyVolume()
	lobbyMusicVolume = math.clamp(math.floor(tonumber(lobbyMusicVolume) or 100), 0, 100)
	LocalPlayer:SetAttribute("LobbyMusicVolume", lobbyMusicVolume)
	local lobbySound = getLobbySound()

	if lobbySound then
		lobbySound.Volume = lobbyMusicVolume / 100
	end

	if parent then
		parent.Text = tostring(lobbyMusicVolume) .. "%"
	end

	local v2 = lobbyMusicVolume / 100

	if fill then
		fill.Size = UDim2.new(v2, 0, 1, 0)
	end

	if knob then
		knob.Position = UDim2.new(v2, 0, 0.5, 0)
	end
end

local function saveVolume() -- 1 equivalent call inferred from this helper
	count += 1
	local v2 = count
	task.delay(0.25, function()
		if v2 ~= count then
			return
		end

		savePianoUserSettings:FireServer({ LobbyMusicVolume = lobbyMusicVolume })
	end)
end

local function createRow()
	local lobbyMusicVolumeRow = list:FindFirstChild("LobbyMusicVolumeRow") or Instance.new("Frame")
	lobbyMusicVolumeRow.Name = "LobbyMusicVolumeRow"
	lobbyMusicVolumeRow.Parent = list
	lobbyMusicVolumeRow.LayoutOrder = 1
	lobbyMusicVolumeRow.Size = UDim2.new(1, -8, 0, 76)
	lobbyMusicVolumeRow.BackgroundColor3 = Color3.fromRGB(36, 41, 46)
	lobbyMusicVolumeRow.BorderSizePixel = 0
	local uiCorner = lobbyMusicVolumeRow:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = lobbyMusicVolumeRow

	local label = lobbyMusicVolumeRow:FindFirstChild("Label") or Instance.new("TextLabel")
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 14, 0, 16)
	label.Size = UDim2.new(1, -92, 0, 22)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = "Lobby Music Volume"
	label.TextColor3 = Color3.fromRGB(240, 242, 246)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = lobbyMusicVolumeRow

	local description = lobbyMusicVolumeRow:FindFirstChild("Description") or Instance.new("TextLabel")
	description.Name = "Description"
	description.AnchorPoint = Vector2.new(0, 0.5)
	description.Position = UDim2.new(0, 14, 0, 38)
	description.Size = UDim2.new(1, -28, 0, 18)
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.Gotham
	description.Text = "Set to 0% to mute lobby music"
	description.TextColor3 = Color3.fromRGB(160, 166, 180)
	description.TextSize = 12
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextTruncate = Enum.TextTruncate.AtEnd
	description.Parent = lobbyMusicVolumeRow

	parent = lobbyMusicVolumeRow:FindFirstChild("Value") or Instance.new("TextLabel")
	parent.Name = "Value"
	parent.AnchorPoint = Vector2.new(1, 0.5)
	parent.Position = UDim2.new(1, -12, 0, 16)
	parent.Size = UDim2.new(0, 58, 0, 24)
	parent.BackgroundColor3 = Color3.fromRGB(48, 54, 62)
	parent.BorderSizePixel = 0
	parent.Font = Enum.Font.GothamBold
	parent.TextColor3 = Color3.fromRGB(245, 247, 250)
	parent.TextSize = 13
	parent.Parent = lobbyMusicVolumeRow
	local uiCorner2 = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 4)
	uiCorner2.Parent = parent

	local sliderTrack = lobbyMusicVolumeRow:FindFirstChild("SliderTrack") or Instance.new("TextButton")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
	sliderTrack.Position = UDim2.new(0, 14, 1, -15)
	sliderTrack.Size = UDim2.new(1, -28, 0, 8)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(24, 27, 31)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.AutoButtonColor = false
	sliderTrack.ClipsDescendants = false
	sliderTrack.Text = ""
	sliderTrack.ZIndex = math.max(lobbyMusicVolumeRow.ZIndex + 1, 2)
	sliderTrack.Parent = lobbyMusicVolumeRow
	local uiCorner3 = sliderTrack:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 4)
	uiCorner3.Parent = sliderTrack

	fill = sliderTrack:FindFirstChild("Fill") or Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
	fill.BorderSizePixel = 0
	fill.Position = UDim2.fromScale(0, 0)
	fill.ZIndex = sliderTrack.ZIndex + 1
	fill.Parent = sliderTrack
	local uiCorner4 = fill:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner4.CornerRadius = UDim.new(0, 4)
	uiCorner4.Parent = fill

	knob = sliderTrack:FindFirstChild("Knob") or Instance.new("TextButton")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.BackgroundColor3 = Color3.fromRGB(235, 238, 242)
	knob.BorderSizePixel = 0
	knob.AutoButtonColor = true
	knob.Text = ""
	knob.ZIndex = sliderTrack.ZIndex + 2
	knob.Parent = sliderTrack
	local uiCorner5 = knob:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner5.CornerRadius = UDim.new(0, 9)
	uiCorner5.Parent = knob

	local function setVolumeFromX(x) -- 2 equivalent calls inferred from this helper
		lobbyMusicVolume = math.floor(math.clamp(
			(x - sliderTrack.AbsolutePosition.X) / math.max(sliderTrack.AbsoluteSize.X, 1),
			0,
			1
		) * 100 + 0.5)
		applyVolume()
		saveVolume() -- inferred equivalent call
	end

	local function beginInput(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			v = true
			setVolumeFromX(p.Position.X) -- inferred equivalent call
		end
	end

	sliderTrack.InputBegan:Connect(beginInput)
	knob.InputBegan:Connect(beginInput)
	UserInputService.InputChanged:Connect(function(input)
		if
			v
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			setVolumeFromX(input.Position.X) -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v = false
		end
	end)

	applyVolume()
end

local function applySettings(result) -- 1 equivalent call inferred from this helper
	if typeof(result) == "table" and result.LobbyMusicVolume ~= nil then
		lobbyMusicVolume = math.clamp(math.floor(tonumber(result.LobbyMusicVolume) or 100), 0, 100)
		applyVolume()
	end
end

createRow()
pianoUserSettingsLoaded.OnClientEvent:Connect(applySettings)

task.spawn(function()
	local success, result = pcall(function()
		return getPianoUserSettings:InvokeServer()
	end)

	if success then
		applySettings(result) -- inferred equivalent call
	end
end)