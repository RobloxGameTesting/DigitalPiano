local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local parent = script.Parent
local mainPanel = parent:FindFirstChild("MainPanel") or parent:WaitForChild("Panel1")
local uiScale = mainPanel:FindFirstChild("UIScale") or Instance.new("UIScale")
uiScale.Parent = mainPanel

local claimButton = mainPanel:WaitForChild("ClaimButton")
local btnText = claimButton:WaitForChild("BtnText")
local closeButton = mainPanel:FindFirstChild("CloseButton")
local resultTextLabel = mainPanel:WaitForChild("ResultTextContainer"):WaitForChild("ResultTextLabel")

local donationsRow = mainPanel:WaitForChild("DonationsRow")
local notesRow = mainPanel:WaitForChild("NotesRow")
local timeRow = mainPanel:WaitForChild("TimeRow")

local HoverSound = script:FindFirstChild("HoverSound")
local ClickSound = script:FindFirstChild("ClickSound")
local OpenSound = script:FindFirstChild("OpenSound")
local SuccessSound = script:FindFirstChild("SuccessSound")

local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local getRankProgress = remotes:WaitForChild("GetRankProgress")
local claimRankRole = remotes:WaitForChild("ClaimRankRole")

local proximityPrompt = workspace:WaitForChild("NPC"):WaitForChild("SuperSupporter"):WaitForChild("PromptPurchase"):WaitForChild("ProximityPrompt")

local flag = false
local flag2 = false
local v = nil
local size = claimButton.Size
local position = claimButton.Position
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.75, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

local v2 = {
	Granted = Color3.fromRGB(255, 215, 0),
	AlreadyRanked = Color3.fromRGB(255, 215, 0),
	Eligible = Color3.fromRGB(80, 255, 140),
	InProgress = Color3.fromRGB(220, 220, 220),
	Ineligible = Color3.fromRGB(255, 190, 90),
	NotInGroup = Color3.fromRGB(255, 190, 90),
	DataNotReady = Color3.fromRGB(220, 220, 220),
	Cooldown = Color3.fromRGB(255, 190, 90),
	CloudError = Color3.fromRGB(255, 110, 110),
	VerifyFailed = Color3.fromRGB(255, 110, 110)
}

local function playSound(object) -- 5 equivalent calls inferred from this helper
	if object then
		object:Play()
	end
end

local function setButtonEnabled(claimButton2, p) -- 1 equivalent call inferred from this helper
	claimButton2.Active = p
	claimButton2.Selectable = p
	pcall(function()
		claimButton2.Interactable = p
	end)
end

local function formatNumber(p)
	local v3 = tostring((math.max(0, (math.floor(tonumber(p) or 0)))))

	repeat
		local v4
		v3, v4 = v3:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v4 == 0

	return v3
end

local function formatDays(timePlayedSeconds) -- 1 equivalent call inferred from this helper
	local v3 = math.max(0, (tonumber(timePlayedSeconds) or 0) / 86400)
	return (string.format("%.1f", v3):gsub("%.0$", ""))
end

local function getFill(instance) -- 1 equivalent call inferred from this helper
	local instanceFrame = instance and instance:FindFirstChild("Frame")
	return instanceFrame and instanceFrame:FindFirstChild("Fill")
end

local function setRow(instance, text, text2, p, p2, p3)
	local textLabel = instance:FindFirstChild("TextLabel")
	local valueLabel = instance:FindFirstChild("ValueLabel")

	if textLabel then
		textLabel.Text = text
	end

	if valueLabel then
		valueLabel.Text = text2
	end

	local fill = getFill(instance) -- inferred equivalent call

	if fill then
		local udim = UDim2.new(math.clamp((tonumber(p) or 0) / math.max(1, tonumber(p2) or 1), 0, 1), 0, 1, 0)

		if p3 then
			TweenService:Create(fill, tweenInfo4, { Size = udim }):Play()
		else
			fill.Size = udim
		end
	end
end

local function setResult(status, message) -- 1 equivalent call inferred from this helper
	resultTextLabel.Text = tostring(message or "")
	resultTextLabel.TextColor3 = v2[status] or Color3.fromRGB(220, 220, 220)
end

local function setClaimButton(p)
	local status = p and p.Status or "DataNotReady"

	if p then
		if p.ClaimEnabled == true then
			p = not flag2
		else
			p = false
		end
	end

	btnText.Text = flag2 and "CHECKING..."
		or status == "Granted" and "CLAIM SUCCESSFUL"
		or status == "AlreadyRanked" and "UNLOCKED"
		or status == "Eligible" and "CLAIM ROLE"
		or status == "NotInGroup" and "JOIN GROUP FIRST"
		or status == "DataNotReady" and "LOADING..."
		or (status == "CloudError" or status == "VerifyFailed" or status == "Cooldown") and "TRY AGAIN"
		or "KEEP PROGRESSING"
	setButtonEnabled(claimButton, p) -- inferred equivalent call
end

local function applyPayload(data, p)
	v = data
	local values = data and data.Values or {}
	local requirements = data and data.Requirements or {}

	setRow(
		donationsRow,
		"Game Robux Donations",
		formatNumber(values.GameDonated) .. " / " .. formatNumber(requirements.GameDonated or 500),
		values.GameDonated,
		requirements.GameDonated or 500,
		p
	)

	setRow(
		notesRow,
		"Total Notes Gained",
		formatNumber(values.TotalNotesEarned) .. " / " .. formatNumber(requirements.TotalNotesEarned or 5000),
		values.TotalNotesEarned,
		requirements.TotalNotesEarned or 5000,
		p
	)

	setRow(
		timeRow,
		"Total Time Played",
		formatDays(values.TimePlayedSeconds) .. " / 7 Days", -- inferred equivalent call
		values.TimePlayedSeconds,
		requirements.TimePlayedSeconds or 604800,
		p
	)

	setResult(data and data.Status or "DataNotReady", data and data.Message or "Progress is unavailable.") -- inferred equivalent call
	setClaimButton(data)
end

local function showLocalError(message)
	applyPayload({
		Status = "CloudError",
		Message = message,
		ClaimEnabled = false,
		Values = {},
		Requirements = { GameDonated = 500, TotalNotesEarned = 5000, TimePlayedSeconds = 604800 }
	}, true)
end

local function refreshProgress(p)
	if flag2 then
		return
	end

	flag2 = true
	setClaimButton(v)
	local success, result = pcall(function()
		return getRankProgress:InvokeServer("SuperSupporter")
	end)

	flag2 = false

	if success and type(result) == "table" then
		applyPayload(result, p)
	else
		showLocalError("Could not load rank progress. Try again in a moment.")
	end
end

local function openPanel()
	if flag then
		refreshProgress(true)
		return
	end

	flag = true
	mainPanel.Visible = true
	uiScale.Scale = 0
	playSound(OpenSound) -- inferred equivalent call
	TweenService:Create(uiScale, tweenInfo, { Scale = 1 }):Play()
	refreshProgress(true)
end

local function closePanel()
	if not flag then
		return
	end

	flag = false
	local tween = TweenService:Create(uiScale, tweenInfo2, { Scale = 0 })
	tween:Play()
	tween.Completed:Once(function()
		if not flag then
			mainPanel.Visible = false
		end
	end)
end

mainPanel.Visible = false
uiScale.Scale = 0
applyPayload({
	Status = "DataNotReady",
	Message = "Use the lobby prompt to check your Super Supporter progress.",
	ClaimEnabled = false,
	Values = {},
	Requirements = { GameDonated = 500, TotalNotesEarned = 5000, TimePlayedSeconds = 604800 }
}, false)

proximityPrompt.Triggered:Connect(function()
	openPanel()
end)

if closeButton then
	closeButton.MouseButton1Click:Connect(function()
		playSound(ClickSound) -- inferred equivalent call
		closePanel()
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
		closePanel()
	end
end)

claimButton.MouseEnter:Connect(function()
	if not claimButton.Active then
		return
	end

	playSound(HoverSound) -- inferred equivalent call
	TweenService:Create(claimButton, tweenInfo3, {
		Size = UDim2.new(size.X.Scale * 1.05, 0, size.Y.Scale * 1.05, 0),
		Position = UDim2.new(position.X.Scale - size.X.Scale * 0.025, 0, position.Y.Scale - size.Y.Scale * 0.025, 0)
	}):Play()
end)

claimButton.MouseLeave:Connect(function()
	TweenService:Create(claimButton, tweenInfo3, { Size = size, Position = position }):Play()
end)

claimButton.MouseButton1Down:Connect(function()
	if not claimButton.Active then
		return
	end

	TweenService:Create(claimButton, tweenInfo3, {
		Size = UDim2.new(size.X.Scale * 0.95, 0, size.Y.Scale * 0.95, 0),
		Position = UDim2.new(position.X.Scale + size.X.Scale * 0.025, 0, position.Y.Scale + size.Y.Scale * 0.025, 0)
	}):Play()
end)

claimButton.MouseButton1Up:Connect(function()
	TweenService:Create(claimButton, tweenInfo3, { Size = size, Position = position }):Play()
end)

claimButton.MouseButton1Click:Connect(function()
	if flag2 or not (v and v.ClaimEnabled) then
		return
	end

	playSound(ClickSound) -- inferred equivalent call
	flag2 = true
	setClaimButton(v)
	resultTextLabel.Text = tostring("Checking requirements with the server...")
	resultTextLabel.TextColor3 = v2.DataNotReady or Color3.fromRGB(220, 220, 220)

	local success, result = pcall(function()
		return claimRankRole:InvokeServer("SuperSupporter")
	end)

	flag2 = false

	if success and type(result) == "table" then
		applyPayload(result, true)
		playSound((result.Status == "Granted" or result.Status == "AlreadyRanked") and SuccessSound) -- inferred equivalent call
	else
		showLocalError("Claim failed. Try again in a moment.")
	end
end)