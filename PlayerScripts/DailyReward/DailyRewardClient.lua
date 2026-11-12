local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

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
		warn(("[DailyRewardClient] Missing %s under %s after startup wait%s"):format(
			childName,
			instance:GetFullName(),
			p and " for " .. p or ""
		))
	end

	return child2
end

local Icon = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Icon"))
local Monetization = ReplicatedStorage:WaitForChild("Monetization")
local DailyRewardConfig = require(Monetization:WaitForChild("DailyRewardConfig"))
local DailyRewardAssets = Monetization:WaitForChild("DailyRewardAssets")

local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local getDailyRewardState = remotes:WaitForChild("GetDailyRewardState")
local claimDailyReward = remotes:WaitForChild("ClaimDailyReward")
local useDailyRewardSkip = remotes:WaitForChild("UseDailyRewardSkip")
local dailyRewardUpdated = remotes:WaitForChild("DailyRewardUpdated")

local v = waitForStartupChild(LocalPlayer, "PlayerGui", "daily reward setup")

if not v then
	return
end

local parent = waitForStartupChild(v, "DailyRewardGUI", "daily reward setup")

if not parent then
	return
end

local cardsList = parent:WaitForChild("CardsList")
local progression = parent:WaitForChild("Progression")
local claimButton = parent:WaitForChild("ClaimButton")
local skipButton = parent:WaitForChild("SkipButton")
local headerLabel = parent:WaitForChild("HeaderLabel")
local timerLabel = parent:WaitForChild("TimerLabel")
local streakScoreLabel = parent:WaitForChild("StreakScoreLabel")
local streakHighscoreLabel = parent:WaitForChild("StreakHighscoreLabel")

local cycleTabs = parent:FindFirstChild("CycleTabs")

if not cycleTabs then
	cycleTabs = Instance.new("Frame")
	cycleTabs.Name = "CycleTabs"
	cycleTabs.AnchorPoint = Vector2.new(0.5, 0.5)
	cycleTabs.Position = UDim2.new(0.5, 0, 0.3, 0)
	cycleTabs.Size = UDim2.new(0.46, 0, 0.055, 0)
	cycleTabs.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
	cycleTabs.BackgroundTransparency = 0.12
	cycleTabs.BorderSizePixel = 0
	cycleTabs.ZIndex = 2
	cycleTabs.Parent = parent

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = cycleTabs

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0.015, 0)
	uiListLayout.Parent = cycleTabs
end

local DayExample = DailyRewardAssets:WaitForChild("DayExample")
local ProgressBarExample = DailyRewardAssets:WaitForChild("ProgressBarExample")
local MarkerImageExample = DailyRewardAssets:WaitForChild("MarkerImageExample")

local dailyRewardBlur = Lighting:FindFirstChild("DailyRewardBlur") or Lighting:FindFirstChild("GUI_Background_Blur")
local sfx = SoundService:FindFirstChild("SFX")
local clickSound = ReplicatedStorage:FindFirstChild("SoundFX")
	and ReplicatedStorage.SoundFX:FindFirstChild("ClickSound")
local SFX_Reward_Claimed = sfx and sfx:FindFirstChild("SFX_Reward_Claimed")
local UI_Menu_Open = sfx and sfx:FindFirstChild("UI_Menu_Open")
local UI_Menu_Close = sfx and sfx:FindFirstChild("UI_Menu_Close")

local v2 = nil
local flag = false
local v3 = false
local v4 = false
local v5 = 1
local v6 = 0
local v7 = 0
local v8 = {}

local function playSound(object) -- 5 equivalent calls inferred from this helper
	if object then
		pcall(function()
			object:Play()
		end)
	end
end

local function formatTime(p) -- 1 equivalent call inferred from this helper
	local v9 = math.max(0, (math.floor(tonumber(p) or 0)))
	local v10 = math.floor(v9 / 3600)
	local v11 = math.floor(v9 % 3600 / 60)
	local v12 = v9 % 60
	return string.format("%02d:%02d:%02d", v10, v11, v12)
end

local function formatSuffix(p, p2) -- 2 equivalent calls inferred from this helper
	return tostring(p) .. ((tonumber(p2) or 0) == 1 and "" or "s")
end

local function getReward(i) -- 1 equivalent call inferred from this helper
	if v2 and type(v2.Rewards) == "table" and v2.Rewards[i] then
		return v2.Rewards[i]
	end

	return DailyRewardConfig.GetReward(i)
end

local function getMaxDays() -- 6 equivalent calls inferred from this helper
	return (math.max(1, (math.floor(tonumber(v2 and v2.MaxDays) or DailyRewardConfig.MAX_DAYS or 7))))
end

local function getDaysPerCycle() -- 3 equivalent calls inferred from this helper
	return (math.max(1, (math.floor(tonumber(v2 and v2.DaysPerCycle) or DailyRewardConfig.DAYS_PER_CYCLE or 7))))
end

local function getCycleForDay(currentDay) -- 2 equivalent calls inferred from this helper
	return (math.max(
		1,
		(math.ceil(math.clamp(math.floor(tonumber(currentDay) or 1), 1, getMaxDays()) / getDaysPerCycle())) -- inferred equivalent call
	))
end

local function getCycleBounds(p, p2) -- 3 equivalent calls inferred from this helper
	local v9 = p2 or getMaxDays() -- inferred equivalent call
	local daysPerCycle = getDaysPerCycle() -- inferred equivalent call
	local v10 = math.max(1, (math.ceil(v9 / daysPerCycle)))
	local v11 = (math.clamp(math.floor(tonumber(p) or 1), 1, v10) - 1) * daysPerCycle + 1
	return v11, math.min(v9, v11 + daysPerCycle - 1), v10
end

local function clearGeneratedRewards()
	for _, frame in ipairs(cardsList:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end

	for _, guiObject in ipairs(progression:GetChildren()) do
		if guiObject:IsA("Frame") or guiObject:IsA("ImageLabel") then
			guiObject:Destroy()
		end
	end
end

local function buildRewardFrames(p)
	local v9 = p or getMaxDays() -- inferred equivalent call
	clearGeneratedRewards()
	local cycleBounds, v10 = getCycleBounds(v5, v9) -- inferred equivalent call
	v6 = cycleBounds
	v7 = v10

	for i = cycleBounds, v10 do
		local reward = getReward(i) -- inferred equivalent call
		local layoutOrder = i - cycleBounds + 1
		local clone = DayExample:Clone()
		clone.Name = tostring(i)
		clone.LayoutOrder = layoutOrder
		clone.Size = UDim2.new(0.128, 0, 0.75, 0)
		clone.Visible = true
		local holder = clone:FindFirstChild("Holder")
		local info = holder and holder:FindFirstChild("Info")

		if info then
			local rewardLabel = info:FindFirstChild("RewardLabel")
			local rewardImage = info:FindFirstChild("RewardImage")

			if rewardLabel then
				rewardLabel.Text = reward.Text or "+" .. tostring(reward.Notes or 0) .. " Notes"
			end

			if rewardImage then
				rewardImage.Image = reward.Image or "rbxasset://textures/ui/GuiImagePlaceholder.png"
			end

			info.Visible = true
		end

		clone.Parent = cardsList

		local clone2 = MarkerImageExample:Clone()
		clone2.Name = tostring(i) .. "_Marker"
		clone2.LayoutOrder = layoutOrder * 2 - 1
		clone2.Visible = true
		clone2.Parent = progression
		local dayLabel = clone2:FindFirstChild("DayLabel")

		if dayLabel then
			dayLabel.Text = "Day " .. tostring(i)
		end

		if not (i < v10) then
			continue
		end

		local clone3 = ProgressBarExample:Clone()
		clone3.Name = tostring(i) .. "_Progress"
		clone3.LayoutOrder = layoutOrder * 2
		clone3.Visible = true
		clone3.Parent = progression
	end
end

local function setButtonEnabled(instance, p) -- 2 equivalent calls inferred from this helper
	instance.Active = p
	instance.AutoButtonColor = p
	instance.ImageTransparency = p and 0 or 0.45
	local textLabel = instance:FindFirstChildWhichIsA("TextLabel", true)

	if textLabel then
		textLabel.TextTransparency = p and 0 or 0.35
	end
end

local function shouldShowSkipButton(): boolean -- 3 equivalent calls inferred from this helper
	return v2 ~= nil and v2.CanClaim ~= true
end

local function getClaimButtonX(): number -- 1 equivalent call inferred from this helper
	if shouldShowSkipButton() then -- inferred equivalent call
		return 0.4
	end

	return 0.5
end

local function applyButtonLayout(p, tweenInfo) -- 1 equivalent call inferred from this helper
	local udim = UDim2.new(getClaimButtonX(), 0, p, 0) -- inferred equivalent call
	local udim2 = UDim2.new(0.64, 0, p, 0)

	if tweenInfo then
		TweenService:Create(claimButton, tweenInfo, { Position = udim }):Play()

		if skipButton.Visible then
			TweenService:Create(skipButton, tweenInfo, { Position = udim2 }):Play()
		else
			skipButton.Position = udim2
		end
	else
		claimButton.Position = udim
		skipButton.Position = udim2
	end
end

local function refreshRewardFrames()
	if not v2 then
		return
	end

	local currentDay = tonumber(v2.CurrentDay) or 1
	local canClaim = v2.CanClaim == true

	for _, frame in ipairs(cardsList:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local name = tonumber(frame.Name) or 0
		local holder = frame:FindFirstChild("Holder")
		local tint = frame:FindFirstChild("Tint")
		local child = progression:FindFirstChild(frame.Name .. "_Marker")
		local child2 = progression:FindFirstChild(frame.Name .. "_Progress")
		local visible = name < currentDay
		local v9 = name == currentDay

		if holder then
			holder.Size = UDim2.new(0.8, 0, 0.8, 0)
			local uiStroke = holder:FindFirstChildOfClass("UIStroke")

			if uiStroke then
				uiStroke.Color = DailyRewardConfig.STATE_COLORS and DailyRewardConfig.STATE_COLORS.UNCLAIMED
					or Color3.fromRGB(50, 50, 50)
				uiStroke.Thickness = 4
			end

			local backShadow = holder:FindFirstChild("BackShadow")

			if backShadow then
				backShadow.Visible = false
			end
		end

		if tint then
			tint.Visible = visible
		end

		if child2 then
			child2.BackgroundColor3 = visible and Color3.fromRGB(87, 255, 78) or Color3.fromRGB(50, 50, 50)
		end

		if child then
			local color = visible and Color3.fromRGB(87, 255, 78) or Color3.fromRGB(50, 50, 50)

			if v9 then
				color = Color3.fromRGB(255, 255, 255)
			end

			child.ImageColor3 = color
			local dayLabel = child:FindFirstChild("DayLabel")

			if dayLabel then
				dayLabel.TextColor3 = color
			end
		end

		if not (v9 and holder) then
			continue
		end

		holder.Size = UDim2.new(1, 0, 1, 0)
		local uiStroke = holder:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Color = canClaim and Color3.fromRGB(87, 255, 78) or Color3.fromRGB(255, 255, 255)
			uiStroke.Thickness = 6
		end

		local backShadow = holder:FindFirstChild("BackShadow")

		if backShadow then
			backShadow.Visible = true
		end
	end
end

local function updateCycleTabs()
	local cycleForDay = getCycleForDay(v2 and v2.CurrentDay or 1) -- inferred equivalent call

	for k, v9 in pairs(v8) do
		local v10 = k == v5
		local v11 = k == cycleForDay
		local color

		if v10 then
			color = Color3.fromRGB(245, 245, 245)
		elseif v11 then
			color = Color3.fromRGB(82, 70, 26)
		else
			color = Color3.fromRGB(20, 22, 28)
		end

		v9.BackgroundColor3 = color
		local color2

		if v10 then
			color2 = Color3.fromRGB(10, 12, 16)
		elseif v11 then
			color2 = Color3.fromRGB(255, 219, 84)
		else
			color2 = Color3.fromRGB(210, 214, 224)
		end

		v9.TextColor3 = color2
		local uiStroke = v9:FindFirstChildOfClass("UIStroke")

		if not uiStroke then
			continue
		end

		local color3

		if v10 then
			color3 = Color3.fromRGB(255, 255, 255)
		elseif v11 then
			color3 = Color3.fromRGB(255, 219, 84)
		else
			color3 = Color3.fromRGB(58, 62, 72)
		end

		uiStroke.Color = color3
		uiStroke.Transparency = v10 and 0 or 0.25
	end
end

local function refreshLabels()
	if not v2 then
		return
	end

	local currentStreak = tonumber(v2.CurrentStreak) or 0
	local longestStreak = tonumber(v2.LongestStreak) or 0
	streakScoreLabel.Text = currentStreak > 0
		and "Current Streak: " .. currentStreak .. " " .. formatSuffix("Day", currentStreak) -- inferred equivalent call
		or ""
	streakHighscoreLabel.Text = longestStreak > 0
		and "Longest Streak: " .. longestStreak .. " " .. formatSuffix("Day", longestStreak) -- inferred equivalent call
		or ""
	setButtonEnabled(claimButton, v2.CanClaim == true) -- inferred equivalent call
	local textLabel = claimButton:FindFirstChildWhichIsA("TextLabel", true)

	if textLabel then
		textLabel.Text = v2.CanClaim and "CLAIM" or "LOCKED"
	end

	local skipProductId = tonumber(v2.SkipProductId) or 0
	local skipCredits = tonumber(v2.SkipCredits) or 0
	local v9

	if v2.CanClaim == true then
		v9 = false
	else
		v9 = skipCredits > 0 or skipProductId > 0
	end

	skipButton.Visible = shouldShowSkipButton() -- inferred equivalent call
	setButtonEnabled(skipButton, v9) -- inferred equivalent call
	applyButtonLayout(
		claimButton.Position.Y.Scale,
		flag and parent.Enabled and TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or nil
	)
	local textLabel2 = skipButton:FindFirstChildWhichIsA("TextLabel", true)

	if textLabel2 then
		if skipCredits > 0 then
			textLabel2.Text = "USE SKIP"
		elseif skipProductId > 0 then
			textLabel2.Text = "SKIP"
		else
			textLabel2.Text = "SKIP SOON"
		end
	end

	updateCycleTabs()
end

local function buildCycleTabs(maxDays)
	local v9 = maxDays or getMaxDays() -- inferred equivalent call

	for _, button in ipairs(cycleTabs:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end

	table.clear(v8)

	local v10 = v5
	local v11 = v9 or getMaxDays() -- inferred equivalent call
	local daysPerCycle = getDaysPerCycle() -- inferred equivalent call
	local v12 = math.max(1, (math.ceil(v11 / daysPerCycle)))
	math.min(v11, (math.clamp(math.floor(tonumber(v10) or 1), 1, v12) - 1) * daysPerCycle + 1 + daysPerCycle - 1)

	cycleTabs.Visible = v12 > 1

	for i = 1, v12 do
		local cycleBounds, v13 = getCycleBounds(i, v9) -- inferred equivalent call
		local textButton = Instance.new("TextButton")
		textButton.Name = "Cycle" .. tostring(i)
		textButton.LayoutOrder = i
		textButton.Size = UDim2.new(0.23, 0, 0.78, 0)
		textButton.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
		textButton.BorderSizePixel = 0
		textButton.AutoButtonColor = true
		textButton.FontFace = Font.fromId(16658221428, Enum.FontWeight.SemiBold)
		textButton.Text = tostring(cycleBounds) .. "-" .. tostring(v13)
		textButton.TextScaled = true
		textButton.TextColor3 = Color3.fromRGB(210, 214, 224)
		textButton.ZIndex = 3
		textButton.Parent = cycleTabs

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 7)
		uiCorner.Parent = textButton

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Thickness = 1.5
		uiStroke.Transparency = 0.25
		uiStroke.Color = Color3.fromRGB(58, 62, 72)
		uiStroke.Parent = textButton

		v8[i] = textButton
		textButton.Activated:Connect(function()
			v5 = i
			buildRewardFrames(v9)
			refreshRewardFrames()
			refreshLabels()
		end)
	end

	updateCycleTabs()
end

local function refreshAll(p)
	if p then
		v2 = p
		v5 = getCycleForDay(v2.CurrentDay) -- inferred equivalent call
	end

	if not v2 then
		return
	end

	local maxDays = getMaxDays() -- inferred equivalent call
	local cycleBounds, v9 = getCycleBounds(v5, maxDays) -- inferred equivalent call
	buildCycleTabs(maxDays)

	if v6 ~= cycleBounds or v7 ~= v9 or #cardsList:GetChildren() <= 2 then
		buildRewardFrames(maxDays)
	end

	refreshRewardFrames()
	refreshLabels()
end

local function updateTimer() -- 3 equivalent calls inferred from this helper
	if not v2 then
		return
	end

	if v2.CanClaim then
		timerLabel.Text = "Ready to claim"
		return
	end

	timerLabel.Text = "Next reward in: " .. formatTime(math.max(0, (tonumber(v2.NextClaimTime) or 0) - os.time())) -- inferred equivalent call
end

local function openPanel()
	if flag then
		return
	end

	flag = true
	playSound(UI_Menu_Open or clickSound) -- inferred equivalent call
	headerLabel.Position = UDim2.new(0.5, 0, 1.5, 0)
	cycleTabs.Position = UDim2.new(0.5, 0, 1.5, 0)
	cardsList.Position = UDim2.new(0.5, 0, 1.5, 0)
	progression.Position = UDim2.new(0.5, 0, 1.5, 0)
	skipButton.Visible = shouldShowSkipButton() -- inferred equivalent call
	applyButtonLayout(1.5) -- inferred equivalent call
	parent.Enabled = true

	if dailyRewardBlur then
		dailyRewardBlur.Enabled = true
	end

	TweenService:Create(headerLabel, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.15, 0)
	}):Play()
	task.wait(0.0675)
	TweenService:Create(cycleTabs, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.285, 0)
	}):Play()
	task.wait(0.054)
	TweenService:Create(cardsList, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.43, 0)
	}):Play()
	task.wait(0.054)
	TweenService:Create(progression, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.65, 0)
	}):Play()
	task.wait(0.09000000000000001)
	applyButtonLayout(0.85, TweenInfo.new(0.3375, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
end

local function closePanel()
	if not (flag or parent.Enabled) then
		return
	end

	flag = false
	playSound(UI_Menu_Close or clickSound) -- inferred equivalent call
	applyButtonLayout(1.5, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
	task.wait(0.08)
	TweenService:Create(progression, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	}):Play()
	TweenService:Create(cardsList, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	}):Play()
	TweenService:Create(cycleTabs, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	}):Play()
	TweenService:Create(headerLabel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	}):Play()
	task.wait(0.24)

	if not flag then
		parent.Enabled = false

		if dailyRewardBlur then
			dailyRewardBlur.Enabled = false
		end
	end
end

local TOPBAR_LABEL = DailyRewardConfig.TOPBAR_LABEL or "Login Rewards"
local v9 = Icon.new():setName("LoginRewardsTopbar"):setCaption(TOPBAR_LABEL):setImageScale(1):align("Right"):setOrder(1)

if (DailyRewardConfig.TOPBAR_ICON_IMAGE_ID or 0) ~= 0 then
	v9:setImage(DailyRewardConfig.TOPBAR_ICON_IMAGE_ID)
end

v9.selected:Connect(function()
	v9:setLabel(TOPBAR_LABEL)
	openPanel()
end)
v9.deselected:Connect(function()
	v9:setLabel("")
	closePanel()
end)

claimButton.MouseButton1Click:Connect(function()
	if v3 or not v2 or v2.CanClaim ~= true then
		return
	end

	v3 = true
	playSound(clickSound) -- inferred equivalent call
	local success, result, v10, v11 = pcall(function()
		return claimDailyReward:InvokeServer()
	end)

	if success and result then
		if v11 and v11.ClaimedReward then
			timerLabel.Text = "Claimed " .. tostring(v11.ClaimedReward.Text or "reward")
		end

		playSound(SFX_Reward_Claimed) -- inferred equivalent call
		refreshAll(v11)
		task.delay(0.55, function()
			if v9.deselect then
				v9:deselect()
			else
				closePanel()
			end
		end)
	elseif success and v11 then
		refreshAll(v11)
		timerLabel.Text = tostring(v10 or "Reward is not ready")
	else
		timerLabel.Text = "Reward claim failed"
	end

	v3 = false
end)

skipButton.MouseButton1Click:Connect(function()
	if v3 or not v2 or v2.CanClaim == true then
		return
	end

	v3 = true
	playSound(clickSound) -- inferred equivalent call

	if (tonumber(v2.SkipCredits) or 0) > 0 then
		local success, result, v10, v11 = pcall(function()
			return useDailyRewardSkip:InvokeServer()
		end)

		if success and v11 then
			refreshAll(v11)
		end

		if success and result then
			timerLabel.Text = "Reward unlocked"
		else
			timerLabel.Text = tostring(v10 or "Skip unavailable")
		end
	else
		local skipProductId = tonumber(v2.SkipProductId) or 0

		if skipProductId > 0 then
			MarketplaceService:PromptProductPurchase(LocalPlayer, skipProductId)
		else
			timerLabel.Text = "Skip product not configured"
		end
	end

	v3 = false
end)

local function pointInside(guiObject, vector2): boolean
	if not (guiObject and guiObject:IsA("GuiObject") and guiObject.Visible) then
		return false
	end

	local absolutePosition = guiObject.AbsolutePosition
	local absoluteSize = guiObject.AbsoluteSize
	return vector2.X >= absolutePosition.X
		and vector2.X <= absolutePosition.X + absoluteSize.X
		and vector2.Y >= absolutePosition.Y
		and vector2.Y <= absolutePosition.Y + absoluteSize.Y
end

local function closeFromOutsideInput() -- 2 equivalent calls inferred from this helper
	if v9.deselect then
		v9:deselect()
	else
		closePanel()
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not (flag and parent.Enabled) then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local position = input.Position and input.Position or UserInputService:GetMouseLocation()
		local vector2 = Vector2.new(position.X, position.Y)

		if not (pointInside(headerLabel, vector2) or pointInside(cycleTabs, vector2) or pointInside(cardsList, vector2) or pointInside(progression, vector2) or pointInside(claimButton, vector2) or pointInside(skipButton, vector2)) then
			closeFromOutsideInput() -- inferred equivalent call
		end
	end

	if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
		closeFromOutsideInput() -- inferred equivalent call
	end
end)

dailyRewardUpdated.OnClientEvent:Connect(function(p)
	refreshAll(p)
	updateTimer() -- inferred equivalent call
end)

task.spawn(function()
	local v10 = nil

	for _ = 1, 20 do
		local success, result = pcall(function()
			return getDailyRewardState:InvokeServer()
		end)

		if success and result then
			v10 = result
			break
		end

		timerLabel.Text = "Loading rewards..."
		task.wait(0.5)
	end

	if v10 then
		buildRewardFrames(tonumber(v10.MaxDays) or DailyRewardConfig.MAX_DAYS)
		refreshAll(v10)
		updateTimer() -- inferred equivalent call

		if v10.CanClaim and not v4 then
			v4 = true
			task.delay(1, function()
				if v9.select then
					v9:select()
				else
					openPanel()
				end
			end)
		end
	else
		timerLabel.Text = "Daily rewards unavailable"
	end
end)

task.spawn(function()
	while true do
		updateTimer() -- inferred equivalent call
		task.wait(1)
	end
end)