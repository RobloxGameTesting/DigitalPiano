local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function setMerchBoothFocused(isFocused: boolean)
	return { isFocused = isFocused }
end

return Rodux.makeActionCreator(script.Name, setMerchBoothFocused)