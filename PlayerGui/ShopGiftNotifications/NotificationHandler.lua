local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local parent = script.Parent
local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local shopGiftNotification = remotes:WaitForChild("ShopGiftNotification")
local shopSystemMessage = remotes:WaitForChild("ShopSystemMessage")
local showPurchaseThanks = parent:WaitForChild("ShowPurchaseThanks")

local container = parent:FindFirstChild("Container")

if container and container:IsA("GuiObject") then
	container.Visible = false
end

local session = parent:FindFirstChild("Session")

if session and session:IsA("GuiObject") then
	session.Visible = false
end

local notification = parent:WaitForChild("Notification")
local title = notification:WaitForChild("Title")
local subtitle = notification:WaitForChild("Subtitle")
local button1 = notification:WaitForChild("Button1")
local button2 = notification:WaitForChild("Button2")
local textLabel = button1:FindFirstChildWhichIsA("TextLabel", true)
local textLabel2 = button2:FindFirstChildWhichIsA("TextLabel", true)
local guiButton = button1:FindFirstChildWhichIsA("GuiButton", true)
local guiButton2 = button2:FindFirstChildWhichIsA("GuiButton", true)
local notificationScale = notification:FindFirstChild("NotificationScale")

if not notificationScale then
	notificationScale = Instance.new("UIScale")
	notificationScale.Name = "NotificationScale"
	notificationScale.Parent = notification
end

local notificationSound = parent:FindFirstChild("NotificationSound")
local SoundFX = ReplicatedStorage:FindFirstChild("SoundFX")
local shopPurchaseSuccess = SoundFX and SoundFX:FindFirstChild("ShopPurchaseSuccess")
local err = SoundFX and SoundFX:FindFirstChild("Error")
local purchaseSuccessSound = parent:FindFirstChild("PurchaseSuccessSound")

if purchaseSuccessSound and not purchaseSuccessSound:IsA("Sound") then
	purchaseSuccessSound = nil
end

if not purchaseSuccessSound and shopPurchaseSuccess and shopPurchaseSuccess:IsA("Sound") then
	purchaseSuccessSound = shopPurchaseSuccess:Clone()
	purchaseSuccessSound.Name = "PurchaseSuccessSound"
	purchaseSuccessSound.Parent = parent
end

local purchaseErrorSound = parent:FindFirstChild("PurchaseErrorSound")

if purchaseErrorSound and not purchaseErrorSound:IsA("Sound") then
	purchaseErrorSound = nil
end

if not purchaseErrorSound and err and err:IsA("Sound") then
	purchaseErrorSound = err:Clone()
	purchaseErrorSound.Name = "PurchaseErrorSound"
	purchaseErrorSound.Parent = parent
end

local position = notification.Position
local udim = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 22)
local v = nil
local v2 = nil
local count = 0

notification.Visible = false
notification.Active = true
notificationScale.Scale = 0.96

local function playSound(sound) -- 3 equivalent calls inferred from this helper
	if sound and sound:IsA("Sound") then
		sound.TimePosition = 0
		sound:Play()
	end
end

local function setButtonText(label, text) -- 2 equivalent calls inferred from this helper
	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function stopTweens() -- 2 equivalent calls inferred from this helper
	if v then
		v:Cancel()
		v = nil
	end

	if v2 then
		v2:Cancel()
		v2 = nil
	end
end

local function hideNotification()
	if not notification.Visible or notification:GetAttribute("IsHiding") == true then
		return
	end

	count += 1
	notification:SetAttribute("IsHiding", true)
	notification:SetAttribute("HideAt", nil)
	stopTweens() -- inferred equivalent call
	v = TweenService:Create(notification, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = udim
	})

	v2 = TweenService:Create(notificationScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = 0.96
	})

	v:Play()
	v2:Play()
	v.Completed:Wait()
	notification.Visible = false
	notification.Position = position
	notification:SetAttribute("IsHiding", false)
end

local function showNotification(p, p2, p3)
	parent.Enabled = true

	if container and container:IsA("GuiObject") then
		container.Visible = false
	end

	if session and session:IsA("GuiObject") then
		session.Visible = false
	end

	local v3 = type(p) == "table" and p or {}
	local title2 = tostring(p2.Title)

	if p3 == "Purchase" and v3.Title ~= nil then
		title2 = tostring(v3.Title)
	end

	local body = tostring(v3.Body or p2.Body)

	title.Text = title2
	subtitle.Text = body
	setButtonText(textLabel, "Close") -- inferred equivalent call
	setButtonText(textLabel2, "OK") -- inferred equivalent call
	local v4 = math.max(3, tonumber(v3.Duration) or 8)
	count += 1
	local v5 = count
	notification:SetAttribute("IsHiding", false)
	notification:SetAttribute("HideAt", time() + v4)
	notification.Position = udim
	notificationScale.Scale = 0.96
	notification.Visible = true
	stopTweens() -- inferred equivalent call
	v = TweenService:Create(notification, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = position
	})

	v2 = TweenService:Create(notificationScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	})

	v:Play()
	v2:Play()

	local sound = tostring(v3.Sound or "")

	if v3.IsError == true or sound == "Error" then
		playSound(purchaseErrorSound or notificationSound) -- inferred equivalent call
	elseif p3 == "Purchase" then
		playSound(purchaseSuccessSound or notificationSound) -- inferred equivalent call
	else
		playSound(notificationSound) -- inferred equivalent call
	end

	task.delay(v4, function()
		if v5 == count and notification.Visible then
			hideNotification()
		end
	end)
end

if guiButton and guiButton:IsA("GuiButton") then
	guiButton.Activated:Connect(hideNotification)
end

if guiButton2 and guiButton2:IsA("GuiButton") then
	guiButton2.Activated:Connect(hideNotification)
end

local function showGiftPanel(p) -- 1 equivalent call inferred from this helper
	showNotification(p, { Title = "Notification", Body = "Someone gifted you a shop item." }, "Gift")
end

local function showPurchaseThanks2(p) -- 1 equivalent call inferred from this helper
	showNotification(p, { Title = "Thank you!", Body = "Thanks for supporting the game." }, "Purchase")
end

local function postSystemChat(value)
	local v3 = tostring(value or "")

	if v3 == "" then
		return
	end

	local text = "[SYSTEM] " .. v3
	local textChannels = TextChatService:FindFirstChild("TextChannels")
	local rbxGeneral = textChannels and textChannels:FindFirstChild("RBXGeneral")

	if rbxGeneral and rbxGeneral.DisplaySystemMessage then
		rbxGeneral:DisplaySystemMessage("<font color=\"#5AFF7D\">[SYSTEM]</font> " .. v3)
	else
		pcall(function()
			StarterGui:SetCore("ChatMakeSystemMessage", {
				Text = text,
				Color = Color3.fromRGB(90, 255, 125),
				Font = Enum.Font.GothamBold
			})
		end)
	end
end

task.spawn(function()
	while parent.Parent do
		local hideAt = notification:GetAttribute("HideAt")

		if notification.Visible and type(hideAt) == "number" and hideAt <= time() then
			task.spawn(hideNotification)
		end

		task.wait(0.1)
	end
end)

_G.ShopNotifications = _G.ShopNotifications or {}
_G.ShopNotifications.ShowGiftPanel = showGiftPanel
_G.ShopNotifications.ShowPurchaseThanks = showPurchaseThanks2
_G.ShopNotifications.PostSystemChat = postSystemChat

shopGiftNotification.OnClientEvent:Connect(function(p)
	if type(p) == "table" and p.Kind == "Purchase" then
		showPurchaseThanks2(p) -- inferred equivalent call
	else
		showGiftPanel(p) -- inferred equivalent call
	end
end)

shopSystemMessage.OnClientEvent:Connect(postSystemChat)
showPurchaseThanks.Event:Connect(showPurchaseThanks2)

parent:SetAttribute("NotificationHandlerReady", true)