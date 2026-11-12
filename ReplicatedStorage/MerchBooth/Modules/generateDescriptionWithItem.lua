local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Cryo = require(MerchBooth.Packages.Cryo)
local matchAssetTypeToAccessoryType = require(MerchBooth.Modules.matchAssetTypeToAccessoryType)
local isAccessory = require(MerchBooth.Modules.isAccessory)
local isClassicClothing = require(MerchBooth.Modules.isClassicClothing)

local color = Color3.fromRGB(122, 122, 122)

local function generateDescriptionWithItem(player, p: number, p2)
	local character = player and player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local selected = humanoid and humanoid:GetAppliedDescription()

	if not selected then
		selected = Instance.new("HumanoidDescription")
		selected.HeadColor = color
		selected.TorsoColor = color
		selected.LeftArmColor = color
		selected.RightArmColor = color
		selected.LeftLegColor = color
		selected.RightLegColor = color
	end

	if isAccessory(p2) then
		local accessoryType = matchAssetTypeToAccessoryType(p2)
		local filtered = Cryo.List.filter(selected:GetAccessories(true), function(p3): boolean
			return p3.AccessoryType ~= accessoryType
		end)

		table.insert(filtered, { Order = 1, AssetId = p, AccessoryType = accessoryType })

		selected:SetAccessories(filtered, true)
		return selected
	end

	if not isClassicClothing(p2) then
		return selected
	end

	if p2 == Enum.AssetType.TShirt then
		selected.GraphicTShirt = p
		return selected
	end

	if p2 == Enum.AssetType.Shirt then
		selected.Shirt = p
		return selected
	elseif p2 == Enum.AssetType.Pants then
		selected.Pants = p
	end

	return selected
end

return generateDescriptionWithItem