local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function removeItemInfo(itemId: string)
	return { itemId = itemId }
end

return Rodux.makeActionCreator(script.Name, removeItemInfo)