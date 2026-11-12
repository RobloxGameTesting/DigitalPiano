local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Piano_Dependencies = workspace:WaitForChild("Piano_Dependencies")
local dependencies = Piano_Dependencies:WaitForChild("Modules"):WaitForChild("Dependencies")
local Remotes = Piano_Dependencies:WaitForChild("Remotes")

local SoundEffects = require(dependencies:WaitForChild("SoundEffects"))
local PlayerVariables = require(dependencies:WaitForChild("PlayerVariables"))

local GetPianoUserSettings = Remotes:WaitForChild("GetPianoUserSettings")
local SavePianoUserSettings = Remotes:WaitForChild("SavePianoUserSettings")
local PianoUserSettingsLoaded = Remotes:WaitForChild("PianoUserSettingsLoaded")
local SyncPianoSoundEffectsState = Remotes:WaitForChild("SyncPianoSoundEffectsState")

local parent = script.Parent
local soundEffects = parent.Parent:WaitForChild("OptionFrame"):WaitForChild("SoundEffects")
local close = parent:WaitForChild("Close")
local resetDefaults = parent:WaitForChild("ResetDefaults")
local presetsToggle = parent:WaitForChild("PresetsToggle")
local effectRack = parent:WaitForChild("EffectRack")
local presetBoard = parent:WaitForChild("PresetBoard")
local presetSets = presetBoard:WaitForChild("PresetSets")
local customInspector = parent:WaitForChild("CustomInspector")
local customSets = customInspector:WaitForChild("CustomSets")
local chainRail = parent:WaitForChild("ChainRail")
local globalStrip = parent:WaitForChild("GlobalStrip")
local powerToggle = globalStrip:WaitForChild("PowerToggle")
local effectToggle = customInspector:WaitForChild("EffectToggle")
local pitchTrack = globalStrip:WaitForChild("PitchTrack")
local wetTrack = globalStrip:WaitForChild("WetTrack")
local pitchValue = globalStrip:FindFirstChild("PitchValue")
local wetValue = globalStrip:FindFirstChild("WetValue")
local userPresets = parent:WaitForChild("UserPresets")
local presetNameBox = userPresets:WaitForChild("PresetNameBox")
local saveCurrent = userPresets:WaitForChild("SaveCurrent")
local loadPreset = userPresets:WaitForChild("LoadPreset")
local deletePreset = userPresets:WaitForChild("DeletePreset")
local presetCount = userPresets:WaitForChild("PresetCount")
local presetList = userPresets:WaitForChild("PresetList")
local presetTemplate = presetList:WaitForChild("PresetTemplate")
local emptyState = userPresets:WaitForChild("EmptyState")
local importPreset = userPresets:WaitForChild("ImportPreset")
local exportPreset = userPresets:WaitForChild("ExportPreset")
local presetCodePanel = userPresets:WaitForChild("PresetCodePanel")
local presetCodeBox = presetCodePanel:WaitForChild("PresetCodeBox")
local applyImport = presetCodePanel:WaitForChild("ApplyImport")
local selectCode = presetCodePanel:WaitForChild("SelectCode")
local closeCode = presetCodePanel:WaitForChild("CloseCode")
local modeLabel = presetCodePanel:WaitForChild("ModeLabel")
local status = presetCodePanel:WaitForChild("Status")

local color = Color3.fromRGB(45, 118, 235)
local color2 = Color3.fromRGB(34, 39, 49)
local color3 = Color3.fromRGB(34, 70, 58)
local color4 = Color3.fromRGB(64, 207, 124)
local color5 = Color3.fromRGB(77, 84, 96)
local color6 = Color3.fromRGB(45, 118, 235)
local color7 = Color3.fromRGB(50, 55, 65)
local color8 = Color3.fromRGB(43, 48, 58)
local color9 = Color3.fromRGB(57, 38, 45)
local color10 = Color3.fromRGB(130, 138, 152)
local color11 = Color3.fromRGB(232, 236, 244)
local color12 = Color3.fromRGB(255, 187, 196)
local udim = UDim2.fromOffset(680, 390)
local udim2 = UDim2.fromOffset(680, 480)
local udim3 = UDim2.fromOffset(680, 554)
local udim4 = UDim2.fromOffset(648, 80)
local udim5 = UDim2.fromOffset(648, 154)
local udim6 = UDim2.fromOffset(16, 398)
local udim7 = UDim2.fromOffset(16, 384)
local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local udim8 = UDim2.fromOffset(23, 3)
local udim9 = UDim2.fromOffset(3, 3)

local v = {
	Pitch = { Min = 0.5, Max = 2, Step = 0.01 },
	Wet = { Min = 0, Max = 1, Step = 0.01 }
}

local v2 = SoundEffects.NormalizeState(PlayerVariables.Current_SoundEffects)
local selectedEffect = v2.SelectedEffect
local soundEffectPresets2 = SoundEffects.NormalizeUserPresets({})
local userPresetLimits = SoundEffects.GetUserPresetLimits()
local id = nil
local v3 = false
local visible = false
local v4 = "Closed"
local v5 = {}
local count = 0
local count2 = 0
local v6 = nil
local v7 = nil
local updateUI

local function connect(button, onActivated) -- 15 equivalent calls inferred from this helper
	if button and button:IsA("GuiButton") then
		button.Activated:Connect(onActivated)
	end
end

local function setToggle(instance, enabled) -- 2 equivalent calls inferred from this helper
	instance:SetAttribute("Enabled", enabled)
	instance.BackgroundColor3 = enabled and color6 or color7
	local knob = instance:FindFirstChild("Knob")

	if knob then
		knob.Position = enabled and udim8 or udim9
	end
end

local function getEffectName(frame) -- 4 equivalent calls inferred from this helper
	return frame and frame:GetAttribute("EffectName")
end

local function getCustomDefinition(p) -- 1 equivalent call inferred from this helper
	if not v5[p] then
		v5[p] = SoundEffects.GetCustomDefinitions(p)
	end

	return v5[p]
end

local function getSettingDefinition(effectName, settingName) -- 2 equivalent calls inferred from this helper
	local customDefinition = getCustomDefinition(effectName) -- inferred equivalent call
	return customDefinition and customDefinition.Settings and customDefinition.Settings[settingName]
end

local function roundToStep(p, step) -- 3 equivalent calls inferred from this helper
	local v8 = tonumber(step) or 0

	if v8 <= 0 then
		return p
	end

	return math.floor(p / v8 + 0.5) * v8
end

local function formatNumber(p) -- 1 equivalent call inferred from this helper
	local v8 = tonumber(p) or 0

	if math.abs(v8 - math.floor(v8 + 0.5)) < 0.001 then
		return (tostring((math.floor(v8 + 0.5))))
	end

	return string.format("%.2f", v8)
end

local function setTrackVisual(instance, p, min, max)
	local v8 = not (min < max) and 0 or math.clamp((p - min) / (max - min), 0, 1)

	local fill = instance:FindFirstChild("Fill")

	if fill and fill:IsA("GuiObject") then
		fill.Size = UDim2.fromScale(v8, 1)
	end

	local thumb = instance:FindFirstChild("Thumb")

	if thumb and thumb:IsA("GuiObject") then
		thumb.Position = UDim2.fromScale(v8, 0.5)
	end
end

local function syncLocalState() -- 1 equivalent call inferred from this helper
	PlayerVariables.Current_SoundEffects = v2
	LocalPlayer:SetAttribute("PianoSoundEffects", SoundEffects.EncodeState(v2))
end

local function findUserPresetIndex(value)
	if type(value) ~= "string" then
		return nil, nil
	end

	for i, v8 in ipairs(soundEffectPresets2) do
		if v8.Id == value then
			return i, v8
		end
	end

	return nil, nil
end

local function sendSettings(p)
	local v8 = {
		SoundEffects = SoundEffects.NormalizeState(v2)
	}

	if p or v3 then
		soundEffectPresets2 = SoundEffects.NormalizeUserPresets(soundEffectPresets2)
		v8.SoundEffectPresets = soundEffectPresets2
	end

	SavePianoUserSettings:FireServer(v8)
end

local function scheduleSoundEffectsStateSync() -- 1 equivalent call inferred from this helper
	count2 += 1
	local v8 = count2
	task.delay(0.12, function()
		if v8 ~= count2 then
			return
		end

		local encodeState = SoundEffects.EncodeState(v2)

		if encodeState == v6 then
			return
		end

		v6 = encodeState

		SyncPianoSoundEffectsState:FireServer(encodeState)
	end)
end

local function scheduleSave(p) -- 13 equivalent calls inferred from this helper
	count += 1
	local v8 = count
	task.delay(0.35, function()
		if v8 ~= count then
			return
		end

		sendSettings(p == true)
	end)
end

local function applyState(p, p2) -- 12 equivalent calls inferred from this helper
	v2 = SoundEffects.NormalizeState(p)
	selectedEffect = v2.SelectedEffect
	syncLocalState() -- inferred equivalent call
	scheduleSoundEffectsStateSync() -- inferred equivalent call

	if updateUI then
		updateUI()
	end

	if p2 then
		scheduleSave(nil) -- inferred equivalent call
	end
end

local function setPresetActionState(p) -- 1 equivalent call inferred from this helper
	loadPreset.Active = p
	loadPreset.AutoButtonColor = p
	loadPreset.BackgroundColor3 = p and color2 or color8
	loadPreset.TextColor3 = p and color11 or color10

	deletePreset.Active = p
	deletePreset.AutoButtonColor = p
	deletePreset.BackgroundColor3 = p and color9 or color8
	deletePreset.TextColor3 = p and color12 or color10

	exportPreset.Active = p
	exportPreset.AutoButtonColor = p
	exportPreset.BackgroundColor3 = p and color2 or color8
	exportPreset.TextColor3 = p and color11 or color10
end

local renderUserPresets

local function clearRenderedUserPresets()
	for _, button in ipairs(presetList:GetChildren()) do
		if button:IsA("TextButton") and button ~= presetTemplate then
			button:Destroy()
		end
	end
end

local function clearSelectedUserPreset(p)
	id = nil

	if p then
		presetNameBox.Text = ""
	end

	renderUserPresets()
end

renderUserPresets = function()
	soundEffectPresets2 = SoundEffects.NormalizeUserPresets(soundEffectPresets2)
	local v8 = id
	local v9

	if type(v8) == "string" then
		for _, v10 in ipairs(soundEffectPresets2) do
			if v10.Id == v8 then
				v9 = v10
				break
			end
		end
	end

	if not v9 then
		id = nil
	end

	presetCount.Text = string.format("%d / %d", #soundEffectPresets2, userPresetLimits.MaxPresets)
	presetCount.TextColor3 = #soundEffectPresets2 >= userPresetLimits.MaxPresets and color12 or color10
	emptyState.Visible = #soundEffectPresets2 == 0
	clearRenderedUserPresets()

	for i, v10 in ipairs(soundEffectPresets2) do
		local clone = presetTemplate:Clone()
		clone.Name = "Preset_" .. tostring(i)
		clone.LayoutOrder = i
		clone.Visible = true
		clone:SetAttribute("PresetId", v10.Id)
		clone.Text = v10.Name
		clone.BackgroundColor3 = v10.Id == id and color or color2
		clone.TextColor3 = color11
		clone.Parent = presetList

		local function fn()
			if id == v10.Id then
				id = nil

				presetNameBox.Text = ""
			else
				id = v10.Id
				presetNameBox.Text = v10.Name
			end

			renderUserPresets()
		end

		connect(clone, fn) -- inferred equivalent call
	end

	setPresetActionState(id ~= nil) -- inferred equivalent call
end

local function getPresetNameInput(name) -- 1 equivalent call inferred from this helper
	local text = tostring(presetNameBox.Text or "")
	return if string.match(text, "^%s*$") then name else text
end

local function saveCurrentUserPreset()
	soundEffectPresets2 = SoundEffects.NormalizeUserPresets(soundEffectPresets2)
	local v8 = id
	local v9, v10

	if type(v8) == "string" then
		for i, v11 in ipairs(soundEffectPresets2) do
			if v11.Id == v8 then
				v9, v10 = i, v11 -- parallel
				break
			end
		end
	end

	local presetNameInput = getPresetNameInput(v10 and v10.Name or selectedEffect .. " Preset") -- inferred equivalent call
	local v11

	if v9 == nil then
		v11 = false
	else
		v11 = presetNameInput == v10.Name
	end

	if v11 then
		local userPreset = SoundEffects.NormalizeUserPreset({
			Id = v10.Id,
			Name = presetNameInput,
			State = v2,
			CreatedAt = v10.CreatedAt,
			UpdatedAt = os.time()
		}, v9)

		soundEffectPresets2[v9] = userPreset
		id = userPreset.Id
	else
		if #soundEffectPresets2 >= userPresetLimits.MaxPresets then
			renderUserPresets()
			return
		end

		local userPreset = SoundEffects.CreateUserPreset(presetNameInput, v2)
		table.insert(soundEffectPresets2, userPreset)
		id = userPreset.Id
	end

	v3 = true
	soundEffectPresets2 = SoundEffects.NormalizeUserPresets(soundEffectPresets2)
	local v12 = id
	local v13

	if type(v12) == "string" then
		for _, v14 in ipairs(soundEffectPresets2) do
			if v14.Id == v12 then
				v13 = v14
				break
			end
		end
	end

	if v13 then
		presetNameBox.Text = v13.Name
	end

	renderUserPresets()
	scheduleSave(true) -- inferred equivalent call
end

local function loadSelectedUserPreset()
	local v8 = id
	local v9

	if type(v8) == "string" then
		for _, v10 in ipairs(soundEffectPresets2) do
			if v10.Id == v8 then
				v9 = v10
				break
			end
		end
	end

	if not v9 then
		renderUserPresets()
		return
	end

	presetNameBox.Text = v9.Name
	applyState(v9.State) -- inferred equivalent call
	scheduleSave(nil) -- inferred equivalent call
end

local function deleteSelectedUserPreset()
	local v8 = id
	local v9

	if type(v8) == "string" then
		for i, v10 in ipairs(soundEffectPresets2) do
			if v10.Id == v8 then
				v9 = i
				break
			end
		end
	end

	if not v9 then
		renderUserPresets()
		return
	end

	table.remove(soundEffectPresets2, v9)
	id = nil
	presetNameBox.Text = ""
	v3 = true
	renderUserPresets()
	scheduleSave(true) -- inferred equivalent call
end

local function applyLoadedUserPresets(soundEffectPresets) -- 2 equivalent calls inferred from this helper
	v3 = true
	soundEffectPresets2 = SoundEffects.NormalizeUserPresets(soundEffectPresets)

	if id then
		local v8 = id
		local v9

		if type(v8) == "string" then
			for i, v10 in ipairs(soundEffectPresets2) do
				if v10.Id == v8 then
					v9 = i
					break
				end
			end
		end

		if not v9 then
			id = nil
		end
	end

	renderUserPresets()
end

local function isCodeModeOpen(): boolean -- 5 equivalent calls inferred from this helper
	return v4 == "Import" or v4 == "Export"
end

local function getPresetPanelSize() -- 1 equivalent call inferred from this helper
	if visible then
		return isCodeModeOpen() and udim3 or udim2 -- inferred equivalent call
	end

	return udim
end

local function getUserPresetPanelSize() -- 1 equivalent call inferred from this helper
	return isCodeModeOpen() and udim5 or udim4 -- inferred equivalent call
end

local function setCodeStatus(value, color13) -- 5 equivalent calls inferred from this helper
	status.Text = value or ""
	status.TextColor3 = color13 or color10
end

local function setUserPresetShelfAlpha(p)
	userPresets.BackgroundTransparency = p
	presetCodePanel.BackgroundTransparency = p

	for _, descendant in ipairs(userPresets:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			descendant.TextTransparency = p
		end

		if descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			descendant.BackgroundTransparency = p
		end

		if descendant:IsA("UIStroke") then
			descendant.Transparency = p
		end
	end
end

local function tweenUserPresetShelfAlpha(p)
	TweenService:Create(userPresets, tweenInfo, { BackgroundTransparency = p }):Play()
	TweenService:Create(presetCodePanel, tweenInfo, { BackgroundTransparency = p }):Play()

	for _, descendant in ipairs(userPresets:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			TweenService:Create(descendant, tweenInfo, { TextTransparency = p }):Play()
		end

		if descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			TweenService:Create(descendant, tweenInfo, { BackgroundTransparency = p }):Play()
		end

		if descendant:IsA("UIStroke") then
			TweenService:Create(descendant, tweenInfo, { Transparency = p }):Play()
		end
	end
end

local function refreshCodePanel()
	local codeModeOpen = isCodeModeOpen() -- inferred equivalent call
	parent:SetAttribute("UserPresetCodeMode", v4)
	presetCodePanel:SetAttribute("Mode", v4)
	presetCodePanel.Visible = visible and codeModeOpen
	applyImport.Visible = v4 == "Import"
	selectCode.Visible = v4 == "Export"
	importPreset.BackgroundColor3 = v4 == "Import" and color or color2
	exportPreset.BackgroundColor3 = v4 == "Export" and color or id and color2 or color8
	modeLabel.Text = v4 == "Export" and "Copy this code to share" or "Paste a preset code to import"
end

local function setUserPresetsOpen(p, p2)
	visible = p == true

	if not visible then
		v4 = "Closed"
	end

	parent:SetAttribute("UserPresetsOpen", visible)
	presetsToggle:SetAttribute("Open", visible)
	presetsToggle.BackgroundColor3 = visible and color or color2
	presetsToggle.TextColor3 = color11
	refreshCodePanel()
	local presetPanelSize = getPresetPanelSize() -- inferred equivalent call
	local userPresetPanelSize = getUserPresetPanelSize() -- inferred equivalent call

	if p2 then
		parent.Size = presetPanelSize
		userPresets.Position = visible and udim7 or udim6
		userPresets.Size = userPresetPanelSize
		userPresets.Visible = visible
		setUserPresetShelfAlpha(visible and 0 or 1)
	else
		if visible then
			userPresets.Visible = true
			setUserPresetShelfAlpha(1)
		end

		TweenService:Create(parent, tweenInfo, { Size = presetPanelSize }):Play()
		TweenService:Create(userPresets, tweenInfo, {
			Position = visible and udim7 or udim6,
			Size = userPresetPanelSize
		}):Play()
		tweenUserPresetShelfAlpha(visible and 0 or 1)

		if not visible then
			task.delay(tweenInfo.Time, function()
				if not visible then
					userPresets.Visible = false
					presetCodePanel.Visible = false
				end
			end)
		end
	end
end

local function setPresetCodeMode(p, p2) -- 1 equivalent call inferred from this helper
	if p == "Import" or p == "Export" then
		v4 = p
		visible = true

		if v4 == "Import" then
			presetCodeBox.Text = ""
			setCodeStatus(nil, color10) -- inferred equivalent call
		end
	else
		v4 = "Closed"
		setCodeStatus(nil, color10) -- inferred equivalent call
	end

	refreshCodePanel()
	setUserPresetsOpen(visible, p2)
end

local function exportSelectedUserPreset()
	local v8 = id
	local v9

	if type(v8) == "string" then
		for _, v10 in ipairs(soundEffectPresets2) do
			if v10.Id == v8 then
				v9 = v10
				break
			end
		end
	end

	if not v9 then
		renderUserPresets()
		return
	end

	local encodeUserPreset = SoundEffects.EncodeUserPreset(v9)

	if encodeUserPreset == "" then
		v4 = "Export"
		visible = true

		if v4 == "Import" then
			presetCodeBox.Text = ""
			setCodeStatus(nil, color10) -- inferred equivalent call
		end

		refreshCodePanel()
		setUserPresetsOpen(visible, false)
		status.Text = "Export failed"
		status.TextColor3 = color12 or color10
	else
		presetCodeBox.Text = encodeUserPreset
		v4 = "Export"
		visible = true

		if v4 == "Import" then
			presetCodeBox.Text = ""
			setCodeStatus(nil, color10) -- inferred equivalent call
		end

		refreshCodePanel()
		setUserPresetsOpen(visible, false)
		status.Text = "Ready"
		status.TextColor3 = color4 or color10
	end
end

local function importUserPresetCode()
	local decodeUserPreset = SoundEffects.DecodeUserPreset(presetCodeBox.Text)

	if decodeUserPreset then
		soundEffectPresets2 = SoundEffects.NormalizeUserPresets(soundEffectPresets2)

		if #soundEffectPresets2 >= userPresetLimits.MaxPresets then
			status.Text = "List full"
			status.TextColor3 = color12 or color10
		else
			table.insert(soundEffectPresets2, decodeUserPreset)
			soundEffectPresets2 = SoundEffects.NormalizeUserPresets(soundEffectPresets2)
			local v8 = soundEffectPresets2[#soundEffectPresets2]

			if v8 then
				id = v8.Id
				presetNameBox.Text = v8.Name
			end

			v3 = true
			renderUserPresets()
			status.Text = "Imported"
			status.TextColor3 = color4 or color10
			scheduleSave(true) -- inferred equivalent call
		end
	else
		status.Text = "Invalid code"
		status.TextColor3 = color12 or color10
	end
end

local function selectPresetCodeText()
	if presetCodeBox.Text == "" then
		return
	end

	presetCodeBox:CaptureFocus()
	task.defer(function()
		presetCodeBox.CursorPosition = #presetCodeBox.Text + 1
		presetCodeBox.SelectionStart = 1
	end)
	status.Text = "Selected"
	status.TextColor3 = color4 or color10
end

local function getEffectActive(effectName) -- 2 equivalent calls inferred from this helper
	local effectActive

	if v2.Power == true then
		effectActive = v2.CustomEnabled[effectName] == true or v2.Presets[effectName] ~= "Off"
	else
		effectActive = false
	end

	return effectActive
end

local function updateEffectSelection(effectName, p) -- 1 equivalent call inferred from this helper
	if not effectName then
		return
	end

	v2.SelectedEffect = effectName
	applyState(v2) -- inferred equivalent call

	if p then
		scheduleSave(nil) -- inferred equivalent call
	end
end

local function setPreset(selectedEffect2, p)
	if not (selectedEffect2 and p) then
		return
	end

	v2.SelectedEffect = selectedEffect2
	v2.Presets[selectedEffect2] = p
	v2.CustomEnabled[selectedEffect2] = false

	if p ~= "Off" then
		v2.Power = true
	end

	applyState(v2) -- inferred equivalent call
	scheduleSave(nil) -- inferred equivalent call
end

local function setGlobalValue(p, value) -- 2 equivalent calls inferred from this helper
	local v8 = v[p]

	if not v8 then
		return
	end

	v2[p] = roundToStep(math.clamp(value, v8.Min, v8.Max), v8.Step) -- inferred equivalent call

	if p == "Pitch" and math.abs(v2.Pitch - 1) > 0.001 then
		v2.Power = true
	elseif p == "Wet" and v2.Wet > 0 then
		v2.Power = true
	end

	applyState(v2) -- inferred equivalent call
	scheduleSave(nil) -- inferred equivalent call
end

local function setCustomValue(effectName, settingName, value)
	local settingDefinition = getSettingDefinition(effectName, settingName) -- inferred equivalent call

	if not settingDefinition then
		return
	end

	v2.SelectedEffect = effectName
	v2.Custom[effectName] = v2.Custom[effectName] or {}
	local v8 = v2.Custom[effectName]
	v8[settingName] = roundToStep( -- inferred equivalent call
		math.clamp(value, settingDefinition.Min, settingDefinition.Max),
		settingDefinition.Step
	)
	v2.CustomEnabled[effectName] = true
	v2.Power = true
	applyState(v2) -- inferred equivalent call
	scheduleSave(nil) -- inferred equivalent call
end

local function valueFromInput(track, p, definition) -- 1 equivalent call inferred from this helper
	local v8 = math.clamp((p.Position.X - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
	return roundToStep(definition.Min + (definition.Max - definition.Min) * v8, definition.Step) -- inferred equivalent call
end

local function updateDrag(p) -- 2 equivalent calls inferred from this helper
	if not v7 then
		return
	end

	local v8 = valueFromInput(v7.Track, p, v7.Definition) -- inferred equivalent call
	v7.SetValue(v8)
end

local function bindTrack(guiObject, definition, fn)
	if not (guiObject and guiObject:IsA("GuiObject") and definition) then
		return
	end

	guiObject.Active = true
	local thumb = guiObject:FindFirstChild("Thumb")

	if thumb and thumb:IsA("GuiObject") then
		thumb.Active = true
	end

	local function begin(p)
		if p.UserInputType ~= Enum.UserInputType.MouseButton1 and p.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		v7 = { Track = guiObject, Definition = definition, SetValue = fn }
		updateDrag(p) -- inferred equivalent call
	end

	guiObject.InputBegan:Connect(begin)

	if thumb and thumb:IsA("GuiObject") then
		thumb.InputBegan:Connect(begin)
	end
end

UserInputService.InputChanged:Connect(function(input)
	if not v7 then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		updateDrag(input) -- inferred equivalent call
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v7 = nil
	end
end)

updateUI = function()
	selectedEffect = v2.SelectedEffect
	parent:SetAttribute("SelectedEffect", selectedEffect)

	local title = presetBoard:FindFirstChild("Title")

	if title then
		title.Text = selectedEffect .. " Presets"
	end

	local title2 = customInspector:FindFirstChild("Title")

	if title2 then
		title2.Text = selectedEffect .. " Custom"
	end

	setToggle(powerToggle, v2.Power == true) -- inferred equivalent call
	setToggle(effectToggle, v2.CustomEnabled[selectedEffect] == true) -- inferred equivalent call

	for _, button in ipairs(effectRack:GetChildren()) do
		if not (button:IsA("TextButton") and button and button:GetAttribute("EffectName")) then
			continue
		end

		local effectName = getEffectName(button) -- inferred equivalent call
		button.BackgroundColor3 = effectName == selectedEffect and color or color2
		local statusDot = button:FindFirstChild("StatusDot")

		if statusDot then
			statusDot.BackgroundColor3 = getEffectActive(effectName) and color4 or color5 -- inferred equivalent call
		end
	end

	for _, frame in ipairs(presetSets:GetChildren()) do
		if not (frame:IsA("Frame") and frame and frame:GetAttribute("EffectName")) then
			continue
		end

		local effectName = getEffectName(frame) -- inferred equivalent call
		frame.Visible = effectName == selectedEffect

		for _, button in ipairs(frame:GetChildren()) do
			if not (button:IsA("TextButton") and button:GetAttribute("PresetName")) then
				continue
			end

			local v8

			if v2.CustomEnabled[effectName] == true then
				v8 = false
			else
				v8 = v2.Presets[effectName] == button:GetAttribute("PresetName")
			end

			button:SetAttribute("Selected", v8)
			button.BackgroundColor3 = v8 and color or color2
		end
	end

	for _, frame in ipairs(customSets:GetChildren()) do
		if not (frame:IsA("Frame") and frame and frame:GetAttribute("EffectName")) then
			continue
		end

		local effectName = getEffectName(frame) -- inferred equivalent call
		frame.Visible = effectName == selectedEffect

		for _, frame2 in ipairs(frame:GetChildren()) do
			if not (frame2:IsA("Frame") and frame2:GetAttribute("SettingName")) then
				continue
			end

			local settingName = frame2:GetAttribute("SettingName")
			local settingDefinition = getSettingDefinition(effectName, settingName) -- inferred equivalent call

			if not settingDefinition then
				continue
			end

			local v8 = v2.Custom[effectName] and v2.Custom[effectName][settingName] or settingDefinition.Default
			local value = frame2:FindFirstChild("Value")

			if value then
				value.Text = formatNumber(v8) -- inferred equivalent call
			end

			local track = frame2:FindFirstChild("Track")

			if track then
				setTrackVisual(track, v8, settingDefinition.Min, settingDefinition.Max)
			end
		end
	end

	for _, button in ipairs(chainRail:GetChildren()) do
		if not (button:IsA("TextButton") and button and button:GetAttribute("EffectName")) then
			continue
		end

		local effectName = getEffectName(button) -- inferred equivalent call

		if effectName == selectedEffect then
			button.BackgroundColor3 = color
		elseif getEffectActive(effectName) then -- inferred equivalent call
			button.BackgroundColor3 = color3
		else
			button.BackgroundColor3 = color2
		end
	end

	if pitchValue then
		pitchValue.Text = string.format("%.2f", v2.Pitch)
	end

	if wetValue then
		wetValue.Text = tostring((math.floor(v2.Wet * 100 + 0.5))) .. "%"
	end

	setTrackVisual(pitchTrack, v2.Pitch, v.Pitch.Min, v.Pitch.Max)
	setTrackVisual(wetTrack, v2.Wet, v.Wet.Min, v.Wet.Max)
end

connect(soundEffects, function() -- inferred equivalent call
	parent.Visible = not parent.Visible
end)
connect(close, function() -- inferred equivalent call
	parent.Visible = false
end)
local function fn()
	applyState(SoundEffects.GetDefaultState(), nil) -- inferred equivalent call
	scheduleSave(nil) -- inferred equivalent call
end

connect(resetDefaults, fn) -- inferred equivalent call

local function fn2()
	setUserPresetsOpen(not visible, false)
end

connect(presetsToggle, fn2) -- inferred equivalent call

local function fn3()
	setPresetCodeMode(v4 == "Import" and "Closed" or "Import", false) -- inferred equivalent call
end

connect(importPreset, fn3) -- inferred equivalent call
connect(exportPreset, exportSelectedUserPreset) -- inferred equivalent call
connect(applyImport, importUserPresetCode) -- inferred equivalent call
connect(selectCode, selectPresetCodeText) -- inferred equivalent call

local function fn4()
	v4 = "Closed"
	setCodeStatus(nil, color10) -- inferred equivalent call
	refreshCodePanel()
	setUserPresetsOpen(visible, false)
end

connect(closeCode, fn4) -- inferred equivalent call

local function fn5()
	v2.Power = not v2.Power
	applyState(v2) -- inferred equivalent call
	scheduleSave(nil) -- inferred equivalent call
end

connect(powerToggle, fn5) -- inferred equivalent call

local function fn6()
	v2.CustomEnabled[selectedEffect] = not v2.CustomEnabled[selectedEffect]

	if v2.CustomEnabled[selectedEffect] then
		v2.Power = true
	end

	applyState(v2) -- inferred equivalent call
	scheduleSave(nil) -- inferred equivalent call
end

connect(effectToggle, fn6) -- inferred equivalent call
connect(saveCurrent, saveCurrentUserPreset) -- inferred equivalent call
connect(loadPreset, loadSelectedUserPreset) -- inferred equivalent call
connect(deletePreset, deleteSelectedUserPreset) -- inferred equivalent call

for _, button in ipairs(parent:GetDescendants()) do
	if button:IsA("TextButton") and button:GetAttribute("EffectName") and not button:GetAttribute("PresetName") then
		connect(button, function()
			updateEffectSelection(button:GetAttribute("EffectName"), true) -- inferred equivalent call
		end)
	elseif button:IsA("TextButton") and button:GetAttribute("PresetName") then
		connect(button, function()
			local effectName = button:GetAttribute("EffectName")
			local presetName = button:GetAttribute("PresetName")

			if effectName then
				if not presetName then
					return
				end

				v2.SelectedEffect = effectName
				v2.Presets[effectName] = presetName
				v2.CustomEnabled[effectName] = false

				if presetName ~= "Off" then
					v2.Power = true
				end

				applyState(v2) -- inferred equivalent call
				scheduleSave(nil) -- inferred equivalent call
			end
		end)
	end
end

bindTrack(pitchTrack, v.Pitch, function(value)
	setGlobalValue("Pitch", value) -- inferred equivalent call
end)
bindTrack(wetTrack, v.Wet, function(value)
	setGlobalValue("Wet", value) -- inferred equivalent call
end)

for _, frame in ipairs(customSets:GetChildren()) do
	if not (frame:IsA("Frame") and getEffectName(frame)) then
		continue
	end

	local effectName = getEffectName(frame)

	for _, frame2 in ipairs(frame:GetChildren()) do
		if not (frame2:IsA("Frame") and frame2:GetAttribute("SettingName")) then
			continue
		end

		local settingName = frame2:GetAttribute("SettingName")
		local settingDefinition = getSettingDefinition(effectName, settingName)
		bindTrack(frame2:FindFirstChild("Track"), settingDefinition, function(p)
			setCustomValue(effectName, settingName, p)
		end)
	end
end

PianoUserSettingsLoaded.OnClientEvent:Connect(function(p)
	if type(p) ~= "table" then
		return
	end

	if p.SoundEffectPresets ~= nil then
		applyLoadedUserPresets(p.SoundEffectPresets) -- inferred equivalent call
	end

	if p.SoundEffects ~= nil then
		applyState(p.SoundEffects) -- inferred equivalent call
	end
end)

task.spawn(function()
	local success, result = pcall(function()
		return GetPianoUserSettings:InvokeServer()
	end)

	if success and type(result) == "table" then
		if result.SoundEffectPresets ~= nil then
			applyLoadedUserPresets(result.SoundEffectPresets) -- inferred equivalent call
		end

		if result.SoundEffects ~= nil then
			applyState(result.SoundEffects) -- inferred equivalent call
		end
	elseif not success then
		ClientDebugConfig.Warn("[SoundEffectsController] Failed to load settings:", result)
	end
end)

parent.Visible = false
parent.ClipsDescendants = true
renderUserPresets()
visible = false

if not visible then
	v4 = "Closed"
end

parent:SetAttribute("UserPresetsOpen", visible)
presetsToggle:SetAttribute("Open", visible)
local backgroundColor

if visible then
	backgroundColor = color or color2
else
	backgroundColor = color2
end

presetsToggle.BackgroundColor3 = backgroundColor
presetsToggle.TextColor3 = color11
refreshCodePanel()
local size

if visible then
	if isCodeModeOpen() then -- inferred equivalent call
		size = udim3 or udim2
	else
		size = udim2
	end
else
	size = udim
end

local size2

if isCodeModeOpen() then -- inferred equivalent call
	size2 = udim5 or udim4
else
	size2 = udim4
end

parent.Size = size
local position

if visible then
	position = udim7 or udim6
else
	position = udim6
end

userPresets.Position = position
userPresets.Size = size2
userPresets.Visible = visible
setUserPresetShelfAlpha(visible and 0 or 1)
applyState(v2) -- inferred equivalent call