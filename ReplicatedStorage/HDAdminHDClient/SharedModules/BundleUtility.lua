local BundleUtility = {}
local HDAdminMain = _G.HDAdminMain
local settings = HDAdminMain.settings
local Players = game:GetService("Players")
local AssetService = game:GetService("AssetService")
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}

function BundleUtility.register(value, p, p2)
	local v5 = { value, p, p2 }
	v3[value] = v5
	v4[tostring(p)] = v5
	local v6 = value:sub(1, 1):lower() .. value:sub(2)
	local rank = p2 and p2.Rank
	local function getPrefixes() -- 1 equivalent call inferred from this helper
		if rank then
			return { settings.Prefix }
		end

		return { settings.ChatPrefix, settings.UniversalPrefix }
	end

	local limitGroupPerMinute = not (rank and tonumber(rank) and rank > 0) and 10 or false
	local disabledByOwner

	if settings.DisableBoosterBundles then
		disabledByOwner = not rank
	else
		disabledByOwner = settings.DisableFunAndBoosterCommands and not rank
	end

	local name = tostring(v6)
	local override

	if not rank then
		override = "/" .. name
	end

	if not rank then
		name = "boosterBundle" .. name
	end

	return {
		Name = name,
		Override = override,
		Aliases = {},
		Prefixes = getPrefixes(), -- inferred equivalent call
		Rank = rank or "Booster",
		RankLock = false,
		Loopable = false,
		Tags = { "fun" },
		Groups = { "Bundle" },
		Description = "",
		Contributors = { "ForeverHD" },
		DisableChatUndo = false,
		LimitGroupPerMinute = limitGroupPerMinute,
		DisabledByOwner = disabledByOwner,
		Args = { "Player" },
		Function = function(_, list)
			local item = list[1]

			if not rank then
				HDAdminMain:GetModule("cf"):CheckFirstTimeUsing(item)
			end

			local _, _ = BundleUtility.apply(item, value)
		end,
		UnFunction = function(_, list)
			local item = list[1]
			BundleUtility.unapply(item)
		end
	}
end

function BundleUtility.getDetail(p)
	local v5 = tostring(p)
	return v3[v5] or v4[v5]
end

function BundleUtility.getWebsiteDescription(player)
	local name = player.Name
	local character = player.Character
	local hdOriginalDescription = character and character:FindFirstChild("HDOriginalDescription")

	if hdOriginalDescription then
		task.defer(function()
			hdOriginalDescription:Destroy()
		end)
		return hdOriginalDescription
	end

	local v5 = v[name]

	if v5 then
		return v5
	end

	local success, result = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)

	if not success then
		return false, result
	end

	v5 = result
	v[name] = v5
	player:GetPropertyChangedSignal("Parent"):Once(function()
		v[name] = nil
		v5:Destroy()
	end)

	return v5
end

function BundleUtility.unapply(player)
	local websiteDescription, v5 = BundleUtility.getWebsiteDescription(player)

	if not websiteDescription then
		return false, v5
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return false, "Missing humanoid"
	end

	local success, result = pcall(function()
		humanoid:ApplyDescriptionReset(websiteDescription, Enum.AssetTypeVerification.Always)
	end)
	return success, result
end

function BundleUtility.getBundleDescription(p)
	local v5 = tostring(p)
	local v6 = v2[v5]

	if v6 then
		return v6
	end

	local success, result = pcall(function()
		return AssetService:GetBundleDetailsAsync(p)
	end)

	if not success then
		return false, result
	end

	local id = nil

	for _, item in pairs(result.Items) do
		if item.Type == "UserOutfit" then
			id = item.Id
			break
		end
	end

	if not id then
		return false, "Missing Bundle Outfit"
	end

	local success2, result2 = pcall(function()
		return Players:GetHumanoidDescriptionFromOutfitId(id)
	end)

	if not success2 then
		return false, result2
	end

	v2[v5] = result2
	return result2
end

function BundleUtility.apply(player, p)
	local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid(player)

	if humanoid then
		humanoid:UnequipTools()
	end

	local detail = BundleUtility.getDetail(p)
	local v5 = detail[2]
	local v6 = detail[3] or {}
	local ignoreAccessories = v6.IgnoreAccessories
	local ignoreAccessorySet = {}

	if typeof(ignoreAccessories) == "table" then
		for _, ignoreAccessory in pairs(ignoreAccessories) do
			ignoreAccessorySet[ignoreAccessory] = true
		end
	end

	local ignoreBodyParts = v6.IgnoreBodyParts
	local ignoreBodyPartSet = {}

	if typeof(ignoreBodyParts) == "table" then
		for _, ignoreBodyPart in pairs(ignoreBodyParts) do
			ignoreBodyPartSet[ignoreBodyPart] = true
		end
	end

	local removeBodyParts = v6.RemoveBodyParts
	local removeBodyPartSet = {}

	if typeof(removeBodyParts) == "table" then
		for _, removeBodyPart in pairs(removeBodyParts) do
			removeBodyPartSet[removeBodyPart] = true
		end
	end

	local websiteDescription, v7 = BundleUtility.getWebsiteDescription(player)

	if not websiteDescription then
		return false, v7
	end

	local bundleDescription, v8 = BundleUtility.getBundleDescription(v5)

	if not bundleDescription then
		return false, v8
	end

	local clone = bundleDescription:Clone()

	for _, child in pairs(websiteDescription:GetChildren()) do
		if child:IsA("AccessoryDescription") then
			local name = child.AccessoryType.Name

			if ignoreAccessories ~= true and not ignoreAccessorySet[name] then
				local clone_2 = child:Clone()
				clone_2.Parent = clone
			end
		elseif child:IsA("BodyPartDescription") then
			local name = child.BodyPart.Name

			if ignoreBodyParts ~= true and not ignoreBodyPartSet[name] then
				local v9 = nil

				for _, bodyPartDescription in pairs(clone:GetChildren()) do
					if
						bodyPartDescription:IsA("BodyPartDescription")
						and bodyPartDescription.BodyPart == child.BodyPart
					then
						v9 = bodyPartDescription
					end
				end

				if v9 then
					v9.Color = child.Color
				else
					local clone_2 = child:Clone()
					clone_2.Parent = clone
				end
			end

			if removeBodyPartSet[name] then
				clone[name] = websiteDescription[name]
			end
		end
	end

	for _, v9 in pairs({
		"ClimbAnimation",
		"FallAnimation",
		"IdleAnimation",
		"JumpAnimation",
		"MoodAnimation",
		"RunAnimation",
		"SwimAnimation",
		"WalkAnimation",
		"GraphicTShirt",
		"Pants",
		"Shirt"
	}) do
		clone[v9] = websiteDescription[v9]
	end

	local function splitByCapitals(value) -- 1 equivalent call inferred from this helper
		return value:gsub("(%u)", " %1"):gsub("^%s", ""):split(" ")
	end

	local scaleLimit = settings.ScaleLimit or 5

	for k, v9 in pairs(v6) do
		if k:sub(1, 5) ~= "Scale" then
			continue
		end

		if scaleLimit < v9 then
			v9 = scaleLimit
		end

		local v10 = splitByCapitals(k:sub(6)) -- inferred equivalent call

		for _, v11 in pairs(v10) do
			clone[v11 .. "Scale"] = v9
		end
	end

	local character = player.Character
	local humanoid2 = character and character:FindFirstChild("Humanoid")
	local _hdOriginalDescription = character and character:FindFirstChild("HDOriginalDescription")

	local success, result = pcall(function()
		humanoid2:ApplyDescriptionReset(clone, Enum.AssetTypeVerification.Always)
	end)
	clone:Destroy()

	if success then
		return true
	end

	return false, result
end

return BundleUtility