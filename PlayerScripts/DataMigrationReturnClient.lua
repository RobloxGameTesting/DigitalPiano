local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData()

if
	type(localPlayerTeleportData) ~= "table"
	or localPlayerTeleportData.Migrated ~= true
	or localPlayerTeleportData.MigrationVersion ~= "DigitalPianoStatsV1"
then
	return
end

local summary = type(localPlayerTeleportData.Summary) == "table" and localPlayerTeleportData.Summary or {}
local old

if type(summary.Old) == "table" then
	old = summary.Old or nil
end

local before

if type(summary.Before) == "table" then
	before = summary.Before or nil
end

local after

if type(summary.After) == "table" then
	after = summary.After or nil
end

local function comma(p)
	local v = math.floor(tonumber(p) or 0)
	local v2 = v < 0 and "-" or ""
	local v3 = tostring((math.abs(v)))

	repeat
		local v4
		v3, v4 = v3:gsub("^(%d+)(%d%d%d)", "%1,%2")
	until v4 == 0

	return v2 .. v3
end

local function formatTime(p)
	local v = math.max(0, (math.floor(tonumber(p) or 0)))
	local v2 = math.floor(v / 86400)
	local v3 = v % 86400
	local v4 = math.floor(v3 / 3600)
	v3 %= 3600
	local v5 = math.floor(v3 / 60)

	if v2 > 0 then
		return string.format("%dd %dh %dm", v2, v4, v5)
	end

	if v4 > 0 then
		return string.format("%dh %dm", v4, v5)
	end

	if v5 > 0 then
		return string.format("%dm", v5)
	end

	return tostring(v3) .. "s"
end

local function formatStat(key, p)
	if p == nil then
		return "-"
	end

	if key == "TimePlayed" then
		return formatTime(p)
	end

	if key == "RobuxDonated" or key == "RobuxRaised" or key == "GameDonated" then
		return comma(p) .. " Robux"
	end

	if key ~= "GiftedGamepasses" then
		return comma(p)
	end

	local v = math.floor(tonumber(p) or 0)
	return comma(v) .. (v == 1 and " gamepass" or " gamepasses")
end

local v = {
	{ Key = "TimePlayed", Label = "Time Played" },
	{ Key = "RobuxDonated", Label = "Player Donated" },
	{ Key = "RobuxRaised", Label = "Robux Raised" },
	{ Key = "GameDonated", Label = "Game Donated" },
	{ Key = "GiftedGamepasses", Label = "Gifted Gamepasses" }
}

local function getViewportSize() -- 1 equivalent call inferred from this helper
	local currentCamera = Workspace.CurrentCamera
	return currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
end

local function getNumberAttribute(instance, attributeName, p) -- 10 equivalent calls inferred from this helper
	local attribute = instance and instance:GetAttribute(attributeName)
	return typeof(attribute) == "number" and attribute or p
end

local function child(instance, childName, className)
	local child2 = instance and instance:FindFirstChild(childName)

	if not child2 then
		warn("[DataMigrationReturnClient] Missing UI object: " .. tostring(childName))
		return nil
	end

	if className and not child2:IsA(className) then
		warn("[DataMigrationReturnClient] UI object " .. tostring(childName) .. " should be " .. className .. ", got " .. child2.ClassName)
		return nil
	end

	return child2
end

local dataMigrationReturnGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("DataMigrationReturnGui", 10)

if not dataMigrationReturnGui then
	warn("[DataMigrationReturnClient] StarterGui.DataMigrationReturnGui template is missing.")
	return
end

dataMigrationReturnGui.Enabled = true
dataMigrationReturnGui.IgnoreGuiInset = false
dataMigrationReturnGui.ResetOnSpawn = false
dataMigrationReturnGui.DisplayOrder = 1000
pcall(function()
	dataMigrationReturnGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
end)

local v2 = child(dataMigrationReturnGui, "Shade", "TextButton")
local v3 = v2 and child(v2, "Panel", "Frame")
local v4 = v3 and child(v3, "Title", "TextLabel")
local v5 = v3 and child(v3, "Subtitle", "TextLabel")
local v6 = v3 and child(v3, "Stats", "ScrollingFrame")
local v7 = v3 and child(v3, "Close", "TextButton")

if not (v2 and v3 and v4 and v5 and v6 and v7) then
	return
end

local panelSize = v3:FindFirstChild("PanelSize") or v3:FindFirstChildOfClass("UISizeConstraint")
local padding = v3:FindFirstChild("Padding") or v3:FindFirstChildOfClass("UIPadding")
local layout = v3:FindFirstChild("Layout") or v3:FindFirstChildOfClass("UIListLayout")
local layout2 = v6:FindFirstChild("Layout") or v6:FindFirstChildOfClass("UIListLayout")

if not (panelSize and padding and layout and layout2) then
	warn("[DataMigrationReturnClient] Return UI is missing layout helpers.")
	return
end

local v8 = {}

for _, v9 in ipairs(v) do
	local row = child(v6, v9.Key, "Frame")
	local label = row and child(row, "Label", "TextLabel")
	local v10 = row and child(row, "Value", "TextLabel")
	local padding2 = row and (row:FindFirstChild("Padding") or row:FindFirstChildOfClass("UIPadding"))

	if not (row and label and v10 and padding2) then
		continue
	end

	label.Text = v9.Label

	local v11 = old and old[v9.Key]
	local v12 = before and before[v9.Key]
	local v13 = after and after[v9.Key]

	if v12 == nil or v13 == nil or v12 == v13 then
		if v11 == nil or v13 == nil then
			v10.Text = formatStat(v9.Key, v13)
		else
			v10.Text = "Transferred " .. formatStat(v9.Key, v11)
		end
	else
		v10.Text = formatStat(v9.Key, v12) .. " -> " .. formatStat(v9.Key, v13)
	end

	v8[#v8 + 1] = { Row = row, Padding = padding2, Label = label, Value = v10 }
end

v4.Text = summary.AlreadyMigrated and "Data Already Migrated" or "Data Migration Complete"
v5.Text = summary.AlreadyMigrated and "Your PianoSystem profile was already ready."
	or "Your old Digital Piano data were successfully migrated into the new System."

local function applyResponsiveLayout()
	local viewportSize = getViewportSize() -- inferred equivalent call
	local touchEnabled = UserInputService.TouchEnabled
	local numberAttribute = getNumberAttribute(dataMigrationReturnGui, "MobileBreakpoint", 760) -- inferred equivalent call
	local numberAttribute2 = getNumberAttribute(dataMigrationReturnGui, "ShortScreenBreakpoint", 560) -- inferred equivalent call
	local v9 = touchEnabled and math.min(viewportSize.X, viewportSize.Y) <= numberAttribute
	local v10 = touchEnabled and viewportSize.X > viewportSize.Y
	local v11 = viewportSize.Y < numberAttribute2 or v10
	local v12 = viewportSize.X < 640 or (v10 or v9)
	local v13 = v12 or viewportSize.X < 820 or viewportSize.Y < 620
	local numberAttribute3 = getNumberAttribute( -- inferred equivalent call
		v3,
		"DesktopMaxWidth",
		getNumberAttribute(dataMigrationReturnGui, "DesktopMaxWidth", 720) -- inferred equivalent call
	)
	local numberAttribute4 = getNumberAttribute( -- inferred equivalent call
		v3,
		"DesktopMaxHeight",
		getNumberAttribute(dataMigrationReturnGui, "DesktopMaxHeight", 540) -- inferred equivalent call
	)
	local numberAttribute5 = getNumberAttribute( -- inferred equivalent call
		v3,
		"PhoneLandscapeMaxWidth",
		getNumberAttribute(dataMigrationReturnGui, "PhoneLandscapeMaxWidth", 640) -- inferred equivalent call
	)
	local numberAttribute6 = getNumberAttribute( -- inferred equivalent call
		v3,
		"PhonePortraitMaxWidth",
		getNumberAttribute(dataMigrationReturnGui, "PhonePortraitMaxWidth", 420) -- inferred equivalent call
	)

	if v10 then
		numberAttribute6 = numberAttribute5
	elseif not v9 then
		numberAttribute6 = numberAttribute3
	end

	local v14 = math.min(numberAttribute6, (math.max(260, viewportSize.X - (v10 and 92 or v9 and 28 or 40))))
	local v15 = math.min(numberAttribute4, (math.max(240, viewportSize.Y - (v10 and 96 or v9 and 36 or 40))))
	panelSize.MaxSize = Vector2.new(v14, v15)

	v3.Position = UDim2.fromScale(0.5, v10 and 0.54 or 0.52)
	v3.Size = UDim2.fromScale(v10 and 0.76 or v9 and 0.92 or 0.88, v11 and 0.82 or v13 and 0.84 or 0.74)
	local v16 = v10 and 18 or v9 and 16 or v13 and 20 or 28
	local v17 = v10 and 14 or v11 and 14 or v13 and 18 or 24
	local v18 = v10 and 14 or v11 and 14 or v13 and 18 or 22
	padding.PaddingTop = UDim.new(0, v17)
	padding.PaddingBottom = UDim.new(0, v18)
	padding.PaddingLeft = UDim.new(0, v16)
	padding.PaddingRight = UDim.new(0, v16)
	local v19 = v10 and 7 or v11 and 8 or v13 and 10 or 12
	layout.Padding = UDim.new(0, v19)
	local v20 = v10 and 30 or v13 and 34 or 38
	local v21 = v12 and 50 or v13 and 46 or 44
	local v22 = v13 and 42 or 46
	v4.Size = UDim2.new(1, 0, 0, v20)
	v5.Size = UDim2.new(1, 0, 0, v21)
	v7.Size = UDim2.new(1, 0, 0, v22)
	local v23 = v12 and 56 or v13 and 40 or 42
	local v24 = v10 and 5 or v13 and 6 or 8
	layout2.Padding = UDim.new(0, v24)

	local v25 = #v * v23 + math.max(0, #v - 1) * v24
	local v26 = math.min(
		v25,
		(math.max(82, math.min(v15, viewportSize.Y * v3.Size.Y.Scale) - (v20 + v21 + v22 + v19 * 3 + v17 + v18)))
	)
	v6.Size = UDim2.new(1, 0, 0, v26)
	v6.ScrollBarThickness = v26 + 1 < v25 and 4 or 0

	for _, v27 in ipairs(v8) do
		v27.Row.Size = UDim2.new(1, 0, 0, v23)
		v27.Padding.PaddingLeft = UDim.new(0, v12 and 10 or 14)
		v27.Padding.PaddingRight = UDim.new(0, v12 and 10 or 14)

		if v12 then
			v27.Label.Position = UDim2.new(0, 0, 0, 4)
			v27.Label.Size = UDim2.new(1, 0, 0, 22)
			v27.Value.Position = UDim2.new(0, 0, 0, 28)
			v27.Value.Size = UDim2.new(1, 0, 0, 24)
			v27.Value.TextXAlignment = Enum.TextXAlignment.Left
			v27.Value.TextTruncate = Enum.TextTruncate.None
		else
			v27.Label.Position = UDim2.fromScale(0, 0)
			v27.Label.Size = UDim2.new(0.4, 0, 1, 0)
			v27.Value.Position = UDim2.fromScale(0.4, 0)
			v27.Value.Size = UDim2.new(0.6, 0, 1, 0)
			v27.Value.TextXAlignment = Enum.TextXAlignment.Right
			v27.Value.TextTruncate = Enum.TextTruncate.AtEnd
		end
	end
end

local CurrentCamera = Workspace.CurrentCamera

if CurrentCamera then
	CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
	end

	applyResponsiveLayout()
end)
applyResponsiveLayout()

local function close()
	TweenService:Create(v2, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(v3, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
	task.delay(0.2, function()
		dataMigrationReturnGui:Destroy()
	end)
end

v7.Activated:Connect(close)
v2.MouseButton1Click:Connect(function() end)