local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local dependencies = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Modules"):WaitForChild("Dependencies")

local SoundfontManager = require(dependencies:WaitForChild("SoundfontManager"))
local Soundfonts = require(dependencies:WaitForChild("Soundfonts"))

if ReplicatedStorage:GetAttribute("SoundfontsPreloaded") then
	return
end

local Notification = script:WaitForChild("Notification")
local list = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PianoUI"):WaitForChild("NotificationContainer"):WaitForChild("List")

local v = { NotificationSpacing = 5, NotificationHeight = 70 }

function v:showNotification(text, p, p2, p3, p4)
	local clone = Notification:Clone()
	clone.Name = "NotificationItem_" .. tick()
	clone.Visible = true
	clone.LayoutOrder = -tick()

	clone.BackgroundColor3 = p and Color3.fromRGB(34, 34, 34) or Color3.fromRGB(50, 30, 30)

	local uiStroke = clone:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Color = p and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(120, 60, 60)
	end

	local icon = clone:FindFirstChild("Icon")

	if icon then
		icon.ImageColor3 = p and Color3.fromRGB(85, 170, 85) or Color3.fromRGB(220, 100, 100)
	end

	local title = clone:FindFirstChild("Title")

	if title then
		if p4 then
			title.Text = "Soundfont Loader"
		else
			title.Text = text
		end
	end

	local message = clone:FindFirstChild("Message")

	if message then
		if p4 then
			if p then
				message.Text = string.format("All %d packs loaded successfully", p3)
			else
				message.Text = "Some packs failed to load completely"
			end
		elseif p then
			message.Text = "Loaded successfully"
		else
			message.Text = string.format("Partially loaded (%d/%d sounds)", p2, p3)
		end
	end

	clone.Size = UDim2.new(1, 0, 0, 0)
	clone.BackgroundTransparency = 1

	if icon then
		icon.ImageTransparency = 1
	end

	if title then
		title.TextTransparency = 1
	end

	if message then
		message.TextTransparency = 1
	end

	if uiStroke then
		uiStroke.Transparency = 1
	end

	clone.Parent = list

	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0, self.NotificationHeight),
		BackgroundTransparency = 0
	}):Play()

	if uiStroke then
		TweenService:Create(uiStroke, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0
		}):Play()
	end

	if icon then
		task.wait(0.1)
		TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 0
		}):Play()
	end

	if title then
		task.wait(0.05)
		TweenService:Create(title, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
	end

	if message then
		TweenService:Create(message, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		}):Play()
	end

	task.delay(p4 and 4.5 or 3.5, function()
		self:removeNotification(clone)
	end)

	return clone
end

function v:removeNotification(instance)
	if instance and instance.Parent then
		local icon = instance:FindFirstChild("Icon")
		local title = instance:FindFirstChild("Title")
		local message = instance:FindFirstChild("Message")
		local uiStroke = instance:FindFirstChildOfClass("UIStroke")

		if icon then
			TweenService:Create(icon, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				ImageTransparency = 1
			}):Play()
		end

		if title then
			TweenService:Create(title, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1
			}):Play()
		end

		if message then
			TweenService:Create(message, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				TextTransparency = 1
			}):Play()
		end

		if uiStroke then
			TweenService:Create(uiStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
		end

		local tween = TweenService:Create(
			instance,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{ Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 }
		)

		tween:Play()
		tween.Completed:Wait()
		instance:Destroy()
	end
end

local v2 = 1
local v3 = {}

local v4 = {}

while Soundfonts[v2] do
	local soundfont = Soundfonts[v2]

	if
		soundfont
		and type(soundfont) == "table"
		and soundfont.AssetIds
		and soundfont.Name
		and (next(v3) == nil or v3[soundfont.Name])
	then
		table.insert(v4, { name = tostring(soundfont.Name), ids = soundfont.AssetIds })
	end

	v2 += 1
end

if #v4 == 0 then
	for _, soundfont in pairs(Soundfonts) do
		if not (soundfont and type(soundfont) == "table" and soundfont.AssetIds and soundfont.Name) then
			continue
		end

		if not (next(v3) == nil or v3[soundfont.Name]) then
			continue
		end

		table.insert(v4, { name = tostring(soundfont.Name), ids = soundfont.AssetIds })
	end
end

local v5 = true
local count = #v4

if count == 0 then
	ReplicatedStorage:SetAttribute("SoundfontsPreloaded", true)
	return
end

for _, v6 in ipairs(v4) do
	local name = v6.name
	local ids = v6.ids or {}

	local sounds, v7 = SoundfontManager.BuildSounds(ids, SoundService)
	local preloadSounds, v8 = SoundfontManager.PreloadSounds(v7, nil, 2)

	if sounds and sounds.Parent then
		sounds:Destroy()
	end

	v:showNotification(name, preloadSounds, v8, #ids, false)

	if not preloadSounds then
		v5 = false
	end

	task.wait(0.1)
end

ReplicatedStorage:SetAttribute("SoundfontsPreloaded", true)
v:showNotification(nil, v5, 0, count, true)