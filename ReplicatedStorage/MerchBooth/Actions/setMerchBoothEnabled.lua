local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function setMerchBoothEnabled(isEnabled: boolean)
	return { isEnabled = isEnabled }
end

return Rodux.makeActionCreator(script.Name, setMerchBoothEnabled)