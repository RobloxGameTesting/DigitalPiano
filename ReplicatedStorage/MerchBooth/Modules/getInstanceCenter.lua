local function getInstancePosition(instance)
	if instance:IsA("BasePart") or instance:IsA("Attachment") then
		return instance.Position
	end

	if instance:IsA("Model") then
		local boundingBox, _ = instance:GetBoundingBox()
		return boundingBox.Position
	end

	local basePart = instance:FindFirstChildWhichIsA("BasePart")

	if basePart then
		return basePart.Position
	end

	return Vector3.new(0, 0, 0)
end

return getInstancePosition