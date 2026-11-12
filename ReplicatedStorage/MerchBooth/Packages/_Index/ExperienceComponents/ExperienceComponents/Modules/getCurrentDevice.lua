local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local constants = require(ExperienceComponents.constants)
local enums = require(ExperienceComponents.enums)

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