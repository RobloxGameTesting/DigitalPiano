local categoryOrder = {}
local categories = {}
local namesByOrder = {}
local Soundfonts = {}

local defaultAccess = { Type = "Free", Price = 0, Currency = "Notes", ShopItemId = "" }

for _, v in ipairs({ "Favorites", "All" }) do
	table.insert(categoryOrder, v)
end

for _, v in ipairs({
	{ Name = "Grand Piano", Order = 1 },
	{ Name = "Electric Piano", Order = 2 },
	{ Name = "Percussion", Order = 3 },
	{ Name = "Strings", Order = 4 },
	{ Name = "Plucked", Order = 5 },
	{ Name = "Wind", Order = 6 },
	{ Name = "Brass", Order = 7 },
	{ Name = "Organ", Order = 8 },
	{ Name = "Synth", Order = 9 },
	{ Name = "Meme", Order = 10 }
}) do
	categories[v.Name] = v
	namesByOrder[v.Order] = v.Name
	table.insert(categoryOrder, v.Name)
end

Soundfonts.CategoryOrder = categoryOrder
Soundfonts.CategoryModules = namesByOrder
Soundfonts.Categories = categories
Soundfonts.DefaultAccess = defaultAccess

local function normalizeAccess(access)
	local v = type(access) == "table" and access or defaultAccess
	local kind = tostring(v.Type or defaultAccess.Type)

	return {
		Type = kind ~= "Paid" and "Free" or kind,
		Price = math.max(0, (math.floor(tonumber(v.Price) or defaultAccess.Price))),
		Currency = tostring(v.Currency or defaultAccess.Currency),
		ShopItemId = tostring(v.ShopItemId or defaultAccess.ShopItemId)
	}
end

local function getCategoryModules()
	local nameSet = {}
	local categoryModules = {}

	for _, moduleScript in ipairs(script:GetChildren()) do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local v = categories[moduleScript.Name]

		if v then
			nameSet[moduleScript.Name] = true
			table.insert(categoryModules, {
				Name = moduleScript.Name,
				Order = v.Order,
				Module = moduleScript
			})
		else
			warn("[Soundfonts] Ignoring unrecognized category module: " .. moduleScript.Name)
		end
	end

	for _, v in ipairs(namesByOrder) do
		if not nameSet[v] then
			warn("[Soundfonts] Missing category module: " .. v)
		end
	end

	table.sort(categoryModules, function(a, b): boolean
		return a.Order < b.Order
	end)

	return categoryModules
end

local function registerSoundfont(name, id, state)
	if state == false then
		return
	end

	if type(id) ~= "number" then
		warn("[Soundfonts] Ignoring non-numeric soundfont id in " .. name .. ": " .. tostring(id))
		return
	end

	if type(state) ~= "table" then
		warn("[Soundfonts] Ignoring invalid soundfont row " .. tostring(id) .. " in " .. name)
		return
	end

	if type(state.Name) ~= "string" or state.Name == "" then
		warn("[Soundfonts] Ignoring unnamed soundfont id " .. tostring(id) .. " in " .. name)
		return
	end

	if Soundfonts[id] ~= nil then
		warn("[Soundfonts] Duplicate soundfont id " .. tostring(id) .. " in category " .. name .. " (" .. state.Name .. ")")
		return
	end

	state.Id = id
	state.Category = name
	state.Access = normalizeAccess(state.Access)
	Soundfonts[id] = state
end

local function loadCategory(p)
	local success, module = pcall(require, p.Module)

	if not success then
		warn("[Soundfonts] Failed to load category module " .. p.Name .. ": " .. tostring(module))
		return
	end

	if type(module) ~= "table" then
		warn("[Soundfonts] Category module did not return a table: " .. p.Name)
		return
	end

	for k, v in pairs(module) do
		registerSoundfont(p.Name, k, v)
	end
end

for _, v in ipairs(getCategoryModules()) do
	loadCategory(v)
end

return Soundfonts