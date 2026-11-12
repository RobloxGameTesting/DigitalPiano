local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function setMerchBoothVisible(visible: boolean)
	return { visible = visible }
end

return Rodux.makeActionCreator(script.Name, setMerchBoothVisible)