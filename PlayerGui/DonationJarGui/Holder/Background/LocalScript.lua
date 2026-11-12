local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local parent = script.Parent
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")
local Debris = game:GetService("Debris")

local template = ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("Template")
local Events = ReplicatedStorage2:WaitForChild("Events")
local CanPurchasePass = Events:WaitForChild("CanPurchasePass")
local beginDonationPurchase = Workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes"):WaitForChild("BeginDonationPurchase")

local screenGui = parent:FindFirstAncestorWhichIsA("ScreenGui")
local ownerId = screenGui and screenGui:GetAttribute("OwnerId") or 0

local v = UserInputService.TouchEnabled

if v then
	local keyboardEnabled = UserInputService.KeyboardEnabled or UserInputService.MouseEnabled
	v = not keyboardEnabled
end

local v2 = not v

local v3 = false
local count = 0
local v4 = 0

local count2 = 0
local tweens = {}

local v5 = {}
local v6 = {}

local function registerTile(p: number, clone, price: number, count3: number)
	v5[p] = v5[p] or {}
	table.insert(v5[p], { tile = clone, price = price, seq = count3 })
end

local function finalizeOrder(p: number)
	local v7 = v5[p]

	if not v7 or #v7 == 0 then
		return
	end

	table.sort(v7, function(a, b): boolean
		if a.price == b.price then
			return a.seq < b.seq
		end

		return a.price < b.price
	end)

	for i, v8 in ipairs(v7) do
		if v8.tile and v8.tile.Parent then
			v8.tile.LayoutOrder = i
		end
	end
end

local function scheduleReindex(p: number, value: number) -- 1 equivalent call inferred from this helper
	if v6[p] then
		return
	end

	v6[p] = true
	task.delay(value or 0.1, function()
		v6[p] = nil
		finalizeOrder(p)
	end)
end

local function comma(p: number)
	local v7 = tostring((math.floor((tonumber(p) or 0) + 0.5)))

	repeat
		local v8
		v7, v8 = v7:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v8 == 0

	return v7
end

local function getSound(childName: string) -- 3 equivalent calls inferred from this helper
	local sound = parent:FindFirstChild(childName)

	if not (sound and sound:IsA("Sound") and sound) then
		sound = nil
	end

	return sound
end

local function playCloned(instance) -- 4 equivalent calls inferred from this helper
	if not instance then
		return
	end

	local clone = instance:Clone()
	clone.Parent = instance.Parent
	clone:Play()
	Debris:AddItem(clone, (clone.TimeLength or 0) + 0.1)
end

local function playTick() -- 1 equivalent call inferred from this helper
	if v then
		return
	end

	playCloned(getSound("Tick")) -- inferred equivalent call
end

local function playClick()
	playCloned(getSound("Click")) -- inferred equivalent call
end

local function playErrorSound()
	local soundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
	local err = soundFX and soundFX:FindFirstChild("Error")

	if not (err and err:IsA("Sound")) then
		return
	end

	local donationErrorSound = err:Clone()
	donationErrorSound.Name = "DonationErrorSound"
	donationErrorSound.Parent = SoundService
	donationErrorSound.TimePosition = 0
	donationErrorSound:Play()
	Debris:AddItem(donationErrorSound, (math.max(3, donationErrorSound.TimeLength + 1)))
end

local function tween(instance, tweenInfo, goal) -- 4 equivalent calls inferred from this helper
	local tween2 = TweenService:Create(instance, tweenInfo, goal)
	table.insert(tweens, tween2)
	return tween2
end

local function cancelTweens()
	for i = #tweens, 1, -1 do
		local v7 = tweens[i]
		pcall(function()
			v7:Cancel()
		end)
		table.remove(tweens, i)
	end
end

local function findSlotRoot(instance)
	while instance and instance ~= parent do
		if instance:GetAttribute("AssetId") ~= nil then
			return instance
		end

		instance = instance.Parent
	end

	return nil
end

local function ensureToast()
	local screenGui2 = parent:FindFirstAncestorWhichIsA("ScreenGui")

	if not screenGui2 then
		return nil
	end

	local jarToast = screenGui2:FindFirstChild("JarToast")

	if jarToast then
		return jarToast
	end

	local jarToast2 = Instance.new("Frame")
	jarToast2.Name = "JarToast"
	jarToast2.AnchorPoint = Vector2.new(0.5, 1)
	jarToast2.Position = UDim2.new(0.5, 0, 1, -90)
	jarToast2.Size = UDim2.new(0, 760, 0, 48)
	jarToast2.BackgroundColor3 = Color3.fromRGB(98, 145, 255)
	jarToast2.Visible = false
	jarToast2.ZIndex = 1000
	jarToast2.Parent = screenGui2

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 24)
	uiCorner.Parent = jarToast2

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 18)
	uiPadding.PaddingRight = UDim.new(0, 18)
	uiPadding.Parent = jarToast2

	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.BackgroundTransparency = 1
	text.Size = UDim2.new(1, 0, 1, 0)
	text.Font = Enum.Font.GothamBold
	text.TextSize = 20
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Text = ""
	text.Parent = jarToast2

	return jarToast2
end

local function showToast(text, value) -- 2 equivalent calls inferred from this helper
	local toast = ensureToast()

	if not toast then
		return
	end

	toast.Text.Text = text
	toast.Visible = true
	toast.BackgroundTransparency = 0
	toast.Text.TextTransparency = 0
	task.delay(value or 2.5, function()
		if toast.Visible then
			for i = 1, 10 do
				task.wait(0.04)
				toast.BackgroundTransparency = i * 0.08
				toast.Text.TextTransparency = i * 0.08
			end

			toast.Visible = false
			toast.BackgroundTransparency = 0
			toast.Text.TextTransparency = 0
		end
	end)
end

local toolTip = parent.Parent and parent.Parent:FindFirstChild("ToolTip") or parent:FindFirstChild("ToolTip")
local renderSteppedConnection = nil

if toolTip then
	local screenGui2 = toolTip:FindFirstAncestorWhichIsA("ScreenGui")

	if screenGui2 and toolTip.Parent ~= screenGui2 then
		toolTip.Parent = screenGui2
	end

	toolTip.AnchorPoint = Vector2.new(0, 0)
	toolTip.ZIndex = 1000
	toolTip.Active = false
	toolTip.Visible = false

	for _, guiObject in ipairs(toolTip:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.Active = false
		end
	end

	if not v2 then
		toolTip.Visible = false
	end
end

local function positionTooltip() -- 1 equivalent call inferred from this helper
	if v2 and toolTip then
		local mouseLocation = UserInputService:GetMouseLocation()
		toolTip.Position = UDim2.new(0, mouseLocation.X + 20, 0, mouseLocation.Y + 20)
	end
end

local function showTooltip(parent2)
	if not (v2 and toolTip) then
		return
	end

	local assetId = parent2:GetAttribute("AssetId")
	local kind = parent2:GetAttribute("Type") or "Clothing"
	local priceNum = tonumber(parent2:GetAttribute("PriceNum"))

	if not assetId then
		return
	end

	local success, productInfo

	if kind == "Gamepass" then
		success, productInfo = pcall(
			MarketplaceService.GetProductInfo,
			MarketplaceService,
			assetId,
			Enum.InfoType.GamePass
		)
	else
		success, productInfo = pcall(
			MarketplaceService.GetProductInfo,
			MarketplaceService,
			assetId,
			Enum.InfoType.Asset
		)
	end

	if not (success and productInfo) then
		return
	end

	local image = kind == "Gamepass" and "rbxassetid://" .. (productInfo.IconImageAssetId or 0)
		or string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", assetId)

	local title = toolTip:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Text = productInfo.Name
	end

	local icon = toolTip:FindFirstChild("Icon")

	if icon and icon:IsA("ImageLabel") then
		icon.Image = image
	end

	local price = toolTip:FindFirstChild("Price")

	if price and price:IsA("TextLabel") then
		price.Text = "" .. comma(priceNum or 0)
	end

	local kind2 = toolTip:FindFirstChild("Type")

	if kind2 and kind2:IsA("TextLabel") then
		kind2.Text = kind == "Gamepass" and "GamePass" or "Clothing"
	end

	toolTip.Visible = true
	positionTooltip() -- inferred equivalent call

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(positionTooltip)
end

local function hideTooltip() -- 7 equivalent calls inferred from this helper
	if not toolTip then
		return
	end

	toolTip.Visible = false

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local username = parent:FindFirstChild("Username")
local function updateOwnerHeaderName(p: number)
	if not (username and username:IsA("TextLabel")) then
		return
	end

	if not p or p == 0 then
		username.Text = ""
		return
	end

	local v7 = nil
	local v8 = nil
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId then
		v7 = playerByUserId.DisplayName
		v8 = playerByUserId.Name
	else
		local success, result = pcall(function()
			local userInfosByUserIdsAsync = UserService:GetUserInfosByUserIdsAsync({ p })
			return userInfosByUserIdsAsync and userInfosByUserIdsAsync[1] or nil
		end)

		if success and result then
			v7 = result.DisplayName or result.Username
			v8 = result.Username
		else
			local success2, nameFromUserIdAsync = pcall(Players.GetNameFromUserIdAsync, Players, p)

			if success2 and nameFromUserIdAsync then
				v7 = nameFromUserIdAsync
				v8 = v7
			end
		end
	end

	if v8 then
		username.Text = string.format("%s (@%s)", v7 or v8, v8)
	else
		username.Text = "Unknown User"
	end
end

local tweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })

local function getHoverScale(parent2)
	local v7 = object2[parent2]

	if v7 and v7.Parent == parent2 then
		return v7
	end

	local selected = parent2:FindFirstChildOfClass("UIScale")

	if not selected then
		selected = Instance.new("UIScale")
		selected.Scale = 1
		selected.Parent = parent2
	end

	object2[parent2] = selected
	return selected
end

local function cancelHoverTween(parent2) -- 2 equivalent calls inferred from this helper
	local v7 = object[parent2]

	if v7 then
		pcall(function()
			v7:Cancel()
		end)
	end

	object[parent2] = nil
end

local function applyHoverEffect(flag: boolean, instance)
	if v or (not instance or instance.Name == "Close") then
		return
	end

	local parent2 = instance.Parent

	if not (parent2 and parent2:IsA("GuiObject")) then
		return
	end

	local v7 = object2[parent2]

	if not v7 or v7.Parent ~= parent2 then
		v7 = parent2:FindFirstChildOfClass("UIScale")

		if not v7 then
			v7 = Instance.new("UIScale")
			v7.Scale = 1
			v7.Parent = parent2
		end

		object2[parent2] = v7
	end

	cancelHoverTween(parent2) -- inferred equivalent call
	local color = Color3.fromRGB(98, 145, 255)
	local color2 = Color3.fromRGB(92, 255, 67)

	if flag then
		local tween2 = TweenService:Create(v7, tweenInfo, { Scale = 1.08 })
		object[parent2] = tween2
		tween2:Play()

		local textLabel = parent2:FindFirstChild("TextLabel")

		if textLabel and textLabel:IsA("GuiObject") then
			TweenService:Create(textLabel, tweenInfo, { BackgroundColor3 = color }):Play()
		end

		local uiStroke = instance:FindFirstChildOfClass("UIStroke") or parent2:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			TweenService:Create(uiStroke, tweenInfo, { Color = color }):Play()
		end

		playTick() -- inferred equivalent call
	else
		local tween2 = TweenService:Create(v7, tweenInfo2, { Scale = 1 })
		object[parent2] = tween2
		tween2:Play()

		local textLabel = parent2:FindFirstChild("TextLabel")

		if textLabel and textLabel:IsA("GuiObject") then
			TweenService:Create(textLabel, tweenInfo2, { BackgroundColor3 = color2 }):Play()
		end

		local uiStroke = instance:FindFirstChildOfClass("UIStroke") or parent2:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			TweenService:Create(uiStroke, tweenInfo2, { Color = color2 }):Play()
		end
	end

	if parent2:IsDescendantOf(parent) then
		parent2.AncestryChanged:Once(function()
			local v8 = object2[parent2]

			if v8 then
				v8.Scale = 1
			end

			cancelHoverTween(parent2) -- inferred equivalent call
		end)
	end
end

local function attachHover(instance)
	if v or instance.Name == "Close" then
		return
	end

	instance.MouseEnter:Connect(function()
		applyHoverEffect(true, instance)

		if v2 then
			showTooltip(instance.Parent)
		end
	end)
	instance.MouseLeave:Connect(function()
		applyHoverEffect(false, instance)
		hideTooltip() -- inferred equivalent call
	end)

	if instance.SelectionGained then
		instance.SelectionGained:Connect(function()
			applyHoverEffect(true, instance)

			if v2 then
				showTooltip(instance.Parent)
			end
		end)
	end

	if instance.SelectionLost then
		instance.SelectionLost:Connect(function()
			applyHoverEffect(false, instance)
			hideTooltip() -- inferred equivalent call
		end)
	end

	local parent2 = instance.Parent

	if parent2 and parent2:IsA("GuiObject") then
		local v7 = object2[parent2]

		if not v7 or v7.Parent ~= parent2 then
			v7 = parent2:FindFirstChildOfClass("UIScale")

			if not v7 then
				v7 = Instance.new("UIScale")
				v7.Scale = 1
				v7.Parent = parent2
			end

			object2[parent2] = v7
		end

		v7.Scale = 1
	end

	applyHoverEffect(false, instance)
end

local function resolveMain()
	local canvasGroup = parent:FindFirstChild("CanvasGroup")

	if canvasGroup and canvasGroup:FindFirstChild("Main") then
		return canvasGroup.Main
	end

	local parentMain = parent:FindFirstChild("Main") or parent:WaitForChild("Main", 5)

	if parentMain then
		return parentMain:FindFirstChild("Main") or parentMain
	end

	return nil
end

local main = resolveMain()

if not main then
	ClientDebugConfig.Warn("[Jar UI] couldn't resolve list container (Main).")
	return
end

local function ensureLayout()
	local v7 = main:FindFirstChildOfClass("UIListLayout") or main:FindFirstChildOfClass("UIGridLayout")

	if not v7 then
		v7 = Instance.new("UIListLayout")
		v7.Padding = UDim.new(0, 6)
		v7.Parent = main
	end

	v7.SortOrder = Enum.SortOrder.LayoutOrder

	if main:IsA("ScrollingFrame") then
		main.CanvasSize = UDim2.new()
		main.ScrollBarThickness = 6
	end
end
ensureLayout()

local function ensureEmptyState()
	local emptyState = main:FindFirstChild("EmptyState")

	if emptyState and emptyState:IsA("Frame") then
		return emptyState
	end

	local emptyState2 = Instance.new("Frame")
	emptyState2.Name = "EmptyState"
	emptyState2.BackgroundTransparency = 1
	emptyState2.Size = UDim2.new(1, 0, 0, 120)
	emptyState2.Visible = false
	emptyState2.LayoutOrder = 1e999
	emptyState2.Parent = main

	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.BackgroundTransparency = 1
	message.TextWrapped = true
	message.Font = Enum.Font.Gotham
	message.TextSize = 18
	message.TextColor3 = Color3.fromRGB(200, 200, 200)
	message.Text = "No items to show."
	message.Size = UDim2.new(1, -24, 1, 0)
	message.Position = UDim2.new(0, 12, 0, 0)
	message.Parent = emptyState2

	return emptyState2
end

local function showEmptyState(value: string?) -- 2 equivalent calls inferred from this helper
	local emptyState = ensureEmptyState()
	local message = emptyState:FindFirstChild("Message")

	if message and message:IsA("TextLabel") then
		message.Text = value or "No items to show."
	end

	emptyState.Visible = true
end

local function hideEmptyState() -- 5 equivalent calls inferred from this helper
	local emptyState = main:FindFirstChild("EmptyState")

	if emptyState and emptyState:IsA("Frame") then
		emptyState.Visible = false
	end
end

local function containerHasTiles(instance): boolean
	for _, child in ipairs(instance:GetChildren()) do
		if
			child:IsA("GuiObject")
			and not child:IsA("UIListLayout")
			and not child:IsA("UIGridLayout")
			and child.Name ~= "EmptyState"
		then
			return true
		end
	end

	return false
end

local function ensureUIScale(parent2) -- 1 equivalent call inferred from this helper
	local v7 = parent2:FindFirstChildOfClass("UIScale")

	if not v7 then
		v7 = Instance.new("UIScale")
		v7.Scale = 1
		v7.Parent = parent2
	end

	return v7
end

local function ensureCanvasGroup(parent2) -- 1 equivalent call inferred from this helper
	local canvasGroup = parent2:FindFirstChildOfClass("CanvasGroup")

	if canvasGroup then
		return canvasGroup
	end

	canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Name = "CanvasGroup"
	canvasGroup.GroupTransparency = 0
	canvasGroup.Parent = parent2

	return canvasGroup
end

local uiScale = ensureUIScale(parent) -- inferred equivalent call
local canvasGroup = ensureCanvasGroup(parent) -- inferred equivalent call

local function animateIn()
	count2 += 1
	local v7 = count2
	cancelTweens()

	parent.Visible = false
	uiScale.Scale = 0.9
	canvasGroup.GroupTransparency = 1

	RunService.Heartbeat:Wait()

	if v7 ~= count2 then
		return
	end

	parent.Visible = true

	local tweenInfo3 = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo4 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local tween2 = tween(uiScale, tweenInfo3, { Scale = 1 }) -- inferred equivalent call
	local tween3 = tween(canvasGroup, tweenInfo4, { GroupTransparency = 0 }) -- inferred equivalent call
	tween2:Play()
	tween3:Play()
end

local function animateOut(fn)
	count2 += 1

	cancelTweens()

	local tweenInfo3 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tweenInfo4 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	local count3 = 0
	local function stepDone()
		count3 += 1

		if count3 >= 2 and fn then
			fn()
		end
	end

	local tween2 = tween(uiScale, tweenInfo3, { Scale = 0.96 }) -- inferred equivalent call
	local tween3 = tween(canvasGroup, tweenInfo4, { GroupTransparency = 1 }) -- inferred equivalent call

	tween2.Completed:Connect(stepDone)
	tween3.Completed:Connect(stepDone)
	tween2:Play()
	tween3:Play()
end

local canvasPositions = {}
local count3 = 0

local function saveScroll(p: number) -- 3 equivalent calls inferred from this helper
	if main and main:IsA("ScrollingFrame") and p and p ~= 0 then
		canvasPositions[p] = main.CanvasPosition
	end
end

local function clampCanvasPos(main2, vector2: Vector2) -- 4 equivalent calls inferred from this helper
	local v7 = math.max(0, main2.AbsoluteCanvasSize.X - main2.AbsoluteSize.X)
	local v8 = math.max(0, main2.AbsoluteCanvasSize.Y - main2.AbsoluteSize.Y)
	return Vector2.new(math.clamp(vector2.X, 0, v7), (math.clamp(vector2.Y, 0, v8)))
end

local function restoreScroll(p: number)
	if not (main and main:IsA("ScrollingFrame")) then
		return
	end

	local v7 = canvasPositions[p]

	if not v7 then
		return
	end

	count3 += 1
	local v8 = count3

	task.spawn(function()
		for _ = 1, 12 do
			if v8 ~= count3 then
				break
			end

			RunService.Heartbeat:Wait()
			main.CanvasPosition = clampCanvasPos(main, v7) -- inferred equivalent call
		end
	end)
end

local pools = parent:FindFirstChild("Pools")

if not pools then
	pools = Instance.new("Folder")
	pools.Name = "Pools"
	pools.Parent = parent
end

local function getPool(p: number) -- 3 equivalent calls inferred from this helper
	local name = tostring(p)
	local v7 = pools:FindFirstChild(name)

	if not v7 then
		v7 = Instance.new("Folder")
		v7.Name = name
		v7.Parent = pools
	end

	return v7
end

local function parkCurrentIntoPool(p: number)
	saveScroll(p) -- inferred equivalent call
	local pool = getPool(p) -- inferred equivalent call

	for _, child in ipairs(main:GetChildren()) do
		if
			not child:IsA("GuiObject")
			or (child:IsA("UIListLayout") or child:IsA("UIGridLayout"))
			or child.Name == "EmptyState"
		then
			continue
		end

		child.Parent = pool
	end
end

local function mountPool(p: number)
	ensureLayout()
	local pool = getPool(p) -- inferred equivalent call

	for _, guiObject in ipairs(pool:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject.Parent = main
		end
	end

	v4 = p
	local flag = false

	for _, child in ipairs(main:GetChildren()) do
		if
			child:IsA("GuiObject")
			and not child:IsA("UIListLayout")
			and not child:IsA("UIGridLayout")
			and child.Name ~= "EmptyState"
		then
			flag = true
			break
		end
	end

	if flag then
		hideEmptyState() -- inferred equivalent call
	else
		showEmptyState() -- inferred equivalent call
	end

	if main then
		if not main:IsA("ScrollingFrame") then
			return
		end

		local v7 = canvasPositions[p]

		if not v7 then
			return
		end

		count3 += 1
		local v8 = count3

		task.spawn(function()
			for _ = 1, 12 do
				if v8 ~= count3 then
					break
				end

				RunService.Heartbeat:Wait()
				main.CanvasPosition = clampCanvasPos(main, v7) -- inferred equivalent call
			end
		end)
	end
end

local function setSlot(clone, assetId: number, p: string, priceNum: number?)
	clone:SetAttribute("AssetId", assetId)
	clone:SetAttribute("Type", p)

	local button = clone:FindFirstChild("Button")
	local guiObject

	if button then
		guiObject = button:FindFirstChild("TextLabel") or button:FindFirstChild("Price")

		if not (guiObject and (guiObject:IsA("TextButton") or guiObject:IsA("TextLabel"))) then
			for _, guiObject2 in ipairs(button:GetDescendants()) do
				if guiObject2:IsA("TextButton") or guiObject2:IsA("TextLabel") then
					guiObject = guiObject2
					break
				end
			end
		end
	end

	if not guiObject then
		local textLabel = clone:FindFirstChild("TextLabel") or clone:FindFirstChild("Price")

		if textLabel and (textLabel:IsA("TextButton") or textLabel:IsA("TextLabel")) then
			guiObject = textLabel
		else
			for _, guiObject2 in ipairs(clone:GetChildren()) do
				if guiObject2:IsA("TextButton") or guiObject2:IsA("TextLabel") then
					guiObject = guiObject2
					break
				end
			end
		end
	end

	if not guiObject then
		return
	end

	local v7 = nil
	local gamePass = p == "Gamepass" and Enum.InfoType.GamePass or Enum.InfoType.Asset

	local success, result = pcall(function()
		if MarketplaceService.GetProductInfoAsync then
			return MarketplaceService:GetProductInfoAsync(assetId, gamePass)
		end

		return MarketplaceService:GetProductInfo(assetId, gamePass)
	end)
	local name

	if success and result then
		name = result.Name
		priceNum = tonumber(result.PriceInRobux) or priceNum

		if p == "Gamepass" then
			if result.IconImageAssetId then
				v7 = "rbxassetid://" .. result.IconImageAssetId
			end
		else
			v7 = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", assetId)
		end
	end

	guiObject.Text = priceNum and priceNum > 0 and "" .. comma(priceNum) or "—"

	if guiObject.TextTransparency ~= nil then
		guiObject.TextTransparency = 0
	end

	guiObject.Visible = true
	guiObject:SetAttribute("IsPrice", true)

	if priceNum then
		clone:SetAttribute("PriceNum", priceNum)
	end

	if name then
		clone:SetAttribute("AssetName", name)
	end

	if v7 then
		clone:SetAttribute("AssetIcon", v7)
	end
end

local function promptFor(slotRoot)
	local assetId = slotRoot:GetAttribute("AssetId")

	if not assetId then
		return
	end

	local kind = slotRoot:GetAttribute("Type") or "Clothing"
	local priceNum = tonumber(slotRoot:GetAttribute("PriceNum")) or 0

	if priceNum <= 0 then
		return
	end

	if kind == "Gamepass" then
		local success, result, v7 = pcall(function()
			return CanPurchasePass:InvokeServer(assetId)
		end)

		if not (success and result) then
			if v7 == "regional" then
				showToast("regional pricing is not supported, ask the owner to disable regional pricing", 5) -- inferred equivalent call
			end

			return
		end
	end

	local success, result, v7 = pcall(function()
		return beginDonationPurchase:InvokeServer(ownerId, assetId, kind, priceNum)
	end)

	if success and result then
		local price

		if type(v7) == "table" then
			price = tonumber(v7.Price) or nil
		end

		if price and price > 0 then
			slotRoot:SetAttribute("PriceNum", price)
		end

		if kind == "Gamepass" then
			pcall(function()
				MarketplaceService:PromptGamePassPurchase(LocalPlayer, assetId)
			end)
		else
			pcall(function()
				MarketplaceService:PromptPurchase(LocalPlayer, assetId)
			end)
		end
	else
		playErrorSound()
		showToast(type(v7) == "string" and v7 or "Could not start purchase.", 4) -- inferred equivalent call
	end
end

local function bindButton(button)
	if button:GetAttribute("Bound") then
		return
	end

	button:SetAttribute("Bound", true)
	button.AutoButtonColor = false

	local function handleActivate()
		playCloned(getSound("Click")) -- inferred equivalent call
		local slotRoot = findSlotRoot(button)

		if slotRoot then
			promptFor(slotRoot)
		end
	end

	if button.Activated then
		button.Activated:Connect(handleActivate)
	end

	button.MouseButton1Click:Connect(handleActivate)

	if button.TouchTap then
		button.TouchTap:Connect(handleActivate)
	end

	attachHover(button)
end

local function bindClicks(folder)
	for _, button in ipairs(folder:GetDescendants()) do
		if button:IsA("GuiButton") then
			bindButton(button)
		end
	end
end

parent.DescendantAdded:Connect(function(button)
	if button:IsA("GuiButton") then
		bindButton(button)
	end
end)

local function clearMain()
	for _, child in ipairs(main:GetChildren()) do
		if not child:IsA("GuiObject") or (child:IsA("UIListLayout") or child:IsA("UIGridLayout")) then
			continue
		end

		child:Destroy()
	end

	if v4 and v4 ~= 0 then
		v5[v4] = nil
		v6[v4] = nil
	end

	hideEmptyState() -- inferred equivalent call
end

local function shouldThisJarBeActive(): boolean
	if not (screenGui and screenGui.Enabled) then
		return false
	end

	local children = LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:GetChildren() or {}
	local count4 = 0
	local v7 = nil

	for _, screenGui2 in ipairs(children) do
		if not (screenGui2:IsA("ScreenGui") and screenGui2.Name == "Jar" and screenGui2.Enabled) then
			continue
		end

		count4 += 1
		v7 = screenGui2
	end

	return not (count4 > 1) or v7 == screenGui
end

local function populateStreaming(p: number, p2: number)
	local set = {}

	local function currentContainer() -- 3 equivalent calls inferred from this helper
		local v7 = v4 == p and main

		if v7 then
			return v7
		end

		local name = tostring(p)
		v7 = pools:FindFirstChild(name)

		if not v7 then
			v7 = Instance.new("Folder")
			v7.Name = name
			v7.Parent = pools
		end

		return v7
	end

	local v7 = currentContainer() -- inferred equivalent call
	local v8 = containerHasTiles(v7)

	if v8 then
		hideEmptyState() -- inferred equivalent call
	else
		local emptyState = ensureEmptyState()
		local message = emptyState:FindFirstChild("Message")

		if message and message:IsA("TextLabel") then
			message.Text = "Loading items…"
		end

		emptyState.Visible = true
	end

	for _, guiObject in ipairs(v7:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local assetId = guiObject:GetAttribute("AssetId")

		if typeof(assetId) == "number" then
			set[assetId] = true
		end
	end

	local getOwnerStore = Events:WaitForChild("GetOwnerStore")
	local count4 = 0
	local count5 = 0

	local function addIfNew(p3: number, p4: string, p5: number?)
		if count ~= p2 or set[p3] then
			return
		end

		set[p3] = true

		if not p5 then
			local gamePass = p4 == "Gamepass" and Enum.InfoType.GamePass or Enum.InfoType.Asset
			local success, productInfo = pcall(MarketplaceService.GetProductInfo, MarketplaceService, p3, gamePass)
			p5 = success
				and productInfo
				and productInfo.IsForSale
				and tonumber(productInfo.PriceInRobux)
				and productInfo.PriceInRobux > 0
				and productInfo.PriceInRobux
				or nil

			if not p5 then
				return
			end
		end

		local clone = template:Clone()
		clone.Name = "asset_" .. tostring(p3)
		clone.LayoutOrder = 0

		if currentContainer() == main then -- inferred equivalent call
			ensureLayout()
		end

		clone.Parent = currentContainer() -- inferred equivalent call

		setSlot(clone, p3, p4, p5)
		bindClicks(clone)

		registerTile(p, clone, p5, count4)
		count4 += 1
		count5 += 1

		if not v8 and count5 == 1 and v4 == p then
			hideEmptyState() -- inferred equivalent call
		end

		scheduleReindex(p) -- inferred equivalent call
	end

	local v9 = nil

	if screenGui then
		local storeJSON = screenGui:GetAttribute("StoreJSON")

		if storeJSON then
			local success, result = pcall(HttpService.JSONDecode, HttpService, storeJSON)
			v9 = success and result or v9
		end
	end

	if v9 then
		for _, v10 in ipairs(v9.clothing or {}) do
			addIfNew(v10, "Clothing")
		end

		for _, v10 in ipairs(v9.gamepasses or {}) do
			addIfNew(v10, "Gamepass")
		end
	end

	local v10 = os.clock() + 25
	local v11 = nil

	while os.clock() < v10 and count == p2 do
		local v12 = getOwnerStore:InvokeServer(p)

		if v12 then
			for _, v13 in ipairs(v12.clothing or {}) do
				addIfNew(v13, "Clothing")
			end

			for _, v13 in ipairs(v12.gamepasses or {}) do
				addIfNew(v13, "Gamepass")
			end

			if v12.ready == true then
				v11 = v11 or os.clock()

				if os.clock() - v11 > 1.2 then
					break
				end
			end
		end

		task.wait(0.45)
	end

	finalizeOrder(p)

	if count5 == 0 and not v8 then
		showEmptyState(v4 == p and ownerId ~= 0 and "This user doesn't have any on-sale items yet." or "No items to show.") -- inferred equivalent call
	else
		hideEmptyState() -- inferred equivalent call
	end

	local v12 = main and main:IsA("ScrollingFrame") and canvasPositions[p]

	if v12 then
		count3 += 1
		local v13 = count3

		task.spawn(function()
			for _ = 1, 12 do
				if v13 ~= count3 then
					break
				end

				RunService.Heartbeat:Wait()
				main.CanvasPosition = clampCanvasPos(main, v12) -- inferred equivalent call
			end
		end)
	end
end

local close = parent:FindFirstChild("Close")

if close and close:IsA("GuiButton") then
	close.AutoButtonColor = false

	local v7 = close:FindFirstChildOfClass("UIScale")

	if not v7 then
		v7 = Instance.new("UIScale")
		v7.Scale = 1
		v7.Parent = close
	end

	local tweenInfo3 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo4 = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	close.MouseButton1Down:Connect(function()
		TweenService:Create(v7, tweenInfo4, { Scale = 0.95 }):Play()
	end)
	close.MouseButton1Up:Connect(function()
		TweenService:Create(v7, tweenInfo3, { Scale = 1 }):Play()
	end)

	local flag = false
	local function finalizeClose()
		hideTooltip() -- inferred equivalent call
		parent.Visible = false

		if screenGui then
			screenGui.Enabled = false
		end

		if main then
			main.Visible = false
		end

		flag = false
	end

	local function doClose()
		if flag then
			return
		end

		flag = true
		local click = parent:FindFirstChild("Click")
		playCloned(click and click:IsA("Sound") and click or nil) -- inferred equivalent call
		saveScroll(v4) -- inferred equivalent call
		local flag2 = false
		animateOut(function()
			if flag2 then
				return
			end

			flag2 = true
			hideTooltip() -- inferred equivalent call
			cancelTweens()

			if main then
				main.Visible = false
			end

			parent.Visible = false

			if screenGui then
				screenGui.Enabled = false
			end

			flag = false
		end)
		task.delay(0.4, function()
			if not flag2 then
				flag2 = true

				if main then
					main.Visible = false
				end

				parent.Visible = false

				if screenGui then
					screenGui.Enabled = false
				end

				hideTooltip() -- inferred equivalent call
				cancelTweens()
				flag = false
			end
		end)
	end

	if close.Activated then
		close.Activated:Connect(doClose)
	end
end

local function clearAndPopulate(p: number, p2: number) -- 1 equivalent call inferred from this helper
	v4 = p
	clearMain()
	ensureLayout()
	task.spawn(function()
		populateStreaming(p, p2)

		if main then
			if not main:IsA("ScrollingFrame") then
				return
			end

			local v7 = canvasPositions[p]

			if not v7 then
				return
			end

			count3 += 1
			local v8 = count3

			task.spawn(function()
				for _ = 1, 12 do
					if v8 ~= count3 then
						break
					end

					RunService.Heartbeat:Wait()
					main.CanvasPosition = clampCanvasPos(main, v7) -- inferred equivalent call
				end
			end)
		end
	end)
end

local function rebuildForCurrentOwner()
	if not shouldThisJarBeActive() then
		v3 = false
		return
	end

	v3 = true
	count += 1
	local v7 = count
	local v8 = ownerId

	if main then
		main.Visible = true
	end

	parent.Visible = true

	updateOwnerHeaderName(v8)

	if v4 ~= 0 then
		saveScroll(v4) -- inferred equivalent call
		parkCurrentIntoPool(v4)
	end

	if #getPool(v8):GetChildren() > 0 then -- inferred equivalent call
		mountPool(v8)
		task.spawn(function()
			populateStreaming(v8, v7)
		end)
	else
		clearAndPopulate(v8, v7) -- inferred equivalent call
	end

	animateIn()
end

if screenGui then
	task.defer(function()
		if parent.Visible == nil then
			parent.Visible = true
		end

		if screenGui.Enabled then
			rebuildForCurrentOwner()
		end

		screenGui:GetAttributeChangedSignal("OwnerId"):Connect(function()
			ownerId = screenGui:GetAttribute("OwnerId") or 0
			updateOwnerHeaderName(ownerId)
			rebuildForCurrentOwner()
		end)

		screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if screenGui.Enabled then
				if main then
					main.Visible = true
				end

				parent.Visible = true
				canvasGroup.GroupTransparency = 0
				uiScale.Scale = 1
				rebuildForCurrentOwner()
			else
				hideTooltip() -- inferred equivalent call
				v3 = false
				cancelTweens()
			end
		end)
	end)
end

task.spawn(function()
	while true do
		task.wait(1)

		if not (screenGui and parent.Visible) then
			continue
		end

		local v7 = shouldThisJarBeActive()

		if v7 or not v3 then
			if v7 and not v3 and screenGui.Enabled then
				rebuildForCurrentOwner()
			end
		else
			v3 = false
			hideTooltip() -- inferred equivalent call
			animateOut(function()
				clearMain()
			end)
		end
	end
end)

task.defer(function()
	for _, button in ipairs(parent:GetDescendants()) do
		if button:IsA("GuiButton") then
			bindButton(button)
		end
	end
end)