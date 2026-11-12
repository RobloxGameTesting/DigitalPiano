local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeviceTypeDetected = ReplicatedStorage:FindFirstChild("DeviceTypeDetected")

local function detectDeviceType(): string
	local touchEnabled = UserInputService.TouchEnabled
	local gamepadEnabled = UserInputService.GamepadEnabled
	local mouseEnabled = UserInputService.MouseEnabled

	if gamepadEnabled and not mouseEnabled then
		return "Console"
	end

	if mouseEnabled then
		return "PC"
	end

	if touchEnabled and not gamepadEnabled then
		return "Mobile"
	end

	return "Unknown"
end

local TouchEnabled = UserInputService.TouchEnabled
local GamepadEnabled = UserInputService.GamepadEnabled
local MouseEnabled = UserInputService.MouseEnabled
local v = GamepadEnabled and not MouseEnabled and "Console"
	or MouseEnabled and "PC"
	or TouchEnabled and not GamepadEnabled and "Mobile"
	or "Unknown"

if DeviceTypeDetected then
	DeviceTypeDetected:FireServer(v)
end