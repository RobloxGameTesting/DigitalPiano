local MerchBooth = script:FindFirstAncestor("MerchBooth")

local matchAssetTypeToAccessoryType = require(MerchBooth.Modules.matchAssetTypeToAccessoryType)
require(MerchBooth.Reducers.serverReducer)
require(MerchBooth.types)

local function getAvailableAccessoryTypes(items)
	local set = {}
	local availableAccessoryTypes = {}

	for _, item in pairs(items) do
		if item.productType == Enum.InfoType.Asset then
			set[matchAssetTypeToAccessoryType(item.assetType)] = true
		else
			set[item.productType] = true
		end
	end

	for k in pairs(set) do
		table.insert(availableAccessoryTypes, k)
	end

	return availableAccessoryTypes
end

return getAvailableAccessoryTypes