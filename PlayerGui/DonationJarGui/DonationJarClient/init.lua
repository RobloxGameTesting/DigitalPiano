local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local parent = script.Parent
local holder = parent:WaitForChild("Holder")
local background = holder:WaitForChild("Background")
local donationForm = background:WaitForChild("CanvasGroup"):WaitForChild("DonationForm")

local close = background:WaitForChild("Close")
local profileThumbnail = background:WaitForChild("ProfileThumbnail")
local donatingTo = background:WaitForChild("DonatingTo")
local username = background:WaitForChild("Username")
local transferStatus = background:WaitForChild("TransferStatus")
local donated = background:WaitForChild("DonatedFrame"):WaitForChild("Donated")
local raised = background:WaitForChild("RaisedFrame"):WaitForChild("Raised")

local amountBox = donationForm:WaitForChild("AmountBox")
local nextButton = donationForm:WaitForChild("NextButton")
local cancelButton = donationForm:WaitForChild("CancelButton")
local Notification = script:WaitForChild("Notification")

local Piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 30)

if not Piano_Dependencies then
	ClientDebugConfig.Warn("[DonationJarClient] Missing Workspace.Piano_Dependencies")
	return
end

local Remotes = Piano_Dependencies:WaitForChild("Remotes", 30)

if not Remotes then
	ClientDebugConfig.Warn("[DonationJarClient] Missing Piano_Dependencies.Remotes")
	return
end

local OpenDonationJar = Remotes:WaitForChild("OpenDonationJar", 30)
local BeginDonationTransfer = Remotes:WaitForChild("BeginDonationTransfer", 30)
local GetPlayerProfile = Remotes:FindFirstChild("GetPlayerProfile")

if not (OpenDonationJar and BeginDonationTransfer) then
	ClientDebugConfig.Warn("[DonationJarClient] Missing donation transfer remotes")
	return
end

local v = utf8.char(57346)

local v2 = nil
local v3 = false
local flag = false
local v4 = nil
local v5 = nil

parent.ResetOnSpawn = false
parent.IgnoreGuiInset = true
parent.DisplayOrder = math.max(parent.DisplayOrder, 35)
parent.Enabled = true
holder.Visible = false
amountBox.ClearTextOnFocus = false
amountBox.PlaceholderText = "Enter Robux Amount"
nextButton.Text = "Next"
cancelButton.Text = "Cancel"
Notification.Visible = false

local donationTransferNotice = parent:FindFirstChild("DonationTransferNotice")

if donationTransferNotice then
	donationTransferNotice:Destroy()
end

local donationTransferNotice2 = Notification:Clone()
donationTransferNotice2.Name = "DonationTransferNotice"
donationTransferNotice2.Visible = false
donationTransferNotice2.Parent = parent
donationTransferNotice2.Active = true

for _, guiObject in ipairs(donationTransferNotice2:GetDescendants()) do
	if guiObject:IsA("GuiObject") then
		guiObject.ZIndex = math.max(guiObject.ZIndex, 1000)
	end
end

if donationTransferNotice2:IsA("GuiObject") then
	donationTransferNotice2.ZIndex = math.max(donationTransferNotice2.ZIndex, 1000)
end

local title = donationTransferNotice2:WaitForChild("Title")
local subtitle = donationTransferNotice2:WaitForChild("Subtitle")
local button1 = donationTransferNotice2:WaitForChild("Button1")
local button2 = donationTransferNotice2:WaitForChild("Button2")
local textLabel = button1:FindFirstChildWhichIsA("TextLabel", true)
local textLabel2 = button2:FindFirstChildWhichIsA("TextLabel", true)
local guiButton = button1:FindFirstChildWhichIsA("GuiButton", true)
local guiButton2 = button2:FindFirstChildWhichIsA("GuiButton", true)

local noticeScale = donationTransferNotice2:FindFirstChild("NoticeScale")

if not noticeScale then
	noticeScale = Instance.new("UIScale")
	noticeScale.Name = "NoticeScale"
	noticeScale.Parent = donationTransferNotice2
end

local click = background:FindFirstChild("Click")
local tick = background:FindFirstChild("Tick")

local function playClonedSound(sound)
	if not (sound and sound:IsA("Sound")) then
		return
	end

	local clone = sound:Clone()
	clone.Parent = sound.Parent
	clone.TimePosition = 0
	clone:Play()
	Debris:AddItem(clone, (math.max(1, clone.TimeLength + 0.25)))
end

local function playClick() -- 5 equivalent calls inferred from this helper
	playClonedSound(click)
end

local function playTick()
	playClonedSound(tick)
end

local function attachButtonSounds(button) -- 5 equivalent calls inferred from this helper
	if button and button:IsA("GuiButton") then
		button.MouseEnter:Connect(playTick)
		button.SelectionGained:Connect(playTick)
	end
end

local function comma(p)
	local v6 = tostring((math.max(0, (math.floor(tonumber(p) or 0)))))

	repeat
		local v7
		v6, v7 = v6:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v7 == 0

	return v6
end

local function setStatus(value, p) -- 1 equivalent call inferred from this helper
	transferStatus.Text = tostring(value or "")
	transferStatus.TextColor3 = p and Color3.fromRGB(255, 147, 147) or Color3.fromRGB(245, 248, 255)
end

local function setStatLabels(robuxDonated, robuxRaised) -- 2 equivalent calls inferred from this helper
	donated.Text = string.format("Donated: %s%s", v, comma(robuxDonated))
	raised.Text = string.format("Raised: %s%s", v, comma(robuxRaised))
end

local function setPending(p) -- 4 equivalent calls inferred from this helper
	v3 = p
	nextButton.AutoButtonColor = not p
	nextButton.Active = not p
	nextButton.TextTransparency = p and 0.25 or 0
end

local function setButtonText(label, text) -- 2 equivalent calls inferred from this helper
	if label and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function hideNotice() -- 5 equivalent calls inferred from this helper
	v5 = nil
	donationTransferNotice2.Visible = false
end

local function showNotice(typedAmount)
	v5 = typedAmount
	title.Text = "Before you send"
	subtitle.Text = string.format(
		"%s may need to accept your %s Robux transfer before it appears in chat and stats.",
		v2 and v2.DisplayName or "The recipient",
		comma(typedAmount)
	)
	setButtonText(textLabel, "Close") -- inferred equivalent call
	setButtonText(textLabel2, "OK") -- inferred equivalent call
	noticeScale.Scale = 0.96
	donationTransferNotice2.Visible = true
	TweenService:Create(noticeScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

local function sanitizeAmountText() -- 1 equivalent call inferred from this helper
	if flag then
		return amountBox.Text
	end

	local text = amountBox.Text:gsub("%D", "")

	if text == amountBox.Text then
		return text
	end

	flag = true
	amountBox.Text = text
	amountBox.CursorPosition = #text + 1
	flag = false

	return text
end

local function getTypedAmount() -- 2 equivalent calls inferred from this helper
	local v6 = sanitizeAmountText() -- inferred equivalent call

	if v6 == "" then
		return nil
	end

	return (math.floor(tonumber(v6) or 0))
end

local function updateAmountStatus() -- 1 equivalent call inferred from this helper
	local typedAmount = getTypedAmount() -- inferred equivalent call

	if typedAmount then
		if typedAmount < 10 then
			transferStatus.Text = tostring("Amount must be atleast 10 Robux.")
			transferStatus.TextColor3 = Color3.fromRGB(255, 147, 147) or Color3.fromRGB(245, 248, 255)
		else
			transferStatus.Text = tostring("Enter how much Robux you would like to Send")
			transferStatus.TextColor3 = Color3.fromRGB(245, 248, 255)
		end
	else
		transferStatus.Text = tostring("Enter how much Robux you would like to Send")
		transferStatus.TextColor3 = Color3.fromRGB(245, 248, 255)
	end
end

local function getPlayerLabel(displayName, name) -- 1 equivalent call inferred from this helper
	local v6 = tostring(displayName or name or "Player")
	local v7 = tostring(name or v6 or "Player")
	return string.format("%s (@%s)", v6, v7)
end

local function refreshTargetProfile(p) -- 1 equivalent call inferred from this helper
	if GetPlayerProfile and GetPlayerProfile:IsA("RemoteFunction") then
		task.spawn(function()
			local success, result = pcall(function()
				return GetPlayerProfile:InvokeServer(p)
			end)

			if not success or not v2 or v2.UserId ~= p then
				return
			end

			local profile = type(result) == "table" and result.Profile or nil
			local stats = profile and profile.Stats

			if type(stats) == "table" then
				setStatLabels(stats.RobuxDonated or 0, stats.RobuxRaised or 0) -- inferred equivalent call
			end
		end)
	end
end

local function setAvatar(p) -- 1 equivalent call inferred from this helper
	profileThumbnail.Image = ""
	task.spawn(function()
		local success, result = pcall(function()
			return Players:GetUserThumbnailAsync(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)

		if success and v2 and v2.UserId == p then
			profileThumbnail.Image = result
		end
	end)
end

local function closeJar() -- 2 equivalent calls inferred from this helper
	if v4 then
		v4:Cancel()
		v4 = nil
	end

	hideNotice() -- inferred equivalent call
	holder.Visible = false
	v2 = nil
	v3 = false
	setPending(false) -- inferred equivalent call
end

local function normalizeTransferResult(p, value, value2)
	if not p then
		return false, "Roblox couldn't open the transfer prompt. Try again."
	end

	if value == true then
		return true, nil
	end

	if type(value) == "table" then
		return value.Success == true, value.Message
	end

	if type(value) == "string" and value2 == nil then
		return true, nil
	end

	if type(value2) == "string" then
		return false, value2
	end

	if type(value) == "string" then
		return false, value
	end

	return false, "Roblox couldn't open the transfer prompt. Try again."
end

local function openRobloxTransfer(p)
	if v3 or not v2 then
		return
	end

	transferStatus.Text = tostring("Enter how much Robux you would like to Send")
	transferStatus.TextColor3 = Color3.fromRGB(245, 248, 255)
	setPending(true) -- inferred equivalent call
	local success, result, v6 = pcall(function()
		return BeginDonationTransfer:InvokeServer(v2.UserId, p)
	end)
	setPending(false) -- inferred equivalent call
	local v7

	if success then
		if result == true then
			v7 = true
			result = nil
		elseif type(result) == "table" then
			v7 = result.Success == true
			result = result.Message
		elseif type(result) == "string" and v6 == nil then
			v7 = true
			result = nil
		elseif type(v6) == "string" then
			result = v6
			v7 = false
		elseif type(result) == "string" then
			v7 = false
		else
			v7 = false
			result = "Roblox couldn't open the transfer prompt. Try again."
		end
	else
		v7 = false
		result = "Roblox couldn't open the transfer prompt. Try again."
	end

	if v7 then
		transferStatus.Text = tostring("Enter how much Robux you would like to Send")
		transferStatus.TextColor3 = Color3.fromRGB(245, 248, 255)
	else
		setStatus(result or "Roblox couldn't open the transfer prompt. Try again.", true) -- inferred equivalent call
	end
end

local function beginTransfer()
	if v3 or not v2 then
		return
	end

	local typedAmount = getTypedAmount() -- inferred equivalent call

	if typedAmount then
		if typedAmount < 10 then
			transferStatus.Text = tostring("Amount must be atleast 10 Robux.")
			transferStatus.TextColor3 = Color3.fromRGB(255, 147, 147) or Color3.fromRGB(245, 248, 255)
		else
			showNotice(typedAmount)
		end
	else
		transferStatus.Text = tostring("Enter how much Robux you would like to Send")
		transferStatus.TextColor3 = Color3.fromRGB(245, 248, 255)

		amountBox:CaptureFocus()
	end
end

local function confirmNotice()
	local v6 = v5
	hideNotice() -- inferred equivalent call

	if not v6 or v6 < 10 then
		return
	end

	openRobloxTransfer(v6)
end

local function openJar(p, value, value2)
	local userId = math.floor(tonumber(p) or 0)

	if userId <= 0 or userId == LocalPlayer.UserId or holder.Visible and v2 and v2.UserId == userId then
		return
	end

	v2 = {
		UserId = userId,
		DisplayName = tostring(value or value2 or "Player"),
		Name = tostring(value2 or value or "Player")
	}

	parent.Enabled = true
	holder.Visible = true
	amountBox.Text = ""
	nextButton.Text = "Next"
	donatingTo.Text = "Sending Robux To:"
	username.Text = getPlayerLabel(v2.DisplayName, v2.Name) -- inferred equivalent call
	setStatLabels(0, 0) -- inferred equivalent call
	transferStatus.Text = tostring("Enter how much Robux you would like to Send")
	transferStatus.TextColor3 = Color3.fromRGB(245, 248, 255)
	setPending(false) -- inferred equivalent call
	hideNotice() -- inferred equivalent call
	setAvatar(userId) -- inferred equivalent call
	refreshTargetProfile(userId) -- inferred equivalent call

	if v4 then
		v4:Cancel()
	end

	local v6 = holder:FindFirstChildOfClass("UIScale")

	if not v6 then
		v6 = Instance.new("UIScale")
		v6.Parent = holder
	end

	v6.Scale = 0.96
	v4 = TweenService:Create(v6, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 1
	})
	v4.Completed:Connect(function()
		if v4 then
			v4 = nil
		end
	end)
	v4:Play()
end

amountBox:GetPropertyChangedSignal("Text"):Connect(updateAmountStatus)
attachButtonSounds(nextButton) -- inferred equivalent call
attachButtonSounds(cancelButton) -- inferred equivalent call
attachButtonSounds(close) -- inferred equivalent call
attachButtonSounds(guiButton) -- inferred equivalent call
attachButtonSounds(guiButton2) -- inferred equivalent call
nextButton.Activated:Connect(function()
	playClick() -- inferred equivalent call
	beginTransfer()
end)
cancelButton.Activated:Connect(function()
	playClick() -- inferred equivalent call
	closeJar() -- inferred equivalent call
end)
close.Activated:Connect(function()
	playClick() -- inferred equivalent call
	closeJar() -- inferred equivalent call
end)

if guiButton and guiButton:IsA("GuiButton") then
	guiButton.Activated:Connect(function()
		playClick() -- inferred equivalent call
		hideNotice() -- inferred equivalent call
	end)
end

if guiButton2 and guiButton2:IsA("GuiButton") then
	guiButton2.Activated:Connect(function()
		playClick() -- inferred equivalent call
		local v6 = v5
		hideNotice() -- inferred equivalent call

		if v6 then
			if v6 < 10 then
				return
			end

			openRobloxTransfer(v6)
		end
	end)
end

OpenDonationJar.OnClientEvent:Connect(openJar)
updateAmountStatus() -- inferred equivalent call