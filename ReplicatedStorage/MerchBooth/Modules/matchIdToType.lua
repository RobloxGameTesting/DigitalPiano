local function matchIdToType(p: number)
	for _, v in ipairs(Enum.AssetType:GetEnumItems()) do
		if v.Value == p then
			return v
		end
	end

	return Enum.AssetType.Hat
end

return matchIdToType