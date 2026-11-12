local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Debris = game:GetService("Debris")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 30)

if not Piano_Dependencies then
	ClientDebugConfig.Warn("[DonationAnnouncementsClient] Missing Workspace.Piano_Dependencies")
	return
end

local Remotes = Piano_Dependencies:WaitForChild("Remotes", 30)

if not Remotes then
	ClientDebugConfig.Warn("[DonationAnnouncementsClient] Missing Piano_Dependencies.Remotes")
	return
end

local DonationSystemMessage = Remotes:WaitForChild("DonationSystemMessage", 60)

if not (DonationSystemMessage and DonationSystemMessage:IsA("RemoteEvent")) then
	ClientDebugConfig.Warn("[DonationAnnouncementsClient] DonationSystemMessage remote did not load")
	return
end

local DonationPurchaseRejected = Remotes:WaitForChild("DonationPurchaseRejected", 60)

if not (DonationPurchaseRejected and DonationPurchaseRejected:IsA("RemoteEvent")) then
	ClientDebugConfig.Warn("[DonationAnnouncementsClient] DonationPurchaseRejected remote did not load")
	DonationPurchaseRejected = nil
end

local v = utf8.char(57346)
local v2 = utf8.char(9829)

local v3 = {}

local v4 = {
	Cyan = "#00D1FF",
	Green = "#32CD32",
	Gold = "#FFD700",
	White = "#FFFFFF",
	Gray = "#DDDDDD",
	PinkUI = Color3.fromRGB(255, 114, 161),
	GoldUI = Color3.fromRGB(255, 205, 80)
}

local function comma(amount)
	local v5 = tostring((math.max(0, (math.floor(tonumber(amount) or 0)))))

	repeat
		local v6
		v5, v6 = v5:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v6 == 0

	return v5
end

local function escapeRichText(value) -- 5 equivalent calls inferred from this helper
	return tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function getTextChannel()
	local textChannels = TextChatService:FindFirstChild("TextChannels")
		or TextChatService:WaitForChild("TextChannels", 15)

	if textChannels then
		return textChannels:FindFirstChild("RBXSystem")
			or textChannels:FindFirstChild("RBXGeneral")
			or textChannels:WaitForChild("RBXGeneral", 5)
	end

	return nil
end

local function displayChatMessage(value)
	local textChannel = getTextChannel()

	if textChannel and textChannel.DisplaySystemMessage and pcall(function()
		textChannel:DisplaySystemMessage(value, "DonationSystem")
	end) then
		return
	end

	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = value:gsub("<[^>]->", ""),
			Color = Color3.fromRGB(90, 255, 125),
			Font = Enum.Font.GothamBold
		})
	end)
end

local function formatGameDonationChatMessage(data)
	local donorDisplayName = tostring(data.DonorDisplayName or data.DisplayName or data.DonorName or "Someone")
	local v5 = data.IsGlobal == true and "<font color='#FFD700'><b>[GLOBAL]</b></font> " or ""

	local v6 = data.IsGlobal == true and "<font color='#FFD700'>" .. v2 .. "</font>"
		or "<font color='#FF6FA0'>" .. v2 .. "</font>"

	return v5 .. string.format(
		"<b><font color='%s'>%s</font> <font color='%s'>Donated</font> <font color='%s'>%s%s</font><br/><font color='%s'>Thank you for your support! %s</font></b>",
		v4.Cyan,
		escapeRichText(donorDisplayName), -- inferred equivalent call
		v4.White,
		v4.Green,
		v,
		comma(data.Amount or 0),
		v4.Gray,
		v6
	)
end

local function playSoundTemplate(sound, name)
	if not (sound and sound:IsA("Sound")) then
		return
	end

	local clone = sound:Clone()
	clone.Name = name
	clone.Parent = SoundService
	clone.TimePosition = 0
	clone:Play()
	Debris:AddItem(clone, (math.max(3, clone.TimeLength + 1)))
	return clone
end

local function playDonationSound() -- 1 equivalent call inferred from this helper
	local soundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
	local donated = soundFX and soundFX:FindFirstChild("Donated")
	playSoundTemplate(donated, "DonationAnnouncementSound")
end

local function playErrorSound() -- 1 equivalent call inferred from this helper
	local soundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
	local err = soundFX and soundFX:FindFirstChild("Error")
	playSoundTemplate(err, "DonationErrorSound")
end

local function safePreload(p) -- 1 equivalent call inferred from this helper
	pcall(function()
		ContentProvider:PreloadAsync(p)
	end)
end

local function soundDuration(sound) -- 2 equivalent calls inferred from this helper
	if sound and sound:IsA("Sound") then
		local playbackSpeed = tonumber(sound.PlaybackSpeed) or 1
		local v5 = playbackSpeed <= 0 and 1 or playbackSpeed

		return (tonumber(sound.TimeLength) or 0) / v5
	end

	return 0
end

local function spawnMascotSpark(mascot, position, goldUI, p)
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Text = p or v2
	textLabel.TextScaled = true
	textLabel.TextColor3 = goldUI or v4.PinkUI
	textLabel.Size = UDim2.fromOffset(18, 18)
	textLabel.Position = position
	textLabel.ZIndex = 101
	textLabel.Parent = mascot

	local tween = TweenService:Create(textLabel, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(
			position.X.Scale,
			position.X.Offset + math.random(-20, 20),
			position.Y.Scale,
			position.Y.Offset - math.random(35, 55)
		),
		TextTransparency = 1
	})

	tween.Completed:Connect(function()
		textLabel:Destroy()
	end)
	tween:Play()
end

local function showDonationMascot(data, value, p)
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local donorName = tostring(data.DonorName or "Someone")
	local receiverName = tostring(data.ReceiverName or "Piano Sim")
	local amount = tonumber(data.Amount) or 0
	local isGlobal = data.IsGlobal == true
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local donationMascot = playerGui:FindFirstChild("DonationMascot")

	if not donationMascot then
		donationMascot = Instance.new("ScreenGui")
		donationMascot.Name = "DonationMascot"
		donationMascot.IgnoreGuiInset = true
		donationMascot.ResetOnSpawn = false
		donationMascot.ZIndexBehavior = Enum.ZIndexBehavior.Global
		donationMascot.DisplayOrder = 100
		donationMascot.Parent = playerGui
	end

	local mascot = Instance.new("Frame")
	mascot.Name = "Mascot"
	mascot.AnchorPoint = Vector2.new(0, 1)
	mascot.Size = UDim2.fromOffset(280, 280)
	mascot.Position = UDim2.new(0, -320, 1, -24)
	mascot.BackgroundTransparency = 1
	mascot.ZIndex = 50
	mascot.Parent = donationMascot

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromOffset(250, 250)
	frame.BackgroundColor3 = isGlobal and v4.GoldUI or v4.PinkUI
	frame.BackgroundTransparency = 0.7
	frame.ZIndex = 50
	frame.Parent = mascot
	local uiCorner = Instance.new("UICorner", frame)
	uiCorner.CornerRadius = UDim.new(1, 0)

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0, 1)
	imageLabel.Size = UDim2.fromOffset(240, 240)
	imageLabel.Position = UDim2.new(0, 10, 1, -10)
	imageLabel.Image = "rbxassetid://75424138933157"
	imageLabel.ZIndex = 50
	imageLabel.Parent = mascot
	safePreload({ imageLabel }) -- inferred equivalent call

	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.RichText = true
	textLabel.TextWrapped = true
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextSize = 25
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.5
	textLabel.AnchorPoint = Vector2.new(0, 1)
	textLabel.Size = UDim2.fromOffset(560, 72)
	textLabel.Position = UDim2.new(0, 24, 0, -10)
	textLabel.ZIndex = 52
	textLabel.TextTransparency = 1
	textLabel.Text = string.format(
		"%sThank you <b>%s</b> for donating <font color='%s'>%s%s</font> to <b>%s</b>! %s",
		isGlobal and "<font color='" .. v4.Gold .. "'>[GLOBAL]</font> " or "",
		escapeRichText(donorName), -- inferred equivalent call
		v4.Green,
		v,
		comma(amount),
		escapeRichText(receiverName), -- inferred equivalent call
		isGlobal and "<font color='" .. v4.Gold .. "'>" .. v2 .. "</font>" or "<font color='#FF6FA0'>" .. v2 .. "</font>"
	)

	textLabel.Parent = mascot

	TweenService:Create(mascot, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 24, 1, -24)
	}):Play()
	TweenService:Create(textLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()

	task.delay(0.15, function()
		for _ = 1, isGlobal and 10 or 6 do
			spawnMascotSpark(
				mascot,
				UDim2.new(0.35, math.random(-30, 30), 0.45, math.random(-10, 10)),
				isGlobal and v4.GoldUI or nil,
				v2
			)
			task.wait(0.05)
		end
	end)

	local v5 = nil
	task.delay(math.max(0, value or 0), function()
		if not mascot.Parent then
			return
		end

		mascot.Rotation = -8
		v5 = TweenService:Create(
			mascot,
			TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Rotation = 8 }
		)
		v5:Play()
	end)

	task.delay(math.max(4, tonumber(p) or 4), function()
		if v5 then
			v5:Cancel()
		end

		TweenService:Create(imageLabel, TweenInfo.new(0.1), { ImageTransparency = 1 }):Play()
		TweenService:Create(frame, TweenInfo.new(0.1), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(textLabel, TweenInfo.new(0.1), { TextTransparency = 1 }):Play()
		TweenService:Create(mascot, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(0, -320, 1, -24)
		}):Play()
		task.wait(0.2)
		mascot:Destroy()
	end)
end

local function playDonationAnnouncementEffects(data)
	local soundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
	local donated = soundFX and (soundFX:FindFirstChild("Donated") or soundFX:FindFirstChild("ShopPurchaseSuccess"))
	local tuturu = soundFX and soundFX:FindFirstChild("Tuturu")
	local v5 = soundDuration(donated) -- inferred equivalent call
	local v6 = soundDuration(tuturu) -- inferred equivalent call
	local v7 = v5 > 0 and v5 * 0.5 or 1.4
	showDonationMascot(data, v7, v7 + (v6 > 0 and v6 or 1.5) + (data.IsGlobal == true and 0.9 or 0.6))
	playSoundTemplate(donated, "DonationAnnouncementSound")
	task.delay(v7, function()
		playSoundTemplate(tuturu, "DonationMascotSound")
	end)
end

local function sendRobloxNotification(title, body, duration)
	local title2 = tostring(title or "Donation rejected")
	local text = tostring(body or "The donation could not be verified, so it was not counted.")

	for _ = 1, 8 do
		if pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = title2,
				Text = text,
				Duration = duration or 6
			})
		end) then
			break
		end

		task.wait(0.25)
	end
end

local function getDonationKey(data)
	local donationId = data.DonationId or data.Guid or data.guid

	if donationId then
		return (tostring(donationId))
	end

	return table.concat({
		tostring(data.DonorUserId or data.DonorName or ""),
		tostring(data.ReceiverUserId or data.ReceiverName or ""),
		tostring(data.Amount or 0),
		tostring(data.AssetId or ""),
		tostring(data.Type or ""),
		(tostring(data.IsGlobal == true))
	}, ":")
end

if DonationPurchaseRejected then
	DonationPurchaseRejected.OnClientEvent:Connect(function(p)
		local v5 = type(p) == "table" and p or {}
		playErrorSound() -- inferred equivalent call
		sendRobloxNotification(v5.Title, v5.Body, v5.Duration)
	end)
end

DonationSystemMessage.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then
		return
	end

	local donationKey = getDonationKey(data)

	if v3[donationKey] then
		return
	end

	v3[donationKey] = os.clock()

	if data.Type == "GameDonation" then
		displayChatMessage(formatGameDonationChatMessage(data))
	else
		local v5 = escapeRichText(data.DonorName or "Someone") -- inferred equivalent call
		local v6 = escapeRichText(data.ReceiverName or "Someone") -- inferred equivalent call
		local v7 = comma(data.Amount)
		displayChatMessage((data.IsGlobal == true and "<font color='#FFD166'><b>[GLOBAL]</b></font> " or "<font color='#5AFF7D'><b>[SYSTEM]</b></font> ") .. string.format(
			"<b><font color='#00D1FF'>%s</font></b> donated <font color='#32CD32'><b>%s%s</b></font> to <b><font color='#00D1FF'>%s</font></b>",
			v5,
			v,
			v7,
			v6
		))
	end

	if data.Type == "GameDonation" then
		playDonationAnnouncementEffects(data)
		return
	end

	playDonationSound() -- inferred equivalent call
end)

task.spawn(function()
	while script.Parent do
		task.wait(60)
		local now = os.clock()

		for k, v5 in pairs(v3) do
			if now - v5 > 300 then
				v3[k] = nil
			end
		end
	end
end)