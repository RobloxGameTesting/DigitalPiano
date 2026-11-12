local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function setControls(name: string, keyCodes)
	return { name = name, keyCodes = keyCodes }
end

return Rodux.makeActionCreator(script.Name, setControls)