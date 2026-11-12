local MerchBooth = script:FindFirstAncestor("MerchBooth")

local createMockAccessory = require(MerchBooth.Mocks.createMockAccessory)

local function createMockInsertedAccessory()
	local model = Instance.new("Model")

	local mockAccessory = createMockAccessory()
	mockAccessory.Parent = model

	return model
end

return createMockInsertedAccessory