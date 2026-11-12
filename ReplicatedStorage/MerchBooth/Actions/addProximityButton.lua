local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function addProximityButton(id: string, adornee)
	return { id = id, adornee = adornee }
end

return Rodux.makeActionCreator(script.Name, addProximityButton)