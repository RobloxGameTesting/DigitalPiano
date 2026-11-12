game:GetService("Players")

local Piano_Dependencies = workspace:WaitForChild("Piano_Dependencies")
local Remotes = Piano_Dependencies:WaitForChild("Remotes")
local Modules = Piano_Dependencies:WaitForChild("Modules")
local Logic = Modules:WaitForChild("Logic")
local Dependencies = Modules:WaitForChild("Dependencies")

local Soundfonts = require(Dependencies:WaitForChild("Soundfonts"))
local PlayerVariables = require(Dependencies:WaitForChild("PlayerVariables"))
local PianoLogic = require(Logic:WaitForChild("PianoLogic"))

local parent = script.Parent
local categoryList = parent:WaitForChild("CategoryList")
local scrollingFrame = parent:WaitForChild("ScrollingFrame")
local search = parent:FindFirstChild("Search")
local emptyLabel = parent:FindFirstChild("EmptyLabel")
local close = parent:FindFirstChild("Close")

local categoryTemplate = categoryList:WaitForChild("CategoryTemplate")
local soundfontRowTemplate = scrollingFrame:WaitForChild("SoundfontRowTemplate")

local function waitForRemote(childName)
	local child = Remotes:FindFirstChild(childName)

	if child then
		return child
	end

	return Remotes:WaitForChild(childName, 5)
end

local getSoundfontState = Remotes:FindFirstChild("GetSoundfontState") or Remotes:WaitForChild("GetSoundfontState", 5)
local setSelectedSoundfont = Remotes:FindFirstChild("SetSelectedSoundfont")
	or Remotes:WaitForChild("SetSelectedSoundfont", 5)
local toggleSoundfontFavorite = Remotes:FindFirstChild("ToggleSoundfontFavorite")
	or Remotes:WaitForChild("ToggleSoundfontFavorite", 5)

local color = Color3.fromRGB(255, 205, 77)
local color2 = Color3.fromRGB(143, 151, 165)
local color3 = Color3.fromRGB(45, 118, 235)
local color4 = Color3.fromRGB(34, 38, 46)
local color5 = Color3.fromRGB(45, 118, 235)
local color6 = Color3.fromRGB(34, 38, 46)
local color7 = Color3.fromRGB(42, 38, 38)
local color8 = Color3.fromRGB(145, 205, 255)
local color9 = Color3.fromRGB(61, 68, 82)

local color10 = Color3.fromRGB(28, 76, 122)
local color11 = Color3.fromRGB(188, 226, 255)

local v = {
	"Favorites",
	"All",
	"Grand Piano",
	"Electric Piano",
	"Percussion",
	"Strings",
	"Plucked",
	"Wind",
	"Brass",
	"Organ",
	"Synth",
	"Meme"
}

local v2 = {}
local clones = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = "All"
local v10 = nil
local v11 = false

local function normalizeBooleanMap(items)
	local booleanMap = {}

	if type(items) ~= "table" then
		return booleanMap
	end

	for k, item in pairs(items) do
		if item == true then
			booleanMap[tostring(k)] = true
		end
	end

	return booleanMap
end

local function cloneArray(list) -- 1 equivalent call inferred from this helper
	local array = {}

	if type(list) ~= "table" then
		return array
	end

	for i, item in ipairs(list) do
		array[i] = item
	end

	return array
end

local function rebuildFavoriteRanks()
	table.clear(v5)

	for i, v12 in ipairs(v4) do
		local v13 = tostring(v12)

		if v3[v13] == true and v5[v13] == nil then
			v5[v13] = i
		end
	end
end

local function getFallbackFavoriteOrder()
	local ids = {}

	for _, v12 in ipairs(v2) do
		local id = tostring(v12.id)

		if v3[id] == true then
			table.insert(ids, id)
		end
	end

	return ids
end

local function normalizeFavoriteOrder(favoriteOrder)
	local favoriteOrder2 = {}
	local set = {}

	if type(favoriteOrder) == "table" then
		for _, item in ipairs(favoriteOrder) do
			local v12 = tonumber(item)
			local v13 = v12 and tostring((math.floor(v12))) or tostring(item or "")

			if v13 == "" or v3[v13] ~= true or set[v13] then
				continue
			end

			set[v13] = true
			table.insert(favoriteOrder2, v13)
		end
	end

	for _, v12 in ipairs(getFallbackFavoriteOrder()) do
		if v3[v12] ~= true or set[v12] then
			continue
		end

		set[v12] = true
		table.insert(favoriteOrder2, v12)
	end

	return favoriteOrder2
end

local function appendFavoriteOrderKey(p) -- 1 equivalent call inferred from this helper
	local v12 = tostring(p)

	if v5[v12] == nil then
		table.insert(v4, v12)
		rebuildFavoriteRanks()
	end
end

local function removeFavoriteOrderKey(p)
	local v12 = tostring(p)

	for i = #v4, 1, -1 do
		if v4[i] == v12 then
			table.remove(v4, i)
		end
	end

	rebuildFavoriteRanks()
end

local function getAccess(p)
	local access = type(p.Access) == "table" and p.Access or nil
	local kind = access and tostring(access.Type or "Free") or "Free"

	return {
		Type = kind ~= "Paid" and "Free" or kind,
		Price = access and math.max(0, (math.floor(tonumber(access.Price) or 0))) or 0,
		Currency = access and tostring(access.Currency or "Notes") or "Notes",
		ShopItemId = access and tostring(access.ShopItemId or "") or ""
	}
end

local function isOwned(id, soundfont): boolean -- 3 equivalent calls inferred from this helper
	local access = getAccess(soundfont)

	if access.Type ~= "Paid" then
		return true
	end

	local v12 = tostring(id)

	if v7[v12] == true or v8[v12] == true then
		return true
	elseif access.ShopItemId == "" then
		return false
	else
		return v7[access.ShopItemId] == true
	end
end

local function getCategory(soundfont) -- 1 equivalent call inferred from this helper
	local category = tostring(soundfont.Category or "Grand Piano")
	return category == "" and "Grand Piano" or category
end

local function getCategoryOrder() -- 1 equivalent call inferred from this helper
	if type(Soundfonts.CategoryOrder) == "table" then
		return Soundfonts.CategoryOrder
	end

	return v
end

local function getFavoriteCount() -- 2 equivalent calls inferred from this helper
	local count = 0

	for _, v12 in pairs(v3) do
		if v12 == true then
			count += 1
		end
	end

	return count
end

local function formatCategoryLabel(p) -- 2 equivalent calls inferred from this helper
	if p ~= "Favorites" then
		return p
	end

	local favoriteCount = getFavoriteCount() -- inferred equivalent call
	return favoriteCount > 0 and string.format("Favorites %d", favoriteCount) or "Favorites"
end

local function styleStroke(parent2, color12, thickness, transparency)
	local uiStroke = parent2:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Color = color12
	uiStroke.Thickness = thickness
	uiStroke.Transparency = transparency
	uiStroke.Parent = parent2
	return uiStroke
end

local function styleCategoryButton(instance, p)
	instance.BackgroundColor3 = p and color3 or color4
	instance.TextColor3 = p and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(207, 213, 224)
	instance.TextStrokeTransparency = 1
	instance.Font = p and Enum.Font.GothamBold or Enum.Font.GothamMedium

	local uiStroke = instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke:Destroy()
	end
end

local function styleFavoriteButton(starButton, p) -- 1 equivalent call inferred from this helper
	if not starButton then
		return
	end

	starButton.Image = p and "rbxassetid://139143070369094" or "rbxassetid://89720525236838"
	starButton.ImageColor3 = p and color or color2
	starButton.ImageTransparency = p and 0 or 0.1
end

local function styleSoundfontRow(row, p, locked)
	if locked then
		row.BackgroundColor3 = color7
	elseif p then
		row.BackgroundColor3 = color5
	else
		row.BackgroundColor3 = color6
	end

	local uiStroke = row:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Color = p and color8 or color9
	uiStroke.Thickness = p and 2 or 1
	uiStroke.Transparency = p and 0 or 0.45
	uiStroke.Parent = row

	local nameLabel = row:FindFirstChild("NameLabel")

	if nameLabel then
		nameLabel.TextColor3 = locked and Color3.fromRGB(178, 182, 190) or Color3.fromRGB(242, 245, 250)
		nameLabel.Font = p and Enum.Font.GothamBold or Enum.Font.GothamSemibold
	end

	local metaLabel = row:FindFirstChild("MetaLabel")

	if metaLabel then
		metaLabel.TextColor3 = p and Color3.fromRGB(224, 238, 255) or Color3.fromRGB(150, 158, 173)
	end
end

local function refreshCategoryButtons()
	for k, v12 in pairs(clones) do
		v12.Text = formatCategoryLabel(k) -- inferred equivalent call
		styleCategoryButton(v12, k == v9)
	end
end

local function refreshSelectedSoundfont()
	local current_SoundfontID = tonumber(PlayerVariables.Current_SoundfontID) or 1
	v10 = current_SoundfontID

	for _, v12 in ipairs(v2) do
		v12.locked = not isOwned(v12.id, v12.soundfont) -- inferred equivalent call
		v12.row:SetAttribute("Locked", v12.locked)
		styleSoundfontRow(v12.row, tonumber(v12.id) == current_SoundfontID, v12.locked)
		styleFavoriteButton(v12.starButton, v3[tostring(v12.id)] == true) -- inferred equivalent call
	end

	refreshCategoryButtons()
end

local function rowMatchesSearch(p, text): boolean -- 1 equivalent call inferred from this helper
	if text == "" then
		return true
	end

	return p.searchName:find(text, 1, true) ~= nil or p.searchCategory:find(text, 1, true) ~= nil
end

local function rowMatchesCategory(p): boolean -- 1 equivalent call inferred from this helper
	if v9 == "All" then
		return true
	elseif v9 == "Favorites" then
		return v3[tostring(p.id)] == true
	end

	return p.category == v9
end

local function releaseSearchFocus() -- 2 equivalent calls inferred from this helper
	if search and search:IsA("TextBox") then
		search:ReleaseFocus()
	end
end

local function applyFilters()
	local text = search and tostring(search.Text or ""):lower() or ""
	local count = 0

	for _, v12 in ipairs(v2) do
		local id = tostring(v12.id)

		if v9 == "Favorites" then
			v12.row.LayoutOrder = v5[id] or v12.defaultLayoutOrder
		else
			v12.row.LayoutOrder = v12.defaultLayoutOrder
		end

		local visible = rowMatchesCategory(v12) and rowMatchesSearch(v12, text) -- inferred equivalent call
		v12.row.Visible = visible

		if visible then
			count += 1
		end
	end

	if emptyLabel then
		emptyLabel.Visible = count == 0

		if v9 == "Favorites" and getFavoriteCount() == 0 then -- inferred equivalent call
			emptyLabel.Text = "No favorite soundfonts yet"
			return
		end

		emptyLabel.Text = "No soundfonts found"
	end
end

local function applySoundfontState(data)
	if type(data) ~= "table" then
		return
	end

	v3 = normalizeBooleanMap(data.Favorites)
	v4 = normalizeFavoriteOrder(data.FavoriteOrder)
	rebuildFavoriteRanks()
	v7 = normalizeBooleanMap(data.Owned)
	v8 = normalizeBooleanMap(data.CanUse)

	local selectedId = tonumber(data.SelectedId)

	if selectedId and type(Soundfonts[selectedId]) == "table" then
		PlayerVariables.Current_SoundfontID = selectedId
	end

	v11 = true

	for _, v12 in ipairs(v2) do
		v12.locked = not isOwned(v12.id, v12.soundfont) -- inferred equivalent call
		v12.row:SetAttribute("Locked", v12.locked)
	end

	refreshSelectedSoundfont()
	applyFilters()
end

local function invokeSoundfontRemote(remoteFunction, ...)
	if not (remoteFunction and remoteFunction:IsA("RemoteFunction")) then
		return false, "Remote unavailable", nil
	end

	local v12 = table.pack(...)
	local success, result, v13, v14 = pcall(function()
		return remoteFunction:InvokeServer(table.unpack(v12, 1, v12.n))
	end)

	if success then
		return result == true, v13, v14
	end

	return false, tostring(result), nil
end

local function loadSoundfontState()
	for _ = 1, 10 do
		local v12, _, v13 = invokeSoundfontRemote(getSoundfontState)

		if type(v13) == "table" then
			applySoundfontState(v13)
		end

		if v12 then
			return
		end

		task.wait(1)
	end

	v11 = true
end

local function toggleFavorite(id)
	local v12 = tostring(id)

	if v6[v12] then
		return
	end

	v6[v12] = true
	local array = cloneArray(v4) -- inferred equivalent call
	local v13 = v3[v12] ~= true
	v3[v12] = v13 and true or nil

	if v13 then
		appendFavoriteOrderKey(v12) -- inferred equivalent call
	else
		removeFavoriteOrderKey(v12)
	end

	refreshSelectedSoundfont()
	applyFilters()

	task.spawn(function()
		local v14, _, v15 = invokeSoundfontRemote(toggleSoundfontFavorite, id, v13)

		if type(v15) == "table" then
			applySoundfontState(v15)
		end

		if not v14 and v11 then
			v3[v12] = not v13 or nil
			v4 = array
			rebuildFavoriteRanks()
			refreshSelectedSoundfont()
			applyFilters()
		end

		v6[v12] = nil
	end)
end

local function selectSoundfont(data)
	if data.locked then
		return
	end

	local current_SoundfontID = tonumber(PlayerVariables.Current_SoundfontID) or 1
	PlayerVariables.Current_SoundfontID = tonumber(data.id) or data.id

	if PianoLogic.PrewarmSoundfont then
		PianoLogic.PrewarmSoundfont(data.soundfont.AssetIds, data.soundfont.PacketType)
	end

	refreshSelectedSoundfont()

	task.spawn(function()
		local v12, _, v13 = invokeSoundfontRemote(setSelectedSoundfont, data.id)

		if type(v13) == "table" then
			applySoundfontState(v13)
		end

		if not v12 and v11 then
			PlayerVariables.Current_SoundfontID = current_SoundfontID
			refreshSelectedSoundfont()
		end
	end)
end

local function buildCategoryButtons()
	for _, button in ipairs(categoryList:GetChildren()) do
		if button:IsA("GuiButton") and button ~= categoryTemplate then
			button:Destroy()
		end
	end

	table.clear(clones)
	local categoryOrder = getCategoryOrder() -- inferred equivalent call

	for i, v12 in ipairs(categoryOrder) do
		local clone = categoryTemplate:Clone()
		clone.Name = "Category_" .. tostring(v12):gsub("%W", "")
		clone.Visible = true
		clone.Text = formatCategoryLabel(v12) -- inferred equivalent call
		clone.LayoutOrder = i
		clone:SetAttribute("Category", v12)
		clone.Parent = categoryList
		clones[v12] = clone

		clone.Activated:Connect(function()
			v9 = v12
			refreshCategoryButtons()
			applyFilters()
		end)
	end

	refreshCategoryButtons()
end

local function buildSoundfontRows()
	for _, button in ipairs(scrollingFrame:GetChildren()) do
		if button:IsA("GuiButton") and button ~= soundfontRowTemplate then
			button:Destroy()
		end
	end

	table.clear(v2)

	local v12 = {}

	for k, soundfont in pairs(Soundfonts) do
		if not (type(k) == "number" and type(soundfont) == "table" and soundfont.Name) then
			continue
		end

		table.insert(v12, {
			id = k,
			soundfont = soundfont,
			sortName = tostring(soundfont.Name):lower()
		})
	end

	table.sort(v12, function(a, b): boolean
		if a.sortName == b.sortName then
			return (tonumber(a.id) or 1e999) < (tonumber(b.id) or 1e999)
		end

		return a.sortName < b.sortName
	end)

	for i, v13 in ipairs(v12) do
		local id = v13.id
		local soundfont = v13.soundfont
		local category = getCategory(soundfont) -- inferred equivalent call
		local access = getAccess(soundfont)
		local locked = not isOwned(id, soundfont) -- inferred equivalent call

		local clone = soundfontRowTemplate:Clone()
		clone.Name = "Soundfont_" .. tostring(id)
		clone.Visible = true
		clone.LayoutOrder = i
		clone:SetAttribute("SoundfontId", id)
		clone:SetAttribute("Category", category)
		clone:SetAttribute("AccessType", access.Type)
		clone:SetAttribute("Price", access.Price)
		clone:SetAttribute("Currency", access.Currency)
		clone:SetAttribute("Locked", locked)
		clone.Parent = scrollingFrame

		local nameLabel = clone:FindFirstChild("NameLabel")

		if nameLabel then
			nameLabel.Text = tostring(soundfont.Name)
		end

		local metaLabel = clone:FindFirstChild("MetaLabel")

		if metaLabel then
			metaLabel.Text = category
		end

		local priceLabel = clone:FindFirstChild("PriceLabel")

		if priceLabel then
			local v14 = id == 1
			priceLabel.Visible = v14 or access.Type == "Paid"

			if v14 then
				priceLabel.Text = "Default"
				priceLabel.BackgroundColor3 = color10
				priceLabel.TextColor3 = color11
			else
				priceLabel.Text = access.Price > 0 and string.format("%d %s", access.Price, access.Currency) or "Paid"
			end
		end

		local favoriteButton = clone:FindFirstChild("FavoriteButton")
		local v14 = {
			id = id,
			soundfont = soundfont,
			row = clone,
			starButton = favoriteButton,
			category = category,
			locked = locked,
			defaultLayoutOrder = i,
			searchName = tostring(soundfont.Name):lower(),
			searchCategory = category:lower()
		}

		table.insert(v2, v14)

		clone.Activated:Connect(function()
			selectSoundfont(v14)
		end)

		if not (favoriteButton and favoriteButton:IsA("GuiButton")) then
			continue
		end

		local function handleFavoriteButton()
			toggleFavorite(id)
		end

		favoriteButton.Activated:Connect(handleFavoriteButton)
		favoriteButton.MouseButton1Click:Connect(handleFavoriteButton)
	end
end

buildCategoryButtons()
buildSoundfontRows()

if search then
	search:GetPropertyChangedSignal("Text"):Connect(applyFilters)
end

if close and close:IsA("GuiButton") then
	local function closePanel()
		releaseSearchFocus() -- inferred equivalent call
		parent.Visible = false
	end

	close.Activated:Connect(closePanel)
	close.MouseButton1Click:Connect(closePanel)
end

parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if parent.Visible then
		refreshSelectedSoundfont()
		applyFilters()
	else
		releaseSearchFocus() -- inferred equivalent call
	end
end)

refreshSelectedSoundfont()
applyFilters()
task.spawn(loadSoundfontState)

task.spawn(function()
	while parent.Parent do
		if (tonumber(PlayerVariables.Current_SoundfontID) or 1) ~= v10 then
			refreshSelectedSoundfont()
		end

		task.wait(0.25)
	end
end)