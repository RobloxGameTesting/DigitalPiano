local parent = script.Parent
local receiverPanel = parent:WaitForChild("ReceiverPanel")
local okButton = receiverPanel:WaitForChild("OkButton")
local uiScale = receiverPanel:WaitForChild("UIScale")
local badgeIcon = receiverPanel:WaitForChild("BadgeIcon")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local BadgeConfig = require(ReplicatedStorage:WaitForChild("BadgeConfig"))

local ShowBadgeReceivedEvent = ReplicatedStorage:WaitForChild("ShowBadgeReceivedEvent")

receiverPanel.Visible = false

ShowBadgeReceivedEvent.OnClientEvent:Connect(function(p)
	if p then
		for _, v in ipairs(BadgeConfig) do
			if v.Id == p then
				badgeIcon.Image = v.Image
				break
			end
		end
	end

	parent.Enabled = true
	receiverPanel.Visible = true
	uiScale.Scale = 0.8
	receiverPanel.GroupTransparency = 1

	TweenService:Create(uiScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	TweenService:Create(receiverPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		GroupTransparency = 0
	}):Play()
end)

okButton.MouseButton1Click:Connect(function()
	TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = 0.8
	}):Play()
	local tween = TweenService:Create(
		receiverPanel,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ GroupTransparency = 1 }
	)
	tween:Play()
	tween.Completed:Wait()
	receiverPanel.Visible = false
end)

local backgroundColor3 = okButton.BackgroundColor3
local color = Color3.fromRGB(
	math.min(255, backgroundColor3.R * 255 + 20),
	math.min(255, backgroundColor3.G * 255 + 20),
	(math.min(255, backgroundColor3.B * 255 + 20))
)

okButton.MouseEnter:Connect(function()
	TweenService:Create(okButton, TweenInfo.new(0.2), { BackgroundColor3 = color }):Play()
end)

okButton.MouseLeave:Connect(function()
	TweenService:Create(okButton, TweenInfo.new(0.2), { BackgroundColor3 = backgroundColor3 }):Play()
end)