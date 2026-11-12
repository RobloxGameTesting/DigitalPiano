local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MonetizationConfig = require(ReplicatedStorage:WaitForChild("Monetization"):WaitForChild("MonetizationConfig"))
local v = math.floor(tonumber(MonetizationConfig.GetGamePassId("GreatPretender")) or 0)

local udim = UDim2.new(0.5, 0, 0, 40)
local udim2 = UDim2.new(0.5, 0, 0, 122)
local udim3 = UDim2.new(0.5, 0, 0, -110)

local pianoSettingsToastGui = nil
local v2 = nil
local v3 = nil
local v4 = {}
local v5 = false
local count = 0
local v6 = nil
local checkGamepassEntitlement = nil
local greatPretenderIconImage = nil

local LocalAutoplayStatusChanged = ReplicatedStorage:FindFirstChild("LocalAutoplayStatusChanged")

if not (LocalAutoplayStatusChanged and LocalAutoplayStatusChanged:IsA("BindableEvent")) then
	if LocalAutoplayStatusChanged then
		LocalAutoplayStatusChanged:Destroy()
	end

	LocalAutoplayStatusChanged = Instance.new("BindableEvent")
	LocalAutoplayStatusChanged.Name = "LocalAutoplayStatusChanged"
	LocalAutoplayStatusChanged.Parent = ReplicatedStorage
end

pcall(function()
	LocalAutoplayStatusChanged.Sandboxed = true
end)

local LocalPianoSessionStateChanged = ReplicatedStorage:FindFirstChild("LocalPianoSessionStateChanged")

if not (LocalPianoSessionStateChanged and LocalPianoSessionStateChanged:IsA("BindableEvent")) then
	if LocalPianoSessionStateChanged then
		LocalPianoSessionStateChanged:Destroy()
	end

	LocalPianoSessionStateChanged = Instance.new("BindableEvent")
	LocalPianoSessionStateChanged.Name = "LocalPianoSessionStateChanged"
	LocalPianoSessionStateChanged.Parent = ReplicatedStorage
end

pcall(function()
	LocalPianoSessionStateChanged.Sandboxed = true
end)

local function playClickSound()
	local soundFX = ReplicatedStorage:FindFirstChild("SoundFX")
	local clickSound2 = soundFX and (soundFX:FindFirstChild("ClickSound2") or soundFX:FindFirstChild("ClickSound"))

	if clickSound2 and clickSound2:IsA("Sound") then
		pcall(function()
			clickSound2:Play()
		end)
	end
end

local function setButtonText(button, text)
	if not button then
		return
	end

	local textLabel = button:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		if button:IsA("TextButton") then
			button.Text = ""
			button.TextTransparency = 1
		end

		textLabel.Text = text
	elseif button:IsA("TextButton") then
		button.Text = text
		button.TextTransparency = 0
	end
end

local function getGreatPretenderIconText()
	for _, v7 in ipairs(MonetizationConfig.Gamepasses or {}) do
		if v7.id == "GreatPretender" and type(v7.icon) == "string" and v7.icon ~= "" then
			return v7.icon
		end
	end

	return "PASS"
end

local function getGreatPretenderIconImage()
	if greatPretenderIconImage ~= nil then
		return greatPretenderIconImage
	end

	greatPretenderIconImage = ""

	if v <= 0 then
		return greatPretenderIconImage
	end

	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(v, Enum.InfoType.GamePass)
	end)

	if success and type(result) == "table" then
		local iconImageAssetId = math.floor(tonumber(result.IconImageAssetId) or 0)

		if iconImageAssetId > 0 then
			greatPretenderIconImage = "rbxassetid://" .. tostring(iconImageAssetId)
		end
	end

	return greatPretenderIconImage
end

local function applyGreatPretenderIcon(greatPretenderAdvertiseToast)
	local icon = greatPretenderAdvertiseToast:FindFirstChild("Icon")

	if not (icon and icon:IsA("ImageLabel")) then
		return
	end

	icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	icon.ImageTransparency = 1

	local gamepassIconText = icon.Parent:FindFirstChild("GamepassIconText")

	if not gamepassIconText then
		gamepassIconText = Instance.new("TextLabel")
		gamepassIconText.Name = "GamepassIconText"
		gamepassIconText.BackgroundTransparency = 1
		gamepassIconText.AnchorPoint = icon.AnchorPoint
		gamepassIconText.Position = UDim2.new(0, 14, 0.5, 0)
		gamepassIconText.Size = UDim2.fromOffset(36, 28)
		gamepassIconText.FontFace = Font.new(
			"rbxasset://fonts/families/BuilderSans.json",
			Enum.FontWeight.Bold,
			Enum.FontStyle.Normal
		)
		gamepassIconText.TextColor3 = Color3.fromRGB(255, 190, 50)
		gamepassIconText.TextScaled = true
		gamepassIconText.TextXAlignment = Enum.TextXAlignment.Center
		gamepassIconText.TextYAlignment = Enum.TextYAlignment.Center
		gamepassIconText.ZIndex = icon.ZIndex + 1
		local uiTextSizeConstraint = Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MinTextSize = 8
		uiTextSizeConstraint.MaxTextSize = 13
		uiTextSizeConstraint.Parent = gamepassIconText
		gamepassIconText.Parent = icon.Parent
	end

	gamepassIconText.Text = getGreatPretenderIconText()
	gamepassIconText.Visible = true

	task.spawn(function()
		local greatPretenderIconImage2 = getGreatPretenderIconImage()

		if v2 ~= greatPretenderAdvertiseToast or not icon.Parent then
			return
		end

		if greatPretenderIconImage2 ~= "" then
			icon.Image = greatPretenderIconImage2
			icon.ImageTransparency = 0
			gamepassIconText.Visible = false
		end
	end)
end

local function getRemotes() -- 2 equivalent calls inferred from this helper
	local piano_Dependencies = Workspace:FindFirstChild("Piano_Dependencies")
		or Workspace:WaitForChild("Piano_Dependencies", 10)

	if piano_Dependencies then
		return piano_Dependencies:FindFirstChild("Remotes") or piano_Dependencies:WaitForChild("Remotes", 10)
	end

	return nil
end

local function getCheckGamepassEntitlementRemote() -- 1 equivalent call inferred from this helper
	if checkGamepassEntitlement and checkGamepassEntitlement.Parent then
		return checkGamepassEntitlement
	end

	local remotes = getRemotes() -- inferred equivalent call
	checkGamepassEntitlement = remotes
		and (remotes:FindFirstChild("CheckGamepassEntitlement") or remotes:WaitForChild("CheckGamepassEntitlement", 5))
	return checkGamepassEntitlement
end

local function ownsGreatPretender()
	if v <= 0 then
		return true
	end

	local checkGamepassEntitlementRemote = getCheckGamepassEntitlementRemote() -- inferred equivalent call

	if checkGamepassEntitlementRemote and checkGamepassEntitlementRemote:IsA("RemoteFunction") then
		local success, result = pcall(function()
			return checkGamepassEntitlementRemote:InvokeServer(v)
		end)

		if success then
			return result == true
		end
	end

	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, v)
	end)

	return success and result == true
end

local function hasActiveAutoplay(): boolean -- 5 equivalent calls inferred from this helper
	return next(v4) ~= nil
end

local function cancelTween() -- 2 equivalent calls inferred from this helper
	if v3 then
		v3:Cancel()
		v3 = nil
	end
end

local function getToastTargetPosition() -- 1 equivalent call inferred from this helper
	if pianoSettingsToastGui then
		local otherPianoMutedToast = pianoSettingsToastGui:FindFirstChild("OtherPianoMutedToast")

		if otherPianoMutedToast and otherPianoMutedToast:IsA("GuiObject") and otherPianoMutedToast.Visible then
			return udim2
		end
	end

	return udim
end

local function hideToast()
	if not (v2 and v2.Visible) then
		return
	end

	local v7 = v2
	cancelTween() -- inferred equivalent call
	v3 = TweenService:Create(v7, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = udim3
	})

	v3.Completed:Connect(function()
		if v2 == v7 then
			v7.Visible = false
		end
	end)
	v3:Play()
end

local function getMerchBooth()
	local merchBooth = ReplicatedStorage:FindFirstChild("MerchBooth")
		or ReplicatedStorage:WaitForChild("MerchBooth", 10)

	if not merchBooth then
		return nil, nil
	end

	local success, result = pcall(function()
		return require(merchBooth)
	end)

	if success and type(result) == "table" then
		return result, merchBooth
	end

	return nil, merchBooth
end

local function focusGreatPretenderItem()
	if v <= 0 then
		return
	end

	local merchBooth, v7 = getMerchBooth()

	if not merchBooth then
		return
	end

	local v8

	if type(merchBooth.isMerchBoothOpen) == "function" then
		local success, result = pcall(function()
			return merchBooth.isMerchBoothOpen()
		end)
		v8 = success and result == true
	else
		v8 = true
	end

	if not v8 then
		return
	end

	pcall(function()
		local clientStore = require(v7:WaitForChild("Modules"):WaitForChild("clientStore"))
		merchBooth.openItemView(v)
		clientStore:flush()
	end)
end

local function openGreatPretenderInShop()
	if v <= 0 then
		return
	end

	ReplicatedStorage:SetAttribute("PianoShopRequestedCategory", "Gamepasses")

	local merchBooth = getMerchBooth()
	local v7

	if merchBooth and type(merchBooth.isMerchBoothOpen) == "function" then
		local success, result = pcall(function()
			return merchBooth.isMerchBoothOpen()
		end)
		v7 = success and result == true
	else
		v7 = false
	end

	if not v7 then
		local openShop = ReplicatedStorage:FindFirstChild("OpenShop") or ReplicatedStorage:WaitForChild("OpenShop", 3)

		if openShop and openShop:IsA("BindableEvent") then
			openShop:Fire("Gamepasses")
		elseif merchBooth and type(merchBooth.openMerchBooth) == "function" then
			pcall(function()
				merchBooth.openMerchBooth()
			end)
		end
	end

	task.delay(0.55, focusGreatPretenderItem)
end

local function ensureToast()
	if v2 and v2.Parent then
		return v2
	end

	pianoSettingsToastGui = PlayerGui:FindFirstChild("PianoSettingsToastGui")

	if not pianoSettingsToastGui then
		pianoSettingsToastGui = Instance.new("ScreenGui")
		pianoSettingsToastGui.Name = "PianoSettingsToastGui"
		pianoSettingsToastGui.ResetOnSpawn = false
		pianoSettingsToastGui.IgnoreGuiInset = true
		pianoSettingsToastGui.DisplayOrder = 12000
		pianoSettingsToastGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		pcall(function()
			pianoSettingsToastGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
			pianoSettingsToastGui.ClipToDeviceSafeArea = true
		end)
		pianoSettingsToastGui.Parent = PlayerGui
	end

	local ui = ReplicatedStorage:WaitForChild("UI", 10)
	local offlineGiftPanelTemplate = ui and ui:WaitForChild("OfflineGiftPanelTemplate", 10)
	local toast = offlineGiftPanelTemplate and offlineGiftPanelTemplate:FindFirstChild("Toast")

	if not (toast and toast:IsA("GuiObject")) then
		return nil
	end

	local greatPretenderAdvertiseToast = pianoSettingsToastGui:FindFirstChild("GreatPretenderAdvertiseToast")

	if greatPretenderAdvertiseToast then
		greatPretenderAdvertiseToast:Destroy()
	end

	local greatPretenderAdvertiseToast2 = toast:Clone()
	greatPretenderAdvertiseToast2.Name = "GreatPretenderAdvertiseToast"
	greatPretenderAdvertiseToast2.Visible = false
	greatPretenderAdvertiseToast2.Position = udim3
	greatPretenderAdvertiseToast2.Parent = pianoSettingsToastGui
	v2 = greatPretenderAdvertiseToast2

	local message = greatPretenderAdvertiseToast2:FindFirstChild("Message")

	if message and message:IsA("TextLabel") then
		message.Text = "Hide your AUTOPLAYING tag with Great Pretender"
	end

	applyGreatPretenderIcon(greatPretenderAdvertiseToast2)

	local actionButton = greatPretenderAdvertiseToast2:FindFirstChild("ActionButton")

	if actionButton and actionButton:IsA("TextButton") then
		setButtonText(actionButton, "Buy")
		local flag = false
		local function activateViewButton()
			if flag then
				return
			end

			flag = true
			playClickSound()
			openGreatPretenderInShop()
			task.delay(0.75, function()
				flag = false
			end)
		end
		actionButton.Activated:Connect(activateViewButton)
		actionButton.MouseButton1Click:Connect(activateViewButton)
	end

	local close = greatPretenderAdvertiseToast2:FindFirstChild("Close")

	if close and close:IsA("TextButton") then
		close.MouseButton1Click:Connect(function()
			playClickSound()
			v5 = true
			hideToast()
		end)
	end

	return greatPretenderAdvertiseToast2
end

local function showToast()
	if v5 or v6 == true or not hasActiveAutoplay() then -- inferred equivalent call
		return
	end

	local toast = ensureToast()

	if not toast then
		return
	end

	cancelTween() -- inferred equivalent call

	if not toast.Visible then
		toast.Position = udim3
		toast.Visible = true
	end

	v3 = TweenService:Create(toast, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = getToastTargetPosition() -- inferred equivalent call
	})

	v3:Play()
end

local function requestToastIfEligible()
	if v5 or not hasActiveAutoplay() then -- inferred equivalent call
		return
	end

	count += 1
	local v7 = count
	task.spawn(function()
		local v8 = ownsGreatPretender()

		if v7 ~= count then
			return
		end

		v6 = v8

		if v8 then
			hideToast()
		else
			showToast()
		end
	end)
end

LocalAutoplayStatusChanged.Event:Connect(function(p, value)
	local v7 = tostring(value or "Autoplay")
	local activeAutoplay = hasActiveAutoplay() -- inferred equivalent call

	if p == true then
		v4[v7] = true

		if not activeAutoplay then
			v5 = false
		end

		if not v5 then
			if not hasActiveAutoplay() then -- inferred equivalent call
				return
			end

			count += 1
			local v8 = count
			task.spawn(function()
				local v9 = ownsGreatPretender()

				if v8 ~= count then
					return
				end

				v6 = v9

				if v9 then
					hideToast()
				else
					showToast()
				end
			end)
		end
	else
		v4[v7] = nil

		if not hasActiveAutoplay() then -- inferred equivalent call
			v5 = false
		end
	end
end)

LocalPianoSessionStateChanged.Event:Connect(function(p)
	if p == true then
		return
	end

	v4 = {}
	v5 = false
	hideToast()
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p == LocalPlayer and p3 and math.floor(tonumber(p2) or 0) == v then
		v6 = true
		hideToast()
	end
end)

task.spawn(function()
	local remotes = getRemotes() -- inferred equivalent call
	local shopPurchasesUpdated = remotes and remotes:FindFirstChild("ShopPurchasesUpdated")

	if shopPurchasesUpdated and shopPurchasesUpdated:IsA("RemoteEvent") then
		shopPurchasesUpdated.OnClientEvent:Connect(function()
			v6 = ownsGreatPretender()

			if v6 then
				hideToast()
			end
		end)
	end
end)