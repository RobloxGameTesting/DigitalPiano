local MerchBooth = script:FindFirstAncestor("MerchBooth")

local setCatalogSortFunction = require(MerchBooth.Actions.setCatalogSortFunction)
require(MerchBooth.types)

return function(object)
	local function setCatalogSort(callback)
		object:dispatch(setCatalogSortFunction(callback))
	end

	return setCatalogSort
end