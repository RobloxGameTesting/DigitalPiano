local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Root = script.Parent:WaitForChild("Root")
local Overlay = Root:WaitForChild("Overlay")
local Panel = Root:WaitForChild("Panel")
local Header = Panel:WaitForChild("Header")
local Body = Panel:WaitForChild("Body")
local StateBadge = Header:WaitForChild("StateBadge")
local Close = Header:WaitForChild("Close")
local Stats = Body:WaitForChild("Stats")
local NotesCount = Stats:WaitForChild("NotesCount")
local GroupsCount = Stats:WaitForChild("GroupsCount")
local LastInput = Stats:WaitForChild("LastInput")
local Notes = Body.NoteFrame:WaitForChild("Notes")
local Controls = Body:WaitForChild("Controls")
local PauseToggle = Controls:WaitForChild("PauseToggle")
local Reset = Controls:WaitForChild("Reset")
local InsertBar = Controls:WaitForChild("InsertBar")
local LoadSheet = Controls:WaitForChild("LoadSheet")
local Open2D = Controls:WaitForChild("Open2D")
local Status = Body:WaitForChild("Status")

local OpenVPNotes = ReplicatedStorage2:FindFirstChild("OpenVPNotes")

if not (OpenVPNotes and OpenVPNotes:IsA("BindableEvent")) then
	if OpenVPNotes then
		OpenVPNotes:Destroy()
	end

	OpenVPNotes = Instance.new("BindableEvent")
	OpenVPNotes.Name = "OpenVPNotes"
	OpenVPNotes.Parent = ReplicatedStorage2
end

local VPNotePlayed = ReplicatedStorage2:FindFirstChild("VPNotePlayed")

if not (VPNotePlayed and VPNotePlayed:IsA("BindableEvent")) then
	if VPNotePlayed then
		VPNotePlayed:Destroy()
	end

	VPNotePlayed = Instance.new("BindableEvent")
	VPNotePlayed.Name = "VPNotePlayed"
	VPNotePlayed.Parent = ReplicatedStorage2
end

local v = {}

for i = 1, 61 do
	v[("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(i, i)] = i
end

local flag = false
local v2 = true
local count = 0
local count2 = 0
local v3 = {}
local v4 = 0
local v5 = 0
local v6 = nil
local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local position4 = UDim2.fromScale(0.5, 0.5)
local udim = UDim2.fromOffset(0, 18)
local v7 = false
local position = nil
local position2 = nil
local v8 = nil

local function setStatus(value, color) -- 1 equivalent call inferred from this helper
	Status.Text = tostring(value or "")
	Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)
end

local function setRecordingState(p)
	v2 = p == true
	PauseToggle.Text = v2 and "Pause" or "Start"
	PauseToggle.BackgroundColor3 = v2 and Color3.fromRGB(47, 145, 91) or Color3.fromRGB(94, 76, 170)
	StateBadge.Text = v2 and "Recording" or "Paused"
	StateBadge.BackgroundColor3 = v2 and Color3.fromRGB(47, 145, 91) or Color3.fromRGB(94, 76, 170)
	setStatus( -- inferred equivalent call
		v2 and "Recording live piano input." or "Paused.",
		v2 and Color3.fromRGB(88, 214, 141) or Color3.fromRGB(255, 190, 90)
	)
end

local function refreshStats(value) -- 4 equivalent calls inferred from this helper
	NotesCount.Text = "Notes: " .. tostring(count)
	GroupsCount.Text = "Groups: " .. tostring(count2)
	LastInput.Text = "Last: " .. tostring(value or "-")
end

local function sortChars(list)
	table.sort(list, function(a, b): boolean
		return (v[a] or 999) < (v[b] or 999)
	end)

	local set = {}
	local result = {}

	for _, item in ipairs(list) do
		if set[item] then
			continue
		end

		set[item] = true
		table.insert(result, item)
	end

	return result
end

local function appendText(p) -- 6 equivalent calls inferred from this helper
	Notes.Text ..= p
end

local function appendSeparator(now)
	if not v6 or Notes.Text == "" then
		return
	end

	local v9 = math.max(0, now - v6)

	if v9 >= 4 then
		appendText("\n") -- inferred equivalent call
	elseif v9 >= 1 then
		appendText("| ") -- inferred equivalent call
	elseif v9 >= 0.45 then
		appendText("- ") -- inferred equivalent call
	else
		appendText(" ") -- inferred equivalent call
	end
end

local function flushPending()
	if #v3 == 0 then
		return
	end

	local now = os.clock()
	local v9 = sortChars(v3)
	table.clear(v3)
	appendSeparator(now)

	if #v9 == 1 then
		appendText(v9[1]) -- inferred equivalent call
	else
		appendText("[" .. table.concat(v9, "") .. "]") -- inferred equivalent call
	end

	count2 += 1
	v6 = now
	refreshStats(table.concat(v9, "")) -- inferred equivalent call
end

local function normalizeChar(value, p) -- 1 equivalent call inferred from this helper
	if typeof(value) == "string" and value ~= "" and v[value] then
		return value
	end

	local v9 = tonumber(p)

	if v9 and v9 >= 1 and v9 <= 61 then
		return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(v9, v9)
	end

	return nil
end

local function handleNote(p, p2)
	if not (flag and v2) then
		return
	end

	p = normalizeChar(p, p2) -- inferred equivalent call

	if not p then
		return
	end

	count += 1
	v5 = os.clock()

	if #v3 == 0 then
		v4 = v5
	end

	table.insert(v3, p)
	refreshStats(p) -- inferred equivalent call
end

local function getPianoUI() -- 3 equivalent calls inferred from this helper
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	return playerGui and playerGui:FindFirstChild("PianoUI")
end

local function getSheetsEditorBox()
	local pianoUI = getPianoUI() -- inferred equivalent call

	if not pianoUI then
		return nil
	end

	for _, frame in ipairs(pianoUI:GetDescendants()) do
		if not (frame.Name == "Sheets" and frame:IsA("Frame")) then
			continue
		end

		local card = frame:FindFirstChild("Card")
		local scroll = card and card:FindFirstChild("Scroll")
		local editor = scroll and scroll:FindFirstChild("Editor")

		if editor and editor:IsA("TextBox") then
			return editor
		end
	end

	return nil
end

local function getAutoPlayerControls()
	local pianoUI = getPianoUI() -- inferred equivalent call

	if not pianoUI then
		return nil, nil
	end

	for _, frame in ipairs(pianoUI:GetDescendants()) do
		if not (frame.Name == "AutoPlayer" and frame:IsA("Frame")) then
			continue
		end

		local notes = frame:FindFirstChild("Notes", true)
		local tempo = frame:FindFirstChild("Tempo", true)

		if notes and notes:IsA("TextBox") then
			if not (tempo and tempo:IsA("TextBox") and tempo) then
				tempo = nil
			end

			return notes, tempo
		end
	end

	return nil, nil
end

local function getSheetText() -- 2 equivalent calls inferred from this helper
	flushPending()
	return (tostring(Notes.Text or ""))
end

local function loadToSheets(): boolean
	local sheetText = getSheetText() -- inferred equivalent call

	if sheetText:match("%S") then
		local sheetsEditorBox = getSheetsEditorBox()
		local autoPlayerControls = getAutoPlayerControls()

		if sheetsEditorBox then
			sheetsEditorBox.Text = sheetText
		end

		if autoPlayerControls then
			autoPlayerControls.Text = sheetText
		end

		if sheetsEditorBox or autoPlayerControls then
			local color = Color3.fromRGB(88, 214, 141)
			Status.Text = tostring("Loaded into Sheets and Autoplayer.")
			Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)

			return true
		else
			local color = Color3.fromRGB(255, 190, 90)
			Status.Text = tostring("Open or sit at a piano first so Sheets can receive this.")
			Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)

			return false
		end
	else
		local color = Color3.fromRGB(255, 190, 90)
		Status.Text = tostring("There are no notes to load yet.")
		Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)

		return false
	end
end

local function openIn2D()
	local sheetText = getSheetText() -- inferred equivalent call

	if sheetText:match("%S") then
		loadToSheets()
		local pianoUI = getPianoUI() -- inferred equivalent call
		local pianoMain = pianoUI and pianoUI:FindFirstChild("PianoMain")
		local pianoRoll2DHandler = pianoMain and pianoMain:FindFirstChild("PianoRoll2DHandler")

		if pianoRoll2DHandler then
			local success, result = pcall(require, pianoRoll2DHandler)

			if success then
				if result.Open then
					result.Open()
				end

				if result.SetSheetSource then
					result.SetSheetSource("VP Notes", sheetText, 120)
				end

				if result.ShowLoadedSourceModes then
					result.ShowLoadedSourceModes()
				end

				local color = Color3.fromRGB(120, 210, 255)
				Status.Text = tostring("Sent to 2D Mode.")
				Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)
			else
				ClientDebugConfig.Warn("[VPNotes] Failed to load PianoRoll2DHandler:", result)
				local color = Color3.fromRGB(255, 105, 105)
				Status.Text = tostring("2D Mode failed to load.")
				Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)
			end
		else
			local color = Color3.fromRGB(255, 190, 90)
			Status.Text = tostring("2D Mode is not available yet.")
			Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)
		end
	else
		local color = Color3.fromRGB(255, 190, 90)
		Status.Text = tostring("There are no notes to send to 2D Mode.")
		Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)
	end
end

local function updatePanelSize()
	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v9 = math.clamp(viewportSize.X - 32, 360, 720)
	local v10 = math.clamp(viewportSize.Y - 72, 360, 500)
	Panel.Size = UDim2.fromOffset(v9, v10)
end

local function prepareModalInput()
	Root.Active = true
	Panel.Active = true

	for _, guiObject in ipairs(Panel:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.Active = true
		end
	end
end

local function isPointerOutsidePanel(input): boolean -- 1 equivalent call inferred from this helper
	if not (input and input.Position) then
		return false
	end

	local position3 = input.Position
	local absolutePosition = Panel.AbsolutePosition
	local absoluteSize = Panel.AbsoluteSize
	return position3.X < absolutePosition.X
		or position3.Y < absolutePosition.Y
		or position3.X > absolutePosition.X + absoluteSize.X
		or position3.Y > absolutePosition.Y + absoluteSize.Y
end

local function updateDrag(p)
	if not (v7 and position and position2) then
		return
	end

	local v9 = p.Position - position
	Panel.Position = UDim2.new(
		position2.X.Scale,
		position2.X.Offset + v9.X,
		position2.Y.Scale,
		position2.Y.Offset + v9.Y
	)

	position4 = Panel.Position
end

local function open()
	updatePanelSize()

	if flag then
		return
	end

	flag = true
	Root.Visible = true
	Overlay.BackgroundTransparency = 1
	Panel.Position = position4 + udim
	TweenService:Create(Panel, tweenInfo, { Position = position4 }):Play()
	setRecordingState(v2)
end

local function close()
	if not flag then
		return
	end

	flushPending()
	flag = false
	position4 = Panel.Position
	Overlay.BackgroundTransparency = 1
	TweenService:Create(Panel, tweenInfo, {
		Position = position4 + udim
	}):Play()
	task.delay(0.16, function()
		if not flag then
			Root.Visible = false
		end
	end)
end

Header.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	v7 = true
	position = input.Position
	position2 = Panel.Position
	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			v7 = false
		end
	end)
end)

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		v8 = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == v8 and v7 and position then
		if not position2 then
			return
		end

		local v9 = input.Position - position
		Panel.Position = UDim2.new(
			position2.X.Scale,
			position2.X.Offset + v9.X,
			position2.Y.Scale,
			position2.Y.Offset + v9.Y
		)

		position4 = Panel.Position
	end
end)

prepareModalInput()

VPNotePlayed.Event:Connect(handleNote)
OpenVPNotes.Event:Connect(open)
Close.MouseButton1Click:Connect(close)
Overlay.InputEnded:Connect(function(input)
	if
		not flag
		or input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	if isPointerOutsidePanel(input) then -- inferred equivalent call
		close()
	end
end)
PauseToggle.MouseButton1Click:Connect(function()
	flushPending()
	setRecordingState(not v2)
end)
Reset.MouseButton1Click:Connect(function()
	table.clear(v3)
	Notes.Text = ""
	count = 0
	count2 = 0
	v6 = nil
	v5 = 0
	refreshStats() -- inferred equivalent call
	local color = Color3.fromRGB(151, 163, 180)
	Status.Text = tostring("Reset.")
	Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)
end)
InsertBar.MouseButton1Click:Connect(function()
	flushPending()

	if Notes.Text ~= "" and not Notes.Text:match("|%s*$") then
		Notes.Text ..= " | "
	end

	local color = Color3.fromRGB(151, 163, 180)
	Status.Text = tostring("Inserted bar separator.")
	Status.TextColor3 = color or Color3.fromRGB(151, 163, 180)
end)
LoadSheet.MouseButton1Click:Connect(loadToSheets)
Open2D.MouseButton1Click:Connect(openIn2D)

RunService.Heartbeat:Connect(function()
	if #v3 > 0 and os.clock() - v4 >= 0.055 then
		flushPending()
	end
end)

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if flag then
			updatePanelSize()
		end
	end)
end

setRecordingState(true)
refreshStats() -- inferred equivalent call
Root.Visible = false
ClientDebugConfig.Print("[VPNotes] Initialized")