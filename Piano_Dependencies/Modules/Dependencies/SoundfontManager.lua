local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundUtils = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("SoundUtils"))

local SoundfontManager = {}

function SoundfontManager.ResolveNote(p, value)
	if type(p.CustomFunction) == "function" then
		local customFunction = p.CustomFunction(value)

		if customFunction and customFunction.asset then
			local asset = tonumber(customFunction.asset)
			local assetId = p.AssetIds[asset]

			if assetId then
				return "rbxassetid://" .. tostring(assetId), customFunction.timePosition or 0, customFunction.pitch or 1
			end
		end
	end

	local v = math.clamp(value, 1, #p.AssetIds)
	return "rbxassetid://" .. tostring(p.AssetIds[v]), 0, 1
end

local function normalizeId(value) -- 1 equivalent call inferred from this helper
	if typeof(value) == "number" then
		return "rbxassetid://" .. value
	end

	local v = tostring(value)
	local match = v:match("(%d+)$")

	if match then
		return "rbxassetid://" .. match
	end

	return v
end

local function isSoundLoaded(item): boolean -- 2 equivalent calls inferred from this helper
	return item.IsLoaded == true
end

function SoundfontManager.BuildSounds(options, p)
	local folder = Instance.new("Folder")
	folder.Name = "_SoundfontPreload_" .. HttpService:GenerateGUID(false)
	folder.Parent = p or game:GetService("SoundService")

	local idSet = {}
	local result = {}

	for _, v in ipairs(options or {}) do
		local id = normalizeId(v) -- inferred equivalent call

		if idSet[id] then
			continue
		end

		idSet[id] = true
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = 0
		sound.PlayOnRemove = false
		sound.Parent = folder
		table.insert(result, sound)
	end

	return folder, result
end

function SoundfontManager.PreloadSounds(list, callback, value)
	if list and #list ~= 0 then
		local count = #list

		local v = typeof(value) == "number" and value or 3

		pcall(function()
			ContentProvider:PreloadAsync(list)
		end)

		local lastTime = os.clock()

		while os.clock() - lastTime < v do
			local count2 = 0

			for _, item in ipairs(list) do
				if isSoundLoaded(item) then -- inferred equivalent call
					count2 += 1
				end
			end

			if callback then
				callback(count2, count)
			end

			if count2 == count then
				break
			end

			task.wait(0.1)
		end

		local count2 = 0

		for _, item in ipairs(list) do
			if isSoundLoaded(item) then -- inferred equivalent call
				count2 += 1
			end
		end

		if callback then
			callback(count2, count)
		end

		return count2 == count, count2
	end

	if callback then
		callback(0, 0)
	end

	return true, 0
end

function SoundfontManager.PreloadAllSoundfonts(items, callback, value)
	local v = 1
	local v2 = {}

	while items[v] do
		local item = items[v]

		if item and type(item) == "table" and item.AssetIds and item.Name then
			table.insert(v2, { name = tostring(item.Name), ids = item.AssetIds })
		end

		v += 1
	end

	if #v2 == 0 then
		for _, item in pairs(items) do
			if item and type(item) == "table" and item.AssetIds and item.Name then
				table.insert(v2, { name = tostring(item.Name), ids = item.AssetIds })
			end
		end
	end

	if #v2 == 0 then
		return true, 0
	end

	local v3 = value or 8
	local v4 = true

	for _, v5 in ipairs(v2) do
		local name = v5.name
		local ids = v5.ids or {}

		local sounds, v6 = SoundfontManager.BuildSounds(ids, game:GetService("SoundService"))
		local preloadSounds, v7 = SoundfontManager.PreloadSounds(v6, nil, v3)

		if sounds and sounds.Parent then
			sounds:Destroy()
		end

		if callback then
			callback(name, preloadSounds, v7, #ids)
		end

		if not preloadSounds then
			v4 = false
		end

		task.wait(0.3)
	end

	return v4, #v2
end

function SoundfontManager.PreloadWithSoundUtils(items, callback)
	local v = 1
	local v2 = {}

	while items[v] do
		local item = items[v]

		if item and type(item) == "table" and item.AssetIds and item.Name then
			table.insert(v2, { name = tostring(item.Name), ids = item.AssetIds })
		end

		v += 1
	end

	if #v2 == 0 then
		for _, item in pairs(items) do
			if item and type(item) == "table" and item.AssetIds and item.Name then
				table.insert(v2, { name = tostring(item.Name), ids = item.AssetIds })
			end
		end
	end

	if #v2 == 0 then
		return true, 0
	end

	local v3 = #v2

	local preloader = SoundUtils.newPreloader()

	for _, v4 in ipairs(v2) do
		for _, v5 in ipairs(v4.ids or {}) do
			local v6 = tostring(v5)

			if not v6:match("^rbxassetid://") then
				v6 = "rbxassetid://" .. v6
			end

			preloader:Add(v6)
		end
	end

	local v4 = pcall(function()
		preloader:LoadAndWait()
	end)

	if callback then
		for _, v5 in ipairs(v2) do
			callback(v5.name, v4, #v5.ids, #v5.ids)
		end
	end

	return v4, v3
end

return SoundfontManager