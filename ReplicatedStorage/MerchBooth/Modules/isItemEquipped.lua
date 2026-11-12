local MerchBooth = script:FindFirstAncestor("MerchBooth")

require(MerchBooth.types)
local isAccessory = require(MerchBooth.Modules.isAccessory)
local isClassicClothing = require(MerchBooth.Modules.isClassicClothing)

return function(object, p): boolean
	if isAccessory(p.assetType) then
		for _, v in ipairs(object:GetAccessories(true)) do
			if v.AssetId == p.assetId then
				return true
			end
		end
	elseif
		isClassicClothing(p.assetType)
		and (object.GraphicTShirt == p.assetId or object.Shirt == p.assetId or object.Pants == p.assetId)
	then
		return true
	end

	return false
end