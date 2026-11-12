local MerchBooth = script:FindFirstAncestor("MerchBooth")

local constants = require(MerchBooth.constants)
local enums = require(MerchBooth.enums)

local function getCurrentDevice(p)
	for k, list in pairs(constants.DeviceInputTypePatterns) do
		for _, item in ipairs(list) do
			if p.Name:match(item) then
				return enums.Device[k]
			end
		end
	end

	return enums.Device.Unknown
end

return getCurrentDevice