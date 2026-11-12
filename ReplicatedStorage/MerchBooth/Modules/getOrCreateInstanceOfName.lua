local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getOrCreateInstanceOfName(name: string, className: string, p)
	local parent = p or ReplicatedStorage
	local instanceOfName = parent:FindFirstChild(name)

	if not instanceOfName then
		instanceOfName = Instance.new(className)
		instanceOfName.Name = name
		instanceOfName.Parent = parent
	end

	return instanceOfName
end

return getOrCreateInstanceOfName