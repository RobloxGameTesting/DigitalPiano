local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BarVisualizerThemeRequest = ReplicatedStorage:WaitForChild("BarVisualizerThemeRequest")
local Pianos = workspace:WaitForChild("Pianos")
local set = {}

local function getMainGui(instance) -- 1 equivalent call inferred from this helper
	local monitor = instance:FindFirstChild("Monitor")
	local screen = monitor and monitor:FindFirstChild("Screen")
	local surfaceGui = screen and screen:FindFirstChild("SurfaceGui")
	return surfaceGui and surfaceGui:FindFirstChild("Main")
end

local function hookBarVisualizer(child)
	if set[child] or child.Name ~= "BarVisualizer" then
		return
	end

	local mainGui = getMainGui(child) -- inferred equivalent call

	if not mainGui then
		return
	end

	local up = mainGui:FindFirstChild("Up")
	local down = mainGui:FindFirstChild("Down")

	if not (up and up:IsA("GuiButton") and down and down:IsA("GuiButton")) then
		return
	end

	set[child] = true
	up.MouseButton1Click:Connect(function()
		BarVisualizerThemeRequest:FireServer(child, 1)
	end)
	down.MouseButton1Click:Connect(function()
		BarVisualizerThemeRequest:FireServer(child, -1)
	end)
end

for _, child in ipairs(Pianos:GetChildren()) do
	hookBarVisualizer(child)
end

Pianos.ChildAdded:Connect(function(child)
	task.defer(hookBarVisualizer, child)
end)