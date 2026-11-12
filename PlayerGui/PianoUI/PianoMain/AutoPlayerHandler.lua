local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local AutoPlayerHandler = {}

game:GetService("UserInputService")
game:GetService("SoundService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local OverheadStatusUpdate = ReplicatedStorage2:WaitForChild("OverheadStatusUpdate", 10)

local LocalAutoplayStatusChanged = ReplicatedStorage2:FindFirstChild("LocalAutoplayStatusChanged")

if not (LocalAutoplayStatusChanged and LocalAutoplayStatusChanged:IsA("BindableEvent")) then
	if LocalAutoplayStatusChanged then
		LocalAutoplayStatusChanged:Destroy()
	end

	LocalAutoplayStatusChanged = Instance.new("BindableEvent")
	LocalAutoplayStatusChanged.Name = "LocalAutoplayStatusChanged"
	LocalAutoplayStatusChanged.Parent = ReplicatedStorage2
end

pcall(function()
	LocalAutoplayStatusChanged.Sandboxed = true
end)

local flag = false
local v = 1
local v2 = 120
local v3 = "Automatic"

local v4 = {}
local v5 = {}

local v6 = {}
local flag2 = false

local v7 = 0

local v8 = 0

local v9 = nil

local notesTextBox = nil
local playButton = nil
local keybindButton = nil
local tempoTextBox = nil
local modeButton = nil
local notesOverlay = nil
local color = Color3.fromRGB(42, 176, 94)
local color2 = Color3.fromRGB(220, 54, 54)
local color3 = Color3.fromRGB(255, 255, 255)

local function updateAutoPlayerPlayButton() -- 9 equivalent calls inferred from this helper
	if not playButton then
		return
	end

	playButton.Text = flag and "Stop" or "Play"
	playButton.BackgroundColor3 = flag and color2 or color
	playButton.TextColor3 = color3
end

local keysFrame = nil
local logic_UI = nil
local logic_Keymap = nil
local KEY_OFFSET = nil
local logic_Piano = nil
local folder_Remotes = nil
local currentHumanoid = nil
local dependence_PlayerVariables = nil
local dependence_Soundfonts = nil
local npsCounter = nil
local pianoPackets = nil

local getCurrentState = nil
local getCurrentPianoModel = nil
local startVisualization = nil
local endVisualization = nil
local animateModelKey = nil
local markActivity = nil
local isPracticeMode = nil
local flag3 = false
local v10 = 0

local function markAutoPlayerActivity(p) -- 2 equivalent calls inferred from this helper
	if not markActivity then
		return
	end

	local now = tick()

	if p or now - v10 >= 2 then
		v10 = now
		markActivity()
	end
end

local function getBindableEvent(name)
	local v11 = ReplicatedStorage2:FindFirstChild(name)

	if v11 and not v11:IsA("BindableEvent") then
		v11:Destroy()
		v11 = nil
	end

	if not v11 then
		v11 = Instance.new("BindableEvent")
		v11.Name = name
		v11.Parent = ReplicatedStorage2
	end

	return v11
end

local function openAutoPlayerKeybindSettings()
	getBindableEvent("OpenAutoPlayerKeybindSettings"):Fire()
end

local function StartAutoPlayerKeepAlive() -- 2 equivalent calls inferred from this helper
	if flag3 then
		return
	end

	flag3 = true
	v10 = 0
	task.spawn(function()
		while flag do
			if markActivity then
				v10 = tick()
				markActivity()
			end

			task.wait(2)
		end

		flag3 = false
	end)
end

local function getCurrentPianoModule() -- 2 equivalent calls inferred from this helper
	local v11 = getCurrentPianoModel and getCurrentPianoModel()
	local scripts = v11 and v11:FindFirstChild("Scripts")
	return scripts and scripts:FindFirstChild("PianoModule") or nil
end

local function IsValidNoteChar(value, p): boolean -- 7 equivalent calls inferred from this helper
	if p then
		return ("trewq0987654321yuiopasdfghjklzxcvbnm"):find(string.lower(value), 1, true) ~= nil
	end

	return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(value, 1, true) ~= nil
end

local function CharToNoteNumber(value, p)
	if p then
		local v11 = ("trewq0987654321yuiopasdfghjklzxcvbnm"):find(string.lower(value), 1, true)

		if v11 then
			local piano88KeyCodes = logic_Keymap.Piano88KeyCodes
			local v12 = getCurrentState()
			return piano88KeyCodes[v11] + v12.Transposition
		end
	else
		local v11 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(value, 1, true)

		if v11 then
			return v11 + getCurrentState().Transposition
		end
	end

	return nil
end

local function getNextAutoPlayerKeyCode() -- 1 equivalent call inferred from this helper
	v7 = v7 % 1000000 + 1
	return -200000 - v7
end

local function getActiveAutoPlayerEntry(p) -- 3 equivalent calls inferred from this helper
	local noteNumber = v6[p]

	if type(noteNumber) == "table" then
		return noteNumber
	end

	if type(noteNumber) == "number" then
		return { noteNumber = noteNumber, sustainPacket = false }
	end

	return nil
end

local function AutoPlayNoteEnd(p, p2)
	if p2 == nil then
		if not p then
			return
		end

		local v11 = {}

		for k, _ in pairs(v6) do
			local activeAutoPlayerEntry = getActiveAutoPlayerEntry(k) -- inferred equivalent call

			if activeAutoPlayerEntry and activeAutoPlayerEntry.noteNumber == p then
				table.insert(v11, k)
			end
		end

		for _, v12 in ipairs(v11) do
			AutoPlayNoteEnd(p, v12)
		end
	else
		local activeAutoPlayerEntry = getActiveAutoPlayerEntry(p2) -- inferred equivalent call
		local v11 = p or activeAutoPlayerEntry and activeAutoPlayerEntry.noteNumber

		if not v11 then
			return
		end

		markAutoPlayerActivity(false) -- inferred equivalent call
		local v12 = getCurrentState()
		local sustainPacket = activeAutoPlayerEntry and activeAutoPlayerEntry.sustainPacket

		if sustainPacket == nil then
			sustainPacket = v12.SustainPacket
		end

		local current_SoundfontID = dependence_PlayerVariables.Current_SoundfontID
		local fadeout = dependence_Soundfonts[current_SoundfontID].Fadeout
		local currentPianoModule = getCurrentPianoModule() -- inferred equivalent call
		logic_UI.FinishNote(keysFrame, v11)

		local v13 = endVisualization and getCurrentPianoModel and getCurrentPianoModel()

		if v13 then
			endVisualization(v11, v13)
		end

		if animateModelKey then
			animateModelKey(v11 + KEY_OFFSET, false)
		else
			if currentPianoModule then
				local success, result = pcall(require, currentPianoModule)

				if success and result and result.PianoAnimation then
					result.PianoAnimation(v11 + KEY_OFFSET, false)
				end
			end

			if pianoPackets and pianoPackets.Animation and not (isPracticeMode and isPracticeMode()) then
				pianoPackets.Animation:Fire(v11 + KEY_OFFSET, false)
			end
		end

		if pianoPackets and pianoPackets.NoteSimple and not (isPracticeMode and isPracticeMode()) then
			pianoPackets.NoteSimple:Fire(
				v11,
				v12.Velocity,
				v12.Transposition,
				sustainPacket,
				p2,
				v11 + KEY_OFFSET,
				false,
				current_SoundfontID
			)
		end

		if not sustainPacket then
			logic_Piano.FinishNonSustainNote(p2, fadeout)
		end

		v6[p2] = nil
	end
end

local function AutoPlayNoteStart(p, p2, p3)
	if flag2 then
		return nil
	end

	local noteNumber = CharToNoteNumber(p, p2)

	if not noteNumber then
		return nil
	end

	markAutoPlayerActivity(false) -- inferred equivalent call
	local v11 = getCurrentState()
	local current_SoundfontID = dependence_PlayerVariables.Current_SoundfontID
	local v12 = dependence_Soundfonts[current_SoundfontID]

	if v12 and logic_Piano.PrewarmSoundfont then
		logic_Piano.PrewarmSoundfont(v12.AssetIds, v12.PacketType)
	end

	local assetIds = v12.AssetIds
	local offset = v12.Offset
	local maxLifetime = v12.MaxLifetime
	local fadeout = v12.Fadeout
	local volumeModifier = v12.VolumeModifier
	local packetType = v12.PacketType
	local currentPianoModule = getCurrentPianoModule() -- inferred equivalent call
	local nextAutoPlayerKeyCode = getNextAutoPlayerKeyCode() -- inferred equivalent call
	local sustainPacket = v11.SustainPacket

	v6[nextAutoPlayerKeyCode] = { noteNumber = noteNumber, sustainPacket = sustainPacket }

	logic_Piano[packetType](
		noteNumber,
		assetIds,
		offset,
		maxLifetime,
		fadeout,
		v11.Transposition,
		packetType,
		sustainPacket,
		p2 or v11.Above88KeyPacket,
		v11.Velocity,
		v11.LocalVolume,
		volumeModifier,
		nextAutoPlayerKeyCode,
		false,
		dependence_PlayerVariables.Current_SoundEffects,
		Players.LocalPlayer and Players.LocalPlayer.UserId or nil
	)

	if npsCounter and not (isPracticeMode and isPracticeMode()) then
		npsCounter.RecordNote()
	end

	if logic_UI and keysFrame then
		logic_UI.PlayNote(keysFrame, noteNumber)
	end

	local v13 = startVisualization and getCurrentPianoModel and getCurrentPianoModel()

	if v13 then
		startVisualization(noteNumber, v13)
	end

	if animateModelKey then
		animateModelKey(noteNumber + KEY_OFFSET, true)
	elseif v11.ModelKeyHighlightEnabled ~= false then
		if currentPianoModule then
			local success, result = pcall(require, currentPianoModule)

			if success and result and result.PianoAnimation then
				result.PianoAnimation(noteNumber + KEY_OFFSET, true)
			end
		end

		if pianoPackets and pianoPackets.Animation and not (isPracticeMode and isPracticeMode()) then
			pianoPackets.Animation:Fire(noteNumber + KEY_OFFSET, true)
		end
	end

	if pianoPackets and pianoPackets.NoteSimple and not (isPracticeMode and isPracticeMode()) then
		pianoPackets.NoteSimple:Fire(
			noteNumber,
			v11.Velocity,
			v11.Transposition,
			sustainPacket,
			nextAutoPlayerKeyCode,
			noteNumber + KEY_OFFSET,
			true,
			current_SoundfontID
		)
	end

	if not p3 then
		task.delay(0.1, function()
			AutoPlayNoteEnd(noteNumber, nextAutoPlayerKeyCode)
		end)
	end

	return noteNumber, nextAutoPlayerKeyCode
end

local function AutoPlayNote(p, p2) -- 2 equivalent calls inferred from this helper
	AutoPlayNoteStart(p, p2, false)
end

local function GetNextNoteOrChord(text, count)
	text:sub(count, count)
	local v11

	if getCurrentState then
		local v12 = getCurrentState()
		v11 = v12 and v12.Above88KeyPacket or false
	else
		v11 = false
	end

	while count <= #text do
		local v12 = text:sub(count, count)

		if v12 == " " or v12 == "\n" or v12 == "\r" or v12 == "\t" or v12 == "|" or v12 == "-" then
			count += 1
		else
			if v12 == "[" or v12 == "]" or v12 == "" then
				break
			end

			if IsValidNoteChar(v12, v11) then -- inferred equivalent call
				break
			end

			count += 1
		end
	end

	if #text < count then
		return nil, count
	end

	local note = text:sub(count, count)

	if note == "[" then
		local v12 = text:find("]", count)

		if not v12 then
			return nil, count + 1
		end

		local v13 = text:sub(count + 1, v12 - 1)

		local set = {}
		local notes = ""

		for i = 1, #v13 do
			local v14 = v13:sub(i, i)

			if v14 == " " or not IsValidNoteChar(v14, v11) or set[v14] then -- inferred equivalent call
				continue
			end

			notes ..= v14
			set[v14] = true
		end

		if #notes > 0 then
			return { type = "chord", notes = notes }, v12 + 1
		end

		return nil, v12 + 1
	end

	if note ~= "" and note ~= "]" and IsValidNoteChar(note, v11) then -- inferred equivalent call
		return { type = "note", note = note }, count + 1
	end

	return nil, count + 1
end

local function BPMToDelay(p) -- 1 equivalent call inferred from this helper
	return 60 / p
end

local function UpdatePositionIndicator(p)
	if not (notesTextBox and notesOverlay) then
		return
	end

	local text = notesTextBox.Text

	if #text == 0 then
		notesOverlay.Text = ""
		notesOverlay.Visible = false
	else
		local v11

		if getCurrentState then
			local v12 = getCurrentState()
			v11 = v12 and v12.Above88KeyPacket or false
		else
			v11 = false
		end

		if p > 0 and p <= #text then
			local count = 0
			local text2 = ""

			while p <= #text and count < 8 do
				text:sub(p, p)

				while p <= #text do
					local v12 = text:sub(p, p)

					if v12 == " " or v12 == "\n" or v12 == "\r" or v12 == "\t" or v12 == "|" or v12 == "-" then
						p += 1
					else
						if v12 == "[" or v12 == "]" or v12 == "" then
							break
						end

						if IsValidNoteChar(v12, v11) then -- inferred equivalent call
							break
						end

						p += 1
					end
				end

				if #text < p then
					break
				end

				local v12 = text:sub(p, p)

				if v12 == "[" then
					local v13 = text:find("]", p)

					if v13 then
						local v14 = text:sub(p, v13)

						if count == 0 then
							text2 ..= "<font color=\"#9CFF00\"><b>" .. v14 .. "</b></font> "
						else
							text2 ..= v14 .. " "
						end

						p = v13 + 1
						count += 1
					else
						p += 1
					end
				elseif v12 == "" or v12 == "]" then
					p += 1
				elseif IsValidNoteChar(v12, v11) then -- inferred equivalent call
					if count == 0 then
						text2 ..= "<font color=\"#9CFF00\"><b>" .. v12 .. "</b></font> "
					else
						text2 ..= v12 .. " "
					end

					p += 1
					count += 1
				else
					p += 1
				end
			end

			notesOverlay.Text = text2
		else
			local v12 = 1
			local count = 0
			local text2 = ""

			while v12 <= #text and count < 8 do
				text:sub(v12, v12)

				while v12 <= #text do
					local v13 = text:sub(v12, v12)

					if v13 == " " or v13 == "\n" or v13 == "\r" or v13 == "\t" or v13 == "|" or v13 == "-" then
						v12 += 1
					else
						if v13 == "[" or v13 == "]" or v13 == "" then
							break
						end

						if IsValidNoteChar(v13, v11) then -- inferred equivalent call
							break
						end

						v12 += 1
					end
				end

				if #text < v12 then
					break
				end

				local v13 = text:sub(v12, v12)

				if v13 == "[" then
					local v14 = text:find("]", v12)

					if v14 then
						text2 ..= text:sub(v12, v14) .. " "
						v12 = v14 + 1
						count += 1
					else
						v12 += 1
					end
				elseif v13 == "" or v13 == "]" then
					v12 += 1
				elseif IsValidNoteChar(v13, v11) then -- inferred equivalent call
					text2 ..= v13 .. " "
					v12 += 1
					count += 1
				else
					v12 += 1
				end
			end

			notesOverlay.Text = text2
		end

		notesOverlay.Visible = true
	end
end

local function ReleaseManualNotes()
	for k, v11 in pairs(v5) do
		AutoPlayNoteEnd(v11, k)
	end

	v5 = {}
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
	if isPracticeMode and isPracticeMode() then
		return
	end

	if p == "Autoplaying" then
		pcall(function()
			LocalAutoplayStatusChanged:Fire(p2 == true, "AutoPlayer")
		end)
	end

	if OverheadStatusUpdate then
		OverheadStatusUpdate:FireServer(p, p2)
	end
end

local function ShowAutoPlayingOverhead() -- 2 equivalent calls inferred from this helper
	if not (isPracticeMode and isPracticeMode()) then
		local v11 = true
		pcall(function()
			LocalAutoplayStatusChanged:Fire(v11 == true, "AutoPlayer")
		end)

		if OverheadStatusUpdate then
			OverheadStatusUpdate:FireServer("Autoplaying", true)
		end
	end

	if v9 then
		v9.Parent = nil
		v9 = nil
	end
end

local function HideAutoPlayingOverhead() -- 5 equivalent calls inferred from this helper
	if not (isPracticeMode and isPracticeMode()) then
		local v11 = false
		pcall(function()
			LocalAutoplayStatusChanged:Fire(v11 == true, "AutoPlayer")
		end)

		if OverheadStatusUpdate then
			OverheadStatusUpdate:FireServer("Autoplaying", false)
		end
	end

	if v9 then
		v9.Parent = nil
		v9 = nil
	end
end

local function ForceCleanupAllAutoPlayerNotes()
	if flag2 then
		return
	end

	flag2 = true

	local v11 = {}

	for k, _ in pairs(v6) do
		table.insert(v11, k)
	end

	for _, v12 in ipairs(v11) do
		local activeAutoPlayerEntry = getActiveAutoPlayerEntry(v12) -- inferred equivalent call

		if activeAutoPlayerEntry then
			AutoPlayNoteEnd(activeAutoPlayerEntry.noteNumber, v12)
		end
	end

	v6 = {}

	flag2 = false
end

local count = 0
local v11 = 0

local function sendAutoPlayerGuideNotification() -- 1 equivalent call inferred from this helper
	local now = os.clock()

	if now - v11 < 1 then
		return
	end

	v11 = now

	count += 1
	local v12 = count

	task.spawn(function()
		for _ = 1, 20 do
			if v12 ~= count then
				break
			end

			if pcall(function()
				StarterGui:SetCore("SendNotification", {
					Title = "AutoPlayer needs notes",
					Text = "Open AUTO and paste a QWERTY sheet into the notes box first.",
					Duration = 4
				})
			end) then
				break
			end

			task.wait(0.25)
		end
	end)
end

local function hasAutoPlayerSheet(): boolean -- 1 equivalent call inferred from this helper
	return (notesTextBox and notesTextBox.Text or ""):match("%S") ~= nil
end

local function ensureManualTriggerReady(): boolean
	if hasAutoPlayerSheet() then -- inferred equivalent call
		if v3 ~= "Manual" then
			v3 = "Manual"

			if modeButton then
				modeButton.Text = "Manual"
			end
		end

		updateAutoPlayerPlayButton() -- inferred equivalent call
		local text = notesTextBox.Text

		if v < 1 or v > #text then
			v = 1
		end

		if flag then
			return true
		end

		flag = true
		StartAutoPlayerKeepAlive() -- inferred equivalent call
		updateAutoPlayerPlayButton() -- inferred equivalent call
		ShowAutoPlayingOverhead() -- inferred equivalent call
		return true
	end

	sendAutoPlayerGuideNotification() -- inferred equivalent call
	return false
end

local function anyManualTriggerHeld(): boolean -- 1 equivalent call inferred from this helper
	for _, _ in pairs(v4) do
		return true
	end

	return false
end

local function PlayNextManualNote()
	if not flag or v3 ~= "Manual" then
		return
	end

	local text = notesTextBox.Text

	if v > #text then
		flag = false
		updateAutoPlayerPlayButton() -- inferred equivalent call
		v = 1
		HideAutoPlayingOverhead() -- inferred equivalent call
		UpdatePositionIndicator(0)
	else
		UpdatePositionIndicator(v)

		local v12, v13 = GetNextNoteOrChord(text, v)

		if v12 then
			if v12.type == "note" then
				local v14, v15 = AutoPlayNoteStart(v12.note, false, true)

				if v14 and v15 then
					v5[v15] = v14
				end
			elseif v12.type == "chord" then
				for i = 1, #v12.notes do
					local v14, v15 = AutoPlayNoteStart(v12.notes:sub(i, i), false, true)

					if v14 and v15 then
						v5[v15] = v14
					end
				end
			end
		end

		v = v13
	end
end

local function StartAutoPlayer()
	local now = tick()

	if now - v8 < 0.5 then
		return
	end

	v8 = now

	if flag then
		flag = false
		updateAutoPlayerPlayButton() -- inferred equivalent call
		HideAutoPlayingOverhead() -- inferred equivalent call
		ReleaseManualNotes()

		ForceCleanupAllAutoPlayerNotes()

		UpdatePositionIndicator(0)
	else
		local text = notesTextBox.Text

		if #text == 0 then
			return
		end

		local text2 = tonumber(tempoTextBox.Text)

		if text2 and text2 > 0 then
			v2 = text2
		end

		flag = true
		StartAutoPlayerKeepAlive() -- inferred equivalent call
		v = 1
		updateAutoPlayerPlayButton() -- inferred equivalent call
		ShowAutoPlayingOverhead() -- inferred equivalent call

		if v3 == "Automatic" then
			task.spawn(function()
				local bPMToDelay = BPMToDelay(v2) -- inferred equivalent call

				while flag and v <= #text do
					UpdatePositionIndicator(v)

					local v12, v13 = GetNextNoteOrChord(text, v)

					if v12 then
						if v12.type == "note" then
							AutoPlayNote(v12.note) -- inferred equivalent call
						elseif v12.type == "chord" then
							for i = 1, #v12.notes do
								AutoPlayNote(v12.notes:sub(i, i), nil) -- inferred equivalent call
							end
						end

						v = v13
						task.wait(bPMToDelay)
					else
						v = v13
					end
				end

				flag = false
				updateAutoPlayerPlayButton() -- inferred equivalent call
				v = 1
				HideAutoPlayingOverhead() -- inferred equivalent call
				UpdatePositionIndicator(0)
			end)
		else
			ClientDebugConfig.Print("[AutoPlayer] Manual mode enabled. Use -, =, [, ] to play notes.")
		end
	end
end

local function ToggleAutoPlayerMode()
	if v3 == "Automatic" then
		v3 = "Manual"

		if modeButton then
			modeButton.Text = "Manual"
		end
	else
		v3 = "Automatic"

		if modeButton then
			modeButton.Text = "Automatic"
		end
	end

	if flag then
		flag = false
		updateAutoPlayerPlayButton() -- inferred equivalent call
		ReleaseManualNotes()
		HideAutoPlayingOverhead() -- inferred equivalent call
	end
end

function AutoPlayerHandler.Initialize(data, data2, instance)
	notesTextBox = data.NotesTextBox
	playButton = data.PlayButton
	keybindButton = data.KeybindButton
	tempoTextBox = data.TempoTextBox
	modeButton = data.ModeButton
	notesOverlay = data.NotesOverlay
	local v12

	if notesOverlay then
		notesOverlay.RichText = true
		notesOverlay.Visible = true
		notesOverlay.BackgroundTransparency = 0
		notesOverlay.BackgroundColor3 = Color3.fromRGB(239, 241, 245)
		notesOverlay.TextColor3 = Color3.fromRGB(25, 28, 35)
		notesOverlay.TextTransparency = 0
		notesOverlay.TextScaled = false
		notesOverlay.TextWrapped = false
		notesOverlay.TextTruncate = Enum.TextTruncate.AtEnd
		notesOverlay.TextSize = 18
		notesOverlay.Font = Enum.Font.GothamBlack
		notesOverlay.TextYAlignment = Enum.TextYAlignment.Center
		v12 = true

		if notesTextBox then
			UpdatePositionIndicator(0)
		end
	else
		v12 = false
	end

	keysFrame = instance.KeysFrame
	logic_UI = instance.Logic_UI
	logic_Keymap = instance.Logic_Keymap
	KEY_OFFSET = instance.KEY_OFFSET
	logic_Piano = instance.Logic_Piano
	folder_Remotes = instance.Folder_Remotes
	currentHumanoid = instance.CurrentHumanoid or instance.Humanoid
	dependence_PlayerVariables = instance.Dependence_PlayerVariables
	dependence_Soundfonts = instance.Dependence_Soundfonts
	npsCounter = instance.NPSCounter
	pianoPackets = instance.PianoPackets

	getCurrentState = data2.getCurrentState
	getCurrentPianoModel = data2.getCurrentPianoModel
	startVisualization = data2.startVisualization
	endVisualization = data2.endVisualization
	animateModelKey = data2.animateModelKey
	markActivity = data2.markActivity
	isPracticeMode = data2.isPracticeMode
	updateAutoPlayerPlayButton() -- inferred equivalent call
	playButton.MouseButton1Click:Connect(StartAutoPlayer)

	if keybindButton then
		keybindButton.MouseButton1Click:Connect(openAutoPlayerKeybindSettings)
	end

	tempoTextBox.FocusLost:Connect(function(_)
		local v13 = tonumber((tempoTextBox.Text:gsub("[^0-9]", "")))

		if v13 and v13 > 0 then
			v2 = math.min(600, v13)
		end

		tempoTextBox.Text = tostring(v2)
	end)

	if notesTextBox then
		notesTextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if not flag then
				UpdatePositionIndicator(0)
			end
		end)
	end

	if modeButton then
		modeButton.MouseButton1Click:Connect(ToggleAutoPlayerMode)
		modeButton.Text = "Automatic"
	end

	ClientDebugConfig.Print(
		"[AutoPlayerHandler] Initialized {",
		"Overlay:",
		v12 and "✓" or "✗",
		"| Mode:",
		v3,
		"| Tempo:",
		v2,
		"| Debounce:",
		0.5 .. "s",
		"}"
	)
end

function AutoPlayerHandler.MobileManualTrigger(p): boolean
	if p == Enum.UserInputState.Begin then
		if not ensureManualTriggerReady() then
			return false
		end

		v4.MobileManualTrigger = true
		ReleaseManualNotes()
		PlayNextManualNote()
	else
		if p ~= Enum.UserInputState.End then
			return false
		end

		v4.MobileManualTrigger = nil

		if not anyManualTriggerHeld() then -- inferred equivalent call
			ReleaseManualNotes()
		end
	end

	return true
end

local set = {
	[Enum.KeyCode.Minus] = true,
	[Enum.KeyCode.Equals] = true,
	[Enum.KeyCode.LeftBracket] = true,
	[Enum.KeyCode.RightBracket] = true
}
AutoPlayerHandler.ManualModeKeybinds = set

function AutoPlayerHandler.SetManualModeKeybinds(list)
	AutoPlayerHandler.ManualModeKeybinds = {}

	if typeof(list) == "table" then
		for _, item in ipairs(list) do
			if typeof(item) == "EnumItem" then
				AutoPlayerHandler.ManualModeKeybinds[item] = true
			end
		end
	end

	if next(AutoPlayerHandler.ManualModeKeybinds) == nil then
		AutoPlayerHandler.ManualModeKeybinds[Enum.KeyCode.Minus] = true
		AutoPlayerHandler.ManualModeKeybinds[Enum.KeyCode.Equals] = true
		AutoPlayerHandler.ManualModeKeybinds[Enum.KeyCode.LeftBracket] = true
		AutoPlayerHandler.ManualModeKeybinds[Enum.KeyCode.RightBracket] = true
	end
end

function AutoPlayerHandler.ManualModeAction(_, p, p2)
	local keyCode = p2.KeyCode

	if not (AutoPlayerHandler.ManualModeKeybinds and AutoPlayerHandler.ManualModeKeybinds[keyCode]) then
		return
	end

	if p == Enum.UserInputState.Begin then
		v4[keyCode] = true

		ReleaseManualNotes()
		PlayNextManualNote()
	elseif p == Enum.UserInputState.End then
		v4[keyCode] = nil

		local v12 = false

		for _, _ in pairs(v4) do
			v12 = true
			break
		end

		if not v12 then
			ReleaseManualNotes()
		end
	end
end

function AutoPlayerHandler.Stop()
	if flag then
		flag = false
		updateAutoPlayerPlayButton() -- inferred equivalent call
		ReleaseManualNotes()

		ForceCleanupAllAutoPlayerNotes()
		HideAutoPlayingOverhead() -- inferred equivalent call
		UpdatePositionIndicator(0)
	end
end

return AutoPlayerHandler