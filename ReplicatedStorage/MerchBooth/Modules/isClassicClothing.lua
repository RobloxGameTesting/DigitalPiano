local MerchBooth = script:FindFirstAncestor("MerchBooth")
local t = require(MerchBooth.Packages.t)

function isClassicClothing(p): boolean
	assert(t.enum(Enum.AssetType)(p))

	return p == Enum.AssetType.TShirt or p == Enum.AssetType.Shirt or p == Enum.AssetType.Pants
end

return isClassicClothing