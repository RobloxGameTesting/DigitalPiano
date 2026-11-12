local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local parent = script.Parent
local overlay = parent:WaitForChild("Overlay")
local panel = parent:WaitForChild("Panel")
local header = panel:WaitForChild("Header")
local close = header:WaitForChild("Close")
local body = panel:WaitForChild("Body")
local controls = body:WaitForChild("Controls")
local editorShell = body:WaitForChild("EditorShell")
local editor = editorShell:WaitForChild("Editor")
local status = body:WaitForChild("Status")

local transposeDown = controls:WaitForChild("TransposeDown")
local transposeUp = controls:WaitForChild("TransposeUp")
local loadCurrent = controls:WaitForChild("LoadCurrent")
local applyCurrent = controls:WaitForChild("ApplyCurrent")
local clear = controls:WaitForChild("Clear")

local v = {}

for i = 1, 61 do
	v[("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(i, i)] = i
end

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local flag = false
local position = panel.Position
local udim = UDim2.new(0, 0, 0, 12)

local clickSound = nil
task.spawn(function()
	local soundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
	clickSound = soundFX and soundFX:FindFirstChild("ClickSound")
end)

local OpenSheetTranspose = ReplicatedStorage2:FindFirstChild("OpenSheetTranspose")

if not (OpenSheetTranspose and OpenSheetTranspose:IsA("BindableEvent")) then
	if OpenSheetTranspose then
		OpenSheetTranspose:Destroy()
	end

	OpenSheetTranspose = Instance.new("BindableEvent")
	OpenSheetTranspose.Name = "OpenSheetTranspose"
	OpenSheetTranspose.Parent = ReplicatedStorage2
end

local function playClick() -- 6 equivalent calls inferred from this helper
	if clickSound and clickSound:IsA("Sound") then
		clickSound:Play()
	end
end

local function setStatus(value, p) -- 1 equivalent call inferred from this helper
	status.Text = value or ""
	status.TextColor3 = p or Color3.fromRGB(150, 162, 180)
end

local function refreshEditorCanvas()
	if not editorShell:IsA("ScrollingFrame") then
		return
	end

	local text = tostring(editor.Text or "")
	local count = 0
	local v2 = 1
	local maxValue = 0

	for i = 1, #text do
		if text:sub(i, i) == "\n" then
			v2 += 1
			maxValue = math.max(maxValue, count)
			count = 0
		else
			count += 1
		end
	end

	local v3 = math.max(maxValue, count)

	local v4 = math.max(editorShell.AbsoluteSize.X, 300)
	local v5 = math.max(editorShell.AbsoluteSize.Y, 180)
	local v6 = math.max(8, (math.floor(editor.TextSize * 0.62)))
	local v7 = math.max(20, editor.TextSize + 7)
	local v8 = math.max(v4 - 24, v3 * v6 + 36)
	local v9 = math.max(v5 - 20, v2 * v7 + 28)

	editor.Size = UDim2.new(0, v8, 0, v9)
	editorShell.CanvasSize = UDim2.new(0, v8 + 24, 0, v9 + 20)
end

local function setEditorText(value) -- 3 equivalent calls inferred from this helper
	editor.Text = tostring(value or "")
	refreshEditorCanvas()
end

local function getPianoUI() -- 2 equivalent calls inferred from this helper
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	return playerGui and playerGui:FindFirstChild("PianoUI")
end

local function getSheetsEditorBox()
	local pianoUI = getPianoUI() -- inferred equivalent call
	local sheets = pianoUI and pianoUI:FindFirstChild("Sheets")
	local card = sheets and sheets:FindFirstChild("Card")
	local scroll = card and card:FindFirstChild("Scroll")
	local editor2 = scroll and scroll:FindFirstChild("Editor")
	return if editor2 and editor2:IsA("TextBox") then editor2 else nil
end

local function getAutoPlayerNotesBox()
	local pianoUI = getPianoUI() -- inferred equivalent call
	local pianoContainer = pianoUI and pianoUI:FindFirstChild("PianoContainer")
	local autoPlayer = pianoContainer and pianoContainer:FindFirstChild("AutoPlayer")
	local notes = autoPlayer and autoPlayer:FindFirstChild("Notes")
	return if notes and notes:IsA("TextBox") then notes else nil
end

local function getCurrentSheetText()
	local sheetsEditorBox = getSheetsEditorBox()

	if sheetsEditorBox and tostring(sheetsEditorBox.Text or ""):match("%S") then
		return sheetsEditorBox.Text, "Sheets"
	end

	local autoPlayerNotesBox = getAutoPlayerNotesBox()

	if autoPlayerNotesBox and tostring(autoPlayerNotesBox.Text or ""):match("%S") then
		return autoPlayerNotesBox.Text, "Autoplayer"
	end

	return "", nil
end

local function setCurrentSheetText(text) -- 1 equivalent call inferred from this helper
	local text2 = tostring(text or "")

	local sheetsEditorBox = getSheetsEditorBox()
	local v2

	if sheetsEditorBox then
		sheetsEditorBox.Text = text2
		v2 = true
	else
		v2 = false
	end

	local autoPlayerNotesBox = getAutoPlayerNotesBox()

	if autoPlayerNotesBox then
		autoPlayerNotesBox.Text = text2
		return true
	end

	return v2
end

local function shiftNoteChar(p, p2) -- 2 equivalent calls inferred from this helper
	local v2 = v[p]

	if not v2 then
		return nil
	end

	local v3 = v2 + p2

	if v3 < 1 or v3 > 61 then
		return nil
	end

	return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(v3, v3)
end

local function sortChord(list)
	table.sort(list, function(a, b): boolean
		return (v[a] or 0) < (v[b] or 0)
	end)

	return table.concat(list)
end

local function appendChord(list, list2)
	table.sort(list2, function(a, b): boolean
		return (v[a] or 0) < (v[b] or 0)
	end)

	local joined = table.concat(list2)

	if #joined == 0 then
		return
	end

	if #joined == 1 then
		table.insert(list, joined)
	else
		table.insert(list, "[" .. joined .. "]")
	end
end

local function transposeSheetText(text, p)
	local v2 = tostring(text or "")
	local flag2 = false
	local v3 = {}
	local v4 = {}

	local function fn(p2, p3): boolean
		return (v[p2] or 0) < (v[p3] or 0)
	end

	for i = 1, #v2 do
		local v5 = v2:sub(i, i)

		if v5 == "[" then
			if flag2 then
				table.sort(v3, fn)

				local joined = table.concat(v3)

				if #joined ~= 0 then
					if #joined == 1 then
						table.insert(v4, joined)
					else
						table.insert(v4, "[" .. joined .. "]")
					end
				end
			end

			flag2 = true
			v3 = {}
		elseif v5 == "]" then
			if flag2 then
				table.sort(v3, fn)

				local joined = table.concat(v3)

				if #joined ~= 0 then
					if #joined == 1 then
						table.insert(v4, joined)
					else
						table.insert(v4, "[" .. joined .. "]")
					end
				end
			end

			flag2 = false
			v3 = {}
		elseif flag2 then
			local v6 = shiftNoteChar(v5, p) -- inferred equivalent call

			if v6 then
				table.insert(v3, v6)
			end
		else
			local v6 = shiftNoteChar(v5, p) -- inferred equivalent call

			if v6 then
				table.insert(v4, v6)
			elseif v5 == " " or v5 == "\n" or v5 == "\r" or v5 == "\t" or v5 == "-" or v5 == "|" then
				table.insert(v4, v5)
			end
		end
	end

	if flag2 then
		table.sort(v3, fn)

		local joined = table.concat(v3)

		if #joined ~= 0 then
			if #joined == 1 then
				table.insert(v4, joined)
			else
				table.insert(v4, "[" .. joined .. "]")
			end
		end
	end

	return (table.concat(v4):gsub("  ", " "):gsub("\n ", "\n"))
end

local function openPanel()
	if flag then
		return
	end

	flag = true
	overlay.Visible = true
	panel.Visible = true
	overlay.BackgroundTransparency = 1
	panel.Position = position + udim
	TweenService:Create(overlay, tweenInfo, { BackgroundTransparency = 0.55 }):Play()
	TweenService:Create(panel, tweenInfo, { Position = position }):Play()
	refreshEditorCanvas()
	status.Text = "Ready"
	status.TextColor3 = Color3.fromRGB(150, 162, 180)
end

local function closePanel()
	if not flag then
		return
	end

	flag = false
	position = panel.Position
	TweenService:Create(overlay, tweenInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(panel, tweenInfo, {
		Position = position + udim
	}):Play()
	task.delay(0.16, function()
		if not flag then
			overlay.Visible = false
			panel.Visible = false
			panel.Position = position
		end
	end)
end

local function loadCurrentSheet()
	playClick() -- inferred equivalent call
	local currentSheetText, v2 = getCurrentSheetText()
	setEditorText(currentSheetText) -- inferred equivalent call

	if v2 then
		setStatus("Loaded from " .. v2) -- inferred equivalent call
	else
		local color = Color3.fromRGB(255, 190, 90)
		status.Text = "No current sheet text found"
		status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
	end
end

local function applyToCurrentSheet()
	playClick() -- inferred equivalent call

	if tostring(editor.Text or ""):match("%S") then
		if setCurrentSheetText(editor.Text) then -- inferred equivalent call
			local color = Color3.fromRGB(88, 214, 141)
			status.Text = "Applied to Sheets and Autoplayer"
			status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
		else
			local color = Color3.fromRGB(255, 90, 110)
			status.Text = "Piano UI was not found"
			status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
		end
	else
		local color = Color3.fromRGB(255, 190, 90)
		status.Text = "Nothing to apply"
		status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
	end
end

local function transposeEditor(p)
	playClick() -- inferred equivalent call

	if not tostring(editor.Text or ""):match("%S") then
		loadCurrentSheet()
	end

	if not tostring(editor.Text or ""):match("%S") then
		return
	end

	setEditorText(transposeSheetText(editor.Text, p)) -- inferred equivalent call

	if p > 0 then
		status.Text = "Transposed up one key"
	else
		status.Text = "Transposed down one key"
	end

	status.TextColor3 = Color3.fromRGB(150, 162, 180)
end

local function clearEditor()
	playClick() -- inferred equivalent call
	setEditorText() -- inferred equivalent call
	status.Text = "Cleared"
	status.TextColor3 = Color3.fromRGB(150, 162, 180)
end

local v2 = false
local position2 = nil
local position3 = nil
local v3 = nil

local function updateDrag(p)
	if not (v2 and position2 and position3) then
		return
	end

	local v4 = p.Position - position2
	panel.Position = UDim2.new(
		position3.X.Scale,
		position3.X.Offset + v4.X,
		position3.Y.Scale,
		position3.Y.Offset + v4.Y
	)

	position = panel.Position
end

header.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	v2 = true
	position2 = input.Position
	position3 = panel.Position

	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			v2 = false
		end
	end)
end)

header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		v3 = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == v3 and v2 and position2 then
		if not position3 then
			return
		end

		local v4 = input.Position - position2
		panel.Position = UDim2.new(
			position3.X.Scale,
			position3.X.Offset + v4.X,
			position3.Y.Scale,
			position3.Y.Offset + v4.Y
		)

		position = panel.Position
	end
end)

local function prepareModalInput()
	panel.Active = true

	for _, guiObject in ipairs(panel:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.Active = true
		end
	end
end

local function isPointerOutsidePanel(p): boolean -- 1 equivalent call inferred from this helper
	if not (p and p.Position) then
		return false
	end

	local position4 = p.Position
	local absolutePosition = panel.AbsolutePosition
	local absoluteSize = panel.AbsoluteSize
	return position4.X < absolutePosition.X
		or position4.Y < absolutePosition.Y
		or position4.X > absolutePosition.X + absoluteSize.X
		or position4.Y > absolutePosition.Y + absoluteSize.Y
end

prepareModalInput()

editor:GetPropertyChangedSignal("Text"):Connect(refreshEditorCanvas)

editorShell:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshEditorCanvas)

OpenSheetTranspose.Event:Connect(openPanel)
overlay.Activated:Connect(function(p)
	if not isPointerOutsidePanel(p) then -- inferred equivalent call
		return
	end

	playClick() -- inferred equivalent call
	closePanel()
end)
close.Activated:Connect(function()
	playClick() -- inferred equivalent call
	closePanel()
end)
transposeUp.Activated:Connect(function()
	transposeEditor(1)
end)
transposeDown.Activated:Connect(function()
	transposeEditor(-1)
end)
loadCurrent.Activated:Connect(loadCurrentSheet)
applyCurrent.Activated:Connect(applyToCurrentSheet)
clear.Activated:Connect(clearEditor)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not flag then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
		closePanel()
	end
end)

panel.Visible = false
overlay.Visible = false
refreshEditorCanvas()
status.Text = ""
status.TextColor3 = Color3.fromRGB(150, 162, 180)

ClientDebugConfig.Print("[SheetTranspose] Initialized")