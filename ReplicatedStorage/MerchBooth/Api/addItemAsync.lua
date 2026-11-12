local RunService = game:GetService("RunService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local t = require(MerchBooth.Packages.t)
require(MerchBooth.types)
local constants = require(MerchBooth.constants)
local setItemInfo = require(MerchBooth.Actions.setItemInfo)
local matchIdToType = require(MerchBooth.Modules.matchIdToType)
local getOrCreateInstanceOfName = require(MerchBooth.Modules.getOrCreateInstanceOfName)
local isAccessory = require(MerchBooth.Modules.isAccessory)
local isClassicClothing = require(MerchBooth.Modules.isClassicClothing)
local generateDummyWithItem = require(MerchBooth.Modules.generateDummyWithItem)
local loadAssetAsync = require(MerchBooth.Modules.loadAssetAsync)
local getProductInfoAsync = require(MerchBooth.Modules.getProductInfoAsync)

local function loadAsset(data)
	local parent = nil

	if data.productType == Enum.InfoType.Asset then
		if isAccessory(data.assetType) then
			local v = loadAssetAsync(data.assetId)
			parent = v:FindFirstChildOfClass("Accessory")
			parent.Parent = nil
			v:Destroy()
		elseif isClassicClothing(data.assetType) then
			parent = generateDummyWithItem(data, nil)

			task.wait()
		end
	elseif data.productType == Enum.InfoType.GamePass or data.productType == Enum.InfoType.Product then
		parent = Instance.new("Part")
		parent.Size = Vector3.new(10, 10, 0)
		parent.Transparency = 1

		for _, face in ipairs({ Enum.NormalId.Front, Enum.NormalId.Back }) do
			local decal = Instance.new("Decal")
			decal.Face = face
			decal.Texture = "rbxthumb://type=Asset&id=" .. data.iconId .. "&w=420&h=420"
			decal.Parent = parent
		end
	end

	parent.Name = data.assetId
	parent.Parent = getOrCreateInstanceOfName(
		constants.Instances.AssetsFolder.name,
		constants.Instances.AssetsFolder.instanceType
	)
	return parent
end

return function(object)
	local function addItemAsync(assetId: number, p, flag: boolean?)
		assert(RunService:IsServer(), "MerchBooth.addItemAsync must be called on the server")
		assert(t.number(assetId), "Bad argument #1 to MerchBooth.addItemAsync: expected a number")
		assert(t.enum(Enum.InfoType), "Bad argument #2 to MerchBooth.addItemAsync: expected a Enum.InfoType")
		assert(t.optional(t.boolean)(flag), "Bad argument #3 to MerchBooth.addItemAsync: expected a boolean or nil")

		local productType = p or Enum.InfoType.Asset

		local productInfoAsync = getProductInfoAsync(assetId, productType)

		local assetType = matchIdToType(productInfoAsync.AssetTypeId)
		local v = {
			assetId = assetId,
			title = productInfoAsync.Name,
			description = productInfoAsync.Description,
			price = 0,
			assetType = 0,
			creatorName = 0,
			creatorType = 0,
			hiddenFromCatalog = 0,
			isOwned = false,
			productType = 0,
			iconId = 0
		}
		local price

		if productInfoAsync.IsForSale then
			price = productInfoAsync.PriceInRobux
		else
			price = productInfoAsync.IsPublicDomain and 0 or -1
		end

		v.price = price

		v.assetType = assetType
		v.creatorName = productInfoAsync.Creator.Name
		local creatorType

		if productInfoAsync.Creator.CreatorType then
			creatorType = Enum.CreatorType[productInfoAsync.Creator.CreatorType]
		end

		v.creatorType = creatorType
		v.hiddenFromCatalog = flag and true or false

		v.productType = productType
		local iconId

		if productInfoAsync.IconImageAssetId == 0 then
			iconId = assetId
		else
			iconId = productInfoAsync.IconImageAssetId
		end

		v.iconId = iconId

		v.viewportObject = loadAsset(v)

		object:dispatch(setItemInfo(tostring(assetId), v))
	end

	return addItemAsync
end