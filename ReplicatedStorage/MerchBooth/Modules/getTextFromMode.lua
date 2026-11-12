local MerchBooth = script:FindFirstAncestor("MerchBooth")

local enums = require(MerchBooth.enums)
local separateThousands = require(script.Parent.separateThousands)

local function getTextFromMode(p, p2: number?)
	if p == enums.PrimaryButtonModes.Loading then
		return ""
	end

	if p == enums.PrimaryButtonModes.Purchase and p2 then
		if p2 == 0 then
			return "FREE"
		end

		if p2 < 0 then
			return "NOT FOR SALE"
		end

		return separateThousands(p2)
	end

	if p == enums.PrimaryButtonModes.Owned then
		return "Owned"
	end

	if p == enums.PrimaryButtonModes.CanEquip then
		return "Equip Item"
	end

	if p == enums.PrimaryButtonModes.OffSale then
		return "Off Sale"
	end

	if p == enums.PrimaryButtonModes.Equipped then
		return "Item Equipped"
	end

	return ""
end

return getTextFromMode