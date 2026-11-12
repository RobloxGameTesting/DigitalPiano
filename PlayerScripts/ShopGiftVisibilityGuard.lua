local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local v = {}
local set = {}
local v2 = {}
local set2 = {}

local function normalizeText(value) -- 3 equivalent calls inferred from this helper
	return tostring(value or ""):lower()
end

local function addCatalogItem(data)
	if type(data) ~= "table" then
		return
	end

	local purchaseKind = data.purchaseKind or "ProfileStore"
	local v3 = type(data.title) == "string" and normalizeText(data.title) or "" -- inferred equivalent call
	local pianoItemId = type(data.pianoItemId) == "string" and data.pianoItemId or ""

	if purchaseKind == "ProfileStore" then
		if v3 ~= "" then
			table.insert(v, v3)
		end

		if pianoItemId ~= "" then
			set[pianoItemId] = true
		end
	else
		if v3 ~= "" then
			table.insert(v2, v3)
		end

		if pianoItemId ~= "" then
			set2[pianoItemId] = true
		end

		local assetId = tonumber(data.assetId) or 0

		if assetId > 0 then
			set2[tostring(assetId)] = true
		end
	end
end

local success, result = pcall(function()
	return require(ReplicatedStorage:WaitForChild("Monetization"):WaitForChild("PianoShopCatalog"))
end)

if success and type(result) == "table" and type(result.GetItems) == "function" then
	for _, v3 in ipairs(result.GetItems()) do
		addCatalogItem(v3)
	end
end

if #v == 0 then
	for _, v3 in ipairs({ "Pianist", "Composer", "Maestro", "Virtuoso", "Royal Bench" }) do
		table.insert(v, normalizeText(v3))
	end

	for _, v3 in ipairs({ "TagPianist", "TagComposer", "TagMaestro", "TagVirtuoso", "BenchRoyal" }) do
		set[v3] = true
	end
end

if #v2 == 0 then
	for _, v3 in ipairs({
		"Rainbow Visualizer",
		"VIP",
		"Great Pretender",
		"Grand Piano Lobby",
		"Push Tool",
		"Invisibility",
		"Third Eye",
		"Heart Particle Effect",
		"MIDI AutoPlayer",
		"x2 Notesplayed",
		"x2 Notes Currency",
		"+1 Recording Slot",
		"+5 Recording Slots",
		"+10 Recording Slots"
	}) do
		table.insert(v2, normalizeText(v3))
	end
end

local v3 = {
	"notes pack",
	"small notes pack",
	"medium notes pack",
	"large notes pack",
	"gamepass",
	"game pass",
	"developer product",
	"recording slot",
	"recording slots",
	"storage",
	"robux",
	utf8.char(57346)
}

local function buttonLooksLikeGift(button): boolean
	local text = normalizeText(button.Name) -- inferred equivalent call
	local v4 = button:IsA("TextButton") and normalizeText(button.Text) or "" -- inferred equivalent call
	return text:find("gift", 1, true) ~= nil or v4:find("gift", 1, true) ~= nil
end

local function collectText(folder)
	local v4 = { normalizeText(folder.Name) }

	for _, guiObject in ipairs(folder:GetDescendants()) do
		if guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
			table.insert(v4, normalizeText(guiObject.Text))
		end

		table.insert(v4, normalizeText(guiObject.Name))
	end

	return table.concat(v4, " ")
end

local function containsAny(value, list): boolean
	for _, item in ipairs(list) do
		if value:find(item, 1, true) then
			return true
		end
	end

	return false
end

local function isRobuxProductContext(p) -- 1 equivalent call inferred from this helper
	return containsAny(p, v3) or containsAny(p, v2)
end

local function isBroadGuiContainer(screenGui)
	return screenGui:IsA("ScreenGui")
		or screenGui.Name == "ShopGui"
		or screenGui.Name == "MerchBooth"
		or screenGui == PlayerGui
end

local function isNotesShopContext(screenGui): boolean
	for _ = 1, 8 do
		if
			not screenGui
			or screenGui:IsA("ScreenGui")
			or screenGui.Name == "ShopGui"
			or screenGui.Name == "MerchBooth"
			or screenGui == PlayerGui
		then
			break
		end

		if set2[screenGui.Name] then
			return false
		end

		if set[screenGui.Name] then
			return true
		end

		local v4 = collectText(screenGui)

		if isRobuxProductContext(v4) then -- inferred equivalent call
			return false
		end

		if containsAny(v4, v) then
			return true
		end

		screenGui = screenGui.Parent
	end

	return false
end

local function hideNotesGiftButton(button)
	if not (button:IsA("GuiButton") and buttonLooksLikeGift(button)) then
		return
	end

	if isNotesShopContext(button.Parent) then
		button.Visible = false
		button.Active = false
		button.AutoButtonColor = false
	end
end

local function scan(folder) -- 1 equivalent call inferred from this helper
	for _, button in ipairs(folder:GetDescendants()) do
		if not (button:IsA("GuiButton") and buttonLooksLikeGift(button) and isNotesShopContext(button.Parent)) then
			continue
		end

		button.Visible = false
		button.Active = false
		button.AutoButtonColor = false
	end
end

PlayerGui.DescendantAdded:Connect(function(descendant)
	task.defer(function()
		local button = descendant

		if button:IsA("GuiButton") then
			if not buttonLooksLikeGift(button) then
				return
			end

			if isNotesShopContext(button.Parent) then
				button.Visible = false
				button.Active = false
				button.AutoButtonColor = false
			end
		end
	end)
end)
scan(PlayerGui) -- inferred equivalent call