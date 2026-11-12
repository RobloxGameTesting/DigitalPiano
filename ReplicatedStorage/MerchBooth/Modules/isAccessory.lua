local MerchBooth = script:FindFirstAncestor("MerchBooth")
local t = require(MerchBooth.Packages.t)

function isAccessory(p): boolean
	assert(t.enum(Enum.AssetType)(p))

	if string.find(p.Name, "Accessory") or p == Enum.AssetType.Hat then
		return true
	end

	return false
end

return isAccessory