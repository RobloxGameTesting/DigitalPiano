local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LightingSettingsConfig = require(ReplicatedStorage:WaitForChild("LightingSettingsConfig"))
local MapLightingProfiles = require(ReplicatedStorage:WaitForChild("MapLightingProfiles"))

local LightingSettingsCategoryController = {}
LightingSettingsCategoryController.__index = LightingSettingsCategoryController

local color = Color3.fromRGB(45, 118, 235)
local color2 = Color3.fromRGB(34, 39, 44)
local color3 = Color3.fromRGB(36, 41, 46)
local color4 = Color3.fromRGB(160, 166, 180)

local v = { "PST-LIGHTING-v1:" }
local v2 = { FogStart = 0, FogEnd = 1000000 }
local v3 = { Density = 0, Offset = 0, Glare = 0, Haze = 0 }

local function ensureCorner(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local uiCorner = guiObject:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, p)
	uiCorner.Parent = guiObject
end

local function clearList(list)
	if not list then
		return
	end

	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("UIListLayout") or child:IsA("UICorner") or child:IsA("UIPadding") then
			continue
		end

		child:Destroy()
	end
end

local function getRemotes()
	local success, result = pcall(function()
		local piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)
		return piano_Dependencies and piano_Dependencies:WaitForChild("Remotes", 10)
	end)

	return success and result or nil
end

local function getCustomLightingChangedEvent() -- 1 equivalent call inferred from this helper
	local customLightingChanged = ReplicatedStorage:FindFirstChild("CustomLightingChanged")

	if not customLightingChanged then
		customLightingChanged = Instance.new("BindableEvent")
		customLightingChanged.Name = "CustomLightingChanged"
		customLightingChanged.Parent = ReplicatedStorage
	end

	return customLightingChanged
end

local success, result = pcall(function()
	return ReplicatedStorage:WaitForChild("SoundFX", 5)
end)
local clickSound

if success and result then
	clickSound = result:FindFirstChild("ClickSound")
else
	clickSound = nil
end

local function safeClick() -- 23 equivalent calls inferred from this helper
	if clickSound then
		pcall(function()
			clickSound:Play()
		end)
	end
end

local function formatNumber(p, decimals)
	local v4 = math.clamp(math.floor(tonumber(decimals) or 0), 0, 3)

	if v4 == 0 then
		return (tostring((math.floor((tonumber(p) or 0) + 0.5))))
	end

	return string.format("%." .. tostring(v4) .. "f", tonumber(p) or 0)
end

local function color3ToHex(data) -- 1 equivalent call inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.clamp(math.floor(data.R * 255 + 0.5), 0, 255),
		math.clamp(math.floor(data.G * 255 + 0.5), 0, 255),
		(math.clamp(math.floor(data.B * 255 + 0.5), 0, 255))
	)
end

local function normalizeHexText(value, value2) -- 4 equivalent calls inferred from this helper
	local upper = tostring(value or ""):gsub("#", ""):upper()

	if upper:match("^%x%x%x%x%x%x$") then
		return "#" .. upper
	end

	return value2 or "#FFFFFF"
end

local function hexToColor3(hexText, value)
	local v4 = normalizeHexText(hexText, value):sub(2) -- inferred equivalent call
	return Color3.fromRGB(
		tonumber(v4:sub(1, 2), 16) or 255,
		tonumber(v4:sub(3, 4), 16) or 255,
		tonumber(v4:sub(5, 6), 16) or 255
	)
end

local function colorFieldMatchesSection(p, name): boolean -- 1 equivalent call inferred from this helper
	if name == "General" and p.Group == "Lighting" or name == "Atmosphere" and p.Group == "Atmosphere" then
		return true
	elseif name == "Color Correction" then
		return p.Group == "ColorCorrection"
	else
		return false
	end
end

local function cleanPresetName(value, value2)
	local v4 = tostring(value or ""):gsub("[%c]", " "):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s%s+", " ")
	return (v4 == "" and (value2 or "My Preset") or v4):sub(1, 32)
end

local function setZIndexRecursive(guiObject, zIndex)
	if guiObject:IsA("GuiObject") then
		guiObject.ZIndex = zIndex
	end

	for _, child in ipairs(guiObject:GetChildren()) do
		setZIndexRecursive(child, zIndex + 1)
	end
end

local function getWheelColorFromInput(wheel, p)
	local absoluteSize = wheel.AbsoluteSize
	local v4 = wheel.AbsolutePosition + absoluteSize / 2
	local selected = Vector2.new(p.Position.X, p.Position.Y) - v4
	local v5 = math.max(1, math.min(absoluteSize.X, absoluteSize.Y) / 2)

	if v5 < selected.Magnitude then
		selected = selected.Unit * v5
	end

	local v6 = (0.5 - math.atan2(selected.Y, selected.X) / 6.283185307179586) % 1
	local v7 = math.clamp(selected.Magnitude / v5, 0, 1)
	return Color3.fromHSV(v6, v7, 1), selected, v5
end

local function setWheelPickerFromColor(wheel, picker, p)
	local absoluteSize = wheel.AbsoluteSize
	local v4 = math.max(1, math.min(absoluteSize.X, absoluteSize.Y) / 2)
	local hsv, v5 = p:ToHSV()
	local v6 = (0.5 - hsv) * 3.141592653589793 * 2
	local v7 = Vector2.new(math.cos(v6), (math.sin(v6))) * v5 * v4
	picker.Position = UDim2.fromScale(
		math.clamp((v7.X + v4) / (v4 * 2), 0, 1),
		(math.clamp((v7.Y + v4) / (v4 * 2), 0, 1))
	)
end

local function createText(parent, name, text, font, textSize, textColor, position, size)
	local text2 = parent:FindFirstChild(name) or Instance.new("TextLabel")
	text2.Name = name
	text2.BackgroundTransparency = 1
	text2.Font = font
	text2.Text = text
	text2.TextColor3 = textColor
	text2.TextSize = textSize
	text2.TextXAlignment = Enum.TextXAlignment.Left
	text2.TextYAlignment = Enum.TextYAlignment.Center
	text2.TextTruncate = Enum.TextTruncate.AtEnd
	text2.Position = position
	text2.Size = size
	text2.Parent = parent
	return text2
end

local function createButton(parent, name, text, position, size, p)
	local button = parent:FindFirstChild(name) or Instance.new("TextButton")
	button.Name = name
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = p or color
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamBold
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 13
	button.Parent = parent
	ensureCorner(button, 8)
	return button
end

local function getLightingEffects(className, name)
	local lightingEffects = {}
	local child = Lighting:FindFirstChild(name)

	if child and child:IsA(className) then
		table.insert(lightingEffects, child)
	end

	for _, child2 in ipairs(Lighting:GetChildren()) do
		if child2:IsA(className) and child2 ~= child then
			table.insert(lightingEffects, child2)
		end
	end

	if #lightingEffects ~= 0 then
		return lightingEffects
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = Lighting
	table.insert(lightingEffects, instance)

	return lightingEffects
end

local function applyProperties(p, items)
	if not (p and items) then
		return
	end

	for k, item in pairs(items) do
		local success2, result2 = pcall(function()
			return p[k]
		end)

		if success2 and typeof(result2) == typeof(item) then
			pcall(function()
				p[k] = item
			end)
		end
	end
end

function LightingSettingsCategoryController.new(p)
	local localPlayer = Players.LocalPlayer
	local center = p.Parent:WaitForChild("Settings"):WaitForChild("Center")
	local body = center:WaitForChild("Body")
	local sideBar = center:WaitForChild("SideBar")
	local categoryScroll = sideBar:FindFirstChild("CategoryScroll") or sideBar
	local general = body:WaitForChild("General")
	local list = general:WaitForChild("List")
	local reset = general:WaitForChild("Reset")
	local audio = categoryScroll:FindFirstChild("Audio") or categoryScroll:FindFirstChild("General")

	local object = setmetatable({}, LightingSettingsCategoryController)
	object.LocalPlayer = localPlayer
	object.Body = body
	object.SideBar = sideBar
	object.CategoryContainer = categoryScroll
	object.GeneralFrame = general
	object.BaseList = list
	object.BaseReset = reset
	object.Frame = body:FindFirstChild("Lighting")
	object.Sidebar = categoryScroll:FindFirstChild("Lighting") or sideBar:FindFirstChild("Lighting")
	object.Button = nil
	object.List = nil
	object.ResetButton = nil
	object.GetLightingSettings = nil
	object.SaveLightingSettings = nil
	object.Settings = LightingSettingsConfig.SanitizeSettings(nil)
	object.RequestInFlight = false
	object.PendingSave = false
	object.ChangeRevision = 0
	object.HasUnsavedLocalChange = false
	object.ColorPickerPanel = nil
	object.PresetNamePanel = nil
	object.DeletePresetPanel = nil
	object.ExportPanel = nil
	object.ImportPanel = nil
	object.PendingDeletePresetId = nil
	object.PendingDeletePresetName = nil
	object.ActiveColorField = nil
	object.ActiveColorHex = "#FFFFFF"
	object.MapAtmosphereGetter = nil
	object.MapAtmosphereSetter = nil

	if not object.Frame then
		object.Frame = general:Clone()
		object.Frame.Name = "Lighting"
		object.Frame.Visible = false
		object.Frame.Parent = body
		clearList(object.Frame:FindFirstChild("List"))
	end

	if object.Sidebar then
		if object.Sidebar.Parent ~= categoryScroll and categoryScroll:IsDescendantOf(sideBar) then
			object.Sidebar.Parent = categoryScroll
		end
	else
		object.Sidebar = audio:Clone()
		object.Sidebar.Name = "Lighting"

		for _, lighting in ipairs(object.Sidebar:GetChildren()) do
			if not lighting:IsA("TextLabel") then
				continue
			end

			lighting.Name = "Lighting"
			lighting.Text = "Lighting"
		end

		object.Sidebar.Parent = categoryScroll
	end

	object.List = object.Frame:WaitForChild("List")
	object.ResetButton = object.Frame:WaitForChild("Reset")
	object.Button = object.Sidebar:WaitForChild("Active")
	object.Sidebar.LayoutOrder = 4
	object.Sidebar.Visible = true
	ensureCorner(object.Sidebar, 8)

	local textLabel = object.Sidebar:FindFirstChildWhichIsA("TextLabel")

	if textLabel then
		textLabel.AnchorPoint = Vector2.new(0, 0)
		textLabel.Position = UDim2.new(0, 12, 0, 0)
		textLabel.Size = UDim2.new(1, -24, 1, 0)
		textLabel.Text = "Lighting"
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.TextWrapped = true
		textLabel.TextScaled = true
		textLabel.TextTruncate = Enum.TextTruncate.None
		local uiTextSizeConstraint = textLabel:FindFirstChildOfClass("UITextSizeConstraint")
			or Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MinTextSize = 12
		uiTextSizeConstraint.MaxTextSize = 22
		uiTextSizeConstraint.Parent = textLabel
	end

	local success2, result2 = pcall(function()
		local piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)
		return piano_Dependencies and piano_Dependencies:WaitForChild("Remotes", 10)
	end)
	local v4 = success2 and result2 or nil

	if v4 then
		object.GetLightingSettings = v4:FindFirstChild("GetLightingSettings")
			or v4:WaitForChild("GetLightingSettings", 5)
		object.SaveLightingSettings = v4:FindFirstChild("SaveLightingSettings")
			or v4:WaitForChild("SaveLightingSettings", 5)
	end

	return object
end

local function applyPropertiesToEffects(p, name, p2) -- 6 equivalent calls inferred from this helper
	for _, v4 in ipairs(getLightingEffects(p, name)) do
		applyProperties(v4, p2)
	end
end

function LightingSettingsCategoryController:BindMapAtmosphere(callback, callback2)
	self.MapAtmosphereGetter = typeof(callback) == "function" and callback or nil
	self.MapAtmosphereSetter = typeof(callback2) == "function" and callback2 or nil

	if self.List then
		self:Render()
	end
end

function LightingSettingsCategoryController:GetMapAtmosphereEnabled(): boolean
	if self.MapAtmosphereGetter then
		local success2, result2 = pcall(self.MapAtmosphereGetter)

		if success2 then
			return result2 == true
		end
	end

	return self.LocalPlayer:GetAttribute("MapAtmosphereEnabled") == true
end

function LightingSettingsCategoryController:SetMapAtmosphereEnabled(p, p2)
	local v4 = p == true

	if self.MapAtmosphereSetter then
		if not pcall(self.MapAtmosphereSetter, v4) then
			self.LocalPlayer:SetAttribute("MapAtmosphereEnabled", v4)
		end
	else
		self.LocalPlayer:SetAttribute("MapAtmosphereEnabled", v4)
	end

	if self.Settings and self.Settings.UseCustom then
		self:ApplyLocal()
	end

	if not p2 then
		self:Render()
	end
end

function LightingSettingsCategoryController:ClearFogHaze()
	applyProperties(Lighting, v2)
	applyPropertiesToEffects("Atmosphere", "Atmosphere", v3) -- inferred equivalent call
end

function LightingSettingsCategoryController:Notify(value, value2, p)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = tostring(value or "Lighting"),
			Text = tostring(value2 or ""),
			Duration = tonumber(p) or 3
		})
	end)
end

function LightingSettingsCategoryController.NormalizeLayout(data)
	data.Frame.AnchorPoint = data.GeneralFrame.AnchorPoint
	data.Frame.Position = data.GeneralFrame.Position
	data.Frame.Size = data.GeneralFrame.Size
	data.Frame.BackgroundColor3 = data.GeneralFrame.BackgroundColor3
	data.Frame.BackgroundTransparency = data.GeneralFrame.BackgroundTransparency
	data.Frame.BorderSizePixel = data.GeneralFrame.BorderSizePixel
	data.List.AnchorPoint = data.BaseList.AnchorPoint
	data.List.Position = data.BaseList.Position
	data.List.Size = UDim2.new(1, 0, 1, -54)
	data.List.BackgroundColor3 = data.BaseList.BackgroundColor3
	data.List.BackgroundTransparency = data.BaseList.BackgroundTransparency
	data.List.BorderSizePixel = data.BaseList.BorderSizePixel
	data.List.AutomaticCanvasSize = Enum.AutomaticSize.Y
	data.List.CanvasSize = UDim2.new(0, 0, 0, 0)
	data.List.ScrollBarThickness = 4
	local uiPadding = data.List:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
	uiPadding.Name = "UIPadding"
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.Parent = data.List
	ensureCorner(data.Frame, 8)
	ensureCorner(data.List, 8)
	data.ResetButton.AnchorPoint = Vector2.new(0, 1)
	data.ResetButton.Position = UDim2.new(0, 0, 1, -2)
	data.ResetButton.Size = UDim2.new(1, 0, 0, 36)
	data.ResetButton.Text = "Reset Lighting"
	ensureCorner(data.ResetButton, 8)
end

function LightingSettingsCategoryController.SetActive(p, p2)
	p.Frame.Visible = p2 == true
	p.Sidebar.BackgroundColor3 = p2 and color or color2
end

function LightingSettingsCategoryController.ConnectButton(p, onMouseButton1Click)
	if p.Button then
		p.Button.MouseButton1Click:Connect(onMouseButton1Click)
	end
end

function LightingSettingsCategoryController:RestoreMapLighting()
	local mapElevatorLastDestination = self.LocalPlayer:GetAttribute("MapElevatorLastDestination") or "lobby"
	local v4 = MapLightingProfiles.Get(mapElevatorLastDestination)
	applyProperties(Lighting, v4.Lighting)

	if self:GetMapAtmosphereEnabled() then
		applyPropertiesToEffects("Atmosphere", "Atmosphere", v4.Atmosphere) -- inferred equivalent call
	else
		self:ClearFogHaze()
	end

	applyPropertiesToEffects("DepthOfFieldEffect", "DepthOfField", { -- inferred equivalent call
		Enabled = false,
		FarIntensity = 0,
		NearIntensity = 0
	})
	applyPropertiesToEffects("BloomEffect", "Bloom", v4.Bloom) -- inferred equivalent call
	applyPropertiesToEffects("SunRaysEffect", "SunRays", v4.SunRays) -- inferred equivalent call
	applyPropertiesToEffects("ColorCorrectionEffect", "MapElevatorColorCorrection", v4.ColorCorrection) -- inferred equivalent call
end

function LightingSettingsCategoryController:ApplyLocal()
	self.Settings = LightingSettingsConfig.SanitizeSettings(self.Settings)
	self.LocalPlayer:SetAttribute("CustomLightingEnabled", self.Settings.UseCustom == true)
	self.LocalPlayer:SetAttribute(
		"CustomLightingPresetId",
		(tostring(self.Settings.SelectedPresetId or LightingSettingsConfig.DEFAULT_PRESET_ID))
	)

	if self.Settings.UseCustom then
		LightingSettingsConfig.ApplyToLighting(Lighting, self.Settings.Current)

		if not self:GetMapAtmosphereEnabled() then
			self:ClearFogHaze()
		end
	else
		self:RestoreMapLighting()
	end

	getCustomLightingChangedEvent():Fire(self.Settings.UseCustom == true, self.Settings.SelectedPresetId) -- inferred equivalent call
end

function LightingSettingsCategoryController:Save(p)
	if self.RequestInFlight then
		self.PendingSave = true
	elseif self.SaveLightingSettings then
		self.PendingSave = false
		self.RequestInFlight = true
		local changeRevision = self.ChangeRevision or 0
		local copy = LightingSettingsConfig.DeepCopy(self.Settings)
		local success2, result2, v4, v5 = pcall(function()
			return self.SaveLightingSettings:InvokeServer(copy)
		end)

		self.RequestInFlight = false

		if success2 and result2 == true and typeof(v5) == "table" then
			if changeRevision == (self.ChangeRevision or 0) then
				self.HasUnsavedLocalChange = false
				self.Settings = LightingSettingsConfig.SanitizeSettings(v5)
				self:ApplyLocal()
				self:Render()
			end
		elseif p then
			self:Notify(
				"Lighting",
				success2 and tostring(v4 or "Lighting could not be saved.") or "Please try again in a moment.",
				3
			)
		end

		if self.PendingSave then
			task.defer(function()
				if self.PendingSave and not self.RequestInFlight then
					self:Save(p)
				end
			end)
		end
	else
		self.PendingSave = false
		self.HasUnsavedLocalChange = false
		self:ApplyLocal()
	end
end

function LightingSettingsCategoryController:Refresh(p)
	if not self.GetLightingSettings then
		local success2, result2 = pcall(function()
			local piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)
			return piano_Dependencies and piano_Dependencies:WaitForChild("Remotes", 10)
		end)
		local v4 = success2 and result2 or nil

		if v4 then
			self.GetLightingSettings = v4:FindFirstChild("GetLightingSettings")
				or v4:WaitForChild("GetLightingSettings", 5)
			self.SaveLightingSettings = v4:FindFirstChild("SaveLightingSettings")
				or v4:WaitForChild("SaveLightingSettings", 5)
		end
	end

	if not self.GetLightingSettings then
		self:Render()
		return
	end

	local changeRevision = self.ChangeRevision or 0
	local success2, result2, v4, v5 = pcall(function()
		return self.GetLightingSettings:InvokeServer()
	end)

	if success2 and result2 == true and typeof(v5) == "table" then
		if
			changeRevision == (self.ChangeRevision or 0)
			and not (self.RequestInFlight or self.HasUnsavedLocalChange)
		then
			self.Settings = LightingSettingsConfig.SanitizeSettings(v5)
			self:ApplyLocal()
			self:Render()
		end
	elseif p then
		self:Notify(
			"Lighting",
			success2 and tostring(v4 or "Lighting settings could not be loaded.") or "Please try again in a moment.",
			3
		)
	end
end

function LightingSettingsCategoryController:MarkLocalChange()
	self.ChangeRevision = (self.ChangeRevision or 0) + 1
	self.HasUnsavedLocalChange = true
	return self.ChangeRevision
end

function LightingSettingsCategoryController:ApplyUserSettings(p, p2)
	if self.RequestInFlight or self.PendingSave or self.HasUnsavedLocalChange then
		return
	end

	if typeof(p) == "table" and typeof(p.Lighting) == "table" then
		self.Settings = LightingSettingsConfig.SanitizeSettings(p.Lighting)
		self:ApplyLocal()
		self:Render()
	elseif p2 then
		self:Refresh()
	end
end

function LightingSettingsCategoryController:CreateRow(p, value, layoutOrder, value2, p2)
	local v4 = tostring(p2 or p):gsub("[^%w_]", "")

	if v4 == "" then
		v4 = "Lighting" .. tostring(layoutOrder or 0)
	end

	local name = v4 .. "Row"
	local row = self.List:FindFirstChild(name) or Instance.new("Frame")
	row.Name = name
	row.LayoutOrder = layoutOrder
	row.Size = UDim2.new(1, -8, 0, value2 or 58)
	row.BackgroundColor3 = color3
	row.BorderSizePixel = 0
	row.Parent = self.List
	ensureCorner(row, 8)
	createText(
		row,
		"Label",
		tostring(p),
		Enum.Font.GothamBold,
		14,
		Color3.fromRGB(240, 242, 246),
		UDim2.new(0, 14, 0, 8),
		UDim2.new(1, -170, 0, 22)
	)
	local text = createText(
		row,
		"Description",
		tostring(value or ""),
		Enum.Font.Gotham,
		12,
		color4,
		UDim2.new(0, 14, 0, 30),
		UDim2.new(1, -170, 0, 18)
	)
	text.Visible = value ~= nil and value ~= ""
	return row
end

function LightingSettingsCategoryController:CreateHeader(p, layoutOrder)
	local header = self.List:FindFirstChild(tostring(p) .. "Header") or Instance.new("TextLabel")
	header.Name = tostring(p) .. "Header"
	header.LayoutOrder = layoutOrder
	header.Size = UDim2.new(1, -8, 0, 28)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.Text = tostring(p)
	header.TextColor3 = Color3.fromRGB(210, 218, 230)
	header.TextSize = 13
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = self.List
	return header
end

function LightingSettingsCategoryController:SelectPreset(p, p2)
	self:MarkLocalChange()
	self.Settings.UseCustom = true
	self.Settings.SelectedPresetId = tostring(p)
	self.Settings.Current = LightingSettingsConfig.SanitizeData(p2)
	self:ApplyLocal()
	self:Render()
	self:Save(true)
end

function LightingSettingsCategoryController:ToggleCustom()
	self:MarkLocalChange()
	self.Settings.UseCustom = not self.Settings.UseCustom
	self:ApplyLocal()
	self:Render()
	self:Save(true)
end

function LightingSettingsCategoryController:CreatePreset(p)
	if #self.Settings.CustomPresets >= LightingSettingsConfig.MAX_CUSTOM_PRESETS then
		self:Notify(
			"Lighting",
			"You can only save " .. tostring(LightingSettingsConfig.MAX_CUSTOM_PRESETS) .. " lighting presets.",
			3
		)
		return
	end

	self:MarkLocalChange()
	local v4 = {
		Id = "custom_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999)),
		Name = cleanPresetName(p, self:GetSuggestedPresetName()),
		Data = LightingSettingsConfig.SanitizeData(self.Settings.Current)
	}

	table.insert(self.Settings.CustomPresets, v4)
	self.Settings.SelectedPresetId = v4.Id
	self.Settings.UseCustom = true
	self:ApplyLocal()
	self:Render()
	self:Save(true)
end

function LightingSettingsCategoryController:DeletePreset(p)
	self:MarkLocalChange()

	for i, customPreset in ipairs(self.Settings.CustomPresets) do
		if customPreset.Id == p then
			table.remove(self.Settings.CustomPresets, i)
			break
		end
	end

	if self.Settings.SelectedPresetId == p then
		local builtInPresetData = LightingSettingsConfig.GetBuiltInPresetData(LightingSettingsConfig.DEFAULT_PRESET_ID)
		self.Settings.SelectedPresetId = LightingSettingsConfig.DEFAULT_PRESET_ID
		self.Settings.Current = builtInPresetData
	end

	self:ApplyLocal()
	self:Render()
	self:Save(true)
end

function LightingSettingsCategoryController:AdjustField(data, p)
	local v4 = self.Settings.Current[data.Group]

	if not v4 then
		return
	end

	self:MarkLocalChange()
	local v5 = tonumber(v4[data.Key]) or 0
	v4[data.Key] = math.clamp(v5 + (data.Step or 1) * p, data.Min, data.Max)
	self.Settings.UseCustom = true
	self.Settings.SelectedPresetId = LightingSettingsConfig.CUSTOM_PRESET_ID
	self:ApplyLocal()
	self:Render()
	self:Save(true)
end

function LightingSettingsCategoryController:ToggleField(p)
	local v4 = self.Settings.Current[p.Group]

	if not v4 then
		return
	end

	self:MarkLocalChange()
	v4[p.Key] = v4[p.Key] ~= true
	self.Settings.UseCustom = true
	self.Settings.SelectedPresetId = LightingSettingsConfig.CUSTOM_PRESET_ID
	self:ApplyLocal()
	self:Render()
	self:Save(true)
end

function LightingSettingsCategoryController:SetColorField(data, value, p)
	local hexTexts = self.Settings.Current[data.Group]

	if not hexTexts then
		return nil
	end

	self:MarkLocalChange()
	local hexText = normalizeHexText(value, data.Default or "#FFFFFF") -- inferred equivalent call
	hexTexts[data.Key] = hexText
	self.Settings.UseCustom = true
	self.Settings.SelectedPresetId = LightingSettingsConfig.CUSTOM_PRESET_ID
	self:ApplyLocal()
	local child = self.List and self.List:FindFirstChild(tostring(data.Group) .. tostring(data.Key) .. "Row")
	local swatch = child and child:FindFirstChild("Swatch")

	if swatch and swatch:IsA("GuiObject") then
		swatch.BackgroundColor3 = hexToColor3(hexText, data.Default)
	end

	if p then
		self:Save(true)
	end

	return hexText
end

function LightingSettingsCategoryController:UpdateColorPickerPanel(value, p)
	local colorPickerPanel = self.ColorPickerPanel

	if not colorPickerPanel then
		return
	end

	local hexText = normalizeHexText(value, self.ActiveColorField and self.ActiveColorField.Default or "#FFFFFF") -- inferred equivalent call
	self.ActiveColorHex = hexText
	local backgroundColor = hexToColor3(hexText)
	local preview = colorPickerPanel:FindFirstChild("Preview")
	local hexBox = colorPickerPanel:FindFirstChild("HexBox")
	local wheel = colorPickerPanel:FindFirstChild("Wheel")
	local picker = wheel and wheel:FindFirstChild("Picker")

	if preview and preview:IsA("GuiObject") then
		preview.BackgroundColor3 = backgroundColor
	end

	if hexBox and hexBox:IsA("TextBox") and hexBox.Text ~= hexText then
		hexBox.Text = hexText
	end

	if wheel and picker then
		task.defer(function()
			if wheel.Parent and picker.Parent then
				setWheelPickerFromColor(wheel, picker, backgroundColor)
			end
		end)
	end

	if p and self.ActiveColorField then
		self:SetColorField(self.ActiveColorField, hexText, false)
	end
end

function LightingSettingsCategoryController:EnsureColorPickerPanel()
	if self.ColorPickerPanel and self.ColorPickerPanel.Parent then
		return self.ColorPickerPanel
	end

	local lightingColorPickerPanel = Instance.new("Frame")
	lightingColorPickerPanel.Name = "LightingColorPickerPanel"
	lightingColorPickerPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	lightingColorPickerPanel.Position = UDim2.fromScale(0.5, 0.5)
	lightingColorPickerPanel.Size = UDim2.new(1, -24, 0, 260)
	lightingColorPickerPanel.BackgroundColor3 = Color3.fromRGB(30, 35, 42)
	lightingColorPickerPanel.BorderSizePixel = 0
	lightingColorPickerPanel.Visible = false
	lightingColorPickerPanel.Parent = self.Frame
	ensureCorner(lightingColorPickerPanel, 8)
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(420, 280)
	uiSizeConstraint.Parent = lightingColorPickerPanel
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(76, 91, 110)
	uiStroke.Thickness = 1
	uiStroke.Parent = lightingColorPickerPanel

	createText(
		lightingColorPickerPanel,
		"Title",
		"Color",
		Enum.Font.GothamBold,
		18,
		Color3.fromRGB(245, 248, 255),
		UDim2.fromOffset(16, 10),
		UDim2.new(1, -58, 0, 28)
	)
	local close = lightingColorPickerPanel:FindFirstChild("Close")

	if close and not close:IsA("ImageButton") then
		close:Destroy()
		close = nil
	end

	local close2 = close or Instance.new("ImageButton")
	close2.Name = "Close"
	close2.AnchorPoint = Vector2.new(1, 0.5)
	close2.Position = UDim2.new(1, -14, 0, 24)
	close2.Size = UDim2.fromOffset(34, 34)
	close2.BackgroundTransparency = 1
	close2.BorderSizePixel = 0
	close2.AutoButtonColor = true
	close2.Image = "rbxassetid://6031094678"
	close2.ImageColor3 = Color3.fromRGB(255, 255, 255)
	close2.ImageTransparency = 0
	close2.ScaleType = Enum.ScaleType.Fit
	close2.Parent = lightingColorPickerPanel
	local uiCorner = close2:FindFirstChildOfClass("UICorner")

	if uiCorner then
		uiCorner:Destroy()
	end

	local wheel = Instance.new("ImageButton")
	wheel.Name = "Wheel"
	wheel.Image = "rbxassetid://6020299385"
	wheel.BackgroundTransparency = 1
	wheel.Position = UDim2.fromOffset(16, 54)
	wheel.Size = UDim2.fromOffset(132, 132)
	wheel.ScaleType = Enum.ScaleType.Fit
	wheel.AutoButtonColor = false
	wheel.Parent = lightingColorPickerPanel
	local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uiAspectRatioConstraint.AspectRatio = 1
	uiAspectRatioConstraint.Parent = wheel
	local picker = Instance.new("Frame")
	picker.Name = "Picker"
	picker.AnchorPoint = Vector2.new(0.5, 0.5)
	picker.Size = UDim2.fromOffset(14, 14)
	picker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	picker.BorderSizePixel = 0
	picker.Parent = wheel
	ensureCorner(picker, 7)
	local uiStroke2 = Instance.new("UIStroke")
	uiStroke2.Color = Color3.fromRGB(25, 30, 36)
	uiStroke2.Thickness = 2
	uiStroke2.Parent = picker

	createText(
		lightingColorPickerPanel,
		"PreviewLabel",
		"Preview",
		Enum.Font.GothamBold,
		13,
		color4,
		UDim2.new(0, 168, 0, 58),
		UDim2.new(1, -184, 0, 20)
	)
	local preview = Instance.new("Frame")
	preview.Name = "Preview"
	preview.Position = UDim2.new(0, 168, 0, 82)
	preview.Size = UDim2.new(1, -188, 0, 42)
	preview.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	preview.BorderSizePixel = 0
	preview.Parent = lightingColorPickerPanel
	ensureCorner(preview, 8)
	local hexBox = Instance.new("TextBox")
	hexBox.Name = "HexBox"
	hexBox.Position = UDim2.new(0, 168, 0, 134)
	hexBox.Size = UDim2.new(1, -188, 0, 34)
	hexBox.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
	hexBox.BorderSizePixel = 0
	hexBox.ClearTextOnFocus = false
	hexBox.Font = Enum.Font.GothamBold
	hexBox.Text = "#FFFFFF"
	hexBox.TextColor3 = Color3.fromRGB(240, 244, 252)
	hexBox.PlaceholderText = "#FFFFFF"
	hexBox.TextSize = 14
	hexBox.Parent = lightingColorPickerPanel
	ensureCorner(hexBox, 8)
	local button = createButton(
		lightingColorPickerPanel,
		"Apply",
		"Apply",
		UDim2.new(1, -16, 1, -24),
		UDim2.fromOffset(116, 36),
		Color3.fromRGB(54, 196, 104)
	)

	local inputChangedConnection = nil
	local inputEndedConnection = nil
	local function disconnectDrag() -- 2 equivalent calls inferred from this helper
		if inputChangedConnection then
			inputChangedConnection:Disconnect()
			inputChangedConnection = nil
		end

		if inputEndedConnection then
			inputEndedConnection:Disconnect()
			inputEndedConnection = nil
		end
	end
	local function updateFromInput(p) -- 2 equivalent calls inferred from this helper
		self:UpdateColorPickerPanel(color3ToHex(getWheelColorFromInput(wheel, p)), true) -- inferred equivalent call
	end
	local function beginDrag(p)
		if p.UserInputType ~= Enum.UserInputType.MouseButton1 and p.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		safeClick() -- inferred equivalent call
		disconnectDrag() -- inferred equivalent call
		updateFromInput(p) -- inferred equivalent call
		inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			then
				updateFromInput(input) -- inferred equivalent call
			end
		end)
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				disconnectDrag() -- inferred equivalent call
			end
		end)
	end
	wheel.InputBegan:Connect(beginDrag)
	hexBox.FocusLost:Connect(function()
		self:UpdateColorPickerPanel(hexBox.Text, true)
	end)
	close2.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		lightingColorPickerPanel.Visible = false
		self.ActiveColorField = nil
	end)
	button.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call

		if self.ActiveColorField then
			self:SetColorField(self.ActiveColorField, self.ActiveColorHex, false)
			lightingColorPickerPanel.Visible = false
			self.ActiveColorField = nil
			self:Render()
			self:Save(true)
		end
	end)
	setZIndexRecursive(lightingColorPickerPanel, 240)
	self.ColorPickerPanel = lightingColorPickerPanel
	return lightingColorPickerPanel
end

function LightingSettingsCategoryController:OpenColorPicker(activeColorField)
	self.Settings = LightingSettingsConfig.SanitizeSettings(self.Settings)

	if self.DeletePresetPanel then
		self.DeletePresetPanel.Visible = false
	end

	local colorPickerPanel = self:EnsureColorPickerPanel()
	self.ActiveColorField = activeColorField
	local title = colorPickerPanel:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Text = tostring(activeColorField.Label or activeColorField.Key)
	end

	self:UpdateColorPickerPanel(
		(self.Settings.Current[activeColorField.Group] or {})[activeColorField.Key] or activeColorField.Default,
		false
	)
	colorPickerPanel.Visible = true
end

function LightingSettingsCategoryController:RenderColorField(data, p)
	local hexText = normalizeHexText((self.Settings.Current[data.Group] or {})[data.Key], data.Default) -- inferred equivalent call
	local row = self:CreateRow(data.Label or data.Key, data.Group, p, 54, tostring(data.Group) .. tostring(data.Key))
	local swatch = row:FindFirstChild("Swatch") or Instance.new("TextButton")
	swatch.Name = "Swatch"
	swatch.Text = ""
	swatch.AnchorPoint = Vector2.new(1, 0.5)
	swatch.Position = UDim2.new(1, -12, 0.5, 0)
	swatch.Size = UDim2.fromOffset(96, 34)
	swatch.BackgroundColor3 = hexToColor3(hexText, data.Default)
	swatch.BorderSizePixel = 0
	swatch.AutoButtonColor = true
	swatch.Parent = row
	ensureCorner(swatch, 8)
	local uiStroke = swatch:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(210, 218, 230)
	uiStroke.Transparency = 0.25
	uiStroke.Thickness = 1
	uiStroke.Parent = swatch
	swatch.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:OpenColorPicker(data)
	end)
end

function LightingSettingsCategoryController:GetSuggestedPresetName()
	local nameSet = {}

	for _, customPreset in ipairs(self.Settings.CustomPresets) do
		nameSet[customPreset.Name] = true
	end

	local v4 = 1

	while nameSet["My Preset " .. tostring(v4)] do
		v4 += 1
	end

	return "My Preset " .. tostring(v4)
end

function LightingSettingsCategoryController:BuildExportText()
	self.Settings = LightingSettingsConfig.SanitizeSettings(self.Settings)
	local v4 = {
		name = "Custom Lighting",
		fogHaze = self:GetMapAtmosphereEnabled(),
		data = LightingSettingsConfig.SanitizeData(self.Settings.Current)
	}

	local success2, result2 = pcall(function()
		return HttpService:JSONEncode(v4)
	end)

	if success2 then
		return "DP-LIGHTING:" .. result2
	end

	return "DP-LIGHTING:{}"
end

function LightingSettingsCategoryController:ParseImportText(value)
	local v4 = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local v5

	if v4:sub(1, 12) == "DP-LIGHTING:" then
		v5 = "DP-LIGHTING:"
	else
		for _, v6 in ipairs(v) do
			if v4:sub(1, #v6) == v6 then
				v5 = v6
				break
			end
		end

		if not v5 then
			return nil, "Paste a valid DP-LIGHTING export code."
		end
	end

	local v6 = v4:sub(#v5 + 1)
	local success2, result2 = pcall(function()
		return HttpService:JSONDecode(v6)
	end)

	if not success2 or type(result2) ~= "table" then
		return nil, "That lighting code could not be read."
	end

	local data = result2.data or result2.Data

	if type(data) ~= "table" then
		return nil, "That lighting code is missing lighting data."
	end

	local fogHaze = nil

	if typeof(result2.fogHaze) == "boolean" then
		fogHaze = result2.fogHaze
	elseif typeof(result2.FogHaze) == "boolean" then
		fogHaze = result2.FogHaze
	end

	return {
		Name = cleanPresetName(result2.name or result2.Name, "Imported Lighting"),
		FogHaze = fogHaze,
		Data = LightingSettingsConfig.SanitizeData(data)
	}
end

function LightingSettingsCategoryController:ApplyImportedText(p): boolean
	local importText, v4 = self:ParseImportText(p)

	if not importText then
		self:Notify("Lighting Import", v4, 3)
		return false
	end

	self:MarkLocalChange()
	self.Settings.UseCustom = true
	self.Settings.SelectedPresetId = LightingSettingsConfig.CUSTOM_PRESET_ID
	self.Settings.Current = importText.Data

	if importText.FogHaze ~= nil then
		self:SetMapAtmosphereEnabled(importText.FogHaze, true)
	end

	self:ApplyLocal()
	self:Render()
	self:Save(true)
	self:Notify("Lighting Import", "Imported " .. tostring(importText.Name) .. ".", 3)
	return true
end

function LightingSettingsCategoryController:EnsurePresetNamePanel()
	if self.PresetNamePanel and self.PresetNamePanel.Parent then
		return self.PresetNamePanel
	end

	local presetNamePanel = Instance.new("Frame")
	presetNamePanel.Name = "PresetNamePanel"
	presetNamePanel.AnchorPoint = Vector2.new(0.5, 0.5)
	presetNamePanel.Position = UDim2.fromScale(0.5, 0.5)
	presetNamePanel.Size = UDim2.new(1, -24, 0, 166)
	presetNamePanel.BackgroundColor3 = Color3.fromRGB(30, 35, 42)
	presetNamePanel.BorderSizePixel = 0
	presetNamePanel.Visible = false
	presetNamePanel.Parent = self.Frame
	ensureCorner(presetNamePanel, 8)
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(420, 190)
	uiSizeConstraint.Parent = presetNamePanel
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(76, 91, 110)
	uiStroke.Thickness = 1
	uiStroke.Parent = presetNamePanel
	createText(
		presetNamePanel,
		"Title",
		"Save Lighting Preset",
		Enum.Font.GothamBold,
		18,
		Color3.fromRGB(245, 248, 255),
		UDim2.fromOffset(16, 12),
		UDim2.new(1, -32, 0, 26)
	)
	local nameBox = Instance.new("TextBox")
	nameBox.Name = "NameBox"
	nameBox.Position = UDim2.fromOffset(16, 54)
	nameBox.Size = UDim2.new(1, -32, 0, 38)
	nameBox.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
	nameBox.BorderSizePixel = 0
	nameBox.ClearTextOnFocus = false
	nameBox.Font = Enum.Font.GothamBold
	nameBox.PlaceholderText = "Preset name"
	nameBox.TextColor3 = Color3.fromRGB(240, 244, 252)
	nameBox.PlaceholderColor3 = color4
	nameBox.TextSize = 14
	nameBox.Parent = presetNamePanel
	ensureCorner(nameBox, 8)
	local button = createButton(
		presetNamePanel,
		"Cancel",
		"Cancel",
		UDim2.new(1, -144, 1, -24),
		UDim2.fromOffset(112, 36),
		color2
	)
	local button2 = createButton(
		presetNamePanel,
		"Save",
		"Save",
		UDim2.new(1, -16, 1, -24),
		UDim2.fromOffset(112, 36),
		Color3.fromRGB(54, 196, 104)
	)
	button.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		presetNamePanel.Visible = false
	end)
	button2.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		presetNamePanel.Visible = false
		self:CreatePreset(nameBox.Text)
	end)
	nameBox.FocusLost:Connect(function(p)
		if p and presetNamePanel.Visible then
			presetNamePanel.Visible = false
			self:CreatePreset(nameBox.Text)
		end
	end)
	setZIndexRecursive(presetNamePanel, 240)
	self.PresetNamePanel = presetNamePanel
	return presetNamePanel
end

function LightingSettingsCategoryController:OpenPresetNamePanel()
	if #self.Settings.CustomPresets >= LightingSettingsConfig.MAX_CUSTOM_PRESETS then
		self:Notify(
			"Lighting",
			"You can only save " .. tostring(LightingSettingsConfig.MAX_CUSTOM_PRESETS) .. " lighting presets.",
			3
		)
		return
	end

	if self.DeletePresetPanel then
		self.DeletePresetPanel.Visible = false
	end

	if self.ExportPanel then
		self.ExportPanel.Visible = false
	end

	if self.ImportPanel then
		self.ImportPanel.Visible = false
	end

	if self.ColorPickerPanel then
		self.ColorPickerPanel.Visible = false
	end

	local presetNamePanel = self:EnsurePresetNamePanel()
	local nameBox = presetNamePanel:FindFirstChild("NameBox")

	if nameBox and nameBox:IsA("TextBox") then
		nameBox.Text = self:GetSuggestedPresetName()
		task.defer(function()
			if nameBox.Parent and presetNamePanel.Visible then
				pcall(function()
					nameBox:CaptureFocus()
				end)
			end
		end)
	end

	presetNamePanel.Visible = true
end

function LightingSettingsCategoryController:EnsureDeletePresetPanel()
	if self.DeletePresetPanel and self.DeletePresetPanel.Parent then
		return self.DeletePresetPanel
	end

	local lightingDeletePresetPanel = Instance.new("Frame")
	lightingDeletePresetPanel.Name = "LightingDeletePresetPanel"
	lightingDeletePresetPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	lightingDeletePresetPanel.Position = UDim2.fromScale(0.5, 0.5)
	lightingDeletePresetPanel.Size = UDim2.new(1, -24, 0, 174)
	lightingDeletePresetPanel.BackgroundColor3 = Color3.fromRGB(30, 35, 42)
	lightingDeletePresetPanel.BorderSizePixel = 0
	lightingDeletePresetPanel.Visible = false
	lightingDeletePresetPanel.Parent = self.Frame
	ensureCorner(lightingDeletePresetPanel, 8)
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(440, 198)
	uiSizeConstraint.Parent = lightingDeletePresetPanel
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(76, 91, 110)
	uiStroke.Thickness = 1
	uiStroke.Parent = lightingDeletePresetPanel
	createText(
		lightingDeletePresetPanel,
		"Title",
		"Delete Preset?",
		Enum.Font.GothamBold,
		18,
		Color3.fromRGB(245, 248, 255),
		UDim2.fromOffset(16, 12),
		UDim2.new(1, -32, 0, 26)
	)
	local text = createText(
		lightingDeletePresetPanel,
		"Message",
		"This cannot be undone.",
		Enum.Font.Gotham,
		13,
		color4,
		UDim2.fromOffset(16, 48),
		UDim2.new(1, -32, 0, 46)
	)
	text.TextWrapped = true
	text.TextTruncate = Enum.TextTruncate.None
	text.TextYAlignment = Enum.TextYAlignment.Top
	local button = createButton(
		lightingDeletePresetPanel,
		"Cancel",
		"Cancel",
		UDim2.new(1, -144, 1, -24),
		UDim2.fromOffset(112, 36),
		color2
	)
	local button2 = createButton(
		lightingDeletePresetPanel,
		"Delete",
		"Delete",
		UDim2.new(1, -16, 1, -24),
		UDim2.fromOffset(112, 36),
		Color3.fromRGB(185, 45, 55)
	)
	button.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self.PendingDeletePresetId = nil
		self.PendingDeletePresetName = nil
		lightingDeletePresetPanel.Visible = false
	end)
	button2.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		local pendingDeletePresetId = self.PendingDeletePresetId
		self.PendingDeletePresetId = nil
		self.PendingDeletePresetName = nil
		lightingDeletePresetPanel.Visible = false

		if pendingDeletePresetId then
			self:DeletePreset(pendingDeletePresetId)
		end
	end)
	setZIndexRecursive(lightingDeletePresetPanel, 250)
	self.DeletePresetPanel = lightingDeletePresetPanel
	return lightingDeletePresetPanel
end

function LightingSettingsCategoryController:OpenDeletePresetPanel(value, p)
	if self.ExportPanel then
		self.ExportPanel.Visible = false
	end

	if self.ImportPanel then
		self.ImportPanel.Visible = false
	end

	if self.PresetNamePanel then
		self.PresetNamePanel.Visible = false
	end

	if self.ColorPickerPanel then
		self.ColorPickerPanel.Visible = false
	end

	self.PendingDeletePresetId = tostring(value or "")
	self.PendingDeletePresetName = cleanPresetName(p, "this preset")
	local deletePresetPanel = self:EnsureDeletePresetPanel()
	local message = deletePresetPanel:FindFirstChild("Message")

	if message and message:IsA("TextLabel") then
		message.Text = "Delete \"" .. self.PendingDeletePresetName .. "\"? This cannot be undone."
	end

	deletePresetPanel.Visible = true
end

function LightingSettingsCategoryController:EnsureExportPanel()
	if self.ExportPanel and self.ExportPanel.Parent then
		return self.ExportPanel
	end

	local lightingExportPanel = Instance.new("Frame")
	lightingExportPanel.Name = "LightingExportPanel"
	lightingExportPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	lightingExportPanel.Position = UDim2.fromScale(0.5, 0.5)
	lightingExportPanel.Size = UDim2.new(1, -24, 0, 230)
	lightingExportPanel.BackgroundColor3 = Color3.fromRGB(30, 35, 42)
	lightingExportPanel.BorderSizePixel = 0
	lightingExportPanel.Visible = false
	lightingExportPanel.Parent = self.Frame
	ensureCorner(lightingExportPanel, 8)
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(520, 250)
	uiSizeConstraint.Parent = lightingExportPanel
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(76, 91, 110)
	uiStroke.Thickness = 1
	uiStroke.Parent = lightingExportPanel
	createText(
		lightingExportPanel,
		"Title",
		"Export Lighting",
		Enum.Font.GothamBold,
		18,
		Color3.fromRGB(245, 248, 255),
		UDim2.fromOffset(16, 12),
		UDim2.new(1, -32, 0, 26)
	)
	createText(
		lightingExportPanel,
		"Hint",
		"Select the code and copy it.",
		Enum.Font.Gotham,
		12,
		color4,
		UDim2.fromOffset(16, 42),
		UDim2.new(1, -32, 0, 20)
	)
	local exportBox = Instance.new("TextBox")
	exportBox.Name = "ExportBox"
	exportBox.Position = UDim2.fromOffset(16, 68)
	exportBox.Size = UDim2.new(1, -32, 0, 104)
	exportBox.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
	exportBox.BorderSizePixel = 0
	exportBox.ClearTextOnFocus = false
	exportBox.Font = Enum.Font.Code
	exportBox.MultiLine = true
	exportBox.Text = ""
	exportBox.TextColor3 = Color3.fromRGB(235, 240, 248)
	exportBox.PlaceholderColor3 = color4
	exportBox.TextSize = 12
	exportBox.TextWrapped = true
	exportBox.TextXAlignment = Enum.TextXAlignment.Left
	exportBox.TextYAlignment = Enum.TextYAlignment.Top
	exportBox.Parent = lightingExportPanel
	ensureCorner(exportBox, 8)
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.PaddingBottom = UDim.new(0, 8)
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 8)
	uiPadding.Parent = exportBox
	local button = createButton(
		lightingExportPanel,
		"Close",
		"Close",
		UDim2.new(1, -16, 1, -24),
		UDim2.fromOffset(112, 36),
		color2
	)

	local function selectText() -- 1 equivalent call inferred from this helper
		pcall(function()
			exportBox:CaptureFocus()
			exportBox.SelectionStart = 1
			exportBox.CursorPosition = #exportBox.Text + 1
		end)
	end

	createButton(lightingExportPanel, "Select", "Select", UDim2.new(1, -144, 1, -24), UDim2.fromOffset(112, 36), color).MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		selectText() -- inferred equivalent call
	end)
	button.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		lightingExportPanel.Visible = false
	end)
	setZIndexRecursive(lightingExportPanel, 250)
	self.ExportPanel = lightingExportPanel
	return lightingExportPanel
end

function LightingSettingsCategoryController:OpenExportPanel()
	if self.DeletePresetPanel then
		self.DeletePresetPanel.Visible = false
	end

	if self.ImportPanel then
		self.ImportPanel.Visible = false
	end

	if self.PresetNamePanel then
		self.PresetNamePanel.Visible = false
	end

	if self.ColorPickerPanel then
		self.ColorPickerPanel.Visible = false
	end

	local exportPanel = self:EnsureExportPanel()
	local exportBox = exportPanel:FindFirstChild("ExportBox")

	if exportBox and exportBox:IsA("TextBox") then
		exportBox.Text = self:BuildExportText()
		task.defer(function()
			if exportBox.Parent and exportPanel.Visible then
				pcall(function()
					exportBox:CaptureFocus()
					exportBox.SelectionStart = 1
					exportBox.CursorPosition = #exportBox.Text + 1
				end)
			end
		end)
	end

	exportPanel.Visible = true
end

function LightingSettingsCategoryController:EnsureImportPanel()
	if self.ImportPanel and self.ImportPanel.Parent then
		return self.ImportPanel
	end

	local lightingImportPanel = Instance.new("Frame")
	lightingImportPanel.Name = "LightingImportPanel"
	lightingImportPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	lightingImportPanel.Position = UDim2.fromScale(0.5, 0.5)
	lightingImportPanel.Size = UDim2.new(1, -24, 0, 260)
	lightingImportPanel.BackgroundColor3 = Color3.fromRGB(30, 35, 42)
	lightingImportPanel.BorderSizePixel = 0
	lightingImportPanel.Visible = false
	lightingImportPanel.Parent = self.Frame
	ensureCorner(lightingImportPanel, 8)
	local uiSizeConstraint = Instance.new("UISizeConstraint")
	uiSizeConstraint.MaxSize = Vector2.new(520, 280)
	uiSizeConstraint.Parent = lightingImportPanel
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(76, 91, 110)
	uiStroke.Thickness = 1
	uiStroke.Parent = lightingImportPanel
	createText(
		lightingImportPanel,
		"Title",
		"Import Lighting",
		Enum.Font.GothamBold,
		18,
		Color3.fromRGB(245, 248, 255),
		UDim2.fromOffset(16, 12),
		UDim2.new(1, -32, 0, 26)
	)
	createText(
		lightingImportPanel,
		"Hint",
		"Paste a DP-LIGHTING code.",
		Enum.Font.Gotham,
		12,
		color4,
		UDim2.fromOffset(16, 42),
		UDim2.new(1, -32, 0, 20)
	)
	local importBox = Instance.new("TextBox")
	importBox.Name = "ImportBox"
	importBox.Position = UDim2.fromOffset(16, 68)
	importBox.Size = UDim2.new(1, -32, 0, 132)
	importBox.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
	importBox.BorderSizePixel = 0
	importBox.ClearTextOnFocus = false
	importBox.Font = Enum.Font.Code
	importBox.MultiLine = true
	importBox.PlaceholderText = "DP-LIGHTING:..."
	importBox.Text = ""
	importBox.TextColor3 = Color3.fromRGB(235, 240, 248)
	importBox.PlaceholderColor3 = color4
	importBox.TextSize = 12
	importBox.TextWrapped = true
	importBox.TextXAlignment = Enum.TextXAlignment.Left
	importBox.TextYAlignment = Enum.TextYAlignment.Top
	importBox.Parent = lightingImportPanel
	ensureCorner(importBox, 8)
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.PaddingBottom = UDim.new(0, 8)
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 8)
	uiPadding.Parent = importBox
	local button = createButton(
		lightingImportPanel,
		"Cancel",
		"Cancel",
		UDim2.new(1, -144, 1, -24),
		UDim2.fromOffset(112, 36),
		color2
	)
	local button2 = createButton(
		lightingImportPanel,
		"Apply",
		"Apply",
		UDim2.new(1, -16, 1, -24),
		UDim2.fromOffset(112, 36),
		Color3.fromRGB(54, 196, 104)
	)
	button.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		lightingImportPanel.Visible = false
	end)
	button2.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call

		if self:ApplyImportedText(importBox.Text) then
			lightingImportPanel.Visible = false
		end
	end)
	setZIndexRecursive(lightingImportPanel, 250)
	self.ImportPanel = lightingImportPanel
	return lightingImportPanel
end

function LightingSettingsCategoryController:OpenImportPanel()
	if self.DeletePresetPanel then
		self.DeletePresetPanel.Visible = false
	end

	if self.ExportPanel then
		self.ExportPanel.Visible = false
	end

	if self.PresetNamePanel then
		self.PresetNamePanel.Visible = false
	end

	if self.ColorPickerPanel then
		self.ColorPickerPanel.Visible = false
	end

	local importPanel = self:EnsureImportPanel()
	local importBox = importPanel:FindFirstChild("ImportBox")

	if importBox and importBox:IsA("TextBox") then
		importBox.Text = ""
		task.defer(function()
			if importBox.Parent and importPanel.Visible then
				pcall(function()
					importBox:CaptureFocus()
				end)
			end
		end)
	end

	importPanel.Visible = true
end

function LightingSettingsCategoryController:SetNumberField(data, p)
	local v4 = self.Settings.Current[data.Group]

	if not v4 then
		return nil
	end

	local min = tonumber(data.Min) or 0
	local max = tonumber(data.Max) or min
	local step = tonumber(data.Step) or 0
	self:MarkLocalChange()
	local v5 = tonumber(p) or min

	if step > 0 then
		v5 = min + math.floor((v5 - min) / step + 0.5) * step
	end

	local v6 = math.clamp(v5, min, max)
	v4[data.Key] = v6
	self.Settings.UseCustom = true
	self.Settings.SelectedPresetId = LightingSettingsConfig.CUSTOM_PRESET_ID
	self:ApplyLocal()
	return v6
end

function LightingSettingsCategoryController:UpdateSliderVisual(data, p, p2, p3, p4)
	local min = tonumber(data.Min) or 0
	local max = tonumber(data.Max) or min
	local v4 = tonumber(p4) or min
	local v5 = min < max and math.clamp((v4 - min) / (max - min), 0, 1) or 0
	p.Text = formatNumber(v4, data.Decimals)
	p2.Size = UDim2.new(v5, 0, 1, 0)
	p3.Position = UDim2.new(v5, 0, 0.5, 0)
end

function LightingSettingsCategoryController:SetSliderFromInput(p, p2, p3, p4, p5, p6)
	local min = tonumber(p.Min) or 0
	local max = tonumber(p.Max) or min
	local v4 = math.max(p2.AbsoluteSize.X, 1)
	local v5 = math.clamp((p6.Position.X - p2.AbsolutePosition.X) / v4, 0, 1)
	local v6 = self:SetNumberField(p, min + (max - min) * v5)

	if v6 ~= nil then
		self:UpdateSliderVisual(p, p3, p4, p5, v6)
	end
end

function LightingSettingsCategoryController:RenderBooleanField(data, p)
	local v4 = (self.Settings.Current[data.Group] or {})[data.Key] == true
	createButton(
		self:CreateRow(data.Label, data.Group, p, 54, tostring(data.Group) .. tostring(data.Key)),
		"Action",
		v4 and "ON" or "OFF",
		UDim2.new(1, -12, 0.5, 0),
		UDim2.new(0, 96, 0, 32),
		v4 and color or color2
	).MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:ToggleField(data)
	end)
end

function LightingSettingsCategoryController:RenderMapAtmosphereField(p)
	local mapAtmosphereEnabled = self:GetMapAtmosphereEnabled()
	createButton(
		self:CreateRow("Fog / Haze", "Map atmosphere, fog, and haze.", p, 54, "MapAtmosphere"),
		"Action",
		mapAtmosphereEnabled and "ON" or "OFF",
		UDim2.new(1, -12, 0.5, 0),
		UDim2.new(0, 96, 0, 32),
		mapAtmosphereEnabled and color or color2
	).MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:SetMapAtmosphereEnabled(not mapAtmosphereEnabled)
	end)
end

function LightingSettingsCategoryController:RenderNumberField(data, p)
	local v4 = tonumber((self.Settings.Current[data.Group] or {})[data.Key]) or 0
	local row = self:CreateRow(data.Label, data.Group, p, 76, tostring(data.Group) .. tostring(data.Key))
	local text = createText(
		row,
		"Value",
		formatNumber(v4, data.Decimals),
		Enum.Font.GothamBold,
		13,
		Color3.fromRGB(235, 238, 245),
		UDim2.new(1, -96, 0, 8),
		UDim2.new(0, 82, 0, 22)
	)
	text.TextXAlignment = Enum.TextXAlignment.Right

	local sliderTrack = row:FindFirstChild("SliderTrack") or Instance.new("TextButton")
	sliderTrack.Name = "SliderTrack"
	sliderTrack.Text = ""
	sliderTrack.AutoButtonColor = false
	sliderTrack.Active = true
	sliderTrack.AnchorPoint = Vector2.new(0, 0)
	sliderTrack.Position = UDim2.new(0, 14, 0, 56)
	sliderTrack.Size = UDim2.new(1, -28, 0, 8)
	sliderTrack.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
	sliderTrack.BorderSizePixel = 0
	sliderTrack.Parent = row
	ensureCorner(sliderTrack, 4)

	local fill = sliderTrack:FindFirstChild("Fill") or Instance.new("Frame")
	fill.Name = "Fill"
	fill.AnchorPoint = Vector2.new(0, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = sliderTrack
	ensureCorner(fill, 4)

	local knob = sliderTrack:FindFirstChild("Knob") or Instance.new("TextButton")
	knob.Name = "Knob"
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.Active = true
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.BackgroundColor3 = Color3.fromRGB(245, 247, 252)
	knob.BorderSizePixel = 0
	knob.Parent = sliderTrack
	ensureCorner(knob, 9)
	self:UpdateSliderVisual(data, text, fill, knob, v4)

	local inputChangedConnection = nil
	local inputEndedConnection = nil
	local function disconnectDrag() -- 2 equivalent calls inferred from this helper
		if inputChangedConnection then
			inputChangedConnection:Disconnect()
			inputChangedConnection = nil
		end

		if inputEndedConnection then
			inputEndedConnection:Disconnect()
			inputEndedConnection = nil
		end
	end
	local function beginDrag(p2)
		if p2.UserInputType ~= Enum.UserInputType.MouseButton1 and p2.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		safeClick() -- inferred equivalent call
		disconnectDrag() -- inferred equivalent call
		self:SetSliderFromInput(data, sliderTrack, text, fill, knob, p2)
		inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			then
				self:SetSliderFromInput(data, sliderTrack, text, fill, knob, input)
			end
		end)
		inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				disconnectDrag() -- inferred equivalent call
				self:Save(true)
			end
		end)
	end
	sliderTrack.InputBegan:Connect(beginDrag)
	knob.InputBegan:Connect(beginDrag)
end

function LightingSettingsCategoryController:Render()
	clearList(self.List)
	self.Settings = LightingSettingsConfig.SanitizeSettings(self.Settings)
	local v4 = 1
	createButton(
		self:CreateRow("Use Custom Lighting", "Overrides elevator room lighting.", v4, 58),
		"Action",
		self.Settings.UseCustom and "ON" or "OFF",
		UDim2.new(1, -12, 0.5, 0),
		UDim2.new(0, 96, 0, 32),
		self.Settings.UseCustom and color or color2
	).MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:ToggleCustom()
	end)
	local v5 = v4 + 1
	self:RenderMapAtmosphereField(v5)
	local v6 = v5 + 9

	self:CreateHeader("Presets", v6)
	local v7 = v6 + 1

	for _, builtInPreset in ipairs(LightingSettingsConfig.BuiltInPresets) do
		local v8 = self.Settings.SelectedPresetId == builtInPreset.Id
		createButton(
			self:CreateRow(builtInPreset.Name, builtInPreset.Description, v7, 58),
			"Action",
			v8 and "Selected" or "Use",
			UDim2.new(1, -12, 0.5, 0),
			UDim2.new(0, 96, 0, 32),
			v8 and color2 or color
		).MouseButton1Click:Connect(function()
			if v8 then
				return
			end

			safeClick() -- inferred equivalent call
			self:SelectPreset(builtInPreset.Id, builtInPreset.Data)
		end)
		v7 += 1
	end

	for _, customPreset in ipairs(self.Settings.CustomPresets) do
		local v8 = self.Settings.SelectedPresetId == customPreset.Id
		local row = self:CreateRow(customPreset.Name, "Saved custom preset.", v7, 58, customPreset.Id)
		createButton(
			row,
			"Delete",
			"Delete",
			UDim2.new(1, -112, 0.5, 0),
			UDim2.new(0, 78, 0, 32),
			Color3.fromRGB(185, 45, 55)
		).MouseButton1Click:Connect(function()
			safeClick() -- inferred equivalent call
			self:OpenDeletePresetPanel(customPreset.Id, customPreset.Name)
		end)
		createButton(
			row,
			"Action",
			v8 and "Selected" or "Use",
			UDim2.new(1, -12, 0.5, 0),
			UDim2.new(0, 88, 0, 32),
			v8 and color2 or color
		).MouseButton1Click:Connect(function()
			if v8 then
				return
			end

			safeClick() -- inferred equivalent call
			self:SelectPreset(customPreset.Id, customPreset.Data)
		end)
		v7 += 1
	end

	local v8 = math.max(0, LightingSettingsConfig.MAX_CUSTOM_PRESETS - #self.Settings.CustomPresets)
	createButton(
		self:CreateRow("Create New Preset", tostring(v8) .. " slot(s) left. Saves current lighting.", v7, 58),
		"Action",
		"Save",
		UDim2.new(1, -12, 0.5, 0),
		UDim2.new(0, 96, 0, 32),
		v8 > 0 and color or color2
	).MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:OpenPresetNamePanel()
	end)
	local v9 = v7 + 1
	createButton(
		self:CreateRow("Export Lighting", "Copy current lighting as a text code.", v9, 58),
		"Action",
		"Export",
		UDim2.new(1, -12, 0.5, 0),
		UDim2.new(0, 96, 0, 32),
		color
	).MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:OpenExportPanel()
	end)
	local v10 = v9 + 1
	createButton(
		self:CreateRow("Import Lighting", "Paste a shared lighting text code.", v10, 58),
		"Action",
		"Import",
		UDim2.new(1, -12, 0.5, 0),
		UDim2.new(0, 96, 0, 32),
		color
	).MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:OpenImportPanel()
	end)
	local v11 = v10 + 10

	for _, section in ipairs(LightingSettingsConfig.Sections) do
		self:CreateHeader(section.Name, v11)
		local v12 = v11 + 1

		for _, field in ipairs(section.Fields) do
			if field.Type == "boolean" then
				self:RenderBooleanField(field, v12)
			else
				self:RenderNumberField(field, v12)
			end

			v12 += 1
		end

		for _, v13 in ipairs(LightingSettingsConfig.ColorFields or {}) do
			if not colorFieldMatchesSection(v13, section.Name) then -- inferred equivalent call
				continue
			end

			self:RenderColorField(v13, v12)
			v12 += 1
		end

		v11 = v12 + 4
	end
end

function LightingSettingsCategoryController:Reset(p)
	self:MarkLocalChange()
	local copy = LightingSettingsConfig.DeepCopy(self.Settings.CustomPresets or {})
	self.Settings = LightingSettingsConfig.SanitizeSettings({
		UseCustom = false,
		SelectedPresetId = LightingSettingsConfig.DEFAULT_PRESET_ID,
		Current = LightingSettingsConfig.GetBuiltInPresetData(LightingSettingsConfig.DEFAULT_PRESET_ID),
		CustomPresets = copy
	})

	self:ApplyLocal()
	self:Render()
	self:Save(not p)
end

function LightingSettingsCategoryController:Initialize()
	local uiListLayout = self.List:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.Parent = self.List
	ensureCorner(self.List, 8)
	self.ResetButton.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:Reset()
	end)
	self:Render()
	task.spawn(function()
		self:Refresh()
	end)
end

return LightingSettingsCategoryController