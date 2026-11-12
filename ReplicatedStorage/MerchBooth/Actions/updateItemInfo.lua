local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
require(MerchBooth.types)

local function updateItemInfo(itemId: string, info)
	return { itemId = itemId, info = info }
end

return Rodux.makeActionCreator(script.Name, updateItemInfo)