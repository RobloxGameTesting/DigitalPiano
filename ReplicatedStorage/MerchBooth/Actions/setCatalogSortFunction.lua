local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
require(MerchBooth.types)

local function setCatalogSortFunction(sort)
	return { sort = sort }
end

return Rodux.makeActionCreator(script.Name, setCatalogSortFunction)