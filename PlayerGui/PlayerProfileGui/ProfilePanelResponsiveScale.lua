local Workspace = game:GetService("Workspace")

local vector2 = Vector2.new(560, 520)

local parent = script.Parent
local profilePanel = parent:WaitForChild("ProfilePanel")
local responsiveScale = profilePanel:FindFirstChild("ResponsiveScale")

if not responsiveScale then
	responsiveScale = Instance.new("UIScale")
	responsiveScale.Name = "ResponsiveScale"
	responsiveScale.Parent = profilePanel
end

local function getViewportSize() -- 1 equivalent call inferred from this helper
	if parent.AbsoluteSize.X > 0 and parent.AbsoluteSize.Y > 0 then
		return parent.AbsoluteSize
	end

	local currentCamera = Workspace.CurrentCamera
	return currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
end

local function applyScale()
	local viewportSize = getViewportSize() -- inferred equivalent call
	local v = viewportSize.X < 520 and 14 or 32
	local v2 = math.max(1, viewportSize.X - v * 2)
	local v3 = math.max(1, viewportSize.Y - v * 2)
	local v4 = math.min(1, v2 / vector2.X, v3 / vector2.Y)
	responsiveScale.Scale = math.max(0.45, v4)
	profilePanel.AnchorPoint = Vector2.new(0.5, 0.5)
	profilePanel.Position = UDim2.fromScale(0.5, 0.5)
	profilePanel.Size = UDim2.fromOffset(vector2.X, vector2.Y)
end

applyScale()
parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyScale)
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(applyScale)

if Workspace.CurrentCamera then
	Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)
end