local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local PianoRoll2DHandler = {}
local Players = game:GetService("Players")
PianoRoll2DHandler._LocalPlayer = Players.LocalPlayer

local v = {
	[" "] = true,
	["\n"] = true,
	["\r"] = true,
	["\t"] = true,
	["|"] = true,
	["-"] = true,
	[","] = true,
	[";"] = true
}

local parent2 = nil
local v2 = nil
local v3 = nil

local pianoRoll2D = nil
local parent3 = nil
PianoRoll2DHandler._BackgroundImage = nil
local keyFrame = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local count = 0
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil
local v13 = nil
local v14 = nil
local v15 = nil
local setOptionModeButtonActive
local v16 = nil
local v17 = nil
local v18 = nil
local v19 = nil
local v20 = nil
local v21 = nil
local v22 = "Sheets"
local v23 = nil
local v24 = nil
local v25 = nil
local v26 = false
local tempo = nil
local v27 = {}
local v28 = {}
local v29 = {}
local fn
local fn2
local fn3
local fn4
local fn5
local fn6
local fn7
local fn8
local fn9
local visibilityByGuiObject = nil
local v30 = { "MenuOptions", "MobilePanelHost", "Leaderboard", "NPS" }

PianoRoll2DHandler._TopbarPlusState = PianoRoll2DHandler._TopbarPlusState
	or { guiStates = {}, iconStates = {}, suppressed = false }

local v31 = {
	{ "Sheets" },
	{ "MidiModal" },
	{ "PianoContainer", "MidiModal" },
	{ "PianoContainer", "Modal" }
}

local v32 = false
local flag = false
local lastTime = 0
local mode = nil
local v36 = {}
local v37 = 1
local v38 = 1
local v39 = 1
local v40 = 0
local count2 = 0
local count3 = 0
local v41 = {}
local frames = {}
local v42 = {}
local count4 = 0
local heartbeatConnection = nil
local heartbeatConnection2 = nil
PianoRoll2DHandler._SettingsChangedConnection = nil
local set = {}
local tokenIndexSet = {}
local set2 = {}
local v43 = {}
local v44 = {}
PianoRoll2DHandler._HoldState = { active = {}, scores = {}, labels = {}, colors = {} }

local v45 = -34
local v46 = false
local flag2 = false
local v47 = nil

local _ = {
	Glow = "rbxassetid://6673021984",
	SoftGlow = "rbxassetid://4509687978",
	Burst = "rbxassetid://6490035152",
	Flare = "rbxassetid://14684195806",
	LightRay = "rbxassetid://1053548563",
	LightRing = "rbxassetid://8271495905"
}

PianoRoll2DHandler._ImpactShapeOrder = {
	"Circle",
	"Ring",
	"Burst",
	"Ray",
	"Flare",
	"Heart",
	"Diamond",
	"Star"
}
PianoRoll2DHandler._ImpactShapeTextures = {
	Burst = "rbxassetid://6490035152",
	Ray = "rbxassetid://1053548563",
	Flare = "rbxassetid://14684195806"
}

PianoRoll2DHandler._Default2DSettings = {
	TileColorHex = "#5FBEFF",
	WhiteTileColorHex = "#5FBEFF",
	BlackTileColorHex = "#1E3A5F",
	ImpactColorHex = "#5FBEFF",
	ImpactShape = "Circle",
	BackgroundImage = "",
	BackgroundTransparency = 45
}

PianoRoll2DHandler._2DSettings = {
	TileColorHex = PianoRoll2DHandler._Default2DSettings.TileColorHex,
	WhiteTileColorHex = PianoRoll2DHandler._Default2DSettings.WhiteTileColorHex,
	BlackTileColorHex = PianoRoll2DHandler._Default2DSettings.BlackTileColorHex,
	ImpactColorHex = PianoRoll2DHandler._Default2DSettings.ImpactColorHex,
	ImpactShape = PianoRoll2DHandler._Default2DSettings.ImpactShape,
	BackgroundImage = PianoRoll2DHandler._Default2DSettings.BackgroundImage,
	BackgroundTransparency = PianoRoll2DHandler._Default2DSettings.BackgroundTransparency
}

PianoRoll2DHandler._PlaybackSpeed = 1
local total = 0
local total2 = 0

local function playClick() -- 6 equivalent calls inferred from this helper
	if v3 then
		v3:Play()
	end
end

local function markActivity() -- 8 equivalent calls inferred from this helper
	if v2 and v2.markActivity then
		v2.markActivity()
	end
end

function PianoRoll2DHandler._ShouldShowManualEffect(): boolean
	return pianoRoll2D ~= nil and pianoRoll2D.Visible == true and not v32
end

local function getSheetText() -- 2 equivalent calls inferred from this helper
	if v2 and v2.getSheetText then
		return v2.getSheetText() or ""
	end

	return ""
end

local function getTempo() -- 2 equivalent calls inferred from this helper
	if v2 and v2.getTempo then
		local v48 = tonumber(v2.getTempo())

		if v48 and v48 > 0 then
			return (math.clamp(v48, 20, 600))
		end
	end

	return 120
end

local function charToNote(p) -- 6 equivalent calls inferred from this helper
	if v2 and v2.charToNote then
		return v2.charToNote(p)
	end

	return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(p, 1, true)
end

function PianoRoll2DHandler._GetQwertyLabelForNote(p)
	local v48 = tonumber(p)

	if not v48 then
		return nil
	end

	local child = keyFrame and keyFrame:FindFirstChild((tostring(v48)))
	local label = child and child:FindFirstChild("Label")

	if label and label:IsA("TextLabel") and label.Text ~= "" then
		return label.Text
	end

	for i = 1, 61 do
		local v49 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(i, i)

		if charToNote(v49) == v48 then -- inferred equivalent call
			return v49
		end
	end

	return nil
end

local function isValidChar(p): boolean -- 2 equivalent calls inferred from this helper
	return p ~= "" and ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(p, 1, true) ~= nil
end

local function makeCorner(parent, value) -- 11 equivalent calls inferred from this helper
	local uiCorner = parent:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, value or 6)
	uiCorner.Parent = parent
	return uiCorner
end

local function makeStroke(parent, color, value) -- 4 equivalent calls inferred from this helper
	local uiStroke = parent:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Color = color
	uiStroke.Thickness = value or 1
	uiStroke.Parent = parent
	return uiStroke
end

local function styleButton(parent, text, color)
	parent.Text = text
	parent.BackgroundColor3 = color or Color3.fromRGB(42, 49, 60)
	parent.BorderSizePixel = 0
	parent.AutoButtonColor = true
	parent.Font = Enum.Font.GothamBold
	parent.TextSize = 13
	parent.TextColor3 = Color3.fromRGB(245, 248, 252)
	parent.TextWrapped = true
	makeCorner(parent) -- inferred equivalent call
end

local function getOrCreate(parent, className, name)
	local child = parent and parent:FindFirstChild(name)

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

local function setText(p, value, textColor) -- 25 equivalent calls inferred from this helper
	if not p then
		return
	end

	p.Text = value or ""

	if textColor then
		p.TextColor3 = textColor
	end
end

local function getAccuracyPercent() -- 4 equivalent calls inferred from this helper
	if total2 > 0 then
		return (math.clamp(math.floor(total / total2 * 100 + 0.5), 0, 100))
	end

	local v48 = count2 + count3

	if v48 <= 0 then
		return 100
	end

	return (math.clamp(math.floor(count2 / v48 * 100 + 0.5), 0, 100))
end

local function showJudgement(value, textColor)
	setText(v5, value, textColor) -- inferred equivalent call

	if not v7 then
		return
	end

	count += 1
	local v48 = count

	if v8 then
		v8:Cancel()
		v8 = nil
	end

	v7.Visible = true
	v7.Text = value or ""
	v7.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	v7.TextTransparency = 0
	v7.TextStrokeTransparency = 0.35
	v7.Position = UDim2.new(0.5, 0, 0.54, 0)
	v8 = TweenService:Create(v7, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.48, 0),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	})

	v8:Play()
	task.delay(0.42, function()
		if v48 == count and v7 then
			v7.Visible = false
		end
	end)
end

local function noteToScale(p)
	return (math.clamp(tonumber(p) or -14, -14, 73) - -14) / 88, 1 / 88
end

local function isBlackKeyIndex(p): boolean -- 2 equivalent calls inferred from this helper
	local v48 = p % 12
	return v48 == 1 or v48 == 4 or v48 == 6 or v48 == 9 or v48 == 11
end

local function is2DBlackNote(p) -- 1 equivalent call inferred from this helper
	return isBlackKeyIndex(math.clamp(tonumber(p) or -14, -14, 73) - -14) -- inferred equivalent call
end

local function getKeySlot(p)
	local guiObject = keyFrame and keyFrame:FindFirstChild((tostring(p)))

	if guiObject and guiObject:IsA("GuiObject") and keyFrame.AbsoluteSize.X > 0 then
		local v48 = guiObject.AbsolutePosition.X - keyFrame.AbsolutePosition.X
		local x = guiObject.AbsoluteSize.X
		return math.clamp(v48 / keyFrame.AbsoluteSize.X, 0, 1), (math.max(x / keyFrame.AbsoluteSize.X, 1 / 88))
	end

	return noteToScale(p)
end

local function releaseTile(p) -- 3 equivalent calls inferred from this helper
	if p and p.frame then
		p.frame.Visible = false
		p.frame.Parent = nil
		table.insert(frames, p.frame)
	end
end

local function clearTiles() -- 3 equivalent calls inferred from this helper
	for _, v48 in ipairs(v41) do
		releaseTile(v48) -- inferred equivalent call
	end

	table.clear(v41)
end

local function getCanvasHeight() -- 13 equivalent calls inferred from this helper
	if parent3 and parent3.AbsoluteSize.Y > 0 then
		return parent3.AbsoluteSize.Y
	end

	return 420
end

local function getPathChild(instance, list) -- 1 equivalent call inferred from this helper
	for _, childName in ipairs(list) do
		instance = instance and instance:FindFirstChild(childName)
	end

	return instance
end

local function raiseGuiTreeZIndex(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	guiObject.ZIndex = math.max(guiObject.ZIndex, p)

	for _, guiObject2 in ipairs(guiObject:GetDescendants()) do
		if guiObject2:IsA("GuiObject") then
			guiObject2.ZIndex = math.max(guiObject2.ZIndex, p + 1)
		end
	end
end

local function raiseSourcePanelsAbove2D()
	if not parent2 then
		return
	end

	for _, v48 in ipairs(v31) do
		raiseGuiTreeZIndex(getPathChild(parent2, v48), 6400) -- inferred equivalent call
	end
end

function PianoRoll2DHandler._SetTopbarPlusHidden(p)
	local topbarPlusState = PianoRoll2DHandler._TopbarPlusState
	local function getIcon()
		if topbarPlusState.icon ~= nil then
			return topbarPlusState.icon
		end

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local services = ReplicatedStorage:FindFirstChild("Services")
		local icon = services and services:FindFirstChild("Icon")

		if not icon then
			return nil
		end

		local success, result = pcall(require, icon)

		if not success or type(result) ~= "table" or type(result.setTopbarEnabled) ~= "function" then
			return nil
		end

		topbarPlusState.icon = result
		return result
	end

	local function isScreenGui(screenGui): boolean -- 1 equivalent call inferred from this helper
		if screenGui and screenGui:IsA("ScreenGui") then
			return screenGui.Name == "TopbarStandard"
				or screenGui.Name == "TopbarStandardClipped"
				or screenGui.Name == "TopbarCentered"
				or screenGui.Name == "TopbarCenteredClipped"
		end

		return false
	end

	local function rememberAndHideScreenGui(child) -- 2 equivalent calls inferred from this helper
		if not isScreenGui(child) then -- inferred equivalent call
			return
		end

		if topbarPlusState.guiStates[child] == nil then
			topbarPlusState.guiStates[child] = child.Enabled
		end

		child.Enabled = false
	end

	local function disconnectListeners() -- 1 equivalent call inferred from this helper
		if topbarPlusState.guiAddedConnection then
			topbarPlusState.guiAddedConnection:Disconnect()
			topbarPlusState.guiAddedConnection = nil
		end

		if topbarPlusState.iconAddedConnection then
			topbarPlusState.iconAddedConnection:Disconnect()
			topbarPlusState.iconAddedConnection = nil
		end
	end

	local function setScreenGuisHidden(p2)
		local localPlayer = PianoRoll2DHandler._LocalPlayer
		local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")

		if not playerGui then
			return
		end

		if p2 then
			for _, child in ipairs(playerGui:GetChildren()) do
				rememberAndHideScreenGui(child) -- inferred equivalent call
			end

			if not topbarPlusState.guiAddedConnection then
				topbarPlusState.guiAddedConnection = playerGui.ChildAdded:Connect(function(child)
					if topbarPlusState.suppressed then
						rememberAndHideScreenGui(child) -- inferred equivalent call
					end
				end)
			end
		else
			for k, guiState in pairs(topbarPlusState.guiStates) do
				if k.Parent then
					k.Enabled = guiState == true
				end
			end

			table.clear(topbarPlusState.guiStates)
		end
	end

	local function isPracticeTopbarIcon(object): boolean -- 1 equivalent call inferred from this helper
		if type(object) ~= "table" then
			return false
		end

		if object.name == "PracticeTopbar" then
			return true
		end

		local widget = object.widget
		return typeof(widget) == "Instance" and widget.Name == "PracticeTopbar"
	end

	local function rememberAndDisableIcon(object)
		if type(object) ~= "table" then
			return
		end

		if topbarPlusState.iconStates[object] == nil then
			topbarPlusState.iconStates[object] = object.isEnabled ~= false
		end

		if not isPracticeTopbarIcon(object) and type(object.deselect) == "function" and object.isSelected then -- inferred equivalent call
			pcall(function()
				object:deselect("PianoRoll2D")
			end)
		end

		if type(object.setEnabled) == "function" then
			pcall(function()
				object:setEnabled(false)
			end)
		end
	end

	local function setIconsEnabled(icon, p2) -- 2 equivalent calls inferred from this helper
		if not icon then
			return
		end

		if p2 then
			for k, iconState in pairs(topbarPlusState.iconStates) do
				if not (type(k) == "table" and type(k.setEnabled) == "function") then
					continue
				end

				pcall(function()
					k:setEnabled(iconState == true)
				end)
			end

			table.clear(topbarPlusState.iconStates)
		else
			if type(icon.getIcons) == "function" then
				for _, v48 in pairs(icon.getIcons()) do
					rememberAndDisableIcon(v48)
				end
			end

			if
				icon.iconAdded
				and type(icon.iconAdded.Connect) == "function"
				and not topbarPlusState.iconAddedConnection
			then
				topbarPlusState.iconAddedConnection = icon.iconAdded:Connect(function(p3)
					if topbarPlusState.suppressed then
						rememberAndDisableIcon(p3)
					end
				end)
			end
		end
	end

	local icon = getIcon()

	if p then
		if topbarPlusState.suppressed then
			setIconsEnabled(icon, false) -- inferred equivalent call

			if icon then
				pcall(function()
					icon.setTopbarEnabled(false)
				end)
			end
		else
			topbarPlusState.suppressed = true

			if icon and topbarPlusState.previousEnabled == nil then
				topbarPlusState.previousEnabled = icon.topbarEnabled ~= false
			end

			setIconsEnabled(icon, false) -- inferred equivalent call

			if icon then
				pcall(function()
					icon.setTopbarEnabled(false)
				end)
			end
		end

		setScreenGuisHidden(true)
	else
		if not topbarPlusState.suppressed then
			return
		end

		topbarPlusState.suppressed = false
		disconnectListeners() -- inferred equivalent call
		setIconsEnabled(icon, true)
		local localPlayer = PianoRoll2DHandler._LocalPlayer

		if localPlayer and localPlayer:FindFirstChild("PlayerGui") then
			for k, guiState in pairs(topbarPlusState.guiStates) do
				if k.Parent then
					k.Enabled = guiState == true
				end
			end

			table.clear(topbarPlusState.guiStates)
		end

		if not icon or topbarPlusState.previousEnabled == nil then
			topbarPlusState.previousEnabled = nil

			return
		end

		local previousEnabled = topbarPlusState.previousEnabled
		topbarPlusState.previousEnabled = nil
		pcall(function()
			icon.setTopbarEnabled(previousEnabled)
		end)
	end
end

local function setExternalOverlaysSuppressed(p) -- 1 equivalent call inferred from this helper
	PianoRoll2DHandler._SetTopbarPlusHidden(p)

	if not parent2 then
		return
	end

	if p then
		visibilityByGuiObject = visibilityByGuiObject or {}

		for _, childName in ipairs(v30) do
			local guiObject = parent2:FindFirstChild(childName)

			if not (guiObject and guiObject:IsA("GuiObject") and guiObject ~= pianoRoll2D) then
				continue
			end

			if visibilityByGuiObject[guiObject] == nil then
				visibilityByGuiObject[guiObject] = guiObject.Visible
			end

			guiObject.Visible = false
		end
	else
		if not visibilityByGuiObject then
			return
		end

		for guiObject, visible in pairs(visibilityByGuiObject) do
			if guiObject and guiObject.Parent and guiObject:IsA("GuiObject") then
				guiObject.Visible = visible
			end
		end

		visibilityByGuiObject = nil
	end
end

function PianoRoll2DHandler.EnsureExternalOverlaysSuppressed(): boolean
	if not (pianoRoll2D and pianoRoll2D.Visible) then
		return false
	end

	setExternalOverlaysSuppressed(true)
	raiseSourcePanelsAbove2D()

	if setOptionModeButtonActive then
		setOptionModeButtonActive(true)
	end

	return true
end

local function getJudgementY()
	return getCanvasHeight() -- inferred equivalent call
end

local function getFallSpeed()
	return getCanvasHeight() / 2.35 -- inferred equivalent call
end

local function getPlaybackSpeed() -- 3 equivalent calls inferred from this helper
	return (math.clamp(tonumber(PianoRoll2DHandler._PlaybackSpeed) or 1, 0.25, 4))
end

local function getTimelineNow(p) -- 4 equivalent calls inferred from this helper
	return ((p or tick()) - v40) * getPlaybackSpeed() -- inferred equivalent call
end

local function getTileHeightForDuration(p, value) -- 2 equivalent calls inferred from this helper
	return (math.max(value or 34, (tonumber(p) or 0.13) * (getCanvasHeight() / 2.35))) -- inferred equivalent call
end

local function getTileImage(parent, name)
	local image = parent:FindFirstChild(name)

	if image and image:IsA("ImageLabel") then
		return image
	end

	if image then
		image:Destroy()
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = name
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.Parent = parent
	return imageLabel
end

local function normalize2DHex(value, p) -- 5 equivalent calls inferred from this helper
	local upper = tostring(value or ""):gsub("#", ""):upper()

	if upper:match("^%x%x%x%x%x%x$") then
		return "#" .. upper
	end

	return p
end

local function hexTo2DColor3(value, p)
	local v48 = normalize2DHex(value) -- inferred equivalent call

	if not v48 then
		return p or Color3.fromRGB(95, 190, 255)
	end

	local v49 = v48:gsub("#", "")
	return Color3.fromRGB(tonumber(v49:sub(1, 2), 16), tonumber(v49:sub(3, 4), 16), (tonumber(v49:sub(5, 6), 16)))
end

local function normalize2DImageId(value)
	local v48 = tostring(value or ""):match("^%s*(.-)%s*$") or ""

	if v48 == "" then
		return ""
	end

	local v49 = v48:match("^rbxassetid://(%d+)$") or v48:match("^(%d+)$") or v48:match("roblox%.com/.*/(%d+)")

	if v49 then
		return "rbxassetid://" .. v49
	end

	return ""
end

local function get2DDisplayImageId(p) -- 1 equivalent call inferred from this helper
	local v48 = normalize2DImageId(p)
	local match = v48:match("^rbxassetid://(%d+)$")

	if match then
		return "rbxthumb://type=Asset&id=" .. match .. "&w=420&h=420"
	end

	return v48
end

local function normalize2DImpactShape(impactShape)
	local v48 = tostring(impactShape or PianoRoll2DHandler._Default2DSettings.ImpactShape)

	for _, v49 in ipairs(PianoRoll2DHandler._ImpactShapeOrder) do
		if v48:lower() == v49:lower() then
			return v49
		end
	end

	return PianoRoll2DHandler._Default2DSettings.ImpactShape
end

local function get2DSettingsPayload(p)
	local v48 = typeof(p) == "table" and p or {}
	local tileColorHex = normalize2DHex(v48.TileColorHex, PianoRoll2DHandler._Default2DSettings.TileColorHex) -- inferred equivalent call
	local whiteTileColorHex = normalize2DHex(v48.WhiteTileColorHex, tileColorHex) -- inferred equivalent call
	local blackTileColorHex = normalize2DHex( -- inferred equivalent call
		v48.BlackTileColorHex,
		PianoRoll2DHandler._Default2DSettings.BlackTileColorHex
	)

	if tileColorHex == "#5FBEFF" and whiteTileColorHex == "#5FBEFF" and blackTileColorHex == "#5FBEFF" then
		blackTileColorHex = PianoRoll2DHandler._Default2DSettings.BlackTileColorHex
	end

	return {
		TileColorHex = tileColorHex,
		WhiteTileColorHex = whiteTileColorHex,
		BlackTileColorHex = blackTileColorHex,
		ImpactColorHex = normalize2DHex(v48.ImpactColorHex, PianoRoll2DHandler._Default2DSettings.ImpactColorHex), -- inferred equivalent call
		ImpactShape = normalize2DImpactShape(v48.ImpactShape),
		BackgroundImage = normalize2DImageId(v48.BackgroundImage),
		BackgroundTransparency = math.clamp(
			math.floor(tonumber(v48.BackgroundTransparency) or PianoRoll2DHandler._Default2DSettings.BackgroundTransparency),
			0,
			100
		)
	}
end

local fn10
local function push2DSettingsToAttributes()
	if not PianoRoll2DHandler._LocalPlayer then
		return
	end

	PianoRoll2DHandler._LocalPlayer:SetAttribute("PianoRoll2DTileColorHex", PianoRoll2DHandler._2DSettings.TileColorHex)
	PianoRoll2DHandler._LocalPlayer:SetAttribute(
		"PianoRoll2DWhiteTileColorHex",
		PianoRoll2DHandler._2DSettings.WhiteTileColorHex
	)
	PianoRoll2DHandler._LocalPlayer:SetAttribute(
		"PianoRoll2DBlackTileColorHex",
		PianoRoll2DHandler._2DSettings.BlackTileColorHex
	)
	PianoRoll2DHandler._LocalPlayer:SetAttribute(
		"PianoRoll2DImpactColorHex",
		PianoRoll2DHandler._2DSettings.ImpactColorHex
	)
	PianoRoll2DHandler._LocalPlayer:SetAttribute("PianoRoll2DImpactShape", PianoRoll2DHandler._2DSettings.ImpactShape)
	PianoRoll2DHandler._LocalPlayer:SetAttribute(
		"PianoRoll2DBackgroundImage",
		PianoRoll2DHandler._2DSettings.BackgroundImage
	)
	PianoRoll2DHandler._LocalPlayer:SetAttribute(
		"PianoRoll2DBackgroundTransparency",
		PianoRoll2DHandler._2DSettings.BackgroundTransparency
	)
end

local function apply2DSettings(p) -- 3 equivalent calls inferred from this helper
	PianoRoll2DHandler._2DSettings = get2DSettingsPayload(p)
	push2DSettingsToAttributes()

	if fn10 then
		fn10()
	end
end

local function readLocal2DSettings()
	if PianoRoll2DHandler._LocalPlayer then
		apply2DSettings({ -- inferred equivalent call
			TileColorHex = PianoRoll2DHandler._LocalPlayer:GetAttribute("PianoRoll2DTileColorHex"),
			WhiteTileColorHex = PianoRoll2DHandler._LocalPlayer:GetAttribute("PianoRoll2DWhiteTileColorHex"),
			BlackTileColorHex = PianoRoll2DHandler._LocalPlayer:GetAttribute("PianoRoll2DBlackTileColorHex"),
			ImpactColorHex = PianoRoll2DHandler._LocalPlayer:GetAttribute("PianoRoll2DImpactColorHex"),
			ImpactShape = PianoRoll2DHandler._LocalPlayer:GetAttribute("PianoRoll2DImpactShape"),
			BackgroundImage = PianoRoll2DHandler._LocalPlayer:GetAttribute("PianoRoll2DBackgroundImage"),
			BackgroundTransparency = PianoRoll2DHandler._LocalPlayer:GetAttribute("PianoRoll2DBackgroundTransparency")
		})
	else
		apply2DSettings(PianoRoll2DHandler._Default2DSettings) -- inferred equivalent call
	end
end

fn10 = function()
	if not PianoRoll2DHandler._BackgroundImage and parent3 then
		local parent = parent3
		local backgroundImage = parent and parent:FindFirstChild("BackgroundImage")

		if not (backgroundImage and backgroundImage:IsA("ImageLabel")) then
			if backgroundImage then
				backgroundImage:Destroy()
			end

			backgroundImage = Instance.new("ImageLabel")
			backgroundImage.Name = "BackgroundImage"
			backgroundImage.Parent = parent
		end

		PianoRoll2DHandler._BackgroundImage = backgroundImage
	end

	if not PianoRoll2DHandler._BackgroundImage then
		return
	end

	PianoRoll2DHandler._BackgroundImage.Parent = parent3
	PianoRoll2DHandler._BackgroundImage.BackgroundTransparency = 1
	PianoRoll2DHandler._BackgroundImage.BorderSizePixel = 0
	PianoRoll2DHandler._BackgroundImage.ScaleType = Enum.ScaleType.Crop
	local v48 = normalize2DImageId(PianoRoll2DHandler._2DSettings.BackgroundImage)
	local backgroundImage = PianoRoll2DHandler._BackgroundImage
	backgroundImage.Image = get2DDisplayImageId(v48) -- inferred equivalent call
	PianoRoll2DHandler._BackgroundImage.Visible = v48 ~= ""

	if parent3 then
		parent3.BackgroundTransparency = v48 == "" and 0 or 1
	end

	PianoRoll2DHandler._BackgroundImage.ImageTransparency = math.clamp(
		(tonumber(PianoRoll2DHandler._2DSettings.BackgroundTransparency) or PianoRoll2DHandler._Default2DSettings.BackgroundTransparency) / 100,
		0,
		1
	)
	PianoRoll2DHandler._BackgroundImage.Size = UDim2.fromScale(1, 1)
	PianoRoll2DHandler._BackgroundImage.Position = UDim2.fromScale(0, 0)
	PianoRoll2DHandler._BackgroundImage.ZIndex = parent3 and parent3.ZIndex + 1 or 6202
end

local function get2DTileColor(p)
	local v48 = hexTo2DColor3(PianoRoll2DHandler._2DSettings.TileColorHex, Color3.fromRGB(95, 190, 255))
	local blackTileColorHex = is2DBlackNote(p) and PianoRoll2DHandler._2DSettings.BlackTileColorHex -- inferred equivalent call
		or PianoRoll2DHandler._2DSettings.WhiteTileColorHex
	return hexTo2DColor3(blackTileColorHex, v48)
end

local function get2DImpactColor(p) -- 1 equivalent call inferred from this helper
	return hexTo2DColor3(PianoRoll2DHandler._2DSettings.ImpactColorHex, p or get2DTileColor(nil))
end

local function get2DImpactShape() -- 1 equivalent call inferred from this helper
	return normalize2DImpactShape(PianoRoll2DHandler._2DSettings.ImpactShape)
end

local function applyTileVfx(parent, p, p2)
	if not parent then
		return
	end

	for _, childName in ipairs({ "TileVfxGlow", "TileVfxRay", "TileVfxBottomBurst", "TileTopShade" }) do
		local child = parent:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	local backgroundColor = p or Color3.fromRGB(95, 190, 255)
	parent.BackgroundColor3 = backgroundColor
	parent.BackgroundTransparency = p2 and 0.15 or 0.08
	parent.ClipsDescendants = true

	local tileGlowStroke = parent:FindFirstChild("TileGlowStroke")

	if not tileGlowStroke then
		tileGlowStroke = Instance.new("UIStroke")
		tileGlowStroke.Name = "TileGlowStroke"
		tileGlowStroke.Parent = parent
	end

	tileGlowStroke.Color = backgroundColor:Lerp(Color3.new(1, 1, 1), p2 and 0.62 or 0.54)
	tileGlowStroke.Thickness = p2 and 1.2 or 1.1
	tileGlowStroke.Transparency = p2 and 0.2 or 0.24

	local tileGlowGradient = parent:FindFirstChild("TileGlowGradient")

	if tileGlowGradient then
		tileGlowGradient:Destroy()
	end

	local tileEdgeShine = parent:FindFirstChild("TileEdgeShine")

	if not tileEdgeShine then
		tileEdgeShine = Instance.new("Frame")
		tileEdgeShine.Name = "TileEdgeShine"
		tileEdgeShine.BorderSizePixel = 0
		tileEdgeShine.BackgroundColor3 = Color3.fromRGB(245, 252, 255)
		tileEdgeShine.Parent = parent
	end

	tileEdgeShine.BackgroundTransparency = p2 and 0.34 or 0.46
	tileEdgeShine.Position = UDim2.new(0, 2, 0, 5)
	tileEdgeShine.Size = UDim2.new(0, 2, 1, -10)
	tileEdgeShine.ZIndex = math.min(parent.ZIndex + 2, 6208)
end

local function tweenOutAndDestroy(instance, duration, goal)
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		goal
	)
	tween:Play()
	task.delay(duration + 0.08, function()
		if instance then
			instance:Destroy()
		end
	end)
	return tween
end

local function getImpactPoint(p)
	if not (pianoRoll2D and parent3) then
		return nil
	end

	local v48 = math.max(pianoRoll2D.AbsoluteSize.X, 1)
	local keySlot, v49 = getKeySlot(p)
	v48 = keyFrame and keyFrame.AbsoluteSize.X > 0 and keyFrame.AbsoluteSize.X or v48
	local v50 = math.max(v49 * v48, 10)
	local v51 = (keySlot + v49 * 0.5) * v48

	if keyFrame then
		v51 += keyFrame.AbsolutePosition.X - pianoRoll2D.AbsolutePosition.X
	end

	return v51, parent3.AbsolutePosition.Y - pianoRoll2D.AbsolutePosition.Y + getCanvasHeight(), v50 -- inferred equivalent call
end

local function makeImpactFrame(frame, name, backgroundColor, backgroundTransparency, value)
	local frame2 = Instance.new("Frame")
	frame2.Name = name
	frame2.BackgroundColor3 = backgroundColor
	frame2.BackgroundTransparency = backgroundTransparency
	frame2.BorderSizePixel = 0
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Position = UDim2.fromScale(0.5, 0.5)
	frame2.ZIndex = frame.ZIndex + (value or 1)
	frame2.Parent = frame
	return frame2
end

local function spawnJudgementImpact(note, backgroundColor3, p)
	if not (pianoRoll2D and pianoRoll2D.Visible) then
		return
	end

	local impactPoint, v48, v49 = getImpactPoint(note)

	if not impactPoint then
		return
	end

	local v50 = get2DImpactColor(backgroundColor3 or Color3.fromRGB(95, 190, 255)) -- inferred equivalent call
	local name = get2DImpactShape() -- inferred equivalent call
	local frame = Instance.new("Frame")
	frame.Name = "JudgementImpact_" .. tostring(note)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromOffset(impactPoint, v48)
	frame.Size = UDim2.fromOffset(math.max(v49 * 3.1, 86), 82)
	frame.ZIndex = 6270
	frame.Parent = pianoRoll2D

	if name == "Circle" then
		local v52 = math.max(v49 * 1.45, 36)
		local circle = Instance.new("Frame")
		circle.Name = "Circle"
		circle.BackgroundTransparency = 1
		circle.BorderSizePixel = 0
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Position = UDim2.fromScale(0.5, 0.5)
		circle.Size = UDim2.fromOffset(v52, v52)
		circle.ZIndex = frame.ZIndex + 3
		circle.Parent = frame
		makeCorner(circle, v52) -- inferred equivalent call
		local lerped = v50:Lerp(Color3.new(1, 1, 1), 0.42)
		local uiStroke = circle:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
		uiStroke.Color = lerped
		uiStroke.Thickness = p and 4 or 3 or 1
		uiStroke.Parent = circle

		uiStroke.Transparency = 0.02
		TweenService:Create(uiStroke, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		tweenOutAndDestroy(circle, 0.34, {
			Size = UDim2.fromOffset(math.max(v49 * 3.6, 86), (math.max(v49 * 3.6, 86)))
		})

		task.delay(0.42, function()
			if frame then
				frame:Destroy()
			end
		end)
	elseif name == "Diamond" then
		local v52 = math.max(v49 * 1.35, 34)
		local diamond = Instance.new("Frame")
		diamond.Name = "Diamond"
		diamond.BackgroundTransparency = 1
		diamond.BorderSizePixel = 0
		diamond.AnchorPoint = Vector2.new(0.5, 0.5)
		diamond.Position = UDim2.fromScale(0.5, 0.5)
		diamond.Size = UDim2.fromOffset(v52, v52)
		diamond.Rotation = 45
		diamond.ZIndex = frame.ZIndex + 3
		diamond.Parent = frame
		local lerped = v50:Lerp(Color3.new(1, 1, 1), 0.38)
		local uiStroke = diamond:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
		uiStroke.Color = lerped
		uiStroke.Thickness = p and 4 or 3 or 1
		uiStroke.Parent = diamond

		TweenService:Create(uiStroke, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		tweenOutAndDestroy(diamond, 0.34, {
			Size = UDim2.fromOffset(math.max(v49 * 3.2, 78), (math.max(v49 * 3.2, 78))),
			Rotation = 45
		})

		task.delay(0.42, function()
			if frame then
				frame:Destroy()
			end
		end)
	elseif name == "Heart" or name == "Star" then
		local textLabel = Instance.new("TextLabel")
		textLabel.Name = name
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.Size = UDim2.fromOffset(math.max(v49 * 2.1, 48), (math.max(v49 * 2.1, 48)))
		textLabel.Font = Enum.Font.GothamBold
		textLabel.Text = name == "Heart" and utf8.char(9829) or utf8.char(9733)
		textLabel.TextColor3 = v50:Lerp(Color3.new(1, 1, 1), 0.24)
		textLabel.TextTransparency = 0.05
		textLabel.TextScaled = true
		textLabel.ZIndex = frame.ZIndex + 3
		textLabel.Parent = frame
		TweenService:Create(textLabel, TweenInfo.new(0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1,
			Size = UDim2.fromOffset(math.max(v49 * 4.2, 112), (math.max(v49 * 4.2, 112))),
			Rotation = name == "Star" and 22 or 0
		}):Play()
		task.delay(0.44, function()
			if frame then
				frame:Destroy()
			end
		end)
	else
		local impactShapeTexture = PianoRoll2DHandler._ImpactShapeTextures[name]

		if impactShapeTexture then
			local impactShape = Instance.new("ImageLabel")
			impactShape.Name = "ImpactShape"
			impactShape.BackgroundTransparency = 1
			impactShape.BorderSizePixel = 0
			impactShape.AnchorPoint = Vector2.new(0.5, 0.5)
			impactShape.Position = UDim2.fromScale(0.5, 0.5)
			impactShape.Size = UDim2.fromOffset(math.max(v49 * 4.2, 104), name == "Ray" and 110 or 104)
			impactShape.Image = impactShapeTexture
			impactShape.ImageColor3 = v50:Lerp(Color3.new(1, 1, 1), 0.22)
			impactShape.ImageTransparency = 0.08
			impactShape.Rotation = name == "Ray" and 90 or 0
			impactShape.ZIndex = frame.ZIndex + 5
			impactShape.Parent = frame
			tweenOutAndDestroy(impactShape, 0.42, {
				ImageTransparency = 1,
				Size = UDim2.fromOffset(math.max(v49 * 7.2, 176), name == "Ray" and 160 or 176),
				Rotation = impactShape.Rotation + (name == "Burst" and 18 or 0)
			})
		end

		local impactFrame = makeImpactFrame(frame, "Glow", v50:Lerp(Color3.new(1, 1, 1), 0.26), 0.18, 1)
		impactFrame.Size = UDim2.fromOffset(math.max(v49 * 3.5, 86), 42)
		makeCorner(impactFrame, 28) -- inferred equivalent call
		tweenOutAndDestroy(impactFrame, 0.38, {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(math.max(v49 * 7, 168), 82)
		})

		local impactFrame2 = makeImpactFrame(frame, "Bloom", v50:Lerp(Color3.new(1, 1, 1), 0.42), 0.28, 2)
		impactFrame2.Size = UDim2.fromOffset(math.max(v49 * 1.45, 34), 62)
		makeCorner(impactFrame2, 32) -- inferred equivalent call
		tweenOutAndDestroy(impactFrame2, 0.34, {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(math.max(v49 * 2.9, 72), 102)
		})

		local ring = Instance.new("Frame")
		ring.Name = "Ring"
		ring.BackgroundTransparency = 1
		ring.BorderSizePixel = 0
		ring.AnchorPoint = Vector2.new(0.5, 0.5)
		ring.Position = UDim2.fromScale(0.5, 0.5)
		ring.Size = UDim2.fromOffset(math.max(v49 * 2.8, 60), 34)
		ring.ZIndex = frame.ZIndex + 3
		ring.Parent = frame
		makeCorner(ring, 26) -- inferred equivalent call
		local lerped = v50:Lerp(Color3.new(1, 1, 1), 0.52)
		local uiStroke = ring:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
		uiStroke.Color = lerped
		uiStroke.Thickness = p and 4 or 3 or 1
		uiStroke.Parent = ring

		uiStroke.Transparency = 0.02
		tweenOutAndDestroy(ring, 0.34, {
			Size = UDim2.fromOffset(math.max(v49 * 5.4, 130), 64)
		})

		TweenService:Create(uiStroke, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()

		local hotLine = Instance.new("Frame")
		hotLine.Name = "HotLine"
		hotLine.AnchorPoint = Vector2.new(0.5, 0.5)
		hotLine.Position = UDim2.fromScale(0.5, 0.5)
		hotLine.Size = UDim2.fromOffset(math.max(v49 * 3.5, 88), p and 7 or 5)
		hotLine.BackgroundColor3 = v50:Lerp(Color3.new(1, 1, 1), 0.7)
		hotLine.BackgroundTransparency = 0.01
		hotLine.BorderSizePixel = 0
		hotLine.ZIndex = frame.ZIndex + 4
		hotLine.Parent = frame
		makeCorner(hotLine, 8) -- inferred equivalent call
		tweenOutAndDestroy(hotLine, 0.28, {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(math.max(v49 * 6.6, 160), 2)
		})

		task.delay(0.48, function()
			if frame then
				frame:Destroy()
			end
		end)
	end
end

local function createTile(note, display, p, tokenIndex, eventTime, p2)
	if not parent3 then
		return nil
	end

	local v48 = table.remove(frames)

	if not v48 then
		v48 = Instance.new("Frame")
		v48.BorderSizePixel = 0
		v48.AnchorPoint = Vector2.new(0, 0)
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 5)
		uiCorner.Parent = v48
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1, 1)
		label.Font = Enum.Font.GothamBlack
		label.TextSize = 13
		label.TextScaled = true
		label.TextWrapped = false
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextStrokeTransparency = 0.45
		local tileLabelTextSizeLimit = Instance.new("UITextSizeConstraint")
		tileLabelTextSizeLimit.Name = "TileLabelTextSizeLimit"
		tileLabelTextSizeLimit.MinTextSize = 8
		tileLabelTextSizeLimit.MaxTextSize = 14
		tileLabelTextSizeLimit.Parent = label
		label.Parent = v48
	end

	local keySlot, v49 = getKeySlot(note)
	local height = math.max(2, tonumber(p2) or 34)
	v48.Name = "Tile_" .. tostring(note)
	v48.AnchorPoint = Vector2.new(0, 0)
	v48.Position = UDim2.new(keySlot, 0, 0, -height)
	v48.Size = UDim2.new(v49, -2, 0, height)
	v48.ZIndex = 6205
	v48.ClipsDescendants = true
	applyTileVfx(v48, p or Color3.fromRGB(95, 190, 255), false)
	v48.Visible = true
	v48.Parent = parent3
	local label = v48:FindFirstChild("Label")

	if label then
		label.TextScaled = true
		label.TextWrapped = false
		local tileLabelTextSizeLimit = label:FindFirstChild("TileLabelTextSizeLimit")

		if not tileLabelTextSizeLimit then
			tileLabelTextSizeLimit = Instance.new("UITextSizeConstraint")
			tileLabelTextSizeLimit.Name = "TileLabelTextSizeLimit"
			tileLabelTextSizeLimit.Parent = label
		end

		tileLabelTextSizeLimit.MinTextSize = 8
		tileLabelTextSizeLimit.MaxTextSize = 14
		label.Text = display or ""
		label.Visible = display ~= nil and display ~= ""
		label.ZIndex = v48.ZIndex + 5
	end

	local v51 = {
		frame = v48,
		note = note,
		display = display,
		tokenIndex = tokenIndex,
		eventTime = eventTime,
		y = -height,
		height = height
	}

	table.insert(v41, v51)
	return v51
end

local function disconnectManualEffectRender() -- 2 equivalent calls inferred from this helper
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

local function getManualEffectHeight(p) -- 2 equivalent calls inferred from this helper
	local v48 = math.max(8, (math.min(9999, getCanvasHeight() - 2))) -- inferred equivalent call
	return (math.clamp(8 + p * 310, 8, v48))
end

local function updateManualEffectCorner(frame, p) -- 3 equivalent calls inferred from this helper
	local uiCorner = frame and frame:FindFirstChildOfClass("UICorner")

	if uiCorner then
		uiCorner.CornerRadius = UDim.new(0, (math.clamp(math.floor((tonumber(p) or 8) / 2), 3, 7)))
	end
end

local function separateReleasedManualEffects(p)
	local v48 = tonumber(p)

	if not v48 then
		return
	end

	local v49 = {}

	for _, v50 in pairs(v42) do
		if not (v50 and v50.released and tonumber(v50.note) == v48 and v50.frame) then
			continue
		end

		if not v50.frame.Parent then
			continue
		end

		table.insert(v49, v50)
	end

	if #v49 == 0 then
		return
	end

	table.sort(v49, function(a, b): boolean
		return a.frame.Position.Y.Offset > b.frame.Position.Y.Offset
	end)
	local releaseStartY = getCanvasHeight() - 8 - 5 -- inferred equivalent call

	local now = tick()

	for _, v51 in ipairs(v49) do
		local frame = v51.frame
		local v52 = frame.Position.Y.Offset
		local v53 = math.max(v51.releaseHeight or frame.Size.Y.Offset, 8)

		if releaseStartY < v52 then
			frame.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, 0, releaseStartY)
			v51.releaseStartY = releaseStartY
			v51.releaseStartedAt = now
			v52 = releaseStartY
		end

		releaseStartY = v52 - v53 - 5
	end
end

local function updateManualEffects(p)
	math.max(0, tonumber(p) or 1 / 60)
	local v48 = false

	for k, v49 in pairs(v42) do
		local note = tonumber(v49.note) or tonumber(k)
		local frame = v49.frame

		if note and frame and frame.Parent and parent3 and pianoRoll2D and pianoRoll2D.Visible then
			if v49.released then
				local v50 = math.max(0, tick() - (v49.releaseStartedAt or tick()))
				local v51 = (v49.releaseStartY or frame.Position.Y.Offset) - v50 * 310

				if v51 <= -24 then
					v42[k] = nil
					frame:Destroy()
				else
					v48 = true
					local keySlot, v52 = getKeySlot(note)
					frame.Position = UDim2.new(keySlot, 0, 0, v51)
					local releaseHeight = v49.releaseHeight or frame.Size.Y.Offset
					frame.Size = UDim2.new(v52, -2, 0, releaseHeight)
					updateManualEffectCorner(frame, releaseHeight) -- inferred equivalent call
					updateManualEffectCorner(frame, releaseHeight) -- inferred equivalent call
				end
			else
				local manualEffectHeight = getManualEffectHeight(math.max(0, tick() - v49.startedAt)) -- inferred equivalent call

				local keySlot, v50 = getKeySlot(note)
				frame.Position = UDim2.new(keySlot, 0, 0, getCanvasHeight()) -- inferred equivalent call
				frame.Size = UDim2.new(v50, -2, 0, manualEffectHeight)
				v48 = true
			end
		else
			v42[k] = nil
		end
	end

	if not v48 then
		disconnectManualEffectRender() -- inferred equivalent call
	end
end

local function startManualEffectRender() -- 2 equivalent calls inferred from this helper
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(updateManualEffects)
end

local fn11
local function beginManualEffect(p)
	local note = tonumber(p)

	if not (note and parent3 and pianoRoll2D and pianoRoll2D.Visible) then
		return
	end

	if v42[note] and fn11 then
		local v49 = v42[note]

		if not v49.released then
			return
		end

		count4 += 1
		v42["released_" .. tostring(note) .. "_" .. tostring(count4)] = v49
		v42[note] = nil
	end

	separateReleasedManualEffects(note)
	local keySlot, v49 = getKeySlot(note)
	local frame = Instance.new("Frame")
	frame.Name = "ManualEffect_" .. tostring(note)
	frame.AnchorPoint = Vector2.new(0, 1)
	frame.Position = UDim2.new(keySlot, 0, 0, getCanvasHeight()) -- inferred equivalent call
	frame.Size = UDim2.new(v49, -2, 0, 8)
	frame.BorderSizePixel = 0
	frame.ZIndex = 6206
	frame.ClipsDescendants = false
	makeCorner(frame, 4) -- inferred equivalent call
	applyTileVfx(frame, get2DTileColor(note), true)
	frame.Parent = parent3
	v42[note] = { note = note, frame = frame, startedAt = tick() }
	startManualEffectRender() -- inferred equivalent call
end

fn11 = function(p, p2)
	local v48 = tonumber(p)
	local v49 = v48 and v42[v48]

	if not v49 then
		return
	end

	local frame = v49.frame

	if not frame then
		v42[v48] = nil
	elseif p2 then
		v42[v48] = nil
		frame:Destroy()
	else
		if v49.released then
			return
		end

		local manualEffectHeight = getManualEffectHeight(tick() - (v49.startedAt or tick())) -- inferred equivalent call
		local v50 = math.max(frame.AbsoluteSize.Y, frame.Size.Y.Offset, manualEffectHeight, 8)
		local v51 = math.max(8, getCanvasHeight() - 2) -- inferred equivalent call
		local releaseHeight = math.clamp(math.max(v50, 8), 8, v51)
		frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, releaseHeight)
		updateManualEffectCorner(frame, releaseHeight) -- inferred equivalent call
		v49.releaseHeight = releaseHeight
		v49.released = true
		v49.releaseStartedAt = tick()
		v49.releaseStartY = frame.Position.Y.Offset
		v42[v48] = v49
		startManualEffectRender() -- inferred equivalent call
	end
end

local function clearManualEffects()
	for k, v48 in pairs(v42) do
		local frame = v48 and v48.frame

		if frame then
			frame:Destroy()
		end

		v42[k] = nil
	end

	table.clear(v42)
	disconnectManualEffectRender() -- inferred equivalent call
end

local function parseSheet(value)
	local v48 = tostring(value or "")
	local v49 = 1
	local sheet = {}

	while v49 <= #v48 do
		local display = v48:sub(v49, v49)

		if v[display] then
			v49 += 1
		elseif display == "[" then
			local v51 = v48:find("]", v49 + 1, true)

			if v51 then
				local v52 = v48:sub(v49 + 1, v51 - 1)
				local set3 = {}
				local chars = {}
				local notes = {}

				for i = 1, #v52 do
					local v55 = v52:sub(i, i)

					if not isValidChar(v55) or set3[v55] then -- inferred equivalent call
						continue
					end

					local v56 = charToNote(v55) -- inferred equivalent call

					if not v56 then
						continue
					end

					set3[v55] = true
					table.insert(chars, v55)
					table.insert(notes, v56)
				end

				if #notes > 0 then
					table.insert(sheet, {
						chars = chars,
						notes = notes,
						display = "[" .. table.concat(chars, "") .. "]"
					})
				end

				v49 = v51 + 1
			else
				v49 += 1
			end
		else
			if isValidChar(display) then -- inferred equivalent call
				local v51 = charToNote(display) -- inferred equivalent call

				if v51 then
					table.insert(sheet, {
						chars = { display },
						notes = { v51 },
						display = display
					})
				end
			end

			v49 += 1
		end
	end

	return sheet
end

local function copyList(list) -- 3 equivalent calls inferred from this helper
	local result = {}

	if typeof(list) == "table" then
		for i, item in ipairs(list) do
			result[i] = item
		end
	end

	return result
end

local function buildDisplay(list, options)
	if typeof(list) == "table" and #list > 0 then
		if #list == 1 then
			return (tostring(list[1]))
		end

		return "[" .. table.concat(list, "") .. "]"
	else
		local v48 = {}

		for _, v49 in ipairs(options or {}) do
			table.insert(v48, (tostring(v49)))
		end

		return table.concat(v48, "+")
	end
end

local function cloneSourceToken(data, p)
	if typeof(data) ~= "table" then
		return nil
	end

	local notes2 = {}
	local notes = data.notes or data.Notes

	if typeof(notes) == "table" then
		for _, note in ipairs(notes) do
			local v49 = tonumber(note)

			if v49 and v49 >= -14 and v49 <= 73 then
				table.insert(notes2, v49)
			end
		end
	else
		local note = tonumber(data.note or data.NoteNumber)

		if note and note >= -14 and note <= 73 then
			table.insert(notes2, note)
		end
	end

	if #notes2 == 0 then
		return nil
	end

	local chars = copyList(data.chars or data.Chars) -- inferred equivalent call
	local velocities = copyList(data.velocities or data.Velocities) -- inferred equivalent call
	local durations = data.durations or data.Durations
	local visualDurations = data.visualDurations or data.VisualDurations
	local duration = math.max(0.05, tonumber(data.duration or data.Duration) or 0.13)
	local durations2 = {}
	local visualDurations2 = {}

	for i = 1, #notes2 do
		local v54

		if typeof(durations) == "table" and durations[i] ~= nil then
			v54 = tonumber(durations[i]) or duration
		else
			v54 = duration
		end

		local v55 = math.max(0.05, v54)
		durations2[i] = v55

		if typeof(visualDurations) == "table" and visualDurations[i] ~= nil then
			visualDurations2[i] = math.max(0.01, tonumber(visualDurations[i]) or v55)
		end

		duration = math.max(duration, v55)
	end

	local sourceTime = tonumber(data.sourceTime or data.SourceTime)
	local eventTime = tonumber(data.eventTime or data.EventTime)
	local eventTime2

	if p then
		eventTime2 = eventTime or 2.35 + (sourceTime or 0)
	end

	return {
		chars = chars,
		notes = notes2,
		display = tostring(data.display or data.Display or buildDisplay(chars, notes2)),
		duration = duration,
		durations = durations2,
		visualDurations = visualDurations2,
		velocities = velocities,
		sourceTime = sourceTime,
		eventTime = eventTime2
	}
end

local function cloneSourceTokens(list, p)
	local sourceTokens = {}

	if typeof(list) == "table" then
		for _, item in ipairs(list) do
			local sourceToken = cloneSourceToken(item, p)

			if sourceToken then
				table.insert(sourceTokens, sourceToken)
			end
		end
	end

	if p then
		table.sort(sourceTokens, function(a, b): boolean
			return (a.eventTime or 0) < (b.eventTime or 0)
		end)
	end

	return sourceTokens
end

local function groupTimedPresses(list)
	table.sort(list, function(a, b): boolean
		if a.time == b.time then
			return a.note < b.note
		end

		return a.time < b.time
	end)
	local v48 = nil
	local result = {}

	for _, item in ipairs(list) do
		local time = tonumber(item.time) or 0

		if not v48 or math.abs(time - v48.sourceTime) > 0.035 then
			v48 = {
				notes = {},
				chars = {},
				durations = {},
				velocities = {},
				sourceTime = time,
				duration = 0.13
			}

			table.insert(result, v48)
		end

		table.insert(v48.notes, item.note)

		if item.char then
			table.insert(v48.chars, item.char)
		end

		table.insert(v48.durations, (math.max(0.05, item.duration or 0.13)))
		table.insert(v48.velocities, item.velocity)
		v48.duration = math.max(v48.duration, item.duration or 0.13)
		v48.display = #v48.chars > 0 and buildDisplay(v48.chars, v48.notes) or ""
	end

	return result
end

local function buildRecordingTokens(p)
	local notes = p and p.Notes

	if typeof(notes) ~= "table" then
		return {}
	end

	local result = copyList(notes) -- inferred equivalent call
	table.sort(result, function(a, b): boolean
		return (tonumber(a.Timestamp) or 0) < (tonumber(b.Timestamp) or 0)
	end)

	local v49 = {}
	local v50 = {}

	for _, v51 in ipairs(result) do
		local noteNumber = tonumber(v51.NoteNumber)

		if not (noteNumber and noteNumber >= -14 and noteNumber <= 73) then
			continue
		end

		local timestamp = tonumber(v51.Timestamp) or 0

		if v51.Action == "Press" then
			local v52 = {
				time = timestamp,
				note = noteNumber,
				velocity = tonumber(v51.Velocity) or nil,
				duration = 0.13
			}

			table.insert(v50, v52)
			v49[noteNumber] = v49[noteNumber] or {}
			table.insert(v49[noteNumber], v52)
		elseif v51.Action == "Release" then
			local v52 = v49[noteNumber]

			if v52 and #v52 > 0 then
				local v53 = table.remove(v52, 1)
				v53.duration = math.max(0.05, timestamp - v53.time)
			end
		end
	end

	return groupTimedPresses(v50)
end

local function setLoadedSource(data): boolean
	if typeof(data) ~= "table" then
		return false
	end

	local v48 = data.usesTiming == true or data.timed == true or data.Timed == true
	local tokens = data.tokens or data.Tokens
	local sourceTokens = cloneSourceTokens(tokens, v48)

	if #sourceTokens == 0 then
		setText(v5, "That source has no playable notes.", Color3.fromRGB(255, 190, 80)) -- inferred equivalent call
		return false
	else
		v23 = tostring(data.name or data.Name or "Loaded Source")
		v24 = tostring(data.kind or data.Kind or v22 or "Source")
		v25 = sourceTokens
		v36 = cloneSourceTokens(sourceTokens, v48)
		v26 = v48
		tempo = tonumber(data.tempo or data.Tempo)
		v22 = v24

		if fn9 then
			fn9(true)
		end

		if pianoRoll2D then
			pianoRoll2D.Visible = true
			setExternalOverlaysSuppressed(true)
			raiseSourcePanelsAbove2D()
			setOptionModeButtonActive(true)
		end

		local v49 = v23 .. " loaded. Choose a play mode."

		if data.showModePanel == false then
			v49 = v23 .. " loaded. Press Play in the MIDI player to choose 2D mode."
		end

		setText(v5, v49, Color3.fromRGB(120, 210, 255)) -- inferred equivalent call

		if data.showModePanel == false then
			if fn7 then
				fn7()
			end
		elseif fn8 then
			fn8(v24, v23 .. " loaded. Choose how to play it.")
		end

		fn6()
		markActivity() -- inferred equivalent call
		return true
	end
end

fn6 = function()
	if not v6 then
		return
	end

	local count5 = #v36
	local v48 = math.clamp(v37, 1, (math.max(count5, 1)))

	if mode == "Listen" then
		v48 = math.clamp(v39 - 1, 0, count5)
	elseif mode == "Rhythm" then
		v48 = math.clamp(math.max(v38 - 1, v39 - 1), 0, count5)
	elseif mode == "Wait" then
		v48 = math.clamp(v37 - 1, 0, count5)
	end

	if mode == "Wait" then
		local v49 = v6
		local v51 = count5 > 0 and v48 or 0
		v49.Text = string.format(
			"%d/%d notes    Hits: %d    Misses: %d    Acc: %d%%",
			v51,
			count5,
			count2,
			count3,
			getAccuracyPercent() -- inferred equivalent call
		)
	else
		local v49 = v6
		local v51 = count5 > 0 and v48 or 0
		v49.Text = string.format(
			"%d / %d    Hits: %d    Misses: %d    Acc: %d%%",
			v51,
			count5,
			count2,
			count3,
			getAccuracyPercent() -- inferred equivalent call
		)
	end
end

local function disconnectRender() -- 3 equivalent calls inferred from this helper
	if heartbeatConnection2 then
		heartbeatConnection2:Disconnect()
		heartbeatConnection2 = nil
	end
end

fn9 = function(p)
	v32 = false
	flag = false
	lastTime = 0
	mode = nil
	disconnectRender() -- inferred equivalent call
	clearTiles() -- inferred equivalent call
	clearManualEffects()
	table.clear(PianoRoll2DHandler._HoldState.active)

	if fn then
		fn()
	end

	if fn2 then
		fn2()
	end

	if fn3 then
		fn3()
	end

	table.clear(set)
	table.clear(tokenIndexSet)
	table.clear(set2)
	table.clear(v43)
	table.clear(v44)
	table.clear(PianoRoll2DHandler._HoldState.active)
	table.clear(PianoRoll2DHandler._HoldState.scores)
	table.clear(PianoRoll2DHandler._HoldState.labels)
	table.clear(PianoRoll2DHandler._HoldState.colors)
	v46 = false
	flag2 = false
	v47 = nil
	total = 0
	total2 = 0

	if not p and pianoRoll2D then
		pianoRoll2D.Visible = false
		setExternalOverlaysSuppressed(false) -- inferred equivalent call
		setOptionModeButtonActive(false)
	end

	setText(v9, "Mode: -", Color3.fromRGB(170, 176, 190)) -- inferred equivalent call
	fn6()
end

local function allNotesMatched(p): boolean
	local v48 = v36[p]

	if not v48 then
		return false
	end

	local v49 = v43[p] or {}

	for _, note in ipairs(v48.notes) do
		if not v49[note] then
			return false
		end
	end

	return true
end

local function allCharsMatched(activeWaitTarget): boolean
	local v48 = v36[activeWaitTarget]

	if not v48 then
		return false
	end

	local v49 = v44[activeWaitTarget] or {}

	for _, char in ipairs(v48.chars) do
		if not v49[char] then
			return false
		end
	end

	return true
end

function PianoRoll2DHandler._GetTokenNoteDuration(data, p)
	if not data then
		return 0.13
	end

	for i, v48 in ipairs(data.notes or {}) do
		if v48 == p then
			return (math.max(0.05, tonumber(data.durations and data.durations[i]) or tonumber(data.duration) or 0.13))
		end
	end

	return (math.max(0.05, tonumber(data.duration) or 0.13))
end

function PianoRoll2DHandler._NoteRequiresHold(p): boolean
	return (tonumber(p) or 0.13) >= 0.22
end

function PianoRoll2DHandler._GetTimingJudgement(p)
	local v48 = "Good"
	local v49 = 70
	local color = Color3.fromRGB(120, 210, 255)

	if p <= 0.08 then
		return "Perfect", 100, (Color3.fromRGB(95, 225, 125))
	end

	if p <= 0.16 then
		color = Color3.fromRGB(120, 210, 255)
		v48 = "Great"
		v49 = 85
	end

	return v48, v49, color
end

function PianoRoll2DHandler._SetTokenJudgement(p, p2, value, p3)
	if not p then
		return
	end

	local v48 = tonumber(p2) or 100
	local score = PianoRoll2DHandler._HoldState.scores[p]

	if score == nil or v48 < score then
		PianoRoll2DHandler._HoldState.scores[p] = v48
		PianoRoll2DHandler._HoldState.labels[p] = value or "Perfect"
		PianoRoll2DHandler._HoldState.colors[p] = p3 or Color3.fromRGB(95, 225, 125)
	end
end

function PianoRoll2DHandler._GetTokenJudgement(p, value, value2, p2)
	return
		PianoRoll2DHandler._HoldState.scores[p] or value or 100,
		PianoRoll2DHandler._HoldState.labels[p] or value2 or "Perfect",
		PianoRoll2DHandler._HoldState.colors[p] or p2 or Color3.fromRGB(95, 225, 125)
end

function PianoRoll2DHandler._ClearActiveHoldsForToken(p)
	for k, v48 in pairs(PianoRoll2DHandler._HoldState.active) do
		if v48 and v48.tokenIndex == p then
			PianoRoll2DHandler._HoldState.active[k] = nil
		end
	end
end

local function spawnWaitToken()
	clearTiles() -- inferred equivalent call
	local v48 = v36[v37]

	if v48 then
		v45 = 0
		v46 = false
		v43[v37] = {}
		v44[v37] = {}

		for i, note in ipairs(v48.notes) do
			local v49 = v48.durations and v48.durations[i] or v48.duration or 0.13
			createTile(note, v48.chars[i] or v48.display, get2DTileColor(note), v37, nil, getTileHeightForDuration(v49)) -- inferred equivalent call
		end

		if fn4 then
			fn4(v48, Color3.fromRGB(255, 190, 80))
		end

		setText(v5, "Press: " .. v48.display, Color3.fromRGB(255, 190, 80)) -- inferred equivalent call
		fn6()
	else
		v32 = false
		local v49 = v5
		setText( -- inferred equivalent call
			v49,
			string.format("Complete. %d hits, %d misses. Accuracy %d%%.", count2, count3, getAccuracyPercent()), -- inferred equivalent call
			Color3.fromRGB(95, 225, 125)
		)
		setText(v9, "Mode: Wait", Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
		fn6()
	end
end

local function colorTokenTiles(p, p2)
	for _, v48 in ipairs(v41) do
		if v48.tokenIndex == p and v48.frame then
			applyTileVfx(v48.frame, p2, false)
		end
	end
end

function PianoRoll2DHandler._ReleaseTokenNoteTiles(p, p2)
	for i = #v41, 1, -1 do
		local v48 = v41[i]

		if not (v48.tokenIndex == p and (p2 == nil or v48.note == p2)) then
			continue
		end

		releaseTile(v48) -- inferred equivalent call
		table.remove(v41, i)
	end
end

local function findReadyWaitToken(p)
	for i, v48 in ipairs(v36) do
		if v48 and not set[i] and v48.eventTime and v48.eventTime <= p then
			return i
		end
	end

	return nil
end

local function beginWaitPause(p)
	local v48 = v36[p]

	if not v48 or set[p] then
		return nil
	end

	flag2 = true
	v47 = p
	v37 = p
	v43[p] = v43[p] or {}
	v44[p] = v44[p] or {}
	local eventTime = v48.eventTime or tick() - v40
	v40 = tick() - eventTime

	if fn4 then
		fn4(v48, Color3.fromRGB(78, 180, 255))
	end

	setText(v5, "Press: " .. v48.display, Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
	fn6()
	return eventTime
end

local function getActiveWaitTarget() -- 2 equivalent calls inferred from this helper
	if flag2 and v47 then
		return v47
	end

	local readyWaitToken = findReadyWaitToken(tick() - v40)

	if not readyWaitToken then
		return nil
	end

	beginWaitPause(readyWaitToken)
	return readyWaitToken
end

local function advanceWaitToken(p)
	local v48 = p or v47 or v37

	if not v36[v48] or set[v48] then
		return
	end

	local tokenJudgement, v49, textColor = PianoRoll2DHandler._GetTokenJudgement(
		v48,
		100,
		"Perfect",
		Color3.fromRGB(95, 225, 125)
	)
	set[v48] = true
	PianoRoll2DHandler._ClearActiveHoldsForToken(v48)
	v46 = false
	flag2 = false
	v47 = nil
	count2 += 1
	total += tokenJudgement
	total2 += 100
	v37 = math.max(v37, v48 + 1)
	colorTokenTiles(v48, textColor)

	if fn3 then
		fn3()
	end

	showJudgement(v49, textColor)
	markActivity() -- inferred equivalent call
	fn6()
end

function PianoRoll2DHandler._FinishRhythmToken(p, _)
	if not v36[p] or set[p] then
		return
	end

	local tokenJudgement, v48, textColor = PianoRoll2DHandler._GetTokenJudgement(
		p,
		70,
		"Good",
		Color3.fromRGB(120, 210, 255)
	)
	set[p] = true
	PianoRoll2DHandler._ClearActiveHoldsForToken(p)
	count2 += 1
	total += tokenJudgement
	total2 += 100
	colorTokenTiles(p, textColor)
	showJudgement(v48, textColor)
	markActivity() -- inferred equivalent call
	fn6()
end

function PianoRoll2DHandler._CompleteGuidedHold(p): boolean
	local v48 = tonumber(p)
	local v49 = v48 and PianoRoll2DHandler._HoldState.active[v48]

	if not v49 or math.max(0, tick() - (v49.startedAt or tick())) + 0.08 < v49.requiredDuration then
		return false
	end

	PianoRoll2DHandler._HoldState.active[v48] = nil
	v43[v49.tokenIndex] = v43[v49.tokenIndex] or {}
	v43[v49.tokenIndex][v48] = true

	if v49.mode == "Wait" then
		PianoRoll2DHandler._ReleaseTokenNoteTiles(v49.tokenIndex, v48)

		if allNotesMatched(v49.tokenIndex) then
			advanceWaitToken(v49.tokenIndex)
		end
	elseif v49.mode == "Rhythm" and allNotesMatched(v49.tokenIndex) then
		PianoRoll2DHandler._FinishRhythmToken(v49.tokenIndex, v48)
	end

	return true
end

function PianoRoll2DHandler._CompleteReadyGuidedHolds()
	local v48 = {}

	for k, v49 in pairs(PianoRoll2DHandler._HoldState.active) do
		if not (v49 and tick() - (v49.startedAt or tick()) + 0.08 >= v49.requiredDuration) then
			continue
		end

		table.insert(v48, k)
	end

	for _, v49 in ipairs(v48) do
		PianoRoll2DHandler._CompleteGuidedHold(v49)
	end
end

function PianoRoll2DHandler._BeginGuidedHold(tokenIndex, note, p, p2, p3, p4): boolean
	if
		PianoRoll2DHandler._HoldState.active[note]
		and PianoRoll2DHandler._HoldState.active[note].tokenIndex == tokenIndex
	then
		return true
	end

	PianoRoll2DHandler._SetTokenJudgement(tokenIndex, p2, p3, p4)
	PianoRoll2DHandler._HoldState.active[note] = {
		tokenIndex = tokenIndex,
		note = note,
		mode = mode,
		startedAt = tick(),
		requiredDuration = math.max(0.05, tonumber(p) or 0.13)
	}

	local v48 = v36[tokenIndex]

	if v48 then
		setText(v5, "Hold: " .. v48.display, p4 or Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
	end

	return true
end

function PianoRoll2DHandler._HandleGuidedNoteRelease(p): boolean
	local v48 = tonumber(p)
	local v49 = v48 and PianoRoll2DHandler._HoldState.active[v48]

	if not v49 then
		return false
	end

	if PianoRoll2DHandler._CompleteGuidedHold(v48) then
		return true
	end

	PianoRoll2DHandler._HoldState.active[v48] = nil

	if v49.mode == "Rhythm" then
		tokenIndexSet[v49.tokenIndex] = true
	end

	count3 += 1
	total2 += 100
	v43[v49.tokenIndex] = v43[v49.tokenIndex] or {}
	v43[v49.tokenIndex][v48] = nil
	colorTokenTiles(v49.tokenIndex, Color3.fromRGB(255, 105, 105))
	local v50 = v36[v49.tokenIndex]
	showJudgement("Miss", Color3.fromRGB(255, 105, 105))

	if v50 then
		setText(v5, "Released too early. Hold: " .. v50.display, Color3.fromRGB(255, 105, 105)) -- inferred equivalent call
	end

	fn6()
	return true
end

local function handleWaitNote(p)
	local activeWaitTarget = getActiveWaitTarget() -- inferred equivalent call
	local v48 = activeWaitTarget and v36[activeWaitTarget]

	if not v48 then
		return
	end

	local flag3 = false

	for _, note in ipairs(v48.notes) do
		if note == p then
			flag3 = true
			break
		end
	end

	if flag3 then
		v43[activeWaitTarget] = v43[activeWaitTarget] or {}

		if v43[activeWaitTarget][p] then
			return
		end

		local tokenNoteDuration = PianoRoll2DHandler._GetTokenNoteDuration(v48, p)

		if PianoRoll2DHandler._NoteRequiresHold(tokenNoteDuration) then
			PianoRoll2DHandler._BeginGuidedHold(
				activeWaitTarget,
				p,
				tokenNoteDuration,
				100,
				"Perfect",
				Color3.fromRGB(95, 225, 125)
			)
			colorTokenTiles(activeWaitTarget, Color3.fromRGB(95, 220, 135))

			if fn4 then
				fn4(v48, Color3.fromRGB(95, 220, 135))
			end

			fn6()
		else
			v43[activeWaitTarget][p] = true
			PianoRoll2DHandler._SetTokenJudgement(activeWaitTarget, 100, "Perfect", Color3.fromRGB(95, 225, 125))

			if allNotesMatched(activeWaitTarget) then
				advanceWaitToken(activeWaitTarget)
				return
			end

			colorTokenTiles(activeWaitTarget, Color3.fromRGB(95, 220, 135))

			if fn4 then
				fn4(v48, Color3.fromRGB(95, 220, 135))
			end
		end
	else
		count3 += 1
		total2 += 100
		showJudgement("Miss", Color3.fromRGB(255, 105, 105))
		setText(v5, "Wrong key. Press: " .. v48.display, Color3.fromRGB(255, 105, 105)) -- inferred equivalent call
		fn6()
	end
end

local function handleWaitChar(value)
	local activeWaitTarget = getActiveWaitTarget() -- inferred equivalent call
	local v48 = activeWaitTarget and v36[activeWaitTarget]

	if not v48 then
		return
	end

	local flag3 = false

	for _, char in ipairs(v48.chars) do
		if char == value then
			flag3 = true
			break
		end
	end

	if flag3 then
		v44[activeWaitTarget] = v44[activeWaitTarget] or {}
		v44[activeWaitTarget][value] = true
		local v50 = charToNote(value) -- inferred equivalent call

		if v50 then
			v43[activeWaitTarget] = v43[activeWaitTarget] or {}
			v43[activeWaitTarget][v50] = true
		end

		if allCharsMatched(activeWaitTarget) or allNotesMatched(activeWaitTarget) then
			advanceWaitToken(activeWaitTarget)
			return
		end

		colorTokenTiles(activeWaitTarget, Color3.fromRGB(95, 220, 135))

		if fn4 then
			fn4(v48, Color3.fromRGB(95, 220, 135))
		end
	else
		count3 += 1
		total2 += 100
		showJudgement("Miss", Color3.fromRGB(255, 105, 105))
		setText(v5, "Wrong key. Press: " .. v48.display, Color3.fromRGB(255, 105, 105)) -- inferred equivalent call
		fn6()
	end
end

local function playToken(data)
	if not v2 then
		return
	end

	for i, note in ipairs(data.notes) do
		local v48

		if data.velocities then
			v48 = data.velocities[i] or nil
		end

		local v49 = math.max(0.05, data.durations and data.durations[i] or data.duration or 0.13)

		if v2.playNote then
			v2.playNote(note, v48)
		end

		if fn5 then
			fn5(note, true)
		end

		task.delay(v49, function()
			if v2 and v2.finishNote then
				v2.finishNote(note)
			end

			if fn5 then
				fn5(note, false)
			end
		end)
	end

	markActivity() -- inferred equivalent call
end

local function tokenHasNote(p, p2): boolean -- 2 equivalent calls inferred from this helper
	for _, note in ipairs(p.notes) do
		if note == p2 then
			return true
		end
	end

	return false
end

local function handleRhythmNote(p)
	local v48 = tick() - v40
	local v49 = 0.35
	local v50 = nil

	for i, v51 in ipairs(v36) do
		if set[i] or tokenIndexSet[i] or not tokenHasNote(v51, p) then -- inferred equivalent call
			continue
		end

		local v52 = math.abs(v48 - (v51.eventTime or 0))

		if not (v52 <= v49) then
			continue
		end

		v50 = i
		v49 = v52
	end

	if v50 then
		local v51 = v36[v50]
		local timingJudgement, v52, textColor = PianoRoll2DHandler._GetTimingJudgement(v49)
		v43[v50] = v43[v50] or {}

		if v43[v50][p] then
			return
		end

		PianoRoll2DHandler._SetTokenJudgement(v50, v52, timingJudgement, textColor)
		local tokenNoteDuration = PianoRoll2DHandler._GetTokenNoteDuration(v51, p)

		if PianoRoll2DHandler._NoteRequiresHold(tokenNoteDuration) then
			PianoRoll2DHandler._BeginGuidedHold(v50, p, tokenNoteDuration, v52, timingJudgement, textColor)
			colorTokenTiles(v50, textColor)
			showJudgement("Hold", textColor)
			fn6()
			return
		end

		v43[v50][p] = true

		if allNotesMatched(v50) then
			PianoRoll2DHandler._FinishRhythmToken(v50, p)
		else
			colorTokenTiles(v50, textColor)
		end
	else
		count3 += 1
		total2 += 100
		showJudgement("Miss", Color3.fromRGB(255, 190, 80))
	end

	fn6()
end

local function finishIfTimedModeDone()
	if
		not v32
		or mode ~= "Wait" and mode ~= "Rhythm" and mode ~= "Listen"
		or v38 <= #v36
		or mode == "Listen" and v39 <= #v36
	then
		return
	end

	if mode == "Wait" and flag2 or #v41 > 0 then
		return
	end

	v32 = false
	disconnectRender() -- inferred equivalent call
	local v48 = v5
	local v49

	if mode == "Listen" then
		v49 = "Listen complete."
	else
		v49 = string.format("Complete. %d hits, %d misses. Accuracy %d%%.", count2, count3, getAccuracyPercent()) -- inferred equivalent call
	end

	setText(v48, v49, Color3.fromRGB(95, 225, 125)) -- inferred equivalent call
	fn6()
end

local function updateWait(p)
	v45 = math.min(getCanvasHeight(), v45 + getCanvasHeight() / 2.35 * p) -- inferred equivalent call

	for _, v48 in ipairs(v41) do
		local v49 = v45 - v48.height
		v48.y = v49

		if v48.frame then
			v48.frame.Position = UDim2.new(v48.frame.Position.X.Scale, 0, 0, v49)
		end
	end
end

local function updateTimed(value)
	local timelineNow = getTimelineNow(tick()) -- inferred equivalent call

	if mode == "Wait" and flag2 then
		v40 += value or 0
		timelineNow = getTimelineNow(tick()) -- inferred equivalent call
	end

	if parent3 and parent3.AbsoluteSize.Y > 0 then
		local _ = parent3.AbsoluteSize.Y
	end

	local v49 = getCanvasHeight() / 2.35 -- inferred equivalent call
	local canvasHeight = getCanvasHeight() -- inferred equivalent call
	local flag3 = false

	while v38 <= #v36 do
		local v50 = v36[v38]

		if not v50 or v50.eventTime - timelineNow > 2.35 then
			break
		end

		for i, note in ipairs(v50.notes) do
			local v51 = v50.durations and v50.durations[i] or v50.duration or 0.13
			local v52

			if v50.visualDurations then
				v52 = v50.visualDurations[i] or v51
			else
				v52 = v51
			end

			local v53 = v52 < v51 and 8 or 34
			local v54 = v50.chars and v50.chars[i] or v24 == "Sheets" and v50.display or ""
			createTile(
				note,
				v54 == "" and mode == "Rhythm" and (PianoRoll2DHandler._GetQwertyLabelForNote(note) or "") or v54,
				get2DTileColor(note),
				v38,
				v50.eventTime,
				getTileHeightForDuration(v52, v53) -- inferred equivalent call
			)
		end

		v38 += 1
		flag3 = true
	end

	if mode == "Wait" then
		if flag2 then
			timelineNow = v47 and v36[v47] and v36[v47].eventTime or timelineNow
		else
			local readyWaitToken = findReadyWaitToken(timelineNow)

			timelineNow = readyWaitToken and beginWaitPause(readyWaitToken) or timelineNow
		end
	end

	PianoRoll2DHandler._CompleteReadyGuidedHolds()

	if mode == "Listen" then
		while v39 <= #v36 do
			local v50 = v36[v39]

			if not v50 or timelineNow < v50.eventTime then
				break
			end

			if not set2[v39] then
				set2[v39] = true
				playToken(v50)
			end

			v39 += 1
			flag3 = true
		end
	end

	for i = #v41, 1, -1 do
		local v50 = v41[i]
		local v51 = nil

		if mode == "Wait" and flag2 and not set[v50.tokenIndex] then
			local v52 = PianoRoll2DHandler._HoldState.active[v50.note]

			if v52 and v52.tokenIndex == v50.tokenIndex then
				v51 = v52
			end
		end

		local v52 = canvasHeight - (v50.eventTime - timelineNow) * v49 - v50.height
		local v53 = v50.height
		local v54 = v51 ~= nil

		if v54 then
			local v55 = math.max(0.05, math.max(0.05, tonumber(v51.requiredDuration) or 0.13) - 0.08)
			local v56 = math.max(0, tick() - (v51.startedAt or tick()))
			local v57 = v50.height * math.clamp(v56 / v55, 0, 1)
			v52 = canvasHeight - v50.height + v57
			v53 = math.max(0, v50.height - v57)
		elseif mode == "Wait" and not set[v50.tokenIndex] and v50.eventTime <= timelineNow then
			v52 = canvasHeight - v50.height
			v53 = v50.height
		elseif canvasHeight < v52 + v50.height then
			v53 = math.max(0, canvasHeight - v52)
		end

		v50.y = v52

		if v50.frame then
			v50.frame.Position = UDim2.new(v50.frame.Position.X.Scale, 0, 0, v52)
			v50.frame.Size = UDim2.new(v50.frame.Size.X.Scale, v50.frame.Size.X.Offset, 0, v53)
		end

		if mode == "Listen" and not v50.impactPlayed and v50.eventTime and v50.eventTime <= timelineNow then
			v50.impactPlayed = true
			spawnJudgementImpact(
				v50.note,
				v50.frame and v50.frame.BackgroundColor3 or Color3.fromRGB(95, 190, 255),
				true
			)
		end

		if v54 or not (canvasHeight <= v52 or v53 <= 0) then
			continue
		end

		if mode == "Wait" and not set[v50.tokenIndex] then
			timelineNow = beginWaitPause(v50.tokenIndex) or timelineNow
			local v55 = canvasHeight - v50.height
			local height = v50.height
			v50.y = v55

			if v50.frame then
				v50.frame.Position = UDim2.new(v50.frame.Position.X.Scale, 0, 0, v55)
				v50.frame.Size = UDim2.new(v50.frame.Size.X.Scale, v50.frame.Size.X.Offset, 0, height)
			end
		else
			if mode == "Rhythm" and not (set[v50.tokenIndex] or tokenIndexSet[v50.tokenIndex]) then
				tokenIndexSet[v50.tokenIndex] = true
				PianoRoll2DHandler._ClearActiveHoldsForToken(v50.tokenIndex)
				count3 += 1
				total2 += 100
				showJudgement("Miss", Color3.fromRGB(255, 105, 105))
				fn6()
			end

			releaseTile(v50) -- inferred equivalent call
			table.remove(v41, i)
		end
	end

	if mode == "Rhythm" and fn4 then
		local v50 = nil

		for i, v52 in ipairs(v36) do
			if not set[i] and not tokenIndexSet[i] and math.abs(timelineNow - (v52.eventTime or 0)) <= 0.35 then
				v50 = v52
				break
			end
		end

		if v50 then
			fn4(v50, Color3.fromRGB(255, 190, 80))
		elseif fn3 then
			fn3()
		end
	end

	if flag3 then
		fn6()
	end

	finishIfTimedModeDone()
end

local function renderStep(p)
	if v32 and not flag then
		updateTimed(math.min(p, 0.05))
	end
end

function PianoRoll2DHandler._StartRender()
	disconnectRender() -- inferred equivalent call
	heartbeatConnection2 = RunService.Heartbeat:Connect(renderStep)
end

function PianoRoll2DHandler._PrepareTokens(): boolean
	if v25 and #v25 > 0 then
		v36 = cloneSourceTokens(v25, v26)
	else
		v36 = parseSheet(getSheetText()) -- inferred equivalent call
		v23 = "Current Sheet"
		v24 = "Sheets"
		v26 = false
		tempo = nil
	end

	if #v36 ~= 0 then
		return true
	end

	setText(v5, "Load a MIDI, recording, or QWERTY sheet first.", Color3.fromRGB(255, 190, 80)) -- inferred equivalent call
	return false
end

function PianoRoll2DHandler._ApplyVisualDurations()
	local eventTimesByNote = {}

	for i = #v36, 1, -1 do
		local v48 = v36[i]

		if not v48 then
			continue
		end

		v48.visualDurations = v48.visualDurations or {}

		for j = #v48.notes, 1, -1 do
			local note = v48.notes[j]
			local v49 = v48.durations and v48.durations[j] or v48.duration or 0.13
			local v50 = v48.visualDurations[j] or v49
			local v51 = eventTimesByNote[note]

			if v51 and v48.eventTime then
				v50 = math.min(v50, (math.max(0.01, v51 - v48.eventTime - 0.045)))
			end

			v48.visualDurations[j] = math.max(0.01, v50)

			if v48.eventTime then
				eventTimesByNote[note] = v48.eventTime
			end
		end
	end
end

function PianoRoll2DHandler._AssignTimedEvents()
	if v26 then
		for _, v48 in ipairs(v36) do
			v48.eventTime = v48.eventTime or 2.35 + (v48.sourceTime or 0)
		end

		PianoRoll2DHandler._ApplyVisualDurations()
	else
		local v48 = tonumber(tempo) or getTempo() -- inferred equivalent call
		local v49 = 60 / math.clamp(v48, 20, 600)

		for i, v50 in ipairs(v36) do
			v50.eventTime = 2.35 + (i - 1) * v49
			v50.duration = v50.duration or 0.13
			v50.durations = v50.durations or {}

			for j = 1, #v50.notes do
				v50.durations[j] = v50.durations[j] or v50.duration
			end
		end

		PianoRoll2DHandler._ApplyVisualDurations()
	end
end

function PianoRoll2DHandler._GetPlaybackDuration()
	local maxValue = 0

	for _, v48 in ipairs(v36) do
		local sourceTime = tonumber(v48.sourceTime)
		local eventTime = tonumber(v48.eventTime)
		maxValue = math.max(
			maxValue,
			(sourceTime or eventTime and math.max(0, eventTime - 2.35) or 0) + (tonumber(v48.duration) or 0.13)
		)
	end

	return maxValue
end

function PianoRoll2DHandler._GetPlaybackSourcePosition()
	local playbackDuration = PianoRoll2DHandler._GetPlaybackDuration()

	if playbackDuration <= 0 then
		return 0, 0
	end

	return
		math.clamp(getTimelineNow(flag and lastTime > 0 and lastTime or tick()) - 2.35, 0, playbackDuration), -- inferred equivalent call
		playbackDuration
end

function PianoRoll2DHandler._SeekPlayback(p): boolean
	if not v32 then
		return false
	end

	local playbackDuration = PianoRoll2DHandler._GetPlaybackDuration()

	if playbackDuration <= 0 then
		return false
	end

	local v48 = math.clamp(tonumber(p) or 0, 0, playbackDuration) + 2.35
	v40 = tick() - v48 / getPlaybackSpeed() -- inferred equivalent call
	clearTiles() -- inferred equivalent call

	if fn2 then
		fn2()
	end

	if fn3 then
		fn3()
	end

	flag2 = false
	v47 = nil
	v46 = false
	table.clear(set2)
	table.clear(PianoRoll2DHandler._HoldState.active)
	table.clear(PianoRoll2DHandler._HoldState.scores)
	table.clear(PianoRoll2DHandler._HoldState.labels)
	table.clear(PianoRoll2DHandler._HoldState.colors)
	v38 = 1

	while v38 <= #v36 and (v36[v38].eventTime or 0) < v48 do
		v38 += 1
	end

	v39 = 1

	while v39 <= #v36 and (v36[v39].eventTime or 0) < v48 do
		set2[v39] = true
		v39 += 1
	end

	v37 = math.clamp(v38, 1, #v36 + 1)
	fn6()
	markActivity() -- inferred equivalent call
	return true
end

function PianoRoll2DHandler._StartMode(p)
	if not pianoRoll2D then
		return
	end

	if v2 and v2.stopSheetPractice then
		v2.stopSheetPractice()
	end

	fn9(true)

	if v2 and v2.hideSourcePanels and v24 ~= "MIDI Player" then
		v2.hideSourcePanels()
	end

	if not PianoRoll2DHandler._PrepareTokens() then
		return
	end

	v32 = true
	flag = false
	lastTime = 0
	mode = p
	v37 = 1
	v38 = 1
	v39 = 1
	count2 = 0
	count3 = 0
	total = 0
	total2 = 0
	v46 = false
	flag2 = false
	v47 = nil
	v40 = tick()
	table.clear(set)
	table.clear(tokenIndexSet)
	table.clear(set2)
	table.clear(v43)
	table.clear(v44)
	table.clear(PianoRoll2DHandler._HoldState.active)
	table.clear(PianoRoll2DHandler._HoldState.scores)
	table.clear(PianoRoll2DHandler._HoldState.labels)
	table.clear(PianoRoll2DHandler._HoldState.colors)
	pianoRoll2D.Visible = true
	setExternalOverlaysSuppressed(true)
	setText(v9, "Mode: " .. p, Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
	PianoRoll2DHandler._AssignTimedEvents()

	local v48 = p == "Wait" and "Note Wait started." or p == "Listen" and "Listen started." or "Rhythm started."

	setText(v5, v48, Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
	fn6()
	markActivity() -- inferred equivalent call
	PianoRoll2DHandler._StartRender()
end

local function setKeyPressedVisual(guiObject, p) -- 3 equivalent calls inferred from this helper
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	if p then
		if guiObject:GetAttribute("PianoRoll2DBaseColor") == nil then
			guiObject:SetAttribute("PianoRoll2DBaseColor", guiObject.BackgroundColor3)
		end

		guiObject.BackgroundColor3 = get2DTileColor(tonumber(guiObject.Name))
	else
		local pianoRoll2DBaseColor = guiObject:GetAttribute("PianoRoll2DBaseColor")

		if typeof(pianoRoll2DBaseColor) == "Color3" then
			guiObject.BackgroundColor3 = pianoRoll2DBaseColor
		end
	end
end

local function get2DKey(p) -- 1 equivalent call inferred from this helper
	local guiObject = keyFrame and keyFrame:FindFirstChild((tostring(p)))

	if guiObject and guiObject:IsA("GuiObject") then
		return guiObject
	end

	return nil
end

local function setGuideVisual(guiObject, p, p2)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local name = tonumber(guiObject.Name)
	local pianoRoll2DGuideStroke = guiObject:FindFirstChild("PianoRoll2DGuideStroke")

	if pianoRoll2DGuideStroke then
		pianoRoll2DGuideStroke.Enabled = false
		pianoRoll2DGuideStroke.Thickness = 0
	end

	if p2 then
		if guiObject:GetAttribute("PianoRoll2DBaseColor") == nil then
			guiObject:SetAttribute("PianoRoll2DBaseColor", guiObject.BackgroundColor3)
		end

		guiObject.BackgroundColor3 = p or get2DTileColor(name)
		v29[guiObject] = true
	else
		v29[guiObject] = nil

		if not (name and (v27[name] or v28[name])) then
			local pianoRoll2DBaseColor = guiObject:GetAttribute("PianoRoll2DBaseColor")

			if typeof(pianoRoll2DBaseColor) == "Color3" then
				guiObject.BackgroundColor3 = pianoRoll2DBaseColor
			end
		end
	end
end

fn3 = function()
	for guiObject in pairs(v29) do
		if not (guiObject and guiObject.Parent) then
			continue
		end

		Color3.fromRGB(78, 180, 255)

		if not (guiObject and guiObject:IsA("GuiObject")) then
			continue
		end

		local name = tonumber(guiObject.Name)
		local pianoRoll2DGuideStroke = guiObject:FindFirstChild("PianoRoll2DGuideStroke")

		if pianoRoll2DGuideStroke then
			pianoRoll2DGuideStroke.Enabled = false
			pianoRoll2DGuideStroke.Thickness = 0
		end

		v29[guiObject] = nil

		if name and (v27[name] or v28[name]) then
			continue
		end

		local pianoRoll2DBaseColor = guiObject:GetAttribute("PianoRoll2DBaseColor")

		if typeof(pianoRoll2DBaseColor) == "Color3" then
			guiObject.BackgroundColor3 = pianoRoll2DBaseColor
		end
	end

	table.clear(v29)
end

fn4 = function(p, color)
	fn3()

	if not p then
		return
	end

	for _, v48 in ipairs(p.notes or {}) do
		local guiObject = get2DKey(v48) -- inferred equivalent call

		if guiObject then
			setGuideVisual(guiObject, color, true)
		end
	end
end

fn5 = function(p, p2)
	local v48 = tonumber(p)
	local guiObject

	if v48 then
		guiObject = keyFrame and keyFrame:FindFirstChild((tostring(v48)))

		if not (guiObject and guiObject:IsA("GuiObject")) then
			guiObject = nil
		end
	else
		guiObject = v48
	end

	if not guiObject then
		return
	end

	if p2 then
		v28[v48] = guiObject

		if guiObject then
			if not guiObject:IsA("GuiObject") then
				return
			end

			if guiObject:GetAttribute("PianoRoll2DBaseColor") == nil then
				guiObject:SetAttribute("PianoRoll2DBaseColor", guiObject.BackgroundColor3)
			end

			guiObject.BackgroundColor3 = get2DTileColor(tonumber(guiObject.Name))
		end
	else
		v28[v48] = nil

		if not v27[v48] and guiObject then
			if not guiObject:IsA("GuiObject") then
				return
			end

			local pianoRoll2DBaseColor = guiObject:GetAttribute("PianoRoll2DBaseColor")

			if typeof(pianoRoll2DBaseColor) == "Color3" then
				guiObject.BackgroundColor3 = pianoRoll2DBaseColor
			end
		end
	end
end

fn2 = function()
	local v48 = {}

	for k in pairs(v28) do
		table.insert(v48, k)
	end

	for _, v49 in ipairs(v48) do
		fn5(v49, false)
	end
end

local function playManual2DNote(p)
	markActivity() -- inferred equivalent call

	if PianoRoll2DHandler._ShouldShowManualEffect() then
		beginManualEffect(p)
	end

	local v48 = false

	if v2 and v2.playManualNote then
		v2.playManualNote(p)
	elseif v2 and v2.playNote then
		v2.playNote(p)
		PianoRoll2DHandler.OnNotePlayed(p)
		v48 = true
	end

	if v32 and not v48 then
		if mode == "Wait" then
			handleWaitNote(p)
		elseif mode == "Rhythm" then
			handleRhythmNote(p)
		end
	end
end

local function finishManual2DNote(p) -- 1 equivalent call inferred from this helper
	if v2 and v2.finishManualNote then
		v2.finishManualNote(p)
	elseif v2 and v2.finishNote then
		v2.finishNote(p)
	end
end

local function press2DKey(p, guiObject)
	local v48 = tonumber(p)

	if not v48 or v27[v48] then
		return
	end

	v27[v48] = guiObject or true
	setKeyPressedVisual(guiObject, true) -- inferred equivalent call
	playManual2DNote(v48)
end

local function release2DKey(p)
	local v48 = tonumber(p)

	if not (v48 and v27[v48]) then
		return
	end

	local v49 = v27[v48]
	v27[v48] = nil

	if typeof(v49) == "Instance" and not v28[v48] then
		setKeyPressedVisual(v49, false) -- inferred equivalent call
	end

	finishManual2DNote(v48) -- inferred equivalent call
	PianoRoll2DHandler._HandleGuidedNoteRelease(v48)
	fn11(v48)
end

fn = function()
	local v48 = {}

	for k in pairs(v27) do
		table.insert(v48, k)
	end

	for _, v49 in ipairs(v48) do
		release2DKey(v49)
	end
end

local function bind2DKey(button)
	if not (button and button:IsA("GuiButton")) then
		return
	end

	local name = tonumber(button.Name)

	if not name then
		return
	end

	button.Active = true
	button.AutoButtonColor = false

	if button:GetAttribute("PianoRoll2DBound") then
		return
	end

	button:SetAttribute("PianoRoll2DBound", true)
	button.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			local v48 = button
			local v49 = tonumber(name)

			if v49 then
				if v27[v49] then
					return
				end

				v27[v49] = v48 or true
				setKeyPressedVisual(v48, true) -- inferred equivalent call
				playManual2DNote(v49)
			end
		end
	end)
	button.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			release2DKey(name)
		end
	end)
	button.MouseLeave:Connect(function()
		release2DKey(name)
	end)
end

fn8 = function(p, value)
	v22 = p or v22

	if v17 then
		v17.Text = v22 .. " Mode"
	end

	if v18 then
		v18.Text = value or "Choose how you want to play."
	end

	if v16 then
		v16.Visible = true
	end
end

fn7 = function()
	if v16 then
		v16.Visible = false
	end
end

local function buildKeys()
	if not keyFrame then
		return
	end

	local v48 = {}

	for i = 1, 61 do
		local v49 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(i, i)
		local v50 = charToNote(v49) -- inferred equivalent call

		if not v50 or not (v50 >= -14) or not (v50 <= 73) or v48[v50] then
			continue
		end

		v48[v50] = v49
	end

	local buttons = {}

	for _, button in ipairs(keyFrame:GetChildren()) do
		if button:IsA("GuiButton") and tonumber(button.Name) then
			table.insert(buttons, button)
		end
	end

	if #buttons >= 88 then
		for _, folder in ipairs(buttons) do
			local name = tonumber(folder.Name)
			folder.Active = true
			folder.AutoButtonColor = false
			folder.ZIndex = math.max(folder.ZIndex, 6203)
			local label = folder:FindFirstChild("Label")

			if label and label:IsA("TextLabel") and label.Text == "" and v48[name] then
				label.Text = v48[name]
			end

			for _, guiObject in ipairs(folder:GetDescendants()) do
				if guiObject:IsA("GuiObject") then
					guiObject.ZIndex = math.max(guiObject.ZIndex, folder.ZIndex + 1)
				end
			end

			bind2DKey(folder)
		end
	else
		for _, guiObject in ipairs(keyFrame:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end

		local function createPianoKey(p, pianoRoll2DIsBlackKey, p2, p3)
			local textButton = Instance.new("TextButton")
			textButton.Name = tostring(p)
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.Active = true
			textButton.BorderSizePixel = 0
			textButton.ZIndex = pianoRoll2DIsBlackKey and 6206 or 6203
			textButton.BackgroundColor3 = pianoRoll2DIsBlackKey and Color3.fromRGB(10, 10, 12)
				or Color3.fromRGB(242, 243, 246)
			textButton:SetAttribute("PianoRoll2DIsBlackKey", pianoRoll2DIsBlackKey)

			if pianoRoll2DIsBlackKey then
				textButton.AnchorPoint = Vector2.new(0.5, 0)
				textButton.Position = UDim2.new(p2, 0, 0, 0)
				textButton.Size = UDim2.new(p3, 0, 0.62, 0)
				makeCorner(textButton, 2) -- inferred equivalent call
				makeStroke(textButton, Color3.fromRGB(0, 0, 0), nil) -- inferred equivalent call
			else
				textButton.AnchorPoint = Vector2.new(0, 0)
				textButton.Position = UDim2.new(p2, 0, 0, 0)
				textButton.Size = UDim2.new(p3, -1, 1, 0)
				makeCorner(textButton, 3) -- inferred equivalent call
				makeStroke(textButton, Color3.fromRGB(192, 196, 204), nil) -- inferred equivalent call
			end

			textButton.Parent = keyFrame

			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.BackgroundTransparency = 1
			label.AnchorPoint = Vector2.new(0.5, 1)
			label.Position = UDim2.new(0.5, 0, 1, pianoRoll2DIsBlackKey and -6 or -10)
			label.Size = UDim2.new(1, -2, 0, 18)
			label.Font = Enum.Font.ArialBold
			label.TextSize = 12
			label.Text = v48[p] or ""
			label.TextColor3 = pianoRoll2DIsBlackKey and Color3.fromRGB(240, 240, 244) or Color3.fromRGB(92, 98, 110)
			label.TextStrokeTransparency = pianoRoll2DIsBlackKey and 0.35 or 1
			label.ZIndex = textButton.ZIndex + 1
			label.Parent = textButton
			bind2DKey(textButton)
		end

		local count5 = 0
		local v49 = {}

		for i = -14, 73 do
			if isBlackKeyIndex(i - -14) then -- inferred equivalent call
				table.insert(v49, {
					note = i,
					x = count5 * (1 / 52)
				})
			else
				createPianoKey(i, false, count5 * (1 / 52), 1 / 52)
				count5 += 1
			end
		end

		for _, v50 in ipairs(v49) do
			if v50.x > 0 and v50.x < 1 then
				createPianoKey(v50.note, true, v50.x, 0.011923076923076923)
			end
		end
	end
end

setOptionModeButtonActive = function(p)
	local led = v15 and v15:FindFirstChild("LED")

	if led and led:IsA("ImageLabel") then
		led.ImageColor3 = p and Color3.fromRGB(74, 225, 120) or Color3.fromRGB(112, 112, 112)
	end
end

function PianoRoll2DHandler._WireOptionFrameButton(parent)
	if not parent then
		return nil
	end

	local pianoRoll2D2 = parent:FindFirstChild("PianoRoll2D")

	if pianoRoll2D2 then
		pianoRoll2D2:Destroy()
	end

	local mode2D = parent:FindFirstChild("Mode2D")

	if mode2D and not mode2D:IsA("GuiButton") then
		mode2D:Destroy()
		mode2D = nil
	end

	if not mode2D then
		mode2D = Instance.new("ImageButton")
		mode2D.Name = "Mode2D"
		mode2D.Image = "rbxassetid://12558996479"
		mode2D.ImageColor3 = Color3.fromRGB(112, 112, 112)
		mode2D.BackgroundTransparency = 1
		mode2D.BorderSizePixel = 0
		mode2D.Position = UDim2.new(0.0219667014, 0, 0.642425239, 0)
		mode2D.Size = UDim2.new(0, 20, 0, 20)
		mode2D.ZIndex = 2
		mode2D.Parent = parent

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.BorderSizePixel = 0
		icon.Image = ""
		icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		icon.ImageTransparency = 0
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Active = false
		icon.Selectable = false
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.Size = UDim2.new(0.78, 0, 0.78, 0)
		icon.ZIndex = 3
		icon.Parent = mode2D

		local led = Instance.new("ImageLabel")
		led.Name = "LED"
		led.Image = "rbxassetid://12558996479"
		led.ImageColor3 = Color3.fromRGB(112, 112, 112)
		led.BackgroundTransparency = 1
		led.Position = UDim2.new(0.220000029, 0, -0.785999894, 0)
		led.Size = UDim2.new(0, 10, 0, 10)
		led.ZIndex = 3
		led.Parent = mode2D

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "TextLabel"
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.new(-1.06879044, 0, -1.63600159, 0)
		textLabel.Size = UDim2.new(0, 71, 0, 12)
		textLabel.Font = Enum.Font.Gotham
		textLabel.Text = "2D PianoRoll"
		textLabel.TextColor3 = Color3.fromRGB(235, 238, 242)
		textLabel.TextSize = 10
		textLabel.TextXAlignment = Enum.TextXAlignment.Center
		textLabel.ZIndex = 3
		textLabel.Parent = mode2D
	end

	v15 = mode2D
	setOptionModeButtonActive(pianoRoll2D and pianoRoll2D.Visible or false)

	if not mode2D:GetAttribute("PianoRoll2DButtonBound") then
		mode2D:SetAttribute("PianoRoll2DButtonBound", true)
		mode2D.MouseButton1Click:Connect(function()
			playClick() -- inferred equivalent call

			if pianoRoll2D and pianoRoll2D.Visible then
				PianoRoll2DHandler.Hide()
			else
				PianoRoll2DHandler.Open()
			end
		end)
	end

	return mode2D
end

function PianoRoll2DHandler._BuildGui()
	pianoRoll2D = parent2:FindFirstChild("PianoRoll2D")

	if not pianoRoll2D then
		pianoRoll2D = Instance.new("Frame")
		pianoRoll2D.Name = "PianoRoll2D"
		pianoRoll2D.Parent = parent2
	end

	pianoRoll2D.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	pianoRoll2D.BorderSizePixel = 0
	pianoRoll2D.Size = UDim2.fromScale(1, 1)
	pianoRoll2D.Position = UDim2.fromScale(0, 0)
	pianoRoll2D.Visible = false
	pianoRoll2D.Active = true
	pianoRoll2D.ZIndex = 6200

	local parent = pianoRoll2D
	local header = parent and parent:FindFirstChild("Header")

	if not (header and header:IsA("Frame")) then
		if header then
			header:Destroy()
		end

		header = Instance.new("Frame")
		header.Name = "Header"
		header.Parent = parent
	end

	header.AnchorPoint = Vector2.new(0.5, 0)
	header.Position = UDim2.new(0.5, 0, 0, 12)
	header.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
	header.BackgroundTransparency = 0.08
	header.BorderSizePixel = 0
	header.Size = UDim2.new(0, 684, 0, 42)
	header.ZIndex = 6210
	makeCorner(header, 8) -- inferred equivalent call
	makeStroke(header, Color3.fromRGB(45, 49, 58), nil) -- inferred equivalent call
	local title = header and header:FindFirstChild("Title")

	if not (title and title:IsA("TextLabel")) then
		if title then
			title:Destroy()
		end

		title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Parent = header
	end

	v4 = title
	v4.BackgroundTransparency = 1
	v4.Position = UDim2.new(0, 14, 0, 0)
	v4.Size = UDim2.new(0, 90, 1, 0)
	v4.Font = Enum.Font.GothamBold
	v4.Text = "2D Mode"
	v4.TextSize = 14
	v4.TextColor3 = Color3.fromRGB(245, 248, 252)
	v4.TextXAlignment = Enum.TextXAlignment.Left
	v4.ZIndex = 6211
	local modeLabel = header and header:FindFirstChild("ModeLabel")

	if not (modeLabel and modeLabel:IsA("TextLabel")) then
		if modeLabel then
			modeLabel:Destroy()
		end

		modeLabel = Instance.new("TextLabel")
		modeLabel.Name = "ModeLabel"
		modeLabel.Parent = header
	end

	v9 = modeLabel
	v9.BackgroundTransparency = 1
	v9.Position = UDim2.new(0, 112, 0, 0)
	v9.Size = UDim2.new(0, 92, 1, 0)
	v9.Font = Enum.Font.GothamMedium
	v9.Text = "Mode: -"
	v9.TextSize = 13
	v9.TextColor3 = Color3.fromRGB(170, 176, 190)
	v9.TextXAlignment = Enum.TextXAlignment.Left
	v9.ZIndex = 6211

	for _, childName in ipairs({ "WaitMode", "RhythmMode", "ListenMode" }) do
		local child = header:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	local sheetsSource = header and header:FindFirstChild("SheetsSource")

	if not (sheetsSource and sheetsSource:IsA("TextButton")) then
		if sheetsSource then
			sheetsSource:Destroy()
		end

		sheetsSource = Instance.new("TextButton")
		sheetsSource.Name = "SheetsSource"
		sheetsSource.Parent = header
	end

	v19 = sheetsSource
	v19.Position = UDim2.new(0, 214, 0, 6)
	v19.Size = UDim2.new(0, 96, 0, 30)
	styleButton(v19, "Sheets", Color3.fromRGB(54, 145, 88))
	v19.ZIndex = 6211
	local recordingsSource = header and header:FindFirstChild("RecordingsSource")

	if not (recordingsSource and recordingsSource:IsA("TextButton")) then
		if recordingsSource then
			recordingsSource:Destroy()
		end

		recordingsSource = Instance.new("TextButton")
		recordingsSource.Name = "RecordingsSource"
		recordingsSource.Parent = header
	end

	v20 = recordingsSource
	v20.Position = UDim2.new(0, 318, 0, 6)
	v20.Size = UDim2.new(0, 104, 0, 30)
	styleButton(v20, "Records", Color3.fromRGB(55, 96, 170))
	v20.ZIndex = 6211
	local midiSource = header and header:FindFirstChild("MidiSource")

	if not (midiSource and midiSource:IsA("TextButton")) then
		if midiSource then
			midiSource:Destroy()
		end

		midiSource = Instance.new("TextButton")
		midiSource.Name = "MidiSource"
		midiSource.Parent = header
	end

	v21 = midiSource
	v21.Position = UDim2.new(0, 430, 0, 6)
	v21.Size = UDim2.new(0, 74, 0, 30)
	styleButton(v21, "MIDI", Color3.fromRGB(110, 82, 180))
	v21.ZIndex = 6211
	local stop = header and header:FindFirstChild("Stop")

	if not (stop and stop:IsA("TextButton")) then
		if stop then
			stop:Destroy()
		end

		stop = Instance.new("TextButton")
		stop.Name = "Stop"
		stop.Parent = header
	end

	v13 = stop
	v13.Position = UDim2.new(0, 512, 0, 6)
	v13.Size = UDim2.new(0, 72, 0, 30)
	styleButton(v13, "Stop", Color3.fromRGB(175, 62, 62))
	v13.ZIndex = 6211
	local close = header and header:FindFirstChild("Close")

	if not (close and close:IsA("TextButton")) then
		if close then
			close:Destroy()
		end

		close = Instance.new("TextButton")
		close.Name = "Close"
		close.Parent = header
	end

	v14 = close
	v14.Position = UDim2.new(0, 592, 0, 6)
	v14.Size = UDim2.new(0, 78, 0, 30)
	styleButton(v14, "Close", Color3.fromRGB(54, 58, 68))
	v14.ZIndex = 6211

	local parent4 = pianoRoll2D
	local canvas = parent4 and parent4:FindFirstChild("Canvas")

	if not (canvas and canvas:IsA("Frame")) then
		if canvas then
			canvas:Destroy()
		end

		canvas = Instance.new("Frame")
		canvas.Name = "Canvas"
		canvas.Parent = parent4
	end

	parent3 = canvas
	parent3.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
	parent3.BorderSizePixel = 0
	parent3.ClipsDescendants = true
	parent3.Position = UDim2.new(0, 0, 0, 0)
	parent3.Size = UDim2.new(1, 0, 0.725, 0)
	parent3.ZIndex = 6201

	local parent5 = parent3
	local backgroundImage = parent5 and parent5:FindFirstChild("BackgroundImage")

	if not (backgroundImage and backgroundImage:IsA("ImageLabel")) then
		if backgroundImage then
			backgroundImage:Destroy()
		end

		backgroundImage = Instance.new("ImageLabel")
		backgroundImage.Name = "BackgroundImage"
		backgroundImage.Parent = parent5
	end

	PianoRoll2DHandler._BackgroundImage = backgroundImage
	PianoRoll2DHandler._BackgroundImage.BackgroundTransparency = 1
	PianoRoll2DHandler._BackgroundImage.BorderSizePixel = 0
	PianoRoll2DHandler._BackgroundImage.ScaleType = Enum.ScaleType.Crop
	fn10()

	local parent6 = parent3
	local judgementLine = parent6 and parent6:FindFirstChild("JudgementLine")

	if not (judgementLine and judgementLine:IsA("Frame")) then
		if judgementLine then
			judgementLine:Destroy()
		end

		judgementLine = Instance.new("Frame")
		judgementLine.Name = "JudgementLine"
		judgementLine.Parent = parent6
	end

	judgementLine.AnchorPoint = Vector2.new(0.5, 1)
	judgementLine.Position = UDim2.new(0.5, 0, 1, 0)
	judgementLine.Size = UDim2.new(1, 0, 0, 3)
	judgementLine.BackgroundColor3 = Color3.fromRGB(235, 87, 87)
	judgementLine.BorderSizePixel = 0
	judgementLine.ZIndex = 6285

	local keyStrip = pianoRoll2D:FindFirstChild("KeyStrip")

	if keyStrip then
		keyStrip:Destroy()
	end

	keyFrame = pianoRoll2D:FindFirstChild("KeyFrame")

	if not keyFrame then
		keyFrame = Instance.new("Frame")
		keyFrame.Name = "KeyFrame"
		keyFrame.Parent = pianoRoll2D
	end

	keyFrame.AnchorPoint = Vector2.new(0.5, 1)
	keyFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
	keyFrame.BackgroundTransparency = 1
	keyFrame.BorderSizePixel = 0
	keyFrame.Position = UDim2.new(0.5, 0, 1, 0)
	keyFrame.Size = UDim2.new(1, 0, 0.275, 0)
	keyFrame.ClipsDescendants = true
	keyFrame.ZIndex = 6202
	buildKeys()

	local parent7 = pianoRoll2D
	local status = parent7 and parent7:FindFirstChild("Status")

	if not (status and status:IsA("TextLabel")) then
		if status then
			status:Destroy()
		end

		status = Instance.new("TextLabel")
		status.Name = "Status"
		status.Parent = parent7
	end

	v5 = status
	v5.BackgroundTransparency = 1
	v5.Position = UDim2.new(0, 18, 0, 58)
	v5.Size = UDim2.new(0.5, -18, 0, 22)
	v5.Font = Enum.Font.GothamMedium
	v5.Text = "Choose Sheets, Records, or MIDI above."
	v5.TextSize = 13
	v5.TextColor3 = Color3.fromRGB(170, 176, 190)
	v5.TextXAlignment = Enum.TextXAlignment.Left
	v5.ZIndex = 6202

	local parent8 = pianoRoll2D
	local progress = parent8 and parent8:FindFirstChild("Progress")

	if not (progress and progress:IsA("TextLabel")) then
		if progress then
			progress:Destroy()
		end

		progress = Instance.new("TextLabel")
		progress.Name = "Progress"
		progress.Parent = parent8
	end

	v6 = progress
	v6.BackgroundTransparency = 1
	v6.Position = UDim2.new(0.5, 0, 0, 58)
	v6.Size = UDim2.new(0.5, -18, 0, 22)
	v6.Font = Enum.Font.GothamMedium
	v6.Text = "0 / 0    Hits: 0    Misses: 0    Acc: 100%"
	v6.TextSize = 13
	v6.TextColor3 = Color3.fromRGB(170, 176, 190)
	v6.TextXAlignment = Enum.TextXAlignment.Right
	v6.ZIndex = 6202

	local parent9 = pianoRoll2D
	local feedback = parent9 and parent9:FindFirstChild("Feedback")

	if not (feedback and feedback:IsA("TextLabel")) then
		if feedback then
			feedback:Destroy()
		end

		feedback = Instance.new("TextLabel")
		feedback.Name = "Feedback"
		feedback.Parent = parent9
	end

	v7 = feedback
	v7.AnchorPoint = Vector2.new(0.5, 0.5)
	v7.Position = UDim2.new(0.5, 0, 0.54, 0)
	v7.Size = UDim2.new(0, 260, 0, 48)
	v7.BackgroundTransparency = 1
	v7.Font = Enum.Font.GothamBlack
	v7.Text = ""
	v7.TextSize = 32
	v7.TextColor3 = Color3.fromRGB(255, 255, 255)
	v7.TextStrokeTransparency = 0.35
	v7.Visible = false
	v7.ZIndex = 6290

	local parent10 = pianoRoll2D
	local modePanel = parent10 and parent10:FindFirstChild("ModePanel")

	if not (modePanel and modePanel:IsA("Frame")) then
		if modePanel then
			modePanel:Destroy()
		end

		modePanel = Instance.new("Frame")
		modePanel.Name = "ModePanel"
		modePanel.Parent = parent10
	end

	v16 = modePanel
	v16.AnchorPoint = Vector2.new(0.5, 0)
	v16.Position = UDim2.new(0.5, 0, 0, 86)
	v16.Size = UDim2.new(0, 580, 0, 118)
	v16.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
	v16.BackgroundTransparency = 0.03
	v16.BorderSizePixel = 0
	v16.Visible = false
	v16.ZIndex = 6300
	makeCorner(v16, 8) -- inferred equivalent call
	makeStroke(v16, Color3.fromRGB(52, 58, 70), nil) -- inferred equivalent call

	local parent11 = v16
	local title2 = parent11 and parent11:FindFirstChild("Title")

	if not (title2 and title2:IsA("TextLabel")) then
		if title2 then
			title2:Destroy()
		end

		title2 = Instance.new("TextLabel")
		title2.Name = "Title"
		title2.Parent = parent11
	end

	v17 = title2
	v17.BackgroundTransparency = 1
	v17.Position = UDim2.new(0, 16, 0, 10)
	v17.Size = UDim2.new(0, 210, 0, 24)
	v17.Font = Enum.Font.GothamBold
	v17.Text = "Sheets Mode"
	v17.TextSize = 17
	v17.TextColor3 = Color3.fromRGB(245, 248, 252)
	v17.TextXAlignment = Enum.TextXAlignment.Left
	v17.ZIndex = 6301

	local parent12 = v16
	local subtitle = parent12 and parent12:FindFirstChild("Subtitle")

	if not (subtitle and subtitle:IsA("TextLabel")) then
		if subtitle then
			subtitle:Destroy()
		end

		subtitle = Instance.new("TextLabel")
		subtitle.Name = "Subtitle"
		subtitle.Parent = parent12
	end

	v18 = subtitle
	v18.BackgroundTransparency = 1
	v18.Position = UDim2.new(0, 16, 0, 34)
	v18.Size = UDim2.new(1, -32, 0, 20)
	v18.Font = Enum.Font.Gotham
	v18.Text = "Choose how you want to play."
	v18.TextSize = 12
	v18.TextColor3 = Color3.fromRGB(175, 182, 196)
	v18.TextXAlignment = Enum.TextXAlignment.Left
	v18.TextTruncate = Enum.TextTruncate.AtEnd
	v18.ZIndex = 6301

	local parent13 = v16
	local waitMode = parent13 and parent13:FindFirstChild("WaitMode")

	if not (waitMode and waitMode:IsA("TextButton")) then
		if waitMode then
			waitMode:Destroy()
		end

		waitMode = Instance.new("TextButton")
		waitMode.Name = "WaitMode"
		waitMode.Parent = parent13
	end

	v10 = waitMode
	v10.Position = UDim2.new(0, 20, 0, 68)
	v10.Size = UDim2.new(0, 112, 0, 34)
	styleButton(v10, "Note Wait", Color3.fromRGB(54, 145, 88))
	v10.ZIndex = 6301

	local parent14 = v16
	local rhythmMode = parent14 and parent14:FindFirstChild("RhythmMode")

	if not (rhythmMode and rhythmMode:IsA("TextButton")) then
		if rhythmMode then
			rhythmMode:Destroy()
		end

		rhythmMode = Instance.new("TextButton")
		rhythmMode.Name = "RhythmMode"
		rhythmMode.Parent = parent14
	end

	v11 = rhythmMode
	v11.Position = UDim2.new(0, 144, 0, 68)
	v11.Size = UDim2.new(0, 112, 0, 34)
	styleButton(v11, "Rhythm", Color3.fromRGB(55, 96, 170))
	v11.ZIndex = 6301

	local parent15 = v16
	local listenMode = parent15 and parent15:FindFirstChild("ListenMode")

	if not (listenMode and listenMode:IsA("TextButton")) then
		if listenMode then
			listenMode:Destroy()
		end

		listenMode = Instance.new("TextButton")
		listenMode.Name = "ListenMode"
		listenMode.Parent = parent15
	end

	v12 = listenMode
	v12.Position = UDim2.new(0, 268, 0, 68)
	v12.Size = UDim2.new(0, 112, 0, 34)
	styleButton(v12, "Listen", Color3.fromRGB(110, 82, 180))
	v12.ZIndex = 6301

	local parent16 = v16
	local closePanel = parent16 and parent16:FindFirstChild("ClosePanel")

	if not (closePanel and closePanel:IsA("TextButton")) then
		if closePanel then
			closePanel:Destroy()
		end

		closePanel = Instance.new("TextButton")
		closePanel.Name = "ClosePanel"
		closePanel.Parent = parent16
	end

	closePanel.Position = UDim2.new(1, -132, 0, 68)
	closePanel.Size = UDim2.new(0, 112, 0, 34)
	styleButton(closePanel, "Cancel", Color3.fromRGB(54, 58, 68))
	closePanel.ZIndex = 6301

	local function chooseSource(p, _, callback)
		v22 = p
		playClick() -- inferred equivalent call
		fn7()

		if callback then
			callback()
		end

		raiseSourcePanelsAbove2D()
		task.defer(raiseSourcePanelsAbove2D)
		setText(v5, "Load or choose a " .. p .. " source.", Color3.fromRGB(170, 176, 190)) -- inferred equivalent call
	end

	v19.MouseButton1Click:Connect(function()
		chooseSource("Sheets", "Choose a play mode for this source.", v2 and v2.openSheets)
	end)
	v20.MouseButton1Click:Connect(function()
		chooseSource("Recordings", "Choose a play mode for this source.", v2 and v2.openRecordings)
	end)
	v21.MouseButton1Click:Connect(function()
		chooseSource("MIDI Player", "Choose a play mode for this source.", v2 and v2.openMidi)
	end)
	closePanel.MouseButton1Click:Connect(function()
		playClick() -- inferred equivalent call
		fn7()
	end)

	v10.MouseButton1Click:Connect(function()
		playClick() -- inferred equivalent call
		fn7()
		PianoRoll2DHandler._StartMode("Wait")
	end)
	v11.MouseButton1Click:Connect(function()
		playClick() -- inferred equivalent call
		fn7()
		PianoRoll2DHandler._StartMode("Rhythm")
	end)
	v12.MouseButton1Click:Connect(function()
		playClick() -- inferred equivalent call
		fn7()
		PianoRoll2DHandler._StartMode("Listen")
	end)
	v13.MouseButton1Click:Connect(function()
		if v3 then
			v3:Play()
		end

		PianoRoll2DHandler.Stop(true)
	end)
	v14.MouseButton1Click:Connect(function()
		if v3 then
			v3:Play()
		end

		PianoRoll2DHandler.Hide()
	end)
end

function PianoRoll2DHandler.Open()
	if v2 and v2.isMidiDesktopPlaybackActive and v2.isMidiDesktopPlaybackActive() and v2.stopMidiPlayback then
		v2.stopMidiPlayback()
	end

	if pianoRoll2D then
		pianoRoll2D.Visible = true
		setExternalOverlaysSuppressed(true)
		raiseSourcePanelsAbove2D()
		setOptionModeButtonActive(true)
		fn7()
		setText(v5, "Choose Sheets, Records, or MIDI above.", Color3.fromRGB(170, 176, 190)) -- inferred equivalent call
	end
end

function PianoRoll2DHandler.Hide()
	fn9(false)
end

function PianoRoll2DHandler.Stop(p)
	fn9(p == true)

	if p and pianoRoll2D then
		setText(v5, "Stopped.", Color3.fromRGB(170, 176, 190)) -- inferred equivalent call
	end
end

function PianoRoll2DHandler.IsOpen(): boolean
	return pianoRoll2D ~= nil and pianoRoll2D.Visible == true
end

function PianoRoll2DHandler.IsRunning(p)
	if p then
		return v32 and v24 == p
	end

	return v32
end

function PianoRoll2DHandler.IsPaused()
	return flag
end

function PianoRoll2DHandler.SetPlaybackSpeed(p)
	local playbackSpeed = math.clamp(tonumber(p) or 1, 0.25, 4)
	local v49 = flag and lastTime and lastTime > 0 and lastTime or tick()
	local timelineNow = getTimelineNow(v49) -- inferred equivalent call
	PianoRoll2DHandler._PlaybackSpeed = playbackSpeed
	v40 = v49 - timelineNow / getPlaybackSpeed() -- inferred equivalent call
	return PianoRoll2DHandler._PlaybackSpeed
end

function PianoRoll2DHandler.ApplySettings(p)
	apply2DSettings(p) -- inferred equivalent call
end

function PianoRoll2DHandler.GetPlaybackProgress()
	local playbackSourcePosition, duration = PianoRoll2DHandler._GetPlaybackSourcePosition()
	return { position = playbackSourcePosition, duration = duration }
end

function PianoRoll2DHandler.Seek(p)
	return PianoRoll2DHandler._SeekPlayback(p)
end

function PianoRoll2DHandler.TogglePause(): boolean
	if not v32 then
		return false
	end

	if flag then
		local v48 = tick() - lastTime
		v40 += v48
		flag = false
		lastTime = 0
		setText(v9, "Mode: " .. tostring(mode), Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
		setText(v5, tostring(mode) .. " resumed.", Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
		markActivity() -- inferred equivalent call
		return false
	end

	flag = true
	lastTime = tick()

	if fn2 then
		fn2()
	end

	setText(v9, "Mode: " .. tostring(mode) .. " (Paused)", Color3.fromRGB(255, 190, 80)) -- inferred equivalent call
	setText(v5, "Paused.", Color3.fromRGB(255, 190, 80)) -- inferred equivalent call
	return true
end

function PianoRoll2DHandler.SetSource(p)
	return setLoadedSource(p)
end

function PianoRoll2DHandler.SetSheetSource(value, p, tempo2)
	local v48 = {
		kind = "Sheets",
		name = value or "Current Sheet",
		tokens = parseSheet(p or getSheetText()), -- inferred equivalent call
		tempo = 0,
		usesTiming = false
	}

	if not tempo2 then
		tempo2 = getTempo() -- inferred equivalent call
	end

	v48.tempo = tempo2
	return setLoadedSource(v48)
end

function PianoRoll2DHandler.SetRecordingSource(p)
	return setLoadedSource({
		kind = "Recordings",
		name = p and p.FileName or "Recording",
		tokens = buildRecordingTokens(p),
		usesTiming = true
	})
end

function PianoRoll2DHandler.ShowLoadedSourceModes(): boolean
	if v25 and #v25 > 0 then
		if pianoRoll2D then
			pianoRoll2D.Visible = true
			setExternalOverlaysSuppressed(true)
			setOptionModeButtonActive(true)
		end

		setText(v5, v23 .. " loaded. Choose a play mode.", Color3.fromRGB(120, 210, 255)) -- inferred equivalent call

		if fn8 then
			fn8(v24, v23 .. " loaded. Choose how to play it.")
		end

		return true
	end

	setText(v5, "Load a MIDI, recording, or QWERTY sheet first.", Color3.fromRGB(255, 190, 80)) -- inferred equivalent call
	return false
end

function PianoRoll2DHandler.StartWaitMode()
	PianoRoll2DHandler._StartMode("Wait")
end

function PianoRoll2DHandler.StartRhythmMode()
	PianoRoll2DHandler._StartMode("Rhythm")
end

function PianoRoll2DHandler.StartListenMode()
	PianoRoll2DHandler._StartMode("Listen")
end

function PianoRoll2DHandler.OnNotePlayed(p)
	local v48 = tonumber(p)

	if not v48 then
		return
	end

	if PianoRoll2DHandler._ShouldShowManualEffect() then
		beginManualEffect(v48)
	end

	if pianoRoll2D and pianoRoll2D.Visible and fn5 and not v27[v48] then
		fn5(v48, true)
		task.delay(0.13, function()
			if not v27[v48] and fn5 then
				fn5(v48, false)
			end
		end)
	end

	if not v32 then
		return
	end

	if mode == "Wait" then
		handleWaitNote(v48)
	elseif mode == "Rhythm" then
		handleRhythmNote(v48)
	end
end

function PianoRoll2DHandler.OnNoteReleased(p)
	local v48 = tonumber(p)

	if v48 and pianoRoll2D and pianoRoll2D.Visible and fn5 then
		fn5(v48, false)
	end

	PianoRoll2DHandler._HandleGuidedNoteRelease(v48)
	fn11(v48)
end

function PianoRoll2DHandler.OnQwertyPlayed(value, p)
	if typeof(value) ~= "string" or value == "" then
		return
	end

	local v48 = tonumber(p) or charToNote(value) -- inferred equivalent call

	if v48 and PianoRoll2DHandler._ShouldShowManualEffect() then
		beginManualEffect(v48)
	end

	if pianoRoll2D and pianoRoll2D.Visible and v48 and fn5 and not v27[v48] then
		fn5(v48, true)
	end

	if not v32 then
		return
	end

	if mode == "Wait" then
		local v49 = v36[v47 or v37]

		if v48 and v49 and tokenHasNote(v49, v48) then -- inferred equivalent call
			handleWaitNote(v48)
		elseif v48 and (v24 ~= "Sheets" or not v49 or #(v49.chars or {}) == 0) then
			handleWaitNote(v48)
		else
			handleWaitChar(value)
		end
	elseif mode == "Rhythm" and v48 then
		handleRhythmNote(v48)
	end
end

function PianoRoll2DHandler.Initialize(p, options, p2)
	parent2 = p
	v2 = options or {}
	v3 = p2
	PianoRoll2DHandler._BuildGui()
	readLocal2DSettings()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local pianoRoll2DSettingsChanged = ReplicatedStorage:FindFirstChild("PianoRoll2DSettingsChanged")

	if not pianoRoll2DSettingsChanged then
		pianoRoll2DSettingsChanged = Instance.new("BindableEvent")
		pianoRoll2DSettingsChanged.Name = "PianoRoll2DSettingsChanged"
		pianoRoll2DSettingsChanged.Parent = ReplicatedStorage
	end

	if PianoRoll2DHandler._SettingsChangedConnection then
		PianoRoll2DHandler._SettingsChangedConnection:Disconnect()
		PianoRoll2DHandler._SettingsChangedConnection = nil
	end

	if pianoRoll2DSettingsChanged and pianoRoll2DSettingsChanged:IsA("BindableEvent") then
		PianoRoll2DHandler._SettingsChangedConnection = pianoRoll2DSettingsChanged.Event:Connect(function(p3)
			PianoRoll2DHandler._2DSettings = get2DSettingsPayload(p3)
			push2DSettingsToAttributes()

			if fn10 then
				fn10()
			end
		end)
	end

	local v48 = v2.getAutoPlayerFrame and v2.getAutoPlayerFrame()
	local open2DMode = v48 and v48:FindFirstChild("Open2DMode")

	if open2DMode then
		open2DMode:Destroy()
	end

	local v49 = v2.getSheetsFrame and v2.getSheetsFrame()
	local open2DMode2 = v49 and v49:FindFirstChild("Open2DMode")

	if open2DMode2 then
		open2DMode2:Destroy()
	end

	local v50 = v2.getOptionFrame and v2.getOptionFrame()

	if not v50 and parent2 then
		local pianoContainer = parent2:FindFirstChild("PianoContainer")
		v50 = pianoContainer and pianoContainer:FindFirstChild("OptionFrame")
	end

	PianoRoll2DHandler._WireOptionFrameButton(v50)
end

return PianoRoll2DHandler