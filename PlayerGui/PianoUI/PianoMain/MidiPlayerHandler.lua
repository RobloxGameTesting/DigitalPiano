local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local OverheadStatusUpdate = ReplicatedStorage:WaitForChild("OverheadStatusUpdate", 10)

local LocalAutoplayStatusChanged = ReplicatedStorage:FindFirstChild("LocalAutoplayStatusChanged")

if not (LocalAutoplayStatusChanged and LocalAutoplayStatusChanged:IsA("BindableEvent")) then
	if LocalAutoplayStatusChanged then
		LocalAutoplayStatusChanged:Destroy()
	end

	LocalAutoplayStatusChanged = Instance.new("BindableEvent")
	LocalAutoplayStatusChanged.Name = "LocalAutoplayStatusChanged"
	LocalAutoplayStatusChanged.Parent = ReplicatedStorage
end

pcall(function()
	LocalAutoplayStatusChanged.Sandboxed = true
end)
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Piano_Dependencies = workspace:WaitForChild("Piano_Dependencies")
local Remotes = Piano_Dependencies:WaitForChild("Remotes")
local Modules = Piano_Dependencies:WaitForChild("Modules")
local Logic = Modules:WaitForChild("Logic")
local Dependencies = Modules:WaitForChild("Dependencies")

local InteractiveMidi = require(ReplicatedStorage:WaitForChild("InteractiveMidi"))
local PianoLogic = require(Logic:WaitForChild("PianoLogic"))
local PlayerVariables = require(Dependencies:WaitForChild("PlayerVariables"))
local Soundfonts = require(Dependencies:WaitForChild("Soundfonts"))
local FetchMidiRemote = Remotes:WaitForChild("FetchMidiRemote", 15)
local GetMidiPlayerAccess = Remotes:WaitForChild("GetMidiPlayerAccess", 15)
local StartMidiPlayerTrial = Remotes:WaitForChild("StartMidiPlayerTrial", 15)
local MidiPlayerAccessUpdated = Remotes:WaitForChild("MidiPlayerAccessUpdated", 15)
local CheckGamepassEntitlement = Remotes:WaitForChild("CheckGamepassEntitlement", 15)

local OpenCommunityMidiUrl = ReplicatedStorage:FindFirstChild("OpenCommunityMidiUrl")

if not (OpenCommunityMidiUrl and OpenCommunityMidiUrl:IsA("BindableEvent")) then
	if OpenCommunityMidiUrl then
		OpenCommunityMidiUrl:Destroy()
	end

	OpenCommunityMidiUrl = Instance.new("BindableEvent")
	OpenCommunityMidiUrl.Name = "OpenCommunityMidiUrl"
	OpenCommunityMidiUrl.Parent = ReplicatedStorage
end

local RefreshCommunityMidiForLoad = ReplicatedStorage:FindFirstChild("RefreshCommunityMidiForLoad")

if not (RefreshCommunityMidiForLoad and RefreshCommunityMidiForLoad:IsA("BindableFunction")) then
	if RefreshCommunityMidiForLoad then
		RefreshCommunityMidiForLoad:Destroy()
	end

	RefreshCommunityMidiForLoad = Instance.new("BindableFunction")
	RefreshCommunityMidiForLoad.Name = "RefreshCommunityMidiForLoad"
	RefreshCommunityMidiForLoad.Parent = ReplicatedStorage
end

local OpenCommunitySheets = ReplicatedStorage:FindFirstChild("OpenCommunitySheets")

if not (OpenCommunitySheets and OpenCommunitySheets:IsA("BindableEvent")) then
	if OpenCommunitySheets then
		OpenCommunitySheets:Destroy()
	end

	OpenCommunitySheets = Instance.new("BindableEvent")
	OpenCommunitySheets.Name = "OpenCommunitySheets"
	OpenCommunitySheets.Parent = ReplicatedStorage
end

local MidiPlayerHandler = {}
local flag = false

local v = {
	{
		name = "O Holy Night",
		url = "https://github.com/JaypeeCabahit/MidiFiles/raw/refs/heads/main/Traditional%20Christmas%20-%20O%20Holy%20Night%20(ver.%202).mid"
	},
	{
		name = "Gravity Falls",
		url = "https://github.com/JaypeeCabahit/MidiFiles/raw/refs/heads/main/Brad%20Breeck%20-%20Gravity%20Falls%20_Main%20Theme.mid"
	},
	{
		name = "Heart and Soul",
		url = "https://github.com/JaypeeCabahit/MidiFiles/raw/refs/heads/main/Heart%20and%20Soul.mid"
	},
	{
		name = "200 Anime Songs by Halcyon",
		url = "https://www.dropbox.com/scl/fi/jbu0kc1b0e5hrrgoda5gu/200_anime_songs.mid?rlkey=yvd2un5irym5lxoysxtmh8f4v&st=ijgiylmk&dl=1"
	},
	{
		name = "Dinner With Luigi",
		url = "https://github.com/JaypeeCabahit/MidiFiles/raw/refs/heads/main/Dinner%20With%20Luigi.mid"
	},
	{
		name = "Canon in D",
		url = "https://github.com/JaypeeCabahit/MidiFiles/raw/refs/heads/main/CanonInD.mid"
	}
}

local function midiNoteToPianoNote(noteNumber) -- 3 equivalent calls inferred from this helper
	local v2 = tonumber(noteNumber)

	if not v2 then
		return nil
	end

	local v3 = v2 - 35
	return if not (v3 < -14 or v3 > 73) then v3 else nil
end

local function formatTime(value) -- 10 equivalent calls inferred from this helper
	local v2 = math.max(0, value or 0)
	return string.format("%d:%02d", math.floor(v2 / 60), (math.floor(v2 % 60)))
end

local function formatSpeed(p) -- 2 equivalent calls inferred from this helper
	return string.format("%.3g", p) .. "x"
end

local function formatTrialTime(p)
	local v2 = math.max(0, (math.floor(tonumber(p) or 0)))
	local v3 = math.floor(v2 / 3600)
	local v4 = math.floor(v2 % 3600 / 60)

	if v3 > 0 then
		return string.format("%dh %02dm", v3, v4)
	end

	return string.format("%dm", v4)
end

local function formatTrialCountdown(p) -- 1 equivalent call inferred from this helper
	local v2 = math.max(0, (math.floor(tonumber(p) or 0)))
	local v3 = math.floor(v2 / 3600)
	local v4 = math.floor(v2 % 3600 / 60)
	local v5 = v2 % 60
	return string.format("%02dh %02dm %02ds", v3, v4, v5)
end

local v2 = nil
local v3 = nil
local v4 = nil
local heartbeatConnection = nil
local v5 = nil
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = 0
local lastTime = nil
local fn
local v10 = {}
local v11 = false
local v12 = 0
local v13 = {}
local v14 = nil
local v15 = nil
local count = 0
local v16 = {
	Active = false,
	Loading = false,
	Playing = false,
	Paused = false,
	Status = "Ready.",
	DisplayName = "MIDI",
	UploadId = "",
	Position = 0,
	Duration = 0,
	SourceLabel = "",
	Source = "",
	Has2DSource = false
}

local function setPreviewState(options)
	local v17 = options or {}

	for k, v18 in pairs(v17) do
		v16[k] = v18
	end

	if v17.SourceLabel ~= nil then
		v16.Source = tostring(v16.SourceLabel or "")
	end

	v16.UpdatedAt = os.clock()
end

local function getLocalHumanoidRootPart()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return nil
	end

	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

	if character then
		return character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 3)
	end

	return nil
end

local function setOverheadStatus(p, p2)
	if v3 and v3.isPracticeMode and v3.isPracticeMode() then
		return
	end

	if p == "Autoplaying" then
		pcall(function()
			LocalAutoplayStatusChanged:Fire(p2 == true, "MidiPlayer")
		end)
	end

	if not OverheadStatusUpdate then
		return
	end

	v13[p] = p2 == true
end

RunService.Heartbeat:Connect(function()
	if not OverheadStatusUpdate or next(v13) == nil then
		return
	end

	local v17 = v13
	v13 = {}

	for k, v18 in pairs(v17) do
		pcall(function()
			OverheadStatusUpdate:FireServer(k, v18)
		end)
	end
end)

local function showMidiOverhead()
	if not (v3 and v3.isPracticeMode and v3.isPracticeMode()) then
		local v17 = true
		pcall(function()
			LocalAutoplayStatusChanged:Fire(v17 == true, "MidiPlayer")
		end)

		if OverheadStatusUpdate then
			v13.Autoplaying = true
		end
	end

	if v4 then
		v4.Parent = nil
		v4 = nil
	end
end

local function hideMidiOverhead() -- 2 equivalent calls inferred from this helper
	if not (v3 and v3.isPracticeMode and v3.isPracticeMode()) then
		local v17 = false
		pcall(function()
			LocalAutoplayStatusChanged:Fire(v17 == true, "MidiPlayer")
		end)

		if OverheadStatusUpdate then
			v13.Autoplaying = false
		end
	end

	if v4 then
		v4.Parent = nil
		v4 = nil
	end
end

local function getCurrentSoundfontPick() -- 2 equivalent calls inferred from this helper
	local current_SoundfontID = PlayerVariables.Current_SoundfontID or 1
	return Soundfonts[current_SoundfontID] or Soundfonts[1]
end

local function playLocalPreviewNote(p, p2)
	local currentSoundfontPick = getCurrentSoundfontPick() -- inferred equivalent call

	if type(currentSoundfontPick) ~= "table" then
		return
	end

	local packetType = tonumber(currentSoundfontPick.PacketType) or 1
	local v17 = PianoLogic[packetType]

	if type(v17) ~= "function" then
		return
	end

	local assetIds = currentSoundfontPick.AssetIds

	if type(assetIds) ~= "table" then
		return
	end

	v17(
		p,
		assetIds,
		tonumber(currentSoundfontPick.Offset) or 0,
		tonumber(currentSoundfontPick.MaxLifetime) or 0.13,
		tonumber(currentSoundfontPick.Fadeout) or 0.15,
		0,
		packetType,
		false,
		false,
		math.clamp(tonumber(p2) or 100, 1, 127),
		tonumber(PlayerVariables.Current_Volume) or 100,
		tonumber(currentSoundfontPick.VolumeModifier) or 1,
		900000 + p,
		false
	)
end

local function finishLocalPreviewNote(p)
	local currentSoundfontPick = getCurrentSoundfontPick() -- inferred equivalent call
	local fadeout = type(currentSoundfontPick) == "table" and tonumber(currentSoundfontPick.Fadeout) or 0.15

	if PianoLogic.FinishNonSustainNote then
		PianoLogic.FinishNonSustainNote(900000 + p, fadeout or 0.15)
	end
end

local previewPlaybackCallbacks = {
	playNote = playLocalPreviewNote,
	finishNote = finishLocalPreviewNote,
	markActivity = function() end,
	setPlaybackMode = function() end,
	isPracticeMode = function(): boolean
		return false
	end
}

local function getPreviewPlaybackCallbacks() -- 1 equivalent call inferred from this helper
	return previewPlaybackCallbacks
end

local function releaseAllNotes() -- 6 equivalent calls inferred from this helper
	for k in pairs(v7) do
		v8[k] = true
	end

	table.clear(v7)
end

local function stopPlayback()
	v9 = 0
	lastTime = nil
	v11 = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if v3 then
		for k in pairs(v7) do
			v3.finishNote(k)
		end

		for k in pairs(v8) do
			v3.finishNote(k)
		end
	end

	table.clear(v7)
	table.clear(v8)
	local v17 = v2
	local v18 = v15
	v2 = nil
	v15 = nil

	if v18 == "CommunityPreview" then
		setPreviewState({
			Active = false,
			Loading = false,
			Playing = false,
			Paused = false,
			Status = "Stopped.",
			Position = 0
		})
	end

	if v17 then
		v10[v17] = true
		v17:Stop()
		task.delay(1, function()
			v10[v17] = nil
		end)
	end

	if v3 and v3.setPlaybackMode then
		v3.setPlaybackMode(false)
	end

	v3 = nil

	if v18 ~= "CommunityPreview" then
		hideMidiOverhead() -- inferred equivalent call
	end
end

local function calcRealDuration(p)
	local loaded = p.Loaded

	if not loaded then
		return p.TimeLength
	end

	local pulsesPerQuarter = loaded.Header and loaded.Header.PulsesPerQuarter

	if not pulsesPerQuarter or pulsesPerQuarter == 0 then
		return p.TimeLength
	end

	local v17 = {
		{ tick = 0, tempo = 500000 }
	}

	for _, list in pairs(loaded.Instructions) do
		for _, item in ipairs(list) do
			if item[1] == "SetTempo" then
				table.insert(v17, { tick = item[2], tempo = item[3] })
			end
		end
	end

	table.sort(v17, function(a, b): boolean
		return a.tick < b.tick
	end)
	local v18 = 0

	for _, list in pairs(loaded.Instructions) do
		for _, item in ipairs(list) do
			if (item[1] == "NoteOn" or item[1] == "NoteOff") and v18 < item[2] then
				v18 = item[2]
			end
		end
	end

	if v18 == 0 then
		return p.TimeLength
	end

	local v19 = 0
	local v20 = 500000
	local total = 0

	for _, v21 in ipairs(v17) do
		if v18 <= v21.tick then
			break
		end

		total += (v21.tick - v19) * v20 / (pulsesPerQuarter * 1000000)
		v19 = v21.tick
		v20 = v21.tempo
	end

	return total + (v18 - v19) * v20 / (pulsesPerQuarter * 1000000)
end

local function groupTimedPresses(list)
	table.sort(list, function(a, b): boolean
		if a.time == b.time then
			return a.note < b.note
		end

		return a.time < b.time
	end)
	local v17 = nil
	local result = {}

	for _, item in ipairs(list) do
		local time = tonumber(item.time) or 0

		if not v17 or math.abs(time - v17.sourceTime) > 0.035 then
			v17 = {
				notes = {},
				chars = {},
				durations = {},
				velocities = {},
				sourceTime = time,
				duration = 0.13
			}

			table.insert(result, v17)
		end

		table.insert(v17.notes, item.note)
		table.insert(v17.durations, (math.max(0.05, item.duration or 0.13)))
		table.insert(v17.velocities, item.velocity)
		v17.duration = math.max(v17.duration, item.duration or 0.13)
		v17.display = ""
	end

	return result
end

local function build2DSourceFromPlayer(p, value)
	local loaded = p and p.Loaded

	if not (loaded and loaded.Instructions and loaded.PlaybackTimes) then
		return nil
	end

	local v17 = {}
	local v18 = {}

	for k, instruction in pairs(loaded.Instructions) do
		local playbackTime = loaded.PlaybackTimes[k]

		if not (typeof(instruction) == "table" and typeof(playbackTime) == "table") then
			continue
		end

		for i, v19 in ipairs(instruction) do
			local v20 = v19[1] or v19.InstructionName or v19.Type

			if not (v20 == "NoteOn" or v20 == "NoteOff") then
				continue
			end

			local time = tonumber(playbackTime[i] or v19.Time or v19.PlaybackTime)
			local channel = tonumber(v19.Channel or v19[3])
			local noteNumber = tonumber(v19.NoteNumber or v19[4])
			local velocity = tonumber(v19.Velocity or v19[5]) or 0

			if not (time and channel ~= 9 and noteNumber) then
				continue
			end

			local note = midiNoteToPianoNote(noteNumber) -- inferred equivalent call

			if not note then
				continue
			end

			if v20 == "NoteOn" and velocity > 0 then
				local v21 = { time = time, note = note, velocity = velocity, duration = 0.13 }

				table.insert(v18, v21)
				v17[note] = v17[note] or {}
				table.insert(v17[note], v21)
			else
				local v21 = v17[note]

				if v21 and #v21 > 0 then
					local v22 = table.remove(v21, 1)
					v22.duration = math.max(0.05, time - v22.time)
				end
			end
		end
	end

	local tokens = groupTimedPresses(v18)

	if #tokens == 0 then
		return nil
	end

	return {
		kind = "MIDI Player",
		name = value or "MIDI",
		tokens = tokens,
		usesTiming = true
	}
end

local function prepareMidi(p, fn2, fn3) -- 3 equivalent calls inferred from this helper
	stopPlayback()
	task.spawn(function()
		local midi, v17, v18 = InteractiveMidi.new("Midi", "Parser", "Player")

		if pcall(function()
			midi:Load(p)
		end) then
			v17:Load(midi)
			v17.WaitEvery = 100

			if pcall(function()
				v17:Parse("Summation")
			end) then
				v18:Load(v17)
				local v19 = calcRealDuration(v18)

				v18.DisplayedDuration = v19 > 0 and v19 or v18.TimeLength
				v2 = v18

				if fn2 then
					fn2(v18)
				end
			elseif fn3 then
				fn3("Failed to parse MIDI")
			end
		elseif fn3 then
			fn3("Invalid MIDI file")
		end
	end)
end

local function beginPlayback(data, callback, value)
	if not v2 then
		return
	end

	local v17 = v2
	value = value or "MidiPlayer"
	v15 = value
	local v18 = "MidiPlayer"

	local v19 = {}

	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if v11 and data.markActivity then
			local now = tick()

			if now - v12 >= 2 then
				v12 = now
				data.markActivity()
			end
		end

		if next(v8) then
			for k in pairs(v8) do
				v8[k] = nil
				data.finishNote(k)
			end
		end

		if v2 then
			if #v19 == 0 then
				return
			end

			local v20 = v19
			v19 = {}

			for _, v21 in ipairs(v20) do
				local v22 = v21[2]

				if v21[1] == "on" then
					v9 = tick()

					if v7[v22] then
						data.finishNote(v22)
					end

					v7[v22] = true
					data.playNote(v22, v21[3], 0, false, v18)
				elseif v7[v22] then
					v7[v22] = nil
					data.finishNote(v22)
				end
			end
		else
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end)

	function v2.Events.NoteOn(data2)
		if data2.Channel == 9 then
			return
		end

		local v20 = midiNoteToPianoNote(data2.NoteNumber) -- inferred equivalent call

		if v20 then
			if data2.Velocity == 0 then
				table.insert(v19, { "off", v20 })
			else
				table.insert(v19, { "on", v20, data2.Velocity })
			end
		end
	end

	function v2.Events.NoteOff(p)
		if p.Channel == 9 then
			return
		end

		local v20 = midiNoteToPianoNote(p.NoteNumber) -- inferred equivalent call

		if v20 then
			table.insert(v19, { "off", v20 })
		end
	end

	function v17.Events.Stopped()
		if v10[v17] then
			v10[v17] = nil
			return
		end

		local timePosition = v17.TimePosition
		local v20 = v17.DisplayedDuration or v17.TimeLength

		if v20 then
			if v20 > 0 then
				v20 = v20 - 0.05 <= timePosition
			else
				v20 = false
			end
		end

		if v17.InstructionProgress and next(v17.InstructionProgress) ~= nil and not v20 then
			local tempo = v17.Tempo
			local tempoTimePosition = v17.TempoTimePosition
			local tempoTimeConstant = v17.TempoTimeConstant
			local isTempoSet = v17.IsTempoSet
			releaseAllNotes() -- inferred equivalent call

			if v17.InstructionProgress then
				table.clear(v17.InstructionProgress)
			end

			if v17.EndOfTracks then
				table.clear(v17.EndOfTracks)
			end

			task.defer(function()
				if v2 == v17 then
					v17.Tempo = tempo
					v17.TempoTimePosition = tempoTimePosition
					v17.TempoTimeConstant = tempoTimeConstant
					v17.IsTempoSet = isTempoSet
					v17:SetTimePosition(timePosition)
					v17:Play()
				end
			end)
		else
			releaseAllNotes() -- inferred equivalent call
			v11 = false
			v2 = nil
			local v21 = v15
			v15 = nil

			if v21 == "CommunityPreview" then
				local displayedDuration = v17.DisplayedDuration or v17.TimeLength or 0
				setPreviewState({
					Active = false,
					Loading = false,
					Playing = false,
					Paused = false,
					Status = "Finished.",
					Position = displayedDuration,
					Duration = displayedDuration
				})
			end

			if data.setPlaybackMode then
				data.setPlaybackMode(false)
			end

			v3 = nil

			if v21 ~= "CommunityPreview" then
				hideMidiOverhead() -- inferred equivalent call
			end

			if callback then
				callback()
			end
		end
	end

	v3 = data

	if data.setPlaybackMode then
		data.setPlaybackMode(true)
	end

	v11 = value ~= "CommunityPreview"
	v12 = 0

	if value ~= "CommunityPreview" then
		task.spawn(showMidiOverhead)
	end

	v2:Play()
end

local function getNamedChild(parent, className, name)
	local child = parent:FindFirstChild(name)

	if child and child:IsA(className) then
		return child
	end

	if child then
		child:Destroy()
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

local function makeCorner(parent, value) -- 15 equivalent calls inferred from this helper
	local uiCorner = parent:FindFirstChildOfClass("UICorner")

	if not uiCorner then
		uiCorner = Instance.new("UICorner")
		uiCorner.Name = "UICorner"
		uiCorner.Parent = parent
	end

	uiCorner.CornerRadius = UDim.new(0, value or 8)
	return uiCorner
end

local function makeLabel(parent, text, size, p, value, p2, p3)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = size
	textLabel.Position = p or UDim2.new(0, 0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = p2 or Color3.fromRGB(150, 150, 170)
	textLabel.TextSize = value or 11
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextXAlignment = p3 or Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Parent = parent
	return textLabel
end

local object = setmetatable({}, { __mode = "k" })

local function configureButtonText(button, options)
	if not (button and button:IsA("TextButton")) then
		return nil
	end

	options = options or {}

	if options.Text ~= nil then
		button.Text = tostring(options.Text)
	end

	local textLabel = button:FindFirstChild("TextLabel")

	if textLabel and not textLabel:IsA("TextLabel") then
		textLabel:Destroy()
		textLabel = nil
	end

	if not textLabel then
		textLabel = Instance.new("TextLabel")
		textLabel.Name = "TextLabel"
		textLabel.Parent = button
	end

	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Position = UDim2.new(0, 0, 0, 0)
	textLabel.Text = button.Text
	textLabel.TextColor3 = options.TextColor3 or button.TextColor3
	textLabel.Font = options.Font or button.Font
	textLabel.TextXAlignment = options.TextXAlignment or button.TextXAlignment
	textLabel.TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Center
	textLabel.TextWrapped = options.TextWrapped == true
	textLabel.TextTruncate = options.TextTruncate or Enum.TextTruncate.AtEnd
	textLabel.TextScaled = true
	textLabel.TextSize = options.MaxTextSize or button.TextSize
	textLabel.ZIndex = button.ZIndex + 1
	local uiTextSizeConstraint = textLabel:FindFirstChildOfClass("UITextSizeConstraint")

	if not uiTextSizeConstraint then
		uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.Name = "UITextSizeConstraint"
		uiTextSizeConstraint.Parent = textLabel
	end

	uiTextSizeConstraint.MinTextSize = options.MinTextSize or 8
	uiTextSizeConstraint.MaxTextSize = options.MaxTextSize or math.max(8, button.TextSize)
	local uiPadding = textLabel:FindFirstChildOfClass("UIPadding")

	if not uiPadding then
		uiPadding = Instance.new("UIPadding")
		uiPadding.Name = "UIPadding"
		uiPadding.Parent = textLabel
	end

	uiPadding.PaddingLeft = UDim.new(0, options.PaddingLeft or 0)
	uiPadding.PaddingRight = UDim.new(0, options.PaddingRight or 0)
	button.TextTransparency = 1

	if not object[button] then
		object[button] = {
			button:GetPropertyChangedSignal("Text"):Connect(function()
				if textLabel.Parent then
					textLabel.Text = button.Text
				end
			end),
			button:GetPropertyChangedSignal("TextColor3"):Connect(function()
				if textLabel.Parent then
					textLabel.TextColor3 = button.TextColor3
				end
			end),
			button:GetPropertyChangedSignal("ZIndex"):Connect(function()
				if textLabel.Parent then
					textLabel.ZIndex = button.ZIndex + 1
				end
			end)
		}
	end

	return textLabel
end

local function makeButton(guiObject, text, size, position, color, p)
	local textButton = Instance.new("TextButton")
	textButton.Size = size
	textButton.Position = position
	textButton.AnchorPoint = p or Vector2.new(0, 0)
	textButton.BackgroundColor3 = color or Color3.fromRGB(60, 160, 255)
	textButton.Text = text
	textButton.TextColor3 = Color3.new(1, 1, 1)
	textButton.TextSize = 13
	textButton.Font = Enum.Font.GothamBold
	textButton.BorderSizePixel = 0
	textButton.Active = true

	if guiObject and guiObject:IsA("GuiObject") then
		textButton.ZIndex = guiObject.ZIndex + 1
	end

	textButton.Parent = guiObject
	makeCorner(textButton, 6) -- inferred equivalent call
	configureButtonText(textButton, { MaxTextSize = 13, MinTextSize = 8 })
	return textButton
end

local function configureTileGrid(parent)
	local uiListLayout = parent:FindFirstChildOfClass("UIListLayout")

	if uiListLayout then
		uiListLayout:Destroy()
	end

	local uiGridLayout = parent:FindFirstChildOfClass("UIGridLayout")

	if not uiGridLayout then
		uiGridLayout = Instance.new("UIGridLayout")
		uiGridLayout.Name = "UIGridLayout"
		uiGridLayout.Parent = parent
	end

	uiGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiGridLayout.FillDirection = Enum.FillDirection.Horizontal
	uiGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uiGridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	uiGridLayout.CellSize = UDim2.new(0.5, -5, 0, 42)
	uiGridLayout.CellPadding = UDim2.fromOffset(10, 10)
	return uiGridLayout
end

local function clearTemplateButtons(instance)
	for _, button in ipairs(instance:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end
end

local function makeSongTileButton(p, name, value)
	local button = makeButton(p, "", UDim2.new(1, 0, 0, 42), UDim2.new(0, 0, 0, 0), Color3.new(1, 1, 1))
	button.LayoutOrder = value or 1
	button.BackgroundTransparency = 0.94
	button.Text = ""
	button.TextTransparency = 1
	button.TextStrokeTransparency = 1
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.TextYAlignment = Enum.TextYAlignment.Center
	button.TextSize = 15
	button.Font = Enum.Font.GothamMedium
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.AutoButtonColor = true
	makeCorner(button, 6) -- inferred equivalent call
	local uiStroke = button:FindFirstChildOfClass("UIStroke")

	if not uiStroke then
		uiStroke = Instance.new("UIStroke")
		uiStroke.Name = "UIStroke"
		uiStroke.Parent = button
	end

	uiStroke.Color = Color3.new(1, 1, 1)
	uiStroke.Transparency = 0.92
	uiStroke.Thickness = 1
	local textLabel = button:FindFirstChild("TextLabel")

	if not (textLabel and textLabel:IsA("TextLabel")) then
		return button
	end

	textLabel.Text = tostring(name or "")
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextScaled = true
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.TextTransparency = 0
	local uiTextSizeConstraint = textLabel:FindFirstChildOfClass("UITextSizeConstraint")

	if not uiTextSizeConstraint then
		uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.Name = "UITextSizeConstraint"
		uiTextSizeConstraint.Parent = textLabel
	end

	uiTextSizeConstraint.MinTextSize = 9
	uiTextSizeConstraint.MaxTextSize = 15
	local uiPadding = textLabel:FindFirstChildOfClass("UIPadding")

	if not uiPadding then
		uiPadding = Instance.new("UIPadding")
		uiPadding.Name = "UIPadding"
		uiPadding.Parent = textLabel
	end

	uiPadding.PaddingLeft = UDim.new(0, 20)
	uiPadding.PaddingRight = UDim.new(0, 12)

	return button
end

local function applyGuiObjectZTree(guiObject, zIndex)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	guiObject.ZIndex = zIndex or guiObject.ZIndex
	local zIndex2 = guiObject.ZIndex

	for _, guiObject2 in ipairs(guiObject:GetDescendants()) do
		if not guiObject2:IsA("GuiObject") then
			continue
		end

		local v17 = guiObject2:GetAttribute("MidiLocalZIndex")

		if typeof(v17) ~= "number" then
			v17 = guiObject2.ZIndex
			guiObject2:SetAttribute("MidiLocalZIndex", v17)
		end

		guiObject2.ZIndex = zIndex2 + 1 + math.clamp(v17, 0, 200)
	end
end

local function isInputPress(p): boolean -- 3 equivalent calls inferred from this helper
	return p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch
end

local function isGuiActuallyVisible(guiObject): boolean
	while guiObject and not guiObject:IsA("ScreenGui") do
		if guiObject:IsA("GuiObject") and not guiObject.Visible then
			return false
		end

		guiObject = guiObject.Parent
	end

	return true
end

local function pointInGui(guiObject, position, value): boolean
	if not (guiObject and guiObject:IsA("GuiObject") and isGuiActuallyVisible(guiObject)) then
		return false
	end

	value = value or 0
	local absolutePosition = guiObject.AbsolutePosition
	local absoluteSize = guiObject.AbsoluteSize
	return position.X >= absolutePosition.X - value
		and position.X <= absolutePosition.X + absoluteSize.X + value
		and position.Y >= absolutePosition.Y - value
		and position.Y <= absolutePosition.Y + absoluteSize.Y + value
end

local function connectActivated(state, fn2)
	state.Active = true
	local v17 = 0
	local function fire() -- 1 equivalent call inferred from this helper
		local now = os.clock()

		if now - v17 < 0.12 then
			return
		end

		v17 = now
		fn2()
	end
	state.Activated:Connect(fire)
	state.InputEnded:Connect(function(input)
		if isInputPress(input) and pointInGui(state, input.Position, 8) then -- inferred equivalent call
			fire() -- inferred equivalent call
		end
	end)
end

local function createSlider(parent, color)
	local track = parent:FindFirstChild("Track")

	if not (track and track:IsA("TextButton")) then
		if track then
			track:Destroy()
		end

		track = Instance.new("TextButton")
		track.Name = "Track"
		track.Parent = parent
	end

	track.Size = UDim2.new(1, 0, 1, 0)
	track.Position = UDim2.new(0, 0, 0, 0)
	track.AnchorPoint = Vector2.new(0, 0)
	track.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
	track.BackgroundTransparency = 0
	track.Text = ""
	track.BorderSizePixel = 0
	track.AutoButtonColor = false
	track.ClipsDescendants = false
	track.ZIndex = math.max(parent.ZIndex or 1, 1) + 20
	track:SetAttribute("MidiLocalZIndex", 20)
	makeCorner(track) -- inferred equivalent call
	local fill = track:FindFirstChild("Fill")

	if not (fill and fill:IsA("Frame")) then
		if fill then
			fill:Destroy()
		end

		fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Parent = track
	end

	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.AnchorPoint = Vector2.new(0, 0)
	fill.BackgroundColor3 = color or Color3.fromRGB(60, 160, 255)
	fill.BorderSizePixel = 0
	fill.ZIndex = track.ZIndex + 1
	fill:SetAttribute("MidiLocalZIndex", 21)
	fill.Active = true
	makeCorner(fill) -- inferred equivalent call
	local handle = track:FindFirstChild("Handle")

	if not (handle and handle:IsA("Frame")) then
		if handle then
			handle:Destroy()
		end

		handle = Instance.new("Frame")
		handle.Name = "Handle"
		handle.Parent = track
	end

	handle.Size = UDim2.new(0, 20, 0, 20)
	handle.Position = UDim2.new(0, 0, 0.5, 0)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.BackgroundColor3 = Color3.new(1, 1, 1)
	handle.BorderSizePixel = 0
	handle.ZIndex = track.ZIndex + 2
	handle:SetAttribute("MidiLocalZIndex", 22)
	makeCorner(handle, 10) -- inferred equivalent call
	local isDragging = false
	local _ = nil
	local userInputType = nil
	local x = nil
	local v17 = nil
	local v18 = nil
	local scrollingFrame = parent:FindFirstAncestorWhichIsA("ScrollingFrame")

	parent.Active = true
	track.Active = true
	handle.Active = true

	local function getHandleRadius() -- 2 equivalent calls inferred from this helper
		return (math.max(handle.AbsoluteSize.X * 0.5, 7))
	end

	local function getFraction(x2) -- 3 equivalent calls inferred from this helper
		local x3 = track.AbsolutePosition.X
		local x4 = track.AbsoluteSize.X
		local handleRadius = getHandleRadius() -- inferred equivalent call
		local v19 = x4 - handleRadius * 2

		if v19 <= 0 then
			return 0
		end

		return (math.clamp((x2 - x3 - handleRadius) / v19, 0, 1))
	end

	local function updateSliderVisual(value)
		local v19 = math.clamp(value or 0, 0, 1)
		local handleRadius = getHandleRadius() -- inferred equivalent call
		local v20 = handleRadius - handleRadius * 2 * v19

		local v21 = not (v19 > 0) and 0 or handleRadius * 2 * (1 - v19)

		fill.Size = UDim2.new(v19, v21, 1, 0)
		handle.Position = UDim2.new(v19, v20, 0.5, 0)
	end

	local function setAncestorScrolling(scrollingEnabled) -- 2 equivalent calls inferred from this helper
		if scrollingFrame then
			scrollingFrame.ScrollingEnabled = scrollingEnabled
		end
	end

	local function applyFraction(p) -- 3 equivalent calls inferred from this helper
		updateSliderVisual(p)

		if v17 then
			v17(p)
		end
	end

	local function beginSliderDrag(input, p)
		if not isInputPress(input) or isDragging or input.UserInputType == Enum.UserInputType.Touch and p ~= handle then -- inferred equivalent call
			return
		end

		isDragging = true
		userInputType = input.UserInputType
		_ = input.UserInputType == Enum.UserInputType.Touch and input or nil
		x = input.Position.X
		setAncestorScrolling(false) -- inferred equivalent call
		applyFraction(getFraction(x)) -- inferred equivalent call
	end

	local function updateSliderDrag(p)
		if not isDragging then
			return
		end

		local v19

		if userInputType == Enum.UserInputType.MouseButton1 then
			v19 = p.UserInputType == Enum.UserInputType.MouseMovement
		else
			v19 = false
		end

		local v20

		if userInputType == Enum.UserInputType.Touch then
			v20 = p.UserInputType == Enum.UserInputType.Touch
		else
			v20 = false
		end

		if v19 or v20 then
			if userInputType == Enum.UserInputType.Touch then
				_ = p
			end

			x = p.Position.X
			applyFraction(getFraction(x)) -- inferred equivalent call
		end
	end

	local function endSliderDrag(p)
		if not isDragging then
			return
		end

		local v19

		if userInputType == Enum.UserInputType.MouseButton1 then
			v19 = p.UserInputType == Enum.UserInputType.MouseButton1
		else
			v19 = false
		end

		local v20

		if userInputType == Enum.UserInputType.Touch then
			v20 = p.UserInputType == Enum.UserInputType.Touch
		else
			v20 = false
		end

		if v19 or v20 then
			local fraction = getFraction(p.Position.X or x) -- inferred equivalent call

			isDragging = false
			_ = nil
			userInputType = nil
			x = nil
			setAncestorScrolling(true) -- inferred equivalent call
			applyFraction(fraction) -- inferred equivalent call

			if v18 then
				v18(fraction)
			end
		end
	end

	parent.InputBegan:Connect(function(input)
		beginSliderDrag(input, parent)
	end)
	track.InputBegan:Connect(function(input)
		beginSliderDrag(input, track)
	end)
	fill.InputBegan:Connect(function(input)
		beginSliderDrag(input, fill)
	end)
	handle.InputBegan:Connect(function(input)
		beginSliderDrag(input, handle)
	end)
	UserInputService.InputBegan:Connect(function(input)
		if not isInputPress(input) then -- inferred equivalent call
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch then
			if pointInGui(handle, input.Position, 10) then
				beginSliderDrag(input, handle)
			end
		elseif pointInGui(parent, input.Position, 12) or pointInGui(track, input.Position, 12) then
			beginSliderDrag(input, track)
		end
	end)
	parent.InputChanged:Connect(updateSliderDrag)
	track.InputChanged:Connect(updateSliderDrag)
	fill.InputChanged:Connect(updateSliderDrag)
	handle.InputChanged:Connect(updateSliderDrag)
	UserInputService.InputChanged:Connect(updateSliderDrag)
	UserInputService.InputEnded:Connect(endSliderDrag)

	return {
		setFraction = function(p)
			if isDragging then
				return
			end

			updateSliderVisual(p)
		end,
		getIsDragging = function()
			return isDragging
		end,
		onDrag = function(p)
			v17 = p
		end,
		onRelease = function(p)
			v18 = p
		end
	}
end

function MidiPlayerHandler.Initialize(instance, parent, data, object2)
	v14 = data

	if flag then
		return
	end

	flag = true
	local midiPlayer = parent:FindFirstChild("MidiPlayer")

	if not (midiPlayer and midiPlayer:IsA("TextButton")) then
		if midiPlayer then
			midiPlayer:Destroy()
		end

		midiPlayer = Instance.new("TextButton")
		midiPlayer.Name = "MidiPlayer"
		midiPlayer.Parent = parent
	end

	local record = parent:FindFirstChild("Record")
	local playRecord = parent:FindFirstChild("PlayRecord")
	local udim = UDim2.new(0.5, 138, 0, -24)

	if record and playRecord and record:IsA("GuiObject") and playRecord:IsA("GuiObject") then
		local v17 = playRecord.Position.X.Scale - record.Position.X.Scale
		local v18 = playRecord.Position.X.Offset - record.Position.X.Offset
		udim = UDim2.new(
			playRecord.Position.X.Scale + v17,
			playRecord.Position.X.Offset + v18,
			playRecord.Position.Y.Scale,
			playRecord.Position.Y.Offset
		)

		midiPlayer.AnchorPoint = playRecord.AnchorPoint
		midiPlayer.Size = playRecord.Size
	else
		midiPlayer.AnchorPoint = Vector2.new(0.5, 0.5)
		midiPlayer.Size = UDim2.fromOffset(116, 30)
	end

	midiPlayer.Position = udim
	midiPlayer.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
	midiPlayer.Text = "MIDI"
	midiPlayer.TextColor3 = Color3.new(1, 1, 1)
	midiPlayer.TextScaled = true
	midiPlayer.TextWrapped = true
	midiPlayer.TextXAlignment = Enum.TextXAlignment.Center
	midiPlayer.TextYAlignment = Enum.TextYAlignment.Center
	midiPlayer.TextSize = 14
	midiPlayer.Font = Enum.Font.GothamBold
	midiPlayer.BorderSizePixel = 0
	midiPlayer.Parent = parent
	local v17 = midiPlayer:FindFirstChildOfClass("UITextSizeConstraint")

	if not v17 then
		v17 = Instance.new("UITextSizeConstraint")
		v17.Parent = midiPlayer
	end

	v17.MinTextSize = 10
	v17.MaxTextSize = 18
	makeCorner(midiPlayer, 6) -- inferred equivalent call
	local screenGui = instance:FindFirstAncestorWhichIsA("ScreenGui")
	local parent2 = screenGui or instance

	if screenGui then
		local midiModalHost = screenGui:FindFirstChild("MidiModalHost")

		if midiModalHost then
			midiModalHost:Destroy()
		end

		local midiModal_Legacy = instance:FindFirstChild("MidiModal")

		if midiModal_Legacy then
			local midiModal = parent2:FindFirstChild("MidiModal")

			if midiModal and midiModal ~= midiModal_Legacy then
				midiModal_Legacy.Visible = false
				midiModal_Legacy.Name = "MidiModal_Legacy"
			else
				midiModal_Legacy.Parent = parent2
			end
		end
	end

	local midiModal = parent2:FindFirstChild("MidiModal")

	if not (midiModal and midiModal:IsA("Frame")) then
		if midiModal then
			midiModal:Destroy()
		end

		midiModal = Instance.new("Frame")
		midiModal.Name = "MidiModal"
		midiModal.Parent = parent2
	end

	midiModal.AnchorPoint = Vector2.new(0.5, 0)
	midiModal.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	midiModal.BorderSizePixel = 0
	midiModal.ClipsDescendants = true
	midiModal.Visible = false
	midiModal.ZIndex = screenGui and 7000 or (parent2.ZIndex or 10) + 1
	midiModal.Active = true
	midiModal.Selectable = false
	midiModal.Parent = parent2
	local uiDragDetector = midiModal:FindFirstChildOfClass("UIDragDetector")

	if uiDragDetector then
		uiDragDetector:Destroy()
	end

	local v18 = false
	local function getViewportSize() -- 1 equivalent call inferred from this helper
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			return currentCamera.ViewportSize
		end

		return Vector2.new(1280, 720)
	end

	local function syncModalToPianoContainer()
		if screenGui then
			local viewportSize = getViewportSize() -- inferred equivalent call

			local function clampToRange(value, min, max) -- 8 equivalent calls inferred from this helper
				if max < min then
					return max
				end

				return (math.clamp(value, min, max))
			end

			local function getLayoutMode()
				if data and data.getMidiPlayerLayoutMode then
					local midiPlayerLayoutMode = data.getMidiPlayerLayoutMode()

					if
						midiPlayerLayoutMode == "2D"
						or midiPlayerLayoutMode == "Mobile"
						or midiPlayerLayoutMode == "Desktop"
					then
						return midiPlayerLayoutMode
					end
				end

				local pianoRoll2D = screenGui:FindFirstChild("PianoRoll2D")
				local mobilePianoContainer = screenGui:FindFirstChild("MobilePianoContainer")

				if pianoRoll2D and pianoRoll2D.Visible then
					return "2D"
				end

				if UserInputService.TouchEnabled or mobilePianoContainer and mobilePianoContainer.Visible then
					return "Mobile"
				end

				return "Desktop"
			end

			local layoutMode = getLayoutMode()

			if layoutMode == "Mobile" then
				midiModal.ZIndex = 5200
				local mobilePianoContainer = screenGui:FindFirstChild("MobilePianoContainer")
				local y = viewportSize.Y

				if mobilePianoContainer and mobilePianoContainer.Visible then
					y = mobilePianoContainer.AbsolutePosition.Y
				end

				local v19 = math.max(18, (math.floor(viewportSize.X * 0.04)))
				local v20 = math.max(320, viewportSize.X - v19 * 2)
				local v21 = clampToRange(math.floor(viewportSize.X * 0.88), math.min(420, v20), math.min(760, v20)) -- inferred equivalent call
				local v22 = math.max(36, (math.floor(viewportSize.Y * 0.07)))
				local v23 = viewportSize.Y - v22 - 28
				local v24 = y - v22 - 12

				if viewportSize.Y >= 560 and v24 >= 320 then
					v23 = math.min(v23, v24)
				end

				local v25 = math.max(180, v23)
				midiModal.Size = UDim2.fromOffset(
					v21,
					clampToRange(math.floor(viewportSize.Y * 0.74), math.min(240, v25), math.min(420, v25)) -- inferred equivalent call
				)
				midiModal.Position = UDim2.fromOffset(math.floor(viewportSize.X * 0.5), v22)
			elseif layoutMode == "2D" then
				midiModal.ZIndex = screenGui and 7000 or midiModal.ZIndex
				local v19 = math.max(360, viewportSize.X - 72)
				local v20 = clampToRange(620, math.min(420, v19), math.min(680, v19)) -- inferred equivalent call
				local v21 = math.max(56, (math.floor(viewportSize.Y * 0.1)))
				local v22 = math.max(240, viewportSize.Y - v21 - 42)
				midiModal.Size = UDim2.fromOffset(v20, clampToRange(360, math.min(280, v22), math.min(420, v22))) -- inferred equivalent call
				midiModal.Position = UDim2.fromOffset(math.floor(viewportSize.X * 0.5), v21)
			else
				midiModal.ZIndex = screenGui and 7000 or midiModal.ZIndex
				local absoluteSize = instance.AbsoluteSize
				local absolutePosition = instance.AbsolutePosition
				local v19 = math.min(820, (math.max(360, viewportSize.X - 48)))
				local v20 = math.min(420, v19)
				local v21 = math.min(520, (math.max(240, viewportSize.Y - 96)))
				local v22 = math.min(300, v21)
				v19 = clampToRange(math.floor(absoluteSize.X * 0.629478514), v20, v19) -- inferred equivalent call
				v21 = clampToRange(math.floor(absoluteSize.Y * 2.04020095), v22, v21) -- inferred equivalent call
				local v23 = math.floor(v19 * 0.5 + 24)
				local v24 = math.floor(viewportSize.X - v19 * 0.5 - 24)
				local v25 = clampToRange(math.floor(absolutePosition.X + absoluteSize.X * 0.5), v23, math.max(v23, v24)) -- inferred equivalent call
				local v26 = math.max(48, (math.floor(viewportSize.Y - v21 - 24)))
				v26 = clampToRange(math.floor(absolutePosition.Y + absoluteSize.Y * -1.38663399), 48, v26) -- inferred equivalent call
				midiModal.Size = UDim2.fromOffset(v19, v21)
				midiModal.Position = UDim2.fromOffset(v25, v26)
			end
		else
			midiModal.Size = UDim2.fromOffset(620, 360)
			midiModal.Position = UDim2.new(0.5, 0, 0, 72)
		end
	end
	syncModalToPianoContainer()

	if screenGui then
		local function syncIfNotDragged()
			if not v18 then
				syncModalToPianoContainer()
			end
		end
		instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncIfNotDragged)
		instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(syncIfNotDragged)
		instance:GetPropertyChangedSignal("Size"):Connect(syncIfNotDragged)
		instance:GetPropertyChangedSignal("Position"):Connect(syncIfNotDragged)

		if workspace.CurrentCamera then
			workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(syncIfNotDragged)
		end
	end

	makeCorner(midiModal, 10) -- inferred equivalent call
	local uiStroke = midiModal:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke:Destroy()
	end

	local uiShadow = midiModal:FindFirstChildOfClass("UIShadow")

	if not uiShadow then
		local success, result = pcall(function()
			return Instance.new("UIShadow")
		end)

		if success then
			uiShadow = result
			uiShadow.Name = "UIShadow"
			uiShadow.Parent = midiModal
		end
	end

	if uiShadow then
		uiShadow.Enabled = true
		uiShadow.Color = Color3.fromRGB(0, 0, 0)
		uiShadow.Transparency = 0.5
		uiShadow.ZIndex = -1
		pcall(function()
			uiShadow.BlurRadius = UDim.new(0, 24)
			uiShadow.Offset = UDim2.fromOffset(0, 0)
			uiShadow.Spread = UDim2.fromOffset(0, 0)
		end)
	end

	local header = midiModal:FindFirstChild("Header")

	if not (header and header:IsA("Frame")) then
		if header then
			header:Destroy()
		end

		header = Instance.new("Frame")
		header.Name = "Header"
		header.Parent = midiModal
	end

	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
	header.BackgroundTransparency = 1
	header.BorderSizePixel = 0
	makeCorner(header, 10) -- inferred equivalent call
	local headerBottomFill = header:FindFirstChild("HeaderBottomFill")

	if not (headerBottomFill and headerBottomFill:IsA("Frame")) then
		if headerBottomFill then
			headerBottomFill:Destroy()
		end

		headerBottomFill = Instance.new("Frame")
		headerBottomFill.Name = "HeaderBottomFill"
		headerBottomFill.Parent = header
	end

	headerBottomFill.Size = UDim2.new(1, 0, 0, 1)
	headerBottomFill.Position = UDim2.new(0, 0, 1, 0)
	headerBottomFill.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	headerBottomFill.BackgroundTransparency = 0.5
	headerBottomFill.BorderSizePixel = 0

	local v19 = false
	local position = nil
	local position2 = nil
	local _ = nil
	local userInputType = nil

	local function beginModalDrag(p)
		if p.UserInputType ~= Enum.UserInputType.MouseButton1 and p.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		v19 = true
		userInputType = p.UserInputType
		_ = p.UserInputType == Enum.UserInputType.Touch and p or nil
		position = p.Position
		position2 = midiModal.Position
	end

	local function updateModalDrag(p)
		if not (v19 and position and position2) then
			return
		end

		local v20 = p.Position - position
		v18 = true
		midiModal.Position = UDim2.new(
			position2.X.Scale,
			position2.X.Offset + v20.X,
			position2.Y.Scale,
			position2.Y.Offset + v20.Y
		)
	end

	local function attachModalDragSource(state) -- 3 equivalent calls inferred from this helper
		state.Active = true
		state.InputBegan:Connect(beginModalDrag)
		state.InputChanged:Connect(function(input)
			if
				(input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
				and v19
				and userInputType == Enum.UserInputType.Touch
			then
				_ = input
			end
		end)
	end

	attachModalDragSource(header) -- inferred equivalent call
	attachModalDragSource(headerBottomFill) -- inferred equivalent call
	UserInputService.InputChanged:Connect(function(input)
		if not v19 then
			return
		end

		if
			userInputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseMovement
		then
			if v19 and position then
				if not position2 then
					return
				end

				local v20 = input.Position - position
				v18 = true
				midiModal.Position = UDim2.new(
					position2.X.Scale,
					position2.X.Offset + v20.X,
					position2.Y.Scale,
					position2.Y.Offset + v20.Y
				)
			end
		elseif userInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch then
			_ = input

			if v19 and position then
				if not position2 then
					return
				end

				local v20 = input.Position - position
				v18 = true
				midiModal.Position = UDim2.new(
					position2.X.Scale,
					position2.X.Offset + v20.X,
					position2.Y.Scale,
					position2.Y.Offset + v20.Y
				)
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		local v20

		if userInputType == Enum.UserInputType.MouseButton1 then
			v20 = input.UserInputType == Enum.UserInputType.MouseButton1
		else
			v20 = false
		end

		local v21

		if userInputType == Enum.UserInputType.Touch then
			v21 = input.UserInputType == Enum.UserInputType.Touch
		else
			v21 = false
		end

		if v20 or v21 then
			v19 = false
			_ = nil
			userInputType = nil
		end
	end)
	local titleLabel = header:FindFirstChild("TitleLabel")

	if not (titleLabel and titleLabel:IsA("TextLabel")) then
		if titleLabel then
			titleLabel:Destroy()
		end

		titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "TitleLabel"
		titleLabel.Parent = header
	end

	titleLabel.Size = UDim2.new(1, -60, 1, 0)
	titleLabel.Position = UDim2.new(0, 14, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "MIDI Player (00h 00m 00s)"
	titleLabel.Font = Enum.Font.Gotham
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	attachModalDragSource(titleLabel) -- inferred equivalent call
	local closeButton = header:FindFirstChild("CloseButton")

	if not (closeButton and closeButton:IsA("ImageButton")) then
		if closeButton then
			closeButton:Destroy()
		end

		closeButton = Instance.new("ImageButton")
		closeButton.Name = "CloseButton"
		closeButton.Parent = header
	end

	closeButton.Size = UDim2.new(0, 36, 0, 36)
	closeButton.Position = UDim2.new(1, -10, 0.5, 0)
	closeButton.AnchorPoint = Vector2.new(1, 0.5)
	closeButton.BackgroundTransparency = 1
	closeButton.Image = "rbxassetid://6031094678"
	closeButton.ImageColor3 = Color3.new(1, 1, 1)
	closeButton.ImageTransparency = 0
	closeButton.ScaleType = Enum.ScaleType.Fit
	closeButton.BorderSizePixel = 0
	local uiCorner = closeButton:FindFirstChildOfClass("UICorner")

	if uiCorner then
		uiCorner:Destroy()
	end

	local midiBody = midiModal:FindFirstChild("MidiBody")

	if not (midiBody and midiBody:IsA("ScrollingFrame")) then
		if midiBody then
			midiBody:Destroy()
		end

		midiBody = Instance.new("ScrollingFrame")
		midiBody.Name = "MidiBody"
		midiBody.Parent = midiModal
	end

	midiBody.Size = UDim2.new(1, -16, 1, -58)
	midiBody.Position = UDim2.new(0, 8, 0, 54)
	midiBody.BackgroundTransparency = 1
	midiBody.ScrollBarThickness = 0
	midiBody.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
	midiBody.ScrollBarImageTransparency = 1
	midiBody.Active = true
	midiBody.ScrollingEnabled = true
	midiBody.ScrollingDirection = Enum.ScrollingDirection.Y
	midiBody.CanvasSize = UDim2.new(0, 0, 0, 0)
	midiBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
	midiBody.BorderSizePixel = 0
	local uiListLayout = midiBody:FindFirstChildOfClass("UIListLayout")

	if not uiListLayout then
		uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Name = "UIListLayout"
		uiListLayout.Parent = midiBody
	end

	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 6)
	local accessGate = midiModal:FindFirstChild("AccessGate")

	if not (accessGate and accessGate:IsA("Frame")) then
		if accessGate then
			accessGate:Destroy()
		end

		accessGate = Instance.new("Frame")
		accessGate.Name = "AccessGate"
		accessGate.Parent = midiModal
	end

	accessGate.Size = UDim2.new(1, -16, 1, -58)
	accessGate.Position = UDim2.new(0, 8, 0, 54)
	accessGate.BackgroundTransparency = 1
	accessGate.BorderSizePixel = 0
	accessGate.Visible = false
	accessGate.Active = true
	local accessTitle = accessGate:FindFirstChild("AccessTitle")

	if not (accessTitle and accessTitle:IsA("TextLabel")) then
		if accessTitle then
			accessTitle:Destroy()
		end

		accessTitle = Instance.new("TextLabel")
		accessTitle.Name = "AccessTitle"
		accessTitle.Parent = accessGate
	end

	accessTitle.Size = UDim2.new(1, 0, 0, 24)
	accessTitle.Position = UDim2.new(0, 0, 0, 8)
	accessTitle.BackgroundTransparency = 1
	accessTitle.Text = "MIDI Player Gamepass"
	accessTitle.TextColor3 = Color3.new(1, 1, 1)
	accessTitle.TextSize = 16
	accessTitle.Font = Enum.Font.GothamBold
	accessTitle.TextXAlignment = Enum.TextXAlignment.Left
	local accessBody = accessGate:FindFirstChild("AccessBody")

	if not (accessBody and accessBody:IsA("TextLabel")) then
		if accessBody then
			accessBody:Destroy()
		end

		accessBody = Instance.new("TextLabel")
		accessBody.Name = "AccessBody"
		accessBody.Parent = accessGate
	end

	accessBody.Size = UDim2.new(1, 0, 0, 52)
	accessBody.Position = UDim2.new(0, 0, 0, 40)
	accessBody.BackgroundTransparency = 1
	accessBody.Text = "Start a free 24-hour trial or buy the gamepass for permanent access."
	accessBody.TextColor3 = Color3.fromRGB(185, 185, 205)
	accessBody.TextSize = 12
	accessBody.Font = Enum.Font.Gotham
	accessBody.TextXAlignment = Enum.TextXAlignment.Left
	accessBody.TextYAlignment = Enum.TextYAlignment.Top
	accessBody.TextWrapped = true
	local accessTrialInfo = accessGate:FindFirstChild("AccessTrialInfo")

	if not (accessTrialInfo and accessTrialInfo:IsA("TextLabel")) then
		if accessTrialInfo then
			accessTrialInfo:Destroy()
		end

		accessTrialInfo = Instance.new("TextLabel")
		accessTrialInfo.Name = "AccessTrialInfo"
		accessTrialInfo.Parent = accessGate
	end

	accessTrialInfo.Size = UDim2.new(1, 0, 0, 28)
	accessTrialInfo.Position = UDim2.new(0, 0, 0, 96)
	accessTrialInfo.BackgroundTransparency = 1
	accessTrialInfo.Text = ""
	accessTrialInfo.TextColor3 = Color3.fromRGB(145, 145, 165)
	accessTrialInfo.TextSize = 11
	accessTrialInfo.Font = Enum.Font.Gotham
	accessTrialInfo.TextXAlignment = Enum.TextXAlignment.Left
	accessTrialInfo.TextWrapped = true
	local accessButtonRow = accessGate:FindFirstChild("AccessButtonRow")

	if not (accessButtonRow and accessButtonRow:IsA("Frame")) then
		if accessButtonRow then
			accessButtonRow:Destroy()
		end

		accessButtonRow = Instance.new("Frame")
		accessButtonRow.Name = "AccessButtonRow"
		accessButtonRow.Parent = accessGate
	end

	accessButtonRow.Size = UDim2.new(1, 0, 0, 38)
	accessButtonRow.Position = UDim2.new(0, 0, 0, 134)
	accessButtonRow.BackgroundTransparency = 1
	accessButtonRow.BorderSizePixel = 0
	local trialButton = accessButtonRow:FindFirstChild("TrialButton")

	if not (trialButton and trialButton:IsA("TextButton")) then
		if trialButton then
			trialButton:Destroy()
		end

		trialButton = Instance.new("TextButton")
		trialButton.Name = "TrialButton"
		trialButton.Parent = accessButtonRow
	end

	trialButton.Size = UDim2.new(0.5, -4, 1, 0)
	trialButton.Position = UDim2.new(0, 0, 0, 0)
	trialButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
	trialButton.Text = "Use Free Trial"
	trialButton.TextColor3 = Color3.new(1, 1, 1)
	trialButton.TextSize = 13
	trialButton.Font = Enum.Font.GothamBold
	trialButton.BorderSizePixel = 0
	trialButton.Active = true
	makeCorner(trialButton, 6) -- inferred equivalent call
	configureButtonText(trialButton, { MaxTextSize = 13, MinTextSize = 8 })
	local buyButton = accessButtonRow:FindFirstChild("BuyButton")

	if not (buyButton and buyButton:IsA("TextButton")) then
		if buyButton then
			buyButton:Destroy()
		end

		buyButton = Instance.new("TextButton")
		buyButton.Name = "BuyButton"
		buyButton.Parent = accessButtonRow
	end

	buyButton.Size = UDim2.new(0.5, -4, 1, 0)
	buyButton.Position = UDim2.new(1, 0, 0, 0)
	buyButton.AnchorPoint = Vector2.new(1, 0)
	buyButton.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
	buyButton.Text = "Buy Gamepass"
	buyButton.TextColor3 = Color3.new(1, 1, 1)
	buyButton.TextSize = 13
	buyButton.Font = Enum.Font.GothamBold
	buyButton.BorderSizePixel = 0
	buyButton.Active = true
	makeCorner(buyButton, 6) -- inferred equivalent call
	configureButtonText(buyButton, { MaxTextSize = 13, MinTextSize = 8 })
	local urlRow = midiBody:FindFirstChild("UrlRow")

	if not (urlRow and urlRow:IsA("Frame")) then
		if urlRow then
			urlRow:Destroy()
		end

		urlRow = Instance.new("Frame")
		urlRow.Name = "UrlRow"
		urlRow.Parent = midiBody
	end

	urlRow.LayoutOrder = 1
	urlRow.Size = UDim2.new(1, 0, 0, 34)
	urlRow.BackgroundTransparency = 1
	local urlClip = urlRow:FindFirstChild("UrlClip")

	if not (urlClip and urlClip:IsA("Frame")) then
		if urlClip then
			urlClip:Destroy()
		end

		urlClip = Instance.new("Frame")
		urlClip.Name = "UrlClip"
		urlClip.Parent = urlRow
	end

	urlClip.Size = UDim2.new(1, -80, 1, 0)
	urlClip.Position = UDim2.new(0, 0, 0, 0)
	urlClip.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	urlClip.BorderSizePixel = 0
	urlClip.Active = true
	urlClip.ClipsDescendants = true
	makeCorner(urlClip, 6) -- inferred equivalent call
	local urlBox = urlClip:FindFirstChild("UrlBox")

	if not (urlBox and urlBox:IsA("TextBox")) then
		if urlBox then
			urlBox:Destroy()
		end

		urlBox = Instance.new("TextBox")
		urlBox.Name = "UrlBox"
		urlBox.Parent = urlClip
	end

	urlBox.Size = UDim2.new(1, 0, 1, 0)
	urlBox.Position = UDim2.new(0, 0, 0, 0)
	urlBox.BackgroundTransparency = 1
	urlBox.Text = ""
	urlBox.PlaceholderText = "Paste MIDI RAW URL (https://...)"
	urlBox.TextColor3 = Color3.new(1, 1, 1)
	urlBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
	urlBox.TextSize = 12
	urlBox.Font = Enum.Font.Gotham
	urlBox.ClearTextOnFocus = false
	urlBox.BorderSizePixel = 0
	urlBox.Active = true
	urlBox.TextXAlignment = Enum.TextXAlignment.Left
	local uiPadding = urlBox:FindFirstChildOfClass("UIPadding")

	if not uiPadding then
		uiPadding = Instance.new("UIPadding")
		uiPadding.Name = "UIPadding"
		uiPadding.Parent = urlBox
	end

	uiPadding.PaddingLeft = UDim.new(0, 8)
	local loadButton = urlRow:FindFirstChild("LoadButton")

	if not (loadButton and loadButton:IsA("TextButton")) then
		if loadButton then
			loadButton:Destroy()
		end

		loadButton = Instance.new("TextButton")
		loadButton.Name = "LoadButton"
		loadButton.Parent = urlRow
	end

	loadButton.Size = UDim2.new(0, 72, 1, 0)
	loadButton.Position = UDim2.new(1, 0, 0, 0)
	loadButton.AnchorPoint = Vector2.new(1, 0)
	loadButton.BackgroundColor3 = Color3.fromRGB(20, 140, 255)
	loadButton.Text = "Load"
	loadButton.TextColor3 = Color3.new(1, 1, 1)
	loadButton.TextSize = 13
	loadButton.Font = Enum.Font.GothamBold
	loadButton.BorderSizePixel = 0
	makeCorner(loadButton, 6) -- inferred equivalent call
	configureButtonText(loadButton, { MaxTextSize = 13, MinTextSize = 8 })
	local statusRow = midiBody:FindFirstChild("StatusRow")

	if not (statusRow and statusRow:IsA("Frame")) then
		if statusRow then
			statusRow:Destroy()
		end

		statusRow = Instance.new("Frame")
		statusRow.Name = "StatusRow"
		statusRow.Parent = midiBody
	end

	statusRow.LayoutOrder = 2
	statusRow.Size = UDim2.new(1, 0, 0, 18)
	statusRow.BackgroundTransparency = 1
	local statusLabel = statusRow:FindFirstChild("StatusLabel")

	if not (statusLabel and statusLabel:IsA("TextLabel")) then
		if statusLabel then
			statusLabel:Destroy()
		end

		statusLabel = Instance.new("TextLabel")
		statusLabel.Name = "StatusLabel"
		statusLabel.Parent = statusRow
	end

	statusLabel.Size = UDim2.new(1, 0, 1, 0)
	statusLabel.Position = UDim2.new(0, 0, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
	statusLabel.TextSize = 11
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local controlsRow = midiBody:FindFirstChild("ControlsRow")

	if not (controlsRow and controlsRow:IsA("Frame")) then
		if controlsRow then
			controlsRow:Destroy()
		end

		controlsRow = Instance.new("Frame")
		controlsRow.Name = "ControlsRow"
		controlsRow.Parent = midiBody
	end

	controlsRow.LayoutOrder = 3
	controlsRow.Size = UDim2.new(1, 0, 0, 36)
	controlsRow.BackgroundTransparency = 1
	controlsRow.Visible = false
	local playPauseButton = controlsRow:FindFirstChild("PlayPauseButton")

	if not (playPauseButton and playPauseButton:IsA("TextButton")) then
		if playPauseButton then
			playPauseButton:Destroy()
		end

		playPauseButton = Instance.new("TextButton")
		playPauseButton.Name = "PlayPauseButton"
		playPauseButton.Parent = controlsRow
	end

	playPauseButton.Size = UDim2.new(0.5, -3, 1, 0)
	playPauseButton.Position = UDim2.new(0, 0, 0, 0)
	playPauseButton.AnchorPoint = Vector2.new(0, 0)
	playPauseButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
	playPauseButton.Text = "Play"
	playPauseButton.TextColor3 = Color3.new(1, 1, 1)
	playPauseButton.TextSize = 13
	playPauseButton.Font = Enum.Font.GothamBold
	playPauseButton.BorderSizePixel = 0
	makeCorner(playPauseButton, 6) -- inferred equivalent call
	configureButtonText(playPauseButton, { MaxTextSize = 13, MinTextSize = 8 })
	local stopButton = controlsRow:FindFirstChild("StopButton")

	if not (stopButton and stopButton:IsA("TextButton")) then
		if stopButton then
			stopButton:Destroy()
		end

		stopButton = Instance.new("TextButton")
		stopButton.Name = "StopButton"
		stopButton.Parent = controlsRow
	end

	stopButton.Size = UDim2.new(0.5, -3, 1, 0)
	stopButton.Position = UDim2.new(1, 0, 0, 0)
	stopButton.AnchorPoint = Vector2.new(1, 0)
	stopButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	stopButton.Text = "Stop"
	stopButton.TextColor3 = Color3.new(1, 1, 1)
	stopButton.TextSize = 13
	stopButton.Font = Enum.Font.GothamBold
	stopButton.BorderSizePixel = 0
	makeCorner(stopButton, 6) -- inferred equivalent call
	configureButtonText(stopButton, { MaxTextSize = 13, MinTextSize = 8 })
	local progressSection = midiBody:FindFirstChild("ProgressSection")

	if not (progressSection and progressSection:IsA("Frame")) then
		if progressSection then
			progressSection:Destroy()
		end

		progressSection = Instance.new("Frame")
		progressSection.Name = "ProgressSection"
		progressSection.Parent = midiBody
	end

	progressSection.LayoutOrder = 4
	progressSection.Size = UDim2.new(1, 0, 0, 38)
	progressSection.BackgroundTransparency = 1
	progressSection.Visible = false
	local timeLabel = progressSection:FindFirstChild("TimeLabel")

	if not (timeLabel and timeLabel:IsA("TextLabel")) then
		if timeLabel then
			timeLabel:Destroy()
		end

		timeLabel = Instance.new("TextLabel")
		timeLabel.Name = "TimeLabel"
		timeLabel.Parent = progressSection
	end

	timeLabel.Size = UDim2.new(1, 0, 0, 16)
	timeLabel.Position = UDim2.new(0, 0, 0, 0)
	timeLabel.BackgroundTransparency = 1
	timeLabel.Text = "0:00 / 0:00"
	timeLabel.TextColor3 = Color3.fromRGB(140, 140, 165)
	timeLabel.TextSize = 11
	timeLabel.Font = Enum.Font.Gotham
	timeLabel.TextXAlignment = Enum.TextXAlignment.Right
	timeLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local progressTrack = progressSection:FindFirstChild("ProgressTrack")

	if not (progressTrack and progressTrack:IsA("Frame")) then
		if progressTrack then
			progressTrack:Destroy()
		end

		progressTrack = Instance.new("Frame")
		progressTrack.Name = "ProgressTrack"
		progressTrack.Parent = progressSection
	end

	progressTrack.Size = UDim2.new(1, 0, 0, 16)
	progressTrack.Position = UDim2.new(0, 0, 0, 20)
	progressTrack.BackgroundTransparency = 1
	local uiSizeConstraint = progressTrack:FindFirstChildOfClass("UISizeConstraint")

	if uiSizeConstraint then
		uiSizeConstraint:Destroy()
	end

	local slider = createSlider(progressTrack, Color3.fromRGB(80, 170, 255))
	local fn2
	slider.onDrag(function(p)
		local v20, v21 = fn2()

		if v20 and v21 then
			timeLabel.Text = formatTime(p * v21) .. " / " .. formatTime(v21) -- inferred equivalent call
		elseif v2 then
			local displayedDuration = v2.DisplayedDuration or v2.TimeLength
			timeLabel.Text = formatTime(p * displayedDuration) .. " / " .. formatTime(displayedDuration) -- inferred equivalent call
		end
	end)
	slider.onRelease(function(p)
		local v20, v21 = fn2()

		if v20 and v21 then
			local v22 = p * v21

			if data.seekMidi2DPlayback then
				data.seekMidi2DPlayback(v22)
			end
		elseif v2 then
			local v22 = p * (v2.DisplayedDuration or v2.TimeLength)

			if v2.InstructionProgress then
				table.clear(v2.InstructionProgress)
			end

			if v2.EndOfTracks then
				table.clear(v2.EndOfTracks)
			end

			v2:SetTimePosition(v22)
		end
	end)
	local speedSection = midiBody:FindFirstChild("SpeedSection")

	if not (speedSection and speedSection:IsA("Frame")) then
		if speedSection then
			speedSection:Destroy()
		end

		speedSection = Instance.new("Frame")
		speedSection.Name = "SpeedSection"
		speedSection.Parent = midiBody
	end

	speedSection.LayoutOrder = 5
	speedSection.Size = UDim2.new(1, 0, 0, 38)
	speedSection.BackgroundTransparency = 1
	local speedLabel = speedSection:FindFirstChild("SpeedLabel")

	if not (speedLabel and speedLabel:IsA("TextLabel")) then
		if speedLabel then
			speedLabel:Destroy()
		end

		speedLabel = Instance.new("TextLabel")
		speedLabel.Name = "SpeedLabel"
		speedLabel.Parent = speedSection
	end

	speedLabel.Size = UDim2.new(1, 0, 0, 16)
	speedLabel.Position = UDim2.new(0, 0, 0, 0)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Text = "Speed: 1x"
	speedLabel.TextColor3 = Color3.fromRGB(140, 140, 165)
	speedLabel.TextSize = 11
	speedLabel.Font = Enum.Font.Gotham
	speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	speedLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local speedTrack = speedSection:FindFirstChild("SpeedTrack")

	if not (speedTrack and speedTrack:IsA("Frame")) then
		if speedTrack then
			speedTrack:Destroy()
		end

		speedTrack = Instance.new("Frame")
		speedTrack.Name = "SpeedTrack"
		speedTrack.Parent = speedSection
	end

	speedTrack.Size = UDim2.new(1, 0, 0, 16)
	speedTrack.Position = UDim2.new(0, 0, 0, 20)
	speedTrack.BackgroundTransparency = 1
	local uiSizeConstraint2 = speedTrack:FindFirstChildOfClass("UISizeConstraint")

	if uiSizeConstraint2 then
		uiSizeConstraint2:Destroy()
	end

	local slider2 = createSlider(speedTrack, Color3.fromRGB(100, 220, 130))
	local timeMultiplier = 1
	local function snapSpeed(p) -- 2 equivalent calls inferred from this helper
		return (math.clamp(math.floor((0.25 + p * 3.75) / 0.25 + 0.5) * 0.25, 0.25, 4))
	end

	local function fracFromSpeed(p) -- 2 equivalent calls inferred from this helper
		return (p - 0.25) / 3.75
	end

	slider2.setFraction(fracFromSpeed(1)) -- inferred equivalent call
	slider2.onDrag(function(p)
		local timeMultiplier2 = snapSpeed(p) -- inferred equivalent call
		timeMultiplier = timeMultiplier2
		speedLabel.Text = "Speed: " .. formatSpeed(timeMultiplier2) -- inferred equivalent call

		if v2 then
			v2.TimeMultiplier = timeMultiplier2
		end

		if v5 and data.isMidi2DRunning and data.isMidi2DRunning() and data.setMidi2DSpeed then
			data.setMidi2DSpeed(timeMultiplier2)
		end
	end)
	slider2.onRelease(function(p)
		local timeMultiplier2 = snapSpeed(p) -- inferred equivalent call
		timeMultiplier = timeMultiplier2
		speedLabel.Text = "Speed: " .. formatSpeed(timeMultiplier2) -- inferred equivalent call
		slider2.setFraction(fracFromSpeed(timeMultiplier2)) -- inferred equivalent call

		if v2 then
			v2.TimeMultiplier = timeMultiplier2
		end

		if v5 and data.isMidi2DRunning and data.isMidi2DRunning() and data.setMidi2DSpeed then
			data.setMidi2DSpeed(timeMultiplier2)
		end
	end)
	local nowPlayingRow = midiBody:FindFirstChild("NowPlayingRow")

	if not (nowPlayingRow and nowPlayingRow:IsA("Frame")) then
		if nowPlayingRow then
			nowPlayingRow:Destroy()
		end

		nowPlayingRow = Instance.new("Frame")
		nowPlayingRow.Name = "NowPlayingRow"
		nowPlayingRow.Parent = midiBody
	end

	nowPlayingRow.LayoutOrder = 6
	nowPlayingRow.Size = UDim2.new(1, 0, 0, 18)
	nowPlayingRow.BackgroundTransparency = 1
	nowPlayingRow.Visible = false
	local songTitle = nowPlayingRow:FindFirstChild("SongTitle")

	if not (songTitle and songTitle:IsA("TextLabel")) then
		if songTitle then
			songTitle:Destroy()
		end

		songTitle = Instance.new("TextLabel")
		songTitle.Name = "SongTitle"
		songTitle.Parent = nowPlayingRow
	end

	songTitle.Size = UDim2.new(1, 0, 1, 0)
	songTitle.Position = UDim2.new(0, 0, 0, 0)
	songTitle.BackgroundTransparency = 1
	songTitle.Text = ""
	songTitle.TextColor3 = Color3.fromRGB(180, 180, 210)
	songTitle.TextSize = 11
	songTitle.Font = Enum.Font.Gotham
	songTitle.TextXAlignment = Enum.TextXAlignment.Left
	songTitle.TextTruncate = Enum.TextTruncate.AtEnd
	local communityRow = midiBody:FindFirstChild("CommunityRow")

	if not (communityRow and communityRow:IsA("Frame")) then
		if communityRow then
			communityRow:Destroy()
		end

		communityRow = Instance.new("Frame")
		communityRow.Name = "CommunityRow"
		communityRow.Parent = midiBody
	end

	communityRow.LayoutOrder = 7
	communityRow.Size = UDim2.new(1, 0, 0, 44)
	communityRow.BackgroundTransparency = 1
	communityRow.BorderSizePixel = 0
	local communityButton = communityRow:FindFirstChild("CommunityButton")

	if not (communityButton and communityButton:IsA("TextButton")) then
		if communityButton then
			communityButton:Destroy()
		end

		communityButton = Instance.new("TextButton")
		communityButton.Name = "CommunityButton"
		communityButton.Parent = communityRow
	end

	communityButton.Size = UDim2.new(1, 0, 1, 0)
	communityButton.Position = UDim2.new(0, 0, 0, 0)
	communityButton.BackgroundColor3 = Color3.fromRGB(114, 137, 218)
	communityButton.Text = "Browse Community Uploads"
	communityButton.TextColor3 = Color3.new(1, 1, 1)
	communityButton.TextSize = 16
	communityButton.Font = Enum.Font.GothamBold
	communityButton.BorderSizePixel = 0
	communityButton.Active = true
	makeCorner(communityButton, 6) -- inferred equivalent call
	configureButtonText(communityButton, { MaxTextSize = 16, MinTextSize = 9 })
	local dividerRecent = midiBody:FindFirstChild("DividerRecent")

	if not (dividerRecent and dividerRecent:IsA("Frame")) then
		if dividerRecent then
			dividerRecent:Destroy()
		end

		dividerRecent = Instance.new("Frame")
		dividerRecent.Name = "DividerRecent"
		dividerRecent.Parent = midiBody
	end

	dividerRecent.LayoutOrder = 8
	dividerRecent.Size = UDim2.new(1, 0, 0, 1)
	dividerRecent.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	dividerRecent.BorderSizePixel = 0
	local recentHeader = midiBody:FindFirstChild("RecentHeader")

	if not (recentHeader and recentHeader:IsA("TextLabel")) then
		if recentHeader then
			recentHeader:Destroy()
		end

		recentHeader = Instance.new("TextLabel")
		recentHeader.Name = "RecentHeader"
		recentHeader.Parent = midiBody
	end

	recentHeader.LayoutOrder = 9
	recentHeader.Size = UDim2.new(1, 0, 0, 20)
	recentHeader.BackgroundTransparency = 1
	recentHeader.Text = "Recent MIDIs"
	recentHeader.TextColor3 = Color3.fromRGB(140, 140, 160)
	recentHeader.TextSize = 11
	recentHeader.Font = Enum.Font.Gotham
	recentHeader.TextXAlignment = Enum.TextXAlignment.Left
	local recentSection = midiBody:FindFirstChild("RecentSection")

	if not (recentSection and recentSection:IsA("Frame")) then
		if recentSection then
			recentSection:Destroy()
		end

		recentSection = Instance.new("Frame")
		recentSection.Name = "RecentSection"
		recentSection.Parent = midiBody
	end

	recentSection.LayoutOrder = 10
	recentSection.Size = UDim2.new(1, 0, 0, 0)
	recentSection.AutomaticSize = Enum.AutomaticSize.Y
	recentSection.BackgroundTransparency = 1
	recentSection.BorderSizePixel = 0
	local uiListLayout2 = recentSection:FindFirstChildOfClass("UIListLayout")

	if not uiListLayout2 then
		uiListLayout2 = Instance.new("UIListLayout")
		uiListLayout2.Name = "UIListLayout"
		uiListLayout2.Parent = recentSection
	end

	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Padding = UDim.new(0, 0)
	local recentHeader2 = recentSection:FindFirstChild("RecentHeader")

	if recentHeader2 then
		recentHeader2:Destroy()
	end

	local recentItems = recentSection:FindFirstChild("RecentItems")

	if not (recentItems and recentItems:IsA("Frame")) then
		if recentItems then
			recentItems:Destroy()
		end

		recentItems = Instance.new("Frame")
		recentItems.Name = "RecentItems"
		recentItems.Parent = recentSection
	end

	recentItems.LayoutOrder = 1
	recentItems.Size = UDim2.new(1, 0, 0, 0)
	recentItems.AutomaticSize = Enum.AutomaticSize.Y
	recentItems.BackgroundTransparency = 1
	recentItems.BorderSizePixel = 0
	configureTileGrid(recentItems)
	clearTemplateButtons(recentItems)
	local emptyRecentLabel = recentItems:FindFirstChild("EmptyRecentLabel")

	if not (emptyRecentLabel and emptyRecentLabel:IsA("TextLabel")) then
		if emptyRecentLabel then
			emptyRecentLabel:Destroy()
		end

		emptyRecentLabel = Instance.new("TextLabel")
		emptyRecentLabel.Name = "EmptyRecentLabel"
		emptyRecentLabel.Parent = recentItems
	end

	emptyRecentLabel.LayoutOrder = 99
	emptyRecentLabel.Size = UDim2.new(1, 0, 0, 42)
	emptyRecentLabel.BackgroundTransparency = 1
	emptyRecentLabel.Text = "No recent MIDIs."
	emptyRecentLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
	emptyRecentLabel.TextSize = 11
	emptyRecentLabel.Font = Enum.Font.Gotham
	emptyRecentLabel.TextXAlignment = Enum.TextXAlignment.Left

	local fn3
	local dividerBuiltin = midiBody:FindFirstChild("DividerBuiltin")

	if not (dividerBuiltin and dividerBuiltin:IsA("Frame")) then
		if dividerBuiltin then
			dividerBuiltin:Destroy()
		end

		dividerBuiltin = Instance.new("Frame")
		dividerBuiltin.Name = "DividerBuiltin"
		dividerBuiltin.Parent = midiBody
	end

	dividerBuiltin.LayoutOrder = 11
	dividerBuiltin.Size = UDim2.new(1, 0, 0, 1)
	dividerBuiltin.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	dividerBuiltin.BorderSizePixel = 0
	local builtinHeader = midiBody:FindFirstChild("BuiltinHeader")

	if not (builtinHeader and builtinHeader:IsA("TextLabel")) then
		if builtinHeader then
			builtinHeader:Destroy()
		end

		builtinHeader = Instance.new("TextLabel")
		builtinHeader.Name = "BuiltinHeader"
		builtinHeader.Parent = midiBody
	end

	builtinHeader.LayoutOrder = 12
	builtinHeader.Size = UDim2.new(1, 0, 0, 20)
	builtinHeader.BackgroundTransparency = 1
	builtinHeader.Text = "Built-in Songs"
	builtinHeader.TextColor3 = Color3.fromRGB(140, 140, 160)
	builtinHeader.TextSize = 11
	builtinHeader.Font = Enum.Font.Gotham
	builtinHeader.TextXAlignment = Enum.TextXAlignment.Left
	local builtinSection = midiBody:FindFirstChild("BuiltinSection")

	if not (builtinSection and builtinSection:IsA("Frame")) then
		if builtinSection then
			builtinSection:Destroy()
		end

		builtinSection = Instance.new("Frame")
		builtinSection.Name = "BuiltinSection"
		builtinSection.Parent = midiBody
	end

	builtinSection.LayoutOrder = 13
	builtinSection.Size = UDim2.new(1, 0, 0, 0)
	builtinSection.AutomaticSize = Enum.AutomaticSize.Y
	builtinSection.BackgroundTransparency = 1
	builtinSection.BorderSizePixel = 0
	local uiListLayout3 = builtinSection:FindFirstChildOfClass("UIListLayout")

	if not uiListLayout3 then
		uiListLayout3 = Instance.new("UIListLayout")
		uiListLayout3.Name = "UIListLayout"
		uiListLayout3.Parent = builtinSection
	end

	uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout3.Padding = UDim.new(0, 0)
	local builtinHeader2 = builtinSection:FindFirstChild("BuiltinHeader")

	if builtinHeader2 then
		builtinHeader2:Destroy()
	end

	clearTemplateButtons(builtinSection)
	local builtinItems = builtinSection:FindFirstChild("BuiltinItems")

	if not (builtinItems and builtinItems:IsA("Frame")) then
		if builtinItems then
			builtinItems:Destroy()
		end

		builtinItems = Instance.new("Frame")
		builtinItems.Name = "BuiltinItems"
		builtinItems.Parent = builtinSection
	end

	builtinItems.LayoutOrder = 1
	builtinItems.Size = UDim2.new(1, 0, 0, 0)
	builtinItems.AutomaticSize = Enum.AutomaticSize.Y
	builtinItems.BackgroundTransparency = 1
	builtinItems.BorderSizePixel = 0
	configureTileGrid(builtinItems)
	clearTemplateButtons(builtinItems)
	local noBuiltInSongs = builtinItems:FindFirstChild("NoBuiltInSongs")

	if noBuiltInSongs then
		noBuiltInSongs:Destroy()
	end

	if #v > 0 then
		for i, v20 in ipairs(v) do
			connectActivated(makeSongTileButton(builtinItems, v20.name, i), function()
				if object2 then
					object2:Play()
				end

				urlBox.Text = ""
				fn3(v20.url, v20.name, true)
			end)
		end
	else
		local noBuiltInSongs2 = Instance.new("TextLabel")
		noBuiltInSongs2.Name = "NoBuiltInSongs"
		noBuiltInSongs2.LayoutOrder = 1
		noBuiltInSongs2.Size = UDim2.new(1, 0, 0, 42)
		noBuiltInSongs2.BackgroundTransparency = 1
		noBuiltInSongs2.Text = "No built-in songs yet."
		noBuiltInSongs2.TextColor3 = Color3.fromRGB(100, 100, 120)
		noBuiltInSongs2.TextSize = 11
		noBuiltInSongs2.Font = Enum.Font.Gotham
		noBuiltInSongs2.TextXAlignment = Enum.TextXAlignment.Left
		noBuiltInSongs2.Parent = builtinItems
	end

	connectActivated(communityButton, function()
		if object2 then
			object2:Play()
		end

		midiModal.Visible = false
		OpenCommunitySheets:Fire("MIDI")
	end)
	applyGuiObjectZTree(midiModal, midiModal.ZIndex)

	local flag2 = false
	local flag3 = false
	local flag4 = false
	local v20 = false

	fn2 = function()
		if not (v5 and data.isMidi2DRunning and data.isMidi2DRunning() and data.getMidi2DProgress) then
			return nil
		end

		local midi2DProgress = data.getMidi2DProgress()

		if typeof(midi2DProgress) ~= "table" then
			return nil
		end

		local duration = tonumber(midi2DProgress.duration)

		if duration and not (duration <= 0) then
			return math.clamp(tonumber(midi2DProgress.position) or 0, 0, duration), duration
		end

		return nil
	end

	local function setStatus(text, color) -- 14 equivalent calls inferred from this helper
		statusLabel.Text = text
		statusLabel.TextColor3 = color or Color3.fromRGB(150, 150, 170)
	end

	local v21 = nil
	local count2 = 0
	local v22 = nil
	local total = 0

	local function setTitleCountdown(p) -- 3 equivalent calls inferred from this helper
		titleLabel.Text = "MIDI Player (" .. formatTrialCountdown(p) .. ")" -- inferred equivalent call
	end

	local function updateTitleFromAccessState(p)
		local v23 = typeof(p) == "table" and p or {}

		if v23.OwnsGamepass == true then
			v22 = nil
			titleLabel.Text = "MIDI Player"
		elseif v23.TrialActive == true then
			local v24 = tonumber(v23.TrialSecondsRemaining)

			if not v24 and tonumber(v23.TrialExpiresAt) then
				v24 = math.max(0, (math.floor(tonumber(v23.TrialExpiresAt) - os.time())))
			end

			local v25 = math.max(0, (math.floor(v24 or 0)))
			v22 = os.clock() + v25
			setTitleCountdown(v25) -- inferred equivalent call
		else
			v22 = nil
			setTitleCountdown(0) -- inferred equivalent call
		end
	end

	local function fetchAccessState()
		if not GetMidiPlayerAccess then
			return {
				HasAccess = false,
				CanStartTrial = false,
				Reason = "AccessRemoteMissing",
				GamePassId = 0,
				TrialDurationSeconds = 86400
			}
		end

		local success, result = pcall(function()
			return GetMidiPlayerAccess:InvokeServer()
		end)

		if success and typeof(result) == "table" then
			return result
		end

		return {
			HasAccess = false,
			CanStartTrial = false,
			Reason = "AccessCheckFailed",
			GamePassId = 0,
			TrialDurationSeconds = 86400
		}
	end

	local function applyAccessState(p): boolean
		v21 = typeof(p) == "table" and p or {}
		updateTitleFromAccessState(v21)

		if v21.HasAccess == true then
			midiBody.Visible = true
			accessGate.Visible = false
			return true
		else
			midiBody.Visible = false
			accessGate.Visible = true
			local trialDurationSeconds = tonumber(v21.TrialDurationSeconds) or 86400

			if v21.Reason == "ProfileNotLoaded" then
				accessBody.Text = "Your data is still loading. Try again in a few seconds."
				accessTrialInfo.Text = ""
			elseif v21.TrialUsed == true then
				accessBody.Text = "Your free trial has ended. Buy the gamepass to keep using the MIDI Player."
				accessTrialInfo.Text = "The free trial can only be used once."
			else
				accessBody.Text = "Start a free 24-hour trial or buy the gamepass for permanent access."
				accessTrialInfo.Text = "Trial duration: " .. formatTrialTime(trialDurationSeconds) .. ". The timer keeps running after you leave."
			end

			local canStartTrial = v21.CanStartTrial == true
			trialButton.Visible = canStartTrial
			trialButton.Active = canStartTrial
			trialButton.AutoButtonColor = canStartTrial

			if canStartTrial then
				trialButton.Size = UDim2.new(0.5, -4, 1, 0)
				trialButton.Position = UDim2.new(0, 0, 0, 0)
				trialButton.AnchorPoint = Vector2.new(0, 0)
				buyButton.Size = UDim2.new(0.5, -4, 1, 0)
				buyButton.Position = UDim2.new(1, 0, 0, 0)
				buyButton.AnchorPoint = Vector2.new(1, 0)
			else
				buyButton.Size = UDim2.new(1, 0, 1, 0)
				buyButton.Position = UDim2.new(0, 0, 0, 0)
				buyButton.AnchorPoint = Vector2.new(0, 0)
			end

			local v23 = math.floor(tonumber(v21.GamePassId) or 0) > 0

			buyButton.Active = v23
			buyButton.AutoButtonColor = v23
			buyButton.BackgroundColor3 = v23 and Color3.fromRGB(60, 160, 255) or Color3.fromRGB(80, 80, 90)
			return false
		end
	end

	local function refreshAccessState(fn4) -- 1 equivalent call inferred from this helper
		count2 += 1
		local v23 = count2
		midiBody.Visible = false
		accessGate.Visible = true
		accessBody.Text = "Checking MIDI Player access..."
		accessTrialInfo.Text = ""

		task.spawn(function()
			local v24 = fetchAccessState()

			if v23 ~= count2 then
				return
			end

			local v25 = applyAccessState(v24)

			if fn4 then
				fn4(v25, v24)
			end
		end)
	end

	RunService.Heartbeat:Connect(function(dt)
		if not v22 then
			return
		end

		total += dt

		if total < 0.25 then
			return
		end

		total = 0
		local v23 = math.max(0, (math.ceil(v22 - os.clock())))
		setTitleCountdown(v23) -- inferred equivalent call

		if v23 <= 0 then
			v22 = nil

			if midiModal.Visible then
				count2 += 1
				local v24 = count2
				midiBody.Visible = false
				accessGate.Visible = true
				accessBody.Text = "Checking MIDI Player access..."
				accessTrialInfo.Text = ""

				local v25 = nil
				task.spawn(function()
					local v26 = fetchAccessState()

					if v24 ~= count2 then
						return
					end

					local v27 = applyAccessState(v26)

					if v25 then
						v25(v27, v26)
					end
				end)
			end
		end
	end)

	local function ensureAccessForAction() -- 1 equivalent call inferred from this helper
		if v21 and v21.HasAccess == true then
			return true
		end

		return applyAccessState(fetchAccessState())
	end

	connectActivated(trialButton, function()
		if object2 then
			object2:Play()
		end

		if not StartMidiPlayerTrial then
			accessTrialInfo.Text = "Trial service is not ready yet."
			return
		end

		trialButton.Text = "Starting..."
		trialButton.Active = false
		task.spawn(function()
			local success, result, v23, v24 = pcall(function()
				return StartMidiPlayerTrial:InvokeServer()
			end)

			trialButton.Text = "Use Free Trial"
			trialButton.Active = true

			if success and result == true and typeof(v24) == "table" then
				if applyAccessState(v24) then
					setStatus("Free trial active: " .. formatTrialTime(v24.TrialSecondsRemaining) .. " left.") -- inferred equivalent call
				end
			elseif success and typeof(v24) == "table" then
				applyAccessState(v24)
				accessTrialInfo.Text = tostring(v23 or "Could not start trial.")
			else
				accessTrialInfo.Text = "Could not start trial. Try again soon."
			end
		end)
	end)

	connectActivated(buyButton, function()
		if object2 then
			object2:Play()
		end

		local v23 = v21 or fetchAccessState()
		v21 = v23
		local gamePassId = math.floor(tonumber(v23.GamePassId) or 0)

		if gamePassId <= 0 then
			accessTrialInfo.Text = "Gamepass is not configured yet."
			return
		end

		if CheckGamepassEntitlement then
			local success, result = pcall(function()
				return CheckGamepassEntitlement:InvokeServer(gamePassId)
			end)

			if success and result == true then
				accessTrialInfo.Text = "MIDI Player is already unlocked, or a gift is being delivered."
				return
			end

			if not success then
				accessTrialInfo.Text = "Purchase check failed. Try again."
				return
			end
		end

		MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, gamePassId)
	end)

	if MidiPlayerAccessUpdated then
		MidiPlayerAccessUpdated.OnClientEvent:Connect(function(p)
			if typeof(p) ~= "table" then
				return
			end

			if applyAccessState(p) and midiModal.Visible then
				setStatus("MIDI Player unlocked.") -- inferred equivalent call
			end
		end)
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(instance2, p, p2)
		if typeof(instance2) ~= "Instance" then
			p2 = p
			p = instance2
		end

		if p2 ~= true then
			return
		end

		local gamePassId = math.floor(tonumber(v21 and v21.GamePassId) or 0)

		if gamePassId > 0 and math.floor(tonumber(p) or 0) ~= gamePassId then
			return
		end

		local function fn4(p3)
			if p3 then
				setStatus("MIDI Player unlocked.") -- inferred equivalent call
			end
		end

		refreshAccessState(fn4) -- inferred equivalent call
	end)

	local function resetPlaybackUi(value)
		controlsRow.Visible = false
		progressSection.Visible = false
		nowPlayingRow.Visible = false
		songTitle.Text = ""
		playPauseButton.Text = "Play"
		playPauseButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
		flag3 = false
		flag4 = false
		v20 = false
		lastTime = nil
		slider.setFraction(0)
		timeLabel.Text = "0:00 / 0:00"
		statusLabel.Text = value or ""
		statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
	end

	local function onSongComplete() -- 1 equivalent call inferred from this helper
		resetPlaybackUi("Finished.")
	end

	fn = function()
		resetPlaybackUi("Stopped.")
	end

	local fn4

	local function rebuildRecentList()
		clearTemplateButtons(recentItems)
		emptyRecentLabel.Visible = #v6 == 0

		for i, v23 in ipairs(v6) do
			connectActivated(makeSongTileButton(recentItems, v23.name, i), function()
				if object2 then
					object2:Play()
				end

				urlBox.Text = v23.hideUrl and "" or v23.url
				fn4(v23.buffer, v23.name, v23.readyStatus)
			end)
		end

		applyGuiObjectZTree(midiModal, midiModal.ZIndex)
	end

	local function formatFetchReadyStatus(value, p) -- 1 equivalent call inferred from this helper
		local v23 = type(p) == "table" and tostring(p.BackupLabel or "") or ""

		if v23 == "" then
			local v24 = tostring(value or "")
			v23 = v24 == "Backup" and "Backup available" or v24 == "Live" and "Original link" or ""
		end

		if v23 == "" then
			return "Ready. Press Play to start."
		end

		return "Ready. " .. v23 .. "."
	end

	local function addToRecent(name, url, result, p, readyStatus)
		for i = #v6, 1, -1 do
			if v6[i].url == url then
				table.remove(v6, i)
			end
		end

		table.insert(v6, 1, {
			name = name,
			url = url,
			buffer = result,
			hideUrl = p == true,
			readyStatus = readyStatus
		})

		while #v6 > 5 do
			table.remove(v6)
		end

		rebuildRecentList()
	end

	fn4 = function(p, value, value2)
		setStatus("Parsing...") -- inferred equivalent call
		controlsRow.Visible = false
		progressSection.Visible = false
		nowPlayingRow.Visible = false
		flag3 = false
		flag4 = false
		playPauseButton.Text = "Play"
		playPauseButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
		slider.setFraction(0)
		timeLabel.Text = "0:00 / 0:00"
		v5 = nil

		local function fn5(p2)
			timeLabel.Text = "0:00 / " .. formatTime(p2.DisplayedDuration or p2.TimeLength) -- inferred equivalent call
			progressSection.Visible = true
			controlsRow.Visible = true
			songTitle.Text = value or "MIDI"
			nowPlayingRow.Visible = true
			local v23 = build2DSourceFromPlayer(p2, value)
			v5 = v23

			if v23 then
				v23.showModePanel = false
			end

			if v23 and data.onMidi2DSourceReady then
				data.onMidi2DSourceReady(v23)
			end

			statusLabel.Text = value2 or "Ready. Press Play to start."
			statusLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
		end
		local function fn6(p2)
			setStatus("Error: " .. tostring(p2), Color3.fromRGB(255, 100, 100)) -- inferred equivalent call
			controlsRow.Visible = false
			progressSection.Visible = false
			nowPlayingRow.Visible = false
		end

		prepareMidi(p, fn5, fn6) -- inferred equivalent call
	end

	local v23 = 0
	RunService.Heartbeat:Connect(function()
		local v24, v25 = fn2()

		if v24 and v25 then
			v23 = 0
			v20 = true

			if not flag4 then
				flag4 = true
			end

			if progressSection then
				progressSection.Visible = true
			end

			if controlsRow then
				controlsRow.Visible = true
			end

			if nowPlayingRow then
				nowPlayingRow.Visible = true
			end

			if songTitle and songTitle.Text == "" and v5 then
				songTitle.Text = tostring(v5.name or v5.Name or "MIDI")
			end

			if not slider.getIsDragging() then
				slider.setFraction((math.min(v24 / v25, 1)))
				timeLabel.Text = formatTime(v24) .. " / " .. formatTime(v25) -- inferred equivalent call
			end

			if data.isMidi2DPaused and data.isMidi2DPaused() then
				playPauseButton.Text = "Resume 2D"
				playPauseButton.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
			else
				playPauseButton.Text = "Pause 2D"
				playPauseButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
			end
		elseif v20 and v5 and data.isMidi2DRunning and not data.isMidi2DRunning() then
			v23 = 0
			v20 = false
			resetPlaybackUi("Finished.")
		else
			if not v2 then
				v23 = 0
				return
			end

			local timeLength = v2.TimeLength
			local timePosition = v2.TimePosition

			if timePosition < v23 - 1 then
				releaseAllNotes() -- inferred equivalent call
			end

			v23 = timePosition

			if v9 > 0 and not flag3 and flag4 and tick() - v9 > 20 then
				v9 = 0
				stopPlayback()
				onSongComplete() -- inferred equivalent call
			else
				if slider.getIsDragging() then
					return
				end

				local displayedDuration = v2.DisplayedDuration or timeLength > 0 and timeLength or nil

				if displayedDuration and displayedDuration > 0 then
					slider.setFraction((math.min(timePosition / displayedDuration, 1)))
					timeLabel.Text = formatTime(timePosition) .. " / " .. formatTime(displayedDuration) -- inferred equivalent call
				else
					slider.setFraction(0)
					timeLabel.Text = formatTime(timePosition) .. " / ..." -- inferred equivalent call
				end
			end
		end
	end)

	fn3 = function(url, name, p, publicId, p2)
		if flag2 then
			return
		end

		if ensureAccessForAction() then -- inferred equivalent call
			local v24 = type(p2) == "table" and p2 or {}
			local v25 = v24.PreferBackup == true or v24.UseBackup == true
			local backupId = tostring(v24.BackupId or v24.CanonicalId or "")
			local canonicalId = tostring(v24.CanonicalId or v24.BackupId or "")
			local v26

			if tostring(url or "") == "" then
				v26 = false
			else
				v26 = tostring(url or ""):match("^https?://") ~= nil
			end

			flag2 = true
			local color = Color3.fromRGB(100, 200, 255)
			statusLabel.Text = v25 and "Loading saved backup..." or "Fetching..."
			statusLabel.TextColor3 = color or Color3.fromRGB(150, 150, 170)

			loadButton.Text = "..."
			loadButton.Active = false
			task.spawn(function()
				local success, result, v27, v28 = pcall(function()
					publicId = tostring(publicId or "")

					if publicId == "" then
						return FetchMidiRemote:InvokeServer(url)
					end

					local v27 = {
						Url = v25 and "" or v26 and url or "",
						PublicId = publicId,
						BackupId = backupId,
						CanonicalId = canonicalId,
						PreferBackup = v25,
						UseBackup = v25
					}

					local v28, v29, v30 = FetchMidiRemote:InvokeServer(v27)

					if type(v28) == "string" and v28 ~= "" then
						return v28, v29, v30
					end

					if v25 and v26 then
						v27.Url = url
						v27.PreferBackup = false
						v27.UseBackup = false
						local v31, v32, v38 = FetchMidiRemote:InvokeServer(v27)

						if type(v31) == "string" and v31 ~= "" then
							return v31, v32, v38
						end
					end

					return v28, v29, v30
				end)

				flag2 = false
				loadButton.Text = "Load"
				loadButton.Active = true

				if success then
					if result then
						local readyStatus = formatFetchReadyStatus(v27, v28) -- inferred equivalent call
						addToRecent(name, url, result, p, readyStatus)

						if p then
							urlBox.Text = ""
						end

						fn4(result, name, readyStatus)
					else
						local v29 = tostring(v27 or "")

						if
							v29 == "Refresh Community MIDI before loading this upload."
							and publicId ~= ""
							and v24.AutoRefreshed ~= true
						then
							setStatus("Refreshing Community MIDI...", Color3.fromRGB(100, 200, 255)) -- inferred equivalent call
							local v30 = false
							pcall(function()
								v30 = RefreshCommunityMidiForLoad:Invoke(publicId) == true
							end)

							if v30 then
								local v31 = {}

								for k, v32 in pairs(v24) do
									v31[k] = v32
								end

								v31.AutoRefreshed = true
								fn3(url, name, p, publicId, v31)
								return
							end
						end

						local v30

						if v29 == "" then
							v30 = v25 and "Could not load the saved backup." or "Failed to fetch MIDI."
						else
							v30 = v29 == "Refresh Community MIDI before loading this upload."
								and v25
								and "This upload changed or is no longer available."
								or v29
						end

						setStatus(v30, Color3.fromRGB(255, 100, 100)) -- inferred equivalent call
					end
				else
					setStatus("Failed to fetch MIDI.", Color3.fromRGB(255, 100, 100)) -- inferred equivalent call
				end
			end)
		else
			setStatus("MIDI Player requires gamepass or active trial.", Color3.fromRGB(255, 120, 120)) -- inferred equivalent call
		end
	end

	connectActivated(loadButton, function()
		if object2 then
			object2:Play()
		end

		local match = urlBox.Text:match("^%s*(.-)%s*$")

		if match == "" then
			setStatus("Please enter a URL.", Color3.fromRGB(255, 200, 50)) -- inferred equivalent call
		elseif match:match("^https?://") then
			local v24 = match:match("([^/]+)%.mid[i]?") or match:match("([^/?#]+)$") or "MIDI"
			fn3(match, v24)
		else
			setStatus("URL must start with https://", Color3.fromRGB(255, 100, 100)) -- inferred equivalent call
		end
	end)

	connectActivated(playPauseButton, function()
		if object2 then
			object2:Play()
		end

		if not v2 then
			return
		end

		if v5 and data.isMidi2DRunning and data.isMidi2DRunning() then
			local v24 = data.toggleMidi2DPause and data.toggleMidi2DPause()
			playPauseButton.Text = v24 and "Resume 2D" or "Pause 2D"
			playPauseButton.BackgroundColor3 = v24 and Color3.fromRGB(60, 160, 255) or Color3.fromRGB(200, 150, 50)
			local color = v24 and Color3.fromRGB(255, 190, 80) or Color3.fromRGB(120, 210, 255)
			statusLabel.Text = v24 and "2D paused." or "2D resumed."
			statusLabel.TextColor3 = color or Color3.fromRGB(150, 150, 170)
		elseif flag4 then
			if flag3 then
				if lastTime and v9 > 0 then
					v9 += tick() - lastTime
				end

				lastTime = nil
				v11 = true
				v12 = 0
				v2:Play()
				task.spawn(showMidiOverhead)
				flag3 = false
				playPauseButton.Text = "Pause"
				playPauseButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
			else
				v2:Pause()
				v11 = false
				flag3 = true
				lastTime = tick()
				releaseAllNotes() -- inferred equivalent call
				playPauseButton.Text = "Resume"
				playPauseButton.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
			end
		else
			if v5 and data.setMidi2DSpeed then
				data.setMidi2DSpeed(timeMultiplier)
			end

			if v5 and data.onMidi2DPlayRequested and data.onMidi2DPlayRequested(v5) then
				setStatus("Choose a 2D mode above.", Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
				midiModal.Visible = false
			else
				flag4 = true
				v2.TimeMultiplier = timeMultiplier
				beginPlayback(data, onSongComplete, "MidiPlayer")
				playPauseButton.Text = "Pause"
				playPauseButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
				songTitle.Text = "Now playing: " .. (songTitle.Text == "" and "MIDI" or songTitle.Text or "MIDI")
				setStatus("") -- inferred equivalent call
			end
		end
	end)

	connectActivated(stopButton, function()
		if object2 then
			object2:Play()
		end

		if v5 and data.isMidi2DRunning and data.isMidi2DRunning() then
			if data.stopMidi2DPlayback then
				data.stopMidi2DPlayback()
			end

			v20 = false
			playPauseButton.Text = "Play"
			playPauseButton.BackgroundColor3 = Color3.fromRGB(60, 180, 80)
			setStatus("2D stopped.") -- inferred equivalent call
		else
			stopPlayback()
			resetPlaybackUi("Stopped.")
		end
	end)

	local function showModalWithAccessCheck() -- 3 equivalent calls inferred from this helper
		v18 = false
		syncModalToPianoContainer()
		applyGuiObjectZTree(midiModal, midiModal.ZIndex)
		midiModal.Visible = true
		count2 += 1
		local v24 = count2
		midiBody.Visible = false
		accessGate.Visible = true
		accessBody.Text = "Checking MIDI Player access..."
		accessTrialInfo.Text = ""

		local v25 = nil
		task.spawn(function()
			local v26 = fetchAccessState()

			if v24 ~= count2 then
				return
			end

			local v27 = applyAccessState(v26)

			if v25 then
				v25(v27, v26)
			end
		end)
	end

	function MidiPlayerHandler.OpenModal()
		showModalWithAccessCheck() -- inferred equivalent call
	end

	function MidiPlayerHandler.OpenUrl(value, value2, value3, p): boolean
		local match = tostring(value or ""):match("^%s*(.-)%s*$")
		local v24 = tostring(value3 or "")
		local v25 = type(p) == "table" and p or {}
		local v26 = v25.PreferBackup == true or v25.UseBackup == true
		local v27

		if match == "" then
			v27 = false
		else
			v27 = match:match("^https?://") ~= nil
		end

		if not v27 and v24 == "" then
			return false
		end

		local v28 = tostring(value2 or "")
		local v29 = v28 == ""
			and (v27 and (match:match("([^/]+)%.mid[i]?") or match:match("([^/?#]+)$") or "MIDI") or "MIDI")
			or v28
		showModalWithAccessCheck() -- inferred equivalent call
		urlBox.Text = (not v27 or v26 or not match) and "" or match
		fn3(v27 and match or "", v29, v26 or not v27, v24, v25)
		return true
	end

	OpenCommunityMidiUrl.Event:Connect(function(p, p2, p3, p4)
		MidiPlayerHandler.OpenUrl(p, p2, p3, p4)
	end)

	function MidiPlayerHandler.RefreshLayout()
		syncModalToPianoContainer()
		applyGuiObjectZTree(midiModal, midiModal.ZIndex)
	end

	connectActivated(midiPlayer, function()
		if object2 then
			object2:Play()
		end

		if midiModal.Visible then
			midiModal.Visible = false
			return
		end

		showModalWithAccessCheck() -- inferred equivalent call
	end)

	connectActivated(closeButton, function()
		if object2 then
			object2:Play()
		end

		midiModal.Visible = false
	end)
end

local function getPreviewSourceLabel(value, p) -- 2 equivalent calls inferred from this helper
	local backupLabel = type(p) == "table" and tostring(p.BackupLabel or "") or ""

	if backupLabel ~= "" then
		return backupLabel
	end

	local v17 = tostring(value or "")

	if v17 == "Backup" then
		return "Backup available"
	elseif v17 == "Live" then
		return "Original link"
	end

	return ""
end

local function fetchMidiBufferForPreviewOptions(p)
	local v17 = type(p) == "table" and p or {}
	local match = tostring(v17.Url or v17.URL or ""):match("^%s*(.-)%s*$")
	local publicId = tostring(v17.PublicId or v17.UploadId or v17.BackupId or v17.CanonicalId or "")
	local backupId = tostring(v17.BackupId or v17.CanonicalId or publicId or "")
	local v18 = v17.PreferBackup == true or v17.UseBackup == true
	local v19

	if match == "" then
		v19 = false
	else
		v19 = match:match("^https?://") ~= nil
	end

	if publicId == "" then
		return FetchMidiRemote:InvokeServer(match)
	end

	local v20 = {
		Url = v18 and "" or v19 and match or "",
		PublicId = publicId,
		BackupId = backupId,
		CanonicalId = backupId,
		PreferBackup = v18,
		UseBackup = v18
	}

	local v21, v22, v23 = FetchMidiRemote:InvokeServer(v20)

	if type(v21) == "string" and v21 ~= "" then
		return v21, v22, v23
	end

	if v18 and v19 then
		v20.Url = match
		v20.PreferBackup = false
		v20.UseBackup = false
		local v24, v25, v26 = FetchMidiRemote:InvokeServer(v20)

		if type(v24) == "string" and v24 ~= "" then
			return v24, v25, v26
		end
	end

	return v21, v22, v23
end

function MidiPlayerHandler.PreviewUrl(p): (boolean, string)
	local v17 = type(p) == "table" and p or {}
	local match = tostring(v17.Url or v17.URL or ""):match("^%s*(.-)%s*$")
	local displayName = tostring(v17.DisplayName or v17.Name or "MIDI")
	local publicId = tostring(v17.PublicId or v17.UploadId or v17.BackupId or v17.CanonicalId or "")
	local backupId = tostring(v17.BackupId or v17.CanonicalId or publicId or "")
	local v18 = v17.PreferBackup == true or v17.UseBackup == true
	MidiPlayerHandler._Preview2DSource = nil
	local v19

	if match == "" then
		v19 = false
	else
		v19 = match:match("^https?://") ~= nil
	end

	if not v19 and publicId == "" then
		setPreviewState({
			Active = false,
			Loading = false,
			Playing = false,
			Paused = false,
			Status = "This MIDI is unavailable.",
			UploadId = publicId,
			DisplayName = displayName
		})
		return false, "This MIDI is unavailable."
	end

	local previewPlaybackCallbacks2 = getPreviewPlaybackCallbacks() -- inferred equivalent call
	count += 1
	local v20 = count
	stopPlayback()
	setPreviewState({
		Active = true,
		Loading = true,
		Playing = false,
		Paused = false,
		Status = "Loading preview...",
		DisplayName = displayName,
		UploadId = publicId,
		Position = 0,
		Duration = 0,
		SourceLabel = "",
		Has2DSource = false
	})

	task.spawn(function()
		local success, result, v21, v22 = pcall(function()
			if publicId == "" then
				return FetchMidiRemote:InvokeServer(match)
			end

			local v21 = {
				Url = v18 and "" or v19 and match or "",
				PublicId = publicId,
				BackupId = backupId,
				CanonicalId = backupId,
				PreferBackup = v18,
				UseBackup = v18
			}

			local v22, v23, v24 = FetchMidiRemote:InvokeServer(v21)

			if type(v22) == "string" and v22 ~= "" then
				return v22, v23, v24
			end

			if v18 and v19 then
				v21.Url = match
				v21.PreferBackup = false
				v21.UseBackup = false
				local v25, v26, v27 = FetchMidiRemote:InvokeServer(v21)

				if type(v25) == "string" and v25 ~= "" then
					return v25, v26, v27
				end
			end

			return v22, v23, v24
		end)

		if v20 ~= count then
			return
		end

		if not success then
			setPreviewState({
				Active = false,
				Loading = false,
				Playing = false,
				Paused = false,
				Status = "Could not load preview. Try again."
			})
		elseif type(result) == "string" and result ~= "" then
			local previewSourceLabel = getPreviewSourceLabel(v21, v22) -- inferred equivalent call
			setPreviewState({ Status = "Preparing preview...", SourceLabel = previewSourceLabel })
			local function fn2(state)
				if v20 ~= count then
					return
				end

				local displayedDuration = state.DisplayedDuration or state.TimeLength or 0
				local preview2DSource = build2DSourceFromPlayer(state, displayName)
				MidiPlayerHandler._Preview2DSource = preview2DSource

				if preview2DSource then
					preview2DSource.showModePanel = false
				end

				setPreviewState({
					Active = true,
					Loading = false,
					Playing = true,
					Paused = false,
					Status = "Playing preview locally.",
					Position = 0,
					Duration = displayedDuration,
					SourceLabel = previewSourceLabel,
					Has2DSource = preview2DSource ~= nil
				})

				state.TimeMultiplier = 1
				beginPlayback(previewPlaybackCallbacks2, function()
					if v20 == count then
						setPreviewState({
							Active = false,
							Loading = false,
							Playing = false,
							Paused = false,
							Status = "Finished."
						})
					end
				end, "CommunityPreview")
			end
			local function fn3(_)
				if v20 ~= count then
					return
				end

				setPreviewState({
					Active = false,
					Loading = false,
					Playing = false,
					Paused = false,
					Status = "Could not play this MIDI preview."
				})
			end

			prepareMidi(result, fn2, fn3) -- inferred equivalent call
		else
			local v23 = tostring(v21 or "")
			setPreviewState({
				Active = false,
				Loading = false,
				Playing = false,
				Paused = false,
				Status = v23 == "" and "Could not load preview." or v23:match("^HTTP%s+%d+") and v18 and "Could not load the saved backup preview." or v23
			})
		end
	end)

	return true, "Loading preview..."
end

function MidiPlayerHandler.LoadUrlTo2D(p, callback): (boolean, string)
	local v17 = type(p) == "table" and p or {}
	local v18

	if type(callback) == "function" then
		v18 = callback or nil
	else
		v18 = nil
	end

	local match = tostring(v17.Url or v17.URL or ""):match("^%s*(.-)%s*$")
	local displayName = tostring(v17.DisplayName or v17.Name or "MIDI")
	local publicId = tostring(v17.PublicId or v17.UploadId or v17.BackupId or v17.CanonicalId or "")
	local v19

	if match == "" then
		v19 = false
	else
		v19 = match:match("^https?://") ~= nil
	end

	if v19 or publicId ~= "" then
		count += 1
		local v20 = count
		stopPlayback()
		MidiPlayerHandler._Preview2DSource = nil
		setPreviewState({
			Active = true,
			Loading = true,
			Playing = false,
			Paused = false,
			Status = "Loading MIDI for 2D...",
			DisplayName = displayName,
			UploadId = publicId,
			Position = 0,
			Duration = 0,
			SourceLabel = "",
			Has2DSource = false
		})

		task.spawn(function()
			local success, result, v21, v22 = pcall(function()
				return fetchMidiBufferForPreviewOptions(v17)
			end)

			if v20 ~= count then
				return
			end

			if success then
				if type(result) == "string" and result ~= "" then
					local previewSourceLabel = getPreviewSourceLabel(v21, v22) -- inferred equivalent call
					setPreviewState({
						Status = "Preparing 2D Mode...",
						SourceLabel = previewSourceLabel
					})
					local function fn2(p2)
						if v20 ~= count then
							return
						end

						local displayedDuration = p2.DisplayedDuration or p2.TimeLength or 0
						local preview2DSource = build2DSourceFromPlayer(p2, displayName)

						if preview2DSource then
							MidiPlayerHandler._Preview2DSource = preview2DSource
							setPreviewState({
								Active = true,
								Loading = false,
								Playing = false,
								Paused = false,
								Status = "2D source ready.",
								Position = 0,
								Duration = displayedDuration,
								SourceLabel = previewSourceLabel,
								Has2DSource = true
							})

							local previewTo2D, v23 = MidiPlayerHandler.LoadPreviewTo2D()

							if v18 then
								v18(previewTo2D == true, v23)
							end
						else
							setPreviewState({
								Active = false,
								Loading = false,
								Playing = false,
								Paused = false,
								Status = "This MIDI has no playable 2D notes.",
								Duration = displayedDuration,
								SourceLabel = previewSourceLabel,
								Has2DSource = false
							})

							if v18 then
								v18(false, "This MIDI has no playable 2D notes.")
							end
						end
					end
					local function fn3(_)
						if v20 ~= count then
							return
						end

						setPreviewState({
							Active = false,
							Loading = false,
							Playing = false,
							Paused = false,
							Status = "Could not prepare this MIDI for 2D.",
							Has2DSource = false
						})

						if v18 then
							v18(false, "Could not prepare this MIDI for 2D.")
						end
					end

					prepareMidi(result, fn2, fn3) -- inferred equivalent call
				else
					local v23 = tostring(v21 or "")
					local status = v23 == "" and "Could not load this MIDI for 2D." or v23

					setPreviewState({
						Active = false,
						Loading = false,
						Playing = false,
						Paused = false,
						Status = status,
						Has2DSource = false
					})

					if v18 then
						v18(false, status)
					end
				end
			else
				setPreviewState({
					Active = false,
					Loading = false,
					Playing = false,
					Paused = false,
					Status = "Could not load this MIDI for 2D.",
					Has2DSource = false
				})

				if v18 then
					v18(false, "Could not load this MIDI for 2D.")
				end
			end
		end)

		return true, "Loading MIDI for 2D..."
	end

	setPreviewState({
		Active = false,
		Loading = false,
		Playing = false,
		Paused = false,
		Status = "This MIDI is unavailable.",
		UploadId = "",
		DisplayName = displayName,
		Has2DSource = false
	})

	if v18 then
		v18(false, "This MIDI is unavailable.")
	end

	return false, "This MIDI is unavailable."
end

function MidiPlayerHandler.TogglePreviewPause(): (boolean, string)
	if v15 ~= "CommunityPreview" or not v2 then
		return false, "Preview is not playing."
	end

	if v16.Paused == true then
		if lastTime and v9 > 0 then
			v9 += tick() - lastTime
		end

		lastTime = nil
		v11 = true
		v12 = 0
		v2:Play()
		setPreviewState({ Playing = true, Paused = false, Status = "Playing preview locally." })
		return true, "Playing"
	end

	v2:Pause()
	v11 = false
	lastTime = tick()
	releaseAllNotes() -- inferred equivalent call
	setPreviewState({ Playing = false, Paused = true, Status = "Preview paused." })
	return true, "Paused"
end

function MidiPlayerHandler.StopPreview(): boolean
	if v15 ~= "CommunityPreview" and v16.Active ~= true then
		return false
	end

	count += 1
	stopPlayback()
	setPreviewState({
		Active = false,
		Loading = false,
		Playing = false,
		Paused = false,
		Status = "Stopped.",
		Position = 0
	})
	return true
end

function MidiPlayerHandler.SeekPreview(p)
	if v15 ~= "CommunityPreview" or not v2 then
		return false, "Preview is not playing."
	end

	local displayedDuration = v2.DisplayedDuration or v2.TimeLength or 0

	if displayedDuration <= 0 then
		return false, "Preview is not ready yet."
	end

	local position = math.clamp(tonumber(p) or 0, 0, displayedDuration)

	if v2.InstructionProgress then
		table.clear(v2.InstructionProgress)
	end

	if v2.EndOfTracks then
		table.clear(v2.EndOfTracks)
	end

	releaseAllNotes() -- inferred equivalent call
	v2:SetTimePosition(position)
	setPreviewState({
		Active = true,
		Loading = false,
		Position = position,
		Duration = displayedDuration
	})
	return true
end

function MidiPlayerHandler.LoadPreviewTo2D(): (boolean, string)
	local preview2DSource = MidiPlayerHandler._Preview2DSource

	if not preview2DSource then
		return false, "Preview is not ready for 2D Mode yet."
	end

	preview2DSource.showModePanel = nil
	v5 = preview2DSource

	local v17 = v14
	local v18 = nil
	local pianoRoll2DHandler = script.Parent and script.Parent:FindFirstChild("PianoRoll2DHandler")

	if pianoRoll2DHandler then
		local success, result = pcall(require, pianoRoll2DHandler)

		if success and type(result) == "table" then
			v18 = result
		end
	end

	if v17 and v17.setMidi2DSpeed then
		v17.setMidi2DSpeed(1)
	elseif v18 and v18.SetPlaybackSpeed then
		v18.SetPlaybackSpeed(1)
	end

	if v17 and v17.onMidi2DSourceReady then
		v17.onMidi2DSourceReady(preview2DSource)
	end

	if v15 == "CommunityPreview" and v2 then
		stopPlayback()
	end

	if v17 and v17.onMidi2DPlayRequested and v17.onMidi2DPlayRequested(preview2DSource) then
		setPreviewState({
			Active = false,
			Loading = false,
			Playing = false,
			Paused = false,
			Status = "Loaded to 2D.",
			Position = 0,
			Has2DSource = true
		})
		return true, "Sent to 2D Mode."
	end

	if not v18 then
		return false, "2D Mode is not available yet."
	end

	if v18.Open then
		v18.Open()
	end

	if v18.IsOpen and not v18.IsOpen() and v18.Initialize then
		local v19 = script:FindFirstAncestorOfClass("ScreenGui")

		if not v19 and script.Parent then
			v19 = script.Parent.Parent
		end

		if v19 then
			v18.Initialize(v19, {
				playNote = previewPlaybackCallbacks.playNote,
				finishNote = previewPlaybackCallbacks.finishNote,
				markActivity = previewPlaybackCallbacks.markActivity,
				isMidiDesktopPlaybackActive = function(): boolean
					return v15 == "CommunityPreview" and v2 ~= nil
				end,
				stopMidiPlayback = function()
					if v15 == "CommunityPreview" and v2 then
						stopPlayback()
					end
				end
			}, nil)

			if v18.Open then
				v18.Open()
			end
		end
	end

	if v18.SetSource then
		v18.SetSource(preview2DSource)
	end

	if v18.ShowLoadedSourceModes and v18.ShowLoadedSourceModes() ~= false and (not v18.IsOpen or v18.IsOpen()) then
		setPreviewState({
			Active = false,
			Loading = false,
			Playing = false,
			Paused = false,
			Status = "Loaded to 2D.",
			Position = 0,
			Has2DSource = true
		})
		return true, "Sent to 2D Mode."
	end

	return false, "2D Mode is not available yet."
end

function MidiPlayerHandler.GetPreviewState()
	local previewState = {}

	for k, v17 in pairs(v16) do
		previewState[k] = v17
	end

	if v15 ~= "CommunityPreview" or not v2 then
		return previewState
	end

	local displayedDuration = v2.DisplayedDuration or v2.TimeLength or previewState.Duration or 0
	previewState.Position = v2.TimePosition or 0
	previewState.Duration = displayedDuration
	previewState.Active = true
	previewState.Loading = false
	previewState.Playing = previewState.Paused ~= true

	return previewState
end

function MidiPlayerHandler.IsPlaybackActive(): boolean
	return v2 ~= nil and v3 ~= nil
end

function MidiPlayerHandler.Stop()
	stopPlayback()

	if fn then
		fn()
	end
end

return MidiPlayerHandler