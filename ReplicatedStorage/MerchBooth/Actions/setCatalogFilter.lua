local MerchBooth = script:FindFirstAncestor("MerchBooth")
require(MerchBooth.types)

local Rodux = require(MerchBooth.Packages.Rodux)

local function setCatalogFilter(filter)
	return { filter = filter }
end

return Rodux.makeActionCreator(script.Name, setCatalogFilter)