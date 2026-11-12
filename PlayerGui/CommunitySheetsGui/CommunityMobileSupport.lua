local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local CommunityMobileSupport = {}

CommunityMobileSupport.IconAssets = {
	Community = "rbxassetid://113539366357576",
	MIDI = "rbxassetid://99706987477553",
	Profile = "rbxassetid://138510965237421",
	Publish = "rbxassetid://85879415343667",
	Close = "rbxassetid://6031094678",
	ShieldToggle = "rbxassetid://139658992048194",
	Reports = "rbxassetid://83417840616686",
	Hidden = "rbxassetid://83417840616686",
	Blocked = "rbxassetid://83417840616686",
	Refresh = "rbxassetid://79975264739465",
	Sort = "rbxassetid://88066022105997",
	Thumb = "rbxassetid://138494039014727"
}

CommunityMobileSupport.SortOrder = { "Default", "Newest", "Oldest", "TopLiked", "MostPlayed" }
CommunityMobileSupport.SortLabels = {
	Default = "Default",
	Newest = "Newest",
	Oldest = "Oldest",
	TopLiked = "Top Liked",
	MostPlayed = "Most Played"
}

local v = {
	{ Name = "Community", Label = "Sheets", Icon = "Community", LayoutOrder = 10 },
	{ Name = "MIDI", Label = "MIDI", Icon = "MIDI", LayoutOrder = 20 },
	{ Name = "Profile", Label = "Me", Icon = "Profile", LayoutOrder = 30 },
	{ Name = "Reports", Label = "Reports", Icon = "Reports", LayoutOrder = 40 },
	{ Name = "Hidden", Label = "Hidden", Icon = "Hidden", LayoutOrder = 50 },
	{ Name = "Blocked", Label = "Blocked", Icon = "Blocked", LayoutOrder = 60 },
	{ Name = "ShieldToggle", Label = "Mod", Icon = "ShieldToggle", LayoutOrder = 70 },
	{ Name = "Publish", Label = "Publish", Icon = "Publish", LayoutOrder = 80 },
	{ Name = "Close", Label = "Close", Icon = "Close", LayoutOrder = 90 }
}

local function ensureCorner(parent, udim) -- 21 equivalent calls inferred from this helper
	local v2 = parent:FindFirstChildOfClass("UICorner")

	if not v2 then
		v2 = Instance.new("UICorner")
		v2.Parent = parent
	end

	v2.CornerRadius = udim or UDim.new(0, 10)
	return v2
end

local function ensureStroke(parent, name)
	local v2 = parent:FindFirstChild(name)

	if v2 and not v2:IsA("UIStroke") then
		v2:Destroy()
		v2 = nil
	end

	if v2 then
		return v2
	end

	v2 = Instance.new("UIStroke")
	v2.Name = name
	v2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	v2.LineJoinMode = Enum.LineJoinMode.Round
	v2.Parent = parent

	return v2
end

local function canUseAsButton(button) -- 1 equivalent call inferred from this helper
	return button and (button:IsA("TextButton") or button:IsA("ImageButton"))
end

function CommunityMobileSupport:EnsureIconButton(value)
	if not canUseAsButton(self) then -- inferred equivalent call
		return nil
	end

	if self:IsA("TextButton") then
		self.Text = ""
		self.TextTransparency = 1
	end

	self.AutoButtonColor = true
	self.BorderSizePixel = 0
	self.BackgroundColor3 = Color3.fromRGB(39, 44, 59)
	self.BackgroundTransparency = 0
	ensureCorner(self, UDim.new(0, 8)) -- inferred equivalent call
	local stroke = ensureStroke(self, "MobileIconStroke")
	stroke.Color = Color3.fromRGB(58, 68, 92)
	stroke.Thickness = 1
	stroke.Transparency = 0.55
	local buttonIcon = self:FindFirstChild("ButtonIcon")

	if buttonIcon and not buttonIcon:IsA("ImageLabel") then
		buttonIcon:Destroy()
		buttonIcon = nil
	end

	if not buttonIcon then
		buttonIcon = Instance.new("ImageLabel")
		buttonIcon.Name = "ButtonIcon"
		buttonIcon.BackgroundTransparency = 1
		buttonIcon.Active = false
		buttonIcon.Parent = self
	end

	buttonIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	buttonIcon.Position = UDim2.fromScale(0.5, 0.5)
	buttonIcon.Size = UDim2.fromOffset(20, 20)
	buttonIcon.Image = CommunityMobileSupport.IconAssets[value] or tostring(value or "")
	buttonIcon.ImageColor3 = Color3.fromRGB(190, 199, 216)
	buttonIcon.ScaleType = Enum.ScaleType.Fit
	buttonIcon.ZIndex = self.ZIndex + 1
	return buttonIcon
end

function CommunityMobileSupport.EnsureRailButton(parent, data, callback)
	local parent2 = parent:FindFirstChild(data.Name)

	if parent2 and not parent2:IsA("TextButton") then
		parent2:Destroy()
		parent2 = nil
	end

	if not parent2 then
		parent2 = Instance.new("TextButton")
		parent2.Name = data.Name
		parent2.Parent = parent
	end

	parent2.LayoutOrder = data.LayoutOrder or 100
	parent2.Size = UDim2.fromOffset(50, 40)
	parent2.AutoButtonColor = true
	parent2.BorderSizePixel = 0
	parent2.Text = ""
	parent2.TextTransparency = 1
	parent2.ClipsDescendants = false
	parent2.ZIndex = parent.ZIndex + 1
	ensureCorner(parent2, UDim.new(0, 10)) -- inferred equivalent call
	ensureStroke(parent2, "RailStroke")

	local activeBar = parent2:FindFirstChild("ActiveBar")

	if activeBar and not activeBar:IsA("Frame") then
		activeBar:Destroy()
		activeBar = nil
	end

	if not activeBar then
		activeBar = Instance.new("Frame")
		activeBar.Name = "ActiveBar"
		activeBar.BorderSizePixel = 0
		activeBar.Parent = parent2
		ensureCorner(activeBar, UDim.new(0, 4)) -- inferred equivalent call
	end

	activeBar.AnchorPoint = Vector2.new(0, 0.5)
	activeBar.Position = UDim2.new(0, 4, 0.5, 0)
	activeBar.Size = UDim2.fromOffset(3, 20)
	activeBar.ZIndex = parent2.ZIndex + 2

	local railIcon = parent2:FindFirstChild("RailIcon")

	if railIcon and not railIcon:IsA("ImageLabel") then
		railIcon:Destroy()
		railIcon = nil
	end

	if not railIcon then
		railIcon = Instance.new("ImageLabel")
		railIcon.Name = "RailIcon"
		railIcon.BackgroundTransparency = 1
		railIcon.Active = false
		railIcon.Parent = parent2
	end

	railIcon.Image = CommunityMobileSupport.IconAssets[data.Icon or data.Name] or ""
	railIcon.ScaleType = Enum.ScaleType.Fit
	railIcon.ZIndex = parent2.ZIndex + 2

	local railLabel = parent2:FindFirstChild("RailLabel")

	if railLabel and not railLabel:IsA("TextLabel") then
		railLabel:Destroy()
		railLabel = nil
	end

	if not railLabel then
		railLabel = Instance.new("TextLabel")
		railLabel.Name = "RailLabel"
		railLabel.BackgroundTransparency = 1
		railLabel.BorderSizePixel = 0
		railLabel.Font = Enum.Font.GothamSemibold
		railLabel.TextXAlignment = Enum.TextXAlignment.Center
		railLabel.Parent = parent2
	end

	railLabel.Text = data.Label or data.Name
	railLabel.Position = UDim2.new(0, 4, 1, -13)
	railLabel.Size = UDim2.new(1, -8, 0, 10)
	railLabel.ZIndex = parent2.ZIndex + 2

	if callback then
		callback(railLabel, 8, 6)
	end

	return parent2
end

function CommunityMobileSupport:StyleRailButton(visible, p, p2)
	if not (self and self:IsA("TextButton")) then
		return
	end

	self.Visible = p2 == true
	local backgroundColor = p or Color3.fromRGB(20, 160, 255)
	local backgroundColor2 = Color3.fromRGB(31, 36, 49)
	backgroundColor2 = visible and backgroundColor2:Lerp(backgroundColor, 0.26) or backgroundColor2
	self.BackgroundColor3 = backgroundColor2
	self.BackgroundTransparency = visible and 0 or 0.08
	local railStroke = self:FindFirstChild("RailStroke")

	if railStroke and railStroke:IsA("UIStroke") then
		railStroke.Color = visible and backgroundColor or Color3.fromRGB(56, 65, 87)
		railStroke.Thickness = 1
		railStroke.Transparency = visible and 0.24 or 0.7
	end

	local activeBar = self:FindFirstChild("ActiveBar")

	if activeBar and activeBar:IsA("Frame") then
		activeBar.Visible = visible
		activeBar.BackgroundColor3 = backgroundColor
	end

	local railIcon = self:FindFirstChild("RailIcon")

	if railIcon and railIcon:IsA("ImageLabel") then
		railIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		railIcon.Position = visible and UDim2.new(0.5, 0, 0, 15) or UDim2.fromScale(0.5, 0.5)
		railIcon.Size = visible and UDim2.fromOffset(18, 18) or UDim2.fromOffset(22, 22)
		railIcon.ImageColor3 = visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(173, 182, 200)
	end

	local railLabel = self:FindFirstChild("RailLabel")

	if railLabel and railLabel:IsA("TextLabel") then
		local visible2

		if visible then
			if self.Name == "Close" then
				visible2 = false
			else
				visible2 = self.Name ~= "Publish"
			end
		else
			visible2 = visible
		end

		railLabel.Visible = visible2
		railLabel.TextColor3 = visible and Color3.fromRGB(242, 246, 255) or Color3.fromRGB(160, 168, 185)
	end
end

function CommunityMobileSupport.EnsureSortMenu(p, callback)
	local mobileSortMenu = p.Main:FindFirstChild("MobileSortMenu")

	if mobileSortMenu and not mobileSortMenu:IsA("Frame") then
		mobileSortMenu:Destroy()
		mobileSortMenu = nil
	end

	if not mobileSortMenu then
		mobileSortMenu = Instance.new("Frame")
		mobileSortMenu.Name = "MobileSortMenu"
		mobileSortMenu.BackgroundColor3 = Color3.fromRGB(24, 28, 39)
		mobileSortMenu.BorderSizePixel = 0
		mobileSortMenu.Visible = false
		mobileSortMenu.Parent = p.Main
		ensureCorner(mobileSortMenu, UDim.new(0, 10)) -- inferred equivalent call
		local stroke = ensureStroke(mobileSortMenu, "MenuStroke")
		stroke.Color = Color3.fromRGB(73, 84, 110)
		stroke.Thickness = 1
		stroke.Transparency = 0.25
		local menuPadding = Instance.new("UIPadding")
		menuPadding.Name = "MenuPadding"
		menuPadding.PaddingTop = UDim.new(0, 7)
		menuPadding.PaddingBottom = UDim.new(0, 7)
		menuPadding.PaddingLeft = UDim.new(0, 8)
		menuPadding.PaddingRight = UDim.new(0, 8)
		menuPadding.Parent = mobileSortMenu
		local menuLayout = Instance.new("UIListLayout")
		menuLayout.Name = "MenuLayout"
		menuLayout.FillDirection = Enum.FillDirection.Vertical
		menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
		menuLayout.Padding = UDim.new(0, 3)
		menuLayout.Parent = mobileSortMenu
	end

	mobileSortMenu.AnchorPoint = Vector2.new(1, 0)
	mobileSortMenu.Position = UDim2.new(1, 0, 0, 114)
	mobileSortMenu.Size = UDim2.fromOffset(math.min(170, (math.max(142, p.Main.AbsoluteSize.X - 12))), 176)
	mobileSortMenu.ZIndex = 70

	for i, childName in ipairs(CommunityMobileSupport.SortOrder) do
		local v2 = mobileSortMenu:FindFirstChild(childName)

		if v2 and not v2:IsA("TextButton") then
			v2:Destroy()
			v2 = nil
		end

		if not v2 then
			v2 = Instance.new("TextButton")
			v2.Name = childName
			v2.AutoButtonColor = true
			v2.BorderSizePixel = 0
			v2.TextXAlignment = Enum.TextXAlignment.Left
			v2.Parent = mobileSortMenu
			ensureCorner(v2, UDim.new(0, 7)) -- inferred equivalent call
		end

		v2.LayoutOrder = i
		v2.Size = UDim2.new(1, 0, 0, 30)
		v2.ZIndex = mobileSortMenu.ZIndex + 1
		v2.Text = CommunityMobileSupport.SortLabels[childName] or childName

		if callback then
			callback(v2, 11, 7)
		end
	end

	return mobileSortMenu
end

function CommunityMobileSupport.EnsureShell(_, data, p)
	local rail = data.Rail
	rail.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
	rail.BackgroundTransparency = 0.02
	rail.BorderSizePixel = 0
	rail.ClipsDescendants = false
	ensureCorner(rail, UDim.new(0, 18)) -- inferred equivalent call
	local stroke = ensureStroke(rail, "RailShellStroke")
	stroke.Color = Color3.fromRGB(43, 50, 67)
	stroke.Thickness = 1
	stroke.Transparency = 0.38
	local railPadding = rail:FindFirstChild("RailPadding") or Instance.new("UIPadding")
	railPadding.Name = "RailPadding"
	railPadding.PaddingTop = UDim.new(0, 8)
	railPadding.PaddingBottom = UDim.new(0, 8)
	railPadding.PaddingLeft = UDim.new(0, 7)
	railPadding.PaddingRight = UDim.new(0, 7)
	railPadding.Parent = rail
	local railLayout = rail:FindFirstChild("RailLayout") or Instance.new("UIListLayout")
	railLayout.Name = "RailLayout"
	railLayout.FillDirection = Enum.FillDirection.Vertical
	railLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	railLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	railLayout.SortOrder = Enum.SortOrder.LayoutOrder
	railLayout.Padding = UDim.new(0, 6)
	railLayout.Parent = rail

	for _, v2 in ipairs(v) do
		CommunityMobileSupport.EnsureRailButton(rail, v2, p)
	end

	CommunityMobileSupport.EnsureIconButton(data.RefreshButton, "Refresh")
	CommunityMobileSupport.EnsureIconButton(data.SortButton, "Sort")
	CommunityMobileSupport.EnsureSortMenu(data, p)
end

function CommunityMobileSupport.UpdateSort(data)
	CommunityMobileSupport.EnsureIconButton(data.controls.RefreshButton, "Refresh")
	CommunityMobileSupport.EnsureIconButton(data.controls.SortButton, "Sort")
	local v2 = data.selectedMode == "Blocked" or data.selectedMode == "Profile"
	data.controls.SortButton.Visible = not v2
	local v3 = data.state.sortMode ~= "Default"
	local buttonIcon = data.controls.SortButton:FindFirstChild("ButtonIcon")

	if buttonIcon and buttonIcon:IsA("ImageLabel") then
		buttonIcon.ImageColor3 = v3 and Color3.fromRGB(20, 160, 255) or Color3.fromRGB(190, 199, 216)
	end

	local mobileIconStroke = data.controls.SortButton:FindFirstChild("MobileIconStroke")

	if mobileIconStroke and mobileIconStroke:IsA("UIStroke") then
		mobileIconStroke.Color = v3 and Color3.fromRGB(20, 160, 255) or Color3.fromRGB(58, 68, 92)
		mobileIconStroke.Transparency = v3 and 0.25 or 0.55
	end

	local sortMenu = CommunityMobileSupport.EnsureSortMenu(data.controls, data.configureTextObject)

	if v2 then
		sortMenu.Visible = false
	end

	for _, childName in ipairs(CommunityMobileSupport.SortOrder) do
		local button = sortMenu:FindFirstChild(childName)

		if not (button and button:IsA("TextButton")) then
			continue
		end

		local v4 = data.state.sortMode == childName
		button.BackgroundColor3 = v4 and Color3.fromRGB(20, 58, 87) or Color3.fromRGB(31, 36, 49)
		button.BackgroundTransparency = v4 and 0 or 0.35
		button.TextColor3 = v4 and Color3.fromRGB(116, 205, 255) or Color3.fromRGB(184, 193, 210)
		button.Font = v4 and Enum.Font.GothamSemibold or Enum.Font.GothamMedium
	end
end

function CommunityMobileSupport.UpdateNav(data)
	CommunityMobileSupport.EnsureShell(data.state, data.controls, data.configureTextObject)
	local canViewReports = data.canViewReports or data.canViewHiddenUploads

	if data.state.moderationTabsEnabled and not canViewReports then
		data.state.moderationTabsEnabled = false
	end

	for _, v2 in ipairs({ "Community", "MIDI", "Profile" }) do
		local modeConfig = data.modeConfigs[v2]
		CommunityMobileSupport.StyleRailButton(
			data.controls.Rail:FindFirstChild(modeConfig.Button),
			data.selectedMode == v2,
			modeConfig.Accent,
			not data.state.moderationTabsEnabled
		)
	end

	local v2 = {
		Reports = data.canViewReports,
		Hidden = data.canViewHiddenUploads,
		Blocked = data.canBlockCommunityUploads
	}

	for _, v3 in ipairs({ "Reports", "Hidden", "Blocked" }) do
		local modeConfig = data.modeConfigs[v3]
		CommunityMobileSupport.StyleRailButton(
			data.controls.Rail:FindFirstChild(modeConfig.Button),
			data.selectedMode == v3,
			modeConfig.Accent,
			data.state.moderationTabsEnabled and v2[v3] == true
		)
	end

	local color = data.state.moderationTabsEnabled and Color3.fromRGB(255, 101, 132) or Color3.fromRGB(37, 174, 255)
	CommunityMobileSupport.StyleRailButton(
		data.controls.Rail:FindFirstChild("ShieldToggle"),
		data.state.moderationTabsEnabled,
		color,
		canViewReports
	)
	CommunityMobileSupport.StyleRailButton(
		data.controls.Rail:FindFirstChild("Publish"),
		false,
		Color3.fromRGB(20, 160, 255),
		not data.state.moderationTabsEnabled
	)
	CommunityMobileSupport.StyleRailButton(
		data.controls.Rail:FindFirstChild("Close"),
		false,
		Color3.fromRGB(236, 72, 112),
		true
	)
	CommunityMobileSupport.UpdateSort(data)
end

function CommunityMobileSupport.UpdateDifficulty(data)
	for _, childName in ipairs(data.difficultyOrder) do
		local button = data.controls.DifficultyBar:FindFirstChild(childName)

		if not (button and button:IsA("TextButton")) then
			continue
		end

		local v2 = data.selectedDifficulty == childName
		button.AutoButtonColor = true
		button.BorderSizePixel = 0
		button.BackgroundTransparency = 1
		button.TextColor3 = v2 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 178, 194)
		button.Font = v2 and Enum.Font.GothamSemibold or Enum.Font.GothamMedium
		button.ZIndex = data.controls.DifficultyBar.ZIndex + 3
		local uiStroke = button:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Transparency = 1
		end

		if data.configureTextObject then
			data.configureTextObject(button, 9, 6)
		end
	end

	CommunityMobileSupport.MoveDifficulty(data)
end

function CommunityMobileSupport.MoveDifficulty(data)
	local difficultyBar = data.controls.DifficultyBar

	if not (difficultyBar and difficultyBar:IsA("Frame")) then
		return
	end

	local mobileDifficultyBarBackground = data.controls.Main:FindFirstChild("MobileDifficultyBarBackground")

	if mobileDifficultyBarBackground then
		mobileDifficultyBarBackground:Destroy()
	end

	local mobileDifficultySelectionIndicator = data.controls.Main:FindFirstChild("MobileDifficultySelectionIndicator")

	if mobileDifficultySelectionIndicator then
		mobileDifficultySelectionIndicator:Destroy()
	end

	local difficultyLayout = difficultyBar:FindFirstChild("DifficultyLayout")

	if difficultyLayout then
		difficultyLayout:Destroy()
	end

	local uiPadding = difficultyBar:FindFirstChildOfClass("UIPadding")

	if uiPadding then
		uiPadding:Destroy()
	end

	difficultyBar.Active = false
	difficultyBar.BorderSizePixel = 0
	difficultyBar.BackgroundColor3 = Color3.fromRGB(37, 42, 56)
	difficultyBar.BackgroundTransparency = 0
	ensureCorner(difficultyBar, UDim.new(0, 8)) -- inferred equivalent call
	local stroke = ensureStroke(difficultyBar, "MobileDifficultyBarStroke")
	stroke.Color = Color3.fromRGB(52, 61, 82)
	stroke.Thickness = 1
	stroke.Transparency = 0.62
	local button = difficultyBar:FindFirstChild(data.selectedDifficulty)

	if not (button and button:IsA("TextButton")) then
		return
	end

	local mobileDifficultySelectionIndicator2 = difficultyBar:FindFirstChild("MobileDifficultySelectionIndicator")

	if mobileDifficultySelectionIndicator2 and not mobileDifficultySelectionIndicator2:IsA("Frame") then
		mobileDifficultySelectionIndicator2:Destroy()
		mobileDifficultySelectionIndicator2 = nil
	end

	if not mobileDifficultySelectionIndicator2 then
		mobileDifficultySelectionIndicator2 = Instance.new("Frame")
		mobileDifficultySelectionIndicator2.Name = "MobileDifficultySelectionIndicator"
		mobileDifficultySelectionIndicator2.Parent = difficultyBar
	end

	mobileDifficultySelectionIndicator2.Active = false
	mobileDifficultySelectionIndicator2.BorderSizePixel = 0
	ensureCorner(mobileDifficultySelectionIndicator2, UDim.new(0, 8)) -- inferred equivalent call
	mobileDifficultySelectionIndicator2.ZIndex = difficultyBar.ZIndex + 1
	local visible = difficultyBar.Visible and button.Visible
	mobileDifficultySelectionIndicator2.Visible = visible

	if not visible then
		return
	end

	local udim = UDim2.fromOffset(
		math.round(button.AbsolutePosition.X - difficultyBar.AbsolutePosition.X),
		(math.round(button.AbsolutePosition.Y - difficultyBar.AbsolutePosition.Y))
	)
	local udim2 = UDim2.fromOffset(math.round(button.AbsoluteSize.X), (math.round(button.AbsoluteSize.Y)))
	local visual = data.getVisual(data.selectedDifficulty)
	mobileDifficultySelectionIndicator2.BackgroundColor3 = visual.Background
	local stroke2 = ensureStroke(mobileDifficultySelectionIndicator2, "SelectionStroke")
	stroke2.Color = visual.Border
	stroke2.Thickness = 1
	stroke2.Transparency = 0.28

	if data.state.mobileDifficultyIndicatorTween then
		data.state.mobileDifficultyIndicatorTween:Cancel()
		data.state.mobileDifficultyIndicatorTween = nil
	end

	if data.animated then
		data.state.mobileDifficultyIndicatorTween = TweenService:Create(
			mobileDifficultySelectionIndicator2,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = udim, Size = udim2 }
		)
		data.state.mobileDifficultyIndicatorTween:Play()
	else
		mobileDifficultySelectionIndicator2.Position = udim
		mobileDifficultySelectionIndicator2.Size = udim2
	end
end

function CommunityMobileSupport.ToggleSortMenu(p)
	local sortMenu = CommunityMobileSupport.EnsureSortMenu(p.controls, p.configureTextObject)
	sortMenu.Visible = not sortMenu.Visible
	CommunityMobileSupport.UpdateSort(p)
end

function CommunityMobileSupport.HideSortMenu(p)
	local mobileSortMenu = p.Main:FindFirstChild("MobileSortMenu")

	if mobileSortMenu then
		mobileSortMenu.Visible = false
	end
end

function CommunityMobileSupport.ConnectSortOptions(data)
	if data.state.mobileSortOptionsConnected then
		return
	end

	data.state.mobileSortOptionsConnected = true

	for _, childName in ipairs(CommunityMobileSupport.SortOrder) do
		local button = CommunityMobileSupport.EnsureSortMenu(data.controls, data.configureTextObject):FindFirstChild(childName)

		if button and button:IsA("TextButton") then
			button.Activated:Connect(function()
				data.setSortMode(childName)
			end)
		end
	end
end

function CommunityMobileSupport.ApplyCardLayout(p, instance)
	local v2 = math.clamp(math.floor(math.max(240, p.cardWidth or instance.AbsoluteSize.X) * 0.28), 88, 116)
	local v3 = v2 + 12
	instance.ClipsDescendants = true
	local iconHolder = instance:FindFirstChild("IconHolder")

	if iconHolder and iconHolder:IsA("GuiObject") then
		iconHolder.Position = UDim2.fromOffset(0, 0)
		iconHolder.Size = UDim2.new(0, v2, 1, 0)
	end

	local difficultyBadge = instance:FindFirstChild("DifficultyBadge")

	if difficultyBadge and difficultyBadge:IsA("GuiObject") then
		difficultyBadge.AnchorPoint = Vector2.new(1, 0)
		difficultyBadge.Position = UDim2.new(1, -10, 0, 10)
		difficultyBadge.Size = UDim2.fromOffset(96, 24)
	end

	local title = instance:FindFirstChild("Title")

	if title and title:IsA("GuiObject") then
		title.Position = UDim2.fromOffset(v3, 14)
		title.Size = UDim2.new(1, -(v3 + 112), 0, 24)
	end

	local creator = instance:FindFirstChild("Creator")

	if creator and creator:IsA("GuiObject") then
		creator.Position = UDim2.fromOffset(v3, 39)
		creator.Size = UDim2.new(1, -(v3 + 24), 0, 18)
	end

	local creatorLink = instance:FindFirstChild("CreatorLink")

	if creatorLink and creatorLink:IsA("GuiObject") and creator and creator:IsA("GuiObject") then
		creatorLink.Position = creator.Position
		creatorLink.Size = creator.Size
	end

	local preview = instance:FindFirstChild("Preview")

	if preview and preview:IsA("GuiObject") then
		preview.Position = UDim2.fromOffset(v3, 62)
		preview.Size = UDim2.new(1, -(v3 + 24), 0, 22)
	end

	local stats = instance:FindFirstChild("Stats")

	if stats and stats:IsA("GuiObject") then
		stats.Position = UDim2.new(0, v3, 1, -34)
		stats.Size = UDim2.fromOffset(132, 26)
	end

	local favoriteButton = instance:FindFirstChild("FavoriteButton")

	if favoriteButton and favoriteButton:IsA("GuiObject") and favoriteButton.Visible then
		favoriteButton.Position = UDim2.new(1, -96, 1, -36)
		favoriteButton.Size = UDim2.fromOffset(54, 28)
	end

	local moreButton = instance:FindFirstChild("MoreButton")

	if moreButton and moreButton:IsA("GuiObject") and moreButton.Visible then
		moreButton.Position = UDim2.new(1, -36, 1, -36)
		moreButton.Size = UDim2.fromOffset(28, 28)
	end

	local uploadDate = instance:FindFirstChild("UploadDate")

	if uploadDate and uploadDate:IsA("GuiObject") then
		uploadDate.Visible = false
	end

	local clickTarget = instance:FindFirstChild("ClickTarget")

	if clickTarget and clickTarget:IsA("GuiObject") then
		clickTarget.Position = UDim2.fromScale(0, 0)
		clickTarget.Size = UDim2.fromScale(1, 1)
	end
end

function CommunityMobileSupport.CreateBlockedCard(data, player, layoutOrder)
	local blockedUserCard = Instance.new("Frame")
	blockedUserCard.Name = "BlockedUserCard"
	blockedUserCard.LayoutOrder = layoutOrder
	blockedUserCard.BackgroundColor3 = Color3.fromRGB(27, 30, 39)
	blockedUserCard.BorderSizePixel = 0
	blockedUserCard.Parent = data.controls.CardGrid
	ensureCorner(blockedUserCard, UDim.new(0, 10)) -- inferred equivalent call
	local stroke = ensureStroke(blockedUserCard, "BlockedStroke")
	stroke.Color = Color3.fromRGB(235, 93, 130)
	stroke.Thickness = 1
	stroke.Transparency = 0.48
	local userId = math.floor(tonumber(player.UserId) or 0)
	local image = tostring(player.AvatarImage or "")

	if image == "" and userId > 0 then
		image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
	end

	local avatar = Instance.new("ImageLabel")
	avatar.Name = "Avatar"
	avatar.Position = UDim2.fromOffset(14, 14)
	avatar.Size = UDim2.fromOffset(42, 42)
	avatar.BackgroundColor3 = Color3.fromRGB(18, 21, 29)
	avatar.BorderSizePixel = 0
	avatar.Image = image
	avatar.ScaleType = Enum.ScaleType.Crop
	avatar.Parent = blockedUserCard
	ensureCorner(avatar, UDim.new(1, 0)) -- inferred equivalent call
	local stroke2 = ensureStroke(avatar, "AvatarStroke")
	stroke2.Color = Color3.fromRGB(57, 63, 78)
	stroke2.Transparency = 0.25

	local displayName = Instance.new("TextLabel")
	displayName.Name = "DisplayName"
	displayName.Position = UDim2.fromOffset(66, 12)
	displayName.Size = UDim2.new(1, -190, 0, 24)
	displayName.BackgroundTransparency = 1
	displayName.Font = Enum.Font.GothamSemibold
	displayName.TextColor3 = Color3.fromRGB(242, 244, 250)
	displayName.TextXAlignment = Enum.TextXAlignment.Left
	local text = tostring(player.DisplayName or "")

	if text == "" then
		text = tostring(player.Name or "")
	end

	if text == "" then
		text = "User " .. tostring(player.UserId or 0)
	end

	displayName.Text = text
	displayName.Parent = blockedUserCard
	data.configureTextObject(displayName, 15, 9)
	local handle = Instance.new("TextLabel")
	handle.Name = "Handle"
	handle.Position = UDim2.fromOffset(66, 37)
	handle.Size = UDim2.new(1, -80, 0, 18)
	handle.BackgroundTransparency = 1
	handle.Font = Enum.Font.Gotham
	handle.TextColor3 = Color3.fromRGB(145, 154, 174)
	handle.TextXAlignment = Enum.TextXAlignment.Left
	local name = tostring(player.Name or "")
	local v2 = name == "" and "Unknown" or name

	handle.Text = string.format("@%s | User ID %s", v2, (tostring(player.UserId or 0)))
	handle.Parent = blockedUserCard
	data.configureTextObject(handle, 10, 7)
	local reason = Instance.new("TextLabel")
	reason.Name = "Reason"
	reason.Position = UDim2.fromOffset(14, 64)
	reason.Size = UDim2.new(1, -148, 0, 36)
	reason.BackgroundTransparency = 1
	reason.Font = Enum.Font.Gotham
	reason.TextColor3 = Color3.fromRGB(190, 196, 210)
	reason.TextXAlignment = Enum.TextXAlignment.Left
	reason.TextYAlignment = Enum.TextYAlignment.Top
	reason.Text = "Reason: " .. tostring(player.Reason == "" and "No reason saved." or player.Reason or "No reason saved.")
	reason.Parent = blockedUserCard
	data.configureTextObject(reason, 11, 7)
	local unblockButton = Instance.new("TextButton")
	unblockButton.Name = "UnblockButton"
	unblockButton.AnchorPoint = Vector2.new(1, 1)
	unblockButton.Position = UDim2.new(1, -12, 1, -12)
	unblockButton.Size = UDim2.fromOffset(112, 32)
	unblockButton.BackgroundColor3 = Color3.fromRGB(34, 91, 78)
	unblockButton.BorderSizePixel = 0
	unblockButton.AutoButtonColor = true
	unblockButton.Font = Enum.Font.GothamBold
	unblockButton.TextColor3 = Color3.fromRGB(121, 255, 207)
	unblockButton.Text = data.state.unblockingUserIds
		and data.state.unblockingUserIds[player.UserId]
		and "WORKING..."
		or "UNBLOCK"
	unblockButton.Parent = blockedUserCard
	ensureCorner(unblockButton, UDim.new(0, 8)) -- inferred equivalent call
	local stroke3 = ensureStroke(unblockButton, "ButtonStroke")
	stroke3.Color = Color3.fromRGB(52, 211, 153)
	stroke3.Transparency = 0.35
	data.configureTextObject(unblockButton, 10, 7)
	table.insert(data.cardConnections, unblockButton.Activated:Connect(function()
		data.unblock(player)
	end))
end

local function profileText(parent, name, options, configureTextObject, value, value2)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 0
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Center

	for k, v2 in pairs(options or {}) do
		textLabel[k] = v2
	end

	textLabel.Parent = parent

	if configureTextObject then
		configureTextObject(textLabel, value or 12, value2 or 8)
	end

	return textLabel
end

local function profileButton(parent, name, options, configureTextObject, value, value2)
	local textButton = Instance.new("TextButton")
	textButton.Name = name
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = true
	textButton.TextWrapped = true
	textButton.TextScaled = true

	for k, v2 in pairs(options or {}) do
		textButton[k] = v2
	end

	textButton.Parent = parent
	ensureCorner(textButton, UDim.new(0, 8)) -- inferred equivalent call

	if configureTextObject then
		configureTextObject(textButton, value or 11, value2 or 7)
	end

	return textButton
end

local function profileImage(player, appearance, data) -- 1 equivalent call inferred from this helper
	local profileAssetImage = data.profileAssetImage(appearance.AvatarAssetId)

	if profileAssetImage ~= "" then
		return profileAssetImage
	end

	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)

	return success and result or ""
end

function CommunityMobileSupport.ClearProfile(p)
	local profileMobileView = p.CardGrid:FindFirstChild("ProfileMobileView")

	if profileMobileView then
		profileMobileView:Destroy()
	end
end

function CommunityMobileSupport.RenderProfile(data, player)
	CommunityMobileSupport.ClearProfile(data.controls)
	data.controls.GridLayout.Parent = nil
	data.controls.CardGrid.Visible = true
	data.controls.EmptyLabel.Visible = false
	local previousCanvas = data.previousCanvas or data.controls.CardGrid.CanvasPosition
	local v2 = math.max(320, data.controls.CardGrid.AbsoluteSize.X)
	local profileMobileView = Instance.new("Frame")
	profileMobileView.Name = "ProfileMobileView"
	profileMobileView.BackgroundTransparency = 1
	profileMobileView.BorderSizePixel = 0
	profileMobileView.Position = UDim2.fromOffset(0, 0)
	profileMobileView.Size = UDim2.new(1, 0, 0, 1)
	profileMobileView.Parent = data.controls.CardGrid

	local appearance = type(player.Appearance) == "table" and player.Appearance or {}
	local profileAssetImage = data.profileAssetImage(appearance.BannerAssetId)
	local profileBanner = Instance.new("ImageLabel")
	profileBanner.Name = "ProfileBanner"
	profileBanner.Position = UDim2.fromOffset(0, 0)
	profileBanner.Size = UDim2.new(1, 0, 0, 68)
	profileBanner.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
	profileBanner.BorderSizePixel = 0
	profileBanner.Image = profileAssetImage
	profileBanner.ImageTransparency = profileAssetImage == "" and 1 or 0
	profileBanner.ScaleType = Enum.ScaleType.Crop
	profileBanner.Parent = profileMobileView
	ensureCorner(profileBanner, UDim.new(0, 10)) -- inferred equivalent call
	local shade = Instance.new("Frame")
	shade.Name = "Shade"
	shade.BackgroundColor3 = Color3.fromRGB(11, 13, 20)
	shade.BackgroundTransparency = 0.3
	shade.BorderSizePixel = 0
	shade.Size = UDim2.fromScale(1, 1)
	shade.Parent = profileBanner
	ensureCorner(shade, UDim.new(0, 10)) -- inferred equivalent call

	local profileHeader = Instance.new("Frame")
	profileHeader.Name = "ProfileHeader"
	profileHeader.Position = UDim2.fromOffset(0, 42)
	profileHeader.Size = UDim2.new(1, 0, 0, 120)
	profileHeader.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
	profileHeader.BorderSizePixel = 0
	profileHeader.Parent = profileMobileView
	ensureCorner(profileHeader, UDim.new(0, 10)) -- inferred equivalent call
	local stroke = ensureStroke(profileHeader, "HeaderStroke")
	stroke.Color = Color3.fromRGB(58, 68, 92)
	stroke.Transparency = 0.45

	local avatar = Instance.new("ImageLabel")
	avatar.Name = "Avatar"
	avatar.Position = UDim2.fromOffset(14, -18)
	avatar.Size = UDim2.fromOffset(68, 68)
	avatar.BackgroundColor3 = Color3.fromRGB(17, 21, 30)
	avatar.BorderSizePixel = 0
	avatar.Image = profileImage(player, appearance, data) -- inferred equivalent call
	avatar.ScaleType = Enum.ScaleType.Crop
	avatar.Parent = profileHeader
	ensureCorner(avatar, UDim.new(0, 18)) -- inferred equivalent call
	local stroke2 = ensureStroke(avatar, "AvatarStroke")
	stroke2.Color = data.profileStrokeColor(appearance.AvatarStrokeColor)
	stroke2.Thickness = 2
	stroke2.Transparency = 0.08

	local displayName = tostring(player.DisplayName or player.Name or "Player")
	local name = tostring(player.Name or "Player")
	profileText(profileHeader, "DisplayName", {
		Position = UDim2.fromOffset(96, 10),
		Size = UDim2.new(1, -266, 0, 24),
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(246, 248, 252),
		Text = displayName
	}, data.configureTextObject, 18, 10)
	profileText(profileHeader, "Handle", {
		Position = UDim2.fromOffset(96, 34),
		Size = UDim2.new(1, -266, 0, 17),
		Font = Enum.Font.GothamMedium,
		TextColor3 = Color3.fromRGB(30, 174, 255),
		Text = "@" .. name
	}, data.configureTextObject, 11, 7)
	local text = player.IsSelf == true and "Your community profile" or "Community creator"
	profileText(profileHeader, "Joined", {
		Position = UDim2.fromOffset(96, 52),
		Size = UDim2.new(1, -266, 0, 17),
		Font = Enum.Font.GothamMedium,
		TextColor3 = Color3.fromRGB(148, 157, 176),
		Text = text
	}, data.configureTextObject, 10, 7)

	local userId = math.floor(tonumber(player.UserId) or 0)
	local v3

	if userId > 0 then
		v3 = userId ~= data.localUserId
	else
		v3 = false
	end

	if v3 then
		profileButton(profileHeader, "SupportButton", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -58, 0, 10),
			Size = UDim2.fromOffset(118, 34),
			BackgroundColor3 = Color3.fromRGB(22, 83, 128),
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(220, 242, 255),
			Text = "Support"
		}, data.configureTextObject, 11, 7).Activated:Connect(data.openSupport)
	end

	local v4

	if userId > 0 and userId ~= data.localUserId then
		v4 = player.CanThumbProfile == true
	else
		v4 = false
	end

	if v4 then
		local thumbButton = Instance.new("ImageButton")
		thumbButton.Name = "ThumbButton"
		thumbButton.AnchorPoint = Vector2.new(1, 0)
		thumbButton.Position = UDim2.new(1, -14, 0, 10)
		thumbButton.Size = UDim2.fromOffset(36, 34)
		thumbButton.BackgroundColor3 = Color3.fromRGB(31, 52, 48)
		thumbButton.BorderSizePixel = 0
		thumbButton.Image = CommunityMobileSupport.IconAssets.Thumb
		thumbButton.ImageColor3 = Color3.fromRGB(102, 255, 191)
		thumbButton.ScaleType = Enum.ScaleType.Fit
		thumbButton.Parent = profileHeader
		ensureCorner(thumbButton, UDim.new(0, 8)) -- inferred equivalent call
		thumbButton.Activated:Connect(data.toggleThumb)
	end

	local reputation = type(player.Reputation) == "table" and player.Reputation or {}
	local v5 = {
		{
			Label = "Thumbs",
			Value = data.comma(player.ThumbsUpCount or player.ProfileThumbsUp or 0)
		},
		{
			Label = "Reputation",
			Value = data.comma(reputation.Score or 0)
		},
		{
			Label = "Sheets",
			Value = tostring(data.counts.Sheets or 0)
		},
		{
			Label = "MIDI",
			Value = tostring(data.counts.Midi or 0)
		}
	}

	local v6 = math.floor((v2 - 42) / 4)

	for i, v7 in ipairs(v5) do
		local frame = Instance.new("Frame")
		frame.Name = "Stat" .. i
		frame.Position = UDim2.fromOffset(14 + (i - 1) * (v6 + 5), 78)
		frame.Size = UDim2.fromOffset(v6, 32)
		frame.BackgroundColor3 = Color3.fromRGB(34, 39, 53)
		frame.BorderSizePixel = 0
		frame.Parent = profileHeader
		ensureCorner(frame, UDim.new(0, 8)) -- inferred equivalent call
		profileText(frame, "Value", {
			Position = UDim2.fromOffset(6, 1),
			Size = UDim2.new(1, -12, 0, 16),
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(244, 246, 252),
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = v7.Value
		}, data.configureTextObject, 12, 7)
		profileText(frame, "Label", {
			Position = UDim2.fromOffset(4, 16),
			Size = UDim2.new(1, -8, 0, 13),
			Font = Enum.Font.GothamMedium,
			TextColor3 = Color3.fromRGB(145, 154, 174),
			TextXAlignment = Enum.TextXAlignment.Center,
			Text = v7.Label
		}, data.configureTextObject, 8, 6)
	end

	local v7 = {
		{
			Id = "Sheets",
			Text = "Sheets " .. tostring(data.counts.Sheets or 0)
		},
		{
			Id = "Midi",
			Text = "MIDI " .. tostring(data.counts.Midi or 0)
		}
	}

	if player.CanViewFavorites == true then
		table.insert(v7, {
			Id = "Favorites",
			Text = "Favorites " .. tostring(data.counts.Favorites or 0)
		})
	end

	table.insert(v7, { Id = "About", Text = "About" })

	local v8 = math.floor((v2 - (#v7 - 1) * 6) / #v7)

	for i, v9 in ipairs(v7) do
		local v10 = data.selectedTab == v9.Id
		local parent = profileButton(profileMobileView, "ProfileTab" .. v9.Id, {
			Position = UDim2.fromOffset((i - 1) * (v8 + 6), 160),
			Size = UDim2.fromOffset(v8, 32),
			BackgroundColor3 = v10 and Color3.fromRGB(32, 40, 56) or Color3.fromRGB(34, 39, 53),
			Font = v10 and Enum.Font.GothamBold or Enum.Font.GothamMedium,
			TextColor3 = v10 and Color3.fromRGB(246, 248, 252) or Color3.fromRGB(154, 162, 180),
			Text = v9.Text
		}, data.configureTextObject, 10, 7)
		local stroke3 = ensureStroke(parent, "TabStroke")
		stroke3.Color = v10 and Color3.fromRGB(20, 160, 255) or Color3.fromRGB(58, 68, 92)
		stroke3.Transparency = v10 and 0.25 or 0.72
		parent.Activated:Connect(function()
			data.setProfileTab(v9.Id)
		end)
	end

	local total = 204

	if data.selectedTab == "About" then
		local aboutPanel = Instance.new("Frame")
		aboutPanel.Name = "AboutPanel"
		aboutPanel.Position = UDim2.fromOffset(0, total)
		aboutPanel.Size = UDim2.new(1, 0, 0, 96)
		aboutPanel.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
		aboutPanel.BorderSizePixel = 0
		aboutPanel.Parent = profileMobileView
		ensureCorner(aboutPanel, UDim.new(0, 10)) -- inferred equivalent call
		local stroke3 = ensureStroke(aboutPanel, "AboutStroke")
		stroke3.Color = Color3.fromRGB(58, 68, 92)
		stroke3.Transparency = 0.5
		profileText(aboutPanel, "Title", {
			Position = UDim2.fromOffset(14, 12),
			Size = UDim2.new(1, -28, 0, 20),
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(244, 246, 252),
			Text = "Biography"
		}, data.configureTextObject, 13, 8)
		profileText(aboutPanel, "Bio", {
			Position = UDim2.fromOffset(14, 38),
			Size = UDim2.new(1, -28, 0, 42),
			Font = Enum.Font.GothamMedium,
			TextColor3 = Color3.fromRGB(158, 166, 184),
			TextYAlignment = Enum.TextYAlignment.Top,
			Text = tostring(player.Bio or "") == "" and "No biography has been added yet." or tostring(player.Bio) or "No biography has been added yet."
		}, data.configureTextObject, 11, 7)
		total += 108
	else
		local entries = data.entries or {}

		if #entries == 0 then
			profileText(profileMobileView, "EmptyProfileText", {
				Position = UDim2.fromOffset(0, total + 26),
				Size = UDim2.new(1, 0, 0, 28),
				Font = Enum.Font.GothamMedium,
				TextColor3 = Color3.fromRGB(154, 162, 180),
				TextXAlignment = Enum.TextXAlignment.Center,
				Text = "No uploads found."
			}, data.configureTextObject, 12, 8)
			total += 76
		else
			for i, entry in ipairs(entries) do
				CommunityMobileSupport.CreateProfileUploadCard(data, profileMobileView, entry, total, i)
				total += 106
			end
		end
	end

	profileMobileView.Size = UDim2.new(1, 0, 0, total + 8)
	data.controls.CardGrid.CanvasSize = UDim2.fromOffset(0, total + 16)
	local v9 = math.max(0, total + 16 - data.controls.CardGrid.AbsoluteSize.Y)
	local zero = data.resetScroll and Vector2.zero or Vector2.new(0, (math.clamp(previousCanvas.Y, 0, v9)))
	data.controls.CardGrid.CanvasPosition = zero
	local v10

	if data.selectedTab == "Midi" then
		v10 = "MIDI"
	elseif data.selectedTab == "Favorites" then
		v10 = "favorites"
	elseif data.selectedTab == "About" then
		v10 = "about"
	else
		v10 = "sheets"
	end

	data.controls.CountLabel.Text = data.selectedTab == "About" and "About"
		or string.format("%s %s", data.comma(#(data.entries or {})), v10)
end

function CommunityMobileSupport.CreateProfileUploadCard(data, parent, data2, p, _)
	local upload = data2.Upload or {}
	local v2 = data2.Mode == "MIDI" and "MIDI" or "SHEET"
	local profileUploadCard = Instance.new("TextButton")
	profileUploadCard.Name = "ProfileUploadCard"
	profileUploadCard.Position = UDim2.fromOffset(0, p)
	profileUploadCard.Size = UDim2.new(1, 0, 0, 96)
	profileUploadCard.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
	profileUploadCard.BorderSizePixel = 0
	profileUploadCard.AutoButtonColor = false
	profileUploadCard.Text = ""
	profileUploadCard.ClipsDescendants = true
	profileUploadCard.Parent = parent
	ensureCorner(profileUploadCard, UDim.new(0, 10)) -- inferred equivalent call
	local stroke = ensureStroke(profileUploadCard, "CardStroke")
	stroke.Color = Color3.fromRGB(58, 68, 92)
	stroke.Transparency = 0.5
	local hero = Instance.new("ImageLabel")
	hero.Name = "Hero"
	hero.Position = UDim2.fromOffset(0, 0)
	hero.Size = UDim2.fromOffset(92, 96)
	hero.BackgroundColor3 = Color3.fromRGB(18, 21, 29)
	hero.BorderSizePixel = 0
	local profileAssetImage = data.profileAssetImage(upload.ImageAssetId or upload.ImageId)
	hero.Image = (profileAssetImage == "" or not profileAssetImage) and "rbxassetid://129219137975212"
		or profileAssetImage
	hero.ImageColor3 = v2 == "MIDI" and Color3.fromRGB(210, 201, 255) or Color3.fromRGB(255, 255, 255)
	hero.ScaleType = Enum.ScaleType.Crop
	hero.Parent = profileUploadCard
	profileText(profileUploadCard, "Title", {
		Position = UDim2.fromOffset(106, 12),
		Size = UDim2.new(1, -226, 0, 22),
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(244, 246, 251),
		Text = tostring(upload.Name or upload.Title or "Untitled Upload")
	}, data.configureTextObject, 14, 8)
	profileText(profileUploadCard, "Meta", {
		Position = UDim2.fromOffset(106, 35),
		Size = UDim2.new(1, -226, 0, 17),
		Font = Enum.Font.GothamMedium,
		TextColor3 = v2 == "MIDI" and Color3.fromRGB(196, 182, 255) or Color3.fromRGB(30, 174, 255),
		Text = v2 == "MIDI" and "Community MIDI" or "Community Sheet"
	}, data.configureTextObject, 10, 7)
	profileText(profileUploadCard, "Stats", {
		Position = UDim2.fromOffset(106, 62),
		Size = UDim2.new(1, -226, 0, 18),
		Font = Enum.Font.GothamMedium,
		TextColor3 = Color3.fromRGB(148, 157, 176),
		Text = string.format(
			"%s | %s likes | %s plays",
			data.formatUploadDate(upload.PublishedAt),
			data.comma(upload.FavoriteCount or upload.Favorites or 0),
			data.comma(upload.PlayCount or 0)
		)
	}, data.configureTextObject, 9, 7)
	local parent2 = profileText(profileUploadCard, "DifficultyBadge", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 12),
		Size = UDim2.fromOffset(92, 24),
		BackgroundColor3 = Color3.fromRGB(34, 39, 53),
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(246, 248, 252),
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = tostring(upload.Difficulty or "Medium"):upper()
	}, data.configureTextObject, 9, 6)
	parent2.BackgroundTransparency = 0
	ensureCorner(parent2, UDim.new(0, 8)) -- inferred equivalent call
	local v3 = math.floor(tonumber(data.profileData.UserId) or 0) == data.localUserId
	local v4

	if v2 == "MIDI" then
		v4 = v3 and (upload.IsPublished == false or upload.OwnerUnpublished == true or upload.OwnerHidden == true)
	else
		v4 = false
	end

	if v4 then
		profileButton(profileUploadCard, "RepublishButton", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -12, 1, -12),
			Size = UDim2.fromOffset(96, 28),
			BackgroundColor3 = Color3.fromRGB(30, 160, 255),
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Text = "Republish"
		}, data.configureTextObject, 10, 7).Activated:Connect(function()
			data.republish(upload)
		end)
	end

	profileUploadCard.Activated:Connect(function()
		if v4 then
			data.setInlineMessage("Republish this MIDI before previewing it.", true)
		elseif data2.Tab == "Favorites" then
			data.openFavorite(upload)
		else
			data.openPreview(data.buildPreviewSong(upload, v2, data.profileData))
		end
	end)
end

return CommunityMobileSupport