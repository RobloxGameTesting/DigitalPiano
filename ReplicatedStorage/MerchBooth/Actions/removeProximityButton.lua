local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function removeProximityButton(adornee)
	return { adornee = adornee }
end

return Rodux.makeActionCreator(script.Name, removeProximityButton)