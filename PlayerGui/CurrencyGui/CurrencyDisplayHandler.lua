local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local parent = script.Parent
parent.IgnoreGuiInset = true
parent.ScreenInsets = Enum.ScreenInsets.None
parent.ClipToDeviceSafeArea = false
local upperBar = parent:WaitForChild("UpperBar")
local notes = upperBar:WaitForChild("Notes")
local amount = notes:WaitForChild("Amount")
local adviceFrame = notes:WaitForChild("AdviceFrame")
local textButton = notes:WaitForChild("TextButton")
local plusButton = upperBar:WaitForChild("PlusButton")
local btn = plusButton:WaitForChild("Btn")
local SoundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
local notesCounter = SoundFX and SoundFX:FindFirstChild("NotesCounter")
local notesCounterSound

if notesCounter and notesCounter:IsA("Sound") then
	notesCounterSound = notesCounter:Clone()
	notesCounterSound.Name = "NotesCounterSound"
	notesCounterSound.Looped = true
	notesCounterSound.Parent = parent
else
	notesCounterSound = nil
end

local function applyResponsiveLayout()
	upperBar.AnchorPoint = Vector2.new(0, 1)
	upperBar.Position = UDim2.new(0, 14, 1, -10)
	upperBar.Size = UDim2.fromOffset(1453, 42)
	upperBar.AutomaticSize = Enum.AutomaticSize.None
	upperBar.ClipsDescendants = false

	local uiScale = upperBar:FindFirstChildOfClass("UIScale")

	if uiScale then
		uiScale.Scale = 1
	end

	notes.AnchorPoint = Vector2.new(0, 0.5)
	notes.Position = UDim2.new(0, 0, 0.5, 0)
	notes.Size = UDim2.new(0.1, 0, 1, 0)

	plusButton.AnchorPoint = Vector2.new(0, 0.5)
	plusButton.Position = UDim2.new(0.111411355, 0, 0.52409637, 0)
	plusButton.Size = UDim2.new(0.0307228938, 0, 1, 0)
end

applyResponsiveLayout()

local function ensurePlusButtonScale() -- 1 equivalent call inferred from this helper
	local v = plusButton:FindFirstChildOfClass("UIScale")

	if not v then
		v = Instance.new("UIScale")
		v.Scale = 1
		v.Parent = plusButton
	end

	return v
end

local function ensurePlusButtonStroke() -- 1 equivalent call inferred from this helper
	local v = plusButton:FindFirstChildOfClass("UIStroke")

	if v then
		return v
	end

	v = Instance.new("UIStroke")
	v.Thickness = 1.5
	v.Transparency = 1
	v.LineJoinMode = Enum.LineJoinMode.Round
	v.Parent = plusButton

	return v
end

local function wirePlusButtonAnimation()
	btn.AutoButtonColor = false
	local plusButtonScale = ensurePlusButtonScale() -- inferred equivalent call
	local plusButtonStroke = ensurePlusButtonStroke() -- inferred equivalent call
	local backgroundColor3 = plusButton.BackgroundColor3
	local backgroundTransparency = plusButton.BackgroundTransparency
	local backgroundColor3_2 = btn.BackgroundColor3
	local backgroundTransparency2 = btn.BackgroundTransparency
	local textColor3 = btn.TextColor3
	local color = plusButtonStroke.Color
	local transparency = plusButtonStroke.Transparency
	local soundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
	local clickSound = soundFX and soundFX:FindFirstChild("ClickSound")
	local v = false
	local v2 = nil
	local v3 = nil
	local v4 = nil
	local v5 = nil
	local v6 = nil

	local function makeTween(instance, duration, goal) -- 11 equivalent calls inferred from this helper
		return TweenService:Create(
			instance,
			TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			goal
		)
	end

	local function cancelTweens() -- 1 equivalent call inferred from this helper
		if v2 then
			v2:Cancel()
		end

		if v3 then
			v3:Cancel()
		end

		if v4 then
			v4:Cancel()
		end

		if v5 then
			v5:Cancel()
		end

		if v6 then
			v6:Cancel()
		end
	end

	local function applyHover(p)
		v = p
		cancelTweens() -- inferred equivalent call

		if p then
			plusButtonStroke.Color = Color3.fromRGB(200, 230, 255)
			v2 = makeTween(plusButton, 0.16, { -- inferred equivalent call
				BackgroundColor3 = Color3.fromRGB(84, 173, 255),
				BackgroundTransparency = 0
			})
			v3 = makeTween(btn, 0.16, { -- inferred equivalent call
				BackgroundColor3 = Color3.fromRGB(84, 173, 255),
				BackgroundTransparency = 1
			})
			v4 = makeTween(btn, 0.16, { TextColor3 = Color3.fromRGB(255, 255, 255) }) -- inferred equivalent call
			v5 = makeTween(plusButtonScale, 0.16, { Scale = 1.06 }) -- inferred equivalent call
			v6 = makeTween(plusButtonStroke, 0.16, { Transparency = 0.15 }) -- inferred equivalent call
		else
			plusButtonStroke.Color = color
			v2 = makeTween(plusButton, 0.16, { -- inferred equivalent call
				BackgroundColor3 = backgroundColor3,
				BackgroundTransparency = backgroundTransparency
			})
			v3 = makeTween(btn, 0.16, { -- inferred equivalent call
				BackgroundColor3 = backgroundColor3_2,
				BackgroundTransparency = backgroundTransparency2
			})
			v4 = makeTween(btn, 0.16, { TextColor3 = textColor3 }) -- inferred equivalent call
			v5 = makeTween(plusButtonScale, 0.16, { Scale = 1 }) -- inferred equivalent call
			v6 = makeTween(plusButtonStroke, 0.16, { Transparency = transparency }) -- inferred equivalent call
		end

		v2:Play()
		v3:Play()
		v4:Play()
		v5:Play()
		v6:Play()
	end

	local function applyPress(p) -- 4 equivalent calls inferred from this helper
		if v5 then
			v5:Cancel()
		end

		v5 = makeTween(plusButtonScale, 0.1, { -- inferred equivalent call
			Scale = p and 0.98 or v and 1.06 or 1
		})
		v5:Play()
	end

	btn.MouseEnter:Connect(function()
		applyHover(true)
	end)
	btn.MouseLeave:Connect(function()
		applyHover(false)
	end)
	btn.MouseButton1Down:Connect(function()
		applyPress(true) -- inferred equivalent call

		if clickSound and clickSound:IsA("Sound") then
			clickSound:Play()
		end
	end)
	btn.MouseButton1Up:Connect(function()
		applyPress(false) -- inferred equivalent call
	end)
	btn.TouchTap:Connect(function()
		applyPress(true) -- inferred equivalent call

		if clickSound and clickSound:IsA("Sound") then
			clickSound:Play()
		end

		task.delay(0.07, function()
			applyPress(false) -- inferred equivalent call
		end)
	end)
end

wirePlusButtonAnimation()

local function formatNumber(p)
	local v = tostring((math.max(0, (math.floor(tonumber(p) or 0)))))

	repeat
		local v2
		v, v2 = v:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local function normalizeAmount(p) -- 5 equivalent calls inferred from this helper
	return (math.max(0, (math.floor(tonumber(p) or 0))))
end

local amount4 = normalizeAmount(amount.Text:gsub(",", "")) -- inferred equivalent call
local flag = false
local count = 0
local renderSteppedConnection = nil
local v = nil
local v2 = 0
local count2 = 0

local function stopNotesCounterSound() -- 3 equivalent calls inferred from this helper
	count2 += 1

	if notesCounterSound and notesCounterSound.IsPlaying then
		notesCounterSound:Stop()
	end
end

local function playNotesCounterSound(p)
	if not (notesCounterSound and notesCounterSound:IsA("Sound")) then
		return
	end

	local v3 = math.max(0.1, tonumber(p) or 0.1)
	count2 += 1
	local v4 = count2
	notesCounterSound.TimePosition = 0
	notesCounterSound:Play()
	task.delay(v3, function()
		if v4 == count2 and notesCounterSound and notesCounterSound.IsPlaying then
			notesCounterSound:Stop()
		end
	end)
end

local function cancelAmountAnimation(p) -- 2 equivalent calls inferred from this helper
	count += 1
	v = nil
	v2 = 0

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	if p ~= false then
		stopNotesCounterSound() -- inferred equivalent call
	end
end

local function setAmountInstant(amount2) -- 2 equivalent calls inferred from this helper
	cancelAmountAnimation(false) -- inferred equivalent call
	stopNotesCounterSound() -- inferred equivalent call
	amount4 = normalizeAmount(amount2) -- inferred equivalent call
	flag = true
	amount.Text = formatNumber(amount4)
end

local function getCounterDuration(p) -- 1 equivalent call inferred from this helper
	local v3 = math.max(1, (math.abs(tonumber(p) or 0)))
	local v4 = math.log(v3 + 1) / 2.302585092994046

	if v3 < 100 then
		return (math.clamp(v4 * 0.45 + 0.45, 0.45, 1.7))
	end

	return (math.clamp(v4 * 2.6 + 1.25, 1.25, 14))
end

local function shouldPlayCounterSound(p): boolean -- 2 equivalent calls inferred from this helper
	return type(p) == "table" and p.PlayCounterSound == true
end

local function animateAmountTo(amount2, p)
	local amount3 = normalizeAmount(amount2) -- inferred equivalent call

	if amount3 <= amount4 then
		setAmountInstant(amount3) -- inferred equivalent call
	else
		cancelAmountAnimation(false) -- inferred equivalent call
		local v3 = amount4
		local v4 = amount3 - v3
		local counterDuration = getCounterDuration(v4) -- inferred equivalent call
		local total = 0
		count += 1
		local v5 = count
		v = amount3
		v2 = os.clock() + counterDuration

		if shouldPlayCounterSound(p) then -- inferred equivalent call
			playNotesCounterSound(counterDuration)
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if v5 ~= count then
				return
			end

			total += dt
			local v6 = math.clamp(total / counterDuration, 0, 1)
			amount4 = normalizeAmount(v3 + v4 * v6) -- inferred equivalent call
			amount.Text = formatNumber(amount4)

			if v6 >= 1 then
				if renderSteppedConnection then
					renderSteppedConnection:Disconnect()
					renderSteppedConnection = nil
				end

				amount4 = amount3
				amount.Text = formatNumber(amount3)
				v = nil
				v2 = 0
				stopNotesCounterSound() -- inferred equivalent call
			end
		end)
	end
end

local function setAmount(p, p2)
	local amount2 = normalizeAmount(p) -- inferred equivalent call

	if flag then
		if v == amount2 then
			if shouldPlayCounterSound(p2) then -- inferred equivalent call
				playNotesCounterSound(math.max(0.1, v2 - os.clock()))
			end

			return
		elseif amount4 < amount2 then
			animateAmountTo(amount2, p2)
			return
		end
	end

	setAmountInstant(amount2) -- inferred equivalent call
end

if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
	textButton.MouseButton1Click:Connect(function()
		local visible = not adviceFrame.Visible
		adviceFrame.Visible = visible
		parent.DisplayOrder = visible and 10 or 0
	end)
else
	textButton.MouseEnter:Connect(function()
		adviceFrame.Visible = true
		parent.DisplayOrder = 10
	end)
	textButton.MouseLeave:Connect(function()
		adviceFrame.Visible = false
		parent.DisplayOrder = 0
	end)
end

btn.MouseButton1Click:Connect(function()
	adviceFrame.Visible = false
	parent.DisplayOrder = 0
	local openShop = ReplicatedStorage2:FindFirstChild("OpenShop") or ReplicatedStorage2:WaitForChild("OpenShop", 3)

	if openShop and openShop:IsA("BindableEvent") then
		openShop:Fire("Notes")
	else
		ClientDebugConfig.Warn("[CurrencyDisplay] OpenShop event was not found.")
	end
end)

local function syncAmountFromAttribute() -- 1 equivalent call inferred from this helper
	local notesBalance = LocalPlayer:GetAttribute("NotesBalance")

	if notesBalance ~= nil then
		setAmount(notesBalance)
	end
end

syncAmountFromAttribute() -- inferred equivalent call
LocalPlayer:GetAttributeChangedSignal("NotesBalance"):Connect(syncAmountFromAttribute)

task.spawn(function()
	local hiddenStats = LocalPlayer:FindFirstChild("HiddenStats") or LocalPlayer:WaitForChild("HiddenStats", 30)

	if not hiddenStats then
		ClientDebugConfig.Warn("[CurrencyDisplay] HiddenStats was not available after profile load wait.")
		return
	end

	local notes2 = hiddenStats:FindFirstChild("Notes") or hiddenStats:WaitForChild("Notes", 30)

	if not notes2 then
		ClientDebugConfig.Warn("[CurrencyDisplay] HiddenStats.Notes was not available after profile load wait.")
		return
	end

	setAmount(notes2.Value)
	notes2.Changed:Connect(setAmount)
end)

task.spawn(function()
	local piano_Dependencies = workspace:WaitForChild("Piano_Dependencies", 15)
	local remotes = piano_Dependencies and piano_Dependencies:WaitForChild("Remotes", 15)

	if not remotes then
		return
	end

	local currencyUpdated = remotes:WaitForChild("CurrencyUpdated", 15)

	if currencyUpdated and currencyUpdated:IsA("RemoteEvent") then
		currencyUpdated.OnClientEvent:Connect(setAmount)
	end
end)