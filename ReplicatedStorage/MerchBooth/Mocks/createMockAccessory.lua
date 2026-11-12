local function createMockAccessory()
	local accessory = Instance.new("Accessory")

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Parent = accessory

	return accessory
end

return createMockAccessory