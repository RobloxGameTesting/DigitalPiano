local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function setDevice(device: string)
	return { device = device }
end

return Rodux.makeActionCreator(script.Name, setDevice)