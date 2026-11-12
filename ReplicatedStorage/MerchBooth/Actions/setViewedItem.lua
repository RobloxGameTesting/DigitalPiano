local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function setViewedItem(assetId: number?)
	return { assetId = assetId }
end

return Rodux.makeActionCreator(script.Name, setViewedItem)