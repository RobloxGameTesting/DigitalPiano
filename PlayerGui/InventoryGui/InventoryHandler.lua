local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local parent = script.Parent
local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")

local function waitForRemote(childName, className, value) -- 9 equivalent calls inferred from this helper
	local selected = remotes:FindFirstChild(childName) or remotes:WaitForChild(childName, value or 6)

	if selected and selected:IsA(className) then
		return selected
	end

	ClientDebugConfig.Warn("[InventoryHandler] Missing remote " .. childName)
	return nil
end

local getInventoryData = waitForRemote("GetInventoryData", "RemoteFunction", 12) -- inferred equivalent call
local getItemStats = waitForRemote("GetItemStats", "RemoteFunction", 12) -- inferred equivalent call
local equipInventoryItem = waitForRemote("EquipInventoryItem", "RemoteFunction", 12) -- inferred equivalent call
local shopPurchasesUpdated = waitForRemote("ShopPurchasesUpdated", "RemoteEvent", 12) -- inferred equivalent call
local advancedChatTags = waitForRemote("AdvancedChatTags", "RemoteEvent") -- inferred equivalent call
local requestChatTags = waitForRemote("RequestChatTags", "RemoteFunction") -- inferred equivalent call
local updateTagPreferences = waitForRemote("UpdateTagPreferences", "RemoteEvent") -- inferred equivalent call
local requestTitles = waitForRemote("RequestTitles", "RemoteFunction") -- inferred equivalent call
local updateTitlePreferences = waitForRemote("UpdateTitlePreferences", "RemoteEvent") -- inferred equivalent call

local function invokeRemote(object, value, ...)
	if not object then
		return false
	end

	local v = table.pack(...)
	local v2 = nil
	local flag = false
	task.spawn(function()
		v2 = table.pack(pcall(function()
			return object:InvokeServer(table.unpack(v, 1, v.n))
		end))

		flag = true
	end)
	local lastTime = os.clock()

	while not flag and os.clock() - lastTime < (value or 5) do
		task.wait()
	end

	if flag then
		local n = v2.n
		return table.unpack(v2, 1, n)
	end

	ClientDebugConfig.Warn("[InventoryHandler] Remote invoke timed out: " .. object.Name)
	return false
end

local PianoShopCatalog = require(ReplicatedStorage2:WaitForChild("Monetization"):WaitForChild("PianoShopCatalog"))
local Items = ReplicatedStorage2:WaitForChild("Items")

local OpenInventory = ReplicatedStorage2:FindFirstChild("OpenInventory")

if not (OpenInventory and OpenInventory:IsA("BindableEvent")) then
	if OpenInventory then
		OpenInventory:Destroy()
	end

	OpenInventory = Instance.new("BindableEvent")
	OpenInventory.Name = "OpenInventory"
	OpenInventory.Parent = ReplicatedStorage2
end

local overlay = parent:WaitForChild("Overlay")
local inventory = parent:WaitForChild("Inventory")
local close = inventory:WaitForChild("Header"):WaitForChild("Close")
local center = inventory:WaitForChild("Center")
local sideBar = center:WaitForChild("SideBar")
local body = center:WaitForChild("Body")
local status = body:WaitForChild("Status")
local searchBar = body:FindFirstChild("SearchBar")
local query = searchBar and searchBar:FindFirstChild("Query")
local clear = searchBar and searchBar:FindFirstChild("Clear")
local items = body:WaitForChild("Items")
local grid = items:WaitForChild("Grid")
local itemTemplate = items:WaitForChild("ItemTemplate")

itemTemplate.Visible = false
inventory.ClipsDescendants = true
center.ClipsDescendants = true
body.ClipsDescendants = true
items.ClipsDescendants = true
overlay.BackgroundTransparency = 1

local v = {
	Card = Color3.fromRGB(31, 37, 48),
	CardHover = Color3.fromRGB(40, 48, 61),
	Blue = Color3.fromRGB(55, 128, 235),
	Green = Color3.fromRGB(34, 197, 94),
	Text = Color3.fromRGB(245, 248, 255),
	Muted = Color3.fromRGB(154, 166, 184),
	Red = Color3.fromRGB(239, 68, 68),
	Gold = Color3.fromRGB(245, 197, 66)
}

local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local rotation = inventory.Rotation
local backgroundTransparency = inventory.BackgroundTransparency

local v2 = {
	Benches = 1,
	Titles = 2,
	ChatTags = 3,
	Effects = 4,
	All = 5
}

local v3 = {
	BenchRoyal = { "Royal Bench" },
	BenchWoodenStool = { "WoodenStool" },
	BenchPlasticChair = { "Plastic Chair" },
	BenchBeachChairNoUmbrellaGreen = { "Beach chair w/out Umbrella Green" },
	BenchBeachChairUmbrellaBlue = { "Beach chair w/ Umbrella Blue" },
	BenchBeachChairUmbrellaRed = { "Beach chair w/ Umbrella Red" },
	BenchBeachChairUmbrellaGreen = { "Beach chair w/ Umbrella Green" },
	BenchCampingChair = { "Camping Chair" },
	BenchCatBench = { "Cat Bench" },
	BenchVIPBench = { "VIP Bench" },
	BenchCursedThrone = { "Cursed Throne" }
}

local v4 = {
	open = false,
	tab = "Benches",
	searchQuery = "",
	inventory = {
		Owned = {},
		SelectedBench = "Default",
		SelectedEffect = "None",
		SelectedPianoEffect = "None",
		ItemRecords = {},
		ItemStats = {}
	},
	chatTags = {},
	chatTagPreferences = {},
	titles = {},
	titlePreferences = {},
	busy = false
}

local v5 = 0

local function normalizeInventoryPayload(p)
	local inventory2 = v4.inventory or {}
	local inventoryPayload = type(p) == "table" and p or {}

	inventoryPayload.Owned = type(inventoryPayload.Owned) == "table" and inventoryPayload.Owned
		or type(inventory2.Owned) == "table" and inventory2.Owned
		or {}
	inventoryPayload.ItemRecords = type(inventoryPayload.ItemRecords) == "table" and inventoryPayload.ItemRecords
		or type(inventory2.ItemRecords) == "table" and inventory2.ItemRecords
		or {}
	inventoryPayload.ItemStats = type(inventoryPayload.ItemStats) == "table" and inventoryPayload.ItemStats
		or type(inventory2.ItemStats) == "table" and inventory2.ItemStats
		or {}

	if
		next(inventoryPayload.ItemStats) == nil
		and type(inventory2.ItemStats) == "table"
		and next(inventory2.ItemStats) ~= nil
	then
		inventoryPayload.ItemStats = inventory2.ItemStats
	end

	inventoryPayload.SelectedBench = type(inventoryPayload.SelectedBench) == "string"
		and inventoryPayload.SelectedBench
		or LocalPlayer:GetAttribute("SelectedBench")
		or inventory2.SelectedBench
		or "Default"
	inventoryPayload.SelectedEffect = type(inventoryPayload.SelectedEffect) == "string"
		and inventoryPayload.SelectedEffect
		or LocalPlayer:GetAttribute("SelectedEffect")
		or inventory2.SelectedEffect
		or "None"
	inventoryPayload.SelectedPianoEffect = type(inventoryPayload.SelectedPianoEffect) == "string"
		and inventoryPayload.SelectedPianoEffect
		or LocalPlayer:GetAttribute("SelectedPianoEffect")
		or inventory2.SelectedPianoEffect
		or "None"
	return inventoryPayload
end

local function applyInventoryPayload(p) -- 4 equivalent calls inferred from this helper
	v4.inventory = normalizeInventoryPayload(p)
end

local function suppressNextInventoryRefresh() -- 6 equivalent calls inferred from this helper
	v5 = os.clock() + 1.25
end

local function waitForPianoDataReady(value): boolean
	if LocalPlayer:GetAttribute("PianoDataReady") == true then
		return true
	end

	local lastTime = os.clock()
	local v6 = value or 8

	while v4.open and os.clock() - lastTime < v6 do
		if LocalPlayer:GetAttribute("PianoDataReady") == true then
			return true
		end

		task.wait(0.1)
	end

	return LocalPlayer:GetAttribute("PianoDataReady") == true
end

local v6 = {}

for _, childName in ipairs({ "Benches", "Titles", "ChatTags", "Effects", "All" }) do
	v6[childName] = sideBar:WaitForChild(childName)
end

local function fitPanel()
	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v7 = math.clamp(viewportSize.X - 44, 580, 860)
	local v8 = math.clamp(viewportSize.Y - 90, 420, 560)
	inventory.Size = UDim2.fromOffset(v7, v8)

	if viewportSize.X < 680 then
		sideBar.Size = UDim2.new(0, 124, 1, 0)
		body.Position = UDim2.fromOffset(136, 0)
		body.Size = UDim2.new(1, -136, 1, 0)
	else
		sideBar.Size = UDim2.new(0, 150, 1, 0)
		body.Position = UDim2.fromOffset(164, 0)
		body.Size = UDim2.new(1, -164, 1, 0)
	end

	local uiPadding = body:FindFirstChildOfClass("UIPadding")
	local v9 = math.max(
		1,
		body.AbsoluteSize.X - (uiPadding and uiPadding.PaddingLeft.Offset or 0) - (uiPadding and uiPadding.PaddingRight.Offset or 0) - 8
	)
	local v10 = math.max(1, (math.floor((v9 + 10) / 210)))
	local v11 = math.floor((v9 - (v10 - 1) * 10) / v10)
	grid.CellSize = UDim2.fromOffset(math.clamp(v11, 160, 230), 142)
end

local function clearRows()
	for _, guiObject in ipairs(items:GetChildren()) do
		if guiObject:IsA("GuiObject") and guiObject ~= itemTemplate then
			guiObject:Destroy()
		end
	end
end

local function owned(pianoItemId): boolean -- 1 equivalent call inferred from this helper
	return (v4.inventory and v4.inventory.Owned or {})[pianoItemId] == true
end

local function getBenchAsset(pianoItemId)
	local v7 = v3[pianoItemId]

	if not v7 then
		return nil
	end

	for _, childName in ipairs(v7) do
		local child = Items:FindFirstChild(childName)

		if child then
			return child
		end
	end

	return nil
end

local function getTagColor(data)
	if type(data) ~= "table" then
		return v.Blue
	end

	if typeof(data.Color) == "Color3" then
		return data.Color
	end

	local gradient = data.Gradient

	if type(gradient) == "table" then
		for _, v7 in ipairs(gradient) do
			if typeof(v7) == "Color3" then
				return v7
			end
		end
	end

	return v.Blue
end

local function itemGroup(data): string
	if data.inventoryKind == "ChatTag" then
		return "ChatTags"
	end

	if data.inventoryKind == "OverheadTitle" then
		return "Titles"
	end

	if data.pianoItemId == "Default" or data.displayType == "Bench" then
		return "Benches"
	end

	if data.displayType == "Tag" or data.category == "Tags" or data.category == "Titles" then
		return "Titles"
	end

	if data.category == "Effects" or data.category == "Themes" then
		return "Effects"
	end

	return "All"
end

local function normalizeSearchQuery(searchQuery) -- 2 equivalent calls inferred from this helper
	return tostring(searchQuery or ""):gsub("^%s+", ""):gsub("%s+$", ""):lower()
end

local function itemMatchesSearch(data, searchQuery): boolean
	if searchQuery == "" then
		return true
	end

	return table.concat({
		tostring(data.title or ""),
		tostring(data.pianoItemId or ""),
		tostring(data.displayType or ""),
		tostring(data.category or ""),
		tostring(data.description or ""),
		(tostring(data.tagName or ""))
	}, " "):lower():find(searchQuery, 1, true) ~= nil
end

local function buildTagInventoryItem(source, inventoryKind, layoutOrder)
	if type(source) ~= "table" then
		return nil
	end

	local tag = tostring(source.Tag or source.Title or "")

	if tag == "" then
		return nil
	end

	local v7 = inventoryKind == "ChatTag"
	local titleId

	if type(source.TitleId) == "string" then
		titleId = source.TitleId or nil
	end

	return {
		inventoryKind = inventoryKind,
		tagName = tag,
		pianoItemId = titleId or inventoryKind .. ":" .. tag,
		trackExisting = titleId ~= nil,
		title = tag,
		description = v7 and "Shown before your name in chat." or "Shown above your player name.",
		displayType = v7 and "Chat Tag" or "Title",
		category = v7 and "ChatTags" or "Titles",
		layoutOrder = layoutOrder,
		color = getTagColor(source),
		source = source
	}
end

local function buildInventoryItems()
	local inventoryItems = {
		{
			pianoItemId = "Default",
			title = "Default Bench",
			description = "Use each piano's original bench.",
			displayType = "Bench",
			category = "Benches",
			layoutOrder = 0,
			color = Color3.fromRGB(120, 210, 255)
		}
	}

	for _, v7 in ipairs(PianoShopCatalog.GetItems()) do
		local pianoItemId = v7.pianoItemId

		if not (v7.displayType ~= "Tag" and v7.category ~= "Tags" and v7.category ~= "Titles" and v7.purchaseKind ~= "DeveloperProduct") then
			continue
		end

		if not (v7.category ~= "Gamepasses" and pianoItemId and owned(pianoItemId)) then -- inferred equivalent call
			continue
		end

		table.insert(inventoryItems, v7)
	end

	local tagNameSet = {}

	for i, chatTag in ipairs(v4.chatTags) do
		local tagInventoryItem = buildTagInventoryItem(chatTag, "ChatTag", 1000 + i)

		if not tagInventoryItem or tagNameSet[tagInventoryItem.tagName] then
			continue
		end

		tagNameSet[tagInventoryItem.tagName] = true
		table.insert(inventoryItems, tagInventoryItem)
	end

	local tagNameSet2 = {}

	for i, title in ipairs(v4.titles) do
		local tagInventoryItem = buildTagInventoryItem(title, "OverheadTitle", 2000 + i)

		if not tagInventoryItem or tagNameSet2[tagInventoryItem.tagName] then
			continue
		end

		tagNameSet2[tagInventoryItem.tagName] = true
		table.insert(inventoryItems, tagInventoryItem)
	end

	table.sort(inventoryItems, function(a, b): boolean
		local v7

		if a.inventoryKind == "ChatTag" then
			v7 = "ChatTags"
		elseif a.inventoryKind == "OverheadTitle" then
			v7 = "Titles"
		elseif a.pianoItemId == "Default" or a.displayType == "Bench" then
			v7 = "Benches"
		elseif a.displayType == "Tag" or a.category == "Tags" or a.category == "Titles" then
			v7 = "Titles"
		elseif a.category == "Effects" or a.category == "Themes" then
			v7 = "Effects"
		else
			v7 = "All"
		end

		local v8

		if b.inventoryKind == "ChatTag" then
			v8 = "ChatTags"
		elseif b.inventoryKind == "OverheadTitle" then
			v8 = "Titles"
		elseif b.pianoItemId == "Default" or b.displayType == "Bench" then
			v8 = "Benches"
		elseif b.displayType == "Tag" or b.category == "Tags" or b.category == "Titles" then
			v8 = "Titles"
		elseif b.category == "Effects" or b.category == "Themes" then
			v8 = "Effects"
		else
			v8 = "All"
		end

		local v9 = v2[v7] or 99
		local v10 = v2[v8] or 99

		if v9 ~= v10 then
			return v9 < v10
		end

		local layoutOrder = tonumber(a.layoutOrder) or 9999
		local layoutOrder2 = tonumber(b.layoutOrder) or 9999

		if layoutOrder == layoutOrder2 then
			return tostring(a.title or a.pianoItemId):lower() < tostring(b.title or b.pianoItemId):lower()
		end

		return layoutOrder < layoutOrder2
	end)

	return inventoryItems
end

local function clearPreview(preview)
	for _, uiCorner in ipairs(preview:GetChildren()) do
		if uiCorner:IsA("UICorner") or uiCorner.Name == "Initials" then
			continue
		end

		uiCorner:Destroy()
	end
end

local function getInitials(title)
	local v7 = tostring(title or "IT")
	local v8 = {}

	if pcall(function()
		for k, v9 in utf8.graphemes(v7) do
			table.insert(v8, v7:sub(k, v9))

			if #v8 >= 2 then
				break
			end
		end
	end) and #v8 > 0 then
		return table.concat(v8):upper()
	end

	return v7:sub(1, 2):upper()
end

local function populatePreview(clone, data)
	local preview = clone:WaitForChild("Preview")
	local initials = preview:FindFirstChild("Initials")
	clearPreview(preview)

	if initials then
		initials.Visible = true
		initials.Text = getInitials(data.title or "IT")
		initials.TextColor3 = data.color or v.Blue
	end

	local benchAsset = getBenchAsset(data.pianoItemId)

	if not benchAsset then
		return
	end

	local clone2 = benchAsset:Clone()
	clone2.Parent = preview

	for _, part in ipairs(clone2:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	local camera = Instance.new("Camera")
	camera.Parent = preview
	preview.CurrentCamera = camera
	local v7, v8

	if clone2:IsA("Model") then
		v7, v8 = clone2:GetBoundingBox()
	elseif clone2:IsA("BasePart") then
		v7 = clone2.CFrame
		v8 = clone2.Size
	else
		local basePart = clone2:FindFirstChildWhichIsA("BasePart", true)
		v7 = basePart and basePart.CFrame or CFrame.new()
		v8 = basePart and basePart.Size or Vector3.new(1, 1, 1)
	end

	local v9 = math.max(v8.X, v8.Y, v8.Z, 1)
	camera.CFrame = CFrame.new(v7.Position + Vector3.new(v9 * 1.4, v9 * 0.7, v9 * 1.7), v7.Position)

	if initials then
		initials.Visible = false
	end
end

local function buildEnabledNames(options, options2, tagName, p)
	local v7 = {}

	for k, v8 in pairs(options2 or {}) do
		if type(k) == "string" and v8 == true then
			v7[k] = true
		end
	end

	if type(tagName) == "string" then
		if p then
			v7[tagName] = true
		else
			v7[tagName] = nil
		end
	end

	local enabledNames = {}
	local set = {}

	if p and type(tagName) == "string" and v7[tagName] then
		table.insert(enabledNames, tagName)
		set[tagName] = true
	end

	for _, v8 in ipairs(options or {}) do
		local v9 = type(v8) == "table" and v8.Tag

		if type(v9) ~= "string" or not v7[v9] or set[v9] then
			continue
		end

		table.insert(enabledNames, v9)
		set[v9] = true
	end

	while #enabledNames > 2 do
		table.remove(enabledNames)
	end

	return enabledNames
end

local function buildLocalPreferences(options, enabledNames)
	local set = {}

	for i, v7 in ipairs(enabledNames or {}) do
		if i <= 2 then
			set[v7] = true
		end
	end

	local localPreferences = {}

	for _, v7 in ipairs(options or {}) do
		local v8 = type(v7) == "table" and v7.Tag

		if type(v8) == "string" then
			localPreferences[v8] = set[v8] == true
		end
	end

	return localPreferences
end

local function formatExistingCount(p)
	local v7 = tostring((math.max(0, (math.floor(tonumber(p) or 0)))))

	repeat
		local v8
		v7, v8 = v7:gsub("^(%d+)(%d%d%d)", "%1,%2")
	until v8 == 0

	return v7
end

local function getItemTrackingData(data)
	local v7 = type(data) == "table" and data.pianoItemId

	if type(v7) ~= "string" then
		return nil, nil
	end

	local inventory2 = v4.inventory or {}
	local itemStats = type(inventory2.ItemStats) == "table" and inventory2.ItemStats or {}
	local itemRecords = type(inventory2.ItemRecords) == "table" and inventory2.ItemRecords or {}
	return itemStats[v7], itemRecords[v7]
end

local function hasLoadedItemStats(): boolean -- 3 equivalent calls inferred from this helper
	local inventory2 = v4.inventory or {}
	local itemStats = type(inventory2.ItemStats) == "table" and inventory2.ItemStats or nil
	return itemStats ~= nil and next(itemStats) ~= nil
end

local function applyTrackingPresentation(clone, data)
	local limitedStroke = clone:FindFirstChild("LimitedStroke")
	local existingCount = clone:FindFirstChild("ExistingCount") or clone:FindFirstChild("LimitedCount")
	local itemTrackingData, v7 = getItemTrackingData(data)
	local v8

	if data.limited == true then
		v8 = true
	elseif type(itemTrackingData) == "table" then
		v8 = itemTrackingData.Limited == true
	else
		v8 = false
	end

	local v9

	if data.developerExclusive == true then
		v9 = true
	elseif type(itemTrackingData) == "table" then
		v9 = itemTrackingData.DeveloperExclusive == true
	else
		v9 = false
	end

	local v10 = v8 or v9 or data.trackExisting == true or type(itemTrackingData) == "table"

	if limitedStroke and limitedStroke:IsA("UIStroke") then
		limitedStroke.Enabled = false
	end

	if existingCount and existingCount:IsA("TextLabel") then
		existingCount.Visible = false
	end

	clone.Description.Size = UDim2.new(1, -20, 0, 32)

	if not v10 then
		return
	end

	if type(itemTrackingData) ~= "table" then
		clone.Description.Size = UDim2.new(1, -20, 0, 32)
		return
	end

	local existingCount2 = itemTrackingData.ExistingCount or itemTrackingData.TotalExisting or data.limitedExisting
	local maxSupply = itemTrackingData.MaxSupply or data.limitedMax
	clone.Description.Size = UDim2.new(1, -20, 0, 24)

	if v8 then
		local limitedAccentColor = data.limitedAccentColor
			or type(itemTrackingData) == "table" and itemTrackingData.LimitedAccentColor
			or v.Gold
		clone.Type.Text = data.limitedLabel
			or type(itemTrackingData) == "table" and itemTrackingData.LimitedLabel
			or "Limited Edition"
		clone.Type.TextColor3 = limitedAccentColor

		if limitedStroke and limitedStroke:IsA("UIStroke") then
			limitedStroke.Color = limitedAccentColor
			limitedStroke.Transparency = 0.35
			limitedStroke.Thickness = 1
			limitedStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			limitedStroke.Enabled = true
		end

		if existingCount and existingCount:IsA("TextLabel") then
			local serial

			if type(v7) == "table" then
				serial = tonumber(v7.Serial) or nil
			end

			local text = string.format(
				"%s / %s existing",
				formatExistingCount(existingCount2),
				formatExistingCount(maxSupply)
			)
			existingCount.TextColor3 = limitedAccentColor
			text = serial and "Serial #" .. formatExistingCount(serial) .. " | " .. text or text
			existingCount.Text = text
			existingCount.Visible = true
		end
	elseif v9 then
		local developerAccentColor = data.developerAccentColor
			or type(itemTrackingData) == "table" and itemTrackingData.DeveloperAccentColor
			or Color3.fromRGB(88, 195, 173)
		clone.Type.Text = data.developerLabel
			or type(itemTrackingData) == "table" and itemTrackingData.DeveloperLabel
			or "Developer Item"
		clone.Type.TextColor3 = developerAccentColor

		if limitedStroke and limitedStroke:IsA("UIStroke") then
			limitedStroke.Color = developerAccentColor
			limitedStroke.Transparency = 0.35
			limitedStroke.Thickness = 1
			limitedStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			limitedStroke.Enabled = true
		end

		if existingCount and existingCount:IsA("TextLabel") then
			local serial

			if type(v7) == "table" then
				serial = tonumber(v7.Serial) or nil
			end

			local text = formatExistingCount(existingCount2) .. " existing"
			existingCount.TextColor3 = developerAccentColor
			text = serial and "Serial #" .. formatExistingCount(serial) .. " | " .. text or text
			existingCount.Text = text
			existingCount.Visible = true
		end
	elseif existingCount and existingCount:IsA("TextLabel") then
		existingCount.TextColor3 = v.Muted
		existingCount.Text = formatExistingCount(existingCount2) .. " existing"
		existingCount.Visible = true
	end
end

local fn

local function isItemEquipped(data): boolean
	if data.displayType == "Bench" then
		return (v4.inventory.SelectedBench or "Default") == data.pianoItemId
	end

	if data.inventoryKind == "ChatTag" then
		return v4.chatTagPreferences[data.tagName] == true
	end

	if data.inventoryKind == "OverheadTitle" then
		return v4.titlePreferences[data.tagName] == true
	end

	if data.displayType == "Effect" then
		return (v4.inventory.SelectedEffect or "None") == data.pianoItemId
	end

	if data.displayType == "Piano Effect" then
		return (v4.inventory.SelectedPianoEffect or "None") == data.pianoItemId
	end

	return false
end

local function makeCard(data, layoutOrder)
	local clone = itemTemplate:Clone()
	clone.Name = data.pianoItemId or data.title or "Item"
	clone.LayoutOrder = layoutOrder
	clone.Visible = true
	clone.Parent = items
	clone.BackgroundColor3 = v.Card
	populatePreview(clone, data)
	clone.Title.Text = data.title or data.pianoItemId or "Item"
	clone.Type.Text = data.displayType or data.category or "Item"
	clone.Type.TextColor3 = data.color or v.Muted
	clone.Description.Text = data.description or "Owned item."
	applyTrackingPresentation(clone, data)
	local v7 = data.displayType == "Bench"
	local v8 = data.inventoryKind == "ChatTag"
	local v9 = data.inventoryKind == "OverheadTitle"
	local v10 = data.displayType == "Effect"
	local v11 = data.displayType == "Piano Effect"
	local itemEquipped = isItemEquipped(data)
	local v12 = v7 or v8 or v9 or v10 or v11

	if v7 then
		clone.Action.Text = itemEquipped and "Equipped" or "Equip"
	elseif v8 or v9 or v10 or v11 then
		clone.Action.Text = itemEquipped and "Unequip" or "Equip"
	else
		clone.Action.Text = "Owned"
	end

	if itemEquipped and (v8 or v9 or v10 or v11) then
		clone.Action.BackgroundColor3 = v.Red
	else
		clone.Action.BackgroundColor3 = itemEquipped and v.Green or v12 and v.Blue or Color3.fromRGB(52, 60, 74)
	end

	clone.Action.Activated:Connect(function()
		if v4.busy then
			return
		end

		if v7 then
			if itemEquipped then
				return
			end

			if equipInventoryItem then
				v4.busy = true
				status.Text = "Equipping " .. tostring(data.title or "bench") .. "..."
				suppressNextInventoryRefresh() -- inferred equivalent call
				local v13, v14, v15, v16 = invokeRemote(equipInventoryItem, 6, "Bench", data.pianoItemId)
				v4.busy = false

				if v13 and v14 then
					applyInventoryPayload(v16) -- inferred equivalent call
					suppressNextInventoryRefresh() -- inferred equivalent call
					render()
					status.Text = "Equipped " .. tostring(data.title or "bench") .. "."
					status.TextColor3 = v.Green

					if not hasLoadedItemStats() then -- inferred equivalent call
						task.defer(fn)
					end
				else
					status.Text = tostring(v13 and v15 or "Could not equip item.")
					status.TextColor3 = v.Red
				end
			else
				status.Text = "Bench inventory is not ready yet."
				status.TextColor3 = v.Red
			end
		elseif v8 then
			if updateTagPreferences then
				local v13 = not itemEquipped
				local enabledNames = buildEnabledNames(v4.chatTags, v4.chatTagPreferences, data.tagName, v13)
				updateTagPreferences:FireServer(enabledNames)
				v4.chatTagPreferences = buildLocalPreferences(v4.chatTags, enabledNames)
				render()
				status.Text = (v13 and "Equipped " or "Unequipped ") .. tostring(data.title or "chat tag") .. "."
				status.TextColor3 = v.Green
			else
				status.Text = "Chat tag inventory is not ready yet."
				status.TextColor3 = v.Red
			end
		elseif v9 then
			if updateTitlePreferences then
				local v13 = not itemEquipped
				local enabledNames = buildEnabledNames(v4.titles, v4.titlePreferences, data.tagName, v13)
				updateTitlePreferences:FireServer(enabledNames)
				v4.titlePreferences = buildLocalPreferences(v4.titles, enabledNames)
				render()
				status.Text = (v13 and "Equipped " or "Unequipped ") .. tostring(data.title or "title") .. "."
				status.TextColor3 = v.Green
			else
				status.Text = "Title inventory is not ready yet."
				status.TextColor3 = v.Red
			end
		elseif v10 then
			if equipInventoryItem then
				v4.busy = true
				local v13 = not itemEquipped
				status.Text = (v13 and "Equipping " or "Unequipping ") .. tostring(data.title or "effect") .. "..."
				suppressNextInventoryRefresh() -- inferred equivalent call
				local v14, v15, v16, v17 = invokeRemote(
					equipInventoryItem,
					6,
					"Effect",
					v13 and data.pianoItemId or "None"
				)
				v4.busy = false

				if v14 and v15 then
					applyInventoryPayload(v17) -- inferred equivalent call
					suppressNextInventoryRefresh() -- inferred equivalent call
					render()
					status.Text = (v13 and "Equipped " or "Unequipped ") .. tostring(data.title or "effect") .. "."
					status.TextColor3 = v.Green

					if not hasLoadedItemStats() then -- inferred equivalent call
						task.defer(fn)
					end
				else
					status.Text = tostring(v14 and v16 or "Could not equip effect.")
					status.TextColor3 = v.Red
				end
			else
				status.Text = "Effect inventory is not ready yet."
				status.TextColor3 = v.Red
			end
		elseif v11 then
			if equipInventoryItem then
				v4.busy = true
				local v13 = not itemEquipped
				status.Text = (v13 and "Equipping " or "Unequipping ") .. tostring(data.title or "piano effect") .. "..."
				suppressNextInventoryRefresh() -- inferred equivalent call
				local v14, v15, v16, v17 = invokeRemote(
					equipInventoryItem,
					6,
					"PianoEffect",
					v13 and data.pianoItemId or "None"
				)
				v4.busy = false

				if v14 and v15 then
					applyInventoryPayload(v17) -- inferred equivalent call
					suppressNextInventoryRefresh() -- inferred equivalent call
					render()
					status.Text = (v13 and "Equipped " or "Unequipped ") .. tostring(data.title or "piano effect") .. "."
					status.TextColor3 = v.Green

					if not hasLoadedItemStats() then -- inferred equivalent call
						task.defer(fn)
					end
				else
					status.Text = tostring(v14 and v16 or "Could not equip piano effect.")
					status.TextColor3 = v.Red
				end
			else
				status.Text = "Piano effect inventory is not ready yet."
				status.TextColor3 = v.Red
			end
		end
	end)
	clone.MouseEnter:Connect(function()
		TweenService:Create(clone, tweenInfo, { BackgroundColor3 = v.CardHover }):Play()
	end)
	clone.MouseLeave:Connect(function()
		TweenService:Create(clone, tweenInfo, { BackgroundColor3 = v.Card }):Play()
	end)
end

function render()
	clearRows()

	for k, v7 in pairs(v6) do
		v7.BackgroundColor3 = k == v4.tab and v.Blue or v.Card
	end

	local searchQuery = normalizeSearchQuery(v4.searchQuery) -- inferred equivalent call

	if clear and clear:IsA("GuiButton") then
		clear.Visible = searchQuery ~= ""
	end

	local count = 0

	for _, v7 in ipairs(buildInventoryItems()) do
		local v8

		if v7.inventoryKind == "ChatTag" then
			v8 = "ChatTags"
		elseif v7.inventoryKind == "OverheadTitle" then
			v8 = "Titles"
		elseif v7.pianoItemId == "Default" or v7.displayType == "Bench" then
			v8 = "Benches"
		elseif v7.displayType == "Tag" or v7.category == "Tags" or v7.category == "Titles" then
			v8 = "Titles"
		elseif v7.category == "Effects" or v7.category == "Themes" then
			v8 = "Effects"
		else
			v8 = "All"
		end

		if not ((v4.tab == "All" or v4.tab == v8) and itemMatchesSearch(v7, searchQuery)) then
			continue
		end

		count += 1
		makeCard(v7, count)
	end

	if count == 0 then
		if searchQuery == "" then
			status.Text = "No owned items in this category yet."
		else
			status.Text = "No owned items match that search."
		end
	else
		status.Text = "Showing " .. tostring(count) .. (searchQuery == "" and " item" or " matching item") .. (count == 1 and "." or "s.")
	end

	status.TextColor3 = v.Muted

	items.Visible = true
	task.defer(function()
		items.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + 12)
	end)
end

fn = function()
	if not getItemStats then
		return
	end

	local pianoItemIdSet = {}
	local pianoItemIds = {}

	for _, v7 in ipairs(buildInventoryItems()) do
		local pianoItemId = v7.pianoItemId

		if
			type(pianoItemId) ~= "string"
			or pianoItemId == ""
			or pianoItemIdSet[pianoItemId]
			or not (v7.trackExisting == true or v7.limited == true)
		then
			continue
		end

		pianoItemIdSet[pianoItemId] = true
		table.insert(pianoItemIds, pianoItemId)
	end

	if #pianoItemIds == 0 then
		return
	end

	task.spawn(function()
		local v7, itemStats = invokeRemote(getItemStats, 20, pianoItemIds)

		if v7 and type(itemStats) == "table" then
			v4.inventory.ItemStats = itemStats

			if v4.open then
				render()
			end
		end
	end)
end

local function fetch()
	status.Text = "Loading inventory..."
	status.TextColor3 = v.Muted
	local v7, v8

	if getInventoryData then
		v7, v8 = invokeRemote(getInventoryData, 8)
	else
		v7 = false
	end

	if v7 and type(v8) == "table" then
		applyInventoryPayload(v8) -- inferred equivalent call
	else
		v4.inventory = normalizeInventoryPayload(v4.inventory)
		status.Text = LocalPlayer:GetAttribute("PianoDataReady") == true
			and "Inventory sync timed out. Showing cached data."
			or "Inventory data is still loading."
		status.TextColor3 = v.Muted
	end

	local v9, chatTags, v10

	if requestChatTags then
		v9, chatTags, v10 = invokeRemote(requestChatTags, 4)
	else
		v9 = false
	end

	if v9 and type(chatTags) == "table" then
		v4.chatTags = chatTags
		v4.chatTagPreferences = type(v10) == "table" and v10 or {}
	else
		v4.chatTags = {}
		v4.chatTagPreferences = {}
	end

	local v11, titles, v12

	if requestTitles then
		v11, titles, v12 = invokeRemote(requestTitles, 4)
	else
		v11 = false
	end

	if v11 and type(titles) == "table" then
		v4.titles = titles
		v4.titlePreferences = type(v12) == "table" and v12 or {}
	else
		v4.titles = {}
		v4.titlePreferences = {}
	end

	render()
	fn()
end

local function playCameraZoom(fieldOfView) -- 2 equivalent calls inferred from this helper
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		TweenService:Create(currentCamera, tweenInfo2, { FieldOfView = fieldOfView }):Play()
	end
end

local function open()
	fitPanel()
	v4.open = true
	clearRows()
	items.Visible = false
	items.CanvasPosition = Vector2.zero
	status.Text = "Loading inventory..."
	status.TextColor3 = v.Muted
	overlay.BackgroundTransparency = 1
	overlay.Visible = true
	inventory.Visible = true
	inventory.Position = UDim2.fromScale(0.5, 0.5)
	inventory.Rotation = rotation
	inventory.BackgroundTransparency = backgroundTransparency

	if query and query:IsA("TextBox") then
		query.Text = v4.searchQuery
	end

	playCameraZoom(50) -- inferred equivalent call
	task.spawn(function()
		if not v4.open then
			return
		end

		waitForPianoDataReady(8)

		if v4.open then
			fetch()
		end
	end)
end

local function close2() -- 2 equivalent calls inferred from this helper
	if not v4.open then
		return
	end

	v4.open = false
	overlay.BackgroundTransparency = 1
	overlay.Visible = false
	inventory.Visible = false
	inventory.BackgroundTransparency = backgroundTransparency
	inventory.Rotation = rotation
	playCameraZoom(70) -- inferred equivalent call
end

for k, v7 in pairs(v6) do
	v7.Activated:Connect(function()
		v4.tab = k
		items.CanvasPosition = Vector2.zero
		render()
	end)
end

if query and query:IsA("TextBox") then
	query:GetPropertyChangedSignal("Text"):Connect(function()
		v4.searchQuery = query.Text or ""

		if clear and clear:IsA("GuiButton") then
			clear.Visible = normalizeSearchQuery(v4.searchQuery) ~= "" -- inferred equivalent call
		end

		items.CanvasPosition = Vector2.zero

		if v4.open then
			render()
		end
	end)
end

if clear and clear:IsA("GuiButton") then
	clear.Activated:Connect(function()
		if query and query:IsA("TextBox") then
			query.Text = ""
			return
		end

		v4.searchQuery = ""
		clear.Visible = false

		if v4.open then
			render()
		end
	end)
end

close.Activated:Connect(close2)
OpenInventory.Event:Connect(function()
	if v4.open then
		close2() -- inferred equivalent call
	else
		open()
	end
end)

if advancedChatTags then
	advancedChatTags.OnClientEvent:Connect(function(chatTags, ...)
		if chatTags == "PlayerTagsUpdate" then
			local v7, chatTags2, v8 = ...

			if v7 == LocalPlayer.UserId and type(chatTags2) == "table" then
				v4.chatTags = chatTags2
				v4.chatTagPreferences = type(v8) == "table" and v8 or v4.chatTagPreferences

				if v4.open then
					render()
				end
			end
		elseif chatTags == "PlayerPreferencesUpdate" then
			local v7, chatTagPreferences = ...

			if v7 == LocalPlayer.UserId and type(chatTagPreferences) == "table" then
				v4.chatTagPreferences = chatTagPreferences

				if v4.open then
					render()
				end
			end
		elseif type(chatTags) == "table" then
			local v7 = ...
			v4.chatTags = chatTags
			v4.chatTagPreferences = type(v7) == "table" and v7 or v4.chatTagPreferences

			if v4.open then
				render()
			end
		end
	end)
end

if shopPurchasesUpdated then
	shopPurchasesUpdated.OnClientEvent:Connect(function()
		if v4.open and not v4.busy then
			local now = os.clock()

			if v5 <= now then
				fetch()
			end
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and v4.open and input.KeyCode == Enum.KeyCode.Escape then
		close2() -- inferred equivalent call
	end
end)
RunService.RenderStepped:Connect(function()
	if v4.open then
		fitPanel()
	end
end)
fitPanel()
ClientDebugConfig.Print("[InventoryHandler] Ready")