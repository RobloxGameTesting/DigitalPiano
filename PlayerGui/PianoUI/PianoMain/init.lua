local guiObject = require
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = guiObject(ReplicatedStorage2:WaitForChild("ClientDebugConfig"))

do
	local Players2 = game:GetService("Players")
	Players = Players2
end

do
	local ContextActionService2 = game:GetService("ContextActionService")
	ContextActionService = ContextActionService2
end

do
	local UserInputService2 = game:GetService("UserInputService")
	UserInputService = UserInputService2
end

do
	local GuiService2 = game:GetService("GuiService")
	GuiService = GuiService2
end

do
	local RunService2 = game:GetService("RunService")
	RunService = RunService2
end

do
	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	ReplicatedStorage = ReplicatedStorage3
end

do
	local TweenService2 = game:GetService("TweenService")
	TweenService = TweenService2
end

PianoPractice = {
	IconClass = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Icon")),
	Active = false,
	Icon = nil,
	Syncing = false,
	Movement = nil
}

local clickSound = ReplicatedStorage:WaitForChild("SoundFX"):WaitForChild("ClickSound")

Piano_Dependencies = workspace.Piano_Dependencies

Folder_Modules = Piano_Dependencies.Modules
Folder_Remotes = Piano_Dependencies.Remotes

GetPianoUserSettingsRemote = Folder_Remotes:WaitForChild("GetPianoUserSettings")
PianoUserSettingsLoadedRemote = Folder_Remotes:WaitForChild("PianoUserSettingsLoaded")
Folder_Logic = Folder_Modules.Logic
Folder_Dependencies = Folder_Modules.Dependencies

local PianoPackets = require(Folder_Dependencies:WaitForChild("PianoPackets"))

do
	local DraggableObject = require(Folder_Dependencies.DraggableObject)
	Dependence_DraggableObject = DraggableObject
end

do
	local Soundfonts = require(Folder_Dependencies.Soundfonts)
	Dependence_Soundfonts = Soundfonts
end

do
	local SoundEffects = require(Folder_Dependencies:WaitForChild("SoundEffects"))
	Dependence_SoundEffects = SoundEffects
end

do
	local PlayerVariables = require(Folder_Dependencies.PlayerVariables)
	Dependence_PlayerVariables = PlayerVariables
end

do
	local HandIK2 = require(workspace.Piano_Dependencies.Modules.Dependencies:WaitForChild("HandIK"))
	HandIK = HandIK2
end

do
	local PianoVisualization2 = require(Folder_Dependencies:WaitForChild("PianoVisualization"))
	PianoVisualization = PianoVisualization2
end

do
	local PianoModelKeyHighlight2 = require(Folder_Dependencies:WaitForChild("PianoModelKeyHighlight"))
	PianoModelKeyHighlight = PianoModelKeyHighlight2
end

do
	local PianoLogic = require(Folder_Logic.PianoLogic)
	Logic_Piano = PianoLogic
end

do
	local CharacterLogic = require(Folder_Logic.CharacterLogic)
	Logic_Character = CharacterLogic
end

do
	local KeymapLogic = require(Folder_Logic.KeymapLogic)
	Logic_Keymap = KeymapLogic
end

do
	local UILogic = require(Folder_Logic.UILogic)
	Logic_UI = UILogic
end

do
	local BindsLogic = require(Folder_Logic.BindsLogic)
	Logic_Binds = BindsLogic
end

do
	local RecordingLogic = require(Folder_Logic.RecordingLogic)
	Logic_Recording = RecordingLogic
end

local AutoPlayerHandler = require(script:WaitForChild("AutoPlayerHandler"))
local RecordingUIHandler = require(script:WaitForChild("RecordingUIHandler"))
local MidiPlayerHandler = require(script:WaitForChild("MidiPlayerHandler"))

do
	local PianoRoll2DHandler2 = require(script:WaitForChild("PianoRoll2DHandler"))
	PianoRoll2DHandler = PianoRoll2DHandler2
end

do
	local ToolVisibilityController2 = require(script:WaitForChild("ToolVisibilityController"))
	ToolVisibilityController = ToolVisibilityController2
end

local NPSCounter = require(Folder_Logic:WaitForChild("NPSCounter"))

LocalPlayer = Players.LocalPlayer

local LocalPianoSessionStateChanged = ReplicatedStorage:FindFirstChild("LocalPianoSessionStateChanged")

if not (LocalPianoSessionStateChanged and LocalPianoSessionStateChanged:IsA("BindableEvent")) then
	if LocalPianoSessionStateChanged then
		LocalPianoSessionStateChanged:Destroy()
	end

	LocalPianoSessionStateChanged = Instance.new("BindableEvent")
	LocalPianoSessionStateChanged.Name = "LocalPianoSessionStateChanged"
	LocalPianoSessionStateChanged.Parent = ReplicatedStorage
end

pcall(function()
	LocalPianoSessionStateChanged.Sandboxed = true
end)

Dependence_PlayerVariables.Current_SoundEffects = Dependence_SoundEffects.NormalizeState(Dependence_PlayerVariables.Current_SoundEffects)

function SetCurrentSoundEffectsState(p)
	local state = Dependence_SoundEffects.NormalizeState(p)
	Dependence_PlayerVariables.Current_SoundEffects = state
	LocalPlayer:SetAttribute("PianoSoundEffects", Dependence_SoundEffects.EncodeState(state))
	return state
end

function GetCurrentSoundEffectsState()
	return Dependence_PlayerVariables.Current_SoundEffects or Dependence_SoundEffects.NormalizeState(nil)
end

local v2 = nil
local humanoid = nil

local flag = false

local function waitForStartupChild(instance, childName, p)
	if not instance then
		return nil
	end

	local child = instance:FindFirstChild(childName)

	if child then
		return child
	end

	local child2 = instance:WaitForChild(childName, 30)

	if not child2 then
		v.Warn(("[PianoMain] Missing %s under %s after startup wait%s"):format(
			childName,
			instance:GetFullName(),
			p and " for " .. p or ""
		))
	end

	return child2
end

do
	local v3 = waitForStartupChild(LocalPlayer, "PlayerGui", "notebind setup")
	local v4 = v3 and waitForStartupChild(v3, "Settings", "notebind setup")
	local v5 = v4 and waitForStartupChild(v4, "Settings", "notebind setup")
	local v6 = v5 and waitForStartupChild(v5, "Center", "notebind setup")
	local v7 = v6 and waitForStartupChild(v6, "Body", "notebind setup")
	guiObject = v7 and waitForStartupChild(v7, "Notebinds", "notebind setup")
end

if guiObject then
	Logic_Binds.Initialize(guiObject, Logic_Keymap)
end

local function isPlayablePianoModel(model): boolean
	if not (model and model:IsA("Model") and model:FindFirstChild("SeatOccupant")) then
		return false
	end

	local scripts = model:FindFirstChild("Scripts")

	if not scripts then
		return false
	end

	return scripts:FindFirstChild("PianoMain") ~= nil and scripts:FindFirstChild("PianoModule") ~= nil
end

local function getPianoModel(instance)
	local pianos = workspace:FindFirstChild("Pianos")

	if not (pianos and instance and instance:IsDescendantOf(pianos)) then
		return nil
	end

	local parent = instance.Parent

	while parent and parent ~= pianos do
		if isPlayablePianoModel(parent) then
			return parent
		end

		parent = parent.Parent
	end

	return nil
end

function PrewarmCurrentSoundfont(p)
	local v3 = p or Dependence_PlayerVariables.Current_SoundfontID
	local dependence_Soundfont = Dependence_Soundfonts[v3]

	if dependence_Soundfont and Logic_Piano.PrewarmSoundfont then
		Logic_Piano.PrewarmSoundfont(dependence_Soundfont.AssetIds, dependence_Soundfont.PacketType)
	end
end

local function SetupCharacter(character)
	v2 = character
	humanoid = character:FindFirstChildOfClass("Humanoid")
		or waitForStartupChild(character, "Humanoid", "character setup")

	if not humanoid then
		return
	end

	humanoid.Died:Connect(function()
		if PianoPractice.Active and PianoPractice.End then
			PianoPractice.End("died")
		else
			UnbindPiano("died")
		end
	end)

	if PianoPractice.Active and PianoPractice.ApplyMovementLock then
		task.defer(PianoPractice.ApplyMovementLock)
	end

	humanoid.Seated:Connect(function(p, p2)
		if p then
			if getPianoModel(p2) then
				if PianoPractice.Active and PianoPractice.End then
					PianoPractice.End("piano-seat")
				end

				BindPiano(p2)
			elseif flag then
				UnbindPiano("non-piano-seat")
			end
		elseif flag then
			UnbindPiano("unseated")
		end
	end)
end

if LocalPlayer.Character then
	SetupCharacter(LocalPlayer.Character)
end

local characterAddedConnection = LocalPlayer.CharacterAdded:Connect(SetupCharacter)

PianoUI = script.Parent
PianoContainer = PianoUI.PianoContainer
DesktopPianoContainer = PianoContainer
MobilePianoContainer = PianoUI:FindFirstChild("MobilePianoContainer")

PianoUI.Enabled = true
PianoContainer.Visible = false
PianoContainerVisiblePosition = PianoContainer.Position
PianoContainerHiddenPosition = UDim2.new(
	PianoContainerVisiblePosition.X.Scale,
	PianoContainerVisiblePosition.X.Offset,
	PianoContainerVisiblePosition.Y.Scale + 0.18,
	PianoContainerVisiblePosition.Y.Offset
)

PianoVisibilityTween = nil
PianoVisibilityTargetVisible = false
PianoCollapseKnob = PianoContainer:FindFirstChild("PianoCollapseKnob")

if PianoCollapseKnob and PianoCollapseKnob:IsA("GuiObject") then
	PianoCollapseKnob.Visible = false
end

DesktopPianoCollapsed = false
DesktopPianoCollapseTween = nil

if MobilePianoContainer then
	MobilePianoContainer.Visible = false
end

if PianoUI:FindFirstChild("MobileUIPrompt") and PianoUI.MobileUIPrompt:IsA("GuiObject") then
	PianoUI.MobileUIPrompt.Visible = false
	PianoUI.MobileUIPrompt.Active = true
end

local TouchEnabled = UserInputService.TouchEnabled
local visible2 = TouchEnabled
local v3 = not TouchEnabled

do
	local function sendMobileDetectedNotification()
		task.spawn(function()
			for _ = 1, 20 do
				if pcall(function()
					local StarterGui = game:GetService("StarterGui")
					StarterGui:SetCore("SendNotification", {
						Title = "Mobile device detected",
						Text = "Choose Mobile UI or PC UI for this session.",
						Duration = 5
					})
				end) then
					break
				end

				task.wait(0.25)
			end
		end)
	end
end

local function createFallbackMobilePrompt()
	local mobileUIPrompt = Instance.new("Frame")
	mobileUIPrompt.Name = "MobileUIPrompt"
	mobileUIPrompt.AnchorPoint = Vector2.new(0.5, 0.5)
	mobileUIPrompt.Position = UDim2.fromScale(0.5, 0.5)
	mobileUIPrompt.Size = UDim2.fromScale(1, 1)
	mobileUIPrompt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	mobileUIPrompt.BackgroundTransparency = 0.35
	mobileUIPrompt.BorderSizePixel = 0
	mobileUIPrompt.ZIndex = 5000
	mobileUIPrompt.Active = true
	mobileUIPrompt.Parent = PianoUI

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.new(0, 430, 0, 210)
	panel.BackgroundColor3 = Color3.fromRGB(25, 28, 34)
	panel.BorderSizePixel = 0
	panel.ZIndex = 5001
	panel.Parent = mobileUIPrompt
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = panel
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(78, 88, 104)
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.1
	uiStroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 24, 0, 20)
	title.Size = UDim2.new(1, -48, 0, 32)
	title.Font = Enum.Font.GothamBold
	title.Text = "Device UI"
	title.TextColor3 = Color3.fromRGB(245, 247, 250)
	title.TextSize = 22
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 5002
	title.Parent = panel

	local body = Instance.new("TextLabel")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0, 24, 0, 58)
	body.Size = UDim2.new(1, -48, 0, 56)
	body.Font = Enum.Font.Gotham
	body.Text = "Choose which piano controls you want to use for this session."
	body.TextColor3 = Color3.fromRGB(210, 216, 224)
	body.TextSize = 15
	body.TextWrapped = true
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.ZIndex = 5002
	body.Parent = panel

	local function makeButton(name, text, position, backgroundColor)
		local textButton = Instance.new("TextButton")
		textButton.Name = name
		textButton.Position = position
		textButton.Size = UDim2.new(0.5, -34, 0, 46)
		textButton.BackgroundColor3 = backgroundColor
		textButton.BorderSizePixel = 0
		textButton.AutoButtonColor = true
		textButton.Font = Enum.Font.GothamBold
		textButton.Text = text
		textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		textButton.TextSize = 15
		textButton.ZIndex = 5002
		textButton.Active = true
		textButton.Parent = panel
		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(0, 8)
		uiCorner2.Parent = textButton
		return textButton
	end

	makeButton("MobileButton", "Use Mobile UI", UDim2.new(0, 24, 1, -70), Color3.fromRGB(45, 147, 255))
	makeButton("PCButton", "Use PC UI", UDim2.new(0.5, 10, 1, -70), Color3.fromRGB(56, 61, 70))
	return mobileUIPrompt
end

local function showMobileUIPromptIfNeeded(p)
	if not (p or TouchEnabled) then
		return
	end

	if not p then
		task.spawn(function()
			for _ = 1, 20 do
				if pcall(function()
					local StarterGui = game:GetService("StarterGui")
					StarterGui:SetCore("SendNotification", {
						Title = "Mobile device detected",
						Text = "Choose Mobile UI or PC UI for this session.",
						Duration = 5
					})
				end) then
					break
				end

				task.wait(0.25)
			end
		end)
	end

	local guiObject2 = PianoUI:FindFirstChild("MobileUIPrompt")

	if not (guiObject2 and guiObject2:IsA("GuiObject")) then
		guiObject2 = createFallbackMobilePrompt()
	end

	local title = guiObject2:FindFirstChild("Title", true)
	local body = guiObject2:FindFirstChild("Body", true)

	if title and title:IsA("TextLabel") then
		title.Text = "Device UI"
	end

	if body and body:IsA("TextLabel") then
		body.Text = "Choose which piano controls you want to use for this session."
	end

	local mobileButton = guiObject2:FindFirstChild("MobileButton", true)
	local pcButton = guiObject2:FindFirstChild("PCButton", true)

	if mobileButton and mobileButton:IsA("GuiButton") and pcButton and pcButton:IsA("GuiButton") then
		guiObject2.Visible = true
		guiObject2.Active = true
		mobileButton.Active = true
		pcButton.Active = true
		mobileButton.Selectable = true
		pcButton.Selectable = true
		local bindableEvent = Instance.new("BindableEvent")
		local connections = {}
		local flag2 = false
		local function choose(p2) -- 4 equivalent calls inferred from this helper
			if flag2 then
				return
			end

			flag2 = true
			visible2 = p2
			v3 = true
			guiObject2.Visible = false

			if ApplyDeviceUIChoice then
				ApplyDeviceUIChoice(p2)
			end

			bindableEvent:Fire()
		end
		local function connectChoiceButton(data, p2)
			table.insert(connections, data.Activated:Connect(function()
				choose(p2) -- inferred equivalent call
			end))
			table.insert(connections, data.MouseButton1Click:Connect(function()
				choose(p2) -- inferred equivalent call
			end))
			table.insert(connections, data.TouchTap:Connect(function()
				choose(p2) -- inferred equivalent call
			end))
			table.insert(connections, data.InputBegan:Connect(function(input)
				if
					input.UserInputType == Enum.UserInputType.Touch
					or input.UserInputType == Enum.UserInputType.MouseButton1
				then
					choose(p2) -- inferred equivalent call
				end
			end))
		end
		connectChoiceButton(mobileButton, true)
		connectChoiceButton(pcButton, false)
		bindableEvent.Event:Wait()

		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		bindableEvent:Destroy()
	else
		v3 = true
		visible2 = true

		if ApplyDeviceUIChoice then
			ApplyDeviceUIChoice(visible2)
		end
	end
end

showMobileUIPromptIfNeeded()

local scrollingEnabled = false
local v4 = false
local v5 = nil
local v6 = nil
local v7 = false
local udim = nil
local udim2 = nil
local udim3 = nil
local v8 = nil
local guiObject2 = nil
local mobileUtilityButtons = nil
local button = nil
MobileBurgerButton = nil
MobileBurgerPanel = nil

MOBILE_KEY_LAYOUT_BASE_WIDTH = 80
local keyWidth = 52
local keyHeight = 130
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local v16 = nil
local keySizeButton = nil
local keySizePanel = nil
local resetKeySize = nil
local v17 = nil
local fn

MobileOctaveScroller = MobileOctaveScroller or {}

do
	local function getMobileKeysFrame() -- 8 equivalent calls inferred from this helper
		if not MobilePianoContainer then
			return nil
		end

		local keyFrame = MobilePianoContainer:FindFirstChild("KeyFrame")
		local keyFrame2 = keyFrame and keyFrame:FindFirstChild("KeyFrame")

		if keyFrame2 and keyFrame2:IsA("GuiObject") then
			return keyFrame2
		end

		return nil
	end
end

do
	local function clampMobileKeyValue(p, p2, min, max) -- 6 equivalent calls inferred from this helper
		local v18 = tonumber(p)

		if v18 then
			return (math.clamp(math.floor(v18 + 0.5), min, max))
		end

		return p2
	end
end

do
	local function updateMobileKeySizeLabels() -- 4 equivalent calls inferred from this helper
		if v9 then
			v9.Text = tostring(keyWidth) .. " px"
		end

		if v10 then
			v10.Text = tostring(keyHeight) .. " px"
		end

		if fn then
			fn()
		end
	end
end

local function applyMobileKeySize()
	local mobileKeysFrame = getMobileKeysFrame() -- inferred equivalent call

	if not mobileKeysFrame then
		return
	end

	local v18 = math.floor(keyWidth * 0.575 + 0.5)
	local v19 = math.floor(keyHeight * (77 / 131) + 0.5)
	local maxValue = 0

	for _, button2 in ipairs(mobileKeysFrame:GetChildren()) do
		if not button2:IsA("GuiButton") then
			continue
		end

		if button2:GetAttribute("MobileDefaultX") == nil then
			button2:SetAttribute("MobileDefaultX", button2.Position.X.Offset)
			button2:SetAttribute(
				"MobileIsBlackKey",
				button2.Size.X.Offset < 56 or button2.ZIndex > 2 or button2.BackgroundColor3 == Color3.new(0, 0, 0)
			)
		end

		local mobileDefaultX = tonumber(button2:GetAttribute("MobileDefaultX")) or button2.Position.X.Offset
		local mobileIsBlackKey = button2:GetAttribute("MobileIsBlackKey") == true
		local v20 = mobileIsBlackKey and v18 or keyWidth
		local v21 = mobileIsBlackKey and v19 or keyHeight
		local v22 = math.floor(mobileDefaultX / MOBILE_KEY_LAYOUT_BASE_WIDTH * keyWidth + 0.5)

		button2.Position = UDim2.new(0, v22, button2.Position.Y.Scale, button2.Position.Y.Offset)
		button2.Size = UDim2.new(0, v20, 0, v21)
		maxValue = math.max(maxValue, v22 + v20)

		local noteLabel = button2:FindFirstChild("NoteLabel")

		if not (noteLabel and noteLabel:IsA("TextLabel")) then
			continue
		end

		local visible = not mobileIsBlackKey

		if visible then
			if keyWidth >= 18 then
				visible = keyHeight >= 50
			else
				visible = false
			end
		end

		noteLabel.Visible = visible

		if not noteLabel.Visible then
			continue
		end

		noteLabel.TextSize = math.clamp(math.floor(keyWidth * 0.4), 20, 34)
		noteLabel.Size = UDim2.new(1, -8, 0, (math.clamp(math.floor(keyHeight * 0.14), 28, 42)))
	end

	if mobileKeysFrame:IsA("ScrollingFrame") then
		mobileKeysFrame.AutomaticCanvasSize = Enum.AutomaticSize.None
		mobileKeysFrame.CanvasSize = UDim2.new(0, maxValue, 0, keyHeight)
		mobileKeysFrame.CanvasPosition = Vector2.new(
			math.min(mobileKeysFrame.CanvasPosition.X, (math.max(maxValue - mobileKeysFrame.AbsoluteSize.X, 0))),
			0
		)
	end

	if MobileOctaveScroller.Update then
		MobileOctaveScroller.Update()
	end
end

do
	local function setMobileKeySize(p, p2) -- 3 equivalent calls inferred from this helper
		keyWidth = clampMobileKeyValue(p, 52, 0, 128) -- inferred equivalent call
		keyHeight = clampMobileKeyValue(p2, 130, 0, 320) -- inferred equivalent call
		updateMobileKeySizeLabels() -- inferred equivalent call
		applyMobileKeySize()
	end
end

do
	local function saveMobileKeySize(p)
		local saveMobilePianoSettings = Folder_Remotes:WaitForChild("SaveMobilePianoSettings")

		if p then
			saveMobilePianoSettings:FireServer({ Reset = true })
		else
			saveMobilePianoSettings:FireServer({ KeyWidth = keyWidth, KeyHeight = keyHeight })
		end
	end
end

function MobileOctaveScroller.GetTrack()
	if
		MobileOctaveScroller.Track
		and MobileOctaveScroller.Track.Parent
		and MobileOctaveScroller.Track:IsA("GuiObject")
	then
		return MobileOctaveScroller.Track
	end

	if not MobileOctaveScroller.Frame then
		return nil
	end

	MobileOctaveScroller.InsetFrame = MobileOctaveScroller.Frame:FindFirstChild("InsetFrame")
	MobileOctaveScroller.Track = MobileOctaveScroller.InsetFrame
		and MobileOctaveScroller.InsetFrame:FindFirstChild("BottomOctave")

	if MobileOctaveScroller.Track and MobileOctaveScroller.Track:IsA("GuiObject") then
		return MobileOctaveScroller.Track
	end

	return nil
end

function MobileOctaveScroller.GetCanvasWidth(p)
	local success, result = pcall(function()
		return p.AbsoluteCanvasSize
	end)

	if success and typeof(result) == "Vector2" and result.X > 0 then
		return result.X
	end

	return p.CanvasSize.X.Offset
end

function MobileOctaveScroller.GetScrollLimit(guiObject3)
	if not guiObject3 then
		if MobilePianoContainer then
			local keyFrame = MobilePianoContainer:FindFirstChild("KeyFrame")
			guiObject3 = keyFrame and keyFrame:FindFirstChild("KeyFrame")

			if not (guiObject3 and guiObject3:IsA("GuiObject")) then
				guiObject3 = nil
			end
		else
			guiObject3 = nil
		end
	end

	if guiObject3 and guiObject3:IsA("ScrollingFrame") then
		return (math.max(MobileOctaveScroller.GetCanvasWidth(guiObject3) - guiObject3.AbsoluteSize.X, 0))
	end

	return 0
end

function MobileOctaveScroller.SetScrollPosition(p, p2)
	local mobileKeysFrame = getMobileKeysFrame() -- inferred equivalent call

	if not (mobileKeysFrame and mobileKeysFrame:IsA("ScrollingFrame")) then
		return
	end

	local v18 = math.clamp(
		math.floor((tonumber(p) or 0) + 0.5),
		0,
		MobileOctaveScroller.GetScrollLimit(mobileKeysFrame)
	)

	if MobileOctaveScroller.Tween then
		MobileOctaveScroller.Tween:Cancel()
		MobileOctaveScroller.Tween = nil
	end

	if p2 then
		MobileOctaveScroller.Tween = TweenService:Create(
			mobileKeysFrame,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CanvasPosition = Vector2.new(v18, 0) }
		)

		MobileOctaveScroller.Tween:Play()
	else
		mobileKeysFrame.CanvasPosition = Vector2.new(v18, 0)
	end

	if MobileOctaveScroller.Update then
		MobileOctaveScroller.Update()
	end
end

function MobileOctaveScroller.IsInputOnHead(p): boolean
	local head = MobileOctaveScroller.Head

	if not (head and head:IsA("GuiObject") and p and p.Position) then
		return false
	end

	local absolutePosition = head.AbsolutePosition
	local absoluteSize = head.AbsoluteSize
	return p.Position.X >= absolutePosition.X
		and p.Position.X <= absolutePosition.X + absoluteSize.X
		and p.Position.Y >= absolutePosition.Y
		and p.Position.Y <= absolutePosition.Y + absoluteSize.Y
end

function MobileOctaveScroller.SetScrollFromHeadDrag(p, p2)
	local mobileKeysFrame = getMobileKeysFrame() -- inferred equivalent call
	local track = MobileOctaveScroller.GetTrack()

	if not (mobileKeysFrame and mobileKeysFrame:IsA("ScrollingFrame") and track and MobileOctaveScroller.Head) then
		return
	end

	local x = track.AbsoluteSize.X
	local x2 = MobileOctaveScroller.Head.AbsoluteSize.X
	local v18 = math.max(x - x2, 0)

	if v18 <= 0 then
		MobileOctaveScroller.SetScrollPosition(0, p2)
		return
	end

	local headDragOffsetX = tonumber(MobileOctaveScroller.HeadDragOffsetX) or x2 * 0.5
	local v19 = math.clamp(p - track.AbsolutePosition.X - headDragOffsetX, 0, v18)
	MobileOctaveScroller.SetScrollPosition(v19 / v18 * MobileOctaveScroller.GetScrollLimit(mobileKeysFrame), p2)
end

function MobileOctaveScroller.SetScrollFromScreenX(p, p2)
	MobileOctaveScroller.HeadDragOffsetX = MobileOctaveScroller.Head
		and MobileOctaveScroller.Head.AbsoluteSize.X * 0.5
		or nil
	MobileOctaveScroller.SetScrollFromHeadDrag(p, p2)
end

do
	local function ScrollByOctaves(p)
		local mobileKeysFrame = getMobileKeysFrame() -- inferred equivalent call

		if mobileKeysFrame and mobileKeysFrame:IsA("ScrollingFrame") then
			local v18 = math.max(keyWidth * 7, 1)
			MobileOctaveScroller.SetScrollPosition(mobileKeysFrame.CanvasPosition.X + v18 * p, true)
		end
	end

	MobileOctaveScroller.ScrollByOctaves = ScrollByOctaves
end

function MobileOctaveScroller.Update()
	local mobileKeysFrame = getMobileKeysFrame() -- inferred equivalent call
	local track = MobileOctaveScroller.GetTrack()

	if not (mobileKeysFrame and mobileKeysFrame:IsA("ScrollingFrame") and track and MobileOctaveScroller.Head) then
		return
	end

	local scrollLimit = MobileOctaveScroller.GetScrollLimit(mobileKeysFrame)
	local v18 = math.max(track.AbsoluteSize.X - MobileOctaveScroller.Head.AbsoluteSize.X, 0)
	local v19 = scrollLimit > 0 and math.clamp(mobileKeysFrame.CanvasPosition.X / scrollLimit, 0, 1) or 0
	MobileOctaveScroller.Head.Position = UDim2.new(0, math.floor(v18 * v19 + 0.5), 0.5, 0)
end

DesktopKeysFrame = PianoContainer.KeyFrame

if MobilePianoContainer then
	local keyFrame = MobilePianoContainer:FindFirstChild("KeyFrame")
	guiObject = keyFrame and keyFrame:FindFirstChild("KeyFrame")

	if not (guiObject and guiObject:IsA("GuiObject")) then
		guiObject = nil
	end
else
	guiObject = nil
end

MobileKeysFrame = guiObject
KeysFrame = visible2 and MobileKeysFrame or DesktopKeysFrame

local function GetActiveKeysFrame() -- 5 equivalent calls inferred from this helper
	if MobilePianoContainer and MobilePianoContainer.Visible and MobileKeysFrame then
		return MobileKeysFrame
	end

	if PianoContainer and PianoContainer.Visible and DesktopKeysFrame then
		return DesktopKeysFrame
	end

	return KeysFrame
end

OptionFrame = PianoContainer.OptionFrame
Screen = PianoContainer.Screen
VelocityBar = PianoContainer.VelocityBar
BindsFrame = PianoContainer:FindFirstChild("Binds")

local topFrame = MobilePianoContainer and MobilePianoContainer:FindFirstChild("TopFrame")
local optionFrame = topFrame and topFrame:FindFirstChild("OptionFrame")
local frame = optionFrame and optionFrame:FindFirstChild("Frame")
local leftBar = optionFrame and optionFrame:FindFirstChild("LeftBar")
local rightBar = optionFrame and optionFrame:FindFirstChild("RightBar")
guiObject = frame and frame:FindFirstChild("Screen")
local transpositionFrame = frame and frame:FindFirstChild("TranspositionFrame")
local volumeTrack = guiObject and guiObject:FindFirstChild("VolumeTrack")
local fill = volumeTrack and volumeTrack:FindFirstChild("Fill")
local knob = volumeTrack and volumeTrack:FindFirstChild("Knob")
local transpositionLabel = transpositionFrame and transpositionFrame:FindFirstChild("TranspositionLabel")
MobileOctaveScroller.Frame = MobilePianoContainer and MobilePianoContainer:FindFirstChild("OctaveFrame")
MobileOctaveScroller.InsetFrame = MobileOctaveScroller.Frame and MobileOctaveScroller.Frame:FindFirstChild("InsetFrame")
MobileOctaveScroller.Track = MobileOctaveScroller.InsetFrame
	and MobileOctaveScroller.InsetFrame:FindFirstChild("BottomOctave")
MobileOctaveScroller.Head = MobileOctaveScroller.Track and MobileOctaveScroller.Track:FindFirstChild("Head")
MobileOctaveScroller.LeftArrow = MobileOctaveScroller.Head and MobileOctaveScroller.Head:FindFirstChild("LeftArrow")
MobileOctaveScroller.RightArrow = MobileOctaveScroller.Head and MobileOctaveScroller.Head:FindFirstChild("RightArrow")

local nps = PianoUI:WaitForChild("MenuOptions"):WaitForChild("NPS")
local frame2 = nps:WaitForChild("Frame")
local value = frame2 and frame2:FindFirstChild("Value")
local nps2 = PianoUI:FindFirstChild("NPS")

do
	local function HideDetachedNPSFrame() -- 1 equivalent call inferred from this helper
		if nps2 and nps2:IsA("GuiObject") then
			nps2.Visible = false
		end
	end
end

local above88KeyPacket = false
local v18 = false
local sustainPacket = true

CapsShiftLock = false
ShiftTransposeHeld = false
ShiftTransposeHeldKeys = {}

Transposition = 0
Velocity = 50

LocalVolume = Dependence_PlayerVariables.Current_Volume

if not LocalVolume or LocalVolume < 10 or LocalVolume > 200 then
	LocalVolume = 100
	Dependence_PlayerVariables.Current_Volume = 100
end

OtherPianoVolume = math.clamp(math.floor(tonumber(LocalPlayer:GetAttribute("OtherPianoVolume")) or 100), 0, 100)
MuteOtherPianos = LocalPlayer:GetAttribute("MuteOtherPianos") == true or OtherPianoVolume <= 0

PianoActionDefaultKeyBinds = {
	Sustain = { "Space" },
	ExitPiano = { "Backspace" },
	ShiftTranspose = { "LeftShift", "RightShift" },
	Above88Modifier = { "LeftControl", "RightControl" },
	VelocityModifier = { "LeftAlt", "RightAlt" },
	TransposeUp = { "Up" },
	TransposeDown = { "Down" },
	VolumeUp = { "Right" },
	VolumeDown = { "Left" },
	ManualAuto1 = { "Minus" },
	ManualAuto2 = { "Equals" },
	ManualAuto3 = { "LeftBracket" },
	ManualAuto4 = { "RightBracket" }
}

PianoActionKeyBinds = {}
PianoActionBindingsActive = false

PianoNoteActionKeyNames = {}
local v19 = {}

for _, v20 in ipairs({ Logic_Keymap.PianoKeyCodes() }) do
	PianoNoteActionKeyNames[v20.Name] = true
end

function GetPianoActionEnumItem(value2)
	if typeof(value2) ~= "string" or value2 == "" or PianoNoteActionKeyNames[value2] then
		return nil
	end

	local success, result = pcall(function()
		return Enum.KeyCode[value2]
	end)

	if success and typeof(result) == "EnumItem" and result ~= Enum.KeyCode.Unknown then
		return result
	end

	return nil
end

function ApplyPianoActionKeyBinds(items)
	PianoActionKeyBinds = {}

	if typeof(items) ~= "table" then
		return
	end

	for k, item in pairs(items) do
		if PianoActionDefaultKeyBinds[k] and GetPianoActionEnumItem(item) then
			PianoActionKeyBinds[k] = item
		end
	end
end

function GetPianoActionKeyList(...)
	local set = {}
	local pianoActionKeyList = {}

	for i = 1, select("#", ...) do
		local v20 = select(i, ...)
		local pianoActionKeyBind = PianoActionKeyBinds[v20]

		if pianoActionKeyBind then
			local v21 = GetPianoActionEnumItem(pianoActionKeyBind)

			if v21 and not set[v21] then
				set[v21] = true
				table.insert(pianoActionKeyList, v21)
			end
		else
			local pianoActionDefaultKeyBind = PianoActionDefaultKeyBinds[v20]

			if typeof(pianoActionDefaultKeyBind) == "table" then
				for _, v21 in ipairs(pianoActionDefaultKeyBind) do
					local v22 = GetPianoActionEnumItem(v21)

					if not v22 or set[v22] then
						continue
					end

					set[v22] = true
					table.insert(pianoActionKeyList, v22)
				end
			end
		end
	end

	return pianoActionKeyList
end

function GetPianoActionKeys(...)
	return table.unpack(GetPianoActionKeyList(...))
end

function ApplyPianoUserAudioSettings(data)
	if typeof(data) == "table" then
		if data.OtherPianoVolume ~= nil then
			OtherPianoVolume = math.clamp(math.floor(tonumber(data.OtherPianoVolume) or 100), 0, 100)
		end

		if data.ActionKeyBinds ~= nil then
			ApplyPianoActionKeyBinds(data.ActionKeyBinds)

			if PianoActionBindingsActive and BindPianoActionKeys then
				BindPianoActionKeys()
			end
		end

		if data.SoundEffects ~= nil then
			SetCurrentSoundEffectsState(data.SoundEffects)
		end

		if typeof(data.MuteOtherPianos) == "boolean" then
			MuteOtherPianos = data.MuteOtherPianos
		else
			MuteOtherPianos = OtherPianoVolume <= 0
		end
	else
		OtherPianoVolume = math.clamp(math.floor(tonumber(LocalPlayer:GetAttribute("OtherPianoVolume")) or 100), 0, 100)
		MuteOtherPianos = LocalPlayer:GetAttribute("MuteOtherPianos") == true or OtherPianoVolume <= 0
		SetCurrentSoundEffectsState(Dependence_SoundEffects.DecodeState(LocalPlayer:GetAttribute("PianoSoundEffects")))
	end

	LocalPlayer:SetAttribute("OtherPianoVolume", OtherPianoVolume)
	LocalPlayer:SetAttribute("MuteOtherPianos", MuteOtherPianos)
end

PianoUserSettingsLoadedRemote.OnClientEvent:Connect(ApplyPianoUserAudioSettings)
task.spawn(function()
	local success, result = pcall(function()
		return GetPianoUserSettingsRemote:InvokeServer()
	end)

	if success then
		ApplyPianoUserAudioSettings(result)
	else
		ApplyPianoUserAudioSettings()
	end
end)

function GetOtherPianoVolumeMultiplier()
	if LocalPlayer:GetAttribute("MainMenuActive") == true or (MuteOtherPianos or OtherPianoVolume <= 0) then
		return 0
	end

	return (math.clamp(OtherPianoVolume / 100, 0, 1))
end

do
	local function getScreenValueLabel(childName) -- 2 equivalent calls inferred from this helper
		local child = Screen and Screen:FindFirstChild(childName)
		return child and child:FindFirstChild("Value")
	end
end

local function updateMobileVolumeSlider()
	if not volumeTrack then
		return
	end

	local v20 = math.clamp((LocalVolume - 10) / 190, 0, 1)

	if fill then
		fill.Size = UDim2.new(v20, 0, fill.Size.Y.Scale, fill.Size.Y.Offset)
	end

	if knob then
		knob.Position = UDim2.new(v20, 0, knob.Position.Y.Scale, knob.Position.Y.Offset)
	end
end

local function SyncPerformerVolume()
	local current_Volume = math.clamp(math.floor(tonumber(LocalVolume) or 100), 10, 200)
	LocalVolume = current_Volume
	Dependence_PlayerVariables.Current_Volume = current_Volume

	if not (PianoPackets and PianoPackets.PerformerVolume) then
		return
	end

	local success, result = pcall(function()
		PianoPackets.PerformerVolume:Fire(current_Volume)
	end)

	if not success then
		v.Warn("[PianoMain] Failed to sync performer volume: " .. tostring(result))
	end
end

do
	local function UpdateVolumeDisplay() -- 7 equivalent calls inferred from this helper
		local screenValueLabel = getScreenValueLabel("Volume") -- inferred equivalent call

		if screenValueLabel then
			Logic_UI.UpdateTextLabel(screenValueLabel, LocalVolume)
		end

		updateMobileVolumeSlider()
		SyncPerformerVolume()
	end
end

function GetShiftTransposeOffset(): number
	if (ShiftTransposeHeld == true) == (CapsShiftLock == true) then
		return 0
	end

	return 1
end

function GetEffectiveTransposition()
	return Transposition + GetShiftTransposeOffset()
end

do
	local function UpdateTranspositionDisplay() -- 8 equivalent calls inferred from this helper
		local v20 = GetEffectiveTransposition()
		local screenValueLabel = getScreenValueLabel("Transposition") -- inferred equivalent call

		if screenValueLabel then
			Logic_UI.UpdateTextLabel(screenValueLabel, v20)
		end

		if transpositionLabel then
			transpositionLabel.Text = tostring(v20)
		end
	end
end

do
	local function ClearPianoModifierState() -- 1 equivalent call inferred from this helper
		above88KeyPacket = false
		v18 = false
		ShiftTransposeHeldKeys = {}
		ShiftTransposeHeld = false
		UpdateTranspositionDisplay() -- inferred equivalent call
	end

	UserInputService.WindowFocusReleased:Connect(ClearPianoModifierState)
	UserInputService.WindowFocused:Connect(ClearPianoModifierState)
end

local function SetSustainImageColor(sustain)
	if not sustain then
		return
	end

	local icon = sustain:FindFirstChild("Icon") or sustain

	if not (icon:IsA("ImageButton") or icon:IsA("ImageLabel")) then
		return
	end

	local imageColor = icon:GetAttribute("PianoDefaultImageColor")

	if not imageColor then
		imageColor = icon.ImageColor3
		icon:SetAttribute("PianoDefaultImageColor", imageColor)
	end

	imageColor = sustainPacket and Color3.fromRGB(52, 152, 245) or imageColor
	icon.ImageColor3 = imageColor
end

local function UpdateSustainDisplay()
	local sustain = OptionFrame and OptionFrame:FindFirstChild("Sustain")
	local led = sustain and sustain:FindFirstChild("LED")

	if led then
		Logic_UI.GlowCheck(led, sustainPacket)
	end

	SetSustainImageColor(sustain)
	local sustain2 = rightBar and rightBar:FindFirstChild("Sustain")

	if sustain2 then
		Logic_UI.GlowCheck(sustain2, sustainPacket)
		SetSustainImageColor(sustain2)
	end
end

local function SetCapsImageColor(caps)
	if not caps then
		return
	end

	local icon = caps:FindFirstChild("Icon") or caps

	if not (icon:IsA("ImageButton") or icon:IsA("ImageLabel")) then
		return
	end

	local imageColor = icon:GetAttribute("PianoDefaultImageColor")

	if not imageColor then
		imageColor = icon.ImageColor3
		icon:SetAttribute("PianoDefaultImageColor", imageColor)
	end

	imageColor = CapsShiftLock and Color3.fromRGB(52, 152, 245) or imageColor
	icon.ImageColor3 = imageColor
end

local function UpdateCapsDisplay()
	local caps = OptionFrame and OptionFrame:FindFirstChild("Caps")
	local led = caps and caps:FindFirstChild("LED")

	if led then
		if CapsShiftLock then
			if led:IsA("ImageLabel") or led:IsA("ImageButton") then
				led.ImageColor3 = Color3.fromRGB(255, 170, 0)
			elseif led:IsA("TextLabel") or led:IsA("TextButton") or led:IsA("Frame") then
				led.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
			end
		else
			Logic_UI.GlowCheck(led, false)
		end
	end

	SetCapsImageColor(caps)
end

local function IsPianoControlsVisible() -- 5 equivalent calls inferred from this helper
	if visible2 and MobilePianoContainer then
		return MobilePianoContainer.Visible
	end

	return PianoContainer.Visible
end

local function ApplyMobilePianoLayout()
	if not (visible2 and MobilePianoContainer) then
		return
	end

	pcall(function()
		PianoUI.ScreenInsets = Enum.ScreenInsets.None
		PianoUI.ClipToDeviceSafeArea = false
	end)

	local _, v20 = GuiService:GetGuiInset()
	local v21 = math.max(v20.Y, 0)

	local v22 = keyHeight
	local v23 = v22 + 102

	MobilePianoContainer.AnchorPoint = Vector2.new(0.5, 1)
	udim = UDim2.new(0.5, 0, 1, -v21)
	udim2 = UDim2.new(0.5, 0, 1, v23 - 38 - v21)
	MobilePianoContainer.Position = v4 and udim2 or udim
	MobilePianoContainer.Size = UDim2.new(1, 0, 0, v23)
	MobilePianoContainer.BackgroundTransparency = v4 and not v7 and 1 or 0
	MobilePianoContainer.ClipsDescendants = false

	if topFrame then
		topFrame.Position = UDim2.new(0, 0, 0, 0)
		topFrame.Size = UDim2.new(1, 0, 0, 72)
	end

	udim3 = UDim2.new(0, 8, 1, -(v21 + v22 - 34))
	v8 = udim3
	guiObject2 = button or guiObject2

	if guiObject2 and guiObject2:IsA("TextButton") then
		if mobileUtilityButtons and guiObject2.Parent ~= mobileUtilityButtons then
			guiObject2.Parent = mobileUtilityButtons
		end

		guiObject2.AnchorPoint = Vector2.new(0, 0)
		guiObject2.BackgroundColor3 = Color3.fromRGB(26, 29, 34)
		guiObject2.BackgroundTransparency = 0.05
		guiObject2.BorderSizePixel = 0
		guiObject2.TextColor3 = Color3.fromRGB(235, 238, 242)
		guiObject2.TextSize = 12
		guiObject2.Font = Enum.Font.GothamBold
		guiObject2.ZIndex = 4000
		guiObject2.Active = true
		guiObject2.LayoutOrder = 5
		guiObject2.Size = UDim2.new(0, 104, 1, 0)
		guiObject2.Text = v4 and "Show Piano" or "Hide Piano"
		guiObject2.Visible = visible2
	end

	for _, guiObject3 in ipairs(MobilePianoContainer:GetDescendants()) do
		if not ((guiObject3:IsA("ImageButton") or guiObject3:IsA("ImageLabel")) and (guiObject3.Image == "" or guiObject3.Image == "rbxassetid://" or guiObject3.Image == "rbxasset://")) then
			continue
		end

		guiObject3.ImageTransparency = 1
		guiObject3.BackgroundTransparency = 1
	end

	local keyFrame = MobilePianoContainer:FindFirstChild("KeyFrame")

	if keyFrame and keyFrame:IsA("GuiObject") then
		keyFrame.Position = UDim2.new(0, 0, 0, 102)
		keyFrame.Size = UDim2.new(1, 0, 0, v22)
		keyFrame.ClipsDescendants = true
	end

	if MobileOctaveScroller.Frame and MobileOctaveScroller.Frame:IsA("GuiObject") then
		MobileOctaveScroller.Frame.LayoutOrder = 500
		MobileOctaveScroller.Frame.Position = UDim2.new(0, 0, 0, 72)
		MobileOctaveScroller.Frame.Size = UDim2.new(1, 0, 0, 30)
		MobileOctaveScroller.Frame.Visible = not v4 or v7
	end

	if MobileOctaveScroller.Track and MobileOctaveScroller.Track:IsA("GuiObject") then
		MobileOctaveScroller.Track.Size = UDim2.new(1, 0, 0, 30)
		MobileOctaveScroller.Track.Active = false
	end

	if MobileOctaveScroller.Head and MobileOctaveScroller.Head:IsA("GuiObject") then
		MobileOctaveScroller.Head.Size = UDim2.new(0, 75, 1, 0)
		MobileOctaveScroller.Head.AnchorPoint = Vector2.new(0, 0.5)
		MobileOctaveScroller.Head.Active = true
	end

	for _, guiObject3 in ipairs({ MobileOctaveScroller.LeftArrow, MobileOctaveScroller.RightArrow }) do
		if not (guiObject3 and guiObject3:IsA("GuiObject")) then
			continue
		end

		guiObject3.Active = false
		guiObject3.Selectable = false
		pcall(function()
			guiObject3.Interactable = false
		end)
	end

	if MobileKeysFrame then
		MobileKeysFrame.Position = UDim2.fromScale(0, 0)
		MobileKeysFrame.Size = UDim2.fromScale(1, 1)
		MobileKeysFrame.Visible = not v4 or v7

		if MobileKeysFrame:IsA("ScrollingFrame") then
			MobileKeysFrame.ScrollingEnabled = scrollingEnabled
			MobileKeysFrame.ScrollingDirection = Enum.ScrollingDirection.X
			MobileKeysFrame.ScrollBarThickness = 0
		end

		applyMobileKeySize()
		MobileOctaveScroller.Update()

		for _, button2 in ipairs(MobileKeysFrame:GetChildren()) do
			if not button2:IsA("GuiButton") then
				continue
			end

			local qwertyNoteLabel = button2:FindFirstChild("QwertyNoteLabel")

			if qwertyNoteLabel and qwertyNoteLabel:IsA("TextLabel") then
				qwertyNoteLabel.Visible = false
			end

			local ctrl = button2:FindFirstChild("Ctrl")

			if ctrl and ctrl:IsA("TextLabel") then
				ctrl.Visible = false
				ctrl.Text = ""
			end

			local mobileIsBlackKey = button2:GetAttribute("MobileIsBlackKey") == true
			local noteLabel = button2:FindFirstChild("NoteLabel")

			if not (noteLabel and noteLabel:IsA("TextLabel")) then
				continue
			end

			local visible = not mobileIsBlackKey

			if visible then
				if keyWidth >= 18 then
					visible = keyHeight >= 50
				else
					visible = false
				end
			end

			noteLabel.Visible = visible
			noteLabel.AnchorPoint = Vector2.new(0.5, 1)
			noteLabel.Position = UDim2.new(0.5, 0, 1, -12)

			if noteLabel.Visible then
				noteLabel.Size = UDim2.new(1, -8, 0, (math.clamp(math.floor(keyHeight * 0.14), 28, 42)))
				noteLabel.TextSize = math.clamp(math.floor(keyWidth * 0.4), 20, 34)
			end

			noteLabel.TextScaled = false
			noteLabel.TextXAlignment = Enum.TextXAlignment.Center
			noteLabel.TextYAlignment = Enum.TextYAlignment.Center
		end
	end

	if keyFrame and keyFrame:IsA("GuiObject") and not v7 then
		keyFrame.Visible = not v4
	end

	if topFrame and topFrame:IsA("GuiObject") then
		topFrame.BackgroundTransparency = v4 and not v7 and 1 or 0
	end

	if frame and frame:IsA("GuiObject") and not v7 then
		frame.Visible = not v4
	end

	if leftBar and leftBar:IsA("GuiObject") then
		leftBar.Visible = false
	end

	if rightBar and rightBar:IsA("GuiObject") and not v7 then
		rightBar.Visible = not v4
	end

	if MobileBurgerButton and MobileBurgerButton:IsA("GuiObject") and not v7 then
		MobileBurgerButton.Visible = not v4
	end

	if v4 and not v7 then
		if MobileBurgerPanel and MobileBurgerPanel:IsA("GuiObject") then
			MobileBurgerPanel.Visible = false
		end

		if keySizePanel and keySizePanel:IsA("GuiObject") then
			keySizePanel.Visible = false
		end
	end

	if mobileUtilityButtons and mobileUtilityButtons:IsA("GuiObject") then
		mobileUtilityButtons.Visible = visible2
	end
end

Folder_Remotes:WaitForChild("MobilePianoSettingsLoaded").OnClientEvent:Connect(function(data)
	if typeof(data) ~= "table" then
		return
	end

	setMobileKeySize(data.KeyWidth or data.MobileKeyWidth, data.KeyHeight or data.MobileKeyHeight) -- inferred equivalent call
	ApplyMobilePianoLayout()
end)

task.spawn(function()
	local success, result = pcall(function()
		return Folder_Remotes:WaitForChild("GetMobilePianoSettings"):InvokeServer()
	end)

	if success and typeof(result) == "table" then
		setMobileKeySize(result.KeyWidth or result.MobileKeyWidth, result.KeyHeight or result.MobileKeyHeight) -- inferred equivalent call
		ApplyMobilePianoLayout()
	end
end)

local visibility = {}

for _, v20 in ipairs({
	DesktopKeysFrame,
	OptionFrame,
	Screen,
	VelocityBar,
	BindsFrame,
	PianoContainer:FindFirstChild("Mobiler")
}) do
	if v20 then
		visibility[v20] = v20.Visible
	end
end

local imageTransparency = PianoContainer:IsA("ImageLabel") and PianoContainer.ImageTransparency or nil
local BackgroundTransparency = PianoContainer.BackgroundTransparency

do
	local function setDesktopShellHiddenForMobile(p) -- 4 equivalent calls inferred from this helper
		for k, v20 in pairs(visibility) do
			if k and k.Parent then
				k.Visible = not p and v20
			end
		end

		if p then
			PianoContainer.BackgroundTransparency = 1

			if PianoContainer:IsA("ImageLabel") then
				PianoContainer.ImageTransparency = 1
			end
		else
			PianoContainer.BackgroundTransparency = BackgroundTransparency

			if imageTransparency and PianoContainer:IsA("ImageLabel") then
				PianoContainer.ImageTransparency = imageTransparency
			end
		end
	end
end

do
	local function createMobileUtilityButton(mobileUtilityButtons2, name, text, layoutOrder)
		if not mobileUtilityButtons2 then
			return nil
		end

		local button2 = mobileUtilityButtons2:FindFirstChild(name)

		if button2 and button2:IsA("GuiButton") then
			return button2
		end

		local textButton = Instance.new("TextButton")
		textButton.Name = name
		textButton.LayoutOrder = layoutOrder
		textButton.Size = UDim2.new(0, 62, 1, 0)
		textButton.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
		textButton.BorderSizePixel = 0
		textButton.AutoButtonColor = true
		textButton.Text = text
		textButton.TextColor3 = Color3.fromRGB(235, 238, 242)
		textButton.TextSize = 12
		textButton.Font = Enum.Font.GothamBold
		textButton.Parent = mobileUtilityButtons2
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 8)
		uiCorner.Parent = textButton
		return textButton
	end

	mobileUtilityButtons = nil
	MobileAutoplayerButton = nil
	MobileManualAutoButton = nil
	MobileMidiButton = nil
	MobilePracticeButton = nil
	MobileOpenRecordButton = nil
	MobileScrollButton = nil
	MobileMode2DButton = nil
	button = nil
	MobileBurgerButton = optionFrame and optionFrame:FindFirstChild("BurgerMenu")
	MobileBurgerPanel = optionFrame and optionFrame:FindFirstChild("BurgerPanel")
	guiObject2 = PianoUI:FindFirstChild("SlideToggle")
		or MobilePianoContainer and MobilePianoContainer:FindFirstChild("SlideToggle")

	if optionFrame then
		mobileUtilityButtons = optionFrame:FindFirstChild("MobileUtilityButtons")

		if not mobileUtilityButtons then
			mobileUtilityButtons = Instance.new("Frame")
			mobileUtilityButtons.Name = "MobileUtilityButtons"
			mobileUtilityButtons.AnchorPoint = Vector2.new(0.5, 1)
			mobileUtilityButtons.Position = UDim2.new(0.5, 0, 0, -4)
			mobileUtilityButtons.Size = UDim2.new(0, 554, 0, 36)
			mobileUtilityButtons.BackgroundTransparency = 1
			mobileUtilityButtons.ZIndex = 1001
			mobileUtilityButtons.Parent = optionFrame
			local uiListLayout = Instance.new("UIListLayout")
			uiListLayout.FillDirection = Enum.FillDirection.Horizontal
			uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uiListLayout.Padding = UDim.new(0, 4)
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Parent = mobileUtilityButtons
		end

		mobileUtilityButtons.Visible = false
		mobileUtilityButtons.Size = UDim2.new(0, 554, 0, 36)
		local manualAuto = mobileUtilityButtons:FindFirstChild("ManualAuto")

		if manualAuto then
			manualAuto:Destroy()
		end

		MobileOpenRecordButton = createMobileUtilityButton(mobileUtilityButtons, "OpenRecordText", "OPEN", 1)
		MobileAutoplayerButton = createMobileUtilityButton(mobileUtilityButtons, "Autoplayer", "AUTO", 2)
		MobileMidiButton = createMobileUtilityButton(mobileUtilityButtons, "MidiPlayer", "MIDI", 3)
		MobilePracticeButton = createMobileUtilityButton(mobileUtilityButtons, "CommunitySheets", "SHEETS", 4)
		MobileMode2DButton = createMobileUtilityButton(mobileUtilityButtons, "Mode2D", "2D", 5)
		MobileScrollButton = createMobileUtilityButton(mobileUtilityButtons, "ScrollLock", "SCROLL", 6)
		button = createMobileUtilityButton(mobileUtilityButtons, "HidePiano", "Hide Piano", 7)

		if MobileMode2DButton and MobileMode2DButton:IsA("TextButton") then
			MobileMode2DButton.LayoutOrder = 5
			MobileMode2DButton.Size = UDim2.new(0, 62, 1, 0)
			MobileMode2DButton.Text = "2D"
		end

		if MobileScrollButton and MobileScrollButton:IsA("TextButton") then
			MobileScrollButton.LayoutOrder = 6
			MobileScrollButton.Size = UDim2.new(0, 62, 1, 0)
			MobileScrollButton.Text = "SCROLL"
		end

		if button and button:IsA("TextButton") then
			button.LayoutOrder = 7
			button.Size = UDim2.new(0, 104, 1, 0)
			button.Text = "Hide Piano"
			button.TextSize = 12
			guiObject2 = button
		end

		manualAuto = optionFrame:FindFirstChild("ManualAuto")

		if manualAuto and not manualAuto:IsA("TextButton") then
			manualAuto:Destroy()
			manualAuto = nil
		end

		if not manualAuto then
			manualAuto = Instance.new("TextButton")
			manualAuto.Name = "ManualAuto"
			manualAuto.Parent = optionFrame
		end

		MobileManualAutoButton = manualAuto
		MobileManualAutoButton.AnchorPoint = Vector2.new(0, 0.5)
		MobileManualAutoButton.Position = UDim2.new(0, 66, 0.5, 0)
		MobileManualAutoButton.Size = UDim2.new(0, 82, 0, 44)
		MobileManualAutoButton.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
		MobileManualAutoButton.BorderSizePixel = 0
		MobileManualAutoButton.AutoButtonColor = true
		MobileManualAutoButton.Text = "AUTOPLAY"
		MobileManualAutoButton.TextColor3 = Color3.fromRGB(235, 238, 242)
		MobileManualAutoButton.TextSize = 12
		MobileManualAutoButton.Font = Enum.Font.GothamBold
		MobileManualAutoButton.ZIndex = 2100
		manualAuto = MobileManualAutoButton:FindFirstChildOfClass("UICorner")

		if not manualAuto then
			manualAuto = Instance.new("UICorner")
			manualAuto.Parent = MobileManualAutoButton
		end

		manualAuto.CornerRadius = UDim.new(0, 8)
	end
end

do
	local function ensureMobileCorner(parent, p) -- 6 equivalent calls inferred from this helper
		local v20 = parent:FindFirstChildOfClass("UICorner")

		if not v20 then
			v20 = Instance.new("UICorner")
			v20.Parent = parent
		end

		v20.CornerRadius = UDim.new(0, p)
	end
end

do
	local function styleMobileBurgerTextButton(parent, backgroundColor) -- 5 equivalent calls inferred from this helper
		parent.BackgroundColor3 = backgroundColor
		parent.BorderSizePixel = 0
		parent.AutoButtonColor = true
		parent.TextColor3 = Color3.fromRGB(235, 238, 242)
		parent.TextSize = 13
		parent.TextScaled = false
		parent.Font = Enum.Font.GothamBold
		parent.ZIndex = math.max(parent.ZIndex, 2201)
		ensureMobileCorner(parent, 8) -- inferred equivalent call
	end
end

local function createMobileKeySizeSliderRow(keySizePanel2, name, text, layoutOrder)
	local parent = keySizePanel2:FindFirstChild(name)

	if parent and not parent:IsA("Frame") then
		parent:Destroy()
		parent = nil
	end

	if not parent then
		parent = Instance.new("Frame")
		parent.Name = name
		parent.Parent = keySizePanel2
	end

	for _, childName in ipairs({ "Minus", "Plus" }) do
		local child = parent:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	parent.LayoutOrder = layoutOrder
	parent.Size = UDim2.new(1, 0, 0, 70)
	parent.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
	parent.BorderSizePixel = 0
	parent.ZIndex = 2201
	ensureMobileCorner(parent, 8) -- inferred equivalent call
	local label = parent:FindFirstChild("Label")

	if not label then
		label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Parent = parent
	end

	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Position = UDim2.new(0, 12, 0, 8)
	label.Size = UDim2.new(0.6, -12, 0, 18)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(235, 238, 242)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 2202

	local value2 = parent:FindFirstChild("Value")

	if not value2 then
		value2 = Instance.new("TextLabel")
		value2.Name = "Value"
		value2.Parent = parent
	end

	value2.BackgroundTransparency = 1
	value2.BorderSizePixel = 0
	value2.Position = UDim2.new(0.6, 0, 0, 8)
	value2.Size = UDim2.new(0.4, -12, 0, 18)
	value2.Font = Enum.Font.GothamMedium
	value2.TextColor3 = Color3.fromRGB(150, 160, 175)
	value2.TextSize = 12
	value2.TextXAlignment = Enum.TextXAlignment.Right
	value2.ZIndex = 2202

	local sliderTrack = parent:FindFirstChild("SliderTrack")

	if not sliderTrack then
		sliderTrack = Instance.new("TextButton")
		sliderTrack.Name = "SliderTrack"
		sliderTrack.Parent = parent
	end

	sliderTrack.Active = true
	sliderTrack.AutoButtonColor = false
	sliderTrack.BackgroundColor3 = Color3.fromRGB(24, 27, 31)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Position = UDim2.new(0, 14, 0, 44)
	sliderTrack.Size = UDim2.new(1, -28, 0, 8)
	sliderTrack.Text = ""
	sliderTrack.ZIndex = 2202
	ensureMobileCorner(sliderTrack, 4) -- inferred equivalent call
	local fill2 = sliderTrack:FindFirstChild("Fill")

	if not fill2 then
		fill2 = Instance.new("Frame")
		fill2.Name = "Fill"
		fill2.Parent = sliderTrack
	end

	fill2.BackgroundColor3 = Color3.fromRGB(52, 119, 228)
	fill2.BorderSizePixel = 0
	fill2.Position = UDim2.fromScale(0, 0)
	fill2.Size = UDim2.fromScale(0, 1)
	fill2.ZIndex = 2203
	ensureMobileCorner(fill2, 4) -- inferred equivalent call
	local knob2 = sliderTrack:FindFirstChild("Knob")

	if not knob2 then
		knob2 = Instance.new("TextButton")
		knob2.Name = "Knob"
		knob2.Parent = sliderTrack
	end

	knob2.Active = true
	knob2.AutoButtonColor = true
	knob2.AnchorPoint = Vector2.new(0.5, 0.5)
	knob2.BackgroundColor3 = Color3.fromRGB(235, 238, 242)
	knob2.BorderSizePixel = 0
	knob2.Position = UDim2.new(0, 0, 0.5, 0)
	knob2.Size = UDim2.new(0, 22, 0, 22)
	knob2.Text = ""
	knob2.ZIndex = 2204
	ensureMobileCorner(knob2, 11) -- inferred equivalent call
	return value2, sliderTrack, fill2, knob2
end

do
	local function getMobileKeySliderAlpha(p, p2, p3)
		local v20 = math.max(p3 - p2, 1)
		return (math.clamp((p - p2) / v20, 0, 1))
	end
end

do
	local function setMobileKeySliderVisual(_, p, p2, p3) -- 2 equivalent calls inferred from this helper
		if p then
			p.Size = UDim2.new(p3, 0, 1, 0)
		end

		if p2 then
			p2.Position = UDim2.new(p3, 0, 0.5, 0)
		end
	end
end

fn = function()
	setMobileKeySliderVisual(nil, v12, v13, math.clamp((keyWidth - 0) / 128, 0, 1)) -- inferred equivalent call
	setMobileKeySliderVisual(nil, v15, v16, math.clamp((keyHeight - 0) / 320, 0, 1)) -- inferred equivalent call
end

do
	local function getPanelOffsetFromRoot(p) -- 2 equivalent calls inferred from this helper
		if not p then
			return 0, 0
		end

		local absolutePosition = PianoUI.AbsolutePosition
		local absolutePosition2 = p.AbsolutePosition
		return absolutePosition2.X - absolutePosition.X, absolutePosition2.Y - absolutePosition.Y
	end
end

local function clampPanelPosition(value2, value3, p)
	local absoluteSize = PianoUI.AbsoluteSize
	local v20 = math.max(p.AbsoluteSize.X, p.Size.X.Offset)
	local v21 = math.max(p.AbsoluteSize.Y, p.Size.Y.Offset)
	return
		math.clamp(value2, 8, (math.max(8, absoluteSize.X - v20 - 8))),
		(math.clamp(value3, 8, (math.max(8, absoluteSize.Y - v21 - 8))))
end

local function fn2()
	if not (MobileBurgerPanel and MobileBurgerButton) then
		return
	end

	if MobileBurgerPanel:GetAttribute("MobilePanelUserMoved") == true then
		local v20, v21 = clampPanelPosition(
			MobileBurgerPanel.Position.X.Offset,
			MobileBurgerPanel.Position.Y.Offset,
			MobileBurgerPanel
		)
		MobileBurgerPanel.Position = UDim2.fromOffset(v20, v21)
	else
		local panelOffsetFromRoot, v20 = getPanelOffsetFromRoot(MobileBurgerButton) -- inferred equivalent call
		local v21, v22 = clampPanelPosition(
			panelOffsetFromRoot,
			v20 + MobileBurgerButton.AbsoluteSize.Y + 8,
			MobileBurgerPanel
		)
		MobileBurgerPanel.Position = UDim2.fromOffset(v21, v22)
	end
end

local function fn3()
	if not keySizePanel then
		return
	end

	if keySizePanel:GetAttribute("MobilePanelUserMoved") == true then
		local v20, v21 = clampPanelPosition(
			keySizePanel.Position.X.Offset,
			keySizePanel.Position.Y.Offset,
			keySizePanel
		)
		keySizePanel.Position = UDim2.fromOffset(v20, v21)
	else
		if MobileBurgerPanel and MobileBurgerPanel:GetAttribute("MobilePanelUserMoved") ~= true then
			fn2()
		end

		local absoluteSize = PianoUI.AbsoluteSize
		local panelOffsetFromRoot, v20 = getPanelOffsetFromRoot(MobileBurgerPanel) -- inferred equivalent call
		local v21 = MobileBurgerPanel and math.max(MobileBurgerPanel.AbsoluteSize.X, MobileBurgerPanel.Size.X.Offset)
			or 190
		local v22 = MobileBurgerPanel and math.max(MobileBurgerPanel.AbsoluteSize.Y, MobileBurgerPanel.Size.Y.Offset)
			or 204
		local v23 = math.max(keySizePanel.AbsoluteSize.X, keySizePanel.Size.X.Offset)
		local v24 = panelOffsetFromRoot + v21 + 8

		if v24 + v23 + 8 > absoluteSize.X then
			v20 = v20 + v22 + 8
			v24 = panelOffsetFromRoot
		end

		local v25, v26 = clampPanelPosition(v24, v20, keySizePanel)
		keySizePanel.Position = UDim2.fromOffset(v25, v26)
	end
end

do
	local function setupMobileBurgerKeySizeControls()
		if not (MobileBurgerPanel and MobileBurgerPanel:IsA("GuiObject")) then
			return
		end

		local function setLocalZTree(guiObject3, p)
			if guiObject3:IsA("GuiObject") then
				guiObject3.ZIndex = math.max(guiObject3.ZIndex, p)
			end

			for _, guiObject4 in ipairs(guiObject3:GetDescendants()) do
				if guiObject4:IsA("GuiObject") then
					guiObject4.ZIndex = math.max(guiObject4.ZIndex, p + 1)
				end
			end
		end

		for _, childName in ipairs({ "KeyWidthRow", "KeyHeightRow", "ResetKeySize" }) do
			local child = MobileBurgerPanel:FindFirstChild(childName)

			if child then
				child:Destroy()
			end
		end

		if MobileBurgerPanel.Parent ~= PianoUI then
			MobileBurgerPanel.Parent = PianoUI
		end

		MobileBurgerPanel.AnchorPoint = Vector2.new(0, 0)
		MobileBurgerPanel.Size = UDim2.new(0, 190, 0, 204)
		MobileBurgerPanel.BackgroundColor3 = Color3.fromRGB(28, 31, 36)
		MobileBurgerPanel.BorderSizePixel = 0
		MobileBurgerPanel.Active = true
		MobileBurgerPanel.ZIndex = math.max(MobileBurgerPanel.ZIndex, 2200)

		local uiListLayout = MobileBurgerPanel:FindFirstChildOfClass("UIListLayout")

		if uiListLayout then
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Padding = UDim.new(0, 8)
		end

		local uiPadding = MobileBurgerPanel:FindFirstChildOfClass("UIPadding")

		if uiPadding then
			uiPadding.PaddingTop = UDim.new(0, 10)
			uiPadding.PaddingBottom = UDim.new(0, 10)
			uiPadding.PaddingLeft = UDim.new(0, 10)
			uiPadding.PaddingRight = UDim.new(0, 10)
		end

		local recordRow = MobileBurgerPanel:FindFirstChild("RecordRow")

		if recordRow and recordRow:IsA("TextButton") then
			recordRow.LayoutOrder = 1
			recordRow.Size = UDim2.new(1, 0, 0, 40)
			styleMobileBurgerTextButton(recordRow, Color3.fromRGB(38, 41, 46)) -- inferred equivalent call
		end

		local playRow = MobileBurgerPanel:FindFirstChild("PlayRow")

		if playRow and playRow:IsA("TextButton") then
			playRow.LayoutOrder = 2
			playRow.Size = UDim2.new(1, 0, 0, 40)
			styleMobileBurgerTextButton(playRow, Color3.fromRGB(38, 41, 46)) -- inferred equivalent call
		end

		keySizeButton = MobileBurgerPanel:FindFirstChild("KeySizeButton")

		if not keySizeButton then
			keySizeButton = Instance.new("TextButton")
			keySizeButton.Name = "KeySizeButton"
			keySizeButton.Parent = MobileBurgerPanel
		end

		keySizeButton.LayoutOrder = 3
		keySizeButton.Size = UDim2.new(1, 0, 0, 40)
		keySizeButton.Text = "KEY SIZE"
		styleMobileBurgerTextButton(keySizeButton, Color3.fromRGB(46, 55, 68)) -- inferred equivalent call

		local exitButton = MobileBurgerPanel:FindFirstChild("ExitButton")

		if exitButton and exitButton:IsA("TextButton") then
			exitButton.LayoutOrder = 4
			exitButton.Size = UDim2.new(1, 0, 0, 40)
			styleMobileBurgerTextButton(exitButton, Color3.fromRGB(220, 54, 54)) -- inferred equivalent call
		end

		keySizePanel = PianoUI:FindFirstChild("KeySizePanel")
			or optionFrame and optionFrame:FindFirstChild("KeySizePanel")

		if not keySizePanel then
			keySizePanel = Instance.new("Frame")
			keySizePanel.Name = "KeySizePanel"
		end

		keySizePanel.Parent = PianoUI

		if keySizePanel then
			keySizePanel.AnchorPoint = Vector2.new(0, 0)
			keySizePanel.Size = UDim2.new(0, 260, 0, 210)
			keySizePanel.BackgroundColor3 = Color3.fromRGB(28, 31, 36)
			keySizePanel.BorderSizePixel = 0
			keySizePanel.Active = true
			keySizePanel.Visible = false
			keySizePanel.ClipsDescendants = false
			ensureMobileCorner(keySizePanel, 10) -- inferred equivalent call
			setLocalZTree(keySizePanel, 2300)

			local v20 = keySizePanel:FindFirstChildOfClass("UIStroke")

			if not v20 then
				v20 = Instance.new("UIStroke")
				v20.Parent = keySizePanel
			end

			v20.Color = Color3.fromRGB(58, 64, 74)
			v20.Thickness = 1
			v20.Transparency = 0.1

			local v21 = keySizePanel:FindFirstChildOfClass("UIListLayout")

			if not v21 then
				v21 = Instance.new("UIListLayout")
				v21.Parent = keySizePanel
			end

			v21.SortOrder = Enum.SortOrder.LayoutOrder
			v21.Padding = UDim.new(0, 8)

			local v22 = keySizePanel:FindFirstChildOfClass("UIPadding")

			if not v22 then
				v22 = Instance.new("UIPadding")
				v22.Parent = keySizePanel
			end

			v22.PaddingTop = UDim.new(0, 10)
			v22.PaddingBottom = UDim.new(0, 10)
			v22.PaddingLeft = UDim.new(0, 10)
			v22.PaddingRight = UDim.new(0, 10)

			v9, v11, v12, v13 = createMobileKeySizeSliderRow(keySizePanel, "KeyWidthRow", "KEY WIDTH", 1)
			v10, v14, v15, v16 = createMobileKeySizeSliderRow(keySizePanel, "KeyHeightRow", "KEY HEIGHT", 2)

			resetKeySize = keySizePanel:FindFirstChild("ResetKeySize")

			if not resetKeySize then
				resetKeySize = Instance.new("TextButton")
				resetKeySize.Name = "ResetKeySize"
				resetKeySize.Parent = keySizePanel
			end

			resetKeySize.LayoutOrder = 3
			resetKeySize.Size = UDim2.new(1, 0, 0, 34)
			resetKeySize.Text = "RESET KEY SIZE"
			styleMobileBurgerTextButton(resetKeySize, Color3.fromRGB(46, 55, 68)) -- inferred equivalent call
			setLocalZTree(keySizePanel, 2300)
			fn3()
		end

		updateMobileKeySizeLabels() -- inferred equivalent call
	end

	setupMobileBurgerKeySizeControls()
end

local v20 = {
	Soundfonts = "ImageLabel",
	SoundEffects = "ImageLabel",
	AutoPlayer = "Frame",
	Modal = "Frame",
	MidiModal = "Frame",
	Sheets = "Frame"
}

local function findDirectPanel(instance, p)
	if not instance then
		return nil
	end

	local v21 = v20[p]

	for _, guiObject3 in ipairs(instance:GetChildren()) do
		if
			guiObject3.Name == p
			and guiObject3:IsA("GuiObject")
			and not guiObject3:IsA("GuiButton")
			and (not v21 or guiObject3:IsA(v21))
		then
			return guiObject3
		end
	end

	return nil
end

local function findSharedFeatureFrame(p) -- 12 equivalent calls inferred from this helper
	local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

	if p == "Sheets" then
		return findDirectPanel(PianoUI, "Sheets") or findDirectPanel(mobilePanelHost, "Sheets")
	elseif p == "MidiModal" then
		return findDirectPanel(PianoUI, "MidiModal")
			or findDirectPanel(PianoContainer, "MidiModal")
			or findDirectPanel(mobilePanelHost, "MidiModal")
	end

	return findDirectPanel(PianoContainer, p) or findDirectPanel(PianoUI, p) or findDirectPanel(mobilePanelHost, p)
end

local function setPanelZTree(guiObject3, p)
	if not guiObject3 then
		return
	end

	if guiObject3:IsA("GuiObject") then
		guiObject3.ZIndex = math.max(guiObject3.ZIndex, p)
	end

	for _, guiObject4 in ipairs(guiObject3:GetDescendants()) do
		if guiObject4:IsA("GuiObject") then
			guiObject4.ZIndex = math.max(guiObject4.ZIndex, p + 1)
		end
	end
end

do
	local function makeInputBlockingPanel(guiObject3) -- 2 equivalent calls inferred from this helper
		if guiObject3 and guiObject3:IsA("GuiObject") then
			guiObject3.Active = true
		end
	end

	for _, v21 in ipairs({
		"Soundfonts",
		"SoundEffects",
		"AutoPlayer",
		"Modal",
		"MidiModal",
		"Sheets"
	}) do
		makeInputBlockingPanel(findSharedFeatureFrame(v21)) -- inferred equivalent call
	end
end

local function getMobilePanelHost()
	local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

	if not mobilePanelHost then
		mobilePanelHost = Instance.new("Frame")
		mobilePanelHost.Name = "MobilePanelHost"
		mobilePanelHost.Parent = PianoUI
	end

	mobilePanelHost.BackgroundTransparency = 1
	mobilePanelHost.BorderSizePixel = 0
	mobilePanelHost.ClipsDescendants = true
	mobilePanelHost.AnchorPoint = Vector2.new(0.5, 0)
	mobilePanelHost.Active = false
	mobilePanelHost.ZIndex = 1150
	return mobilePanelHost
end

do
	local function getMobileTopMargin() -- 1 equivalent call inferred from this helper
		local v21 = 0
		pcall(function()
			v21 = GuiService:GetGuiInset().Y
		end)
		return (math.max(v21 + 8, 62))
	end
end

local function ApplyMobileFeatureLayouts()
	local mobilePanelHost = getMobilePanelHost()

	if not visible2 then
		mobilePanelHost.Visible = false
		return
	end

	local v21, v22

	if workspace.CurrentCamera then
		v21 = workspace.CurrentCamera.ViewportSize.X
		v22 = workspace.CurrentCamera.ViewportSize.Y
	else
		v22 = 720
		v21 = 1280
	end

	local mobileTopMargin = getMobileTopMargin() -- inferred equivalent call
	local v23 = math.max(260, v22 - mobileTopMargin - 18)
	local v24 = math.max(240, v21 - (v21 <= 360 and 12 or 32))
	local v25 = math.max(v21 <= 340 and math.min(280, v24) or math.min(320, v24), (math.min(v24, 920)))
	local v26 = math.max(300, (math.min(v23 - 20, (math.floor(v22 * 0.68)))))

	mobilePanelHost.Visible = true
	mobilePanelHost.ClipsDescendants = false
	mobilePanelHost.AnchorPoint = Vector2.new(0.5, 0)
	mobilePanelHost.Position = UDim2.new(0.5, 0, 0, mobileTopMargin)
	mobilePanelHost.Size = UDim2.new(1, 0, 1, -mobileTopMargin)
	setPanelZTree(mobilePanelHost, 1800)

	for _, guiObject3 in ipairs(mobilePanelHost:GetChildren()) do
		if not (guiObject3:IsA("GuiButton") or (guiObject3.Name == "Sheets" or guiObject3.Name == "Soundfonts" or guiObject3.Name == "SoundEffects") and not guiObject3:IsA(v20[guiObject3.Name] or "GuiObject")) then
			continue
		end

		if not guiObject3:IsA("GuiObject") then
			continue
		end

		guiObject3.Visible = false
		guiObject3.Size = UDim2.fromOffset(0, 0)
	end

	local function placePanel(guiObject3)
		if not (guiObject3 and guiObject3:IsA("GuiObject")) then
			return
		end

		if guiObject3.Parent ~= mobilePanelHost then
			guiObject3.Parent = mobilePanelHost
		end

		guiObject3.AnchorPoint = Vector2.new(0.5, 0.5)
		guiObject3.Position = UDim2.new(0.5, 0, 0.52, 0)
		guiObject3.Size = UDim2.new(0, v25, 0, v26)
		guiObject3.ClipsDescendants = false
		makeInputBlockingPanel(guiObject3) -- inferred equivalent call
		setPanelZTree(guiObject3, 2400)
	end

	local mobilePanelHost2 = PianoUI:FindFirstChild("MobilePanelHost")

	placePanel(findDirectPanel(PianoContainer, "Soundfonts") or findDirectPanel(PianoUI, "Soundfonts") or findDirectPanel(mobilePanelHost2, "Soundfonts"))
	local mobilePanelHost3 = PianoUI:FindFirstChild("MobilePanelHost")

	placePanel(findDirectPanel(PianoContainer, "SoundEffects") or findDirectPanel(PianoUI, "SoundEffects") or findDirectPanel(mobilePanelHost3, "SoundEffects"))
	local mobilePanelHost4 = PianoUI:FindFirstChild("MobilePanelHost")

	placePanel(findDirectPanel(PianoContainer, "AutoPlayer") or findDirectPanel(PianoUI, "AutoPlayer") or findDirectPanel(mobilePanelHost4, "AutoPlayer"))
	local mobilePanelHost5 = PianoUI:FindFirstChild("MobilePanelHost")

	placePanel(findDirectPanel(PianoUI, "Sheets") or findDirectPanel(mobilePanelHost5, "Sheets"))
	local mobilePanelHost6 = PianoUI:FindFirstChild("MobilePanelHost")

	placePanel(findDirectPanel(PianoContainer, "Modal") or findDirectPanel(PianoUI, "Modal") or findDirectPanel(mobilePanelHost6, "Modal"))
end

local function hideSharedFeatureFrames()
	for _, v21 in ipairs({ "Soundfonts", "SoundEffects", "AutoPlayer", "Modal", "MidiModal" }) do
		local sharedFeatureFrame = findSharedFeatureFrame(v21)

		if sharedFeatureFrame and sharedFeatureFrame:IsA("GuiObject") then
			sharedFeatureFrame.Visible = false
		end
	end

	local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

	local guiObject3 = findDirectPanel(PianoUI, "Sheets") or findDirectPanel(mobilePanelHost, "Sheets")

	if guiObject3 and guiObject3:IsA("GuiObject") then
		guiObject3.Visible = false
	end

	local mobilePanelHost2 = PianoUI:FindFirstChild("MobilePanelHost")

	if mobilePanelHost2 and mobilePanelHost2:IsA("GuiObject") then
		mobilePanelHost2.Visible = false
	end

	if MobileBurgerPanel and MobileBurgerPanel:IsA("GuiObject") then
		MobileBurgerPanel.Visible = false
	end

	if keySizePanel and keySizePanel:IsA("GuiObject") then
		keySizePanel.Visible = false
	end
end

function IsVisiblePointInsideGui(guiObject3, p): boolean
	if not (guiObject3 and guiObject3:IsA("GuiObject") and guiObject3.Visible and p and p.Position) then
		return false
	end

	local absolutePosition = guiObject3.AbsolutePosition
	local absoluteSize = guiObject3.AbsoluteSize
	local position = p.Position
	return position.X >= absolutePosition.X
		and position.X <= absolutePosition.X + absoluteSize.X
		and position.Y >= absolutePosition.Y
		and position.Y <= absolutePosition.Y + absoluteSize.Y
end

function IsMobilePianoInputBlocked(p): boolean
	if not visible2 then
		return false
	end

	if not p then
		for _, guiObject3 in ipairs({ MobileBurgerPanel, keySizePanel }) do
			if guiObject3 and guiObject3:IsA("GuiObject") and guiObject3.Visible then
				return true
			end
		end
	end

	if IsVisiblePointInsideGui(MobileBurgerPanel, p) or IsVisiblePointInsideGui(keySizePanel, p) then
		return true
	end

	for _, v21 in ipairs({
		"Soundfonts",
		"SoundEffects",
		"AutoPlayer",
		"Modal",
		"MidiModal",
		"Sheets"
	}) do
		local sharedFeatureFrame = findSharedFeatureFrame(v21)

		if
			sharedFeatureFrame
			and sharedFeatureFrame:IsA("GuiObject")
			and sharedFeatureFrame.Visible
			and (not p or IsVisiblePointInsideGui(sharedFeatureFrame, p))
		then
			return true
		end
	end

	return false
end

MobilePanelDragState = nil
function CanStartMobilePanelDrag(guiObject3, p): boolean
	if
		not (guiObject3 and guiObject3:IsA("GuiObject") and p)
		or p.UserInputType ~= Enum.UserInputType.Touch and p.UserInputType ~= Enum.UserInputType.MouseButton1
	then
		return false
	end

	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not (playerGui and p.Position) then
		return true
	end

	local guiObjectsAtPosition = playerGui:GetGuiObjectsAtPosition(p.Position.X, p.Position.Y)

	for _, instance in ipairs(guiObjectsAtPosition) do
		if instance == guiObject3 then
			return true
		end

		if instance:IsDescendantOf(guiObject3) then
			return not (instance:IsA("TextButton") or instance:IsA("ImageButton") or instance:IsA("TextBox"))
		end
	end

	return true
end

function MakeMobilePanelDraggable(guiObject3)
	if not guiObject3 or not guiObject3:IsA("GuiObject") or guiObject3:GetAttribute("MobilePanelDragBound") then
		return
	end

	guiObject3:SetAttribute("MobilePanelDragBound", true)
	guiObject3.Active = true
	guiObject3.InputBegan:Connect(function(input)
		if not CanStartMobilePanelDrag(guiObject3, input) then
			return
		end

		MobilePanelDragState = {
			Panel = guiObject3,
			StartInputPosition = input.Position,
			StartPanelPosition = guiObject3.Position
		}

		setPanelZTree(guiObject3, 2450)
	end)
end

UserInputService.InputChanged:Connect(function(input)
	if
		not MobilePanelDragState
		or input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMovement
	then
		return
	end

	local mobilePanelDragState = MobilePanelDragState
	local panel = mobilePanelDragState.Panel

	if not (panel and panel.Parent) then
		MobilePanelDragState = nil
		return
	end

	local v21 = input.Position - mobilePanelDragState.StartInputPosition
	local v22, v23 = clampPanelPosition(
		mobilePanelDragState.StartPanelPosition.X.Offset + v21.X,
		mobilePanelDragState.StartPanelPosition.Y.Offset + v21.Y,
		panel
	)
	panel.Position = UDim2.fromOffset(v22, v23)
end)

UserInputService.InputEnded:Connect(function(input)
	if not MobilePanelDragState then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		if MobilePanelDragState.Panel and MobilePanelDragState.Panel.Parent then
			MobilePanelDragState.Panel:SetAttribute("MobilePanelUserMoved", true)
		end

		MobilePanelDragState = nil
	end
end)

MakeMobilePanelDraggable(MobileBurgerPanel)
MakeMobilePanelDraggable(keySizePanel)

function GetDesktopPianoCollapsedPosition()
	local v21 = PianoContainer.AbsoluteSize.Y

	if v21 <= 0 then
		v21 = PianoContainer.Size.Y.Offset
	end

	return UDim2.new(PianoContainerVisiblePosition.X.Scale, PianoContainerVisiblePosition.X.Offset, 1, v21 + 2)
end

function SetDesktopPianoTopButtonsVisible(visible)
	local optionFrame2 = PianoContainer:FindFirstChild("OptionFrame")

	if not optionFrame2 then
		return
	end

	for _, childName in ipairs({ "Record", "PlayRecord", "MidiPlayer" }) do
		local guiObject3 = optionFrame2:FindFirstChild(childName)

		if guiObject3 and guiObject3:IsA("GuiObject") then
			guiObject3.Visible = visible
		end
	end
end

function UpdateDesktopPianoCollapseKnob()
	if not (PianoCollapseKnob and PianoCollapseKnob:IsA("GuiButton")) then
		return
	end

	local pianoVisibilityTargetVisible = not visible2 and PianoContainer.Visible and PianoVisibilityTargetVisible
	PianoCollapseKnob.Visible = pianoVisibilityTargetVisible
	PianoCollapseKnob.Active = pianoVisibilityTargetVisible
	PianoCollapseKnob.AutoButtonColor = pianoVisibilityTargetVisible
	PianoCollapseKnob.Text = ""
	PianoCollapseKnob.TextTransparency = 1
	local chevron = PianoCollapseKnob:FindFirstChild("Chevron")

	if chevron and chevron:IsA("TextLabel") then
		chevron.Text = DesktopPianoCollapsed and "^" or "v"
	end
end

function SetDesktopPianoCollapsed(p)
	if visible2 or not PianoContainer.Visible then
		return
	end

	if DesktopPianoCollapseTween then
		DesktopPianoCollapseTween:Cancel()
		DesktopPianoCollapseTween = nil
	end

	if PianoVisibilityTween then
		PianoVisibilityTween:Cancel()
		PianoVisibilityTween = nil
	end

	DesktopPianoCollapsed = p

	if p then
		hideSharedFeatureFrames()
	end

	SetDesktopPianoTopButtonsVisible(not p)
	UpdateDesktopPianoCollapseKnob()

	local position = p and GetDesktopPianoCollapsedPosition() or PianoContainerVisiblePosition
	local v21 = TweenService:Create(
		PianoContainer,
		TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = position }
	)

	DesktopPianoCollapseTween = v21
	v21.Completed:Connect(function()
		if DesktopPianoCollapseTween == v21 then
			DesktopPianoCollapseTween = nil
		end

		SetDesktopPianoTopButtonsVisible(not DesktopPianoCollapsed)
		UpdateDesktopPianoCollapseKnob()
	end)
	v21:Play()
end

function ToggleDesktopPianoCollapsed()
	if clickSound then
		clickSound:Play()
	end

	SetDesktopPianoCollapsed(not DesktopPianoCollapsed)
end

function AnimateDesktopPianoVisibility(p)
	if p or PianoVisibilityTargetVisible or PianoContainer.Visible then
		if PianoVisibilityTween then
			PianoVisibilityTween:Cancel()
			PianoVisibilityTween = nil
		end

		PianoVisibilityTargetVisible = p

		if p then
			DesktopPianoCollapsed = false

			if DesktopPianoCollapseTween then
				DesktopPianoCollapseTween:Cancel()
				DesktopPianoCollapseTween = nil
			end

			SetDesktopPianoTopButtonsVisible(true)
			PianoContainer.Visible = true
			PianoContainer.Position = PianoContainerHiddenPosition
			UpdateDesktopPianoCollapseKnob()
			PianoVisibilityTween = TweenService:Create(
				PianoContainer,
				TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = PianoContainerVisiblePosition }
			)
		else
			DesktopPianoCollapsed = false

			if DesktopPianoCollapseTween then
				DesktopPianoCollapseTween:Cancel()
				DesktopPianoCollapseTween = nil
			end

			SetDesktopPianoTopButtonsVisible(true)

			if PianoCollapseKnob and PianoCollapseKnob:IsA("GuiObject") then
				PianoCollapseKnob.Visible = false
			end

			PianoContainer.Visible = true
			PianoVisibilityTween = TweenService:Create(
				PianoContainer,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ Position = PianoContainerHiddenPosition }
			)

			PianoVisibilityTween.Completed:Connect(function()
				if not PianoVisibilityTargetVisible then
					PianoContainer.Visible = false
					PianoContainer.Position = PianoContainerVisiblePosition
				end
			end)
		end

		PianoVisibilityTween:Play()
	else
		PianoContainer.Position = PianoContainerVisiblePosition

		if PianoCollapseKnob and PianoCollapseKnob:IsA("GuiObject") then
			PianoCollapseKnob.Visible = false
		end
	end
end

local function SetPianoVisibility(visible)
	HideDetachedNPSFrame() -- inferred equivalent call

	if nps and nps:IsA("GuiObject") then
		nps.Visible = true
	end

	if visible2 and MobilePianoContainer then
		DesktopPianoCollapsed = false
		SetDesktopPianoTopButtonsVisible(true)

		if PianoCollapseKnob and PianoCollapseKnob:IsA("GuiObject") then
			PianoCollapseKnob.Visible = false
		end

		if visible then
			v4 = false
		end

		ApplyMobilePianoLayout()
		PianoContainer.Visible = false
		MobilePianoContainer.Visible = visible
		setDesktopShellHiddenForMobile(true) -- inferred equivalent call

		if guiObject2 and guiObject2:IsA("GuiObject") then
			if guiObject2 == button then
				guiObject2.Visible = visible
			else
				guiObject2.Visible = visible and v4
			end
		end
	else
		AnimateDesktopPianoVisibility(visible)

		if MobilePianoContainer then
			MobilePianoContainer.Visible = false
		end

		if guiObject2 and guiObject2:IsA("GuiObject") then
			guiObject2.Visible = false
		end

		setDesktopShellHiddenForMobile(false) -- inferred equivalent call
	end

	if mobileUtilityButtons then
		mobileUtilityButtons.Visible = visible and visible2
	end

	if not visible then
		hideSharedFeatureFrames()
	end
end

function ApplyDeviceUIChoice(p)
	local visible = PianoContainer and PianoContainer.Visible or MobilePianoContainer and MobilePianoContainer.Visible
	visible2 = p == true
	v3 = true
	MobileKeysFrame = getMobileKeysFrame() -- inferred equivalent call
	KeysFrame = visible2 and MobileKeysFrame or DesktopKeysFrame

	if visible2 then
		ApplyMobilePianoLayout()
	else
		if MobilePianoContainer then
			MobilePianoContainer.Visible = false
		end

		setDesktopShellHiddenForMobile(false) -- inferred equivalent call
	end

	if visible then
		SetPianoVisibility(true)
	else
		if PianoContainer then
			PianoContainer.Visible = false
		end

		if MobilePianoContainer then
			MobilePianoContainer.Visible = false
		end

		if mobileUtilityButtons then
			mobileUtilityButtons.Visible = false
		end
	end

	if _G.PianoSimBindMobileRecordingControls then
		_G.PianoSimBindMobileRecordingControls()
	end
end

OpenDeviceChangeEvent = ReplicatedStorage:FindFirstChild("OpenDeviceChange")

if not (OpenDeviceChangeEvent and OpenDeviceChangeEvent:IsA("BindableEvent")) then
	if OpenDeviceChangeEvent then
		OpenDeviceChangeEvent:Destroy()
	end

	OpenDeviceChangeEvent = Instance.new("BindableEvent")
	OpenDeviceChangeEvent.Name = "OpenDeviceChange"
	OpenDeviceChangeEvent.Parent = ReplicatedStorage
end

OpenDeviceChangeEvent.Event:Connect(function()
	task.spawn(function()
		showMobileUIPromptIfNeeded(true)
	end)
end)

KEY_OFFSET = 15

PianoSimVPNotes = PianoSimVPNotes or {}
guiObject = PianoSimVPNotes

do
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	guiObject.Event = ReplicatedStorage:FindFirstChild("VPNotePlayed")
end

if not PianoSimVPNotes.Event then
	PianoSimVPNotes.Event = Instance.new("BindableEvent")
	PianoSimVPNotes.Event.Name = "VPNotePlayed"
	local event = PianoSimVPNotes.Event
	event.Parent = game:GetService("ReplicatedStorage")
end

function PianoSimVPNotes.GetChar(p)
	local v21 = tonumber(p)

	if not v21 then
		return nil
	end

	for i = 1, 61 do
		if Logic_Keymap:GetMappedNote(i) == v21 then
			return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(i, i)
		end
	end

	if v21 >= 1 and v21 <= 61 then
		return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(v21, v21)
	end

	return nil
end

function PianoSimVPNotes.Fire(p, p2)
	if not p or p == "" then
		return
	end

	if PianoSimVPNotes.Event and PianoSimVPNotes.Event:IsA("BindableEvent") then
		PianoSimVPNotes.Event:Fire(p, p2)
	end
end

local v21 = {}
local v22 = {}
local v23 = {}
local v24 = {}
local v25 = {}

local function createActiveVisualizationTable() -- 2 equivalent calls inferred from this helper
	return (setmetatable({}, { __mode = "k" }))
end

local activeVisualizationTable = createActiveVisualizationTable() -- inferred equivalent call
local currentPianoModel = nil
local v26 = 0
local viewingPianoModel = nil

PianoPractice.PianoCameraCycle = {
	PianoModel = nil,
	Cameras = {},
	Index = 0,
	Mode = "FreeCam",
	CanUseFreeCam = true,
	LastFreeCamCFrame = nil
}

function PianoPractice.GetPianoCameraLabel()
	local camera = OptionFrame and OptionFrame:FindFirstChild("Camera")

	if not camera then
		return nil
	end

	local textLabel = camera:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		return textLabel
	end

	return nil
end

function PianoPractice.SetPianoCameraButtonLabel(text)
	local pianoCameraLabel = PianoPractice.GetPianoCameraLabel()

	if pianoCameraLabel then
		pianoCameraLabel.Text = text
	end
end

function PianoPractice.IsValidPianoCameraTarget(instance)
	return instance and (instance:IsA("BasePart") or instance:IsA("Camera") or instance:IsA("Attachment"))
end

function PianoPractice.GetPianoCameraSortIndex(p)
	local match = p.Name:match("^Camera(%d*)$")

	if match == nil then
		return tonumber(p.Name:match("(%d+)$")) or 1e999
	elseif match == "" then
		return 1
	end

	return tonumber(match) or 1e999
end

function PianoPractice.CollectPianoCameras(instance)
	local children = {}
	local cameras = instance and instance:FindFirstChild("Cameras")

	if cameras then
		for _, child in ipairs(cameras:GetChildren()) do
			if PianoPractice.IsValidPianoCameraTarget(child) then
				table.insert(children, child)
			end
		end
	end

	table.sort(children, function(a, b): boolean
		local pianoCameraSortIndex = PianoPractice.GetPianoCameraSortIndex(a)
		local pianoCameraSortIndex2 = PianoPractice.GetPianoCameraSortIndex(b)

		if pianoCameraSortIndex == pianoCameraSortIndex2 then
			return a.Name < b.Name
		end

		return pianoCameraSortIndex < pianoCameraSortIndex2
	end)

	return children
end

function PianoPractice.GetPianoCanUseFreeCam(instance, list): boolean
	local canUseFreeCam = instance and instance:GetAttribute("CanUseFreeCam")

	if #list ~= 0 then
		return canUseFreeCam ~= false
	end

	if canUseFreeCam == false and instance then
		v.Warn("[PianoMain] " .. instance:GetFullName() .. " has CanUseFreeCam disabled but no custom cameras; using Free Cam.")
	end

	return true
end

function PianoPractice.RefreshPianoCameraCycle(pianoModel)
	local pianoCameras = PianoPractice.CollectPianoCameras(pianoModel)
	local pianoCameraCycle = PianoPractice.PianoCameraCycle
	pianoCameraCycle.PianoModel = pianoModel
	pianoCameraCycle.Cameras = pianoCameras
	pianoCameraCycle.CanUseFreeCam = PianoPractice.GetPianoCanUseFreeCam(pianoModel, pianoCameras)
	return pianoCameras
end

function PianoPractice.ClearPianoCameraCycle()
	local pianoCameraCycle = PianoPractice.PianoCameraCycle
	pianoCameraCycle.PianoModel = nil
	pianoCameraCycle.Cameras = {}
	pianoCameraCycle.Index = 0
	pianoCameraCycle.Mode = "FreeCam"
	pianoCameraCycle.CanUseFreeCam = true
	pianoCameraCycle.LastFreeCamCFrame = nil
	PianoPractice.SetPianoCameraButtonLabel("Camera")
end

do
	local function ApplyPianoCameraIndex(p)
		local pianoCameraCycle = PianoPractice.PianoCameraCycle

		if p == 0 then
			local v27 = pianoCameraCycle.Mode == "Custom" and 0.35 or 0
			local lastFreeCamCFrame = pianoCameraCycle.LastFreeCamCFrame
			pianoCameraCycle.Index = 0
			pianoCameraCycle.Mode = "FreeCam"
			Logic_Character.UseFreeCamera(humanoid, true, v27, lastFreeCamCFrame)
			PianoPractice.SetPianoCameraButtonLabel("Free Cam")
			return true
		else
			local camera = pianoCameraCycle.Cameras[p]

			if not (camera and camera.Parent) then
				v.Warn("[PianoMain] Custom piano camera target was unavailable; using Free Cam.")
				return PianoPractice.ApplyPianoCameraIndex(0)
			end

			if pianoCameraCycle.Mode == "FreeCam" and workspace.CurrentCamera then
				pianoCameraCycle.LastFreeCamCFrame = workspace.CurrentCamera.CFrame
			end

			if not Logic_Character.SetScriptedCamera(camera, 0.35) then
				v.Warn("[PianoMain] Custom piano camera target was unavailable; using Free Cam.")
				return PianoPractice.ApplyPianoCameraIndex(0)
			end

			pianoCameraCycle.Index = p
			pianoCameraCycle.Mode = "Custom"
			PianoPractice.SetPianoCameraButtonLabel(camera.Name)
			return true
		end
	end

	PianoPractice.ApplyPianoCameraIndex = ApplyPianoCameraIndex
end

function PianoPractice.InitializePianoCameraCycle(p)
	if #PianoPractice.RefreshPianoCameraCycle(p) > 0 and not PianoPractice.PianoCameraCycle.CanUseFreeCam then
		PianoPractice.ApplyPianoCameraIndex(1)
	else
		PianoPractice.ApplyPianoCameraIndex(0)
	end
end

do
	local function CyclePianoCamera()
		if not currentPianoModel then
			return
		end

		if MarkPianoActivity then
			MarkPianoActivity()
		end

		local pianoCameraCycle = PianoPractice.PianoCameraCycle

		if pianoCameraCycle.PianoModel ~= currentPianoModel then
			PianoPractice.InitializePianoCameraCycle(currentPianoModel)
		end

		local cameras = pianoCameraCycle.Cameras

		if #cameras == 0 then
			PianoPractice.RefreshPianoCameraCycle(currentPianoModel)
			PianoPractice.ApplyPianoCameraIndex(0)
		else
			local v27 = (pianoCameraCycle.Mode == "FreeCam" or pianoCameraCycle.Index <= 0) and 1
				or pianoCameraCycle.Index + 1

			local v28 = #cameras < v27 and (pianoCameraCycle.CanUseFreeCam and 0 or 1) or v27

			PianoPractice.ApplyPianoCameraIndex(v28)
		end
	end

	PianoPractice.CyclePianoCamera = CyclePianoCamera
end

local v27 = {}

local v28 = UserInputService.TouchEnabled and 0.03 or 0.05

local function getKeyPartForVisualization(p, instance)
	if not instance then
		return nil
	end

	local v29 = tonumber(p)

	if not v29 then
		return nil
	end

	local synth = instance:FindFirstChild("Synth")

	if instance:GetAttribute("UseDefaultSynthesia") == true and synth then
		local part = synth:FindFirstChild((tostring((math.floor(v29 + KEY_OFFSET + 0.5)))))
		return if part and part:IsA("BasePart") then part else nil
	else
		local keys = instance:FindFirstChild("Keys")

		if not keys then
			return nil
		end

		local keys2 = keys:FindFirstChild("Keys")
		local v30

		if keys2 then
			v30 = { keys2, keys } or { keys }
		else
			v30 = { keys }
		end

		local useA0PhysicalKeyNumbers = instance:GetAttribute("UseA0PhysicalKeyNumbers") == true
		local v31

		if keys2 and useA0PhysicalKeyNumbers then
			v31 = { v29 + KEY_OFFSET, v29, v29 - KEY_OFFSET }
		elseif keys2 then
			v31 = { v29, v29 + KEY_OFFSET, v29 - KEY_OFFSET }
		else
			v31 = { v29 + KEY_OFFSET, v29, v29 - KEY_OFFSET }
		end

		local set = {}

		for _, v32 in ipairs(v31) do
			local v46 = math.floor(v32 + 0.5)

			if set[v46] then
				continue
			end

			set[v46] = true
			local v47 = tostring(v46)

			for _, v48 in ipairs(v30) do
				local part = v48:FindFirstChild(v47)

				if part and part:IsA("BasePart") then
					return part
				end
			end
		end

		return nil
	end
end

local visualSettingHelpers = {}

function visualSettingHelpers.HexToColor3(value2)
	if typeof(value2) ~= "string" then
		return nil
	end

	local v29 = value2:gsub("#", "")

	if #v29 ~= 6 then
		return nil
	end

	local v30 = tonumber(v29:sub(1, 2), 16)
	local v31 = tonumber(v29:sub(3, 4), 16)
	local v32 = tonumber(v29:sub(5, 6), 16)

	if v30 and v31 and v32 then
		return Color3.fromRGB(v30, v31, v32)
	end

	return nil
end

function visualSettingHelpers.GetSynthesiaColorsForPlayer(instance)
	if not instance then
		return nil
	end

	local currentColourHex = instance:GetAttribute("CurrentColourHex") or "#FFFFFF"
	local white = visualSettingHelpers.HexToColor3(instance:GetAttribute("WhiteSynthesiaHex") or currentColourHex)
		or Color3.fromRGB(255, 255, 255)
	return {
		White = white,
		Black = visualSettingHelpers.HexToColor3(instance:GetAttribute("BlackSynthesiaHex") or currentColourHex) or white
	}
end

function visualSettingHelpers.ApplySynthesiaColorsFromPlayer(p, instance, p2)
	if not (p and instance) then
		return nil
	end

	local synthesiaColorsForPlayer = visualSettingHelpers.GetSynthesiaColorsForPlayer(p)

	if not synthesiaColorsForPlayer then
		return nil
	end

	if p2 == false or instance:GetAttribute("RainbowActive") == true then
		return synthesiaColorsForPlayer
	end

	if PianoVisualization.SetVisualizerKeyColors then
		PianoVisualization.SetVisualizerKeyColors(
			synthesiaColorsForPlayer.White,
			synthesiaColorsForPlayer.Black,
			instance
		)
	else
		PianoVisualization.SetVisualizerColor(synthesiaColorsForPlayer.White, instance)
	end

	if instance:GetAttribute("RainbowActive") ~= true then
		PianoModelKeyHighlight.ApplySynthesiaColors(
			instance,
			synthesiaColorsForPlayer.White,
			synthesiaColorsForPlayer.Black
		)
	end

	return synthesiaColorsForPlayer
end

function visualSettingHelpers.ModelKeyHighlightEnabledFor(instance): boolean
	return not instance or instance:GetAttribute("ModelKeyHighlightEnabled") ~= false
end

function visualSettingHelpers.IsSharedDuetPianoModel(instance): boolean
	return instance ~= nil
		and instance.Name == "Duet Piano"
		and (instance:GetAttribute("AllowMultipleOccupants") == true or instance:FindFirstChild("SeatOccupants") ~= nil)
end

function visualSettingHelpers.IsBlackModelKey(p, p2, p3)
	return PianoModelKeyHighlight.IsBlackModelKey(p3, p, p2)
end

function visualSettingHelpers.GetModelKeyHighlightColorForPlayer(p, p2, p3, p4)
	local playerSynthesiaColors, v29 = PianoModelKeyHighlight.GetPlayerSynthesiaColors(p)

	if p4 then
		PianoModelKeyHighlight.ApplySynthesiaColors(p4, playerSynthesiaColors, v29)
	end

	if visualSettingHelpers.IsBlackModelKey(p2, p3, p4) then
		return v29 or playerSynthesiaColors
	end

	return playerSynthesiaColors
end

do
	local function resolveModelKeyPartForHighlight(instance, p)
		local keys = instance and instance:FindFirstChild("Keys")

		if not (keys and p) then
			return nil
		end

		local part = keys:FindFirstChild((tostring(p)))

		if part and part:IsA("BasePart") then
			return part
		end

		local keys2 = keys:FindFirstChild("Keys")

		if not keys2 then
			return nil
		end

		if instance:GetAttribute("UseA0PhysicalKeyNumbers") == true then
			local part2 = keys2:FindFirstChild((tostring(p)))

			if part2 and part2:IsA("BasePart") then
				return part2
			end

			return nil
		else
			local v29 = tonumber(p)
			local v30 = v29 and v29 - KEY_OFFSET
			local part2 = v30 and keys2:FindFirstChild((tostring(v30)))

			if part2 and part2:IsA("BasePart") then
				return part2
			end

			local part3 = keys2:FindFirstChild((tostring(p)))

			if part3 and part3:IsA("BasePart") then
				return part3
			end
		end

		return nil
	end

	function visualSettingHelpers.PrepareModelKeyHighlight(instance, p, p2, p3)
		if not p2 then
			return
		end

		local v29 = instance and instance:GetAttribute("UseDefaultSynthesia") == true

		if not (v29 or visualSettingHelpers.IsSharedDuetPianoModel(instance)) then
			return
		end

		local modelKeyPartForHighlight = resolveModelKeyPartForHighlight(instance, p)

		if not (modelKeyPartForHighlight and modelKeyPartForHighlight:IsA("BasePart")) then
			return
		end

		local rainbowOwnerUserId = tonumber(instance:GetAttribute("RainbowOwnerUserId")) or 0

		if rainbowOwnerUserId > 0 and p3 and p3.UserId == rainbowOwnerUserId then
			modelKeyPartForHighlight:SetAttribute("HighlightColor", nil)
			return
		end

		local synthesiaColorsForPlayer = visualSettingHelpers.GetSynthesiaColorsForPlayer(p3)

		if v29 and synthesiaColorsForPlayer and synthesiaColorsForPlayer.White then
			instance:SetAttribute("VizColor", synthesiaColorsForPlayer.White)
		end

		modelKeyPartForHighlight:SetAttribute(
			"HighlightColor",
			visualSettingHelpers.GetModelKeyHighlightColorForPlayer(p3, p, modelKeyPartForHighlight, instance)
		)
	end
end

function visualSettingHelpers.AnimatePianoModelKey(instance, p, p2, p3, value2, p4, p5)
	if not (instance and p) then
		return
	end

	visualSettingHelpers.PrepareModelKeyHighlight(instance, p, p2, p3)
	local pianoModule = instance:FindFirstChild("Scripts") and instance.Scripts:FindFirstChild("PianoModule")

	if pianoModule then
		local success, result = pcall(require, pianoModule)

		if success and result and result.PianoAnimation then
			result.PianoAnimation(
				p,
				p2,
				p2 and not visualSettingHelpers.ModelKeyHighlightEnabledFor(p3),
				value2 or 0,
				p4,
				p5
			)
		end
	end
end

function visualSettingHelpers.ClearPianoModelKeyHighlights(instance)
	local keys = instance and instance:FindFirstChild("Keys")

	if not keys then
		return
	end

	for _, child in ipairs(keys:GetChildren()) do
		local name = tonumber(child.Name)

		if name then
			visualSettingHelpers.AnimatePianoModelKey(instance, name, false, LocalPlayer)
		end
	end
end

LocalPlayer:GetAttributeChangedSignal("ModelKeyHighlightEnabled"):Connect(function()
	if LocalPlayer:GetAttribute("ModelKeyHighlightEnabled") == false then
		visualSettingHelpers.ClearPianoModelKeyHighlights(currentPianoModel)
	end
end)

do
	local function startVisualization(p, p2, p3)
		if not p2 then
			return
		end

		local v29 = visualSettingHelpers.ApplySynthesiaColorsFromPlayer(p3 or LocalPlayer, p2, false)

		if not v27[p] then
			v27[p] = { lastPress = 0, lastRelease = 0 }
		end

		local now = tick()

		if now - v27[p].lastPress < v28 then
			return
		end

		v27[p].lastPress = now

		if not activeVisualizationTable[p2] then
			activeVisualizationTable[p2] = {}
		end

		if activeVisualizationTable[p2][p] then
			PianoVisualization.EndVisualization(p)
			activeVisualizationTable[p2][p] = nil
		end

		local keyPartForVisualization = getKeyPartForVisualization(p, p2)

		local v30 = keyPartForVisualization
			and PianoVisualization.StartVisualization(keyPartForVisualization, p, 5, p3 or LocalPlayer, v29)

		if v30 then
			activeVisualizationTable[p2][p] = v30
		end
	end

	local function endVisualization(p, currentPianoModel2)
		if not currentPianoModel2 then
			return
		end

		if not v27[p] then
			v27[p] = { lastPress = 0, lastRelease = 0 }
		end

		local now = tick()
		v27[p].lastRelease = now

		if activeVisualizationTable[currentPianoModel2] and activeVisualizationTable[currentPianoModel2][p] then
			PianoVisualization.EndVisualization(p)
			activeVisualizationTable[currentPianoModel2][p] = nil
		end
	end

	local function cleanupPianoVisualizations(p) -- 5 equivalent calls inferred from this helper
		if p then
			if activeVisualizationTable[p] then
				for k, _ in pairs(activeVisualizationTable[p]) do
					PianoVisualization.EndVisualization(k)
				end

				activeVisualizationTable[p] = nil
			end
		else
			PianoVisualization.FadeAllVisualizations()
			activeVisualizationTable = createActiveVisualizationTable() -- inferred equivalent call
		end
	end

	local function forceReleasePianoKeys(instance)
		local scripts = instance and instance:FindFirstChild("Scripts")
		local pianoModule = scripts and scripts:FindFirstChild("PianoModule")

		if not pianoModule then
			return
		end

		local success, result = pcall(function()
			local module = require(pianoModule)

			if module.ForceReleaseAllKeys then
				module.ForceReleaseAllKeys()
			end
		end)

		if not success then
			v.Warn("[PianoMain] Failed to release viewed piano keys:", result)
		end
	end

	PianoSimCustomVisualEffectCache = PianoSimCustomVisualEffectCache or setmetatable({}, {
		__mode = "k"
	})

	local function isCustomVisualEffectDisabled(instance): boolean
		if not (instance and instance:GetAttribute("PianoSimDisableCustomVisualEffect") ~= true) then
			return true
		end

		local scripts = instance:FindFirstChild("Scripts")
		local visualEffectClient = scripts and scripts:FindFirstChild("VisualEffectClient")
		return visualEffectClient ~= nil
			and visualEffectClient:GetAttribute("PianoSimDisableCustomVisualEffect") == true
	end

	function PianoSimGetCustomVisualEffect(instance)
		if not instance then
			return nil
		end

		if isCustomVisualEffectDisabled(instance) then
			PianoSimCustomVisualEffectCache[instance] = false
			return nil
		end

		local v29 = PianoSimCustomVisualEffectCache[instance]

		if v29 == nil then
			local scripts = instance:FindFirstChild("Scripts")
			local visualEffectClient = scripts and scripts:FindFirstChild("VisualEffectClient")

			if not (visualEffectClient and visualEffectClient:IsA("ModuleScript")) then
				PianoSimCustomVisualEffectCache[instance] = false
				return nil
			end

			local success, result = pcall(require, visualEffectClient)

			if success and type(result) == "table" then
				PianoSimCustomVisualEffectCache[instance] = result
				return result
			end

			v.Warn("[PianoMain] Failed to load VisualEffectClient for", instance:GetFullName(), result)
			PianoSimCustomVisualEffectCache[instance] = false
			return nil
		end

		return if not (v29 == false or not v29) then v29 else nil
	end

	function PianoSimRunCustomVisualEffect(p, p2, p3, p4)
		local v29 = PianoSimGetCustomVisualEffect(p)

		if not (v29 and v29.Play) then
			return
		end

		local success, result = pcall(v29.Play, p2, p3, p4)

		if not success then
			v.Warn("[PianoMain] VisualEffectClient failed:", result)
		end
	end

	function PianoSimResetCustomVisualEffect(p)
		local function resetOne(p2) -- 1 equivalent call inferred from this helper
			local v29 = PianoSimGetCustomVisualEffect(p2)

			if v29 and v29.Reset then
				pcall(v29.Reset)
			end
		end

		if p then
			resetOne(p) -- inferred equivalent call
		else
			for _, v29 in pairs(PianoSimCustomVisualEffectCache) do
				if v29 and v29 ~= false and v29.Reset then
					pcall(v29.Reset)
				end
			end
		end
	end

	local function cleanupViewedPiano(viewingPianoModel2) -- 1 equivalent call inferred from this helper
		if viewingPianoModel2 then
			cleanupPianoVisualizations(viewingPianoModel2)
			PianoSimResetCustomVisualEffect(viewingPianoModel2)

			if viewingPianoModel2 ~= currentPianoModel then
				forceReleasePianoKeys(viewingPianoModel2)
			end
		else
			cleanupPianoVisualizations(nil) -- inferred equivalent call
			PianoSimResetCustomVisualEffect(nil)
		end
	end

	function PianoSimGetAudienceZonePart(instance)
		local pianoGroupId = instance and instance:GetAttribute("PianoGroupId")
		local pianoGroupZones = workspace:FindFirstChild("PianoGroupZones")
		local part = pianoGroupId and pianoGroupZones and pianoGroupZones:FindFirstChild(pianoGroupId)

		if part then
			if part:IsA("BasePart") then
				return part
			end

			local zone = part:FindFirstChild("Zone")

			if zone and zone:IsA("BasePart") then
				return zone
			end
		end

		return instance and instance:FindFirstChild("Zone")
	end

	local function isLocalPlayerInsidePianoZone(p): boolean
		local character = LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local part = PianoSimGetAudienceZonePart(p)

		if not (humanoidRootPart and part and part:IsA("BasePart")) then
			return false
		end

		local pointToObjectSpace = part.CFrame:PointToObjectSpace(humanoidRootPart.Position)
		local v29 = part.Size * 0.5

		return math.abs(pointToObjectSpace.X) <= v29.X + 2
			and math.abs(pointToObjectSpace.Y) <= v29.Y + 8
			and math.abs(pointToObjectSpace.Z) <= v29.Z + 2
	end

	local function getNearestPracticeIceFishingPiano()
		if not PianoPractice.Active then
			return nil
		end

		local pianos = workspace:FindFirstChild("Pianos")
		local iceFishing = pianos and pianos:FindFirstChild("IceFishing")
		local character = LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not (iceFishing and humanoidRootPart) then
			return nil
		end

		local v29 = nil
		local v30 = nil

		for _, model in ipairs(iceFishing:GetChildren()) do
			if not (model:IsA("Model") and model:FindFirstChild("Zone") and isLocalPlayerInsidePianoZone(model)) then
				continue
			end

			local seat = model:FindFirstChild("Seat", true)
			local position = model.Zone.Position

			if seat and seat:IsA("BasePart") then
				position = seat.Position
			end

			local magnitude = (humanoidRootPart.Position - position).Magnitude

			if not (not v29 or magnitude < v29) then
				continue
			end

			v30 = model
			v29 = magnitude
		end

		return v30
	end

	local function randomPracticeIceFishingPoint(position, p)
		local random = Random.new()

		for _ = 1, 1000 do
			local number = random:NextNumber(-p, p)
			local number2 = random:NextNumber(-p, p)

			if number * number + number2 * number2 <= p * p then
				return (Vector3.new(position.X + number, position.Y, position.Z + number2))
			end
		end

		return position
	end

	local function practiceIceFishingQuadraticRoot(p, p2, p3) -- 1 equivalent call inferred from this helper
		local v29 = math.max(0, p2 * p2 - 4 * p * p3)
		return (-p2 + math.sqrt(v29)) / (2 * p)
	end

	local function rotatePracticeIceFishingVector(data, p, p2)
		local v29 = math.rad(p)

		if p2 == "x" then
			return (Vector3.new(
				data.X,
				math.cos(v29) * data.Y - math.sin(v29) * data.Z,
				math.sin(v29) * data.Y + math.cos(v29) * data.Z
			))
		elseif p2 == "y" then
			return (Vector3.new(
				math.cos(v29) * data.X - math.sin(v29) * data.Z,
				data.Y,
				math.sin(v29) * data.X + math.cos(v29) * data.Z
			))
		elseif p2 == "z" then
			return (Vector3.new(
				math.cos(v29) * data.X - math.sin(v29) * data.Y,
				math.sin(v29) * data.X + math.cos(v29) * data.Y,
				data.Z
			))
		end

		return data
	end

	local function animatePracticeIceFishingFish(clone, p, p2, number, vector3) -- 1 equivalent call inferred from this helper
		task.spawn(function()
			local vector3_2 = Vector3.new(0, -workspace.Gravity, 0)
			local total = 0

			while clone.Parent and total < number * 2 do
				local v29 = vector3_2 * 0.5 * total * total + p2 * total + p
				clone:PivotTo(CFrame.new(v29) * CFrame.Angles(
					vector3.X * total / number,
					vector3.Y * total / number,
					vector3.Z * total / number
				))

				total += RunService.Heartbeat:Wait()
			end

			if clone.Parent then
				clone:Destroy()
			end
		end)
	end

	local function trimPracticeIceFishingFish(fish)
		local children = {}

		for _, child in ipairs(fish:GetChildren()) do
			if child:GetAttribute("LocalPracticeIceFishingEffect") then
				table.insert(children, child)
			end
		end

		while true do
			local v29 = #children >= 50 and table.remove(children, 1)

			if not v29 then
				break
			end

			v29:Destroy()
		end
	end

	local function spawnPracticeIceFishingFish(nearestPracticeIceFishingPiano)
		local parent = nearestPracticeIceFishingPiano and nearestPracticeIceFishingPiano.Parent

		if not parent or parent.Name ~= "IceFishing" then
			return
		end

		local fish = parent:FindFirstChild("Fish")
		local fishList = parent:FindFirstChild("FishList")
		local fishSpawn = parent:FindFirstChild("FishSpawn")

		if not (fish and fishList and fishSpawn and fishSpawn:IsA("BasePart")) then
			return
		end

		local settings = nearestPracticeIceFishingPiano:FindFirstChild("Settings")

		if (settings and require(settings) or { KeyAesthetics = true }).KeyAesthetics == false then
			return
		end

		local children = fishList:GetChildren()

		if #children == 0 then
			return
		end

		trimPracticeIceFishingFish(fish)

		local random = Random.new()
		local position = fishSpawn.Position
		local v29 = math.max(1, math.min(fishSpawn.Size.Y, fishSpawn.Size.Z) / 2)
		local v30 = randomPracticeIceFishingPoint(position, v29)
		local v31 = position - v30
		local v32 = v31.Magnitude < 0.001 and Vector3.new(1, 0, 0) or v31

		local v47 = 180 - 135 * (v32.Magnitude / v29)
		local v48 = math.max(
			1,
			practiceIceFishingQuadraticRoot(1, -2 * v32.Magnitude * math.cos((math.rad(v47))), v32.Magnitude ^ 2 - 529) -- inferred equivalent call
		)

		local number = random:NextNumber(-v47, v47)
		local unit = v32.Unit
		local v49 = math.rad(number)

		local v50 = v30 + Vector3.new(
			math.cos(v49) * unit.X - math.sin(v49) * unit.Z,
			unit.Y,
			math.sin(v49) * unit.X + math.cos(v49) * unit.Z
		) * random:NextNumber(v48 / 3, v48)

		local number2 = random:NextNumber(0.3, 0.8)
		local vector3 = Vector3.new(0, -workspace.Gravity, 0)
		local v51 = (v50 - v30 - vector3 * 0.5 * number2 ^ 2) / number2
		local vector3_2 = Vector3.new(random:NextNumber(-5, 5), random:NextNumber(-5, 5), random:NextNumber(-5, 5))

		local clone = children[random:NextInteger(1, #children)]:Clone()
		clone:SetAttribute("LocalPracticeIceFishingEffect", true)
		clone.Parent = fish
		clone:PivotTo(CFrame.new(v30))
		animatePracticeIceFishingFish(clone, v30, v51, number2, vector3_2) -- inferred equivalent call
	end

	function PianoPractice.RunNearbyIceFishingEffect(_, p)
		if not (PianoPractice.Active and p) then
			return
		end

		local nearestPracticeIceFishingPiano = getNearestPracticeIceFishingPiano()

		if nearestPracticeIceFishingPiano then
			spawnPracticeIceFishingFish(nearestPracticeIceFishingPiano)
		end
	end

	local total = 0
	RunService.Heartbeat:Connect(function(dt)
		if not viewingPianoModel then
			return
		end

		total += dt

		if total < 0.2 then
			return
		end

		total = 0

		if humanoid and humanoid.SeatPart and IsPianoControlsVisible() then -- inferred equivalent call
			return
		end

		if not isLocalPlayerInsidePianoZone(viewingPianoModel) then
			cleanupViewedPiano(viewingPianoModel) -- inferred equivalent call
			ClearAllPianoKeyHighlights()
			viewingPianoModel = nil
		end
	end)

	DraggableFrames = {}

	if findSharedFeatureFrame("Soundfonts") then
		table.insert(DraggableFrames, findSharedFeatureFrame("Soundfonts"))
	end

	if findSharedFeatureFrame("SoundEffects") then
		table.insert(DraggableFrames, findSharedFeatureFrame("SoundEffects"))
	end

	if findSharedFeatureFrame("Sheets") then
		table.insert(DraggableFrames, findSharedFeatureFrame("Sheets"))
	end

	function ClearAllPianoKeyHighlights()
		if Logic_UI.ClearAllKeyFrames then
			Logic_UI.ClearAllKeyFrames(DesktopKeysFrame, MobileKeysFrame)
		else
			Logic_UI.ClearAllNotes(KeysFrame)
		end
	end

	function PianoSimCanPlayForCompetitionTurn(instance): boolean
		if not instance then
			return true
		end

		local parent = instance.Parent

		if not parent or not parent:IsA("Model") or parent.Name ~= "CompetitionPiano" then
			return true
		end

		local on = instance:FindFirstChild("On")
		return not (on and on:IsA("BoolValue")) or on.Value == true
	end

	local function ProcessPianoAction(_, p, p2)
		if ReplicatedStorage:GetAttribute("BindsCaptureActive") == true then
			return Enum.ContextActionResult.Sink
		end

		local value2 = p2.KeyCode.Value

		local lower = string.char(value2):lower()
		local v29 = (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) ~= (CapsShiftLock == true)

		local v30 = GetEffectiveTransposition()
		local flag2 = false

		local v31 = {
			["1"] = "!",
			["2"] = "@",
			["4"] = "$",
			["5"] = "%",
			["6"] = "^",
			["8"] = "*",
			["9"] = "("
		}

		local v32 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(lower, 1, true)

		if v32 then
			local v47 = Logic_Keymap:GetMappedNote(v32)

			if v29 then
				local v48 = v31[lower]
				local v49 = v48 and ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(v48, 1, true)

				if v49 then
					local mappedNote = Logic_Keymap:GetMappedNote(v49)

					if mappedNote ~= v49 then
						v47 = mappedNote
						flag2 = true
					end
				else
					local v50 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(
						string.char(value2):upper(),
						1,
						true
					)

					if v50 and v50 ~= v32 then
						local mappedNote = Logic_Keymap:GetMappedNote(v50)

						if mappedNote ~= v50 then
							v47 = mappedNote
							flag2 = true
						end
					end
				end
			end

			local v48

			if flag2 then
				v48 = v30 - 1 or v30
			else
				v48 = v30
			end

			local v49 = v47 + v48

			local current_SoundfontID = Dependence_PlayerVariables.Current_SoundfontID
			local dependence_Soundfont = Dependence_Soundfonts[current_SoundfontID]
			PrewarmCurrentSoundfont(current_SoundfontID)

			local assetIds = dependence_Soundfont.AssetIds
			local offset = dependence_Soundfont.Offset
			local maxLifetime = dependence_Soundfont.MaxLifetime
			local fadeout = dependence_Soundfont.Fadeout
			local volumeModifier = dependence_Soundfont.VolumeModifier
			local packetType = dependence_Soundfont.PacketType

			local v50 = humanoid.SeatPart and getPianoModel(humanoid.SeatPart)

			if p == Enum.UserInputState.Begin and not PianoSimCanPlayForCompetitionTurn(v50) then
				return Enum.ContextActionResult.Sink
			end

			if v50 and v50:FindFirstChild("Scripts") then
				v50.Scripts:FindFirstChild("PianoModule")
			end

			if p == Enum.UserInputState.Begin then
				if v25[p2.KeyCode] then
					return Enum.ContextActionResult.Sink
				end

				v25[p2.KeyCode] = true

				if v18 == true then
					Velocity = tonumber(Logic_Keymap:VelocityKeyCodes()[("1234567890qwertyuiopasdfghjklzxc"):find(
						string.char(value2),
						1,
						true
					)])
					Logic_UI.ForceShowFrame(VelocityBar)
					VelocityBar.Bar.Size = UDim2.fromOffset(Velocity, 5)

					v25[p2.KeyCode] = nil
					return Enum.ContextActionResult.Sink
				elseif above88KeyPacket == true then
					local piano88KeyCodes = Logic_Keymap.Piano88KeyCodes

					local v51 = ("trewq0987654321yuiopasdfghj"):find(lower, 1, true)

					if not v51 then
						return Enum.ContextActionResult.Pass
					end

					local v52 = piano88KeyCodes[v51] + v30
					local v53 = ("trewq0987654321yuiopasdfghj"):sub(v51, v51)

					if v29 then
						v53 = v31[v53] or v53:upper()
					end

					Logic_Piano[packetType](
						v52,
						assetIds,
						offset,
						maxLifetime,
						fadeout,
						v30,
						packetType,
						sustainPacket,
						above88KeyPacket,
						Velocity,
						LocalVolume,
						volumeModifier,
						p2.KeyCode,
						false,
						GetCurrentSoundEffectsState(),
						LocalPlayer.UserId
					)

					if not PianoPractice.Active then
						Logic_Recording.RecordNotePress(v52, Velocity, 0, sustainPacket)
					end

					MarkPianoActivity()
					PianoRoll2DHandler.OnNotePlayed(v52)
					PianoSimVPNotes.Fire(PianoSimVPNotes.GetChar(v52), v52)

					if not PianoPractice.Active then
						NPSCounter.RecordNote()
					end

					if not PianoPractice.Active then
						PianoPackets.NoteSimple:Fire(
							v52,
							Velocity,
							v30,
							sustainPacket,
							p2.KeyCode and p2.KeyCode.Value or 0,
							v52 + KEY_OFFSET,
							true,
							current_SoundfontID,
							Transposition,
							v53,
							"Ctrl"
						)
					end

					v21[p2.KeyCode] = v52
					v22[p2.KeyCode] = Transposition
					v23[p2.KeyCode] = v53
					v24[p2.KeyCode] = "Ctrl"
					Logic_UI.PlayNote(GetActiveKeysFrame(), v52) -- inferred equivalent call

					startVisualization(v52, v50)

					visualSettingHelpers.AnimatePianoModelKey(
						v50,
						v52 + KEY_OFFSET,
						true,
						LocalPlayer,
						Transposition,
						v53,
						"Ctrl"
					)
					PianoSimRunCustomVisualEffect(v50, v52, true, LocalPlayer)
					PianoPractice.RunNearbyIceFishingEffect(v52, true)
				else
					Logic_Piano[packetType](
						v49,
						assetIds,
						offset,
						maxLifetime,
						fadeout,
						v30,
						packetType,
						sustainPacket,
						above88KeyPacket,
						Velocity,
						LocalVolume,
						volumeModifier,
						p2.KeyCode,
						false,
						GetCurrentSoundEffectsState(),
						LocalPlayer.UserId
					)

					if not PianoPractice.Active then
						Logic_Recording.RecordNotePress(v49, Velocity, 0, sustainPacket)
					end

					MarkPianoActivity()
					PianoRoll2DHandler.OnQwertyPlayed(lower, v49)
					PianoSimVPNotes.Fire(PianoSimVPNotes.GetChar(v49) or lower, v49)

					if not PianoPractice.Active then
						NPSCounter.RecordNote()
					end

					if not PianoPractice.Active then
						PianoPackets.NoteSimple:Fire(
							v49,
							Velocity,
							v30,
							sustainPacket,
							p2.KeyCode and p2.KeyCode.Value or 0,
							v49 + KEY_OFFSET,
							true,
							current_SoundfontID,
							Transposition
						)
					end

					v21[p2.KeyCode] = v49
					v22[p2.KeyCode] = Transposition
					Logic_UI.PlayNote(GetActiveKeysFrame(), v49) -- inferred equivalent call

					startVisualization(v49, currentPianoModel)

					visualSettingHelpers.AnimatePianoModelKey(v50, v49 + KEY_OFFSET, true, LocalPlayer, Transposition)
					PianoSimRunCustomVisualEffect(v50, v49, true, LocalPlayer)
					PianoPractice.RunNearbyIceFishingEffect(v49, true)
				end
			elseif p == Enum.UserInputState.End then
				v25[p2.KeyCode] = nil

				Logic_Piano.FinishNonSustainNote(p2.KeyCode, fadeout)

				local v51 = v21[p2.KeyCode]
				local v52 = v22[p2.KeyCode] or Transposition
				local v53 = v23[p2.KeyCode]
				local v54 = v24[p2.KeyCode]

				if v51 then
					if not PianoPractice.Active then
						PianoPackets.NoteSimple:Fire(
							v51,
							Velocity,
							v30,
							sustainPacket,
							p2.KeyCode and p2.KeyCode.Value or 0,
							v51 + KEY_OFFSET,
							false,
							current_SoundfontID,
							v52,
							v53,
							v54
						)

						Logic_Recording.RecordNoteRelease(v51, Velocity, 0, sustainPacket)
					end

					PianoRoll2DHandler.OnNoteReleased(v51)
				end

				if sustainPacket == false then
					Logic_Piano.FadeoutAllSustainedNotes(fadeout)

					if not PianoPractice.Active then
						PianoPackets.FinishNonSustainedNotes:Fire(fadeout)
					end
				end

				Logic_UI.FinishNote(GetActiveKeysFrame(), v21[p2.KeyCode]) -- inferred equivalent call

				if v51 then
					endVisualization(v51, currentPianoModel)
				end

				if v51 then
					visualSettingHelpers.AnimatePianoModelKey(v50, v51 + KEY_OFFSET, false, LocalPlayer, v52, v53, v54)
					PianoSimRunCustomVisualEffect(v50, v51, false, LocalPlayer)
				end

				v21[p2.KeyCode] = nil
				v22[p2.KeyCode] = nil
				v23[p2.KeyCode] = nil
				v24[p2.KeyCode] = nil
			end
		end
	end

	local function SustainAction(_, p, p2)
		if p2 and v19[p2.KeyCode] then
			if p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
				v19[p2.KeyCode] = nil
			end

			return Enum.ContextActionResult.Sink
		else
			local current_SoundfontID = Dependence_PlayerVariables.Current_SoundfontID
			local fadeout = Dependence_Soundfonts[current_SoundfontID].Fadeout

			if p == Enum.UserInputState.Begin then
				sustainPacket = not sustainPacket

				if not PianoPractice.Active then
					Logic_Recording.RecordSustainToggle(sustainPacket)
				end

				Logic_Piano.UpdateSustainState(sustainPacket, fadeout)

				if not PianoPractice.Active then
					if sustainPacket then
						PianoPackets.SustainRelease:Fire("__PianoSustainOn", fadeout)
					else
						PianoPackets.FinishNonSustainedNotes:Fire(fadeout)
					end
				end

				UpdateSustainDisplay()
			elseif p == Enum.UserInputState.End then
				sustainPacket = not sustainPacket

				if not PianoPractice.Active then
					Logic_Recording.RecordSustainToggle(sustainPacket)
				end

				Logic_Piano.UpdateSustainState(sustainPacket, fadeout)

				if not PianoPractice.Active then
					if sustainPacket then
						PianoPackets.SustainRelease:Fire("__PianoSustainOn", fadeout)
					else
						PianoPackets.FinishNonSustainedNotes:Fire(fadeout)
					end
				end

				UpdateSustainDisplay()
			end
		end
	end

	local function VelocityAction(_, p, _)
		if p == Enum.UserInputState.Begin then
			v18 = true
		elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			v18 = false
		end
	end

	local function Above88KeyAction(_, p, _)
		if p == Enum.UserInputState.Begin then
			above88KeyPacket = true
		elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			above88KeyPacket = false
		end
	end

	local function ShiftAction(_, p, p2)
		if p == Enum.UserInputState.Begin then
			ShiftTransposeHeldKeys[p2.KeyCode] = true
		elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
			ShiftTransposeHeldKeys[p2.KeyCode] = nil
		end

		ShiftTransposeHeld = next(ShiftTransposeHeldKeys) ~= nil
		UpdateTranspositionDisplay() -- inferred equivalent call
	end

	local function TransposeUpAction(_, p)
		if p == Enum.UserInputState.Begin then
			Transposition = Logic_Piano.Transpose(1, Transposition)
			UpdateTranspositionDisplay() -- inferred equivalent call
		end
	end

	local function TransposeDownAction(_, p)
		if p == Enum.UserInputState.Begin then
			Transposition = Logic_Piano.Transpose(-1, Transposition)
			UpdateTranspositionDisplay() -- inferred equivalent call
		end
	end

	local function VolumeUpAction(_, p)
		if p == Enum.UserInputState.Begin then
			LocalVolume = Logic_Piano.Volume(10, LocalVolume)
			Dependence_PlayerVariables.Current_Volume = LocalVolume
			UpdateVolumeDisplay() -- inferred equivalent call
		end
	end

	local function VolumeDownAction(_, p)
		if p == Enum.UserInputState.Begin then
			LocalVolume = Logic_Piano.Volume(-10, LocalVolume)
			Dependence_PlayerVariables.Current_Volume = LocalVolume
			UpdateVolumeDisplay() -- inferred equivalent call
		end
	end

	local v29 = {}
	local v30 = {}
	local v31 = {}
	local v32 = {}
	local v47 = {}
	local v48 = {}
	local v49 = {}
	local v50 = {}

	local function GetUIAbove88Visual(p)
		local v51 = tonumber(p)

		if not v51 then
			return nil, nil
		end

		for k, piano88KeyCode in pairs(Logic_Keymap.Piano88KeyCodes) do
			if piano88KeyCode == v51 and k <= 27 then
				return ("trewq0987654321yuiopasdfghj"):sub(k, k), "Ctrl"
			end
		end

		return nil, nil
	end

	local nows = {}

	local v51 = false
	BroadcastPlaybackToSpectators = true

	local heartbeatConnection = nil
	local heartbeatConnection2 = nil
	local vizColorChangedConnection = nil

	local fn4

	local function fn5(p, value2, value3, p2, p3)
		local v52 = Velocity

		if typeof(value2) == "number" then
			v52 = math.clamp(math.floor(value2), 0, 100)
			value2 = nil
		end

		local v53 = typeof(p2) == "boolean" and p2 or sustainPacket

		if v29[p] then
			fn4(p, nil)
		end

		if visible2 and not v51 then
			local now = tick()

			if now - (nows[p] or 0) < 0.05 then
				return
			end

			nows[p] = now
		end

		local current_SoundfontID = Dependence_PlayerVariables.Current_SoundfontID
		local dependence_Soundfont = Dependence_Soundfonts[current_SoundfontID]
		PrewarmCurrentSoundfont(current_SoundfontID)

		local assetIds = dependence_Soundfont.AssetIds
		local offset = dependence_Soundfont.Offset
		local maxLifetime = dependence_Soundfont.MaxLifetime
		local fadeout = dependence_Soundfont.Fadeout
		local volumeModifier = dependence_Soundfont.VolumeModifier
		local packetType = dependence_Soundfont.PacketType

		local v54 = humanoid and humanoid.SeatPart and getPianoModel(humanoid.SeatPart)

		if not PianoSimCanPlayForCompetitionTurn(v54) then
			return
		end

		if v54 and v54:FindFirstChild("Scripts") then
			v54.Scripts:FindFirstChild("PianoModule")
		end

		local v55 = p + ((typeof)(value3) == "number" and value3 or Transposition)
		local v56, v57

		if not v51 then
			v56, v57 = GetUIAbove88Visual(p)
		end

		v49[p] = v55
		local v58 = p3 == "MidiPlayer"
		local v59 = -p

		if v51 then
			v59 = -100000 - p
		end

		if v58 then
			v59 = -200000 - p
		end

		v50[p] = v59
		Logic_Piano[packetType](
			v55,
			assetIds,
			offset,
			maxLifetime,
			fadeout,
			0,
			packetType,
			v53,
			above88KeyPacket,
			v52,
			LocalVolume,
			volumeModifier,
			v59,
			false,
			GetCurrentSoundEffectsState(),
			LocalPlayer.UserId
		)

		Logic_UI.PlayNote(GetActiveKeysFrame(), p) -- inferred equivalent call

		if not v51 then
			MarkPianoActivity()
			PianoRoll2DHandler.OnNotePlayed(p)
			PianoSimVPNotes.Fire(PianoSimVPNotes.GetChar(p), p)

			if not PianoPractice.Active then
				NPSCounter.RecordNote()
			end
		end

		startVisualization(p, currentPianoModel)

		visualSettingHelpers.AnimatePianoModelKey(v54, p + KEY_OFFSET, true, LocalPlayer, 0, v56, v57)
		PianoSimRunCustomVisualEffect(v54 or currentPianoModel, v55, true, LocalPlayer)
		PianoPractice.RunNearbyIceFishingEffect(v55, true)

		if not (v51 or PianoPractice.Active) then
			Logic_Recording.RecordNotePress(v55, v52, 0, v53)
		end

		if
			not PianoPractice.Active
			and (BroadcastPlaybackToSpectators or type(v59) ~= "number" or not (v59 <= -90000))
		then
			PianoPackets.NoteSimple:Fire(v55, v52, 0, v53, v59, p + KEY_OFFSET, true, current_SoundfontID, 0, v56, v57)
		end

		if value2 and pcall(function()
			return value2.UserInputType
		end) then
			if not v30[p] then
				v30[p] = {}
			end

			local success, result = pcall(function()
				return value2.UserInputType
			end)

			if success then
				local v60 = result == Enum.UserInputType.Touch and tostring(value2) or "mouse"
				v30[p][v60] = true
			end
		end

		v29[p] = true
		v48[p] = tick()

		if v47[p] then
			task.cancel(v47[p])
			v47[p] = nil
		end

		if not v51 then
			v47[p] = task.delay(10, function()
				if v29[p] then
					v.Print("[PianoMain] Force-releasing stuck note:", p)
					fn4(p, nil)
				end
			end)
		end
	end

	fn4 = function(p, p2)
		if not v29[p] then
			return
		end

		if p2 and v30[p] then
			local success, result = pcall(function()
				return p2.UserInputType
			end)

			if success then
				local v52 = result == Enum.UserInputType.Touch and tostring(p2) or "mouse"
				v30[p][v52] = nil

				local flag2 = false

				for _, _ in pairs(v30[p]) do
					flag2 = true
					break
				end

				if flag2 then
					return
				end
			end
		end

		local current_SoundfontID = Dependence_PlayerVariables.Current_SoundfontID
		local fadeout = Dependence_Soundfonts[current_SoundfontID].Fadeout

		local v52 = humanoid and humanoid.SeatPart and getPianoModel(humanoid.SeatPart)

		if v52 and v52:FindFirstChild("Scripts") then
			v52.Scripts:FindFirstChild("PianoModule")
		end

		local v53 = v49[p] or p + Transposition
		local v54, v55

		if not v51 then
			v54, v55 = GetUIAbove88Visual(p)
		end

		local v56 = v50[p] or -p
		Logic_Piano.FinishNonSustainNote(v56, fadeout)

		Logic_UI.FinishNote(GetActiveKeysFrame(), p) -- inferred equivalent call

		endVisualization(p, currentPianoModel)

		visualSettingHelpers.AnimatePianoModelKey(v52, p + KEY_OFFSET, false, LocalPlayer, 0, v54, v55)
		PianoSimRunCustomVisualEffect(v52 or currentPianoModel, v53, false, LocalPlayer)

		if
			not PianoPractice.Active
			and (BroadcastPlaybackToSpectators or type(v56) ~= "number" or not (v56 <= -90000))
		then
			PianoPackets.NoteSimple:Fire(
				v53,
				Velocity,
				0,
				sustainPacket,
				v56,
				p + KEY_OFFSET,
				false,
				current_SoundfontID,
				0,
				v54,
				v55
			)
		end

		if not (v51 or PianoPractice.Active) then
			Logic_Recording.RecordNoteRelease(v53, Velocity, 0, sustainPacket)
		end

		v29[p] = nil
		v30[p] = nil
		v48[p] = nil
		v49[p] = nil
		v50[p] = nil

		if v47[p] then
			task.cancel(v47[p])
			v47[p] = nil
		end
	end

	local activatedConnection = nil
	local heartbeatConnection3 = nil
	_PianoIdleConnection = nil
	_PianoIdleCheckElapsed = 0
	PIANO_IDLE_EJECT_SECONDS = 300
	LastPianoActivityTime = 0

	function MarkPianoActivity()
		LastPianoActivityTime = tick()
	end

	function StopPianoIdleWatcher()
		if _PianoIdleConnection then
			_PianoIdleConnection:Disconnect()
			_PianoIdleConnection = nil
		end

		_PianoIdleCheckElapsed = 0
	end

	function StartPianoIdleWatcher()
		StopPianoIdleWatcher()
		MarkPianoActivity()
		_PianoIdleConnection = RunService.Heartbeat:Connect(function(dt)
			_PianoIdleCheckElapsed += dt

			if _PianoIdleCheckElapsed < 1 then
				return
			end

			_PianoIdleCheckElapsed = 0

			if
				currentPianoModel
				and IsPianoControlsVisible() -- inferred equivalent call
				and tick() - LastPianoActivityTime >= PIANO_IDLE_EJECT_SECONDS
			then
				v.Warn("[PianoMain] Ejected from piano for being afk")
				StopPianoIdleWatcher()
				task.defer(function()
					UnbindPiano("idle")
				end)
			end
		end)
	end

	function UnbindPianoActionKeys()
		ContextActionService:UnbindAction("PianoAction")
		ContextActionService:UnbindAction("ShiftCheck")
		ContextActionService:UnbindAction("AltCheck")
		ContextActionService:UnbindAction("ControlCheck")
		ContextActionService:UnbindAction("TranspositionCheck")
		ContextActionService:UnbindAction("TransposeUpCheck")
		ContextActionService:UnbindAction("TransposeDownCheck")
		ContextActionService:UnbindAction("SustainCheck")
		ContextActionService:UnbindAction("ExitCheck")
		ContextActionService:UnbindAction("ManualModeAction")
		ContextActionService:UnbindAction("VolumeCheck")
		ContextActionService:UnbindAction("VolumeUpCheck")
		ContextActionService:UnbindAction("VolumeDownCheck")
		ClearPianoModifierState() -- inferred equivalent call
		v19 = {}
		PianoActionBindingsActive = false
	end

	function ExitPianoAction(_, p)
		if p == Enum.UserInputState.Begin then
			task.defer(function()
				if PianoPractice.Active and PianoPractice.End then
					PianoPractice.End("exit-key")
				else
					UnbindPiano("exit-key")
				end
			end)
		end

		return Enum.ContextActionResult.Sink
	end

	function BindPianoActionKeys()
		UnbindPianoActionKeys()
		local v52 = GetPianoActionKeyList("ShiftTranspose")
		local v53 = GetPianoActionKeyList("Sustain")
		v19 = {}

		for _, v54 in ipairs(v53) do
			if UserInputService:IsKeyDown(v54) then
				v19[v54] = true
			end
		end

		if not table.find(v52, Enum.KeyCode.LeftShift) then
			table.insert(v52, Enum.KeyCode.LeftShift)
		end

		if not table.find(v52, Enum.KeyCode.RightShift) then
			table.insert(v52, Enum.KeyCode.RightShift)
		end

		ContextActionService:BindAction("ShiftCheck", ShiftAction, false, table.unpack(v52))
		ContextActionService:BindAction("AltCheck", VelocityAction, false, GetPianoActionKeys("VelocityModifier"))
		ContextActionService:BindAction("ControlCheck", Above88KeyAction, false, GetPianoActionKeys("Above88Modifier"))
		ContextActionService:BindAction("TransposeUpCheck", TransposeUpAction, false, GetPianoActionKeys("TransposeUp"))
		ContextActionService:BindAction(
			"TransposeDownCheck",
			TransposeDownAction,
			false,
			GetPianoActionKeys("TransposeDown")
		)
		ContextActionService:BindAction("SustainCheck", SustainAction, false, table.unpack(v53))
		ContextActionService:BindAction("ExitCheck", ExitPianoAction, false, GetPianoActionKeys("ExitPiano"))
		ContextActionService:BindAction("VolumeUpCheck", VolumeUpAction, false, GetPianoActionKeys("VolumeUp"))
		ContextActionService:BindAction("VolumeDownCheck", VolumeDownAction, false, GetPianoActionKeys("VolumeDown"))
		ContextActionService:BindActionAtPriority(
			"PianoAction",
			ProcessPianoAction,
			false,
			3000,
			Logic_Keymap.PianoKeyCodes()
		)

		if AutoPlayerHandler.SetManualModeKeybinds then
			AutoPlayerHandler.SetManualModeKeybinds(GetPianoActionKeyList(
				"ManualAuto1",
				"ManualAuto2",
				"ManualAuto3",
				"ManualAuto4"
			))
		end

		ContextActionService:BindAction(
			"ManualModeAction",
			AutoPlayerHandler.ManualModeAction,
			false,
			GetPianoActionKeys("ManualAuto1", "ManualAuto2", "ManualAuto3", "ManualAuto4")
		)

		PianoActionBindingsActive = true
	end

	local function ApplyMovementLock()
		if not humanoid then
			return
		end

		if not PianoPractice.Movement then
			PianoPractice.Movement = {
				WalkSpeed = humanoid.WalkSpeed,
				JumpPower = humanoid.JumpPower,
				JumpHeight = humanoid.JumpHeight,
				AutoRotate = humanoid.AutoRotate,
				TouchControls = GuiService.TouchControlsEnabled
			}

			pcall(function()
				PianoPractice.Movement.JumpingEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)
			end)
			pcall(function()
				local movement = PianoPractice.Movement
				local PlayerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
				movement.Controls = PlayerModule:GetControls()
			end)
		end

		pcall(function()
			if PianoPractice.Movement.Controls then
				PianoPractice.Movement.Controls:Disable()
			end
		end)
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
		humanoid.AutoRotate = false
		pcall(function()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end)
		GuiService.TouchControlsEnabled = false
	end

	PianoPractice.ApplyMovementLock = ApplyMovementLock

	local function ReleaseMovementLock()
		if not PianoPractice.Movement then
			return
		end

		pcall(function()
			if PianoPractice.Movement.Controls then
				PianoPractice.Movement.Controls:Enable()
			end
		end)

		if humanoid then
			humanoid.WalkSpeed = PianoPractice.Movement.WalkSpeed or 16
			humanoid.JumpPower = PianoPractice.Movement.JumpPower or 50
			humanoid.JumpHeight = PianoPractice.Movement.JumpHeight or 7.2
			humanoid.AutoRotate = PianoPractice.Movement.AutoRotate ~= false
			pcall(function()
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, PianoPractice.Movement.JumpingEnabled ~= false)
			end)
		end

		if PianoPractice.Movement.TouchControls ~= nil then
			GuiService.TouchControlsEnabled = PianoPractice.Movement.TouchControls
		end

		PianoPractice.Movement = nil
	end

	PianoPractice.ReleaseMovementLock = ReleaseMovementLock

	local function ResetNoteState()
		for _, v52 in pairs(v47) do
			task.cancel(v52)
		end

		v29 = {}
		v30 = {}
		v31 = {}
		v32 = {}
		v47 = {}
		v48 = {}
		v49 = {}
		v50 = {}
		v21 = {}
		v22 = {}
		v23 = {}
		v24 = {}
		v25 = {}
		nows = {}
	end

	PianoPractice.ResetNoteState = ResetNoteState

	local function ReleaseHeldNotes()
		local current_SoundfontID = Dependence_PlayerVariables.Current_SoundfontID
		local dependence_Soundfont = Dependence_Soundfonts[current_SoundfontID]
		local fadeout = dependence_Soundfont and dependence_Soundfont.Fadeout or 0.25

		while next(v29) do
			local v52 = next(v29)
			fn4(v52, nil)
		end

		while next(v21) do
			local v52, v53 = next(v21)
			Logic_Piano.FinishNonSustainNote(v52, fadeout)
			PianoRoll2DHandler.OnNoteReleased(v53)
			v21[v52] = nil
			v22[v52] = nil
			v23[v52] = nil
			v24[v52] = nil
		end

		Logic_Piano.FadeoutAllSustainedNotes(fadeout)
	end

	PianoPractice.ReleaseHeldNotes = ReleaseHeldNotes

	function PianoPractice.SyncIcon(p)
		if not PianoPractice.Icon or PianoPractice.Syncing then
			return
		end

		PianoPractice.Syncing = true
		pcall(function()
			if p then
				PianoPractice.Icon:select()
			else
				PianoPractice.Icon:deselect()
			end
		end)
		PianoPractice.Syncing = false
	end

	local function Begin()
		if PianoPractice.Active then
			return
		end

		if flag then
			UnbindPiano("practice-mode")
		end

		if humanoid then
			humanoid.Sit = false
		end

		PianoPractice.Active = true
		LocalPlayer:SetAttribute("PianoPracticeModeActive", true)
		currentPianoModel = nil
		v26 = 0
		viewingPianoModel = nil
		PianoPractice.ClearPianoCameraCycle()
		StopPianoIdleWatcher()
		SetPianoVisibility(true)
		ClearAllPianoKeyHighlights()
		UpdateVolumeDisplay() -- inferred equivalent call
		UpdateTranspositionDisplay() -- inferred equivalent call
		UpdateSustainDisplay()
		UpdateCapsDisplay()
		PrewarmCurrentSoundfont()
		PianoPractice.ResetNoteState()
		cleanupPianoVisualizations(nil) -- inferred equivalent call
		NPSCounter.Reset()
		PianoPractice.ApplyMovementLock()

		if activatedConnection then
			activatedConnection:Disconnect()
			activatedConnection = nil
		end

		local exitButton = visible2 and MobileBurgerPanel and MobileBurgerPanel:FindFirstChild("ExitButton")
			or visible2 and optionFrame and optionFrame:FindFirstChild("Mobiler")
			or PianoContainer:FindFirstChild("Mobiler")

		if exitButton then
			activatedConnection = exitButton.Activated:Connect(function()
				PianoPractice.End("exit-button")
			end)
		end

		BindPianoActionKeys()
		PianoPractice.SyncIcon(true)
	end

	PianoPractice.Begin = Begin

	local function End(value2)
		if not PianoPractice.Active then
			return
		end

		v.Print("[PianoMain] Ending piano practice. Reason: " .. tostring(value2 or "unknown"))
		PianoPractice.ReleaseHeldNotes()
		AutoPlayerHandler.Stop()
		PianoRoll2DHandler.Hide()
		MidiPlayerHandler.Stop()
		PianoPractice.ReleaseHeldNotes()
		SetPianoVisibility(false)
		UnbindPianoActionKeys()

		if activatedConnection then
			activatedConnection:Disconnect()
			activatedConnection = nil
		end

		PianoPractice.ReleaseMovementLock()
		PianoPractice.ResetNoteState()
		cleanupPianoVisualizations(nil) -- inferred equivalent call
		ClearAllPianoKeyHighlights()
		NPSCounter.Reset()
		currentPianoModel = nil
		v26 = 0
		viewingPianoModel = nil
		PianoPractice.ClearPianoCameraCycle()
		PianoPractice.Active = false
		LocalPlayer:SetAttribute("PianoPracticeModeActive", false)
		PianoPractice.SyncIcon(false)
	end

	PianoPractice.End = End

	function BindPiano(p)
		local pianoModel = getPianoModel(p)

		if not pianoModel then
			return
		end

		flag = true

		SetPianoVisibility(true)
		pcall(function()
			LocalPianoSessionStateChanged:Fire(true, pianoModel)
		end)
		StartPianoIdleWatcher()

		ToolVisibilityController.Hide(humanoid)

		if value then
			local indicator = nps:FindFirstChild("Indicator")
			NPSCounter.Initialize(value, indicator and indicator:FindFirstChild("Fill"))

			if not heartbeatConnection3 then
				heartbeatConnection3 = RunService.Heartbeat:Connect(function()
					NPSCounter.Update()

					local nps3 = NPSCounter.GetNPS()

					if NPSCounter.MAX_NPS < nps3 then
						v.Warn("[Anti-Cheat] Player exceeded " .. NPSCounter.MAX_NPS .. " NPS limit (" .. nps3 .. " NPS), kicking from piano")

						if heartbeatConnection3 then
							heartbeatConnection3:Disconnect()
							heartbeatConnection3 = nil
						end

						task.spawn(function()
							UnbindPiano("nps-limit")
						end)
					end
				end)
			end
		end

		ClearAllPianoKeyHighlights()
		UpdateVolumeDisplay() -- inferred equivalent call
		task.defer(SyncPerformerVolume)
		UpdateTranspositionDisplay() -- inferred equivalent call
		UpdateSustainDisplay()
		PrewarmCurrentSoundfont()

		v21 = {}
		v22 = {}
		v23 = {}
		v24 = {}
		v25 = {}
		v29 = {}
		v30 = {}
		v31 = {}
		v32 = {}
		v48 = {}
		v49 = {}
		v50 = {}
		cleanupPianoVisualizations(nil) -- inferred equivalent call

		if p then
			currentPianoModel = pianoModel
			v26 = pianoModel and pianoModel:GetAttribute("SessionId") or 0
			viewingPianoModel = nil

			if pianoModel then
				local vizColor = pianoModel:GetAttribute("VizColor")

				if vizColor and typeof(vizColor) == "Color3" then
					PianoVisualization.SetVisualizerColor(vizColor, pianoModel)
				end

				if vizColorChangedConnection then
					vizColorChangedConnection:Disconnect()
					vizColorChangedConnection = nil
				end

				vizColorChangedConnection = pianoModel:GetAttributeChangedSignal("VizColor"):Connect(function()
					local vizColor2 = pianoModel:GetAttribute("VizColor")

					if vizColor2 and typeof(vizColor2) == "Color3" then
						PianoVisualization.SetVisualizerColor(vizColor2, pianoModel)
					end
				end)
			end
		end

		if humanoid then
			Logic_Character.AddCamera(humanoid)
			PianoPractice.InitializePianoCameraCycle(pianoModel)

			if humanoid then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			end
		end

		if not heartbeatConnection then
			local RunService = game:GetService("RunService")
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local now = tick()

				for k, _ in pairs(v29) do
					local v52 = v48[k] or now

					if v51 or not (now - v52 > 3) then
						continue
					end

					v.Warn("[PianoMain] Auto-releasing stuck note:", k, "stuck for", math.floor(now - v52), "seconds")

					fn4(k, nil)
				end
			end)
		end

		if not heartbeatConnection2 then
			local v52 = tick()
			local RunService = game:GetService("RunService")
			heartbeatConnection2 = RunService.Heartbeat:Connect(function()
				local now = tick()

				if now - v52 >= 2 then
					if not v51 then
						Logic_UI.CleanupStuckNotes(KeysFrame, 5)
					end

					v52 = now
				end
			end)
		end

		if visible2 then
			GuiService.TouchControlsEnabled = false
		end

		local exitButton = visible2 and MobileBurgerPanel and MobileBurgerPanel:FindFirstChild("ExitButton")
			or visible2 and optionFrame and optionFrame:FindFirstChild("Mobiler")
			or PianoContainer:FindFirstChild("Mobiler")

		if exitButton then
			if activatedConnection then
				activatedConnection:Disconnect()
			end

			activatedConnection = exitButton.Activated:Connect(function()
				UnbindPiano("exit-button")
			end)
		end

		BindPianoActionKeys()

		local pianoSession = Folder_Remotes:FindFirstChild("PianoSession")

		if pianoSession then
			pianoSession:FireServer("Start")
		end
	end

	function UnbindPiano(value2)
		if not (flag or currentPianoModel or PianoVisibilityTargetVisible) and not IsPianoControlsVisible() then -- inferred equivalent call
			return
		end

		flag = false
		v.Print("[PianoMain] Un-binding piano actions. Reason: " .. tostring(value2 or "unknown"))
		StopPianoIdleWatcher()

		SetPianoVisibility(false)
		pcall(function()
			LocalPianoSessionStateChanged:Fire(false, value2)
		end)

		local pianoSession = Folder_Remotes:FindFirstChild("PianoSession")

		if pianoSession then
			pianoSession:FireServer("End")
		end

		local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

		local guiObject3 = findDirectPanel(PianoUI, "Sheets") or findDirectPanel(mobilePanelHost, "Sheets")

		if guiObject3 and guiObject3:IsA("GuiObject") then
			guiObject3.Visible = false
		end

		ToolVisibilityController.Restore()
		cleanupPianoVisualizations(nil) -- inferred equivalent call

		if currentPianoModel then
			local scripts = currentPianoModel:FindFirstChild("Scripts")
			local pianoModule = scripts and scripts:FindFirstChild("PianoModule")

			if pianoModule then
				local success, result = pcall(function()
					local module = require(pianoModule)

					if module.ForceReleaseAllKeys then
						module.ForceReleaseAllKeys()
					end
				end)

				if not success then
					v.Warn("[PianoMain] Failed to force release keys:", result)
				end
			end
		end

		currentPianoModel = nil
		v26 = 0
		viewingPianoModel = nil
		PianoPractice.ClearPianoCameraCycle()
		v.Print("[PianoMain] Cleared all visualizations, piano model reference, and session")

		if v2 then
			pcall(function()
				HandIK.OnLeave(v2)
			end)
		end

		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end

		UnbindPianoActionKeys()

		if activatedConnection then
			activatedConnection:Disconnect()
			activatedConnection = nil
		end

		if visible2 then
			GuiService.TouchControlsEnabled = true
		end

		if humanoid then
			humanoid.Sit = false
		end

		task.wait(0.1)
		Logic_Character.RevokeCamera()
		ClearAllPianoKeyHighlights()

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		if heartbeatConnection2 then
			heartbeatConnection2:Disconnect()
			heartbeatConnection2 = nil
		end

		if vizColorChangedConnection then
			vizColorChangedConnection:Disconnect()
			vizColorChangedConnection = nil
		end

		if heartbeatConnection3 then
			heartbeatConnection3:Disconnect()
			heartbeatConnection3 = nil
		end

		NPSCounter.Reset()

		for _, v52 in pairs(v47) do
			task.cancel(v52)
		end

		v29 = {}
		v30 = {}
		v47 = {}
		v48 = {}
		v49 = {}
		v50 = {}
		v21 = {}
		v22 = {}
		v23 = {}
		v24 = {}
		v25 = {}
		nows = {}

		AutoPlayerHandler.Stop()
		PianoRoll2DHandler.Hide()

		MidiPlayerHandler.Stop()

		local currentPlayback = RecordingUIHandler and RecordingUIHandler.CurrentPlayback

		if currentPlayback then
			if currentPlayback.Stop then
				currentPlayback:Stop()
			end

			RecordingUIHandler.CurrentPlayback = nil

			v51 = false

			if RecordingUIHandler and RecordingUIHandler.HidePlaybackOverhead then
				RecordingUIHandler.HidePlaybackOverhead()
			end

			local playRecord = OptionFrame:FindFirstChild("PlayRecord")

			if playRecord then
				playRecord.Text = "Play/Pause"
				playRecord.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
			end

			v.Print("[Recording] Playback stopped (player left piano)")
		end

		if Logic_Recording and Logic_Recording.IsRecording then
			Logic_Recording.StopRecording()
			local record = OptionFrame:FindFirstChild("Record")

			if record then
				record.Text = "Record"
				record.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
			end

			if RecordingUIHandler and RecordingUIHandler.HideOverhead then
				RecordingUIHandler.HideOverhead()
			end

			v.Print("[Recording] Recording stopped (player left piano)")
		end
	end

	local function playClickSound() -- 18 equivalent calls inferred from this helper
		if clickSound then
			clickSound:Play()
		end
	end

	local function connectGuiButton(button2, onActivated) -- 27 equivalent calls inferred from this helper
		if button2 and onActivated and button2:IsA("GuiButton") then
			button2.Activated:Connect(onActivated)
		end
	end

	function MobileOctaveScroller.IsPointer(p): boolean
		return p.UserInputType == Enum.UserInputType.Touch or p.UserInputType == Enum.UserInputType.MouseButton1
	end

	function MobileOctaveScroller.Bind()
		local track = MobileOctaveScroller.GetTrack()

		if
			not (track and MobileOctaveScroller.Head and MobileOctaveScroller.Head:IsA("GuiObject"))
			or MobileOctaveScroller.Head:GetAttribute("MobileOctaveScrollerBound")
		then
			return
		end

		MobileOctaveScroller.Head:SetAttribute("MobileOctaveScrollerBound", true)

		track.Active = false
		MobileOctaveScroller.Head.Active = true

		for _, guiObject3 in ipairs({ MobileOctaveScroller.LeftArrow, MobileOctaveScroller.RightArrow }) do
			if not (guiObject3 and guiObject3:IsA("GuiObject")) then
				continue
			end

			guiObject3.Active = false
			guiObject3.Selectable = false
			pcall(function()
				guiObject3.Interactable = false
			end)
		end

		MobileOctaveScroller.Dragging = false
		MobileOctaveScroller.Head.InputBegan:Connect(function(input)
			if MobileOctaveScroller.IsPointer(input) and MobileOctaveScroller.IsInputOnHead(input) then
				MobileOctaveScroller.Dragging = true
				MobileOctaveScroller.HeadDragOffsetX = math.clamp(
					input.Position.X - MobileOctaveScroller.Head.AbsolutePosition.X,
					0,
					MobileOctaveScroller.Head.AbsoluteSize.X
				)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if MobileOctaveScroller.IsPointer(input) then
				MobileOctaveScroller.Dragging = false
				MobileOctaveScroller.HeadDragOffsetX = nil
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if
				MobileOctaveScroller.Dragging
				and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement)
			then
				MobileOctaveScroller.SetScrollFromHeadDrag(input.Position.X, false)
			end
		end)
		local mobileKeysFrame = getMobileKeysFrame() -- inferred equivalent call

		if mobileKeysFrame and mobileKeysFrame:IsA("ScrollingFrame") then
			mobileKeysFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				MobileOctaveScroller.Update()
			end)
		end

		MobileOctaveScroller.Update()
	end

	local function bindMobileManualAutoButton()
		if not (MobileManualAutoButton and MobileManualAutoButton:IsA("GuiButton")) then
			return
		end

		local flag2 = false
		local backgroundColor3 = MobileManualAutoButton.BackgroundColor3
		local color = Color3.fromRGB(52, 119, 228)

		local function isManualTriggerInput(p): boolean -- 2 equivalent calls inferred from this helper
			return p == nil
				or p.UserInputType == Enum.UserInputType.Touch
				or p.UserInputType == Enum.UserInputType.MouseButton1
		end

		local function beginManualTrigger(p)
			if not isManualTriggerInput(p) or flag2 then -- inferred equivalent call
				return
			end

			flag2 = true
			MobileManualAutoButton.BackgroundColor3 = color

			if not (AutoPlayerHandler.MobileManualTrigger and AutoPlayerHandler.MobileManualTrigger(Enum.UserInputState.Begin)) then
				flag2 = false
				MobileManualAutoButton.BackgroundColor3 = backgroundColor3
			end
		end

		local function endManualTrigger(p)
			if not (isManualTriggerInput(p) and flag2) then -- inferred equivalent call
				return
			end

			flag2 = false

			if AutoPlayerHandler.MobileManualTrigger then
				AutoPlayerHandler.MobileManualTrigger(Enum.UserInputState.End)
			end

			if MobileManualAutoButton and MobileManualAutoButton.Parent then
				MobileManualAutoButton.BackgroundColor3 = backgroundColor3
			end
		end

		MobileManualAutoButton.InputBegan:Connect(beginManualTrigger)
		MobileManualAutoButton.InputEnded:Connect(endManualTrigger)
		MobileManualAutoButton.MouseLeave:Connect(function()
			if not flag2 then
				return
			end

			flag2 = false

			if AutoPlayerHandler.MobileManualTrigger then
				AutoPlayerHandler.MobileManualTrigger(Enum.UserInputState.End)
			end

			if MobileManualAutoButton and MobileManualAutoButton.Parent then
				MobileManualAutoButton.BackgroundColor3 = backgroundColor3
			end
		end)
	end

	local function getMobileSliderValueFromInput(p, x, p2, p3) -- 4 equivalent calls inferred from this helper
		if not p then
			return p2
		end

		local v52 = math.max(p.AbsoluteSize.X, 1)
		local v53 = math.clamp((x - p.AbsolutePosition.X) / v52, 0, 1)
		return (math.floor(p2 + (p3 - p2) * v53 + 0.5))
	end

	local function bindMobileKeySizeSlider(track, p, minValue, maxValue, applyValue)
		if not (track and p and applyValue) then
			return
		end

		local function beginDrag(p2)
			if p2.UserInputType ~= Enum.UserInputType.Touch and p2.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			v17 = {
				Track = track,
				MinValue = minValue,
				MaxValue = maxValue,
				ApplyValue = applyValue
			}

			applyValue(getMobileSliderValueFromInput(track, p2.Position.X, minValue, maxValue)) -- inferred equivalent call
		end

		track.InputBegan:Connect(beginDrag)
		p.InputBegan:Connect(beginDrag)
	end

	UserInputService.InputChanged:Connect(function(input)
		if
			not v17
			or input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseMovement
		then
			return
		end

		local v52 = v17
		v52.ApplyValue(getMobileSliderValueFromInput(v52.Track, input.Position.X, v52.MinValue, v52.MaxValue)) -- inferred equivalent call
	end)

	UserInputService.InputEnded:Connect(function(input)
		if
			not v17
			or input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseButton1
		then
			return
		end

		v17 = nil
		Folder_Remotes:WaitForChild("SaveMobilePianoSettings"):FireServer({
			KeyWidth = keyWidth,
			KeyHeight = keyHeight
		})
	end)

	function ToggleSustainFromButton()
		playClickSound() -- inferred equivalent call
		sustainPacket = not sustainPacket

		Logic_Recording.RecordSustainToggle(sustainPacket)

		local current_SoundfontID = Dependence_PlayerVariables.Current_SoundfontID
		local dependence_Soundfont = Dependence_Soundfonts[current_SoundfontID]
		local fadeout = dependence_Soundfont and dependence_Soundfont.Fadeout or 1
		Logic_Piano.UpdateSustainState(sustainPacket, fadeout)

		if sustainPacket then
			PianoPackets.SustainRelease:Fire("__PianoSustainOn", fadeout)
		else
			PianoPackets.FinishNonSustainedNotes:Fire(fadeout)
		end

		UpdateSustainDisplay()
	end

	function ToggleCapsFromButton()
		playClickSound() -- inferred equivalent call
		CapsShiftLock = not CapsShiftLock
		UpdateCapsDisplay()
		UpdateTranspositionDisplay() -- inferred equivalent call
	end

	function ChangeTransposition(p)
		playClickSound() -- inferred equivalent call
		Transposition = Logic_Piano.Transpose(p, Transposition)
		UpdateTranspositionDisplay() -- inferred equivalent call
	end

	function ChangeVolume(p)
		playClickSound() -- inferred equivalent call
		LocalVolume = Logic_Piano.Volume(p, LocalVolume)
		Dependence_PlayerVariables.Current_Volume = LocalVolume
		UpdateVolumeDisplay() -- inferred equivalent call
	end

	function ToggleSoundfonts()
		playClickSound() -- inferred equivalent call
		local sharedFeatureFrame = findSharedFeatureFrame("Soundfonts") -- inferred equivalent call

		if sharedFeatureFrame then
			Logic_UI.ShowHideFrame(sharedFeatureFrame)
			ApplyMobileFeatureLayouts()
		end
	end

	function ToggleSheets()
		playClickSound() -- inferred equivalent call
		local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

		local v52 = findDirectPanel(PianoUI, "Sheets") or findDirectPanel(mobilePanelHost, "Sheets")

		if v52 then
			Logic_UI.ShowHideFrame(v52)
			ApplyMobileFeatureLayouts()
		end
	end

	function ToggleAutoplayer()
		playClickSound() -- inferred equivalent call
		local sharedFeatureFrame = findSharedFeatureFrame("AutoPlayer") -- inferred equivalent call

		if sharedFeatureFrame then
			Logic_UI.ShowHideFrame(sharedFeatureFrame)
			ApplyMobileFeatureLayouts()
		end
	end

	function HideAutoplayer()
		playClickSound() -- inferred equivalent call
		local sharedFeatureFrame = findSharedFeatureFrame("AutoPlayer") -- inferred equivalent call

		if sharedFeatureFrame then
			sharedFeatureFrame.Visible = false
			ApplyMobileFeatureLayouts()
		end
	end

	function ToggleMidiPlayer()
		playClickSound() -- inferred equivalent call
		local sharedFeatureFrame = findSharedFeatureFrame("MidiModal") -- inferred equivalent call

		if sharedFeatureFrame and sharedFeatureFrame.Visible then
			sharedFeatureFrame.Visible = false
			return
		end

		if MidiPlayerHandler.OpenModal then
			MidiPlayerHandler.OpenModal()
		else
			local sharedFeatureFrame2 = findSharedFeatureFrame("MidiModal") -- inferred equivalent call

			if sharedFeatureFrame2 then
				sharedFeatureFrame2.Visible = true
			end
		end

		local sharedFeatureFrame2 = findSharedFeatureFrame("MidiModal") -- inferred equivalent call

		if sharedFeatureFrame2 and sharedFeatureFrame2.Parent ~= PianoUI then
			sharedFeatureFrame2.Parent = PianoUI
		end

		if visible2 then
			if PianoUI:IsA("ScreenGui") then
				PianoUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			end

			if sharedFeatureFrame2 then
				sharedFeatureFrame2.Parent = PianoUI
				sharedFeatureFrame2.ZIndex = 5200
			end

			ApplyMobilePianoLayout()

			if MidiPlayerHandler.RefreshLayout then
				MidiPlayerHandler.RefreshLayout()
			end
		else
			if PianoUI:IsA("ScreenGui") then
				PianoUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
			end

			setPanelZTree(sharedFeatureFrame2, 6250)
			ApplyMobileFeatureLayouts()
			setPanelZTree(sharedFeatureFrame2, 6250)
		end
	end

	function ToggleCommunitySheets()
		playClickSound() -- inferred equivalent call
		local openCommunitySheets = ReplicatedStorage:FindFirstChild("OpenCommunitySheets")

		if not openCommunitySheets then
			openCommunitySheets = Instance.new("BindableEvent")
			openCommunitySheets.Name = "OpenCommunitySheets"
			openCommunitySheets.Parent = ReplicatedStorage
		end

		if openCommunitySheets:IsA("BindableEvent") then
			openCommunitySheets:Fire()
		end
	end

	function updateMobileScrollDisplay()
		local mobileKeysFrame = getMobileKeysFrame() -- inferred equivalent call

		if mobileKeysFrame and mobileKeysFrame:IsA("ScrollingFrame") then
			mobileKeysFrame.ScrollingEnabled = scrollingEnabled
		end

		if MobileScrollButton and MobileScrollButton:IsA("TextButton") then
			MobileScrollButton.Text = scrollingEnabled and "SCROLL" or "LOCK"
			MobileScrollButton.BackgroundColor3 = scrollingEnabled and Color3.fromRGB(38, 41, 46)
				or Color3.fromRGB(46, 55, 68)
			MobileScrollButton.TextColor3 = scrollingEnabled and Color3.fromRGB(235, 238, 242)
				or Color3.fromRGB(96, 180, 255)
		end
	end

	function ToggleMobileScroll()
		playClickSound() -- inferred equivalent call
		scrollingEnabled = not scrollingEnabled
		updateMobileScrollDisplay()
	end

	function ToggleMobileBurgerMenu()
		playClickSound() -- inferred equivalent call

		if MobileBurgerPanel and MobileBurgerPanel:IsA("GuiObject") then
			local visible = not MobileBurgerPanel.Visible

			if visible then
				fn2()
			end

			MobileBurgerPanel.Visible = visible

			if MobileBurgerPanel.Visible then
				setPanelZTree(MobileBurgerPanel, 2300)
			elseif keySizePanel and keySizePanel:IsA("GuiObject") then
				keySizePanel.Visible = false
			end
		end
	end

	function ToggleMobileKeySizePanel()
		playClickSound() -- inferred equivalent call

		if not (keySizePanel and keySizePanel:IsA("GuiObject")) then
			return
		end

		fn3()
		keySizePanel.Visible = not keySizePanel.Visible

		if keySizePanel.Visible then
			setPanelZTree(keySizePanel, 2300)
		end
	end

	function SetMobilePianoCollapsed(p)
		if not (visible2 and MobilePianoContainer) then
			return
		end

		if v5 then
			v5:Cancel()
			v5 = nil
		end

		if v6 then
			v6:Cancel()
			v6 = nil
		end

		local position = MobilePianoContainer.Position
		v7 = true
		v4 = p
		ApplyMobilePianoLayout()
		setDesktopShellHiddenForMobile(true) -- inferred equivalent call
		PianoContainer.Visible = false
		MobilePianoContainer.Visible = true
		local position2 = v4 and udim2 or udim

		if not position2 then
			v7 = false
			return
		end

		MobilePianoContainer.Position = position

		if frame and frame:IsA("GuiObject") then
			frame.Visible = true
		end

		if rightBar and rightBar:IsA("GuiObject") then
			rightBar.Visible = true
		end

		if MobileBurgerButton and MobileBurgerButton:IsA("GuiObject") then
			MobileBurgerButton.Visible = true
		end

		if MobileBurgerPanel and MobileBurgerPanel:IsA("GuiObject") then
			MobileBurgerPanel.Visible = false
		end

		if keySizePanel and keySizePanel:IsA("GuiObject") then
			keySizePanel.Visible = false
		end

		if guiObject2 and guiObject2:IsA("TextButton") then
			guiObject2.Text = p and "Show Piano" or "Hide Piano"
			guiObject2.Visible = true
		end

		local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		v5 = TweenService:Create(MobilePianoContainer, tweenInfo, { Position = position2 })
		v5:Play()

		local function finishAnimation() -- 1 equivalent call inferred from this helper
			v7 = false
			ApplyMobilePianoLayout()
		end

		local completedConnection = nil
		completedConnection = v5.Completed:Connect(function()
			if completedConnection then
				completedConnection:Disconnect()
			end

			finishAnimation() -- inferred equivalent call
		end)
	end

	local function ToggleMobilePianoCollapsed()
		playClickSound() -- inferred equivalent call
		SetMobilePianoCollapsed(not v4)
	end

	function visualSettingHelpers.BindControlsAndMobileSliders()
		updateMobileScrollDisplay()
		MobileOctaveScroller.Bind()

		local velocityBar = VelocityBar
		connectGuiButton(velocityBar, function() -- inferred equivalent call
			playClickSound() -- inferred equivalent call
			Velocity = 50
			VelocityBar.Visible = false
		end)
		connectGuiButton(PianoCollapseKnob, ToggleDesktopPianoCollapsed) -- inferred equivalent call
		connectGuiButton(OptionFrame:FindFirstChild("Sustain"), ToggleSustainFromButton) -- inferred equivalent call
		connectGuiButton(OptionFrame:FindFirstChild("Caps"), ToggleCapsFromButton) -- inferred equivalent call
		connectGuiButton(OptionFrame:FindFirstChild("TransposeUp"), function() -- inferred equivalent call
			ChangeTransposition(1)
		end)
		connectGuiButton(OptionFrame:FindFirstChild("TransposeDown"), function() -- inferred equivalent call
			ChangeTransposition(-1)
		end)
		connectGuiButton(OptionFrame:FindFirstChild("VolumeUp"), function() -- inferred equivalent call
			ChangeVolume(10)
		end)
		connectGuiButton(OptionFrame:FindFirstChild("VolumeDown"), function() -- inferred equivalent call
			ChangeVolume(-10)
		end)
		connectGuiButton(OptionFrame:FindFirstChild("Soundfonts"), ToggleSoundfonts) -- inferred equivalent call
		connectGuiButton(OptionFrame:FindFirstChild("Sheets"), ToggleSheets) -- inferred equivalent call
		connectGuiButton(OptionFrame:FindFirstChild("Autoplayer"), ToggleAutoplayer) -- inferred equivalent call

		if rightBar then
			connectGuiButton(rightBar:FindFirstChild("Sustain"), ToggleSustainFromButton) -- inferred equivalent call
			connectGuiButton(rightBar:FindFirstChild("Soundfonts"), ToggleSoundfonts) -- inferred equivalent call
			connectGuiButton(rightBar:FindFirstChild("Sheets"), ToggleSheets) -- inferred equivalent call
		end

		if transpositionFrame then
			connectGuiButton(transpositionFrame:FindFirstChild("TranspositionUp"), function() -- inferred equivalent call
				ChangeTransposition(1)
			end)
			connectGuiButton(transpositionFrame:FindFirstChild("TranspositionDown"), function() -- inferred equivalent call
				ChangeTransposition(-1)
			end)
		end

		connectGuiButton(MobileAutoplayerButton, ToggleAutoplayer) -- inferred equivalent call
		local sharedFeatureFrame = findSharedFeatureFrame("AutoPlayer") -- inferred equivalent call
		local close = sharedFeatureFrame and sharedFeatureFrame:FindFirstChild("Close")
		connectGuiButton(close, HideAutoplayer) -- inferred equivalent call
		bindMobileManualAutoButton()
		connectGuiButton(MobileMidiButton, ToggleMidiPlayer) -- inferred equivalent call
		connectGuiButton(MobilePracticeButton, ToggleCommunitySheets) -- inferred equivalent call
		local mobileMode2DButton = MobileMode2DButton
		connectGuiButton(mobileMode2DButton, function() -- inferred equivalent call
			playClickSound() -- inferred equivalent call

			if PianoRoll2DHandler.IsOpen and PianoRoll2DHandler.IsOpen() then
				PianoRoll2DHandler.Hide()
			elseif PianoRoll2DHandler.Open then
				PianoRoll2DHandler.Open()
			end
		end)
		connectGuiButton(MobileScrollButton, ToggleMobileScroll) -- inferred equivalent call
		connectGuiButton(button, ToggleMobilePianoCollapsed) -- inferred equivalent call
		connectGuiButton(MobileBurgerButton, ToggleMobileBurgerMenu) -- inferred equivalent call
		connectGuiButton(keySizeButton, ToggleMobileKeySizePanel) -- inferred equivalent call
		local track = v11
		local v53 = v13
		local function fn6(p)
			setMobileKeySize(p, keyHeight) -- inferred equivalent call
			ApplyMobilePianoLayout()
		end

		if track and v53 and fn6 then
			local minValue = 0
			local maxValue = 128
			local function beginDrag(p)
				if
					p.UserInputType ~= Enum.UserInputType.Touch
					and p.UserInputType ~= Enum.UserInputType.MouseButton1
				then
					return
				end

				v17 = { Track = track, MinValue = minValue, MaxValue = maxValue, ApplyValue = fn6 }

				fn6(getMobileSliderValueFromInput(track, p.Position.X, minValue, maxValue)) -- inferred equivalent call
			end

			track.InputBegan:Connect(beginDrag)
			v53.InputBegan:Connect(beginDrag)
		end

		local track2 = v14
		local v55 = v16
		local function fn7(p)
			keyWidth = clampMobileKeyValue(keyWidth, 52, 0, 128) -- inferred equivalent call
			keyHeight = clampMobileKeyValue(p, 130, 0, 320) -- inferred equivalent call
			updateMobileKeySizeLabels() -- inferred equivalent call
			applyMobileKeySize()

			ApplyMobilePianoLayout()
		end

		if track2 and v55 and fn7 then
			local minValue = 0
			local maxValue = 320
			local function beginDrag(p)
				if
					p.UserInputType ~= Enum.UserInputType.Touch
					and p.UserInputType ~= Enum.UserInputType.MouseButton1
				then
					return
				end

				v17 = { Track = track2, MinValue = minValue, MaxValue = maxValue, ApplyValue = fn7 }

				fn7(getMobileSliderValueFromInput(track2, p.Position.X, minValue, maxValue)) -- inferred equivalent call
			end

			track2.InputBegan:Connect(beginDrag)
			v55.InputBegan:Connect(beginDrag)
		end

		local function fn8()
			playClickSound() -- inferred equivalent call
			keyWidth = clampMobileKeyValue(52, 52, 0, 128) -- inferred equivalent call
			keyHeight = clampMobileKeyValue(130, 130, 0, 320) -- inferred equivalent call
			updateMobileKeySizeLabels() -- inferred equivalent call
			applyMobileKeySize()

			ApplyMobilePianoLayout()
			Folder_Remotes:WaitForChild("SaveMobilePianoSettings"):FireServer({ Reset = true })
		end

		connectGuiButton(resetKeySize, fn8) -- inferred equivalent call

		if guiObject2 ~= button then
			connectGuiButton(guiObject2, ToggleMobilePianoCollapsed) -- inferred equivalent call
		end

		local function bindMobileVolumeSlider()
			if not volumeTrack then
				return
			end

			volumeTrack.Active = true

			if fill then
				fill.Active = true
			end

			if knob then
				knob.Active = true
			end

			local function setVolumeFromInputX(x) -- 2 equivalent calls inferred from this helper
				local x2 = volumeTrack.AbsoluteSize.X

				if x2 <= 0 then
					return
				end

				LocalVolume = math.clamp(
					math.floor((math.clamp((x - volumeTrack.AbsolutePosition.X) / x2, 0, 1) * 190 + 10) / 10 + 0.5) * 10,
					10,
					200
				)
				Dependence_PlayerVariables.Current_Volume = LocalVolume
				UpdateVolumeDisplay() -- inferred equivalent call
			end

			local function isVolumeInput(input): boolean -- 2 equivalent calls inferred from this helper
				return input.UserInputType == Enum.UserInputType.Touch
					or input.UserInputType == Enum.UserInputType.MouseButton1
			end

			local v58 = false

			for _, v59 in ipairs({ volumeTrack, fill, knob }) do
				if v59 then
					v59.InputBegan:Connect(function(input)
						if isVolumeInput(input) then -- inferred equivalent call
							v58 = true
							setVolumeFromInputX(input.Position.X) -- inferred equivalent call
						end
					end)
				end
			end

			UserInputService.InputChanged:Connect(function(input)
				if not v58 then
					return
				end

				if
					input.UserInputType == Enum.UserInputType.Touch
					or input.UserInputType == Enum.UserInputType.MouseMovement
				then
					setVolumeFromInputX(input.Position.X) -- inferred equivalent call
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if isVolumeInput(input) then -- inferred equivalent call
					v58 = false
				end
			end)
			UpdateVolumeDisplay() -- inferred equivalent call
		end

		bindMobileVolumeSlider()

		local camera = OptionFrame:FindFirstChild("Camera")

		if camera then
			camera.Activated:Connect(function()
				playClickSound() -- inferred equivalent call
				PianoPractice.CyclePianoCamera()
			end)
		end

		local notebinds = OptionFrame:FindFirstChild("Notebinds")

		if notebinds then
			notebinds.MouseButton1Click:Connect(function()
				local openSettingsNotebinds = ReplicatedStorage:FindFirstChild("OpenSettingsNotebinds")

				if openSettingsNotebinds then
					openSettingsNotebinds:Fire()
				end
			end)
		end
	end

	local function buildMidiPlayerCallbacks()
		return {
			playNote = fn5,
			finishNote = fn4,
			markActivity = MarkPianoActivity,
			setPlaybackMode = function(p)
				v51 = p
			end,
			getMidiPlayerLayoutMode = function(): string
				if PianoRoll2DHandler.IsOpen and PianoRoll2DHandler.IsOpen() then
					return "2D"
				end

				return if visible2 then "Mobile" else "Desktop"
			end,
			onMidi2DSourceReady = function(p)
				if PianoRoll2DHandler.IsOpen and PianoRoll2DHandler.IsOpen() then
					return PianoRoll2DHandler.SetSource(p)
				end

				return false
			end,
			onMidi2DPlayRequested = function(p)
				if not (PianoRoll2DHandler.IsOpen and PianoRoll2DHandler.IsOpen()) then
					return false
				end

				if p then
					p.showModePanel = false
					PianoRoll2DHandler.SetSource(p)
				end

				return PianoRoll2DHandler.ShowLoadedSourceModes and PianoRoll2DHandler.ShowLoadedSourceModes()
			end,
			isMidi2DRunning = function()
				return PianoRoll2DHandler.IsRunning and PianoRoll2DHandler.IsRunning("MIDI Player")
			end,
			toggleMidi2DPause = function()
				if PianoRoll2DHandler.TogglePause then
					return PianoRoll2DHandler.TogglePause()
				end

				return false
			end,
			isMidi2DPaused = function()
				return PianoRoll2DHandler.IsPaused and PianoRoll2DHandler.IsPaused()
			end,
			getMidi2DProgress = function()
				if PianoRoll2DHandler.GetPlaybackProgress then
					return PianoRoll2DHandler.GetPlaybackProgress()
				end

				return nil
			end,
			seekMidi2DPlayback = function(p)
				if PianoRoll2DHandler.Seek then
					return PianoRoll2DHandler.Seek(p)
				end

				return false
			end,
			setMidi2DSpeed = function(p)
				if PianoRoll2DHandler.SetPlaybackSpeed then
					return PianoRoll2DHandler.SetPlaybackSpeed(p)
				end

				return 1
			end,
			stopMidi2DPlayback = function()
				if PianoRoll2DHandler.Stop then
					PianoRoll2DHandler.Stop(true)
				end
			end,
			isPracticeMode = function()
				return PianoPractice.Active
			end
		}
	end

	MidiPlayerHandler.Initialize(PianoContainer, OptionFrame, buildMidiPlayerCallbacks(), clickSound)
	visualSettingHelpers.BindControlsAndMobileSliders()

	local RemotePianoPacketHandler = require(script:WaitForChild("RemotePianoPacketHandler"))
	RemotePianoPacketHandler.Initialize({
		PianoPackets = PianoPackets,
		LocalPlayer = LocalPlayer,
		Logic_Piano = Logic_Piano,
		Logic_UI = Logic_UI,
		PianoVisualization = PianoVisualization,
		VisualSettingHelpers = visualSettingHelpers,
		Dependence_PlayerVariables = Dependence_PlayerVariables,
		Dependence_Soundfonts = Dependence_Soundfonts,
		Dependence_SoundEffects = Dependence_SoundEffects,
		PianoPractice = PianoPractice,
		GetCurrentHumanoid = function()
			if not humanoid and LocalPlayer.Character then
				humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
			end

			return humanoid
		end,
		GetCurrentPianoModel = function()
			return currentPianoModel
		end,
		GetViewingPianoModel = function()
			return viewingPianoModel
		end,
		SetViewingPianoModel = function(p)
			viewingPianoModel = p
		end,
		GetPianoModel = getPianoModel,
		IsPianoControlsVisible = IsPianoControlsVisible,
		CleanupViewedPiano = cleanupViewedPiano,
		ClearAllPianoKeyHighlights = ClearAllPianoKeyHighlights,
		PrewarmCurrentSoundfont = PrewarmCurrentSoundfont,
		GetOtherPianoVolumeMultiplier = GetOtherPianoVolumeMultiplier,
		GetLocalVolume = function()
			return LocalVolume
		end,
		GetActiveKeysFrame = GetActiveKeysFrame,
		StartVisualization = startVisualization,
		EndVisualization = endVisualization,
		PianoSimRunCustomVisualEffect = PianoSimRunCustomVisualEffect
	})

	DesktopFeaturePanelDragState = nil

	function IsDesktopFeaturePanelDragInput(p)
		if p then
			if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
				p = p.Position ~= nil
			else
				p = false
			end
		end

		return p
	end

	function IsDesktopFeaturePanelMoveInput(p, p2): boolean
		if p2 == Enum.UserInputType.MouseButton1 then
			return p.UserInputType == Enum.UserInputType.MouseMovement
		end

		return p2 == Enum.UserInputType.Touch and p.UserInputType == Enum.UserInputType.Touch
	end

	function IsFeaturePanelSliderLikeDragTarget(guiObject3): boolean
		if not guiObject3:IsA("GuiObject") then
			return false
		end

		local name = string.lower(guiObject3.Name)
		return name:find("slider", 1, true) ~= nil
			or name == "track"
			or name == "fill"
			or name == "thumb"
			or name == "knob"
			or name == "bar"
			or name == "handle"
	end

	function IsFeaturePanelInteractiveDragTarget(instance, p): boolean
		while instance and instance ~= p do
			if
				instance:IsA("TextButton")
				or instance:IsA("ImageButton")
				or instance:IsA("TextBox")
				or instance:IsA("ScrollingFrame")
			then
				return true
			end

			if IsFeaturePanelSliderLikeDragTarget(instance) then
				return true
			end

			instance = instance.Parent
		end

		return false
	end

	function CanStartDesktopFeaturePanelDrag(guiObject3, p)
		if not (guiObject3 and guiObject3:IsA("GuiObject") and IsDesktopFeaturePanelDragInput(p)) then
			return false
		end

		local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return true
		end

		local guiObjectsAtPosition = playerGui:GetGuiObjectsAtPosition(p.Position.X, p.Position.Y)
		local v52 = false

		for _, v53 in ipairs(guiObjectsAtPosition) do
			v52 = (v53 == guiObject3 or v53:IsDescendantOf(guiObject3)) and true or v52

			if v53:IsDescendantOf(guiObject3) and IsFeaturePanelInteractiveDragTarget(v53, guiObject3) then
				return false
			end
		end

		return v52
	end

	function BindDesktopFeaturePanelDrag(guiObject3)
		if not guiObject3 or not guiObject3:IsA("GuiObject") or guiObject3:GetAttribute("DesktopFeatureDragBound") then
			return
		end

		guiObject3:SetAttribute("DesktopFeatureDragBound", true)
		guiObject3.Active = true
		guiObject3.InputBegan:Connect(function(input)
			if not CanStartDesktopFeaturePanelDrag(guiObject3, input) then
				return
			end

			DesktopFeaturePanelDragState = {
				Panel = guiObject3,
				InputType = input.UserInputType,
				StartInputPosition = input.Position,
				StartPanelPosition = guiObject3.Position
			}

			setPanelZTree(guiObject3, 2450)
		end)
	end

	UserInputService.InputChanged:Connect(function(input)
		local desktopFeaturePanelDragState = DesktopFeaturePanelDragState

		if not (desktopFeaturePanelDragState and IsDesktopFeaturePanelMoveInput(
			input,
			desktopFeaturePanelDragState.InputType
		)) then
			return
		end

		local panel = desktopFeaturePanelDragState.Panel

		if not (panel and panel.Parent) then
			DesktopFeaturePanelDragState = nil
			return
		end

		local v52 = input.Position - desktopFeaturePanelDragState.StartInputPosition
		local startPanelPosition = desktopFeaturePanelDragState.StartPanelPosition
		panel.Position = UDim2.new(
			startPanelPosition.X.Scale,
			startPanelPosition.X.Offset + v52.X,
			startPanelPosition.Y.Scale,
			startPanelPosition.Y.Offset + v52.Y
		)
	end)

	UserInputService.InputEnded:Connect(function(input)
		local desktopFeaturePanelDragState = DesktopFeaturePanelDragState

		if not desktopFeaturePanelDragState then
			return
		end

		if
			input.UserInputType == desktopFeaturePanelDragState.InputType
			or desktopFeaturePanelDragState.InputType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseButton1
		then
			DesktopFeaturePanelDragState = nil
		end
	end)

	function visualSettingHelpers.InitializeBottomSystems()
		for _, v52 in pairs(DraggableFrames) do
			BindDesktopFeaturePanelDrag(v52)
		end

		local function bindPianoKeyFrame(instance)
			if not instance then
				return
			end

			for _, button2 in pairs(instance:GetChildren()) do
				if not (button2:IsA("ImageButton") or button2:IsA("TextButton")) then
					continue
				end

				local name = tonumber(button2.Name)

				if not name or button2:GetAttribute("PianoSimKeyInputBound") then
					continue
				end

				button2:SetAttribute("PianoSimKeyInputBound", true)
				button2.Active = true

				local function isPianoPressInput(input): boolean -- 2 equivalent calls inferred from this helper
					return input.UserInputType == Enum.UserInputType.Touch
						or input.UserInputType == Enum.UserInputType.MouseButton1
				end

				button2.InputBegan:Connect(function(input)
					if not isPianoPressInput(input) then -- inferred equivalent call
						return
					end

					if IsPianoControlsVisible() and not IsMobilePianoInputBlocked(input) then -- inferred equivalent call
						fn5(name, input)
					end
				end)

				button2.InputEnded:Connect(function(input)
					if not (isPianoPressInput(input) and IsPianoControlsVisible()) then -- inferred equivalent call
						return
					end

					fn4(name, input)
				end)

				button2.MouseLeave:Connect(function()
					if PianoUI.Enabled and v29[name] then
						fn4(name, nil)
					end
				end)
			end
		end

		bindPianoKeyFrame(DesktopKeysFrame)
		bindPianoKeyFrame(MobileKeysFrame)
		local sharedFeatureFrame = findSharedFeatureFrame("AutoPlayer") -- inferred equivalent call

		if sharedFeatureFrame then
			AutoPlayerHandler.Initialize({
				AutoPlayerFrame = sharedFeatureFrame,
				NotesTextBox = sharedFeatureFrame.Notes,
				NotesOverlay = sharedFeatureFrame:FindFirstChild("NotesOverlay"),
				PlayButton = sharedFeatureFrame.Play,
				KeybindButton = sharedFeatureFrame:FindFirstChild("Bind"),
				TempoTextBox = sharedFeatureFrame.Tempo,
				ModeButton = sharedFeatureFrame:FindFirstChild("Mode")
			}, {
				getCurrentState = function()
					return {
						Transposition = Transposition,
						Velocity = Velocity,
						Above88KeyPacket = above88KeyPacket,
						SustainPacket = sustainPacket,
						LocalVolume = LocalVolume,
						ModelKeyHighlightEnabled = LocalPlayer:GetAttribute("ModelKeyHighlightEnabled") ~= false
					}
				end,
				getCurrentPianoModel = function()
					return currentPianoModel
				end,
				startVisualization = startVisualization,
				endVisualization = endVisualization,
				animateModelKey = function(p, p2)
					if p2 then
						visualSettingHelpers.ApplySynthesiaColorsFromPlayer(LocalPlayer, currentPianoModel)
					end

					visualSettingHelpers.AnimatePianoModelKey(currentPianoModel, p, p2, LocalPlayer)
				end,
				markActivity = MarkPianoActivity,
				isPracticeMode = function()
					return PianoPractice.Active
				end
			}, {
				KeysFrame = KeysFrame,
				Logic_UI = Logic_UI,
				Logic_Keymap = Logic_Keymap,
				KEY_OFFSET = KEY_OFFSET,
				Logic_Piano = Logic_Piano,
				Folder_Remotes = Folder_Remotes,
				CurrentHumanoid = humanoid,
				Dependence_PlayerVariables = Dependence_PlayerVariables,
				Dependence_Soundfonts = Dependence_Soundfonts,
				NPSCounter = NPSCounter,
				PianoPackets = PianoPackets
			})
		end

		local function getSheetsEditorBox()
			local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

			local v52 = findDirectPanel(PianoUI, "Sheets") or findDirectPanel(mobilePanelHost, "Sheets")

			local card = v52 and v52:FindFirstChild("Card")
			local scroll = card and card:FindFirstChild("Scroll")
			local editor = scroll and scroll:FindFirstChild("Editor")

			if editor and editor:IsA("TextBox") then
				return editor
			end

			return nil
		end

		local function getCurrentSheetText()
			local sheetsEditorBox = getSheetsEditorBox()

			if sheetsEditorBox and tostring(sheetsEditorBox.Text or ""):match("%S") then
				return sheetsEditorBox.Text
			end

			local notes = sharedFeatureFrame and sharedFeatureFrame:FindFirstChild("Notes")
			return notes and notes.Text or ""
		end

		ApplyMobileFeatureLayouts()

		local function raiseFeaturePanelAbove2D(guiObject3)
			if PianoUI:IsA("ScreenGui") then
				PianoUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
			end

			if not (guiObject3 and guiObject3:IsA("GuiObject")) then
				return
			end

			guiObject3.ZIndex = math.max(guiObject3.ZIndex, 6250)

			for _, guiObject4 in ipairs(guiObject3:GetDescendants()) do
				if guiObject4:IsA("GuiObject") then
					guiObject4.ZIndex = math.max(guiObject4.ZIndex, 6251)
				end
			end
		end

		PianoRoll2DHandler.Initialize(PianoUI, {
			getSheetText = getCurrentSheetText,
			getTempo = function()
				local tempo = sharedFeatureFrame and sharedFeatureFrame:FindFirstChild("Tempo")
				return tempo and tempo.Text or "120"
			end,
			charToNote = function(value2)
				if typeof(value2) ~= "string" or value2 == "" then
					return nil
				end

				local v52 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(value2, 1, true)

				if v52 then
					return Logic_Keymap:GetMappedNote(v52)
				end

				return nil
			end,
			playNote = function(p, p2)
				local v52 = v51
				local v53 = PianoRoll2DHandler.IsRunning
					and PianoRoll2DHandler.IsRunning("MIDI Player")
					and "MidiPlayer"
					or nil
				v51 = true
				fn5(p, p2 or Velocity, 0, sustainPacket, v53)
				v51 = v52
			end,
			finishNote = function(p)
				fn4(p, nil)
			end,
			playManualNote = function(p)
				fn5(p, nil)
			end,
			finishManualNote = function(p)
				fn4(p, nil)
			end,
			openSheets = function()
				hideSharedFeatureFrames()
				local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

				local v52 = findDirectPanel(PianoUI, "Sheets") or findDirectPanel(mobilePanelHost, "Sheets")

				if v52 then
					v52.Visible = true
					raiseFeaturePanelAbove2D(v52)
					ApplyMobileFeatureLayouts()
					raiseFeaturePanelAbove2D(v52)
				end
			end,
			openRecordings = function()
				hideSharedFeatureFrames()

				if RecordingUIHandler.OpenModal then
					RecordingUIHandler.OpenModal()
				else
					local sharedFeatureFrame2 = findSharedFeatureFrame("Modal") -- inferred equivalent call

					if sharedFeatureFrame2 then
						sharedFeatureFrame2.Visible = true
					end
				end

				local sharedFeatureFrame2 = findSharedFeatureFrame("Modal") -- inferred equivalent call
				raiseFeaturePanelAbove2D(sharedFeatureFrame2)
				ApplyMobileFeatureLayouts()
				raiseFeaturePanelAbove2D(sharedFeatureFrame2)
			end,
			openMidi = function()
				hideSharedFeatureFrames()

				if MidiPlayerHandler.OpenModal then
					MidiPlayerHandler.OpenModal()
				else
					local sharedFeatureFrame2 = findSharedFeatureFrame("MidiModal") -- inferred equivalent call

					if sharedFeatureFrame2 then
						sharedFeatureFrame2.Visible = true
					end
				end

				local sharedFeatureFrame2 = findSharedFeatureFrame("MidiModal") -- inferred equivalent call
				raiseFeaturePanelAbove2D(sharedFeatureFrame2)
				ApplyMobileFeatureLayouts()

				if sharedFeatureFrame2 and sharedFeatureFrame2.Parent ~= PianoUI then
					sharedFeatureFrame2.Parent = PianoUI
				end

				raiseFeaturePanelAbove2D(sharedFeatureFrame2)
			end,
			getAutoPlayerFrame = function()
				return sharedFeatureFrame
			end,
			getSheetsFrame = function()
				local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

				return findDirectPanel(PianoUI, "Sheets") or findDirectPanel(mobilePanelHost, "Sheets")
			end,
			getOptionFrame = function()
				return OptionFrame
			end,
			stopSheetPractice = function() end,
			hideSourcePanels = function()
				hideSharedFeatureFrames()
			end,
			isMidiDesktopPlaybackActive = function()
				return MidiPlayerHandler.IsPlaybackActive and MidiPlayerHandler.IsPlaybackActive()
			end,
			stopMidiPlayback = function()
				if MidiPlayerHandler.Stop then
					MidiPlayerHandler.Stop()
				end
			end,
			markActivity = MarkPianoActivity
		}, clickSound)

		local saveTemplate = script:WaitForChild("SaveTemplate", 10)

		if saveTemplate then
			local mobilePanelHost = PianoUI:FindFirstChild("MobilePanelHost")

			RecordingUIHandler.RecordingModal = findDirectPanel(PianoContainer, "Modal")
				or findDirectPanel(PianoUI, "Modal")
				or findDirectPanel(mobilePanelHost, "Modal")
				or PianoContainer:WaitForChild("Modal", 10)

			if visible2 and RecordingUIHandler.RecordingModal then
				ApplyMobileFeatureLayouts()
			end

			RecordingUIHandler.Initialize({
				RecordButton = OptionFrame:FindFirstChild("Record"),
				PlayRecordButton = OptionFrame:FindFirstChild("PlayRecord"),
				Modal = RecordingUIHandler.RecordingModal,
				SaveTemplate = saveTemplate,
				KeysFrame = KeysFrame,
				Logic_UI = Logic_UI,
				OptionFrame = OptionFrame
			}, {
				playNote = fn5,
				finishNote = fn4,
				toggleSustain = function(p)
					sustainPacket = p
					local current_SoundfontID = Dependence_PlayerVariables.Current_SoundfontID
					local dependence_Soundfont = Dependence_Soundfonts[current_SoundfontID]
					local fadeout = dependence_Soundfont and dependence_Soundfont.Fadeout or 1
					Logic_Piano.UpdateSustainState(sustainPacket, fadeout)
					UpdateSustainDisplay()

					if not PianoPractice.Active then
						if sustainPacket then
							PianoPackets.SustainRelease:Fire("__PianoSustainOn", fadeout)
						else
							PianoPackets.FinishNonSustainedNotes:Fire(fadeout)
						end
					end
				end,
				setPlaybackMode = function(p)
					v51 = p
				end,
				isPracticeMode = function()
					return PianoPractice.Active
				end,
				onRecording2DSourceReady = function(p)
					if PianoRoll2DHandler.IsOpen and PianoRoll2DHandler.IsOpen() then
						return PianoRoll2DHandler.SetRecordingSource(p)
					end

					return false
				end,
				clearHighlights = ClearAllPianoKeyHighlights,
				handlesUiHighlights = true
			})

			if RecordingUIHandler.RecordingModal and RecordingUIHandler.RecordingModal:IsA("GuiObject") then
				table.insert(
					RecordingUIHandler._connections,
					RecordingUIHandler.RecordingModal:GetPropertyChangedSignal("Visible"):Connect(function()
						if visible2 and RecordingUIHandler.RecordingModal.Visible then
							ApplyMobileFeatureLayouts()
						end
					end)
				)
			end

			local v52 = {}

			local function disconnectMobileRecordingSyncConnections(p)
				if not (p and p.SyncConnections) then
					return
				end

				for _, syncConnection in ipairs(p.SyncConnections) do
					if syncConnection and syncConnection.Connected then
						syncConnection:Disconnect()
					end
				end

				p.SyncConnections = {}
			end

			local function captureMobileRecordingSourceState(button2)
				local v53 = v52[button2]

				if v53 then
					return v53
				end

				local v54 = {
					Parent = button2.Parent,
					AnchorPoint = button2.AnchorPoint,
					Position = button2.Position,
					Size = button2.Size,
					BackgroundTransparency = button2.BackgroundTransparency,
					BorderSizePixel = button2.BorderSizePixel,
					ZIndex = button2.ZIndex,
					TextTransparency = 0,
					ImageTransparency = 0,
					Children = 0,
					SyncConnections = 0,
					Installed = false,
					Target = nil
				}
				local textTransparency

				if button2:IsA("TextButton") then
					textTransparency = button2.TextTransparency or nil
				end

				v54.TextTransparency = textTransparency
				local imageTransparency2

				if button2:IsA("ImageButton") then
					imageTransparency2 = button2.ImageTransparency or nil
				end

				v54.ImageTransparency = imageTransparency2
				v54.Children = {}
				v54.SyncConnections = {}

				for _, child in ipairs(button2:GetChildren()) do
					if child:IsA("GuiObject") then
						v54.Children[child] = { Visible = child.Visible }
					elseif child:IsA("UIStroke") then
						v54.Children[child] = { Enabled = child.Enabled }
					end
				end

				v52[button2] = v54
				return v54
			end

			local function restoreMobileRecordingTapTarget(button2)
				local v53 = button2 and v52[button2]

				if not v53 then
					return
				end

				disconnectMobileRecordingSyncConnections(v53)

				if v53.Parent and v53.Parent.Parent then
					button2.Parent = v53.Parent
				end

				button2.AnchorPoint = v53.AnchorPoint
				button2.Position = v53.Position
				button2.Size = v53.Size
				button2.BackgroundTransparency = v53.BackgroundTransparency
				button2.BorderSizePixel = v53.BorderSizePixel
				button2.ZIndex = v53.ZIndex

				if button2:IsA("TextButton") and v53.TextTransparency ~= nil then
					button2.TextTransparency = v53.TextTransparency
				elseif button2:IsA("ImageButton") and v53.ImageTransparency ~= nil then
					button2.ImageTransparency = v53.ImageTransparency
				end

				for instance, child in pairs(v53.Children) do
					if not (instance and instance.Parent == button2) then
						continue
					end

					if instance:IsA("GuiObject") and child.Visible ~= nil then
						instance.Visible = child.Visible
					elseif instance:IsA("UIStroke") and child.Enabled ~= nil then
						instance.Enabled = child.Enabled
					end
				end

				v53.Installed = false
				v53.Target = nil
			end

			local function restoreMobileRecordingControls() -- 1 equivalent call inferred from this helper
				for k in pairs(v52) do
					restoreMobileRecordingTapTarget(k)
				end
			end

			function _G:PianoSimInstallMobileRecordingTapTarget(guiObject3)
				if not (visible2 and self and guiObject3 and self:IsA("GuiButton") and guiObject3:IsA("GuiObject")) then
					return
				end

				local v53 = captureMobileRecordingSourceState(self)

				if v53.Installed and v53.Target == guiObject3 then
					return
				end

				if v53.Installed then
					restoreMobileRecordingTapTarget(self)
					v53 = captureMobileRecordingSourceState(self)
				end

				local function syncVisibleMobileButton()
					if not (guiObject3 and guiObject3.Parent and self and self.Parent) then
						return
					end

					if self:IsA("TextButton") and guiObject3:IsA("TextButton") then
						local text = self.Text or ""

						if text == "Record" then
							text = "RECORD"
						elseif text == "Play/Pause" then
							text = "PLAY / PAUSE"
						elseif text == "Open" then
							text = "OPEN"
						elseif #text > 0 then
							text = string.upper(text)
						end

						guiObject3.Text = text
						guiObject3.BackgroundColor3 = self.BackgroundColor3
						guiObject3.TextColor3 = self.TextColor3
					end
				end

				guiObject3.Active = true
				self.Parent = guiObject3
				self.AnchorPoint = Vector2.new(0, 0)
				self.Position = UDim2.fromScale(0, 0)
				self.Size = UDim2.fromScale(1, 1)
				self.BackgroundTransparency = 1
				self.BorderSizePixel = 0
				self.ZIndex = guiObject3.ZIndex + 50

				if self:IsA("TextButton") then
					self.TextTransparency = 1
				elseif self:IsA("ImageButton") then
					self.ImageTransparency = 1
				end

				for _, child in ipairs(self:GetChildren()) do
					if child:IsA("GuiObject") then
						child.Visible = false
					elseif child:IsA("UIStroke") then
						child.Enabled = false
					end
				end

				v53.Installed = true
				v53.Target = guiObject3
				syncVisibleMobileButton()

				if self:IsA("TextButton") then
					local textChangedConnection = self:GetPropertyChangedSignal("Text"):Connect(syncVisibleMobileButton)
					local backgroundColor3ChangedConnection = self:GetPropertyChangedSignal("BackgroundColor3"):Connect(syncVisibleMobileButton)
					local textColor3ChangedConnection = self:GetPropertyChangedSignal("TextColor3"):Connect(syncVisibleMobileButton)
					table.insert(v53.SyncConnections, textChangedConnection)
					table.insert(v53.SyncConnections, backgroundColor3ChangedConnection)
					table.insert(v53.SyncConnections, textColor3ChangedConnection)
					table.insert(RecordingUIHandler._connections, textChangedConnection)
					table.insert(RecordingUIHandler._connections, backgroundColor3ChangedConnection)
					table.insert(RecordingUIHandler._connections, textColor3ChangedConnection)
				end
			end

			function _G.PianoSimBindMobileRecordingControls()
				if visible2 then
					_G.PianoSimInstallMobileRecordingTapTarget(
						OptionFrame:FindFirstChild("OpenRecord"),
						mobileUtilityButtons and mobileUtilityButtons:FindFirstChild("OpenRecordText") or leftBar and leftBar:FindFirstChild("OpenRecord")
					)
					_G.PianoSimInstallMobileRecordingTapTarget(
						OptionFrame:FindFirstChild("Record"),
						MobileBurgerPanel and MobileBurgerPanel:FindFirstChild("RecordRow") or leftBar and leftBar:FindFirstChild("Record")
					)
					_G.PianoSimInstallMobileRecordingTapTarget(
						OptionFrame:FindFirstChild("PlayRecord"),
						MobileBurgerPanel and MobileBurgerPanel:FindFirstChild("PlayRow") or leftBar and leftBar:FindFirstChild("PlayRecord")
					)
				else
					restoreMobileRecordingControls() -- inferred equivalent call
				end
			end
			_G.PianoSimBindMobileRecordingControls()
		else
			v.Warn("[PianoMain] Recording UI did not initialize because SaveTemplate was not available.")
		end

		MidiPlayerHandler.Initialize(PianoContainer, OptionFrame, buildMidiPlayerCallbacks(), clickSound)
		ApplyMobileFeatureLayouts()

		if PianoPractice.IconClass and not PianoPractice.Icon then
			PianoPractice.Icon = PianoPractice.IconClass.new():setName("PracticeTopbar"):setLabel("Piano"):align("Left"):setOrder(2)
			PianoPractice.Icon.selected:Connect(function()
				if not PianoPractice.Syncing then
					PianoPractice.Begin()
				end
			end)
			PianoPractice.Icon.deselected:Connect(function()
				if not PianoPractice.Syncing then
					PianoPractice.End("topbar")
				end
			end)
		end

		if PianoUI:FindFirstChild("Stats") or PianoUI:FindFirstChild("Leaderboard") then
			local LeaderboardUI = require(script:WaitForChild("LeaderboardUI"))
			LeaderboardUI.Initialize()
		end

		script.Destroying:Connect(function()
			if characterAddedConnection then
				characterAddedConnection:Disconnect()
			end

			if PianoPractice.Active and PianoPractice.End then
				PianoPractice.End("script-destroying")
			else
				UnbindPiano("script-destroying")
			end
		end)

		v.Print(
			"[PianoMain] Initialized {",
			"AutoPlayer:",
			sharedFeatureFrame and "✓" or "✗",
			"| Recording:",
			saveTemplate and "✓" or "✗",
			"| NPS:",
			value and "✓" or "✗",
			"| Leaderboard:",
			LeaderboardFrame and "✓" or "✗",
			"| Binds:",
			BindsFrame and "✓" or "✗",
			"| Mobile:",
			visible2 and "✓" or "✗",
			"}"
		)
	end
end

visualSettingHelpers.InitializeBottomSystems()