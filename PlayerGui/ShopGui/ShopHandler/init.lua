local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local OpenShop = ReplicatedStorage2:FindFirstChild("OpenShop")

if not (OpenShop and OpenShop:IsA("BindableEvent")) then
	if OpenShop then
		OpenShop:Destroy()
	end

	OpenShop = Instance.new("BindableEvent")
	OpenShop.Name = "OpenShop"
	OpenShop.Parent = ReplicatedStorage2
end

local v = false
local flag = false
local v2 = nil
local fn

local function requestOpenShop(p) -- 1 equivalent call inferred from this helper
	if v and fn then
		fn(p)
		return
	end

	v2 = p
	flag = true
end

local connectionsByBindableEvent = {}

local function bindOpenShopEvent(bindableEvent) -- 2 equivalent calls inferred from this helper
	if bindableEvent and bindableEvent:IsA("BindableEvent") and not connectionsByBindableEvent[bindableEvent] then
		connectionsByBindableEvent[bindableEvent] = bindableEvent.Event:Connect(requestOpenShop)
	end
end

bindOpenShopEvent(OpenShop) -- inferred equivalent call
ReplicatedStorage2.ChildAdded:Connect(function(bindableEvent)
	if bindableEvent.Name == "OpenShop" and bindableEvent and bindableEvent:IsA("BindableEvent") then
		if connectionsByBindableEvent[bindableEvent] then
			return
		end

		connectionsByBindableEvent[bindableEvent] = bindableEvent.Event:Connect(requestOpenShop)
	end
end)

local LocalPlayer = Players.LocalPlayer
local MerchBooth = require(ReplicatedStorage2:WaitForChild("MerchBooth"))
local merchBooth = ReplicatedStorage2:WaitForChild("MerchBooth")
local clientStore = require(merchBooth.Modules.clientStore)
local setItemInfo = require(merchBooth.Actions.setItemInfo)
local updateItemInfo = require(merchBooth.Actions.updateItemInfo)
local Monetization = ReplicatedStorage2:WaitForChild("Monetization")
local PianoShopCatalog = require(Monetization:WaitForChild("PianoShopCatalog"))
local ExperienceCreatorInfo = require(Monetization:WaitForChild("ExperienceCreatorInfo"))
local Items = ReplicatedStorage2:WaitForChild("Items")
local Modules = ReplicatedStorage2:WaitForChild("Modules")
local PianoOnFireVfxBuilder = require(Modules:WaitForChild("PianoOnFireVfxBuilder"))
local Pianos = workspace:WaitForChild("Pianos")

local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local getPurchases = remotes:WaitForChild("GetPurchases")
local getItemStats = remotes:WaitForChild("GetItemStats")
local shopPurchasesUpdated = remotes:WaitForChild("ShopPurchasesUpdated")

local v3 = nil
local count = 0
local lastTime = 0
local flag2 = false
local v4 = ExperienceCreatorInfo.Get()

local v5 = 0
local v6 = nil
local v7 = {
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

local pianoMerchBoothClientAssets = Instance.new("Folder")
pianoMerchBoothClientAssets.Name = "PianoMerchBoothClientAssets"
pianoMerchBoothClientAssets.Parent = script

local function formatNumber(p)
	local v8 = tostring((math.max(0, (math.floor(tonumber(p) or 0)))))

	repeat
		local v9
		v8, v9 = v8:gsub("^(%d+)(%d%d%d)", "%1,%2")
	until v9 == 0

	return v8
end

local function buildExistingText(data, data2)
	if type(data) ~= "table" or data.trackExisting ~= true and (type)(data2) ~= "table" then
		return nil
	end

	local existingCount = (type)(data2) == "table" and (data2.ExistingCount or data2.TotalExisting)
		or data.limitedExisting
	local v8

	if data.limited == true then
		v8 = true
	elseif (type)(data2) == "table" then
		v8 = data2.Limited == true
	else
		v8 = false
	end

	local v9

	if data.developerExclusive == true then
		v9 = true
	elseif (type)(data2) == "table" then
		v9 = data2.DeveloperExclusive == true
	else
		v9 = false
	end

	if v8 then
		local maxSupply = (type)(data2) == "table" and data2.MaxSupply or data.limitedMax
		return string.format(
			"%s | %s / %s existing",
			data.limitedLabel or "Limited Edition",
			formatNumber(existingCount),
			formatNumber(maxSupply)
		)
	end

	if not v9 then
		return formatNumber(existingCount) .. " existing"
	end

	local developerLabel = data.developerLabel or (type)(data2) == "table" and data2.DeveloperLabel or "Developer Item"
	return string.format("%s | %s existing", developerLabel, formatNumber(existingCount))
end

local function configureMerchBooth()
	MerchBooth.configure({
		backgroundColor = Color3.fromRGB(13, 15, 20),
		scrollBarColor = Color3.fromRGB(74, 137, 255),
		cornerRadius = UDim.new(0, 14),
		cornerRadiusSmall = UDim.new(0, 8),
		textSize = 14,
		textFont = Enum.Font.Gotham,
		textColor = Color3.fromRGB(238, 241, 246),
		secondaryTextColor = Color3.fromRGB(158, 166, 178),
		headerTextSize = 18,
		headerFont = Enum.Font.GothamMedium,
		titleTextSize = 28,
		titleFont = Enum.Font.GothamBold,
		buttonColor = Color3.fromRGB(45, 118, 235),
		buttonTextColor = Color3.fromRGB(255, 255, 255),
		secondaryButtonColor = Color3.fromRGB(30, 35, 44),
		secondaryButtonTextColor = Color3.fromRGB(255, 255, 255),
		inactiveButtonColor = Color3.fromRGB(78, 86, 101),
		inactiveButtonTextColor = Color3.fromRGB(190, 198, 210),
		proximityButtonActivationDistance = 10,
		proximityButtonExclusivity = Enum.ProximityPromptExclusivity.OnePerButton,
		proximityButtonOffset = Vector2.new(0, 0),
		proximityButtonRequiresLineOfSight = false,
		proximityButtonPulseCount = 3,
		particleEmitterTemplate = merchBooth:WaitForChild("ParticleEmitter"),
		useFilters = false,
		disableCharacterMovement = false,
		hideOtherUis = true,
		closeWhenFarFromPrompt = false
	})

	MerchBooth.toggleCatalogButton(false)
	MerchBooth.setCatalogSort(function(p, p2): boolean
		return (p.layoutOrder or 0) < (p2.layoutOrder or 0)
	end)
end

local function getInfoType(productTypeName) -- 1 equivalent call inferred from this helper
	if productTypeName == "GamePass" then
		return Enum.InfoType.GamePass
	end

	return Enum.InfoType.Product
end

local function getMarketplaceInfo(assetId, infoType)
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(assetId, infoType)
	end)

	if success and type(result) == "table" then
		return
			math.max(0, (math.floor(tonumber(result.PriceInRobux) or 0))),
			tonumber(result.IconImageAssetId) or assetId
	end

	return 0, assetId
end

local function parseCustomImageId(value)
	if typeof(value) == "number" then
		local v8 = math.floor(value)

		if v8 > 0 then
			return v8, "rbxassetid://" .. tostring(v8)
		end
	elseif typeof(value) == "string" then
		local v8 = value:match("^%s*(.-)%s*$") or ""
		local v9 = v8:match("^rbxassetid://(%d+)$") or v8:match("^(%d+)$")

		if v9 then
			local v10 = tonumber(v9)

			if v10 and v10 > 0 then
				return v10, "rbxassetid://" .. v9
			end
		end
	end

	return nil, nil
end

local function getCustomThumbnail(p)
	local v8, v9 = parseCustomImageId(p)

	if not v8 then
		return nil, nil
	end

	if pcall(function()
		MarketplaceService:GetProductInfo(v8, Enum.InfoType.Asset)
	end) then
		return v8, v9
	end

	return nil, nil
end

local function getViewedPianoItemId() -- 11 equivalent calls inferred from this helper
	local merchBoothOpen, v8 = MerchBooth.isMerchBoothOpen()

	if merchBoothOpen and v8 then
		local state = clientStore:getState()

		local v9 = state and state.server and state.server.itemInfo and state.server.itemInfo[tostring(v8)]
		return v9 and v9.pianoItemId or nil
	end

	return nil
end

local function removeLocalFireEyesPreview()
	local character = LocalPlayer.Character

	if not character then
		return
	end

	for _, child in ipairs(character:GetChildren()) do
		if child.Name == "LocalFireEyesShopPreview" then
			child:Destroy()
		end
	end
end

local function applyLocalFireEyesPreview()
	if LocalPlayer:GetAttribute("SelectedEffect") == "EffectFireEyes" then
		removeLocalFireEyesPreview()
		return
	end

	local character = LocalPlayer.Character
	local head = character and character:FindFirstChild("Head")
	local fireEyesEffect = Items:FindFirstChild("FireEyesEffect")

	if not (character and head and head:IsA("BasePart") and fireEyesEffect) then
		return
	end

	if character:FindFirstChild("LocalFireEyesShopPreview") then
		return
	end

	local localFireEyesShopPreview = Instance.new("Folder")
	localFireEyesShopPreview.Name = "LocalFireEyesShopPreview"
	localFireEyesShopPreview.Parent = character

	for _, part in ipairs(fireEyesEffect:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()
		local v8 = clone:GetAttribute("HeadOffsetCFrame")

		if typeof(v8) ~= "CFrame" then
			v8 = CFrame.new(0, 0.15, -0.52)
		end

		clone.Anchored = false
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Massless = true
		clone.Transparency = 1
		clone.CFrame = head.CFrame * v8
		clone.Parent = localFireEyesShopPreview

		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = head
		weldConstraint.Part1 = clone
		weldConstraint.Parent = clone

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:Emit(80)
		end
	end
end

local function removeLocalPianoOnFirePreview()
	if v6 then
		PianoOnFireVfxBuilder.DestroyEffect(v6, "LocalPianoOnFireShopPreview")
		v6 = nil
	else
		for _, child in ipairs(Pianos:GetChildren()) do
			PianoOnFireVfxBuilder.DestroyEffect(child, "LocalPianoOnFireShopPreview")
		end
	end
end

local function getLocalSeatedPiano()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local model = humanoid and humanoid.SeatPart

	if not model then
		return nil
	end

	while model do
		if model:IsA("Model") and model.Parent == Pianos then
			return model
		end

		if model == workspace then
			break
		end

		model = model.Parent
	end

	return nil
end

local function applyLocalPianoOnFirePreview()
	if LocalPlayer:GetAttribute("SelectedPianoEffect") == "EffectPianoOnFire" then
		removeLocalPianoOnFirePreview()
		return
	end

	local localSeatedPiano = getLocalSeatedPiano()

	if not PianoOnFireVfxBuilder.IsSupportedPiano(localSeatedPiano) then
		removeLocalPianoOnFirePreview()
		return
	end

	if v6 and v6 ~= localSeatedPiano then
		PianoOnFireVfxBuilder.DestroyEffect(v6, "LocalPianoOnFireShopPreview")
		v6 = nil
	end

	if localSeatedPiano:FindFirstChild("LocalPianoOnFireShopPreview") then
		v6 = localSeatedPiano
	else
		v6 = PianoOnFireVfxBuilder.CreateEffectFolder(localSeatedPiano, {
				FolderName = "LocalPianoOnFireShopPreview",
				Owner = LocalPlayer,
				IsLocalPreview = true
			})
			and localSeatedPiano
			or nil
	end
end

local function syncLocalShopEffectPreviews(p) -- 1 equivalent call inferred from this helper
	local now = os.clock()

	if not p and now - v5 < 0.25 then
		return
	end

	v5 = now
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end
end

local function findBenchPreviewAsset(pianoItemId)
	local v8 = v7[pianoItemId]

	if not v8 then
		return nil
	end

	for _, childName in ipairs(v8) do
		local child = Items:FindFirstChild(childName)

		if child then
			return child
		end
	end

	return nil
end

local function getModelForViewport(model) -- 2 equivalent calls inferred from this helper
	if model:IsA("Model") then
		return model
	end

	local model2 = Instance.new("Model")
	model2.Name = model.Name
	model.Parent = model2
	return model2
end

local function prepareViewportObject(folder)
	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("BaseScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		elseif descendant:IsA("Humanoid") then
			descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			descendant.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
		elseif descendant:IsA("BillboardGui") or descendant:IsA("ForceField") then
			descendant:Destroy()
		end
	end
end

local function makePreviewGlow(cframe, p)
	local part = Instance.new("Part")
	part.Name = "FireEyesPreviewGlow" .. tostring(p)
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 238, 120)
	part.Size = Vector3.new(0.28, 0.28, 0.28)
	part.CFrame = cframe

	local part2 = Instance.new("Part")
	part2.Name = "FireEyesPreviewFlame" .. tostring(p)
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanTouch = false
	part2.CanQuery = false
	part2.Material = Enum.Material.Neon
	part2.Color = Color3.fromRGB(255, 94, 0)
	part2.Size = Vector3.new(0.12, 0.36, 0.12)
	part2.CFrame = cframe * CFrame.new(0, 0.22, 0)
	part2.Parent = part

	return part
end

local function attachFireEyesToPreview(fireEyesPreview)
	local fireEyesEffect = Items:FindFirstChild("FireEyesEffect")
	local head = fireEyesPreview and fireEyesPreview:FindFirstChild("Head", true)

	if not (fireEyesEffect and head and head:IsA("BasePart")) then
		return
	end

	local count2 = 0

	for _, part in ipairs(fireEyesEffect:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()
		local v8 = clone:GetAttribute("HeadOffsetCFrame")

		if typeof(v8) ~= "CFrame" then
			v8 = CFrame.new(0, 0.15, -0.52)
		end

		clone.Anchored = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Massless = true
		clone.Transparency = 1
		clone.CFrame = head.CFrame * v8

		for _, emitter in ipairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true
			emitter:SetAttribute("EmitCount", 80)
		end

		clone.Parent = fireEyesPreview

		count2 += 1
	end
end

local function cloneLocalCharacterForPreview()
	local character = LocalPlayer.Character

	if not character then
		return nil
	end

	local archivable = character.Archivable
	character.Archivable = true
	local fireEyesPreview = character:Clone()
	character.Archivable = archivable

	if not fireEyesPreview then
		return nil
	end

	fireEyesPreview.Name = "FireEyesPreview"
	prepareViewportObject(fireEyesPreview)
	local humanoidRootPart = fireEyesPreview:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		fireEyesPreview.PrimaryPart = humanoidRootPart
	end

	fireEyesPreview:PivotTo(CFrame.Angles(0, 3.141592653589793, 0))

	local head = fireEyesPreview:FindFirstChild("Head", true)

	if head and head:IsA("BasePart") then
		for _, part in ipairs(fireEyesPreview:GetDescendants()) do
			if not (part:IsA("BasePart") and part ~= head) then
				continue
			end

			local name = part.Name:lower()

			if not (name:find("leg", 1, true) or name:find("foot", 1, true) or name:find("root", 1, true)) then
				continue
			end

			part:Destroy()
		end
	end

	attachFireEyesToPreview(fireEyesPreview)
	return fireEyesPreview
end

local function makeFireEyesPreviewObject() -- 1 equivalent call inferred from this helper
	local localCharacterForPreview = cloneLocalCharacterForPreview()

	if not localCharacterForPreview then
		return nil
	end

	localCharacterForPreview.Parent = pianoMerchBoothClientAssets
	return localCharacterForPreview
end

local function createPianoOnFirePreviewPart(parent, name, size, cframe, color, p)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = p or Enum.Material.SmoothPlastic
	part.Parent = parent
	return part
end

local function enablePreviewVfx(folder)
	if folder:IsA("ParticleEmitter") then
		folder.Enabled = true
	elseif folder:IsA("Light") then
		folder.Enabled = true
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
		elseif descendant:IsA("Light") then
			descendant.Enabled = true
		end
	end
end

local function attachPianoOnFirePreviewVfx(parent)
	local pianoOnFireEffect = Items:FindFirstChild("PianoOnFireEffect")
	local bodyTop_Flames = pianoOnFireEffect
		and (pianoOnFireEffect:FindFirstChild("BodyTop_Flames") or pianoOnFireEffect:FindFirstChildWhichIsA("BasePart"))
	local v8 = false

	if bodyTop_Flames then
		for _, child in ipairs(bodyTop_Flames:GetChildren()) do
			local clone = child:Clone()
			enablePreviewVfx(clone)
			clone.Parent = parent
			v8 = true
		end
	end

	if not v8 then
		local fallbackFlames = Instance.new("ParticleEmitter")
		fallbackFlames.Name = "FallbackFlames"
		fallbackFlames.Color = ColorSequence.new(Color3.fromRGB(255, 218, 92), Color3.fromRGB(255, 74, 18))
		fallbackFlames.LightEmission = 0.75
		fallbackFlames.Lifetime = NumberRange.new(0.45, 0.9)
		fallbackFlames.Rate = 45
		fallbackFlames.Speed = NumberRange.new(1.2, 3.4)
		fallbackFlames.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.35),
			NumberSequenceKeypoint.new(0.45, 0.8),
			NumberSequenceKeypoint.new(1, 0.08)
		})

		fallbackFlames.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(1, 1)
		})

		fallbackFlames.Parent = parent
	end

	local pianoOnFirePreviewGlow = parent:FindFirstChildWhichIsA("PointLight") or Instance.new("PointLight")
	pianoOnFirePreviewGlow.Name = "PianoOnFirePreviewGlow"
	pianoOnFirePreviewGlow.Color = Color3.fromRGB(255, 110, 32)
	pianoOnFirePreviewGlow.Brightness = 2.2
	pianoOnFirePreviewGlow.Range = 7
	pianoOnFirePreviewGlow.Enabled = true
	pianoOnFirePreviewGlow.Parent = parent
end

local function makePianoOnFirePreviewObject() -- 1 equivalent call inferred from this helper
	local pianoOnFirePreviewPiano = Items:FindFirstChild("PianoOnFirePreviewPiano")

	if not pianoOnFirePreviewPiano then
		return nil
	end

	local pianoOnFirePreview = getModelForViewport(pianoOnFirePreviewPiano:Clone()) -- inferred equivalent call
	pianoOnFirePreview.Name = "PianoOnFirePreview"
	prepareViewportObject(pianoOnFirePreview)
	enablePreviewVfx(pianoOnFirePreview)
	pianoOnFirePreview.Parent = pianoMerchBoothClientAssets
	return pianoOnFirePreview
end

local function getGamepassPreviewTexture(p, p2) -- 1 equivalent call inferred from this helper
	local assetId = tonumber(p.assetId) or 0
	local v8 = tonumber(p2) or 0

	if v8 > 0 and v8 ~= assetId then
		return "rbxassetid://" .. tostring(v8)
	end

	if assetId > 0 then
		return "rbxthumb://type=GamePass&id=" .. tostring(assetId) .. "&w=420&h=420"
	end

	return ""
end

local function makeGamepassCoinPreview(data, p)
	local model = Instance.new("Model")
	model.Name = tostring(data.assetId) .. "_Preview"

	local icon = Instance.new("Part")
	icon.Name = "Icon"
	icon.Anchored = true
	icon.CanCollide = false
	icon.CanTouch = false
	icon.CanQuery = false
	icon.Material = Enum.Material.SmoothPlastic
	icon.Color = Color3.fromRGB(255, 255, 255)
	icon.Transparency = 1
	icon.Size = Vector3.new(3.1, 3.1, 0.12)
	icon.CFrame = CFrame.new(0, 0, 0)
	icon.Parent = model
	local gamepassPreviewTexture = getGamepassPreviewTexture(data, p) -- inferred equivalent call

	if gamepassPreviewTexture ~= "" then
		local front = Instance.new("Decal")
		front.Name = "Front"
		front.Face = Enum.NormalId.Front
		front.Texture = gamepassPreviewTexture
		front.Parent = icon

		local back = front:Clone()
		back.Name = "Back"
		back.Face = Enum.NormalId.Back
		back.Parent = icon
	end

	model.PrimaryPart = icon
	model.Parent = pianoMerchBoothClientAssets
	return model
end

local function makeViewportObject(data, p)
	if (data.purchaseKind or "ProfileStore") == "Gamepass" then
		return makeGamepassCoinPreview(data, p)
	end

	local v8 = data.displayType == "Bench" and findBenchPreviewAsset(data.pianoItemId)

	if v8 then
		local modelForViewport = getModelForViewport(v8:Clone()) -- inferred equivalent call
		modelForViewport.Name = tostring(data.assetId) .. "_Preview"
		prepareViewportObject(modelForViewport)
		modelForViewport.Parent = pianoMerchBoothClientAssets
		return modelForViewport
	elseif data.displayType == "Effect" and data.pianoItemId == "EffectFireEyes" then
		return makeFireEyesPreviewObject() -- inferred equivalent call
	else
		if data.displayType ~= "Piano Effect" or data.pianoItemId ~= "EffectPianoOnFire" then
			return nil
		end

		return makePianoOnFirePreviewObject() -- inferred equivalent call
	end
end

local function registerCatalogItems()
	if flag2 then
		return
	end

	flag2 = true

	for _, v8 in ipairs(PianoShopCatalog.GetItems()) do
		local purchaseKind = v8.purchaseKind or "ProfileStore"
		local infoType = getInfoType(v8.productTypeName) -- inferred equivalent call
		local price = math.max(0, (math.floor(tonumber(v8.price) or 0)))
		local icon = v8.icon or v8.thumbnailImage
		local v9, thumbnailImage = parseCustomImageId(icon)

		if v9 then
			local v10 = v9

			if not pcall(function()
				MarketplaceService:GetProductInfo(v10, Enum.InfoType.Asset)
			end) then
				v9 = nil
				thumbnailImage = nil
			end
		else
			v9 = nil
			thumbnailImage = nil
		end

		local iconId = v9 or tonumber(v8.iconId) or tonumber(v8.assetId) or 0

		if purchaseKind == "DeveloperProduct" or purchaseKind == "Gamepass" then
			local v10
			price, v10 = getMarketplaceInfo(v8.assetId, infoType)

			if not thumbnailImage then
				iconId = v10
			end
		end

		if purchaseKind == "Gamepass" then
			thumbnailImage = nil
		end

		local v10 = {}
		v10.assetId = v8.assetId
		v10.iconId = iconId
		v10.thumbnailImage = thumbnailImage
		v10.title = v8.title or "Shop Item"
		v10.description = v8.description or ""
		v10.hiddenFromCatalog = v8.hiddenFromCatalog == true
		v10.isOwned = false
		v10.price = price
		v10.productType = infoType
		v10.viewportObject = makeViewportObject(v8, iconId)
		local creatorName

		if purchaseKind == "ProfileStore" then
			creatorName = v4.creatorName or nil
		end

		v10.creatorName = creatorName
		local creatorType

		if purchaseKind == "ProfileStore" then
			creatorType = v4.creatorType or nil
		end

		v10.creatorType = creatorType
		v10.category = v8.category
		v10.color = v8.color
		v10.layoutOrder = v8.layoutOrder
		v10.purchaseKind = purchaseKind
		v10.pianoItemId = v8.pianoItemId
		v10.giftProductId = v8.giftProductId
		v10.rewardedAdKey = v8.rewardedAdKey
		v10.rewardedAdProductId = v8.rewardedAdProductId
		v10.displayType = v8.displayType
		v10.trackExisting = v8.trackExisting
		v10.limited = v8.limited
		v10.limitedLabel = v8.limitedLabel
		v10.limitedMax = v8.limitedMax
		v10.limitedAccentColor = v8.limitedAccentColor
		v10.developerExclusive = v8.developerExclusive
		v10.developerLabel = v8.developerLabel
		v10.developerAccentColor = v8.developerAccentColor
		v10.offSale = v8.offSale
		v10.existingText = buildExistingText(v8, nil)
		local existingTextColor

		if v8.developerExclusive then
			existingTextColor = v8.developerAccentColor
		elseif v8.limited then
			existingTextColor = v8.limitedAccentColor
		end

		v10.existingTextColor = existingTextColor
		local priceText

		if v8.offSale then
			priceText = "Off Sale"
		else
			priceText = v8.priceText

			if not priceText then
				if purchaseKind == "ProfileStore" then
					priceText = formatNumber(price) .. " Notes" or nil
				else
					priceText = nil
				end
			end
		end

		v10.priceText = priceText
		local priceIcon

		if v8.priceIcon == nil then
			if purchaseKind == "ProfileStore" then
				priceIcon = false
			end
		else
			priceIcon = v8.priceIcon
		end

		v10.priceIcon = priceIcon
		v10.hideExperienceOnlyWarning = v8.hideExperienceOnlyWarning == true or purchaseKind == "ProfileStore"

		clientStore:dispatch(setItemInfo(tostring(v8.assetId), v10))
	end
end

local function getItems() -- 4 equivalent calls inferred from this helper
	registerCatalogItems()
	return MerchBooth.getItems()
end

local function dispatchItemPatch(k, p) -- 4 equivalent calls inferred from this helper
	clientStore:dispatch(updateItemInfo(tostring(k), p))
end

local function refreshOwnership(items)
	local v8 = {}
	local success, result = pcall(function()
		return getPurchases:InvokeServer()
	end)

	if success and type(result) == "table" then
		v8 = result
	end

	local pianoItemIds = {}

	for _, item in pairs(items) do
		if not (item.purchaseKind == "ProfileStore" and item.trackExisting == true and type(item.pianoItemId) == "string") then
			continue
		end

		table.insert(pianoItemIds, item.pianoItemId)
	end

	local v9 = {}

	if #pianoItemIds > 0 then
		local success2, result2 = pcall(function()
			return getItemStats:InvokeServer(pianoItemIds)
		end)

		if success2 and type(result2) == "table" then
			v9 = result2
		end
	end

	for k, item in pairs(items) do
		if item.purchaseKind == "ProfileStore" then
			local v10

			if type(item.pianoItemId) == "string" then
				v10 = v9[item.pianoItemId] or nil
			end

			local v11 = {
				isOwned = item.pianoItemId and v8[item.pianoItemId] == true and true or false,
				existingText = buildExistingText(item, v10),
				existingTextColor = 0
			}
			local existingTextColor

			if item.developerExclusive then
				existingTextColor = item.developerAccentColor
			elseif item.limited then
				existingTextColor = item.limitedAccentColor
			end

			v11.existingTextColor = existingTextColor
			dispatchItemPatch(k, v11) -- inferred equivalent call
		elseif item.productType == Enum.InfoType.GamePass then
			dispatchItemPatch(k, { -- inferred equivalent call
				isOwned = v8[item.pianoItemId or "Gamepass:" .. tostring(item.assetId)] == true
			})
		elseif item.purchaseKind == "DeveloperProduct" then
			dispatchItemPatch(k, { isOwned = false }) -- inferred equivalent call
		end
	end
end

local function applyCategoryFilter(items, p)
	local v8 = PianoShopCatalog.IsCategory(p) and p or nil
	v3 = v8
	ReplicatedStorage2:SetAttribute("PianoShopRequestedCategory", v8 or "")

	for k, _ in pairs(items) do
		dispatchItemPatch(k, { hiddenFromCatalog = false }) -- inferred equivalent call
	end
end

local function refreshOwnershipAsync(p) -- 3 equivalent calls inferred from this helper
	count += 1
	local v8 = count
	task.spawn(function()
		refreshOwnership(p)

		if v8 == count then
			applyCategoryFilter(getItems(), v3) -- inferred equivalent call
			v5 = os.clock()
			local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

			if viewedPianoItemId == "EffectFireEyes" then
				applyLocalFireEyesPreview()
			else
				removeLocalFireEyesPreview()
			end

			if viewedPianoItemId == "EffectPianoOnFire" then
				applyLocalPianoOnFirePreview()
			else
				removeLocalPianoOnFirePreview()
			end
		end
	end)
end

local function openPianoMerchBooth(p) -- 1 equivalent call inferred from this helper
	local items = getItems() -- inferred equivalent call
	applyCategoryFilter(items, p)
	MerchBooth.openMerchBooth()
	v5 = os.clock()
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end

	refreshOwnershipAsync(items) -- inferred equivalent call
end

configureMerchBooth()
registerCatalogItems()
task.delay(1, function()
	refreshOwnershipAsync(getItems()) -- inferred equivalent call
end)

shopPurchasesUpdated.OnClientEvent:Connect(function()
	refreshOwnershipAsync(getItems()) -- inferred equivalent call
end)

fn = function(p)
	local v8 = PianoShopCatalog.IsCategory(p) and p or nil

	if MerchBooth.isMerchBoothOpen() and v3 == v8 then
		if os.clock() - lastTime < 0.35 then
			return
		end

		MerchBooth.closeMerchBooth()
		removeLocalFireEyesPreview()
		removeLocalPianoOnFirePreview()
	else
		lastTime = os.clock()
		openPianoMerchBooth(v8) -- inferred equivalent call
	end
end

ReplicatedStorage2:GetAttributeChangedSignal("PianoShopRequestedCategory"):Connect(function()
	v5 = os.clock()
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end
end)
MerchBooth.itemViewOpened:Connect(function()
	v5 = os.clock()
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end
end)
MerchBooth.itemViewClosed:Connect(function()
	v5 = os.clock()
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end
end)
MerchBooth.catalogViewOpened:Connect(function()
	v5 = os.clock()
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end
end)
MerchBooth.merchBoothClosed:Connect(function()
	v5 = os.clock()
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end
end)
LocalPlayer:GetAttributeChangedSignal("SelectedEffect"):Connect(function()
	v5 = os.clock()
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end
end)
LocalPlayer:GetAttributeChangedSignal("SelectedPianoEffect"):Connect(function()
	v5 = os.clock()
	local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

	if viewedPianoItemId == "EffectFireEyes" then
		applyLocalFireEyesPreview()
	else
		removeLocalFireEyesPreview()
	end

	if viewedPianoItemId == "EffectPianoOnFire" then
		applyLocalPianoOnFirePreview()
	else
		removeLocalPianoOnFirePreview()
	end
end)
LocalPlayer.CharacterAdded:Connect(function()
	task.defer(function()
		v5 = os.clock()
		local viewedPianoItemId = getViewedPianoItemId() -- inferred equivalent call

		if viewedPianoItemId == "EffectFireEyes" then
			applyLocalFireEyesPreview()
		else
			removeLocalFireEyesPreview()
		end

		if viewedPianoItemId == "EffectPianoOnFire" then
			applyLocalPianoOnFirePreview()
		else
			removeLocalPianoOnFirePreview()
		end
	end)
end)
RunService.RenderStepped:Connect(function()
	syncLocalShopEffectPreviews(false) -- inferred equivalent call
end)

v = true
bindOpenShopEvent(ReplicatedStorage2:FindFirstChild("OpenShop")) -- inferred equivalent call

if flag then
	local v8 = v2
	flag = false
	v2 = nil
	task.defer(function()
		requestOpenShop(v8) -- inferred equivalent call
	end)
end

ClientDebugConfig.Print("[ShopHandler] Shop is Ready")