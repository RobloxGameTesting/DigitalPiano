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
local leftPane = body:WaitForChild("LeftPane")
local rightPane = body:WaitForChild("RightPane")
local newButton = leftPane:WaitForChild("NewButton")
local countLabel = leftPane:WaitForChild("CountLabel")
local sheetList = leftPane:WaitForChild("SheetList")
local sheetButtonTemplate = sheetList:WaitForChild("SheetButtonTemplate")
sheetButtonTemplate.Parent = parent
local nameBox = rightPane:WaitForChild("NameBox")
local actions = rightPane:WaitForChild("Actions")
local saveButton = actions:WaitForChild("SaveButton")
local loadButton = actions:WaitForChild("LoadButton")
local deleteButton = actions:WaitForChild("DeleteButton")
local status = rightPane:WaitForChild("Status")
local editorShell = rightPane:WaitForChild("EditorShell")
local editor = editorShell:WaitForChild("Editor")

local function configureTextObject(instance, p, value)
	if not (instance and (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox"))) then
		return
	end

	instance.TextWrapped = true
	instance.TextScaled = true
	local autoTextSizeConstraint = instance:FindFirstChild("AutoTextSizeConstraint")

	if not autoTextSizeConstraint then
		autoTextSizeConstraint = Instance.new("UITextSizeConstraint")
		autoTextSizeConstraint.Name = "AutoTextSizeConstraint"
		autoTextSizeConstraint.Parent = instance
	end

	autoTextSizeConstraint.MinTextSize = value or 8
	autoTextSizeConstraint.MaxTextSize = p or math.max(10, (math.floor(tonumber(instance.TextSize) or 14)))
end

configureTextObject(nameBox, 15, 9)
configureTextObject(saveButton, 13, 8)
configureTextObject(loadButton, 13, 8)
configureTextObject(deleteButton, 13, 8)
configureTextObject(status, 13, 8)
configureTextObject(countLabel, 12, 8)
configureTextObject(newButton, 13, 8)
configureTextObject(close, 13, 8)

local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local getPersonalSheets = remotes:WaitForChild("GetPersonalSheets")
local savePersonalSheet = remotes:WaitForChild("SavePersonalSheet")
local deletePersonalSheet = remotes:WaitForChild("DeletePersonalSheet")

local OpenPersonalSheets = ReplicatedStorage2:FindFirstChild("OpenPersonalSheets")

if not (OpenPersonalSheets and OpenPersonalSheets:IsA("BindableEvent")) then
	if OpenPersonalSheets then
		OpenPersonalSheets:Destroy()
	end

	OpenPersonalSheets = Instance.new("BindableEvent")
	OpenPersonalSheets.Name = "OpenPersonalSheets"
	OpenPersonalSheets.Parent = ReplicatedStorage2
end

local clickSound = nil
task.spawn(function()
	local soundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
	clickSound = soundFX and soundFX:FindFirstChild("ClickSound")
end)

local v = {}
local id = nil
local v2 = nil
local v3 = 0
local v4 = 20
local v5 = 50000
local flag = false
local position = panel.Position
local udim = UDim2.new(0, 0, 0, 12)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function playClick() -- 7 equivalent calls inferred from this helper
	if clickSound and clickSound:IsA("Sound") then
		clickSound:Play()
	end
end

local function setStatus(value, color) -- 7 equivalent calls inferred from this helper
	status.Text = value or ""
	status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
end

local function findSheet(p) -- 3 equivalent calls inferred from this helper
	for _, v6 in ipairs(v) do
		if v6.Id == p then
			return v6
		end
	end

	return nil
end

local function trim(text) -- 1 equivalent call inferred from this helper
	return tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function getPublicData(p) -- 1 equivalent call inferred from this helper
	local public = type(p) == "table" and p.Public or nil
	return type(public) == "table" and public or nil
end

local function isPublished(p) -- 2 equivalent calls inferred from this helper
	local publicData = getPublicData(p) -- inferred equivalent call
	return publicData and publicData.IsPublished == true
end

local function updatePublishControls() -- 5 equivalent calls inferred from this helper
	countLabel.Text = tostring(#v) .. " / " .. tostring(v4) .. " saved"
end

local function refreshEditorCanvas()
	local text = tostring(editor.Text or "")
	local count = 0
	local v6 = 1
	local maxValue = 0

	for i = 1, #text do
		if text:sub(i, i) == "\n" then
			v6 += 1
			maxValue = math.max(maxValue, count)
			count = 0
		else
			count += 1
		end
	end

	local v7 = math.max(maxValue, count)

	local v8 = math.max(editorShell.AbsoluteSize.X, 300)
	local v9 = math.max(editorShell.AbsoluteSize.Y, 180)
	local v10 = math.max(8, (math.floor(editor.TextSize * 0.62)))
	local v11 = math.max(20, editor.TextSize + 7)
	local v12 = math.max(v8 - 24, v7 * v10 + 36)
	local v13 = math.max(v9 - 20, v6 * v11 + 28)
	editor.Size = UDim2.new(0, v12, 0, v13)
	editorShell.CanvasSize = UDim2.new(0, v12 + 24, 0, v13 + 20)
end

local function setEditorText(value) -- 5 equivalent calls inferred from this helper
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

local function setCurrentSheetText(text) -- 1 equivalent call inferred from this helper
	local sheetsEditorBox = getSheetsEditorBox()
	local v6

	if sheetsEditorBox then
		sheetsEditorBox.Text = text
		v6 = true
	else
		v6 = false
	end

	local autoPlayerNotesBox = getAutoPlayerNotesBox()

	if autoPlayerNotesBox then
		autoPlayerNotesBox.Text = text
		return true
	end

	return v6
end

local function selectSheet(p)
	if v2 ~= p then
		v2 = nil
		v3 = 0
	end

	id = p
	local sheet = findSheet(p) -- inferred equivalent call

	if sheet then
		nameBox.Text = sheet.Name or "Untitled Sheet"
		setEditorText(sheet.Sheet or "") -- inferred equivalent call
		local v6 = isPublished(sheet) and " (Published)" or "" -- inferred equivalent call
		setStatus("Selected " .. nameBox.Text .. v6) -- inferred equivalent call
	else
		nameBox.Text = "Untitled Sheet"
		setEditorText() -- inferred equivalent call
		status.Text = "New sheet"
		status.TextColor3 = Color3.fromRGB(150, 162, 180)
	end

	updatePublishControls() -- inferred equivalent call
end

local function clearList()
	for _, button in ipairs(sheetList:GetChildren()) do
		if button:IsA("TextButton") and button ~= sheetButtonTemplate then
			button:Destroy()
		end
	end
end

local function renderList()
	clearList()
	countLabel.Text = tostring(#v) .. " / " .. tostring(v4) .. " saved"

	for i, v6 in ipairs(v) do
		local clone = sheetButtonTemplate:Clone()
		clone.Name = "Sheet_" .. tostring(i)
		clone.LayoutOrder = i
		clone.Visible = true
		local text = tostring(v6.Name or "Untitled Sheet")
		local public

		if type(v6) == "table" then
			public = v6.Public or nil
		end

		local v7 = type(public) == "table" and public or nil

		if v7 and v7.IsPublished == true then
			text = "[Public] " .. text
		end

		clone.Text = text
		clone.BackgroundColor3 = v6.Id == id and Color3.fromRGB(55, 128, 235) or Color3.fromRGB(32, 37, 45)
		configureTextObject(clone, 13, 8)
		clone.Parent = sheetList
		clone.Activated:Connect(function()
			playClick() -- inferred equivalent call
			selectSheet(v6.Id)
			renderList()
		end)
	end
end

local function applyPayload(p)
	local v6 = type(p) == "table" and p or {}
	v = type(v6.Sheets) == "table" and v6.Sheets or {}
	v4 = tonumber(v6.Limit) or v4
	v5 = tonumber(v6.MaxTextLength) or v5

	if id and not findSheet(id) then -- inferred equivalent call
		id = nil
	end

	renderList()
	updatePublishControls() -- inferred equivalent call
end

local function refreshFromServer()
	local success, result, v6, v7 = pcall(function()
		return getPersonalSheets:InvokeServer()
	end)

	if success and result then
		applyPayload(v7)
		setStatus(v6 or "Loaded") -- inferred equivalent call
	elseif success then
		setStatus(v6 or "Could not load personal sheets", Color3.fromRGB(255, 190, 90)) -- inferred equivalent call
	else
		local color = Color3.fromRGB(255, 90, 110)
		status.Text = "Could not reach personal sheet service"
		status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
	end
end

local function saveCurrentSheet(p)
	if p ~= false then
		playClick() -- inferred equivalent call
	end

	local v6 = trim(nameBox.Text) -- inferred equivalent call

	if v6 == "" then
		v6 = "Untitled Sheet"
		nameBox.Text = v6
	end

	local text = tostring(editor.Text or "")
	local v7 = #text

	if v5 < v7 then
		text = text:sub(1, v5)
		setEditorText(text) -- inferred equivalent call
	end

	local success, result, v8, v9, v10 = pcall(function()
		return savePersonalSheet:InvokeServer({ Id = id, Name = v6, Sheet = text })
	end)

	if success and result then
		id = v10 or id
		applyPayload(v9)

		if id then
			selectSheet(id)
		end

		renderList()
		setStatus(v8 or "Saved", Color3.fromRGB(88, 214, 141)) -- inferred equivalent call
		return true, id
	end

	if success then
		if v9 then
			applyPayload(v9)
		end

		setStatus(v8 or "Could not save", Color3.fromRGB(255, 190, 90)) -- inferred equivalent call
	else
		local color = Color3.fromRGB(255, 90, 110)
		status.Text = "Could not reach personal sheet service"
		status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
	end

	return false, nil
end

local function deleteSelectedSheet()
	playClick() -- inferred equivalent call

	if id then
		if isPublished(findSheet(id)) then -- inferred equivalent call
			v2 = nil
			v3 = 0
			local color = Color3.fromRGB(255, 190, 90)
			status.Text = "Unpublish this sheet from Community Sheets before deleting it."
			status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
		else
			v2 = nil
			v3 = 0
			local success, result, v6, v7 = pcall(function()
				return deletePersonalSheet:InvokeServer(id)
			end)

			if success and result then
				id = nil
				nameBox.Text = "Untitled Sheet"
				setEditorText() -- inferred equivalent call
				applyPayload(v7)
				setStatus(v6 or "Deleted", Color3.fromRGB(88, 214, 141)) -- inferred equivalent call
			elseif success then
				if v7 then
					applyPayload(v7)
				end

				setStatus(v6 or "Could not delete", Color3.fromRGB(255, 190, 90)) -- inferred equivalent call
			else
				local color = Color3.fromRGB(255, 90, 110)
				status.Text = "Could not reach personal sheet service"
				status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
			end
		end
	else
		local color = Color3.fromRGB(255, 190, 90)
		status.Text = "Select a saved sheet first"
		status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
	end
end

local function loadToPiano()
	playClick() -- inferred equivalent call
	local text = tostring(editor.Text or "")

	if text == "" then
		local color = Color3.fromRGB(255, 190, 90)
		status.Text = "No sheet text to load"
		status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
	elseif setCurrentSheetText(text) then -- inferred equivalent call
		local color = Color3.fromRGB(88, 214, 141)
		status.Text = "Loaded into Sheets and Autoplayer"
		status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
	else
		local color = Color3.fromRGB(255, 90, 110)
		status.Text = "Piano UI was not found"
		status.TextColor3 = color or Color3.fromRGB(150, 162, 180)
	end
end

local function newSheet()
	playClick() -- inferred equivalent call
	id = nil
	nameBox.Text = "Untitled Sheet"
	setEditorText() -- inferred equivalent call
	renderList()
	updatePublishControls() -- inferred equivalent call
	status.Text = "New sheet"
	status.TextColor3 = Color3.fromRGB(150, 162, 180)
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
	refreshFromServer()
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

local v6 = false
local position2 = nil
local position3 = nil
local v7 = nil

local function updateDrag(p)
	if not (v6 and position2 and position3) then
		return
	end

	local v8 = p.Position - position2
	panel.Position = UDim2.new(
		position3.X.Scale,
		position3.X.Offset + v8.X,
		position3.Y.Scale,
		position3.Y.Offset + v8.Y
	)

	position = panel.Position
end

header.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	v6 = true
	position2 = input.Position
	position3 = panel.Position
	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			v6 = false
		end
	end)
end)

header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		v7 = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == v7 and v6 and position2 then
		if not position3 then
			return
		end

		local v8 = input.Position - position2
		panel.Position = UDim2.new(
			position3.X.Scale,
			position3.X.Offset + v8.X,
			position3.Y.Scale,
			position3.Y.Offset + v8.Y
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

OpenPersonalSheets.Event:Connect(openPanel)
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
newButton.Activated:Connect(newSheet)
saveButton.Activated:Connect(saveCurrentSheet)
loadButton.Activated:Connect(loadToPiano)
deleteButton.Activated:Connect(deleteSelectedSheet)
editor:GetPropertyChangedSignal("Text"):Connect(function()
	refreshEditorCanvas()
	updatePublishControls() -- inferred equivalent call
end)
editorShell:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshEditorCanvas)

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
nameBox.Text = "Untitled Sheet"
refreshEditorCanvas()
updatePublishControls() -- inferred equivalent call
ClientDebugConfig.Print("[PersonalSheets] Initialized")