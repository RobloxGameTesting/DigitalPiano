local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
game:GetService("MarketplaceService")

local SlideFX = require(ReplicatedStorage2:WaitForChild("Services"):WaitForChild("SlideFX"))

local clickSound = ReplicatedStorage2:WaitForChild("SoundFX"):WaitForChild("ClickSound")

local parent = script.Parent
local menuOptions = parent:WaitForChild("MenuOptions")
local buttons = menuOptions:WaitForChild("Buttons")
local stats = parent:FindFirstChild("Stats") or parent:WaitForChild("Leaderboard")

local function waitForStartupChild(instance, childName, p)
	if not instance then
		return nil
	end

	local child = instance:FindFirstChild(childName)

	if child then
		return child
	end

	local child2 = instance:WaitForChild(childName, 30)

	if not child2 then
		ClientDebugConfig.Warn(("[BottomBar] Missing %s under %s after startup wait%s"):format(
			childName,
			instance:GetFullName(),
			p and " for " .. p or ""
		))
	end

	return child2
end

local v = waitForStartupChild(Players.LocalPlayer, "PlayerGui", "settings button setup")

if not v then
	return
end

local v2 = waitForStartupChild(v, "Settings", "settings button setup")

if not v2 then
	return
end

local v3 = waitForStartupChild(v2, "Settings", "settings button setup")

if not v3 then
	return
end

local color = Color3.fromRGB(84, 173, 255)
local color2 = Color3.new(1, 1, 1)
local color3 = Color3.fromRGB(200, 230, 255)

local Quint = Enum.EasingStyle.Quint

local tooltip = nil

local function isGuiShown(guiObject): boolean
	while guiObject and guiObject ~= parent do
		if guiObject:IsA("GuiObject") and not guiObject.Visible then
			return false
		end

		guiObject = guiObject.Parent
	end

	return true
end

local function isPianoOverlayActive(): boolean
	for _, childName in ipairs({ "PianoContainer", "MobilePianoContainer", "PianoRoll2D" }) do
		local guiObject = parent:FindFirstChild(childName)

		if guiObject and guiObject:IsA("GuiObject") and guiObject.Visible then
			return true
		end
	end

	return false
end

local function createTooltip()
	if tooltip then
		return tooltip
	end

	tooltip = Instance.new("TextLabel")
	tooltip.Name = "Tooltip"
	tooltip.Size = UDim2.new(0, 0, 0, 40)
	tooltip.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
	tooltip.BackgroundTransparency = 0.1
	tooltip.BorderSizePixel = 0
	tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
	tooltip.Font = Enum.Font.GothamBold
	tooltip.TextSize = 16
	tooltip.TextXAlignment = Enum.TextXAlignment.Center
	tooltip.TextYAlignment = Enum.TextYAlignment.Center
	tooltip.Visible = false
	tooltip.ZIndex = 10000
	tooltip.AutomaticSize = Enum.AutomaticSize.X
	tooltip.Parent = parent

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 12)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.PaddingBottom = UDim.new(0, 8)
	uiPadding.Parent = tooltip

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = tooltip

	return tooltip
end

local function showTooltip(name: string, instance)
	if isPianoOverlayActive() or not (isGuiShown(menuOptions) and isGuiShown(instance)) then
		if tooltip then
			tooltip.Visible = false
		end
	else
		local tooltip2 = createTooltip()
		tooltip2.Text = tostring(instance:GetAttribute("TooltipText") or name)

		local absolutePosition = instance.AbsolutePosition
		local absoluteSize = instance.AbsoluteSize

		local v4 = absolutePosition.X + absoluteSize.X / 2
		local v5 = absolutePosition.Y - 5

		tooltip2.Position = UDim2.new(0, v4, 0, v5)
		tooltip2.AnchorPoint = Vector2.new(0.5, 1)
		tooltip2.Visible = true

		task.wait()

		local absoluteSize2 = parent.AbsoluteSize
		local absoluteSize3 = tooltip2.AbsoluteSize
		local v6 = v4 - absoluteSize3.X / 2

		if v4 + absoluteSize3.X / 2 > absoluteSize2.X then
			v4 = absoluteSize2.X - absoluteSize3.X / 2 - 10
		elseif v6 < 0 then
			v4 = absoluteSize3.X / 2 + 10
		end

		tooltip2.Position = UDim2.new(0, v4, 0, v5)
	end
end

local function hideTooltip() -- 2 equivalent calls inferred from this helper
	if tooltip then
		tooltip.Visible = false
	end
end

local function hideTooltipWhenChanged(guiObject) -- 4 equivalent calls inferred from this helper
	if guiObject and guiObject:IsA("GuiObject") then
		guiObject:GetPropertyChangedSignal("Visible"):Connect(hideTooltip)
	end
end

hideTooltipWhenChanged(menuOptions) -- inferred equivalent call
hideTooltipWhenChanged(parent:FindFirstChild("PianoContainer")) -- inferred equivalent call
hideTooltipWhenChanged(parent:FindFirstChild("MobilePianoContainer")) -- inferred equivalent call
hideTooltipWhenChanged(parent:FindFirstChild("PianoRoll2D")) -- inferred equivalent call

local function ensureUIScale(parent2) -- 1 equivalent call inferred from this helper
	local v4 = parent2:FindFirstChildOfClass("UIScale")

	if not v4 then
		v4 = Instance.new("UIScale")
		v4.Scale = 1
		v4.Parent = parent2
	end

	return v4
end

local function ensureStroke(background) -- 1 equivalent call inferred from this helper
	local v4 = background:FindFirstChildOfClass("UIStroke")

	if v4 then
		return v4
	end

	v4 = Instance.new("UIStroke")
	v4.Thickness = 1.5
	v4.Transparency = 1
	v4.LineJoinMode = Enum.LineJoinMode.Round
	v4.Parent = background

	return v4
end

local function tween(instance, duration, goal) -- 10 equivalent calls inferred from this helper
	return TweenService:Create(instance, TweenInfo.new(duration, Quint, Enum.EasingDirection.Out), goal)
end

local function wireButton(button)
	local background = button:FindFirstChild("Background")
	local icon = background and background:FindFirstChild("Icon")

	if not (background and icon) then
		ClientDebugConfig.Warn("[HoverSolid] Skipping " .. button:GetFullName() .. " (needs Background/Icon)")
		return
	end

	local backgroundColor3 = background.BackgroundColor3
	local backgroundTransparency = background.BackgroundTransparency
	local imageColor3 = icon.ImageColor3
	local uiScale = ensureUIScale(button) -- inferred equivalent call
	local stroke = ensureStroke(background) -- inferred equivalent call
	local v4 = false
	local _ = false
	local v5 = nil
	local v6 = nil
	local v7 = nil
	local v8 = nil

	local function applyHover(flag: boolean)
		v4 = flag

		if v5 then
			v5:Cancel()
		end

		if v6 then
			v6:Cancel()
		end

		if v7 then
			v7:Cancel()
		end

		if v8 then
			v8:Cancel()
		end

		if flag then
			v5 = tween(background, 0.16, { BackgroundColor3 = color, BackgroundTransparency = 0 }) -- inferred equivalent call
			v6 = tween(icon, 0.16, { ImageColor3 = color2 }) -- inferred equivalent call
			v7 = tween(uiScale, 0.16, { Scale = 1.06 }) -- inferred equivalent call
			stroke.Color = color3
			v8 = tween(stroke, 0.16, { Transparency = 0.15 }) -- inferred equivalent call
		else
			v5 = tween(background, 0.16, { -- inferred equivalent call
				BackgroundColor3 = backgroundColor3,
				BackgroundTransparency = backgroundTransparency
			})
			v6 = tween(icon, 0.16, { ImageColor3 = imageColor3 }) -- inferred equivalent call
			v7 = tween(uiScale, 0.16, { Scale = 1 }) -- inferred equivalent call
			v8 = tween(stroke, 0.16, { Transparency = 1 }) -- inferred equivalent call
		end

		v5:Play()
		v6:Play()
		v7:Play()
		v8:Play()
	end

	local function applyPress(flag: boolean) -- 4 equivalent calls inferred from this helper
		_ = flag

		if v7 then
			v7:Cancel()
		end

		if flag then
			v7 = tween(uiScale, 0.1, { Scale = 0.98 }) -- inferred equivalent call
		else
			v7 = tween(uiScale, 0.1, { -- inferred equivalent call
				Scale = v4 and 1.06 or 1
			})
		end

		v7:Play()
	end

	button.MouseEnter:Connect(function()
		applyHover(true)
		showTooltip(button.Name, button)
	end)
	button.MouseLeave:Connect(function()
		applyHover(false)
		hideTooltip() -- inferred equivalent call
	end)
	button.MouseButton1Down:Connect(function()
		hideTooltip() -- inferred equivalent call
		applyPress(true) -- inferred equivalent call
		clickSound:Play()
	end)
	button.MouseButton1Up:Connect(function()
		applyPress(false) -- inferred equivalent call
	end)

	button.TouchTap:Connect(function()
		applyPress(true) -- inferred equivalent call
		task.delay(0.07, function()
			applyPress(false) -- inferred equivalent call
		end)
	end)

	button.SelectionGained:Connect(function()
		applyHover(true)
	end)
	button.SelectionLost:Connect(function()
		applyHover(false)
	end)
end

for _, button in ipairs(buttons:GetChildren()) do
	if button:IsA("TextButton") then
		wireButton(button)
	end
end

buttons.ChildAdded:Connect(function(button)
	if button:IsA("TextButton") then
		wireButton(button)
	end
end)

stats.AnchorPoint = Vector2.new(0.5, 0.5)

if stats.Position == UDim2.new() then
	stats.Position = UDim2.fromScale(0.5, 0.5)
end

local v4 = SlideFX.attach(stats, {
	direction = "right",
	startHidden = true,
	inTime = 0.25,
	outTime = 0.22,
	easeIn = Enum.EasingStyle.Quad,
	easeOut = Enum.EasingStyle.Quad
})

local function getBlur() -- 1 equivalent call inferred from this helper
	local v5 = Lighting:FindFirstChildOfClass("BlurEffect")

	if not v5 then
		v5 = Instance.new("BlurEffect")
		v5.Size = 0
		v5.Parent = Lighting
	end

	return v5
end

local function setBlur(p)
	TweenService:Create(getBlur(), TweenInfo.new(0.15, Enum.EasingStyle.Quad), { -- inferred equivalent call
		Size = p and 12 or 0
	}):Play()
end

local function openLB() -- 1 equivalent call inferred from this helper
	if v4:IsOpen() then
		return
	end

	setBlur(true)
	v4:Show()
end
local function closeLB() -- 3 equivalent calls inferred from this helper
	if not v4:IsOpen() then
		return
	end

	v4:Hide()
	setBlur(false)
end
local function toggleLB()
	if v4:IsOpen() then
		closeLB() -- inferred equivalent call
	else
		openLB() -- inferred equivalent call
	end
end

local leaderboard = buttons:FindFirstChild("Leaderboard")

if leaderboard and leaderboard:IsA("TextButton") then
	leaderboard.MouseButton1Click:Connect(toggleLB)
end

local function pointInside(p, vector2: Vector2): boolean -- 2 equivalent calls inferred from this helper
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return vector2.X >= absolutePosition.X
		and vector2.X <= absolutePosition.X + absoluteSize.X
		and vector2.Y >= absolutePosition.Y
		and vector2.Y <= absolutePosition.Y + absoluteSize.Y
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not v4:IsOpen() then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local position = input.Position and input.Position or UserInputService:GetMouseLocation()

		if not pointInside(stats, Vector2.new(position.X, position.Y)) then -- inferred equivalent call
			closeLB() -- inferred equivalent call
		end
	end

	if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
		closeLB() -- inferred equivalent call
	end
end)

local close = stats:FindFirstChild("Close", true)
local textButton = close and close:FindFirstChildWhichIsA("TextButton", true)

if textButton then
	textButton.MouseButton1Click:Connect(closeLB)
end

v3.AnchorPoint = Vector2.new(0.5, 0.5)

if v3.Position == UDim2.new() then
	v3.Position = UDim2.fromScale(0.5, 0.5)
end

local v5 = SlideFX.attach(v3, {
	direction = "right",
	startHidden = true,
	inTime = 0.25,
	outTime = 0.22,
	easeIn = Enum.EasingStyle.Quad,
	easeOut = Enum.EasingStyle.Quad
})

local function bringSettingsToFront()
	v2.DisplayOrder = math.max(v2.DisplayOrder, 1000)
	v2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	v3.ZIndex = math.max(v3.ZIndex, 100)

	local shadow = v3:FindFirstChild("Shadow")

	if shadow and shadow:IsA("GuiObject") then
		shadow.Visible = false
		shadow.Active = false
		shadow.ZIndex = math.max(v3.ZIndex - 1, 1)
	end

	local center = v3:FindFirstChild("Center")

	if center and center:IsA("GuiObject") then
		center.ZIndex = v3.ZIndex + 1
	end
end

local function openSettings() -- 3 equivalent calls inferred from this helper
	if v5:IsOpen() then
		return
	end

	bringSettingsToFront()
	setBlur(true)
	v5:Show()
end
local function closeSettings() -- 4 equivalent calls inferred from this helper
	if not v5:IsOpen() then
		return
	end

	v5:Hide()
	setBlur(false)
end
local function toggleSettings()
	if v5:IsOpen() then
		closeSettings() -- inferred equivalent call
	else
		openSettings() -- inferred equivalent call
	end
end

local settings = buttons:FindFirstChild("Settings")

if settings and settings:IsA("TextButton") then
	settings.MouseButton1Click:Connect(toggleSettings)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not v5:IsOpen() then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local position = input.Position and input.Position or UserInputService:GetMouseLocation()

		if not pointInside(v3, Vector2.new(position.X, position.Y)) then -- inferred equivalent call
			closeSettings() -- inferred equivalent call
		end
	end

	if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
		closeSettings() -- inferred equivalent call
	end
end)

local SettingsCloseEvent = ReplicatedStorage2:FindFirstChild("SettingsCloseEvent")

if not SettingsCloseEvent then
	SettingsCloseEvent = Instance.new("BindableEvent")
	SettingsCloseEvent.Name = "SettingsCloseEvent"
	SettingsCloseEvent.Parent = ReplicatedStorage2
end

SettingsCloseEvent.Event:Connect(function()
	closeSettings() -- inferred equivalent call
	ClientDebugConfig.Print("[BottomBar] Settings closed via close button")
end)

local function getMenuBindable(name) -- 5 equivalent calls inferred from this helper
	local v6 = ReplicatedStorage2:FindFirstChild(name)

	if v6 and v6:IsA("BindableEvent") then
		return v6
	end

	if v6 then
		v6:Destroy()
	end

	v6 = Instance.new("BindableEvent")
	v6.Name = name
	v6.Parent = ReplicatedStorage2

	return v6
end

getMenuBindable("OpenSettingsNotebinds").Event:Connect(function() -- inferred equivalent call
	openSettings() -- inferred equivalent call
end)

getMenuBindable("OpenAutoPlayerKeybindSettings").Event:Connect(function() -- inferred equivalent call
	openSettings() -- inferred equivalent call
end)

getMenuBindable("OpenSettings").Event:Connect(openSettings) -- inferred equivalent call

getMenuBindable("OpenLeaderboard").Event:Connect(openLB) -- inferred equivalent call

local inviteFriends = buttons:FindFirstChild("InviteFriends")

if inviteFriends and inviteFriends:IsA("TextButton") then
	inviteFriends.MouseButton1Click:Connect(function()
		local localPlayer = Players.LocalPlayer

		local success, result = pcall(function()
			SocialService:PromptGameInvite(localPlayer)
		end)

		if success then
			ClientDebugConfig.Print("[InviteFriends] Invite prompt opened successfully")
		else
			ClientDebugConfig.Warn("[InviteFriends] Failed to show invite prompt: " .. tostring(result))
		end
	end)
end

local function openOwnProfile()
	getMenuBindable("OpenPremium"):Fire() -- inferred equivalent call
end

local profile = buttons:FindFirstChild("Profile") or buttons:FindFirstChild("Premium")

if profile and profile:IsA("TextButton") then
	profile.Name = "Profile"
	profile:SetAttribute("TooltipText", "Profile")
	profile.MouseButton1Click:Connect(openOwnProfile)
end

local OpenPremium = ReplicatedStorage2:FindFirstChild("OpenPremium")

if not (OpenPremium and OpenPremium:IsA("BindableEvent")) then
	if OpenPremium then
		OpenPremium:Destroy()
	end

	local openPremium = Instance.new("BindableEvent")
	openPremium.Name = "OpenPremium"
	openPremium.Parent = ReplicatedStorage2
end

local gridMenu = buttons:FindFirstChild("GridMenu")

if gridMenu and gridMenu:IsA("TextButton") then
	gridMenu.MouseButton1Click:Connect(function()
		local openMenuGrid = ReplicatedStorage2:FindFirstChild("OpenMenuGrid")

		if openMenuGrid then
			openMenuGrid:Fire()
		end
	end)
end