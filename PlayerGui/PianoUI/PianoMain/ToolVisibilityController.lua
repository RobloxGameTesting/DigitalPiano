local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local StarterGui = game:GetService("StarterGui")

local v = nil

local function setBackpackCoreGuiEnabled(p): boolean
	local result = nil

	for _ = 1, 5 do
		local success
		success, result = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, p)
		end)

		if success then
			return true
		end

		task.wait(0.1)
	end

	ClientDebugConfig.Warn("[ToolVisibilityController] Failed to set Backpack CoreGui visibility:", (tostring(result)))
	return false
end

local ToolVisibilityController = {}

function ToolVisibilityController.Hide(object)
	if v == nil then
		local success, result = pcall(function()
			return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
		end)

		v = success and result or true
	end

	if object then
		pcall(function()
			object:UnequipTools()
		end)
	end

	setBackpackCoreGuiEnabled(false)
end

function ToolVisibilityController.Restore()
	if v == nil then
		return
	end

	setBackpackCoreGuiEnabled(v ~= false)
	v = nil
end

return ToolVisibilityController