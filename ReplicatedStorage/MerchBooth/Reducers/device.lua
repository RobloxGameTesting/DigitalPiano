local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
local enums = require(MerchBooth.enums)
local setDevice = require(MerchBooth.Actions.setDevice)

return (Rodux.createReducer(enums.Device.Computer, {
	[setDevice.name] = function(p: string, p2)
		if p2.device == enums.Device.Unknown then
			return p
		end

		return p2.device
	end
}))