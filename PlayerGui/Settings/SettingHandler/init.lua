local result = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = result(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

result = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local localPlayer = result.LocalPlayer

result = Workspace:WaitForChild("Piano_Dependencies")
local parent3 = result:WaitForChild("Modules"):WaitForChild("Logic")
local KeymapLogic = require(parent3:WaitForChild("KeymapLogic"))
local BindsLogic = require(parent3:WaitForChild("BindsLogic"))
local UILogic = require(parent3:WaitForChild("UILogic"))
local PianoLogic = require(parent3:WaitForChild("PianoLogic"))
local dependencies = result:WaitForChild("Modules"):WaitForChild("Dependencies")
local PianoVisualization = require(dependencies:WaitForChild("PianoVisualization"))
local success
success, result = pcall(function()
	return ReplicatedStorage2:WaitForChild("SoundFX")
end)
local clickSound

if success and result then
	clickSound = result:FindFirstChild("ClickSound")
else
	clickSound = nil
end

local function safeClick() -- 39 equivalent calls inferred from this helper
	if clickSound then
		pcall(function()
			clickSound:Play()
		end)
	end
end

require(ReplicatedStorage2:WaitForChild("Services"):WaitForChild("GradientPresets"))
local MonetizationConfig = require(ReplicatedStorage2:WaitForChild("Monetization"):WaitForChild("MonetizationConfig"))
local gamePassId = MonetizationConfig.GetGamePassId("GreatPretender")

local function colorToHex(data) -- 2 equivalent calls inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(data.R * 255),
		math.floor(data.G * 255),
		(math.floor(data.B * 255))
	)
end

local function isSingleColor(list): boolean -- 1 equivalent call inferred from this helper
	if type(list) ~= "table" then
		return false
	end

	if #list == 1 then
		return true
	end

	local item = list[1]

	for i = 2, #list do
		if list[i] ~= item then
			return false
		end
	end

	return true
end

local function createGradientText(tag, gradient)
	local v2 = gradient == "RAINBOW"
		and {
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(255, 127, 0),
			Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 0, 255),
			Color3.fromRGB(75, 0, 130),
			Color3.fromRGB(148, 0, 211)
		}
		or gradient

	if isSingleColor(v2) then -- inferred equivalent call
		v2 = type(v2) == "table" and v2[1] or v2
		return string.format("<font color=\"%s\">%s</font>", colorToHex(v2), tag) -- inferred equivalent call
	else
		local count = #tag
		local v3 = ""

		for i = 1, count do
			local v4 = tag:sub(i, i)
			local v5 = (i - 1) / math.max(count - 1, 1)
			local count2 = #v2
			local v6 = v5 * (count2 - 1)
			local v7 = math.floor(v6) + 1
			local v8 = math.min(v7 + 1, count2)
			local v9 = v6 - (v7 - 1)

			local v10 = v2[v7]
			local v11 = v2[v8]

			v3 ..= string.format(
				"<font color=\"%s\">%s</font>",
				colorToHex(Color3.new( -- inferred equivalent call
					v10.R + (v11.R - v10.R) * v9,
					v10.G + (v11.G - v10.G) * v9,
					v10.B + (v11.B - v10.B) * v9
				)),
				v4
			)
		end

		return v3
	end
end

local parent = script.Parent
local settings = parent:WaitForChild("Settings")

local function bringSettingsGuiToFront()
	parent.DisplayOrder = math.max(parent.DisplayOrder, 1000)
	parent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	settings.ZIndex = math.max(settings.ZIndex, 100)

	local shadow = settings:FindFirstChild("Shadow")

	if shadow and shadow:IsA("GuiObject") then
		shadow.Visible = false
		shadow.Active = false
		shadow.ZIndex = math.max(settings.ZIndex - 1, 1)
	end

	local center = settings:FindFirstChild("Center")

	if center and center:IsA("GuiObject") then
		center.ZIndex = settings.ZIndex + 1
	end
end

bringSettingsGuiToFront()

local center = settings:WaitForChild("Center")
result = center:WaitForChild("Close")
parent3 = center:WaitForChild("Body")
local sideBar = center:WaitForChild("SideBar")

local v2 = {}
v2.SidebarContainer = sideBar:FindFirstChild("CategoryScroll") or sideBar
local general = parent3:WaitForChild("General")
local chatTags = parent3:WaitForChild("ChatTags")
v2.Frame = parent3:FindFirstChild("Title")

if not v2.Frame then
	v2.Frame = chatTags:Clone()
	v2.Frame.Name = "Title"
	v2.Frame.Visible = false
	v2.Frame.Parent = parent3
end

local notebinds = parent3:WaitForChild("Notebinds")
local keybinds = parent3:FindFirstChild("Keybinds")

if not keybinds then
	keybinds = general:Clone()
	keybinds.Name = "Keybinds"
	keybinds.Visible = false
	keybinds.Parent = parent3

	local list = keybinds:FindFirstChild("List")

	if list then
		for _, uiListLayout in ipairs(list:GetChildren()) do
			if not uiListLayout:IsA("UIListLayout") then
				uiListLayout:Destroy()
			end
		end
	end
end

local audio = parent3:FindFirstChild("Audio")

if not audio then
	audio = general:Clone()
	audio.Name = "Audio"
	audio.Visible = false
	audio.Parent = parent3

	local list = audio:FindFirstChild("List")

	if list then
		for _, uiListLayout in ipairs(list:GetChildren()) do
			if not uiListLayout:IsA("UIListLayout") then
				uiListLayout:Destroy()
			end
		end
	end
end

local privacy = parent3:FindFirstChild("Privacy")

if not privacy then
	privacy = general:Clone()
	privacy.Name = "Privacy"
	privacy.Visible = false
	privacy.Parent = parent3

	local list = privacy:FindFirstChild("List")

	if list then
		for _, uiListLayout in ipairs(list:GetChildren()) do
			if not uiListLayout:IsA("UIListLayout") then
				uiListLayout:Destroy()
			end
		end
	end
end

BindsLogic.Initialize(notebinds, KeymapLogic)

local general2 = v2.SidebarContainer:WaitForChild("General")
local chatTags2 = v2.SidebarContainer:WaitForChild("ChatTags")
local notebinds2 = v2.SidebarContainer:WaitForChild("Notebinds")
v2.Sidebar = v2.SidebarContainer:FindFirstChild("Title")

if not v2.Sidebar then
	v2.Sidebar = chatTags2:Clone()
	v2.Sidebar.Name = "Title"

	for _, title in ipairs(v2.Sidebar:GetChildren()) do
		if not title:IsA("TextLabel") then
			continue
		end

		title.Name = "Title"
		title.Text = "Title"
	end

	v2.Sidebar.Parent = v2.SidebarContainer
end

local audio2 = v2.SidebarContainer:FindFirstChild("Audio")

if not audio2 then
	audio2 = chatTags2:Clone()
	audio2.Name = "Audio"

	for _, audio3 in ipairs(audio2:GetChildren()) do
		if not audio3:IsA("TextLabel") then
			continue
		end

		audio3.Name = "Audio"
		audio3.Text = "Audio"
	end

	audio2.Parent = v2.SidebarContainer
end

local privacy2 = v2.SidebarContainer:FindFirstChild("Privacy")

if not privacy2 then
	privacy2 = chatTags2:Clone()
	privacy2.Name = "Privacy"

	for _, privacy3 in ipairs(privacy2:GetChildren()) do
		if not privacy3:IsA("TextLabel") then
			continue
		end

		privacy3.Name = "Privacy"
		privacy3.Text = "Privacy"
	end

	privacy2.Parent = v2.SidebarContainer
end

local keybinds2 = v2.SidebarContainer:FindFirstChild("Keybinds")

if not keybinds2 then
	keybinds2 = notebinds2:Clone()
	keybinds2.Name = "Keybinds"

	for _, keybinds3 in ipairs(keybinds2:GetChildren()) do
		if not keybinds3:IsA("TextLabel") then
			continue
		end

		keybinds3.Name = "Keybinds"
		keybinds3.Text = "Keybinds"
	end

	keybinds2.Parent = v2.SidebarContainer
end

general2.LayoutOrder = 1
audio2.LayoutOrder = 2
privacy2.LayoutOrder = 3
keybinds2.LayoutOrder = 6
notebinds2.LayoutOrder = 7
chatTags2.LayoutOrder = 8
v2.Sidebar.LayoutOrder = 9
parent3 = general2:WaitForChild("Active")
local active = audio2:WaitForChild("Active")
local active2 = privacy2:WaitForChild("Active")
local active3 = chatTags2:WaitForChild("Active")
v2.Button = v2.Sidebar:WaitForChild("Active")
local active4 = keybinds2:WaitForChild("Active")
local active5 = notebinds2:WaitForChild("Active")

general2.Visible = true
audio2.Visible = true
privacy2.Visible = true
keybinds2.Visible = true
notebinds2.Visible = true
chatTags2.Visible = false
v2.Sidebar.Visible = false
active3.Active = false
v2.Button.Active = false

if active3:IsA("GuiButton") then
	active3.Selectable = false
end

if v2.Button:IsA("GuiButton") then
	v2.Button.Selectable = false
end

local list = general:WaitForChild("List")
local reset = general:WaitForChild("Reset")
local list2 = chatTags:WaitForChild("List")
local reset2 = chatTags:WaitForChild("Reset")
v2.List = v2.Frame:WaitForChild("List")
v2.ResetButton = v2.Frame:WaitForChild("Reset")
local list3 = audio:WaitForChild("List")
local reset3 = audio:WaitForChild("Reset")
local list4 = privacy:WaitForChild("List")
local reset4 = privacy:WaitForChild("Reset")
local list5 = keybinds:WaitForChild("List")
local reset5 = keybinds:WaitForChild("Reset")

local tagHandler = list2:WaitForChild("TagHandler")
local tagList = tagHandler:WaitForChild("TagList")
v2.TagHandler = v2.List:WaitForChild("TagHandler")
v2.TagList = v2.TagHandler:WaitForChild("TagList")
local TagTemplate = script:WaitForChild("TagTemplate")

local function ensureSettingsCorner(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local uiCorner = guiObject:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, p)
	uiCorner.Parent = guiObject
end

local function normalizeSettingsLayout()
	chatTags.AnchorPoint = general.AnchorPoint
	chatTags.Position = general.Position
	chatTags.Size = general.Size
	chatTags.BackgroundColor3 = general.BackgroundColor3
	chatTags.BackgroundTransparency = general.BackgroundTransparency
	chatTags.BorderSizePixel = general.BorderSizePixel

	list2.AnchorPoint = list.AnchorPoint
	list2.Position = list.Position
	list2.Size = list.Size
	list2.BackgroundColor3 = list.BackgroundColor3
	list2.BackgroundTransparency = list.BackgroundTransparency
	list2.BorderSizePixel = list.BorderSizePixel
	list2.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list2.CanvasSize = UDim2.new(0, 0, 0, 0)

	tagHandler.AnchorPoint = Vector2.new(0, 0)
	tagHandler.Position = UDim2.new(0, 0, 0, 0)
	tagHandler.Size = UDim2.new(1, -8, 0, 280)
	tagHandler.BackgroundTransparency = 1
	tagHandler.BorderSizePixel = 0

	tagList.AnchorPoint = Vector2.new(0, 0)
	tagList.Position = UDim2.new(0, 0, 0, 0)
	tagList.Size = UDim2.new(1, 0, 1, 0)
	tagList.BackgroundTransparency = 1
	tagList.BorderSizePixel = 0
	tagList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tagList.CanvasSize = UDim2.new(0, 0, 0, 0)

	reset2.AnchorPoint = reset.AnchorPoint
	reset2.Position = reset.Position
	reset2.Size = reset.Size

	v2.Frame.AnchorPoint = general.AnchorPoint
	v2.Frame.Position = general.Position
	v2.Frame.Size = general.Size
	v2.Frame.BackgroundColor3 = general.BackgroundColor3
	v2.Frame.BackgroundTransparency = general.BackgroundTransparency
	v2.Frame.BorderSizePixel = general.BorderSizePixel

	v2.List.AnchorPoint = list.AnchorPoint
	v2.List.Position = list.Position
	v2.List.Size = list.Size
	v2.List.BackgroundColor3 = list.BackgroundColor3
	v2.List.BackgroundTransparency = list.BackgroundTransparency
	v2.List.BorderSizePixel = list.BorderSizePixel
	v2.List.AutomaticCanvasSize = Enum.AutomaticSize.Y
	v2.List.CanvasSize = UDim2.new(0, 0, 0, 0)

	v2.TagHandler.AnchorPoint = Vector2.new(0, 0)
	v2.TagHandler.Position = UDim2.new(0, 0, 0, 0)
	v2.TagHandler.Size = UDim2.new(1, -8, 0, 280)
	v2.TagHandler.BackgroundTransparency = 1
	v2.TagHandler.BorderSizePixel = 0

	v2.TagList.AnchorPoint = Vector2.new(0, 0)
	v2.TagList.Position = UDim2.new(0, 0, 0, 0)
	v2.TagList.Size = UDim2.new(1, 0, 1, 0)
	v2.TagList.BackgroundTransparency = 1
	v2.TagList.BorderSizePixel = 0
	v2.TagList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	v2.TagList.CanvasSize = UDim2.new(0, 0, 0, 0)

	v2.ResetButton.AnchorPoint = reset.AnchorPoint
	v2.ResetButton.Position = reset.Position
	v2.ResetButton.Size = reset.Size

	audio.AnchorPoint = general.AnchorPoint
	audio.Position = general.Position
	audio.Size = general.Size
	audio.BackgroundColor3 = general.BackgroundColor3
	audio.BackgroundTransparency = general.BackgroundTransparency
	audio.BorderSizePixel = general.BorderSizePixel
	list3.AnchorPoint = list.AnchorPoint
	list3.Position = list.Position
	list3.Size = UDim2.new(1, 0, 1, -54)
	list3.BackgroundColor3 = list.BackgroundColor3
	list3.BackgroundTransparency = list.BackgroundTransparency
	list3.BorderSizePixel = list.BorderSizePixel
	list3.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list3.CanvasSize = UDim2.new(0, 0, 0, 0)
	list3.ScrollBarThickness = 4
	ensureSettingsCorner(audio, 8)
	ensureSettingsCorner(list3, 8)
	reset3.AnchorPoint = Vector2.new(0, 1)
	reset3.Position = UDim2.new(0, 0, 1, -2)
	reset3.Size = UDim2.new(1, 0, 0, 36)
	reset3.Text = "Reset Audio"
	ensureSettingsCorner(reset3, 8)

	privacy.AnchorPoint = general.AnchorPoint
	privacy.Position = general.Position
	privacy.Size = general.Size
	privacy.BackgroundColor3 = general.BackgroundColor3
	privacy.BackgroundTransparency = general.BackgroundTransparency
	privacy.BorderSizePixel = general.BorderSizePixel
	list4.AnchorPoint = list.AnchorPoint
	list4.Position = list.Position
	list4.Size = UDim2.new(1, 0, 1, -54)
	list4.BackgroundColor3 = list.BackgroundColor3
	list4.BackgroundTransparency = list.BackgroundTransparency
	list4.BorderSizePixel = list.BorderSizePixel
	list4.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list4.CanvasSize = UDim2.new(0, 0, 0, 0)
	list4.ScrollBarThickness = 4
	ensureSettingsCorner(privacy, 8)
	ensureSettingsCorner(list4, 8)
	reset4.AnchorPoint = Vector2.new(0, 1)
	reset4.Position = UDim2.new(0, 0, 1, -2)
	reset4.Size = UDim2.new(1, 0, 0, 36)
	reset4.Text = "Reset Privacy"
	ensureSettingsCorner(reset4, 8)

	keybinds.AnchorPoint = general.AnchorPoint
	keybinds.Position = general.Position
	keybinds.Size = general.Size
	keybinds.BackgroundColor3 = general.BackgroundColor3
	keybinds.BackgroundTransparency = general.BackgroundTransparency
	keybinds.BorderSizePixel = general.BorderSizePixel
	list5.AnchorPoint = list.AnchorPoint
	list5.Position = list.Position
	list5.Size = UDim2.new(1, 0, 1, -54)
	list5.BackgroundColor3 = list.BackgroundColor3
	list5.BackgroundTransparency = list.BackgroundTransparency
	list5.BorderSizePixel = list.BorderSizePixel
	list5.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list5.CanvasSize = UDim2.new(0, 0, 0, 0)
	list5.ScrollBarThickness = 4
	ensureSettingsCorner(keybinds, 8)
	ensureSettingsCorner(list5, 8)
	reset5.AnchorPoint = Vector2.new(0, 1)
	reset5.Position = UDim2.new(0, 0, 1, -2)
	reset5.Size = UDim2.new(1, 0, 0, 36)
	reset5.Text = "Reset Keybinds"
	ensureSettingsCorner(reset5, 8)

	for _, v3 in ipairs({ general2, audio2, privacy2, chatTags2, v2.Sidebar, keybinds2, notebinds2 }) do
		ensureSettingsCorner(v3, 8)
		local textLabel = v3:FindFirstChildWhichIsA("TextLabel")

		if not textLabel then
			continue
		end

		textLabel.AnchorPoint = Vector2.new(0, 0)
		textLabel.Position = UDim2.new(0, 12, 0, 0)
		textLabel.Size = UDim2.new(1, -24, 1, 0)
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.TextWrapped = true
		textLabel.TextScaled = true
		textLabel.TextTruncate = Enum.TextTruncate.None

		if not textLabel:FindFirstChildOfClass("UITextSizeConstraint") then
			local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
			uiTextSizeConstraint.Parent = textLabel
		end

		local uiTextSizeConstraint = textLabel:FindFirstChildOfClass("UITextSizeConstraint")
		uiTextSizeConstraint.MinTextSize = 12
		local uiTextSizeConstraint_2 = textLabel:FindFirstChildOfClass("UITextSizeConstraint")
		uiTextSizeConstraint_2.MaxTextSize = 22
	end
end

normalizeSettingsLayout()

local success2, result2 = pcall(function()
	local piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)

	if piano_Dependencies then
		return piano_Dependencies:WaitForChild("Remotes", 10)
	end

	return nil
end)
local advancedChatTags, updateTagPreferences, requestChatTags, saveVisualizerSettings, visualizerSettingsLoaded, getPianoUserSettings, savePianoUserSettings, pianoUserSettingsLoaded, checkGamepassEntitlement, shopPurchasesUpdated

if success2 and result2 then
	advancedChatTags = result2:FindFirstChild("AdvancedChatTags")
	updateTagPreferences = result2:FindFirstChild("UpdateTagPreferences")
	requestChatTags = result2:FindFirstChild("RequestChatTags")
	v2.UpdatePreferences = result2:FindFirstChild("UpdateTitlePreferences")
	v2.RequestTitles = result2:FindFirstChild("RequestTitles")
	saveVisualizerSettings = result2:FindFirstChild("SaveVisualizerSettings")
		or result2:WaitForChild("SaveVisualizerSettings", 5)
	visualizerSettingsLoaded = result2:FindFirstChild("VisualizerSettingsLoaded")
		or result2:WaitForChild("VisualizerSettingsLoaded", 5)
	getPianoUserSettings = result2:FindFirstChild("GetPianoUserSettings")
		or result2:WaitForChild("GetPianoUserSettings", 5)
	savePianoUserSettings = result2:FindFirstChild("SavePianoUserSettings")
		or result2:WaitForChild("SavePianoUserSettings", 5)
	pianoUserSettingsLoaded = result2:FindFirstChild("PianoUserSettingsLoaded")
		or result2:WaitForChild("PianoUserSettingsLoaded", 5)
	checkGamepassEntitlement = result2:FindFirstChild("CheckGamepassEntitlement")
		or result2:WaitForChild("CheckGamepassEntitlement", 5)
	shopPurchasesUpdated = result2:FindFirstChild("ShopPurchasesUpdated")
		or result2:WaitForChild("ShopPurchasesUpdated", 5)
	v2.CheckGamepassEntitlement = checkGamepassEntitlement
else
	saveVisualizerSettings = nil
	savePianoUserSettings = nil
	checkGamepassEntitlement = nil
	updateTagPreferences = nil
	requestChatTags = nil
	getPianoUserSettings = nil
end

local OpenPianoColorWheel = ReplicatedStorage2:FindFirstChild("OpenPianoColorWheel")

if not OpenPianoColorWheel then
	OpenPianoColorWheel = Instance.new("BindableEvent")
	OpenPianoColorWheel.Name = "OpenPianoColorWheel"
	OpenPianoColorWheel.Parent = ReplicatedStorage2
end

local PianoRoll2DSettingsChanged = ReplicatedStorage2:FindFirstChild("PianoRoll2DSettingsChanged")

if not PianoRoll2DSettingsChanged then
	PianoRoll2DSettingsChanged = Instance.new("BindableEvent")
	PianoRoll2DSettingsChanged.Name = "PianoRoll2DSettingsChanged"
	PianoRoll2DSettingsChanged.Parent = ReplicatedStorage2
end

result2 = ReplicatedStorage2:FindFirstChild("PianoRoll2DColorPicked")

if not result2 then
	result2 = Instance.new("BindableEvent")
	result2.Name = "PianoRoll2DColorPicked"
	result2.Parent = ReplicatedStorage2
end

local OverheadStatusUpdate = ReplicatedStorage2:WaitForChild("OverheadStatusUpdate", 10)
local UpdateFlagVisibility = ReplicatedStorage2:WaitForChild("UpdateFlagVisibility", 10)

local color = Color3.fromRGB(45, 118, 235)
local color2 = Color3.fromRGB(34, 39, 44)
local color3 = Color3.fromRGB(200, 60, 60)

local v3 = "General"
local v4 = {}
local v5 = {}
v2.Tags = {}
v2.Enabled = {}
local v6 = {
	DefaultSynthesiaEnabled = localPlayer:GetAttribute("DefaultSynthesiaEnabled") ~= false,
	HeartParticleEffectEnabled = localPlayer:GetAttribute("HeartParticleEffectEnabled") ~= false,
	HeartParticleEffectUnlocked = localPlayer:GetAttribute("HeartParticleEffectUnlocked") == true,
	HeartParticleToggleButton = nil,
	VisualizerColorHex = localPlayer:GetAttribute("CurrentColourHex") or "#FFFFFF",
	WhiteSynthesiaHex = localPlayer:GetAttribute("WhiteSynthesiaHex") or "#FFFFFF",
	BlackSynthesiaHex = localPlayer:GetAttribute("BlackSynthesiaHex") or "#FFFFFF",
	ModelKeyHighlightEnabled = localPlayer:GetAttribute("ModelKeyHighlightEnabled") ~= false,
	HandIKEnabled = localPlayer:GetAttribute("HandIKEnabled") ~= false,
	WhiteKeyHighlightHex = localPlayer:GetAttribute("WhiteKeyHighlightHex") or "#66FF66",
	BlackKeyHighlightHex = localPlayer:GetAttribute("BlackKeyHighlightHex") or "#66FF66"
}

local v7 = nil
local v8 = nil
local v9 = false
local v10 = localPlayer:GetAttribute("HideAutoplayingTag") ~= false
local v11 = localPlayer:GetAttribute("ShowCountryFlag") ~= false
local v12 = localPlayer:GetAttribute("HideOtherPlayers") == true
local v13 = localPlayer:GetAttribute("OtherPlayerTileEffectsEnabled") ~= false
mapAtmosphereEnabled = localPlayer:GetAttribute("MapAtmosphereEnabled") == true
local v14 = nil
local v15 = nil
local v16 = nil
local v17 = nil
mapAtmosphereToggleButton = nil
local otherPianoVolume2 = tonumber(localPlayer:GetAttribute("OtherPianoVolume")) or 100
local v18 = nil
local v19 = nil
local v20 = nil
local v21 = false
local maxPianoSoundsBounds, v22, v23 = PianoLogic.GetMaxPianoSoundsBounds()
local maxPianoSounds = tonumber(localPlayer:GetAttribute("MaxPianoSounds")) or PianoLogic.GetMaxPianoSounds() or v23
local v24 = nil
local v25 = nil
local v26 = nil
local v27 = false
local v28 = { "Circle", "Ring", "Burst", "Ray", "Flare", "Heart", "Diamond", "Star" }
local v29 = {
	TileColorHex = "#5FBEFF",
	WhiteTileColorHex = "#5FBEFF",
	BlackTileColorHex = "#1E3A5F",
	ImpactColorHex = "#5FBEFF",
	ImpactShape = "Circle",
	BackgroundImage = "",
	BackgroundTransparency = 45
}

local v30 = {
	TileColorHex = 0,
	WhiteTileColorHex = 0,
	BlackTileColorHex = 0,
	ImpactColorHex = 0,
	ImpactShape = 0,
	BackgroundImage = 0,
	BackgroundTransparency = 0
}
v30.TileColorHex = localPlayer:GetAttribute("PianoRoll2DTileColorHex") or v29.TileColorHex
v30.WhiteTileColorHex = localPlayer:GetAttribute("PianoRoll2DWhiteTileColorHex")
	or localPlayer:GetAttribute("PianoRoll2DTileColorHex")
	or v29.WhiteTileColorHex
v30.BlackTileColorHex = localPlayer:GetAttribute("PianoRoll2DBlackTileColorHex") or v29.BlackTileColorHex
v30.ImpactColorHex = localPlayer:GetAttribute("PianoRoll2DImpactColorHex") or v29.ImpactColorHex
v30.ImpactShape = localPlayer:GetAttribute("PianoRoll2DImpactShape") or v29.ImpactShape
v30.BackgroundImage = localPlayer:GetAttribute("PianoRoll2DBackgroundImage") or v29.BackgroundImage
v30.BackgroundTransparency = localPlayer:GetAttribute("PianoRoll2DBackgroundTransparency") or v29.BackgroundTransparency

local nameSet = {}
local v31 = nil
local v32 = nil
local v36 = nil
local v37 = nil
local v38 = nil
local v39 = nil
local fn
local v40 = nil
local v41 = nil
local v42 = nil
local v43 = false
local pianoRoll2DShapePanel = nil
local v44 = {
	{
		id = "Sustain",
		label = "Sustain Pedal",
		description = "Hold/tap sustain while playing",
		order = 1
	},
	{ id = "ExitPiano", label = "Exit Piano", description = "Leave the current piano", order = 2 },
	{ id = "TransposeUp", label = "Transpose Up", description = "Raise transpose by 1", order = 3 },
	{
		id = "TransposeDown",
		label = "Transpose Down",
		description = "Lower transpose by 1",
		order = 4
	},
	{ id = "VolumeUp", label = "Volume Up", description = "Increase your piano volume", order = 5 },
	{
		id = "VolumeDown",
		label = "Volume Down",
		description = "Decrease your piano volume",
		order = 6
	},
	{
		id = "ShiftTranspose",
		label = "Shift Transpose",
		description = "Temporary transpose modifier",
		order = 7
	},
	{
		id = "VelocityModifier",
		label = "Velocity Modifier",
		description = "Hold to use alternate velocity",
		order = 8
	},
	{
		id = "Above88Modifier",
		label = "88 Key / High Note Modifier",
		description = "Hold to access higher notes",
		order = 9
	}
}

local v45 = {
	{ id = "ManualAuto1", label = "Auto Player 1", order = 1 },
	{ id = "ManualAuto2", label = "Auto Player 2", order = 2 },
	{ id = "ManualAuto3", label = "Auto Player 3", order = 3 },
	{ id = "ManualAuto4", label = "Auto Player 4", order = 4 }
}
local actionKeyBinds2 = {}

local v47 = {
	Sustain = "Space",
	ExitPiano = "Backspace",
	ShiftTranspose = "LeftShift",
	Above88Modifier = "LeftControl",
	VelocityModifier = "LeftAlt",
	TransposeUp = "Up",
	TransposeDown = "Down",
	VolumeUp = "Right",
	VolumeDown = "Left",
	ManualAuto1 = "Minus",
	ManualAuto2 = "Equals",
	ManualAuto3 = "LeftBracket",
	ManualAuto4 = "RightBracket"
}
local inputBeganConnection = nil
local v48 = nil
local fn2
local keyButtonsById = {}
local v49 = nil
local keyButtonsById2 = {}

for _, v50 in ipairs({ KeymapLogic.PianoKeyCodes() }) do
	nameSet[v50.Name] = true
end

local v50 = {
	LeftShift = "Left Shift",
	RightShift = "Right Shift",
	LeftControl = "Left Ctrl",
	RightControl = "Right Ctrl",
	LeftAlt = "Left Alt",
	RightAlt = "Right Alt",
	LeftBracket = "[",
	RightBracket = "]",
	Equals = "=",
	Minus = "-",
	Backspace = "Backspace",
	Space = "Space"
}

local function hexToColor3(value)
	if typeof(value) ~= "string" then
		return nil
	end

	local v51 = value:gsub("#", "")

	if #v51 ~= 6 then
		return nil
	end

	local v52 = tonumber(v51:sub(1, 2), 16)
	local v53 = tonumber(v51:sub(3, 4), 16)
	local v54 = tonumber(v51:sub(5, 6), 16)

	if v52 and v53 and v54 then
		return Color3.fromRGB(v52, v53, v54)
	end

	return nil
end

local function applyGuiHighlightSettings()
	local v51 = hexToColor3(v6.WhiteKeyHighlightHex) or Color3.fromRGB(102, 255, 102)
	local v52 = hexToColor3(v6.BlackKeyHighlightHex) or Color3.fromRGB(102, 255, 102)
	UILogic.SetActiveKeyHighlightColors(v51, v52)
	localPlayer:SetAttribute("WhiteKeyHighlightHex", v6.WhiteKeyHighlightHex)
	localPlayer:SetAttribute("BlackKeyHighlightHex", v6.BlackKeyHighlightHex)
end

local function saveVisualizerSetting(p) -- 5 equivalent calls inferred from this helper
	if saveVisualizerSettings and typeof(p) == "table" then
		saveVisualizerSettings:FireServer(p)
	end
end

local function refreshSynthesiaToggle() -- 3 equivalent calls inferred from this helper
	if not v7 then
		return
	end

	local defaultSynthesiaEnabled = v6.DefaultSynthesiaEnabled ~= false
	v7.Text = defaultSynthesiaEnabled and "ON" or "OFF"
	v7.BackgroundColor3 = defaultSynthesiaEnabled and color or color2
end

function v2.RefreshHeartParticleToggle()
	if not v6.HeartParticleToggleButton then
		return
	end

	if v6.HeartParticleEffectUnlocked then
		local heartParticleEffectEnabled = v6.HeartParticleEffectEnabled ~= false
		v6.HeartParticleToggleButton.Text = heartParticleEffectEnabled and "ON" or "OFF"
		v6.HeartParticleToggleButton.BackgroundColor3 = heartParticleEffectEnabled and color or color2
	else
		v6.HeartParticleToggleButton.Text = "LOCKED"
		v6.HeartParticleToggleButton.BackgroundColor3 = color2
	end
end

function v2.RefreshHeartParticleEntitlement()
	local gamePassId2 = MonetizationConfig.GetGamePassId("HeartParticleEffect")

	if gamePassId2 and gamePassId2 ~= 0 then
		local success3, result3 = pcall(function()
			if v2.CheckGamepassEntitlement then
				return v2.CheckGamepassEntitlement:InvokeServer(gamePassId2)
			end

			return MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, gamePassId2)
		end)

		v6.HeartParticleEffectUnlocked = success3 and result3 == true

		if v6.HeartParticleEffectUnlocked then
			localPlayer:SetAttribute("HeartParticleEffectUnlocked", true)
		end

		v2.RefreshHeartParticleToggle()
	else
		v6.HeartParticleEffectUnlocked = false
		v2.RefreshHeartParticleToggle()
	end
end

local function refreshModelKeyHighlightToggle() -- 3 equivalent calls inferred from this helper
	if not v8 then
		return
	end

	local modelKeyHighlightEnabled = v6.ModelKeyHighlightEnabled ~= false
	v8.Text = modelKeyHighlightEnabled and "ON" or "OFF"
	v8.BackgroundColor3 = modelKeyHighlightEnabled and color or color2
end

function refreshHandIKToggle()
	local handIKToggleButton = v6.HandIKToggleButton

	if not handIKToggleButton then
		return
	end

	local handIKEnabled = v6.HandIKEnabled ~= false
	handIKToggleButton.Text = handIKEnabled and "ON" or "OFF"
	handIKToggleButton.BackgroundColor3 = handIKEnabled and color or color2
end

function refreshMapAtmosphereToggle()
	if not mapAtmosphereToggleButton then
		return
	end

	mapAtmosphereToggleButton.Text = mapAtmosphereEnabled and "ON" or "OFF"
	mapAtmosphereToggleButton.BackgroundColor3 = mapAtmosphereEnabled and color or color2
end

function saveMapAtmosphereSetting()
	if savePianoUserSettings then
		savePianoUserSettings:FireServer({
			MapAtmosphereEnabled = mapAtmosphereEnabled == true
		})
	end
end

local function createSettingRow(text, value, layoutOrder, p)
	local parent2 = p or list
	local name = text:gsub("%s+", "") .. "Row"
	local parent4 = parent2:FindFirstChild(name)

	if not parent4 then
		parent4 = Instance.new("Frame")
		parent4.Name = name
		parent4.Parent = parent2
	end

	parent4.LayoutOrder = layoutOrder
	parent4.Size = UDim2.new(1, -8, 0, 58)
	parent4.BackgroundColor3 = Color3.fromRGB(36, 41, 46)
	parent4.BorderSizePixel = 0

	local uiCorner = parent4:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = parent4

	local label = parent4:FindFirstChild("Label") or Instance.new("TextLabel")
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 14, 0.5, value and -8 or 0)
	label.Size = UDim2.new(1, -160, 0, 22)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(240, 242, 246)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent4

	local description = parent4:FindFirstChild("Description") or Instance.new("TextLabel")
	description.Name = "Description"
	description.AnchorPoint = Vector2.new(0, 0.5)
	description.Position = UDim2.new(0, 14, 0.5, 13)
	description.Size = UDim2.new(1, -160, 0, 18)
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.Gotham
	description.Text = value or ""
	description.TextColor3 = Color3.fromRGB(160, 166, 180)
	description.TextSize = 12
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextTruncate = Enum.TextTruncate.AtEnd
	description.Visible = value ~= nil and value ~= ""
	description.Parent = parent4

	return parent4
end

local function createActionButton(parent2, text)
	local action = parent2:FindFirstChild("Action") or Instance.new("TextButton")
	action.Name = "Action"
	action.AnchorPoint = Vector2.new(1, 0.5)
	action.Position = UDim2.new(1, -12, 0.5, 0)
	action.Size = UDim2.new(0, 118, 0, 34)
	action.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
	action.BorderSizePixel = 0
	action.AutoButtonColor = true
	action.Font = Enum.Font.GothamBold
	action.Text = text
	action.TextColor3 = Color3.fromRGB(255, 255, 255)
	action.TextSize = 13
	action.Parent = parent2

	local uiCorner = action:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = action
	return action
end

local TeamSettingsCategoryController = require(script:WaitForChild("TeamSettingsCategoryController"))
v2.TeamSettings = TeamSettingsCategoryController.new(script)
v2.TeamSettings:NormalizeLayout()
local LightingSettingsCategoryController = require(script:WaitForChild("LightingSettingsCategoryController"))
v2.LightingSettings = LightingSettingsCategoryController.new(script)
v2.LightingSettings:NormalizeLayout()
v2.LightingSettings:BindMapAtmosphere(function(): boolean
	return mapAtmosphereEnabled == true
end, function(p)
	mapAtmosphereEnabled = p == true
	localPlayer:SetAttribute("MapAtmosphereEnabled", mapAtmosphereEnabled)
	refreshMapAtmosphereToggle()
	saveMapAtmosphereSetting()
end)

local function updateOtherPianoVolumeVisuals()
	otherPianoVolume2 = math.clamp(math.floor(tonumber(otherPianoVolume2) or 100), 0, 100)
	localPlayer:SetAttribute("OtherPianoVolume", otherPianoVolume2)
	localPlayer:SetAttribute("MuteOtherPianos", otherPianoVolume2 <= 0)

	if v18 then
		v18.Text = tostring(otherPianoVolume2) .. "%"
	end

	local v51 = otherPianoVolume2 / 100

	if v19 then
		v19.Size = UDim2.new(v51, 0, 1, 0)
	end

	if v20 then
		v20.Position = UDim2.new(v51, 0, 0.5, 0)
	end
end

local count = 0
local function saveOtherPianoVolume() -- 3 equivalent calls inferred from this helper
	if not savePianoUserSettings then
		return
	end

	count += 1
	local v51 = count
	task.delay(0.25, function()
		if v51 ~= count then
			return
		end

		savePianoUserSettings:FireServer({
			OtherPianoVolume = otherPianoVolume2,
			MuteOtherPianos = otherPianoVolume2 <= 0
		})
	end)
end

localPlayer:GetAttributeChangedSignal("OtherPianoVolume"):Connect(function()
	local otherPianoVolume = tonumber(localPlayer:GetAttribute("OtherPianoVolume"))

	if otherPianoVolume == nil then
		return
	end

	local v51 = math.clamp(math.floor(otherPianoVolume + 0.5), 0, 100)

	if v51 == otherPianoVolume2 then
		return
	end

	otherPianoVolume2 = v51
	updateOtherPianoVolumeVisuals()
end)

local function updateMaxPianoSoundsVisuals()
	maxPianoSounds = math.clamp(math.floor(tonumber(maxPianoSounds) or v23), maxPianoSoundsBounds, v22)
	localPlayer:SetAttribute("MaxPianoSounds", maxPianoSounds)

	if PianoLogic.SetMaxPianoSounds then
		PianoLogic.SetMaxPianoSounds(maxPianoSounds)
	end

	if v24 then
		v24.Text = tostring(maxPianoSounds)
	end

	local v51 = math.max(v22 - maxPianoSoundsBounds, 1)
	local v52 = (maxPianoSounds - maxPianoSoundsBounds) / v51

	if v25 then
		v25.Size = UDim2.new(v52, 0, 1, 0)
	end

	if v26 then
		v26.Position = UDim2.new(v52, 0, 0.5, 0)
	end
end

local count2 = 0
local function saveMaxPianoSounds() -- 3 equivalent calls inferred from this helper
	if not savePianoUserSettings then
		return
	end

	count2 += 1
	local v51 = count2
	task.delay(0.25, function()
		if v51 ~= count2 then
			return
		end

		savePianoUserSettings:FireServer({ MaxPianoSounds = maxPianoSounds })
	end)
end

local function sendOverheadAutoplayingPreference() -- 1 equivalent call inferred from this helper
	if OverheadStatusUpdate then
		OverheadStatusUpdate:FireServer("HideAutoplayingTag", v10 == true)
	end
end

local function sendCountryFlagPreference() -- 1 equivalent call inferred from this helper
	if UpdateFlagVisibility then
		UpdateFlagVisibility:FireServer(v11 ~= true)
	end
end

local function pushPrivacySettingsToRuntime()
	localPlayer:SetAttribute("HideAutoplayingTag", v10 == true)
	localPlayer:SetAttribute("ShowCountryFlag", v11 == true)
	localPlayer:SetAttribute("HideOtherPlayers", v12 == true)
	localPlayer:SetAttribute("OtherPlayerTileEffectsEnabled", v13 ~= false)
	localPlayer:SetAttribute("MapAtmosphereEnabled", mapAtmosphereEnabled == true)
	sendOverheadAutoplayingPreference() -- inferred equivalent call
	sendCountryFlagPreference() -- inferred equivalent call
end

local function refreshGreatPretenderEntitlement()
	local v51 = false

	if gamePassId and gamePassId ~= 0 then
		if checkGamepassEntitlement then
			local success3, result3 = pcall(function()
				return checkGamepassEntitlement:InvokeServer(gamePassId)
			end)

			if success3 then
				v51 = result3 == true
			else
				v.Warn("[Settings] Great Pretender entitlement check failed: " .. tostring(result3))
			end
		else
			local success3, result3 = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, gamePassId)
			end)
			v51 = success3 and result3 == true
		end
	end

	local v52 = not v9
	v9 = v51

	if v9 and v52 and typeof(localPlayer:GetAttribute("HideAutoplayingTag")) ~= "boolean" then
		v10 = true
	end

	return v9
end

local function refreshPrivacyToggles()
	if v14 then
		if v9 then
			v14.Text = v10 and "ON" or "OFF"
			v14.BackgroundColor3 = v10 and color or color2
		else
			v14.Text = "LOCKED"
			v14.BackgroundColor3 = color2
		end
	end

	if v15 then
		v15.Text = v11 and "ON" or "OFF"
		v15.BackgroundColor3 = v11 and color or color2
	end

	if v16 then
		v16.Text = v12 and "ON" or "OFF"
		v16.BackgroundColor3 = v12 and color or color2
	end

	if v17 then
		v17.Text = v13 and "ON" or "OFF"
		v17.BackgroundColor3 = v13 and color or color2
	end
end

local count3 = 0
local function savePrivacySettings() -- 7 equivalent calls inferred from this helper
	if not savePianoUserSettings then
		return
	end

	count3 += 1
	local v51 = count3
	task.delay(0.2, function()
		if v51 ~= count3 then
			return
		end

		savePianoUserSettings:FireServer({
			HideAutoplayingTag = v10 == true,
			ShowCountryFlag = v11 == true,
			HideOtherPlayers = v12 == true,
			OtherPlayerTileEffectsEnabled = v13 ~= false
		})
	end)
end

local function normalizePianoRoll2DHex(value, p) -- 8 equivalent calls inferred from this helper
	local upper = tostring(value or ""):gsub("#", ""):upper()

	if upper:match("^%x%x%x%x%x%x$") then
		return "#" .. upper
	end

	return p
end

local function normalizePianoRoll2DImage(value)
	local v51 = tostring(value or ""):match("^%s*(.-)%s*$") or ""

	if v51 == "" then
		return ""
	end

	local v52 = v51:match("^rbxassetid://(%d+)$") or v51:match("^(%d+)$") or v51:match("roblox%.com/.*/(%d+)")

	if v52 then
		return "rbxassetid://" .. v52
	end

	return ""
end

local function normalizePianoRoll2DShape(impactShape)
	local v51 = tostring(impactShape or v29.ImpactShape)

	for _, v52 in ipairs(v28) do
		if v51:lower() == v52:lower() then
			return v52
		end
	end

	return v29.ImpactShape
end

local function normalizePianoRoll2DSettings(p)
	local v51 = typeof(p) == "table" and p or {}
	local pianoRoll2DHex = normalizePianoRoll2DHex(v51.TileColorHex, v29.TileColorHex) -- inferred equivalent call
	local pianoRoll2DHex2 = normalizePianoRoll2DHex(v51.WhiteTileColorHex, pianoRoll2DHex) -- inferred equivalent call
	local blackTileColorHex = normalizePianoRoll2DHex(v51.BlackTileColorHex, v29.BlackTileColorHex) -- inferred equivalent call

	if pianoRoll2DHex == "#5FBEFF" and pianoRoll2DHex2 == "#5FBEFF" and blackTileColorHex == "#5FBEFF" then
		blackTileColorHex = v29.BlackTileColorHex
	end

	return {
		TileColorHex = pianoRoll2DHex,
		WhiteTileColorHex = pianoRoll2DHex2,
		BlackTileColorHex = blackTileColorHex,
		ImpactColorHex = normalizePianoRoll2DHex(v51.ImpactColorHex, v29.ImpactColorHex), -- inferred equivalent call
		ImpactShape = normalizePianoRoll2DShape(v51.ImpactShape),
		BackgroundImage = normalizePianoRoll2DImage(v51.BackgroundImage),
		BackgroundTransparency = math.clamp(
			math.floor(tonumber(v51.BackgroundTransparency) or v29.BackgroundTransparency),
			0,
			100
		)
	}
end

local function getPianoRoll2DSettingsPayload() -- 3 equivalent calls inferred from this helper
	return normalizePianoRoll2DSettings(v30)
end

local function pushPianoRoll2DSettingsToRuntime()
	v30 = getPianoRoll2DSettingsPayload() -- inferred equivalent call
	localPlayer:SetAttribute("PianoRoll2DTileColorHex", v30.TileColorHex)
	localPlayer:SetAttribute("PianoRoll2DWhiteTileColorHex", v30.WhiteTileColorHex)
	localPlayer:SetAttribute("PianoRoll2DBlackTileColorHex", v30.BlackTileColorHex)
	localPlayer:SetAttribute("PianoRoll2DImpactColorHex", v30.ImpactColorHex)
	localPlayer:SetAttribute("PianoRoll2DImpactShape", v30.ImpactShape)
	localPlayer:SetAttribute("PianoRoll2DBackgroundImage", v30.BackgroundImage)
	localPlayer:SetAttribute("PianoRoll2DBackgroundTransparency", v30.BackgroundTransparency)

	if PianoRoll2DSettingsChanged then
		PianoRoll2DSettingsChanged:Fire(v30)
	end
end

local function stylePianoRoll2DSwatch(p, text)
	if not p then
		return
	end

	local backgroundColor = hexToColor3(text) or Color3.fromRGB(48, 54, 62)
	p.Text = text
	p.BackgroundColor3 = backgroundColor
	p.TextColor3 = backgroundColor.R * 0.299 + backgroundColor.G * 0.587 + backgroundColor.B * 0.114 > 0.62
		and Color3.fromRGB(20, 23, 28)
		or Color3.fromRGB(255, 255, 255)
end

local function updatePianoRoll2DSettingsVisuals()
	v30 = getPianoRoll2DSettingsPayload() -- inferred equivalent call
	stylePianoRoll2DSwatch(v31 or v32, v30.WhiteTileColorHex)
	stylePianoRoll2DSwatch(v36, v30.BlackTileColorHex)
	stylePianoRoll2DSwatch(v37, v30.ImpactColorHex)

	if v38 then
		v38.Text = v30.BackgroundImage
	end

	if v39 then
		v39.Text = v30.ImpactShape
	end

	if fn then
		fn()
	end

	if v40 then
		v40.Text = tostring(v30.BackgroundTransparency) .. "%"
	end

	local v51 = v30.BackgroundTransparency / 100

	if v41 then
		v41.Size = UDim2.new(v51, 0, 1, 0)
	end

	if v42 then
		v42.Position = UDim2.new(v51, 0, 0.5, 0)
	end
end

local count4 = 0
local function savePianoRoll2DSettings(p) -- 6 equivalent calls inferred from this helper
	if not savePianoUserSettings then
		return
	end

	count4 += 1
	local v51 = count4
	local function submit() -- 1 equivalent call inferred from this helper
		if v51 ~= count4 then
			return
		end

		savePianoUserSettings:FireServer({
			PianoRoll2D = getPianoRoll2DSettingsPayload() -- inferred equivalent call
		})
	end

	if not p then
		task.delay(0.25, submit)

		return
	end

	submit() -- inferred equivalent call
end

local function applyPianoRoll2DSettings(p, p2, p3) -- 2 equivalent calls inferred from this helper
	v30 = normalizePianoRoll2DSettings(p)
	pushPianoRoll2DSettingsToRuntime()
	updatePianoRoll2DSettingsVisuals()

	if p2 then
		savePianoRoll2DSettings(p3) -- inferred equivalent call
	end
end

if result2 then
	result2.Event:Connect(function(p, value)
		if p == "pianoRollTile" or p == "pianoRollWhiteTile" then
			local pianoRoll2DHex = normalizePianoRoll2DHex(value, v29.WhiteTileColorHex) -- inferred equivalent call
			v30.TileColorHex = pianoRoll2DHex
			v30.WhiteTileColorHex = pianoRoll2DHex
		elseif p == "pianoRollBlackTile" then
			v30.BlackTileColorHex = normalizePianoRoll2DHex(value, v29.BlackTileColorHex) -- inferred equivalent call
		else
			if p ~= "pianoRollImpact" then
				return
			end

			v30.ImpactColorHex = normalizePianoRoll2DHex(value, v29.ImpactColorHex) -- inferred equivalent call
		end

		v30 = normalizePianoRoll2DSettings(v30)
		pushPianoRoll2DSettingsToRuntime()
		updatePianoRoll2DSettingsVisuals()
		savePianoRoll2DSettings(false) -- inferred equivalent call
	end)
end

local function createPianoRoll2DColorRow(settingRow, _, p)
	local input = settingRow:FindFirstChild("Input")

	if input then
		input:Destroy()
	end

	local apply = settingRow:FindFirstChild("Apply")

	if apply then
		apply:Destroy()
	end

	local label = settingRow:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Size = UDim2.new(1, -210, 0, 22)
	end

	local description = settingRow:FindFirstChild("Description")

	if description and description:IsA("TextLabel") then
		description.Size = UDim2.new(1, -210, 0, 18)
	end

	local colorSwatch = settingRow:FindFirstChild("ColorSwatch") or Instance.new("TextButton")
	colorSwatch.Name = "ColorSwatch"
	colorSwatch.AnchorPoint = Vector2.new(1, 0.5)
	colorSwatch.Position = UDim2.new(1, -140, 0.5, 0)
	colorSwatch.Size = UDim2.new(0, 70, 0, 34)
	colorSwatch.BorderSizePixel = 0
	colorSwatch.AutoButtonColor = true
	colorSwatch.Font = Enum.Font.GothamBold
	colorSwatch.TextSize = 11
	colorSwatch.TextColor3 = Color3.fromRGB(255, 255, 255)
	colorSwatch.Parent = settingRow
	local uiCorner = colorSwatch:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = colorSwatch

	local actionButton = createActionButton(settingRow, "Edit")
	actionButton.Size = UDim2.new(0, 118, 0, 34)
	local function openColorWheel()
		safeClick() -- inferred equivalent call
		OpenPianoColorWheel:Fire(p)
	end
	colorSwatch.MouseButton1Click:Connect(openColorWheel)
	actionButton.MouseButton1Click:Connect(openColorWheel)
	return colorSwatch
end

local function createPianoRoll2DTextBox(settingRow, p, value)
	settingRow.Size = UDim2.new(1, -8, 0, 76)
	local label = settingRow:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Position = UDim2.new(0, 14, 0, 16)
		label.Size = UDim2.new(1, -250, 0, 22)
	end

	local description = settingRow:FindFirstChild("Description")

	if description and description:IsA("TextLabel") then
		description.Position = UDim2.new(0, 14, 0, 38)
		description.Size = UDim2.new(1, -250, 0, 18)
	end

	local input = settingRow:FindFirstChild("Input") or Instance.new("TextBox")
	input.Name = "Input"
	input.AnchorPoint = Vector2.new(1, 0.5)
	input.Position = UDim2.new(1, -92, 0.5, 0)
	input.Size = UDim2.new(0, 142, 0, 34)
	input.BackgroundColor3 = Color3.fromRGB(48, 54, 62)
	input.BorderSizePixel = 0
	input.ClearTextOnFocus = false
	input.Font = Enum.Font.GothamMedium
	input.PlaceholderText = value or ""
	input.TextColor3 = Color3.fromRGB(245, 247, 250)
	input.PlaceholderColor3 = Color3.fromRGB(130, 136, 150)
	input.TextSize = 12
	input.TextXAlignment = Enum.TextXAlignment.Center
	input.Parent = settingRow
	local uiCorner = input:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = input

	local apply = settingRow:FindFirstChild("Apply") or Instance.new("TextButton")
	apply.Name = "Apply"
	apply.AnchorPoint = Vector2.new(1, 0.5)
	apply.Position = UDim2.new(1, -12, 0.5, 0)
	apply.Size = UDim2.new(0, 72, 0, 34)
	apply.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
	apply.BorderSizePixel = 0
	apply.AutoButtonColor = true
	apply.Font = Enum.Font.GothamBold
	apply.Text = "Apply"
	apply.TextColor3 = Color3.fromRGB(255, 255, 255)
	apply.TextSize = 12
	apply.Parent = settingRow
	local uiCorner2 = apply:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 8)
	uiCorner2.Parent = apply

	local function applyInput() -- 2 equivalent calls inferred from this helper
		if p == "TileColorHex" or p == "ImpactColorHex" then
			v30[p] = normalizePianoRoll2DHex(input.Text, v29[p]) -- inferred equivalent call
		elseif p == "BackgroundImage" then
			v30.BackgroundImage = normalizePianoRoll2DImage(input.Text)
		end

		v30 = normalizePianoRoll2DSettings(v30)
		pushPianoRoll2DSettingsToRuntime()
		updatePianoRoll2DSettingsVisuals()
		savePianoRoll2DSettings(false) -- inferred equivalent call
	end
	apply.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		applyInput() -- inferred equivalent call
	end)
	input.FocusLost:Connect(function(p2)
		if p2 then
			applyInput() -- inferred equivalent call
		end
	end)
	return input
end

local function createPianoRoll2DTransparencySlider(settingRow)
	settingRow.Size = UDim2.new(1, -8, 0, 76)
	local label = settingRow:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Position = UDim2.new(0, 14, 0, 16)
		label.Size = UDim2.new(1, -92, 0, 22)
	end

	local description = settingRow:FindFirstChild("Description")

	if description and description:IsA("TextLabel") then
		description.Position = UDim2.new(0, 14, 0, 38)
		description.Size = UDim2.new(1, -28, 0, 18)
	end

	local parent2 = settingRow:FindFirstChild("Value") or Instance.new("TextLabel")
	parent2.Name = "Value"
	parent2.AnchorPoint = Vector2.new(1, 0.5)
	parent2.Position = UDim2.new(1, -12, 0, 16)
	parent2.Size = UDim2.new(0, 58, 0, 24)
	parent2.BackgroundColor3 = Color3.fromRGB(48, 54, 62)
	parent2.BorderSizePixel = 0
	parent2.Font = Enum.Font.GothamBold
	parent2.TextColor3 = Color3.fromRGB(245, 247, 250)
	parent2.TextSize = 13
	parent2.Parent = settingRow
	local uiCorner = parent2:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 4)
	uiCorner.Parent = parent2
	v40 = parent2

	local sliderTrack = settingRow:FindFirstChild("SliderTrack") or Instance.new("TextButton")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
	sliderTrack.Position = UDim2.new(0, 14, 1, -15)
	sliderTrack.Size = UDim2.new(1, -28, 0, 8)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(24, 27, 31)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.AutoButtonColor = false
	sliderTrack.ClipsDescendants = false
	sliderTrack.Text = ""
	sliderTrack.ZIndex = math.max(settingRow.ZIndex + 1, 2)
	sliderTrack.Parent = settingRow
	local uiCorner2 = sliderTrack:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 4)
	uiCorner2.Parent = sliderTrack

	local fill = sliderTrack:FindFirstChild("Fill") or Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(100, 190, 255)
	fill.BorderSizePixel = 0
	fill.Position = UDim2.fromScale(0, 0)
	fill.Size = UDim2.fromScale(0, 1)
	fill.ZIndex = sliderTrack.ZIndex + 1
	fill.Parent = sliderTrack
	local uiCorner3 = fill:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 4)
	uiCorner3.Parent = fill
	v41 = fill

	local knob = sliderTrack:FindFirstChild("Knob") or Instance.new("TextButton")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.BackgroundColor3 = Color3.fromRGB(235, 238, 242)
	knob.BorderSizePixel = 0
	knob.AutoButtonColor = true
	knob.Text = ""
	knob.ZIndex = sliderTrack.ZIndex + 2
	knob.Parent = sliderTrack
	local uiCorner4 = knob:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner4.CornerRadius = UDim.new(0, 9)
	uiCorner4.Parent = knob
	v42 = knob

	local function setTransparencyFromX(x) -- 2 equivalent calls inferred from this helper
		local v51 = math.clamp((x - sliderTrack.AbsolutePosition.X) / math.max(sliderTrack.AbsoluteSize.X, 1), 0, 1)
		v30.BackgroundTransparency = math.floor(v51 * 100 + 0.5)
		v30 = normalizePianoRoll2DSettings(v30)
		pushPianoRoll2DSettingsToRuntime()
		updatePianoRoll2DSettingsVisuals()
		savePianoRoll2DSettings(false) -- inferred equivalent call
	end
	local function beginInput(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			v43 = true
			setTransparencyFromX(p.Position.X) -- inferred equivalent call
		end
	end
	sliderTrack.InputBegan:Connect(beginInput)
	knob.InputBegan:Connect(beginInput)
	UserInputService.InputChanged:Connect(function(input)
		if
			v43
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			setTransparencyFromX(input.Position.X) -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v43 = false
		end
	end)
end

local function createPianoRoll2DShapeRow(settingRow)
	local shapeDropdown = settingRow:FindFirstChild("ShapeDropdown")

	if shapeDropdown then
		shapeDropdown:Destroy()
	end

	local pianoRoll2DShapePanel2 = parent:FindFirstChild("PianoRoll2DShapePanel")

	if pianoRoll2DShapePanel2 and pianoRoll2DShapePanel2 ~= settings:FindFirstChild("PianoRoll2DShapePanel") then
		pianoRoll2DShapePanel2:Destroy()
	end

	v39 = createActionButton(settingRow, v30.ImpactShape)
	v39.Text = v30.ImpactShape

	pianoRoll2DShapePanel = settings:WaitForChild("PianoRoll2DShapePanel")
	pianoRoll2DShapePanel.Visible = false
	pianoRoll2DShapePanel.Active = true
	pianoRoll2DShapePanel.ZIndex = math.max(settings.ZIndex + 80, pianoRoll2DShapePanel.ZIndex)

	local close = pianoRoll2DShapePanel:WaitForChild("Close")
	local dragHandle = pianoRoll2DShapePanel:FindFirstChild("DragHandle") or pianoRoll2DShapePanel
	local options = pianoRoll2DShapePanel:WaitForChild("Options")
	local uiGridLayout = options:FindFirstChildOfClass("UIGridLayout")

	if options:IsA("ScrollingFrame") then
		options.Active = true
		options.ScrollingEnabled = true
		options.ScrollingDirection = Enum.ScrollingDirection.Y
		options.ScrollBarThickness = math.max(options.ScrollBarThickness, 6)
		options.AutomaticCanvasSize = Enum.AutomaticSize.None
	end

	local function refreshScrollCanvas()
		if options:IsA("ScrollingFrame") and uiGridLayout then
			local count5 = 0

			for _, button in ipairs(options:GetChildren()) do
				if button:IsA("TextButton") then
					count5 += 1
				end
			end

			local v51 = count5 * 38 + math.max(count5 - 1, 0) * 8
			local v52 = math.max(uiGridLayout.AbsoluteContentSize.Y, v51)
			options.CanvasSize = UDim2.new(0, 0, 0, v52 + 8)
		end
	end

	if uiGridLayout then
		uiGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshScrollCanvas)
		task.defer(refreshScrollCanvas)
	end

	local v51 = false
	local vector2 = nil
	local absolutePosition = nil
	local function moveShapePanel(input)
		if not (v51 and vector2 and absolutePosition) then
			return
		end

		local parent2 = pianoRoll2DShapePanel.Parent

		if not (parent2 and parent2:IsA("GuiObject")) then
			return
		end

		local absoluteSize = pianoRoll2DShapePanel.AbsoluteSize
		local absolutePosition2 = parent2.AbsolutePosition
		local absoluteSize2 = parent2.AbsoluteSize
		local vector2_2 = Vector2.new(input.Position.X - vector2.X, input.Position.Y - vector2.Y)
		local v52 = absolutePosition + vector2_2
		local vector2_3 = Vector2.new(
			math.clamp(v52.X, absolutePosition2.X, absolutePosition2.X + math.max(absoluteSize2.X - absoluteSize.X, 0)),
			(math.clamp(v52.Y, absolutePosition2.Y, absolutePosition2.Y + math.max(absoluteSize2.Y - absoluteSize.Y, 0)))
		)

		local vector2_4 = Vector2.new(
			absoluteSize.X * pianoRoll2DShapePanel.AnchorPoint.X,
			absoluteSize.Y * pianoRoll2DShapePanel.AnchorPoint.Y
		)
		local v53 = vector2_3 - absolutePosition2 + vector2_4
		pianoRoll2DShapePanel.Position = UDim2.fromOffset(v53.X, v53.Y)
	end
	dragHandle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v51 = true
			vector2 = Vector2.new(input.Position.X, input.Position.Y)
			absolutePosition = pianoRoll2DShapePanel.AbsolutePosition
			input.Changed:Connect(function()
				if
					input.UserInputState == Enum.UserInputState.End
					or input.UserInputState == Enum.UserInputState.Cancel
				then
					v51 = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if
			v51
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			moveShapePanel(input)
		end
	end)

	fn = function()
		if not pianoRoll2DShapePanel then
			return
		end

		if v39 then
			v39.Text = v30.ImpactShape
		end

		for i, childName in ipairs(v28) do
			local button = options:FindFirstChild(childName)

			if not (button and button:IsA("TextButton")) then
				continue
			end

			button.LayoutOrder = i
			button.BackgroundColor3 = childName == v30.ImpactShape and color or Color3.fromRGB(34, 39, 44)
			button.Text = childName
			button.ZIndex = pianoRoll2DShapePanel.ZIndex + 2

			if button:GetAttribute("PianoRoll2DShapeConnected") then
				continue
			end

			button:SetAttribute("PianoRoll2DShapeConnected", true)
			button.MouseButton1Click:Connect(function()
				safeClick() -- inferred equivalent call
				v30.ImpactShape = childName
				pianoRoll2DShapePanel.Visible = false
				v30 = normalizePianoRoll2DSettings(v30)
				pushPianoRoll2DSettingsToRuntime()
				updatePianoRoll2DSettingsVisuals()
				savePianoRoll2DSettings(false) -- inferred equivalent call
			end)
		end

		refreshScrollCanvas()
	end

	v39.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		pianoRoll2DShapePanel.Visible = not pianoRoll2DShapePanel.Visible

		if pianoRoll2DShapePanel.Visible then
			pianoRoll2DShapePanel.Parent = settings

			if options:IsA("ScrollingFrame") then
				options.CanvasPosition = Vector2.new(0, 0)
			end

			fn()
		end
	end)
	close.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		pianoRoll2DShapePanel.Visible = false
	end)
	settings:GetPropertyChangedSignal("Visible"):Connect(function()
		if not settings.Visible and pianoRoll2DShapePanel then
			pianoRoll2DShapePanel.Visible = false
		end
	end)
	fn()
end

local function isValidActionKeyName(value)
	if typeof(value) ~= "string" or value == "" or nameSet[value] then
		return false
	end

	local success3, result3 = pcall(function()
		return Enum.KeyCode[value]
	end)

	if success3 then
		if typeof(result3) == "EnumItem" then
			success3 = result3 ~= Enum.KeyCode.Unknown
		else
			success3 = false
		end
	end

	return success3
end

local function copyActionKeybinds(actionKeyBinds)
	local result3 = {}

	if typeof(actionKeyBinds) ~= "table" then
		return result3
	end

	for _, v51 in ipairs(v44) do
		local v52 = actionKeyBinds[v51.id]

		if isValidActionKeyName(v52) then
			result3[v51.id] = v52
		end
	end

	for _, v51 in ipairs(v45) do
		local v52 = actionKeyBinds[v51.id]

		if isValidActionKeyName(v52) then
			result3[v51.id] = v52
		end
	end

	return result3
end

local function displayActionKeyName(value) -- 2 equivalent calls inferred from this helper
	return v50[value] or value or "n/a"
end

local function getActionKeyName(p)
	return actionKeyBinds2[p] or v47[p] or "n/a"
end

local function saveActionKeybinds() -- 6 equivalent calls inferred from this helper
	if savePianoUserSettings then
		savePianoUserSettings:FireServer({ ActionKeyBinds = actionKeyBinds2 })
	end
end

local function disconnectActionCapture() -- 4 equivalent calls inferred from this helper
	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end
end

local function beginActionKeyCapture(id) -- 2 equivalent calls inferred from this helper
	disconnectActionCapture() -- inferred equivalent call
	v48 = id

	if fn2 then
		fn2()
	end

	inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		if not (input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown) then
			return
		end

		if input.KeyCode == Enum.KeyCode.Escape then
			v48 = nil
			disconnectActionCapture() -- inferred equivalent call
		elseif nameSet[input.KeyCode.Name] then
			v.Warn("[Settings] That key is reserved for piano notes. Choose a non-note keybind.")
			v48 = nil
			disconnectActionCapture() -- inferred equivalent call
		else
			actionKeyBinds2[id] = input.KeyCode.Name
			v48 = nil
			disconnectActionCapture() -- inferred equivalent call
			saveActionKeybinds() -- inferred equivalent call
		end

		if fn2 then
			fn2()
		end
	end)
end

local function createActionKeybindRow(data)
	local actionKeybindRow = list5:FindFirstChild(data.id .. "Row") or Instance.new("Frame")
	actionKeybindRow.Name = data.id .. "Row"
	actionKeybindRow.Parent = list5
	actionKeybindRow.LayoutOrder = data.order
	actionKeybindRow.Size = UDim2.new(1, -8, 0, 58)
	actionKeybindRow.BackgroundColor3 = Color3.fromRGB(36, 41, 46)
	actionKeybindRow.BorderSizePixel = 0

	local uiCorner = actionKeybindRow:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = actionKeybindRow

	local label = actionKeybindRow:FindFirstChild("Label") or Instance.new("TextLabel")
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 14, 0.5, -8)
	label.Size = UDim2.new(1, -250, 0, 22)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = data.label
	label.TextColor3 = Color3.fromRGB(240, 242, 246)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = actionKeybindRow

	local description = actionKeybindRow:FindFirstChild("Description") or Instance.new("TextLabel")
	description.Name = "Description"
	description.AnchorPoint = Vector2.new(0, 0.5)
	description.Position = UDim2.new(0, 14, 0.5, 13)
	description.Size = UDim2.new(1, -250, 0, 18)
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.Gotham
	description.Text = data.description or ""
	description.TextColor3 = Color3.fromRGB(160, 166, 180)
	description.TextSize = 12
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextTruncate = Enum.TextTruncate.AtEnd
	description.Parent = actionKeybindRow

	local keyButton = actionKeybindRow:FindFirstChild("KeyButton") or Instance.new("TextButton")
	keyButton.Name = "KeyButton"
	keyButton.AnchorPoint = Vector2.new(1, 0.5)
	keyButton.Position = UDim2.new(1, -88, 0.5, 0)
	keyButton.Size = UDim2.new(0, 110, 0, 34)
	keyButton.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
	keyButton.BorderSizePixel = 0
	keyButton.AutoButtonColor = true
	keyButton.Font = Enum.Font.GothamBold
	keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyButton.TextSize = 13
	keyButton.Parent = actionKeybindRow
	local uiCorner2 = keyButton:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 8)
	uiCorner2.Parent = keyButton
	keyButton.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		beginActionKeyCapture(data.id) -- inferred equivalent call
	end)

	local reset6 = actionKeybindRow:FindFirstChild("Reset") or Instance.new("TextButton")
	reset6.Name = "Reset"
	reset6.AnchorPoint = Vector2.new(1, 0.5)
	reset6.Position = UDim2.new(1, -12, 0.5, 0)
	reset6.Size = UDim2.new(0, 66, 0, 34)
	reset6.BackgroundColor3 = Color3.fromRGB(56, 62, 70)
	reset6.BorderSizePixel = 0
	reset6.AutoButtonColor = true
	reset6.Font = Enum.Font.GothamBold
	reset6.Text = "Reset"
	reset6.TextColor3 = Color3.fromRGB(235, 238, 242)
	reset6.TextSize = 12
	reset6.Parent = actionKeybindRow
	local uiCorner3 = reset6:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 8)
	uiCorner3.Parent = reset6
	reset6.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		actionKeyBinds2[data.id] = nil
		saveActionKeybinds() -- inferred equivalent call

		if fn2 then
			fn2()
		end
	end)

	keyButtonsById[data.id] = keyButton
	return actionKeybindRow
end

local function openAutoPlayerKeybindPopup()
	if v49 then
		v49.Visible = true
	end
end

local function createAutoPlayerKeybindPopup()
	local autoPlayerKeybindOverlay = center:FindFirstChild("AutoPlayerKeybindOverlay") or Instance.new("Frame")
	autoPlayerKeybindOverlay.Name = "AutoPlayerKeybindOverlay"
	autoPlayerKeybindOverlay.AnchorPoint = Vector2.new(0, 0)
	autoPlayerKeybindOverlay.Position = UDim2.fromScale(0, 0)
	autoPlayerKeybindOverlay.Size = UDim2.fromScale(1, 1)
	autoPlayerKeybindOverlay.BackgroundColor3 = Color3.fromRGB(20, 24, 28)
	autoPlayerKeybindOverlay.BackgroundTransparency = 0.2
	autoPlayerKeybindOverlay.BorderSizePixel = 0
	autoPlayerKeybindOverlay.Active = true
	autoPlayerKeybindOverlay.Visible = false
	autoPlayerKeybindOverlay.ZIndex = 1000
	autoPlayerKeybindOverlay.Parent = center
	v49 = autoPlayerKeybindOverlay

	local panel = autoPlayerKeybindOverlay:FindFirstChild("Panel") or Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.Size = UDim2.new(0, 360, 0, 280)
	panel.BackgroundColor3 = Color3.fromRGB(34, 39, 44)
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Visible = true
	panel.ZIndex = 1001
	panel.Parent = autoPlayerKeybindOverlay

	local uiCorner = panel:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = panel

	local uiStroke = panel:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(58, 68, 78)
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.05
	uiStroke.Parent = panel

	local title = panel:FindFirstChild("Title") or Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 18, 0, 12)
	title.Size = UDim2.new(1, -64, 0, 28)
	title.Font = Enum.Font.GothamBold
	title.Text = "Auto Player Keys"
	title.TextColor3 = Color3.fromRGB(245, 247, 250)
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 1002
	title.Parent = panel

	local close = panel:FindFirstChild("Close")

	if close and not close:IsA("ImageButton") then
		close:Destroy()
		close = nil
	end

	local close2 = close or Instance.new("ImageButton")
	close2.Name = "Close"
	close2.AnchorPoint = Vector2.new(1, 0)
	close2.Position = UDim2.new(1, -12, 0, 12)
	close2.Size = UDim2.new(0, 32, 0, 28)
	close2.BackgroundTransparency = 1
	close2.BorderSizePixel = 0
	close2.AutoButtonColor = true
	close2.Image = "rbxassetid://6031094678"
	close2.ImageColor3 = Color3.fromRGB(235, 238, 242)
	close2.ImageTransparency = 0
	close2.ScaleType = Enum.ScaleType.Fit
	close2.ZIndex = 1002
	close2.Parent = panel
	close2.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		autoPlayerKeybindOverlay.Visible = false
	end)

	for _, v51 in ipairs(v45) do
		local parent2 = panel:FindFirstChild(v51.id .. "PopupRow") or Instance.new("Frame")
		parent2.Name = v51.id .. "PopupRow"
		parent2.Position = UDim2.new(0, 18, 0, 48 + (v51.order - 1) * 52)
		parent2.Size = UDim2.new(1, -36, 0, 44)
		parent2.BackgroundColor3 = Color3.fromRGB(36, 41, 46)
		parent2.BorderSizePixel = 0
		parent2.ZIndex = 61
		parent2.Parent = panel
		local uiCorner2 = parent2:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(0, 8)
		uiCorner2.Parent = parent2

		local label = parent2:FindFirstChild("Label") or Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0, 12, 0, 0)
		label.Size = UDim2.new(1, -190, 1, 0)
		label.Font = Enum.Font.GothamBold
		label.Text = v51.label
		label.TextColor3 = Color3.fromRGB(240, 242, 246)
		label.TextSize = 13
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 62
		label.Parent = parent2

		local keyButton = parent2:FindFirstChild("KeyButton") or Instance.new("TextButton")
		keyButton.Name = "KeyButton"
		keyButton.AnchorPoint = Vector2.new(1, 0.5)
		keyButton.Position = UDim2.new(1, -76, 0.5, 0)
		keyButton.Size = UDim2.new(0, 96, 0, 30)
		keyButton.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
		keyButton.BorderSizePixel = 0
		keyButton.AutoButtonColor = true
		keyButton.Font = Enum.Font.GothamBold
		keyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		keyButton.TextSize = 12
		keyButton.ZIndex = 62
		keyButton.Parent = parent2
		local uiCorner3 = keyButton:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		uiCorner3.CornerRadius = UDim.new(0, 8)
		uiCorner3.Parent = keyButton
		keyButton.MouseButton1Click:Connect(function()
			safeClick() -- inferred equivalent call
			beginActionKeyCapture(v51.id) -- inferred equivalent call
		end)

		local reset6 = parent2:FindFirstChild("Reset") or Instance.new("TextButton")
		reset6.Name = "Reset"
		reset6.AnchorPoint = Vector2.new(1, 0.5)
		reset6.Position = UDim2.new(1, -10, 0.5, 0)
		reset6.Size = UDim2.new(0, 56, 0, 30)
		reset6.BackgroundColor3 = Color3.fromRGB(56, 62, 70)
		reset6.BorderSizePixel = 0
		reset6.AutoButtonColor = true
		reset6.Font = Enum.Font.GothamBold
		reset6.Text = "Reset"
		reset6.TextColor3 = Color3.fromRGB(235, 238, 242)
		reset6.TextSize = 11
		reset6.ZIndex = 62
		reset6.Parent = parent2
		local uiCorner4 = reset6:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
		uiCorner4.CornerRadius = UDim.new(0, 8)
		uiCorner4.Parent = reset6
		reset6.MouseButton1Click:Connect(function()
			safeClick() -- inferred equivalent call
			actionKeyBinds2[v51.id] = nil
			saveActionKeybinds() -- inferred equivalent call

			if fn2 then
				fn2()
			end
		end)

		keyButtonsById[v51.id] = keyButton
		keyButtonsById2[v51.id] = keyButton
	end
end

local function createAutoPlayerKeybindRow()
	local autoPlayerGroupRow = list5:FindFirstChild("AutoPlayerGroupRow") or Instance.new("Frame")
	autoPlayerGroupRow.Name = "AutoPlayerGroupRow"
	autoPlayerGroupRow.Parent = list5
	autoPlayerGroupRow.LayoutOrder = 10
	autoPlayerGroupRow.Size = UDim2.new(1, -8, 0, 58)
	autoPlayerGroupRow.BackgroundColor3 = Color3.fromRGB(36, 41, 46)
	autoPlayerGroupRow.BorderSizePixel = 0
	local uiCorner = autoPlayerGroupRow:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = autoPlayerGroupRow

	local label = autoPlayerGroupRow:FindFirstChild("Label") or Instance.new("TextLabel")
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 14, 0.5, -8)
	label.Size = UDim2.new(1, -250, 0, 22)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = "Auto Player Keys"
	label.TextColor3 = Color3.fromRGB(240, 242, 246)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = autoPlayerGroupRow

	local description = autoPlayerGroupRow:FindFirstChild("Description") or Instance.new("TextLabel")
	description.Name = "Description"
	description.AnchorPoint = Vector2.new(0, 0.5)
	description.Position = UDim2.new(0, 14, 0.5, 13)
	description.Size = UDim2.new(1, -250, 0, 18)
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.Gotham
	description.Text = "Manual autoplay trigger keys"
	description.TextColor3 = Color3.fromRGB(160, 166, 180)
	description.TextSize = 12
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextTruncate = Enum.TextTruncate.AtEnd
	description.Parent = autoPlayerGroupRow

	local edit = autoPlayerGroupRow:FindFirstChild("Edit") or Instance.new("TextButton")
	edit.Name = "Edit"
	edit.AnchorPoint = Vector2.new(1, 0.5)
	edit.Position = UDim2.new(1, -88, 0.5, 0)
	edit.Size = UDim2.new(0, 110, 0, 34)
	edit.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
	edit.BorderSizePixel = 0
	edit.AutoButtonColor = true
	edit.Font = Enum.Font.GothamBold
	edit.Text = "Edit"
	edit.TextColor3 = Color3.fromRGB(255, 255, 255)
	edit.TextSize = 13
	edit.Parent = autoPlayerGroupRow
	local uiCorner2 = edit:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 8)
	uiCorner2.Parent = edit
	edit.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call

		if v49 then
			v49.Visible = true
		end
	end)

	local reset6 = autoPlayerGroupRow:FindFirstChild("Reset") or Instance.new("TextButton")
	reset6.Name = "Reset"
	reset6.AnchorPoint = Vector2.new(1, 0.5)
	reset6.Position = UDim2.new(1, -12, 0.5, 0)
	reset6.Size = UDim2.new(0, 66, 0, 34)
	reset6.BackgroundColor3 = Color3.fromRGB(56, 62, 70)
	reset6.BorderSizePixel = 0
	reset6.AutoButtonColor = true
	reset6.Font = Enum.Font.GothamBold
	reset6.Text = "Reset"
	reset6.TextColor3 = Color3.fromRGB(235, 238, 242)
	reset6.TextSize = 12
	reset6.Parent = autoPlayerGroupRow
	local uiCorner3 = reset6:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 8)
	uiCorner3.Parent = reset6
	reset6.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call

		for _, v51 in ipairs(v45) do
			actionKeyBinds2[v51.id] = nil
		end

		saveActionKeybinds() -- inferred equivalent call

		if fn2 then
			fn2()
		end
	end)
end

fn2 = function()
	for _, v51 in ipairs(v44) do
		local v52 = keyButtonsById[v51.id]

		if not v52 then
			continue
		end

		if v48 == v51.id then
			v52.Text = "Press key..."
			v52.BackgroundColor3 = Color3.fromRGB(255, 190, 50)
			v52.TextColor3 = Color3.fromRGB(25, 25, 25)
		else
			local id = v51.id
			v52.Text = displayActionKeyName(actionKeyBinds2[id] or v47[id] or "n/a") -- inferred equivalent call
			v52.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
			v52.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	for _, v51 in ipairs(v45) do
		local v52 = keyButtonsById[v51.id]

		if not v52 then
			continue
		end

		if v48 == v51.id then
			v52.Text = "Press key..."
			v52.BackgroundColor3 = Color3.fromRGB(255, 190, 50)
			v52.TextColor3 = Color3.fromRGB(25, 25, 25)
		else
			local id = v51.id
			v52.Text = displayActionKeyName(actionKeyBinds2[id] or v47[id] or "n/a") -- inferred equivalent call
			v52.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
			v52.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end

local function initializeActionKeybindSettings()
	local v51 = list5:FindFirstChildOfClass("UIListLayout")

	if not v51 then
		v51 = Instance.new("UIListLayout")
		v51.Parent = list5
	end

	v51.SortOrder = Enum.SortOrder.LayoutOrder
	v51.Padding = UDim.new(0, 8)
	list5.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list5.CanvasSize = UDim2.new(0, 0, 0, 0)
	list5.ScrollBarThickness = 0
	local uiPadding = list5:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 10)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = list5

	for _, frame in ipairs(list5:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	keyButtonsById = {}
	keyButtonsById2 = {}

	for _, v52 in ipairs(v44) do
		createActionKeybindRow(v52)
	end

	createAutoPlayerKeybindRow()
	createAutoPlayerKeybindPopup()
	fn2()
end

local function createVolumeSlider(settingRow)
	settingRow.Size = UDim2.new(1, -8, 0, 76)
	local label = settingRow:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Position = UDim2.new(0, 14, 0, 16)
		label.Size = UDim2.new(1, -92, 0, 22)
	end

	local description = settingRow:FindFirstChild("Description")

	if description and description:IsA("TextLabel") then
		description.Position = UDim2.new(0, 14, 0, 38)
		description.Size = UDim2.new(1, -28, 0, 18)
	end

	local parent2 = settingRow:FindFirstChild("Value") or Instance.new("TextLabel")
	parent2.Name = "Value"
	parent2.AnchorPoint = Vector2.new(1, 0.5)
	parent2.Position = UDim2.new(1, -12, 0, 16)
	parent2.Size = UDim2.new(0, 58, 0, 24)
	parent2.BackgroundColor3 = Color3.fromRGB(48, 54, 62)
	parent2.BorderSizePixel = 0
	parent2.Font = Enum.Font.GothamBold
	parent2.TextColor3 = Color3.fromRGB(245, 247, 250)
	parent2.TextSize = 13
	parent2.Parent = settingRow
	local uiCorner = parent2:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 4)
	uiCorner.Parent = parent2
	v18 = parent2

	local sliderTrack = settingRow:FindFirstChild("SliderTrack") or Instance.new("TextButton")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
	sliderTrack.Position = UDim2.new(0, 14, 1, -15)
	sliderTrack.Size = UDim2.new(1, -28, 0, 8)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(24, 27, 31)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.AutoButtonColor = false
	sliderTrack.ClipsDescendants = false
	sliderTrack.Text = ""
	sliderTrack.ZIndex = math.max(settingRow.ZIndex + 1, 2)
	sliderTrack.Parent = settingRow
	local uiCorner2 = sliderTrack:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 4)
	uiCorner2.Parent = sliderTrack

	local fill = sliderTrack:FindFirstChild("Fill") or Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
	fill.BorderSizePixel = 0
	fill.Position = UDim2.fromScale(0, 0)
	fill.Size = UDim2.fromScale(1, 1)
	fill.ZIndex = sliderTrack.ZIndex + 1
	fill.Parent = sliderTrack
	local uiCorner3 = fill:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 4)
	uiCorner3.Parent = fill
	v19 = fill

	local knob = sliderTrack:FindFirstChild("Knob") or Instance.new("TextButton")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(1, 0, 0.5, 0)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.BackgroundColor3 = Color3.fromRGB(235, 238, 242)
	knob.BorderSizePixel = 0
	knob.AutoButtonColor = true
	knob.Text = ""
	knob.ZIndex = sliderTrack.ZIndex + 2
	knob.Parent = sliderTrack
	local uiCorner4 = knob:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner4.CornerRadius = UDim.new(0, 9)
	uiCorner4.Parent = knob
	v20 = knob

	local function setVolumeFromX(x) -- 2 equivalent calls inferred from this helper
		local x2 = sliderTrack.AbsolutePosition.X
		local v51 = math.max(sliderTrack.AbsoluteSize.X, 1)
		otherPianoVolume2 = math.floor(math.clamp((x - x2) / v51, 0, 1) * 100 + 0.5)
		updateOtherPianoVolumeVisuals()
		saveOtherPianoVolume() -- inferred equivalent call
	end

	local function beginInput(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			v21 = true
			setVolumeFromX(p.Position.X) -- inferred equivalent call
		end
	end

	sliderTrack.InputBegan:Connect(beginInput)
	knob.InputBegan:Connect(beginInput)
	UserInputService.InputChanged:Connect(function(input)
		if
			v21
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
			v21 = false
		end
	end)

	updateOtherPianoVolumeVisuals()
end

local function createMaxPianoSoundsSlider(settingRow)
	settingRow.Size = UDim2.new(1, -8, 0, 76)
	local label = settingRow:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.Position = UDim2.new(0, 14, 0, 16)
		label.Size = UDim2.new(1, -92, 0, 22)
	end

	local description = settingRow:FindFirstChild("Description")

	if description and description:IsA("TextLabel") then
		description.Position = UDim2.new(0, 14, 0, 38)
		description.Size = UDim2.new(1, -28, 0, 18)
	end

	local parent2 = settingRow:FindFirstChild("Value") or Instance.new("TextLabel")
	parent2.Name = "Value"
	parent2.AnchorPoint = Vector2.new(1, 0.5)
	parent2.Position = UDim2.new(1, -12, 0, 16)
	parent2.Size = UDim2.new(0, 58, 0, 24)
	parent2.BackgroundColor3 = Color3.fromRGB(48, 54, 62)
	parent2.BorderSizePixel = 0
	parent2.Font = Enum.Font.GothamBold
	parent2.TextColor3 = Color3.fromRGB(245, 247, 250)
	parent2.TextSize = 13
	parent2.Parent = settingRow
	local uiCorner = parent2:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 4)
	uiCorner.Parent = parent2
	v24 = parent2

	local sliderTrack = settingRow:FindFirstChild("SliderTrack") or Instance.new("TextButton")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.AnchorPoint = Vector2.new(0, 0.5)
	sliderTrack.Position = UDim2.new(0, 14, 1, -15)
	sliderTrack.Size = UDim2.new(1, -28, 0, 8)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(24, 27, 31)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.AutoButtonColor = false
	sliderTrack.ClipsDescendants = false
	sliderTrack.Text = ""
	sliderTrack.ZIndex = math.max(settingRow.ZIndex + 1, 2)
	sliderTrack.Parent = settingRow
	local uiCorner2 = sliderTrack:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 4)
	uiCorner2.Parent = sliderTrack

	local fill = sliderTrack:FindFirstChild("Fill") or Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(45, 118, 235)
	fill.BorderSizePixel = 0
	fill.Position = UDim2.fromScale(0, 0)
	fill.Size = UDim2.fromScale(1, 1)
	fill.ZIndex = sliderTrack.ZIndex + 1
	fill.Parent = sliderTrack
	local uiCorner3 = fill:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner3.CornerRadius = UDim.new(0, 4)
	uiCorner3.Parent = fill
	v25 = fill

	local knob = sliderTrack:FindFirstChild("Knob") or Instance.new("TextButton")
	knob.Name = "Knob"
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(1, 0, 0.5, 0)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.BackgroundColor3 = Color3.fromRGB(235, 238, 242)
	knob.BorderSizePixel = 0
	knob.AutoButtonColor = true
	knob.Text = ""
	knob.ZIndex = sliderTrack.ZIndex + 2
	knob.Parent = sliderTrack
	local uiCorner4 = knob:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner4.CornerRadius = UDim.new(0, 9)
	uiCorner4.Parent = knob
	v26 = knob

	local function setMaxSoundsFromX(x) -- 2 equivalent calls inferred from this helper
		local x2 = sliderTrack.AbsolutePosition.X
		local v51 = math.max(sliderTrack.AbsoluteSize.X, 1)
		local v52 = math.clamp((x - x2) / v51, 0, 1)
		maxPianoSounds = math.floor(maxPianoSoundsBounds + v52 * (v22 - maxPianoSoundsBounds) + 0.5)
		updateMaxPianoSoundsVisuals()
		saveMaxPianoSounds() -- inferred equivalent call
	end

	local function beginInput(p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			v27 = true
			setMaxSoundsFromX(p.Position.X) -- inferred equivalent call
		end
	end

	sliderTrack.InputBegan:Connect(beginInput)
	knob.InputBegan:Connect(beginInput)
	UserInputService.InputChanged:Connect(function(input)
		if
			v27
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
		then
			setMaxSoundsFromX(input.Position.X) -- inferred equivalent call
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v27 = false
		end
	end)

	updateMaxPianoSoundsVisuals()
end

local function applyPianoUserSettings(result3)
	if typeof(result3) ~= "table" then
		return
	end

	if result3.OtherPianoVolume == nil then
		if typeof(result3.MuteOtherPianos) == "boolean" then
			otherPianoVolume2 = result3.MuteOtherPianos and 0 or 100
		end
	else
		otherPianoVolume2 = math.clamp(math.floor(tonumber(result3.OtherPianoVolume) or 100), 0, 100)
	end

	if result3.MaxPianoSounds ~= nil then
		maxPianoSounds = math.clamp(math.floor(tonumber(result3.MaxPianoSounds) or v23), maxPianoSoundsBounds, v22)
	end

	if typeof(result3.HideAutoplayingTag) == "boolean" then
		v10 = result3.HideAutoplayingTag
	end

	if typeof(result3.ShowCountryFlag) == "boolean" then
		v11 = result3.ShowCountryFlag
	end

	if typeof(result3.HideOtherPlayers) == "boolean" then
		v12 = result3.HideOtherPlayers
	end

	if typeof(result3.OtherPlayerTileEffectsEnabled) == "boolean" then
		v13 = result3.OtherPlayerTileEffectsEnabled
	end

	if typeof(result3.MapAtmosphereEnabled) == "boolean" then
		mapAtmosphereEnabled = result3.MapAtmosphereEnabled
		localPlayer:SetAttribute("MapAtmosphereEnabled", mapAtmosphereEnabled)
	end

	v2.TeamSettings:ApplyUserSettings(result3, v3 == "Teams")
	v2.LightingSettings:ApplyUserSettings(result3, v3 == "Lighting")
	pushPrivacySettingsToRuntime()
	refreshPrivacyToggles()
	refreshMapAtmosphereToggle()

	if typeof(result3.PianoRoll2D) == "table" then
		applyPianoRoll2DSettings(result3.PianoRoll2D, false) -- inferred equivalent call
	end

	if typeof(result3.ActionKeyBinds) == "table" then
		actionKeyBinds2 = copyActionKeybinds(result3.ActionKeyBinds)

		if fn2 then
			fn2()
		end
	end

	updateOtherPianoVolumeVisuals()
	updateMaxPianoSoundsVisuals()
	refreshPrivacyToggles()
end

local function initializePianoVisualSettings()
	local v51 = list:FindFirstChildOfClass("UIListLayout")

	if not v51 then
		v51 = Instance.new("UIListLayout")
		v51.Parent = list
	end

	v51.SortOrder = Enum.SortOrder.LayoutOrder
	v51.Padding = UDim.new(0, 8)

	for _, childName in ipairs({
		"WhiteSynthesiaColorRow",
		"BlackSynthesiaColorRow",
		"WhiteKeyHighlightRow",
		"BlackKeyHighlightRow",
		"KeyHighlightColorRow",
		"OtherPlayer'sPianoVolumeRow",
		"Fog/HazeRow"
	}) do
		local child = list:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end

	v7 = createActionButton(createSettingRow("Synthesia Effect", "Default-effect pianos only", 1), "ON")
	v7.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		v6.DefaultSynthesiaEnabled = v6.DefaultSynthesiaEnabled == false
		localPlayer:SetAttribute("DefaultSynthesiaEnabled", v6.DefaultSynthesiaEnabled)

		if not v6.DefaultSynthesiaEnabled then
			PianoVisualization.FadeAllVisualizations()
		end

		saveVisualizerSetting({ DefaultSynthesiaEnabled = v6.DefaultSynthesiaEnabled }) -- inferred equivalent call

		if not v7 then
			return
		end

		local defaultSynthesiaEnabled = v6.DefaultSynthesiaEnabled ~= false
		v7.Text = defaultSynthesiaEnabled and "ON" or "OFF"
		v7.BackgroundColor3 = defaultSynthesiaEnabled and color or color2
	end)

	v6.HeartParticleToggleButton = createActionButton(
		createSettingRow("Heart Particle Effect", "Gamepass owners only", 2),
		"LOCKED"
	)
	v6.HeartParticleToggleButton.MouseButton1Click:Connect(function()
		if clickSound then
			pcall(function()
				clickSound:Play()
			end)
		end

		v2.RefreshHeartParticleEntitlement()

		if v6.HeartParticleEffectUnlocked then
			v6.HeartParticleEffectEnabled = v6.HeartParticleEffectEnabled == false
			localPlayer:SetAttribute("HeartParticleEffectEnabled", v6.HeartParticleEffectEnabled)
			saveVisualizerSetting({ HeartParticleEffectEnabled = v6.HeartParticleEffectEnabled }) -- inferred equivalent call
			v2.RefreshHeartParticleToggle()
		elseif
			MonetizationConfig.GetGamePassId("HeartParticleEffect")
			and MonetizationConfig.GetGamePassId("HeartParticleEffect") ~= 0
		then
			MarketplaceService:PromptGamePassPurchase(
				localPlayer,
				MonetizationConfig.GetGamePassId("HeartParticleEffect")
			)
		end
	end)

	createActionButton(createSettingRow("Synthesia Color", "White/black falling bars", 3), "Edit").MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		OpenPianoColorWheel:Fire("synthesia")
	end)

	v8 = createActionButton(createSettingRow("Piano Model Highlight", "Actual piano keys", 4), "ON")
	v8.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		v6.ModelKeyHighlightEnabled = v6.ModelKeyHighlightEnabled == false
		localPlayer:SetAttribute("ModelKeyHighlightEnabled", v6.ModelKeyHighlightEnabled)
		saveVisualizerSetting({ ModelKeyHighlightEnabled = v6.ModelKeyHighlightEnabled }) -- inferred equivalent call

		if not v8 then
			return
		end

		local modelKeyHighlightEnabled = v6.ModelKeyHighlightEnabled ~= false
		v8.Text = modelKeyHighlightEnabled and "ON" or "OFF"
		v8.BackgroundColor3 = modelKeyHighlightEnabled and color or color2
	end)

	v6.HandIKToggleButton = createActionButton(createSettingRow("Hand Animation", "Piano hand IK animation", 5), "ON")
	v6.HandIKToggleButton.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		v6.HandIKEnabled = v6.HandIKEnabled == false
		localPlayer:SetAttribute("HandIKEnabled", v6.HandIKEnabled)
		local v52 = { HandIKEnabled = v6.HandIKEnabled }

		if saveVisualizerSettings and typeof(v52) == "table" then
			saveVisualizerSettings:FireServer(v52)
		end

		refreshHandIKToggle()
	end)
	refreshHandIKToggle()

	createActionButton(createSettingRow("GUI Key Highlight Color", "GUI white/black active colors", 6), "Edit").MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		OpenPianoColorWheel:Fire("keyHighlight")
	end)

	v31 = createPianoRoll2DColorRow(
		createSettingRow("2D White Tile Color", "Color for white-key falling tiles", 7),
		"WhiteTileColorHex",
		"pianoRollWhiteTile"
	)
	v32 = v31

	v36 = createPianoRoll2DColorRow(
		createSettingRow("2D Black Tile Color", "Color for black-key falling tiles", 8),
		"BlackTileColorHex",
		"pianoRollBlackTile"
	)

	v37 = createPianoRoll2DColorRow(
		createSettingRow("2D Burst Color", "Color wheel for hit effects", 9),
		"ImpactColorHex",
		"pianoRollImpact"
	)

	createPianoRoll2DShapeRow(createSettingRow("2D Burst Shape", "Choose circle, heart, diamond, or burst styles", 10))

	v38 = createPianoRoll2DTextBox(
		createSettingRow("2D Background Image", "Paste a Roblox image asset id", 11),
		"BackgroundImage",
		"rbxassetid://..."
	)

	createPianoRoll2DTransparencySlider(createSettingRow("2D Background Transparency", "0% opaque, 100% hidden", 12))
	v30 = normalizePianoRoll2DSettings(v30)
	pushPianoRoll2DSettingsToRuntime()
	updatePianoRoll2DSettingsVisuals()

	local v52 = list3:FindFirstChildOfClass("UIListLayout")

	if not v52 then
		v52 = Instance.new("UIListLayout")
		v52.Parent = list3
	end

	v52.SortOrder = Enum.SortOrder.LayoutOrder
	v52.Padding = UDim.new(0, 10)
	list3.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list3.CanvasSize = UDim2.new(0, 0, 0, 0)
	local uiPadding = list3:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 10)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = list3

	createVolumeSlider(createSettingRow("Other Player's Piano Volume", "Set to 0% to mute other pianos", 1, list3))

	createMaxPianoSoundsSlider(createSettingRow(
		"Maximum Piano Sounds",
		"Caps simultaneous piano sounds you hear",
		2,
		list3
	))

	if tagHandler then
		tagHandler.LayoutOrder = 1
	end

	refreshSynthesiaToggle() -- inferred equivalent call
	v2.RefreshHeartParticleToggle()
	refreshModelKeyHighlightToggle() -- inferred equivalent call
	refreshMapAtmosphereToggle()
	applyGuiHighlightSettings()
end

local function initializePrivacySettings()
	local v51 = list4:FindFirstChildOfClass("UIListLayout")

	if not v51 then
		v51 = Instance.new("UIListLayout")
		v51.Parent = list4
	end

	v51.SortOrder = Enum.SortOrder.LayoutOrder
	v51.Padding = UDim.new(0, 10)
	list4.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list4.CanvasSize = UDim2.new(0, 0, 0, 0)
	local uiPadding = list4:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 10)
	uiPadding.PaddingBottom = UDim.new(0, 10)
	uiPadding.Parent = list4

	for _, frame in ipairs(list4:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	v14 = createActionButton(
		createSettingRow("Hide AUTOPLAYING Tag", "Great Pretender gamepass owners only", 1, list4),
		"ON"
	)
	v14.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		refreshGreatPretenderEntitlement()

		if v9 then
			v10 = not v10
			pushPrivacySettingsToRuntime()
			savePrivacySettings() -- inferred equivalent call
			refreshPrivacyToggles()
		elseif gamePassId and gamePassId ~= 0 then
			MarketplaceService:PromptGamePassPurchase(localPlayer, gamePassId)
		end
	end)

	v15 = createActionButton(
		createSettingRow("Show Country Flag", "Display your country flag on overhead", 2, list4),
		"ON"
	)
	v15.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		v11 = not v11
		pushPrivacySettingsToRuntime()
		savePrivacySettings() -- inferred equivalent call
		refreshPrivacyToggles()
	end)

	v16 = createActionButton(
		createSettingRow("Hide Other Players", "Clientside characters, overheads, and chat", 3, list4),
		"OFF"
	)
	v16.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		v12 = not v12
		pushPrivacySettingsToRuntime()
		savePrivacySettings() -- inferred equivalent call
		refreshPrivacyToggles()
	end)

	v17 = createActionButton(
		createSettingRow("Other Players' Tile Effects", "Clientside falling piano tile effects", 4, list4),
		"ON"
	)
	v17.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		v13 = not v13
		pushPrivacySettingsToRuntime()

		if not v13 and PianoVisualization.FadeOtherPlayerVisualizations then
			PianoVisualization.FadeOtherPlayerVisualizations()
		end

		savePrivacySettings() -- inferred equivalent call
		refreshPrivacyToggles()
	end)

	refreshPrivacyToggles()
	pushPrivacySettingsToRuntime()
end

local function getEnabledTagCount() -- 2 equivalent calls inferred from this helper
	local count5 = 0

	for _, v51 in pairs(v5) do
		if v51 then
			count5 += 1
		end
	end

	return count5
end

local function applyTagPreferences(items)
	local v51 = {}
	local v52

	if type(items) == "table" then
		v52 = next(items) ~= nil
	else
		v52 = false
	end

	local count5 = 0

	for _, v53 in ipairs(v4) do
		if not (type(v53) == "table" and v53.Type == "Tag") then
			continue
		end

		local tag = v53.Tag

		if v52 then
			v51[tag] = items[tag] == true
		else
			local v54 = count5 < 2
			v51[tag] = v54

			if v54 then
				count5 += 1
			end
		end
	end

	v5 = v51
end

local function updateDisplayedTags()
	if not updateTagPreferences then
		return
	end

	local v51 = {}

	for k, v52 in pairs(v5) do
		if v52 then
			table.insert(v51, k)
		end
	end

	updateTagPreferences:FireServer(v51)
end

local function createTagSlider(p)
	local clone = TagTemplate:Clone()
	clone.Parent = tagList

	local tagName = clone:FindFirstChild("TagName")

	if tagName then
		tagName.Text = createGradientText(p.Tag, p.Gradient)
		tagName.RichText = true
	end

	local element = clone:FindFirstChild("Element")

	if element then
		element.Visible = false
	end

	local v51 = v5[p.Tag]

	if v51 == nil then
		if getEnabledTagCount() < 2 then -- inferred equivalent call
			v5[p.Tag] = true
			v51 = true
		else
			v5[p.Tag] = false
			v51 = false
		end
	end

	local actionButton = createActionButton(clone, v51 and "Unequip" or "Equip")
	actionButton.BackgroundColor3 = v51 and color3 or color
	actionButton:SetAttribute("state", v51)

	local function refreshButton() -- 1 equivalent call inferred from this helper
		local state = actionButton:GetAttribute("state")
		actionButton.Text = state and "Unequip" or "Equip"
		actionButton.BackgroundColor3 = state and color3 or color
	end

	actionButton.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		v51 = actionButton:GetAttribute("state")

		if v51 then
			actionButton:SetAttribute("state", false)
			v5[p.Tag] = false
		else
			if getEnabledTagCount() >= 2 then -- inferred equivalent call
				v.Warn("[Settings] Cannot enable more than " .. 2 .. " tags")
				return
			end

			actionButton:SetAttribute("state", true)
			v5[p.Tag] = true
		end

		refreshButton() -- inferred equivalent call
		updateDisplayedTags()
	end)

	return clone
end

local function populateTagList()
	if type(v4) ~= "table" then
		v.Warn("[SettingsHandler] Invalid playerTags data")
		return
	end

	for _, frame in ipairs(tagList:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local count5 = 0

	for _, v51 in ipairs(v4) do
		if not (type(v51) == "table" and v51.Type == "Tag") then
			continue
		end

		createTagSlider(v51)
		count5 += 1
	end

	if tagHandler then
		tagHandler.Visible = count5 > 0
	end

	if chatTags then
		chatTags.Visible = v3 == "ChatTags"
	end
end

function v2.GetEnabledCount()
	local count5 = 0

	for _, v51 in pairs(v2.Enabled) do
		if v51 then
			count5 += 1
		end
	end

	return count5
end

function v2.ApplyPreferences(items)
	local enabled = {}
	local v52

	if type(items) == "table" then
		v52 = next(items) ~= nil
	else
		v52 = false
	end

	local count5 = 0

	for _, tag in ipairs(v2.Tags) do
		if not (type(tag) == "table" and tag.Type == "Tag") then
			continue
		end

		local tag2 = tag.Tag

		if v52 then
			enabled[tag2] = items[tag2] == true
		else
			local v53 = count5 < 2
			enabled[tag2] = v53

			if v53 then
				count5 += 1
			end
		end
	end

	v2.Enabled = enabled
end

function v2.UpdateDisplayed()
	if not v2.UpdatePreferences then
		return
	end

	local v51 = {}

	for k, v52 in pairs(v2.Enabled) do
		if v52 then
			table.insert(v51, k)
		end
	end

	v2.UpdatePreferences:FireServer(v51)
end

function v2.CreateSlider(p)
	local clone = TagTemplate:Clone()
	clone.Parent = v2.TagList

	local tagName = clone:FindFirstChild("TagName")

	if tagName then
		tagName.Text = createGradientText(p.Tag, p.Gradient)
		tagName.RichText = true
	end

	local element = clone:FindFirstChild("Element")

	if element then
		element.Visible = false
	end

	local v51 = v2.Enabled[p.Tag]

	if v51 == nil then
		if v2.GetEnabledCount() < 2 then
			v2.Enabled[p.Tag] = true
			v51 = true
		else
			v2.Enabled[p.Tag] = false
			v51 = false
		end
	end

	local actionButton = createActionButton(clone, v51 and "Unequip" or "Equip")
	actionButton.BackgroundColor3 = v51 and color3 or color
	actionButton:SetAttribute("state", v51)

	local function refreshButton() -- 1 equivalent call inferred from this helper
		local state = actionButton:GetAttribute("state")
		actionButton.Text = state and "Unequip" or "Equip"
		actionButton.BackgroundColor3 = state and color3 or color
	end

	actionButton.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		v51 = actionButton:GetAttribute("state")

		if v51 then
			actionButton:SetAttribute("state", false)
			v2.Enabled[p.Tag] = false
		else
			if v2.GetEnabledCount() >= 2 then
				v.Warn("[Settings] Cannot enable more than " .. 2 .. " titles")
				return
			end

			actionButton:SetAttribute("state", true)
			v2.Enabled[p.Tag] = true
		end

		refreshButton() -- inferred equivalent call
		v2.UpdateDisplayed()
	end)

	return clone
end

function v2.Populate()
	if type(v2.Tags) ~= "table" then
		v.Warn("[SettingsHandler] Invalid titleTags data")
		return
	end

	for _, frame in ipairs(v2.TagList:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	local count5 = 0

	for _, tag in ipairs(v2.Tags) do
		if not (type(tag) == "table" and tag.Type == "Tag") then
			continue
		end

		v2.CreateSlider(tag)
		count5 += 1
	end

	if v2.TagHandler then
		v2.TagHandler.Visible = count5 > 0
	end

	if v2.Frame then
		v2.Frame.Visible = v3 == "Title"
	end
end

function v2.Reset()
	local count5 = 0

	for k, _ in pairs(v2.Enabled) do
		v2.Enabled[k] = false
	end

	for _, tag in ipairs(v2.Tags) do
		if not (type(tag) == "table" and tag.Type == "Tag" and count5 < 2) then
			continue
		end

		v2.Enabled[tag.Tag] = true
		count5 += 1
	end

	local count6 = 0

	for _, frame in ipairs(v2.TagList:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		count6 += 1
		local action = frame:FindFirstChild("Action")

		if not action then
			continue
		end

		local v51 = count6 <= 2
		action:SetAttribute("state", v51)
		action.Text = v51 and "Unequip" or "Equip"
		action.BackgroundColor3 = v51 and color3 or color
	end

	v2.UpdateDisplayed()
end

local function resetSettings()
	local count5 = 0

	for k, _ in pairs(v5) do
		v5[k] = false
	end

	for _, v51 in ipairs(v4) do
		if not (type(v51) == "table" and v51.Type == "Tag" and count5 < 2) then
			continue
		end

		v5[v51.Tag] = true
		count5 += 1
	end

	local count6 = 0

	for _, frame in ipairs(tagList:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		count6 += 1
		local action = frame:FindFirstChild("Action")

		if not action then
			continue
		end

		local v51 = count6 <= 2
		action:SetAttribute("state", v51)
		action.Text = v51 and "Unequip" or "Equip"
		action.BackgroundColor3 = v51 and color3 or color
	end

	updateDisplayedTags()

	v6.DefaultSynthesiaEnabled = true
	v6.HeartParticleEffectEnabled = true
	v6.VisualizerColorHex = "#FFFFFF"
	v6.WhiteSynthesiaHex = "#FFFFFF"
	v6.BlackSynthesiaHex = "#FFFFFF"
	v6.ModelKeyHighlightEnabled = true
	v6.HandIKEnabled = true
	v6.WhiteKeyHighlightHex = "#66FF66"
	v6.BlackKeyHighlightHex = "#66FF66"
	localPlayer:SetAttribute("DefaultSynthesiaEnabled", true)
	localPlayer:SetAttribute("HeartParticleEffectEnabled", true)
	localPlayer:SetAttribute("CurrentColourHex", v6.VisualizerColorHex)
	localPlayer:SetAttribute("WhiteSynthesiaHex", v6.WhiteSynthesiaHex)
	localPlayer:SetAttribute("BlackSynthesiaHex", v6.BlackSynthesiaHex)
	localPlayer:SetAttribute("ModelKeyHighlightEnabled", true)
	localPlayer:SetAttribute("HandIKEnabled", true)
	otherPianoVolume2 = 100
	maxPianoSounds = v23
	v10 = true
	v11 = true
	v12 = false
	v13 = true
	mapAtmosphereEnabled = false
	localPlayer:SetAttribute("MapAtmosphereEnabled", false)
	v2.TeamSettings:Reset(true)
	v2.LightingSettings:Reset(true)
	applyPianoRoll2DSettings(v29, false) -- inferred equivalent call
	savePianoRoll2DSettings(true) -- inferred equivalent call
	pushPrivacySettingsToRuntime()
	refreshPrivacyToggles()
	savePrivacySettings() -- inferred equivalent call
	updateOtherPianoVolumeVisuals()
	updateMaxPianoSoundsVisuals()
	saveOtherPianoVolume() -- inferred equivalent call
	saveMaxPianoSounds() -- inferred equivalent call
	saveMapAtmosphereSetting()
	refreshMapAtmosphereToggle()
	applyGuiHighlightSettings()
	saveVisualizerSetting({ -- inferred equivalent call
		VisualizerColorHex = v6.VisualizerColorHex,
		DefaultSynthesiaEnabled = true,
		HeartParticleEffectEnabled = true,
		HandIKEnabled = true,
		WhiteSynthesiaHex = v6.WhiteSynthesiaHex,
		BlackSynthesiaHex = v6.BlackSynthesiaHex,
		ModelKeyHighlightEnabled = true,
		WhiteKeyHighlightHex = v6.WhiteKeyHighlightHex,
		BlackKeyHighlightHex = v6.BlackKeyHighlightHex
	})
	refreshSynthesiaToggle() -- inferred equivalent call
	v2.RefreshHeartParticleToggle()
	refreshModelKeyHighlightToggle() -- inferred equivalent call
	refreshHandIKToggle()

	if BindsLogic and BindsLogic.ResetBindings then
		BindsLogic.ResetBindings()
	end

	actionKeyBinds2 = {}

	if fn2 then
		fn2()
	end

	saveActionKeybinds() -- inferred equivalent call
	v.Print("[Settings] All settings reset to default values")
end

local function updateCategoryUI()
	general.Visible = v3 == "General"
	audio.Visible = v3 == "Audio"
	privacy.Visible = v3 == "Privacy"
	chatTags.Visible = v3 == "ChatTags"
	v2.Frame.Visible = v3 == "Title"
	keybinds.Visible = v3 == "Keybinds"
	notebinds.Visible = v3 == "Notebinds"

	general2.BackgroundColor3 = v3 == "General" and color or color2
	audio2.BackgroundColor3 = v3 == "Audio" and color or color2
	privacy2.BackgroundColor3 = v3 == "Privacy" and color or color2
	chatTags2.BackgroundColor3 = v3 == "ChatTags" and color or color2
	v2.Sidebar.BackgroundColor3 = v3 == "Title" and color or color2
	keybinds2.BackgroundColor3 = v3 == "Keybinds" and color or color2
	notebinds2.BackgroundColor3 = v3 == "Notebinds" and color or color2
	v2.TeamSettings:SetActive(v3 == "Teams")
	v2.LightingSettings:SetActive(v3 == "Lighting")
end

local function switchToCategory(p) -- 6 equivalent calls inferred from this helper
	if v3 ~= p then
		v3 = p
		updateCategoryUI()
		v.Print("[Settings] Switched to " .. p .. " category")
	end

	if p == "ChatTags" and requestChatTags then
		task.spawn(function()
			local success3, result3, v51 = pcall(function()
				return requestChatTags:InvokeServer()
			end)

			if success3 and type(result3) == "table" then
				v4 = result3
				applyTagPreferences(v51)
				populateTagList()
				v.Print("[SettingsHandler] Refreshed " .. #v4 .. " chat tags")
			end
		end)
	elseif p == "Teams" then
		task.spawn(function()
			v2.TeamSettings:Refresh(true)
		end)
	elseif p == "Lighting" then
		task.spawn(function()
			v2.LightingSettings:Refresh(true)
		end)
	elseif p == "Title" and v2.RequestTitles then
		task.spawn(function()
			local success3, result3, v51 = pcall(function()
				return v2.RequestTitles:InvokeServer()
			end)

			if success3 and type(result3) == "table" then
				v2.Tags = result3
				v2.ApplyPreferences(v51)
				v2.Populate()
				v.Print("[SettingsHandler] Refreshed " .. #v2.Tags .. " titles")
			end
		end)
	end
end

local function closeSettings() -- 1 equivalent call inferred from this helper
	local settingsCloseEvent = ReplicatedStorage2:FindFirstChild("SettingsCloseEvent")

	if not settingsCloseEvent then
		settingsCloseEvent = Instance.new("BindableEvent")
		settingsCloseEvent.Name = "SettingsCloseEvent"
		settingsCloseEvent.Parent = ReplicatedStorage2
	end

	settingsCloseEvent:Fire()

	settings.Visible = false
	v.Print("[Settings] Settings frame closed")
end

if pianoUserSettingsLoaded then
	pianoUserSettingsLoaded.OnClientEvent:Connect(applyPianoUserSettings)
end

if getPianoUserSettings then
	task.spawn(function()
		local success3, result3 = pcall(function()
			return getPianoUserSettings:InvokeServer()
		end)

		if success3 then
			applyPianoUserSettings(result3)
		end
	end)
end

if visualizerSettingsLoaded then
	visualizerSettingsLoaded.OnClientEvent:Connect(function(data)
		if typeof(data) ~= "table" then
			return
		end

		if typeof(data.VisualizerColorHex) == "string" then
			v6.VisualizerColorHex = data.VisualizerColorHex
			localPlayer:SetAttribute("CurrentColourHex", data.VisualizerColorHex)
		end

		if typeof(data.DefaultSynthesiaEnabled) == "boolean" then
			v6.DefaultSynthesiaEnabled = data.DefaultSynthesiaEnabled
			localPlayer:SetAttribute("DefaultSynthesiaEnabled", data.DefaultSynthesiaEnabled)
		end

		if typeof(data.HeartParticleEffectEnabled) == "boolean" then
			v6.HeartParticleEffectEnabled = data.HeartParticleEffectEnabled
			localPlayer:SetAttribute("HeartParticleEffectEnabled", data.HeartParticleEffectEnabled)
		end

		if typeof(data.WhiteSynthesiaHex) == "string" then
			v6.WhiteSynthesiaHex = data.WhiteSynthesiaHex
			localPlayer:SetAttribute("WhiteSynthesiaHex", data.WhiteSynthesiaHex)
		end

		if typeof(data.BlackSynthesiaHex) == "string" then
			v6.BlackSynthesiaHex = data.BlackSynthesiaHex
			localPlayer:SetAttribute("BlackSynthesiaHex", data.BlackSynthesiaHex)
		end

		if typeof(data.ModelKeyHighlightEnabled) == "boolean" then
			v6.ModelKeyHighlightEnabled = data.ModelKeyHighlightEnabled
			localPlayer:SetAttribute("ModelKeyHighlightEnabled", data.ModelKeyHighlightEnabled)
		end

		if typeof(data.HandIKEnabled) == "boolean" then
			v6.HandIKEnabled = data.HandIKEnabled
			localPlayer:SetAttribute("HandIKEnabled", data.HandIKEnabled)
		end

		if typeof(data.WhiteKeyHighlightHex) == "string" then
			v6.WhiteKeyHighlightHex = data.WhiteKeyHighlightHex
		end

		if typeof(data.BlackKeyHighlightHex) == "string" then
			v6.BlackKeyHighlightHex = data.BlackKeyHighlightHex
		end

		applyGuiHighlightSettings()
		refreshSynthesiaToggle() -- inferred equivalent call
		v2.RefreshHeartParticleToggle()
		refreshModelKeyHighlightToggle() -- inferred equivalent call
		refreshHandIKToggle()
	end)
end

if advancedChatTags then
	advancedChatTags.OnClientEvent:Connect(function(value, ...)
		if value == "PlayerTagsUpdate" then
			local v51, v52, v53 = ...

			if v51 == localPlayer.UserId and type(v52) == "table" then
				v4 = v52
				applyTagPreferences(v53)
				populateTagList()
				v.Print("[SettingsHandler] Updated local player tags: " .. #v4)
			end
		elseif value == "PlayerPreferencesUpdate" then
			local v51, v52 = ...

			if v51 == localPlayer.UserId then
				applyTagPreferences(v52)
				populateTagList()
			end
		else
			if type(value) == "string" then
				return
			end

			if type(value) == "table" then
				local v51 = ...
				v4 = value
				applyTagPreferences(v51)
				populateTagList()
				v.Print("[SettingsHandler] Loaded " .. #v4 .. " tags")
			end
		end
	end)
end

if requestChatTags then
	task.spawn(function()
		local success3, result3, v51 = pcall(function()
			return requestChatTags:InvokeServer()
		end)

		if success3 and result3 and type(result3) == "table" and #result3 > 0 then
			v4 = result3
			applyTagPreferences(v51)
			populateTagList()
			v.Print("[SettingsHandler] Requested and loaded " .. #v4 .. " tags")
		end
	end)
end

if v2.RequestTitles then
	task.spawn(function()
		local success3, result3, v51 = pcall(function()
			return v2.RequestTitles:InvokeServer()
		end)

		if success3 and result3 and type(result3) == "table" then
			v2.Tags = result3
			v2.ApplyPreferences(v51)
			v2.Populate()
			v.Print("[SettingsHandler] Requested and loaded " .. #v2.Tags .. " titles")
		end
	end)
end

initializeActionKeybindSettings()
initializePianoVisualSettings()
initializePrivacySettings()
v2.TeamSettings:Initialize()
v2.LightingSettings:Initialize()

task.spawn(function()
	refreshGreatPretenderEntitlement()
	v2.RefreshHeartParticleEntitlement()
	refreshPrivacyToggles()
	pushPrivacySettingsToRuntime()
end)

localPlayer:GetAttributeChangedSignal("HeartParticleEffectUnlocked"):Connect(function()
	v6.HeartParticleEffectUnlocked = localPlayer:GetAttribute("HeartParticleEffectUnlocked") == true
	v2.RefreshHeartParticleToggle()
end)

if shopPurchasesUpdated then
	shopPurchasesUpdated.OnClientEvent:Connect(function()
		task.spawn(function()
			refreshGreatPretenderEntitlement()
			v2.RefreshHeartParticleEntitlement()
			refreshPrivacyToggles()
			pushPrivacySettingsToRuntime()
			v2.TeamSettings:Refresh()
		end)
	end)
end

localPlayer:GetAttributeChangedSignal("PianoDataStatus"):Connect(function()
	if localPlayer:GetAttribute("PianoDataStatus") == "Ready" then
		task.spawn(function()
			refreshGreatPretenderEntitlement()
			v2.RefreshHeartParticleEntitlement()
			refreshPrivacyToggles()
			pushPrivacySettingsToRuntime()
			v2.TeamSettings:Refresh()
		end)
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p == localPlayer and p3 then
		task.defer(function()
			v2.TeamSettings:Refresh()
		end)
	end

	if p == localPlayer and p2 == gamePassId and p3 then
		v9 = true
		v10 = true
		pushPrivacySettingsToRuntime()
		savePrivacySettings() -- inferred equivalent call
		refreshPrivacyToggles()
	end

	if p == localPlayer and p2 == MonetizationConfig.GetGamePassId("HeartParticleEffect") and p3 then
		v6.HeartParticleEffectUnlocked = true
		v6.HeartParticleEffectEnabled = true
		localPlayer:SetAttribute("HeartParticleEffectUnlocked", true)
		localPlayer:SetAttribute("HeartParticleEffectEnabled", true)
		saveVisualizerSetting({ HeartParticleEffectEnabled = true }) -- inferred equivalent call
		v2.RefreshHeartParticleToggle()
	end
end)

updateCategoryUI()

parent3.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	switchToCategory("General") -- inferred equivalent call
end)
active.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	switchToCategory("Audio") -- inferred equivalent call
end)
active2.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	switchToCategory("Privacy") -- inferred equivalent call
end)
v2.TeamSettings:ConnectButton(function()
	safeClick() -- inferred equivalent call

	if v3 ~= "Teams" then
		v3 = "Teams"
		updateCategoryUI()
		v.Print("[Settings] Switched to Teams category")
	end

	task.spawn(function()
		v2.TeamSettings:Refresh(true)
	end)
end)
v2.LightingSettings:ConnectButton(function()
	safeClick() -- inferred equivalent call

	if v3 ~= "Lighting" then
		v3 = "Lighting"
		updateCategoryUI()
		v.Print("[Settings] Switched to Lighting category")
	end

	task.spawn(function()
		v2.LightingSettings:Refresh(true)
	end)
end)
active3.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	switchToCategory("ChatTags") -- inferred equivalent call
end)
v2.Button.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call

	if v3 ~= "Title" then
		v3 = "Title"
		updateCategoryUI()
		v.Print("[Settings] Switched to Title category")
	end

	if v2.RequestTitles then
		task.spawn(function()
			local success3, result3, v51 = pcall(function()
				return v2.RequestTitles:InvokeServer()
			end)

			if success3 and type(result3) == "table" then
				v2.Tags = result3
				v2.ApplyPreferences(v51)
				v2.Populate()
				v.Print("[SettingsHandler] Refreshed " .. #v2.Tags .. " titles")
			end
		end)
	end
end)
active4.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	switchToCategory("Keybinds") -- inferred equivalent call
end)
active5.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	switchToCategory("Notebinds") -- inferred equivalent call
end)
result.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	closeSettings() -- inferred equivalent call
end)
reset.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	resetSettings()
end)
reset2.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	resetSettings()
end)
v2.ResetButton.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	v2.Reset()
end)
reset3.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	otherPianoVolume2 = 100
	maxPianoSounds = v23
	updateOtherPianoVolumeVisuals()
	updateMaxPianoSoundsVisuals()
	saveOtherPianoVolume() -- inferred equivalent call
	saveMaxPianoSounds() -- inferred equivalent call
end)
reset4.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	v10 = true
	v11 = true
	v12 = false
	v13 = true
	pushPrivacySettingsToRuntime()
	refreshPrivacyToggles()
	savePrivacySettings() -- inferred equivalent call
end)
reset5.MouseButton1Click:Connect(function()
	safeClick() -- inferred equivalent call
	actionKeyBinds2 = {}
	fn2()
	saveActionKeybinds() -- inferred equivalent call
end)

task.spawn(function()
	local openSettingsNotebinds = ReplicatedStorage2:WaitForChild("OpenSettingsNotebinds", 10)

	if openSettingsNotebinds then
		openSettingsNotebinds.Event:Connect(function()
			v3 = "Notebinds"
			updateCategoryUI()
		end)
	end
end)

task.spawn(function()
	local openAutoPlayerKeybindSettings = ReplicatedStorage2:FindFirstChild("OpenAutoPlayerKeybindSettings")

	if openAutoPlayerKeybindSettings and not openAutoPlayerKeybindSettings:IsA("BindableEvent") then
		openAutoPlayerKeybindSettings:Destroy()
		openAutoPlayerKeybindSettings = nil
	end

	if not openAutoPlayerKeybindSettings then
		openAutoPlayerKeybindSettings = Instance.new("BindableEvent")
		openAutoPlayerKeybindSettings.Name = "OpenAutoPlayerKeybindSettings"
		openAutoPlayerKeybindSettings.Parent = ReplicatedStorage2
	end

	openAutoPlayerKeybindSettings.Event:Connect(function()
		bringSettingsGuiToFront()
		settings.Visible = true
		v3 = "Keybinds"
		updateCategoryUI()
		task.defer(openAutoPlayerKeybindPopup)
	end)
end)

v.Print("[SettingsHandler] Initialized successfully")