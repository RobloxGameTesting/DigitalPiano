local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local udim = UDim2.new(0.5, 0, 0, 40)
local udim2 = UDim2.new(0.5, 0, 0, -110)

local otherPianoVolume = tonumber(LocalPlayer:GetAttribute("OtherPianoVolume"))
local otherPianoVolume3 = math.clamp(
	math.floor((otherPianoVolume == nil and (LocalPlayer:GetAttribute("MuteOtherPianos") == true and 0 or 100) or otherPianoVolume) + 0.5),
	0,
	100
)

local pianoSettingsToastGui = nil
local v = nil
local v2 = nil
local v3 = false
local v4 = false
local count = 0
local v5 = os.clock() + 35
local savePianoUserSettings = nil

local function playClickSound()
	local soundFX = ReplicatedStorage:FindFirstChild("SoundFX")
	local clickSound2 = soundFX and soundFX:FindFirstChild("ClickSound2")

	if clickSound2 and clickSound2:IsA("Sound") then
		pcall(function()
			clickSound2:Play()
		end)
	end
end

local function setButtonText(button, text)
	if not button then
		return
	end

	local textLabel = button:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		if button:IsA("TextButton") then
			button.Text = ""
			button.TextTransparency = 1
		end

		textLabel.Text = text
	elseif button:IsA("TextButton") then
		button.Text = text
		button.TextTransparency = 0
	end
end

local function getRemotes() -- 2 equivalent calls inferred from this helper
	local piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)

	if piano_Dependencies then
		return piano_Dependencies:WaitForChild("Remotes", 10)
	end

	return nil
end

local function getSavePianoUserSettings() -- 1 equivalent call inferred from this helper
	if savePianoUserSettings and savePianoUserSettings.Parent then
		return savePianoUserSettings
	end

	local remotes = getRemotes() -- inferred equivalent call
	savePianoUserSettings = remotes and remotes:WaitForChild("SavePianoUserSettings", 10)
	return savePianoUserSettings
end

local function cancelTween() -- 2 equivalent calls inferred from this helper
	if v2 then
		v2:Cancel()
		v2 = nil
	end
end

local function readVolumeFromSettings(result) -- 1 equivalent call inferred from this helper
	if typeof(result) ~= "table" then
		return nil
	end

	if result.OtherPianoVolume ~= nil then
		return (math.clamp(math.floor(tonumber(result.OtherPianoVolume) or 100), 0, 100))
	end

	if typeof(result.MuteOtherPianos) ~= "boolean" then
		return nil
	end

	return if result.MuteOtherPianos then 0 else 100
end

local function applyRuntimeVolume(p, p2) -- 1 equivalent call inferred from this helper
	otherPianoVolume3 = math.clamp(math.floor(tonumber(p) or 100), 0, 100)
	LocalPlayer:SetAttribute("OtherPianoVolume", otherPianoVolume3)
	LocalPlayer:SetAttribute("MuteOtherPianos", otherPianoVolume3 <= 0)

	if p2 then
		local savePianoUserSettings2 = getSavePianoUserSettings() -- inferred equivalent call

		if savePianoUserSettings2 then
			savePianoUserSettings2:FireServer({
				OtherPianoVolume = otherPianoVolume3,
				MuteOtherPianos = otherPianoVolume3 <= 0
			})
		end
	end
end

local function hideToast()
	if not (v and v.Visible) then
		return
	end

	local v6 = v
	cancelTween() -- inferred equivalent call
	v2 = TweenService:Create(v6, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = udim2
	})

	v2.Completed:Connect(function()
		if v == v6 then
			v6.Visible = false
		end
	end)
	v2:Play()
end

local function ensureToast()
	if v and v.Parent then
		return v
	end

	pianoSettingsToastGui = PlayerGui:FindFirstChild("PianoSettingsToastGui")

	if not pianoSettingsToastGui then
		pianoSettingsToastGui = Instance.new("ScreenGui")
		pianoSettingsToastGui.Name = "PianoSettingsToastGui"
		pianoSettingsToastGui.ResetOnSpawn = false
		pianoSettingsToastGui.IgnoreGuiInset = true
		pianoSettingsToastGui.DisplayOrder = 12000
		pianoSettingsToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		pcall(function()
			pianoSettingsToastGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
			pianoSettingsToastGui.ClipToDeviceSafeArea = true
		end)
		pianoSettingsToastGui.Parent = PlayerGui
	end

	local ui = ReplicatedStorage:WaitForChild("UI", 10)
	local offlineGiftPanelTemplate = ui and ui:WaitForChild("OfflineGiftPanelTemplate", 10)
	local toast = offlineGiftPanelTemplate and offlineGiftPanelTemplate:FindFirstChild("Toast")

	if not (toast and toast:IsA("GuiObject")) then
		return nil
	end

	local otherPianoMutedToast = pianoSettingsToastGui:FindFirstChild("OtherPianoMutedToast")

	if otherPianoMutedToast then
		otherPianoMutedToast:Destroy()
	end

	local otherPianoMutedToast2 = toast:Clone()
	otherPianoMutedToast2.Name = "OtherPianoMutedToast"
	otherPianoMutedToast2.Visible = false
	otherPianoMutedToast2.Position = udim2
	otherPianoMutedToast2.Parent = pianoSettingsToastGui
	v = otherPianoMutedToast2

	local message = otherPianoMutedToast2:FindFirstChild("Message")

	if message and message:IsA("TextLabel") then
		message.Text = "Other players' pianos are muted for you"
	end

	local actionButton = otherPianoMutedToast2:FindFirstChild("ActionButton")

	if actionButton and actionButton:IsA("TextButton") then
		setButtonText(actionButton, "Restore 100%")
		actionButton.MouseButton1Click:Connect(function()
			playClickSound()
			v4 = true
			applyRuntimeVolume(100, true)
			hideToast()
		end)
	end

	local close = otherPianoMutedToast2:FindFirstChild("Close")

	if close and close:IsA("TextButton") then
		close.MouseButton1Click:Connect(function()
			playClickSound()
			v4 = true
			hideToast()
		end)
	end

	return otherPianoMutedToast2
end

local function showToast()
	if v4 or v3 or otherPianoVolume3 > 0 then
		return
	end

	local toast = ensureToast()

	if not toast then
		return
	end

	v3 = true
	cancelTween() -- inferred equivalent call
	toast.Position = udim2
	toast.Visible = true
	v2 = TweenService:Create(toast, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = udim
	})

	v2:Play()

	task.delay(12, function()
		if v == toast and toast.Visible and otherPianoVolume3 <= 0 and not v4 then
			hideToast()
		end
	end)
end

local function queueToastCheck(value, p) -- 2 equivalent calls inferred from this helper
	count += 1
	local v6 = count
	task.delay(value or 0, function()
		if v6 ~= count then
			return
		end

		if p or os.clock() <= v5 then
			showToast()
		end
	end)
end

local function syncFromAttributes(p)
	local otherPianoVolume2 = tonumber(LocalPlayer:GetAttribute("OtherPianoVolume"))

	if otherPianoVolume2 == nil then
		if LocalPlayer:GetAttribute("MuteOtherPianos") == true then
			otherPianoVolume3 = 0
		end
	else
		otherPianoVolume3 = math.clamp(math.floor(otherPianoVolume2 + 0.5), 0, 100)
	end

	if not (otherPianoVolume3 <= 0) then
		hideToast()

		return
	end

	queueToastCheck(1, p == true) -- inferred equivalent call
end

LocalPlayer:GetAttributeChangedSignal("OtherPianoVolume"):Connect(function()
	syncFromAttributes(false)
end)

LocalPlayer:GetAttributeChangedSignal("MuteOtherPianos"):Connect(function()
	syncFromAttributes(false)
end)

task.defer(function()
	syncFromAttributes(false)
end)

task.spawn(function()
	local remotes = getRemotes() -- inferred equivalent call
	local getPianoUserSettings = remotes and remotes:WaitForChild("GetPianoUserSettings", 10)

	if not getPianoUserSettings then
		return
	end

	local success, result = pcall(function()
		return getPianoUserSettings:InvokeServer()
	end)

	if not success then
		return
	end

	local volumeFromSettings = readVolumeFromSettings(result) -- inferred equivalent call

	if volumeFromSettings == nil then
		return
	end

	applyRuntimeVolume(volumeFromSettings) -- inferred equivalent call

	if volumeFromSettings <= 0 then
		queueToastCheck(1.5, true) -- inferred equivalent call
	end
end)