local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")

local CurrentCamera = workspace.CurrentCamera

local parent = script.Parent
local overlay = parent:WaitForChild("Overlay")
local panel = parent:WaitForChild("Panel")
local itemTemplate = parent:WaitForChild("ItemTemplate")

local flag = false
local position = panel.Position

panel.Visible = false
overlay.Visible = false
panel.BackgroundTransparency = 1
overlay.BackgroundTransparency = 1

local v = {
	{
		name = "Shop",
		image = "rbxassetid://13846572781",
		color = Color3.fromRGB(255, 190, 50),
		order = 1,
		action = "OpenShop"
	},
	{
		name = "Inventory",
		icon = "rbxassetid://13858170242",
		color = Color3.fromRGB(90, 185, 255),
		order = 2,
		action = "OpenInventory"
	},
	{
		name = "Device Change",
		icon = "rbxassetid://13849401378",
		color = Color3.fromRGB(106, 178, 255),
		order = 3,
		action = "OpenDeviceChange"
	},
	{
		name = "Community Sheets",
		image = "rbxassetid://13849019147",
		color = Color3.fromRGB(120, 210, 255),
		order = 4,
		action = "OpenCommunitySheets"
	},
	{
		name = "Sheet Transpose",
		icon = "T+",
		color = Color3.fromRGB(90, 185, 255),
		order = 5,
		action = "OpenSheetTranspose"
	},
	{
		name = "Personal Sheets",
		icon = "rbxassetid://13868564749",
		color = Color3.fromRGB(52, 211, 153),
		order = 6,
		action = "OpenPersonalSheets"
	},
	{
		name = "VP Notes",
		icon = "VP",
		color = Color3.fromRGB(165, 140, 255),
		order = 7,
		action = "OpenVPNotes"
	},
	{
		name = "Map Elevator",
		icon = "rbxassetid://13863911054",
		color = Color3.fromRGB(120, 210, 255),
		order = 8,
		action = "OpenMapElevator"
	},
	{
		name = "Comments",
		icon = "rbxassetid://13858761079",
		color = Color3.fromRGB(120, 210, 255),
		order = 9,
		action = "OpenPlayerComments"
	}
}

local color = Color3.fromRGB(32, 36, 43)
local color2 = Color3.fromRGB(50, 58, 70)
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local uiGridLayout = panel:FindFirstChildOfClass("UIGridLayout")
local uiPadding = panel:FindFirstChildOfClass("UIPadding")

local function getViewportSize() -- 1 equivalent call inferred from this helper
	CurrentCamera = workspace.CurrentCamera
	return CurrentCamera and CurrentCamera.ViewportSize or Vector2.new(1280, 720)
end

local function setPadding(p, p2)
	if not uiPadding then
		return
	end

	uiPadding.PaddingLeft = UDim.new(0, p)
	uiPadding.PaddingRight = UDim.new(0, p)
	uiPadding.PaddingTop = UDim.new(0, p2)
	uiPadding.PaddingBottom = UDim.new(0, p2)
end

local function applyResponsiveLayout()
	if not uiGridLayout then
		return
	end

	local viewportSize = getViewportSize() -- inferred equivalent call
	local fillDirectionMaxCells = viewportSize.X < 700 and 2 or 3
	local v2 = math.ceil(#v / fillDirectionMaxCells)
	local v3 = math.min(viewportSize.X * 0.86, fillDirectionMaxCells == 2 and 430 or 620)
	local v4 = math.min(viewportSize.Y * 0.76, 520)
	local v5 = math.clamp(math.floor(v3 * 0.035), 10, 16)
	local v6 = math.clamp(math.floor(v4 * 0.035), 10, 16)
	local v7 = math.clamp(math.floor(v3 * 0.045), 12, 28)
	local v8 = math.clamp(math.floor(v4 * 0.05), 10, 24)

	local v9 = math.clamp(
		math.floor((v3 - v5 * 2 - v7 * (fillDirectionMaxCells - 1)) / fillDirectionMaxCells),
		116,
		150
	)
	local v10 = math.clamp(math.floor(v9 * 0.88), 98, 132)

	local v11 = v9 * fillDirectionMaxCells + v7 * (fillDirectionMaxCells - 1) + v5 * 2
	local v12 = v10 * v2 + v8 * (v2 - 1) + v6 * 2

	if v4 < v12 then
		v10 = math.max(86, (math.floor((v4 - v8 * (v2 - 1) - v6 * 2) / v2)))
		v12 = v10 * v2 + v8 * (v2 - 1) + v6 * 2
	end

	position = UDim2.fromScale(0.5, viewportSize.Y < 650 and 0.5 or 0.46)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = position
	panel.Size = UDim2.fromOffset(v11, v12)
	itemTemplate.Size = UDim2.fromOffset(v9, v10)
	uiGridLayout.CellSize = UDim2.fromOffset(v9, v10)
	uiGridLayout.CellPadding = UDim2.fromOffset(v7, v8)
	uiGridLayout.FillDirectionMaxCells = fillDirectionMaxCells
	setPadding(v5, v6)
end

local function getTextConstraint(parent2, minTextSize, maxTextSize) -- 1 equivalent call inferred from this helper
	local selected = parent2:FindFirstChildOfClass("UITextSizeConstraint")

	if not selected then
		selected = Instance.new("UITextSizeConstraint")
		selected.Parent = parent2
	end

	selected.MinTextSize = minTextSize
	selected.MaxTextSize = maxTextSize
	return selected
end

local function configureTextLabel(parent2, minTextSize, maxTextSize) -- 2 equivalent calls inferred from this helper
	parent2.TextScaled = true
	parent2.TextWrapped = true
	getTextConstraint(parent2, minTextSize, maxTextSize) -- inferred equivalent call
end

local function ensureBindableEvent(name)
	local v2 = ReplicatedStorage2:FindFirstChild(name)

	if v2 and not v2:IsA("BindableEvent") then
		v2:Destroy()
		v2 = nil
	end

	if not v2 then
		v2 = Instance.new("BindableEvent")
		v2.Name = name
		v2.Parent = ReplicatedStorage2
	end

	return v2
end

ensureBindableEvent("OpenInventory")
ensureBindableEvent("OpenPlayerComments")

local function close()
	if not flag then
		return
	end

	flag = false
	TweenService:Create(panel, tweenInfo, {
		Position = position + UDim2.new(0, 0, 0, 8)
	}):Play()
	TweenService:Create(overlay, tweenInfo, { BackgroundTransparency = 1 }):Play()
	task.delay(0.15, function()
		panel.Visible = false
		overlay.Visible = false
		panel.BackgroundTransparency = 1
		panel.Position = position
	end)
end

local function open()
	if flag then
		close()
		return
	end

	applyResponsiveLayout()
	flag = true
	panel.Visible = true
	overlay.Visible = true
	panel.BackgroundTransparency = 1
	panel.Position = position + UDim2.new(0, 0, 0, 8)
	TweenService:Create(panel, tweenInfo, { Position = position }):Play()
	TweenService:Create(overlay, tweenInfo, { BackgroundTransparency = 0.55 }):Play()
end

local function getIconImage(menuCard)
	local iconImage = menuCard:FindFirstChild("IconImage")

	if iconImage and iconImage:IsA("ImageLabel") then
		return iconImage
	end

	local iconImage2 = Instance.new("ImageLabel")
	iconImage2.Name = "IconImage"
	iconImage2.AnchorPoint = Vector2.new(0.5, 0.5)
	iconImage2.Position = UDim2.fromScale(0.5, 0.38)
	iconImage2.Size = UDim2.fromScale(0.46, 0.46)
	iconImage2.BackgroundTransparency = 1
	iconImage2.ScaleType = Enum.ScaleType.Fit
	iconImage2.ZIndex = menuCard.ZIndex + 2
	iconImage2.Parent = menuCard
	return iconImage2
end

local function fireAction(p)
	close()
	task.wait(0.1)

	local bindableEvent = ReplicatedStorage2:FindFirstChild(p.action) or ReplicatedStorage2:WaitForChild(p.action, 3)

	if bindableEvent and bindableEvent:IsA("BindableEvent") then
		bindableEvent:Fire()
	else
		ClientDebugConfig.Warn("[MenuGrid] Missing BindableEvent action:", p.action)
	end
end

local function buildGrid()
	for _, frame in ipairs(panel:GetChildren()) do
		if frame:IsA("Frame") and frame.Name == "MenuCard" then
			frame:Destroy()
		end
	end

	local v2 = math.max(itemTemplate.Size.Y.Offset, uiGridLayout and uiGridLayout.CellSize.Y.Offset or 0, 100)

	for _, v3 in ipairs(v) do
		local menuCard = itemTemplate:Clone()
		menuCard.Name = "MenuCard"
		menuCard.LayoutOrder = v3.order
		menuCard.Visible = true
		menuCard.BackgroundColor3 = color
		menuCard.BackgroundTransparency = 0
		menuCard.ZIndex = panel.ZIndex + 1

		local icon = menuCard:FindFirstChild("Icon")
		local iconImage = getIconImage(menuCard)
		local image = v3.image

		if not image and typeof(v3.icon) == "string" and v3.icon:match("^rbxasset") then
			image = v3.icon
		end

		if image then
			iconImage.Visible = true
			iconImage.Image = image
			iconImage.ImageColor3 = v3.color

			if icon and icon:IsA("TextLabel") then
				icon.Visible = false
			end
		else
			iconImage.Visible = false

			if icon and icon:IsA("TextLabel") then
				icon.Visible = true
				icon.Text = v3.icon or ""
				icon.TextColor3 = v3.color
				icon.ZIndex = menuCard.ZIndex + 2
				configureTextLabel(icon, 22, math.clamp(math.floor(v2 * 0.42), 34, 56)) -- inferred equivalent call
			end
		end

		local label = menuCard:FindFirstChild("Label")

		if label and label:IsA("TextLabel") then
			label.Text = v3.name
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.Font = Enum.Font.GothamBold
			label.ZIndex = menuCard.ZIndex + 2
			configureTextLabel(label, 11, math.clamp(math.floor(v2 * 0.16), 15, 20)) -- inferred equivalent call
		end

		local hitbox = Instance.new("TextButton")
		hitbox.Name = "Hitbox"
		hitbox.Size = UDim2.new(1, 0, 1, 0)
		hitbox.BackgroundTransparency = 1
		hitbox.Text = ""
		hitbox.ZIndex = menuCard.ZIndex + 5
		hitbox.Parent = menuCard

		hitbox.MouseEnter:Connect(function()
			TweenService:Create(menuCard, tweenInfo, { BackgroundColor3 = color2 }):Play()
		end)
		hitbox.MouseLeave:Connect(function()
			TweenService:Create(menuCard, tweenInfo, { BackgroundColor3 = color }):Play()
		end)

		hitbox.MouseButton1Click:Connect(function()
			fireAction(v3)
		end)

		menuCard.Parent = panel
	end
end

overlay.MouseButton1Click:Connect(close)

local OpenMenuGrid = ReplicatedStorage2:FindFirstChild("OpenMenuGrid")

if not (OpenMenuGrid and OpenMenuGrid:IsA("BindableEvent")) then
	if OpenMenuGrid then
		OpenMenuGrid:Destroy()
	end

	OpenMenuGrid = Instance.new("BindableEvent")
	OpenMenuGrid.Name = "OpenMenuGrid"
	OpenMenuGrid.Parent = ReplicatedStorage2
end

OpenMenuGrid.Event:Connect(function()
	if not flag then
		applyResponsiveLayout()
		buildGrid()
	end

	open()
end)

local function refreshOpenLayout() -- 1 equivalent call inferred from this helper
	if not flag then
		return
	end

	applyResponsiveLayout()
	buildGrid()
end

if CurrentCamera then
	CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshOpenLayout)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	CurrentCamera = workspace.CurrentCamera

	if CurrentCamera then
		CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshOpenLayout)
	end

	refreshOpenLayout() -- inferred equivalent call
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape and flag then
		close()
	end
end)

ClientDebugConfig.Print("[MenuGrid] Initialized with " .. #v .. " item(s)")