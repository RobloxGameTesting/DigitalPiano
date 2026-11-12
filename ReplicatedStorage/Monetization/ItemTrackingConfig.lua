local ItemTrackingConfig = {}

local v = {
	Benches = true,
	Effects = true,
	Themes = true,
	Titles = true,
	Tags = true
}

local v2 = {}

local function copyConfig(options)
	local result = {}

	for k, v3 in pairs(options or {}) do
		result[k] = v3
	end

	return result
end

function ItemTrackingConfig.Get(itemId, p)
	if type(itemId) ~= "string" or not itemId then
		if type(p) == "table" then
			itemId = p.pianoItemId or nil
		else
			itemId = nil
		end
	end

	if not itemId or itemId == "" then
		return nil
	end

	local v3 = type(p) == "table" and p or nil
	local v4 = v2[itemId]
	local category = v3 and v3.category
	local purchaseKind = v3 and v3.purchaseKind
	local v5

	if v4 == nil and (not v3 or v3.trackExisting ~= true and v3.limited ~= true and v3.developerExclusive ~= true) then
		if purchaseKind == "ProfileStore" then
			v5 = v[category] == true
		else
			v5 = false
		end
	else
		v5 = true
	end

	if not v5 then
		return nil
	end

	local result = copyConfig(v3)

	for k, v6 in pairs(v4 or {}) do
		result[k] = v6
	end

	result.ItemId = itemId
	local trackExisting

	if
		result.TrackExisting == true
		or result.trackExisting == true
		or result.Limited == true
		or result.limited == true
		or result.DeveloperExclusive == true
		or result.developerExclusive == true
	then
		trackExisting = true
	elseif purchaseKind == "ProfileStore" then
		trackExisting = v[category] == true
	else
		trackExisting = false
	end

	result.TrackExisting = trackExisting
	result.Limited = result.Limited == true or result.limited == true
	result.DeveloperExclusive = result.DeveloperExclusive == true or result.developerExclusive == true
	result.Serialed = result.Serialed == true
		or result.serialed == true
		or result.Limited == true
		or result.DeveloperExclusive == true
	result.OffSale = result.OffSale == true or result.offSale == true or result.DeveloperExclusive == true

	if result.Limited then
		result.MaxSupply = math.max(0, (math.floor(tonumber(result.MaxSupply or result.limitedMax) or 0)))
		result.LimitedLabel = type(result.LimitedLabel) == "string" and result.LimitedLabel
			or type(result.limitedLabel) == "string" and result.limitedLabel
			or "Limited Edition"
		result.LimitedAccentColor = typeof(result.LimitedAccentColor) == "Color3" and result.LimitedAccentColor
			or typeof(result.limitedAccentColor) == "Color3" and result.limitedAccentColor
			or Color3.fromRGB(245, 197, 66)
	end

	if result.DeveloperExclusive then
		result.DeveloperLabel = type(result.DeveloperLabel) == "string" and result.DeveloperLabel
			or type(result.developerLabel) == "string" and result.developerLabel
			or "Developer Item"
		result.DeveloperAccentColor = typeof(result.DeveloperAccentColor) == "Color3" and result.DeveloperAccentColor
			or typeof(result.developerAccentColor) == "Color3" and result.developerAccentColor
			or Color3.fromRGB(88, 195, 173)
	end

	if result.PushImmune == nil then
		result.PushImmune = result.pushImmune == true
	end

	return result
end

function ItemTrackingConfig:ApplyToCatalogItem()
	if type(self) ~= "table" then
		return self
	end

	local v3 = ItemTrackingConfig.Get(self.pianoItemId, self)

	if not v3 then
		return self
	end

	self.trackExisting = v3.TrackExisting == true
	self.existingLabel = "existing"
	self.limited = v3.Limited == true
	self.serialed = v3.Serialed == true
	self.offSale = v3.OffSale == true
	self.developerExclusive = v3.DeveloperExclusive == true

	if self.limited then
		self.limitedLabel = v3.LimitedLabel
		self.limitedMax = v3.MaxSupply
		self.limitedAccentColor = v3.LimitedAccentColor
	end

	if self.developerExclusive then
		self.developerLabel = v3.DeveloperLabel
		self.developerAccentColor = v3.DeveloperAccentColor
	end

	if v3.PushImmune then
		self.pushImmune = true
	end

	return self
end

return ItemTrackingConfig