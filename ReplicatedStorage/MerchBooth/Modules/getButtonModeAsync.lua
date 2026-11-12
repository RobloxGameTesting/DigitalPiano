local MerchBooth = script:FindFirstAncestor("MerchBooth")

local enums = require(MerchBooth.enums)
require(MerchBooth.types)
local isItemEquipped = require(MerchBooth.Modules.isItemEquipped)

return function()
	local function getButtonModeAsync(player, data)
		local character = player and player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local v = enums.PrimaryButtonModes.Purchase

		if humanoid and data.isOwned then
			v = enums.PrimaryButtonModes.Owned

			if not data.assetType then
				return v
			end

			v = enums.PrimaryButtonModes.CanEquip

			if isItemEquipped(humanoid:GetAppliedDescription(), data) then
				return enums.PrimaryButtonModes.Equipped
			end

			return v
		end

		if data.offSale == true then
			return enums.PrimaryButtonModes.OffSale
		end

		return v
	end

	return getButtonModeAsync
end