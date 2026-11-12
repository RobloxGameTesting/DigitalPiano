local function matchAssetTypeToAccessoryType(p)
	if not (p and p.Name) then
		return Enum.AccessoryType.Unknown
	end

	for _, v in ipairs(Enum.AccessoryType:GetEnumItems()) do
		if string.gsub(p.Name, "Accessory", "") == v.Name then
			return v
		end
	end

	return Enum.AccessoryType.Unknown
end

return matchAssetTypeToAccessoryType