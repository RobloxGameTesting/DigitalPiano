local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local parent = script.Parent
local mainPanel = parent:WaitForChild("MainPanel")
local playerListPanel = parent:WaitForChild("PlayerListPanel")
local serverBrowserTemplates = parent:WaitForChild("ServerBrowserTemplates")

local header = mainPanel:WaitForChild("Header")
local close = header:WaitForChild("Close")
local ghostMode = header:WaitForChild("GhostMode")
local checkbox = ghostMode:WaitForChild("Checkbox")
local checkIcon = checkbox:WaitForChild("CheckIcon")

local searchContainer = mainPanel:WaitForChild("SearchContainer")
local searchBox = searchContainer:WaitForChild("SearchBox")
local sortBtn = searchContainer:WaitForChild("SortBtn")
local textLabel = sortBtn:FindFirstChild("TextLabel")
local sortDropdown = sortBtn:FindFirstChild("SortDropdown")
local arrowLabel = sortBtn:FindFirstChild("ArrowLabel")
local vcToggle = searchContainer:FindFirstChild("VCToggle")
local textLabel2 = vcToggle and vcToggle:FindFirstChild("TextLabel")
local vcIcon = vcToggle and vcToggle:FindFirstChild("VCIcon")
local uiStroke = vcToggle and vcToggle:FindFirstChildWhichIsA("UIStroke")

local columnsHeader = mainPanel:WaitForChild("ColumnsHeader")
local serverList = mainPanel:WaitForChild("ServerList")
local uiListLayout = serverList:FindFirstChildWhichIsA("UIListLayout")
local serverRowTemplate = serverBrowserTemplates:WaitForChild("ServerRowTemplate")

local header2 = playerListPanel:WaitForChild("Header")
local title = header2:WaitForChild("Title")
local close2 = header2:WaitForChild("Close")
local playersScroll = playerListPanel:WaitForChild("PlayersScroll")
local uiListLayout2 = playersScroll:FindFirstChildWhichIsA("UIListLayout")
local playerCardTemplate = serverBrowserTemplates:WaitForChild("PlayerCardTemplate")

local RequestServerBrowserPage = ReplicatedStorage2:WaitForChild("RequestServerBrowserPage")
local SendServerBrowserPageToClient = ReplicatedStorage2:WaitForChild("SendServerBrowserPageToClient")
local RequestPlayerListRemote = ReplicatedStorage2:WaitForChild("RequestPlayerListRemote")
local TeleportPlayerRemote = ReplicatedStorage2:WaitForChild("TeleportPlayerRemote")
local SendServerPingToClient = ReplicatedStorage2:WaitForChild("SendServerPingToClient")
local SendPlayerListToClient = ReplicatedStorage2:WaitForChild("SendPlayerListToClient")
local ToggleHideFromSearch = ReplicatedStorage2:WaitForChild("ToggleHideFromSearch")

local color = Color3.fromRGB(30, 30, 30)
local color2 = Color3.fromRGB(210, 225, 235)
local color3 = Color3.fromRGB(35, 150, 70)
local color4 = Color3.fromRGB(45, 180, 90)
local color5 = Color3.fromRGB(60, 60, 60)
local color6 = Color3.fromRGB(225, 225, 225)
local color7 = Color3.fromRGB(30, 30, 30)
local color8 = Color3.fromRGB(38, 38, 38)
local color9 = Color3.fromRGB(24, 42, 52)
local color10 = Color3.fromRGB(35, 35, 35)
local color11 = Color3.fromRGB(45, 48, 52)
local color12 = Color3.fromRGB(42, 130, 190)
local color13 = Color3.fromRGB(55, 155, 220)
local color14 = Color3.fromRGB(100, 200, 255)
local color15 = Color3.fromRGB(210, 216, 224)
local color16 = Color3.fromRGB(245, 250, 255)

local MaxPlayers = Players.MaxPlayers
local visible = false
local v = false
local v2 = nil
local sortOrder = "Descending"
local voiceOnly = parent:GetAttribute("ServerBrowserVoiceOnly") == true
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}

local cursor = nil
local v12 = true
local flag = false
local count = 0
local lastTime = 0
local count2 = 0
local v13 = 200
local v14 = 0
local v15 = 0
local v16 = nil
local fn

local fn2

local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local serverBrowserStatusRow = Instance.new("TextButton")
serverBrowserStatusRow.Name = "ServerBrowserStatusRow"
serverBrowserStatusRow.Size = UDim2.new(1, -12, 0, 48)
serverBrowserStatusRow.BackgroundColor3 = color
serverBrowserStatusRow.BackgroundTransparency = 0
serverBrowserStatusRow.BorderSizePixel = 0
serverBrowserStatusRow.TextColor3 = color2
serverBrowserStatusRow.TextSize = 14
serverBrowserStatusRow.Font = Enum.Font.GothamMedium
serverBrowserStatusRow.Text = "Loading servers..."
serverBrowserStatusRow.AutoButtonColor = false
serverBrowserStatusRow.Visible = false
serverBrowserStatusRow.LayoutOrder = 1000000
serverBrowserStatusRow.Parent = nil
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = serverBrowserStatusRow
local function setText(instance, value)
	if not instance then
		return
	end

	local text = tostring(value or "")

	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		instance.Text = text
	end

	local textLabel3 = instance:FindFirstChild("TextLabel")

	if textLabel3 and (textLabel3:IsA("TextLabel") or textLabel3:IsA("TextButton") or textLabel3:IsA("TextBox")) then
		textLabel3.Text = text
	end
end

local function playClick() -- 8 equivalent calls inferred from this helper
	local soundFX = ReplicatedStorage2:FindFirstChild("SoundFX")
	local clickSound2 = soundFX and (soundFX:FindFirstChild("ClickSound2") or soundFX:FindFirstChild("ClickSound"))

	if clickSound2 then
		clickSound2:Play()
	end
end

local function getCurrentServerId() -- 2 equivalent calls inferred from this helper
	local serverBrowserCurrentServerId = ReplicatedStorage2:GetAttribute("ServerBrowserCurrentServerId")

	if type(serverBrowserCurrentServerId) == "string" and serverBrowserCurrentServerId ~= "" then
		return serverBrowserCurrentServerId
	end

	return game.JobId ~= "" and game.JobId or "STUDIO-" .. tostring(game.PlaceId)
end

local currentServerId = getCurrentServerId() -- inferred equivalent call
ReplicatedStorage2:GetAttributeChangedSignal("ServerBrowserCurrentServerId"):Connect(function()
	currentServerId = getCurrentServerId() -- inferred equivalent call
end)

local function formatUptime(uptime)
	local v17 = tonumber(uptime) or 0
	local v18 = math.floor(v17 / 86400)
	local v19 = math.floor(v17 % 86400 / 3600)
	local v20 = math.floor(v17 % 3600 / 60)

	if v18 > 0 then
		return string.format("%dd %02dh", v18, v19)
	end

	return string.format("%02dh %02dm", v19, v20)
end

local function displayServerId(value, isPrivateServer, isVoiceOnly) -- 2 equivalent calls inferred from this helper
	local selected = tostring(value or "")

	if #selected > 5 then
		selected = string.sub(selected, -5)
	end

	if isVoiceOnly then
		return "VC-" .. selected
	end

	if isPrivateServer then
		return "PS-" .. selected
	end

	return selected
end

local function updateCanvas(p, uiListLayout3) -- 4 equivalent calls inferred from this helper
	if p and uiListLayout3 then
		p.CanvasSize = UDim2.new(0, 0, 0, uiListLayout3.AbsoluteContentSize.Y + 14)
	end
end

if uiListLayout then
	uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local parent2 = serverList
		local v17 = uiListLayout

		if parent2 then
			if not v17 then
				return
			end

			parent2.CanvasSize = UDim2.new(0, 0, 0, v17.AbsoluteContentSize.Y + 14)
		end
	end)
end

if uiListLayout2 then
	uiListLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local parent2 = playersScroll
		local v17 = uiListLayout2

		if parent2 then
			if not v17 then
				return
			end

			parent2.CanvasSize = UDim2.new(0, 0, 0, v17.AbsoluteContentSize.Y + 14)
		end
	end)
end

local function setHiddenFromSearch(p) -- 1 equivalent call inferred from this helper
	visible = p == true
	checkIcon.Visible = visible
	checkbox.BackgroundColor3 = visible and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(35, 35, 35)
end
local function ensureVoiceBadge(instance)
	local id = instance and instance:FindFirstChild("ID")

	if not id then
		return nil
	end

	id.ClipsDescendants = false

	local vcBadge = id:FindFirstChild("VCBadge")

	if vcBadge and not vcBadge:IsA("ImageLabel") then
		vcBadge:Destroy()
		vcBadge = nil
	end

	if not vcBadge then
		vcBadge = Instance.new("ImageLabel")
		vcBadge.Name = "VCBadge"
		vcBadge.Parent = id
	end

	vcBadge.BackgroundTransparency = 1
	vcBadge.AnchorPoint = Vector2.new(0, 0.5)
	vcBadge.Position = UDim2.new(1, -18, 0.5, 0)
	vcBadge.Size = UDim2.fromOffset(16, 16)
	vcBadge.Image = "rbxassetid://13868441911"
	vcBadge.ImageColor3 = Color3.fromRGB(105, 190, 255)
	vcBadge.ZIndex = id.ZIndex + 1
	return vcBadge
end

local function setVoiceBadge(button, isVoiceOnly) -- 1 equivalent call inferred from this helper
	local voiceBadge = ensureVoiceBadge(button)

	if voiceBadge then
		voiceBadge.Visible = isVoiceOnly == true
	end
end
local function updateVoiceOnlyToggle()
	if not vcToggle then
		return
	end

	vcToggle.BackgroundColor3 = voiceOnly and color12 or color10
	vcToggle:SetAttribute("VoiceOnlyEnabled", voiceOnly)

	if textLabel2 then
		textLabel2.TextColor3 = voiceOnly and color16 or color15
	end

	if vcIcon then
		vcIcon.ImageColor3 = voiceOnly and color16 or Color3.fromRGB(160, 168, 176)
	end

	if uiStroke then
		uiStroke.Color = voiceOnly and Color3.fromRGB(100, 185, 240) or Color3.fromRGB(70, 70, 70)
	end
end

local function setVoiceOnlyFilter(p)
	local v17 = p == true

	if voiceOnly == v17 then
		updateVoiceOnlyToggle()
		return
	end

	voiceOnly = v17
	parent:SetAttribute("ServerBrowserVoiceOnly", voiceOnly)
	updateVoiceOnlyToggle()

	if v then
		fn(true, false)
	end
end

local function disconnectServer(p)
	for _, v17 in ipairs({
		"Join_",
		"Players_",
		"PlayersEnter_",
		"PlayersLeave_",
		"Row_",
		"Hover_",
		"HoverLeave_",
		"RowEnter_",
		"RowLeave_"
	}) do
		local v18 = v17 .. p

		if not v5[v18] then
			continue
		end

		v5[v18]:Disconnect()
		v5[v18] = nil
	end
end

local function clearPlayerList()
	for _, guiObject in ipairs(playersScroll:GetChildren()) do
		if guiObject:IsA("Frame") and guiObject ~= playerCardTemplate then
			guiObject:Destroy()
		elseif guiObject:IsA("TextLabel") then
			guiObject:Destroy()
		end
	end
end

local function fn3()
	local v17 = fn2()
	local v18 = v16 or "wide"
	local v19 = v18 ~= "wide" or v17.X < 1200

	playerListPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	playerListPanel.ZIndex = 80

	for _, guiObject in ipairs(playerListPanel:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = math.max(guiObject.ZIndex, 81)
		end
	end

	if v19 then
		playerListPanel.Size = v18 == "narrow" and UDim2.new(0.88, 0, 0.82, 0) or UDim2.new(0.58, 0, 0.78, 0)
		playerListPanel.Position = UDim2.fromScale(0.5, 0.5)
	else
		local v20 = math.floor((math.clamp(v17.X * 0.24, 320, 390)))
		local v21 = math.floor((math.min(920, v17.X - v20 - 18 - 72)))
		local v22 = v21 + 18 + v20
		local v23 = math.max(24, (v17.X - v22) / 2)
		local v24 = v17.Y / 2

		mainPanel.Size = UDim2.fromOffset(v21, (math.floor(v17.Y * 0.8)))
		mainPanel.Position = UDim2.fromOffset(v23 + v21 / 2, v24)

		playerListPanel.Size = UDim2.fromOffset(v20, (math.floor(v17.Y * 0.78)))
		playerListPanel.Position = UDim2.fromOffset(v23 + v21 + 18 + v20 / 2, v24)
	end

	playerListPanel.Visible = true
end

fn2 = function()
	local success, result = pcall(function()
		return parent.AbsoluteSize
	end)

	if success and result.X > 1 and result.Y > 1 then
		return result
	end

	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

	if viewportSize.X <= 1 or viewportSize.Y <= 1 then
		return Vector2.new(1280, 720)
	end

	return viewportSize
end

local function setColumnObject(p, p2, p3)
	if not p then
		return
	end

	p.Visible = p3 ~= false
	p.Size = UDim2.new(p2, 0, 1, 0)
end

local function setRowObject(instance, childName, p, p2)
	local child = instance and instance:FindFirstChild(childName)

	if not child then
		return
	end

	child.Visible = p2 ~= false
	child.Size = UDim2.new(p, 0, child.Size.Y.Scale, child.Size.Y.Offset)
end

local function applyRowLayout(instance, p)
	if not instance then
		return
	end

	if p == "narrow" then
		local id = instance and instance:FindFirstChild("ID")

		if id then
			id.Visible = true
			id.Size = UDim2.new(0.42, 0, id.Size.Y.Scale, id.Size.Y.Offset)
		end

		local region = instance and instance:FindFirstChild("Region")

		if region then
			region.Visible = false
			region.Size = UDim2.new(0, 0, region.Size.Y.Scale, region.Size.Y.Offset)
		end

		local uptime = instance and instance:FindFirstChild("Uptime")

		if uptime then
			uptime.Visible = false
			uptime.Size = UDim2.new(0, 0, uptime.Size.Y.Scale, uptime.Size.Y.Offset)
		end

		local players = instance and instance:FindFirstChild("Players")

		if players then
			players.Visible = true
			players.Size = UDim2.new(0.24, 0, players.Size.Y.Scale, players.Size.Y.Offset)
		end

		local actionFrame = instance and instance:FindFirstChild("ActionFrame")

		if actionFrame then
			actionFrame.Visible = true
			actionFrame.Size = UDim2.new(0.34, 0, actionFrame.Size.Y.Scale, actionFrame.Size.Y.Offset)
		end

		instance.Size = UDim2.new(1, -8, 0, 48)
	elseif p == "compact" then
		local id = instance and instance:FindFirstChild("ID")

		if id then
			id.Visible = true
			id.Size = UDim2.new(0.25, 0, id.Size.Y.Scale, id.Size.Y.Offset)
		end

		local region = instance and instance:FindFirstChild("Region")

		if region then
			region.Visible = true
			region.Size = UDim2.new(0.33, 0, region.Size.Y.Scale, region.Size.Y.Offset)
		end

		local uptime = instance and instance:FindFirstChild("Uptime")

		if uptime then
			uptime.Visible = false
			uptime.Size = UDim2.new(0, 0, uptime.Size.Y.Scale, uptime.Size.Y.Offset)
		end

		local players = instance and instance:FindFirstChild("Players")

		if players then
			players.Visible = true
			players.Size = UDim2.new(0.18, 0, players.Size.Y.Scale, players.Size.Y.Offset)
		end

		local actionFrame = instance and instance:FindFirstChild("ActionFrame")

		if actionFrame then
			actionFrame.Visible = true
			actionFrame.Size = UDim2.new(0.24, 0, actionFrame.Size.Y.Scale, actionFrame.Size.Y.Offset)
		end

		instance.Size = UDim2.new(1, -10, 0, 52)
	else
		local id = instance and instance:FindFirstChild("ID")

		if id then
			id.Visible = true
			id.Size = UDim2.new(0.23, 0, id.Size.Y.Scale, id.Size.Y.Offset)
		end

		local region = instance and instance:FindFirstChild("Region")

		if region then
			region.Visible = true
			region.Size = UDim2.new(0.27, 0, region.Size.Y.Scale, region.Size.Y.Offset)
		end

		local uptime = instance and instance:FindFirstChild("Uptime")

		if uptime then
			uptime.Visible = true
			uptime.Size = UDim2.new(0.18, 0, uptime.Size.Y.Scale, uptime.Size.Y.Offset)
		end

		local players = instance and instance:FindFirstChild("Players")

		if players then
			players.Visible = true
			players.Size = UDim2.new(0.14, 0, players.Size.Y.Scale, players.Size.Y.Offset)
		end

		local actionFrame = instance and instance:FindFirstChild("ActionFrame")

		if actionFrame then
			actionFrame.Visible = true
			actionFrame.Size = UDim2.new(0.18, 0, actionFrame.Size.Y.Scale, actionFrame.Size.Y.Offset)
		end

		instance.Size = UDim2.new(1, -12, 0, 54)
	end
end

local function applyColumnLayout(p)
	if p == "narrow" then
		local colServerID = columnsHeader:FindFirstChild("ColServerID")

		if colServerID then
			colServerID.Visible = true
			colServerID.Size = UDim2.new(0.42, 0, 1, 0)
		end

		local colRegion = columnsHeader:FindFirstChild("ColRegion")

		if colRegion then
			colRegion.Visible = false
			colRegion.Size = UDim2.new(0, 0, 1, 0)
		end

		local colUptime = columnsHeader:FindFirstChild("ColUptime")

		if colUptime then
			colUptime.Visible = false
			colUptime.Size = UDim2.new(0, 0, 1, 0)
		end

		local colPlayers = columnsHeader:FindFirstChild("ColPlayers")

		if colPlayers then
			colPlayers.Visible = true
			colPlayers.Size = UDim2.new(0.24, 0, 1, 0)
		end

		local colAction = columnsHeader:FindFirstChild("ColAction")

		if colAction then
			colAction.Visible = true
			colAction.Size = UDim2.new(0.34, 0, 1, 0)
		end

		columnsHeader.Size = UDim2.new(1, 0, 0, 20)
	elseif p == "compact" then
		local colServerID = columnsHeader:FindFirstChild("ColServerID")

		if colServerID then
			colServerID.Visible = true
			colServerID.Size = UDim2.new(0.25, 0, 1, 0)
		end

		local colRegion = columnsHeader:FindFirstChild("ColRegion")

		if colRegion then
			colRegion.Visible = true
			colRegion.Size = UDim2.new(0.33, 0, 1, 0)
		end

		local colUptime = columnsHeader:FindFirstChild("ColUptime")

		if colUptime then
			colUptime.Visible = false
			colUptime.Size = UDim2.new(0, 0, 1, 0)
		end

		local colPlayers = columnsHeader:FindFirstChild("ColPlayers")

		if colPlayers then
			colPlayers.Visible = true
			colPlayers.Size = UDim2.new(0.18, 0, 1, 0)
		end

		local colAction = columnsHeader:FindFirstChild("ColAction")

		if colAction then
			colAction.Visible = true
			colAction.Size = UDim2.new(0.24, 0, 1, 0)
		end

		columnsHeader.Size = UDim2.new(1, 0, 0, 20)
	else
		local colServerID = columnsHeader:FindFirstChild("ColServerID")

		if colServerID then
			colServerID.Visible = true
			colServerID.Size = UDim2.new(0.23, 0, 1, 0)
		end

		local colRegion = columnsHeader:FindFirstChild("ColRegion")

		if colRegion then
			colRegion.Visible = true
			colRegion.Size = UDim2.new(0.27, 0, 1, 0)
		end

		local colUptime = columnsHeader:FindFirstChild("ColUptime")

		if colUptime then
			colUptime.Visible = true
			colUptime.Size = UDim2.new(0.18, 0, 1, 0)
		end

		local colPlayers = columnsHeader:FindFirstChild("ColPlayers")

		if colPlayers then
			colPlayers.Visible = true
			colPlayers.Size = UDim2.new(0.14, 0, 1, 0)
		end

		local colAction = columnsHeader:FindFirstChild("ColAction")

		if colAction then
			colAction.Visible = true
			colAction.Size = UDim2.new(0.18, 0, 1, 0)
		end

		columnsHeader.Size = UDim2.new(1, 0, 0, 20)
	end
end

local function applyHeaderLayout(p)
	local title2 = header:FindFirstChild("Title")
	local label = ghostMode:FindFirstChild("Label")

	close.Position = UDim2.new(1, -24, 0.5, -12)
	close.Size = UDim2.fromOffset(24, 24)

	if p == "narrow" then
		if label then
			label.Visible = false
		end

		ghostMode.Size = UDim2.fromOffset(32, 24)
		ghostMode.Position = UDim2.new(1, -68, 0.5, -12)

		if title2 then
			title2.Size = UDim2.new(1, -112, 1, 0)
		end
	else
		if label then
			label.Visible = true
		end

		ghostMode.Size = UDim2.fromOffset(180, 24)
		ghostMode.Position = UDim2.new(1, -220, 0.5, -12)

		if title2 then
			title2.Size = UDim2.new(1, -240, 1, 0)
		end
	end
end

local function applySearchLayout(p)
	local v17 = p == "narrow"
	local v18 = p == "compact"
	local v19 = v17 and 100 or v18 and 118 or 140
	local v20 = v17 and 36 or v18 and 78 or 86
	local v21 = v17 and 6 or 8
	local v22 = 10
	local v23 = v19 + v20 + (v17 and 74 or v18 and 90 or 104)

	searchContainer.Size = UDim2.new(1, 0, 0, v17 and 38 or 40)
	searchBox.Position = UDim2.new(0, 40, 0, 0)
	searchBox.Size = UDim2.new(1, -v23, 1, 0)
	searchBox.PlaceholderText = v17 and "Search..." or "Search by Region, Server ID, or Player..."

	sortBtn.Size = UDim2.new(0, v19, 0, 30)
	sortBtn.Position = UDim2.new(1, -v19 - v22, 0.5, -15)

	if vcToggle then
		vcToggle.Visible = true
		vcToggle.Size = UDim2.new(0, v20, 0, 30)
		vcToggle.Position = UDim2.new(1, -v19 - v22 - v21 - v20, 0.5, -15)

		if textLabel2 then
			textLabel2.Visible = not v17
			textLabel2.Size = UDim2.new(1, -26, 1, 0)
			textLabel2.Position = UDim2.fromOffset(26, 0)
		end

		if vcIcon then
			vcIcon.Size = UDim2.fromOffset(16, 16)
			vcIcon.AnchorPoint = Vector2.new(0, 0.5)
			vcIcon.Position = v17 and UDim2.new(0.5, -8, 0.5, 0) or UDim2.new(0, 7, 0.5, 0)
		end
	end
end

local function fn4()
	local v17 = fn2()
	local x = v17.X
	local y = v17.Y

	local v18 = (x < 680 or x < y and x < 760) and "narrow" or (y <= 430 or x < 980) and "compact" or "wide"

	v16 = v18
	parent:SetAttribute("ServerBrowserResponsiveMode", v18)

	mainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	mainPanel.Position = UDim2.fromScale(0.5, 0.5)

	if v18 == "narrow" then
		mainPanel.Size = UDim2.new(0.94, 0, 0.86, 0)
	elseif v18 == "compact" then
		mainPanel.Size = UDim2.new(0.92, 0, 0.84, 0)
	else
		mainPanel.Size = UDim2.new(0.72, 0, 0.8, 0)
	end

	applyHeaderLayout(v18)
	applySearchLayout(v18)
	applyColumnLayout(v18)
	applyRowLayout(serverRowTemplate, v18)

	for _, v19 in pairs(v4) do
		applyRowLayout(v19, v18)
	end

	serverBrowserStatusRow.Size = UDim2.new(1, v18 == "narrow" and -8 or -12, 0, v18 == "narrow" and 46 or 50)

	if playerListPanel.Visible then
		fn3()
	end

	updateCanvas(serverList, uiListLayout) -- inferred equivalent call
	local parent2 = playersScroll
	local v19 = uiListLayout2

	if parent2 then
		if not v19 then
			return
		end

		parent2.CanvasSize = UDim2.new(0, 0, 0, v19.AbsoluteContentSize.Y + 14)
	end
end

local function hidePlayerList() -- 4 equivalent calls inferred from this helper
	playerListPanel.Visible = false

	if v and fn4 then
		fn4()
	end
end

local function requestPlayerList(serverId): boolean
	if v8[serverId] then
		return false
	end

	v8[serverId] = true
	local v17 = v3[serverId]
	RequestPlayerListRemote:FireServer({
		serverId = serverId,
		playerCount = v17 and v17.playerCount or nil
	})

	task.delay(2.5, function()
		v8[serverId] = nil
	end)
	return true
end

local function getCachedPlayerList(p) -- 1 equivalent call inferred from this helper
	local v17 = v3[p]

	if v17 and v17.playerListTimestamp and os.clock() - v17.playerListTimestamp < 8 then
		return v17.playerList or {}
	end

	return nil
end

local function getAvatarImageObjects(instance)
	local avatar = instance:FindFirstChild("Avatar")

	if not avatar then
		return nil, nil, nil
	end

	avatar.ClipsDescendants = true

	local avatarImage = avatar:FindFirstChild("AvatarImage")

	if avatarImage and not avatarImage:IsA("ImageLabel") then
		avatarImage:Destroy()
		avatarImage = nil
	end

	if not avatarImage then
		avatarImage = Instance.new("ImageLabel")
		avatarImage.Name = "AvatarImage"
		avatarImage.Parent = avatar

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(1, 0)
		uiCorner2.Parent = avatarImage
	end

	avatarImage.BackgroundTransparency = 1
	avatarImage.Size = UDim2.fromScale(1, 1)
	avatarImage.Position = UDim2.fromScale(0, 0)
	avatarImage.ScaleType = Enum.ScaleType.Crop
	avatarImage.ZIndex = avatar.ZIndex + 1

	local initial = avatar:FindFirstChild("Initial")

	if initial and not initial:IsA("TextLabel") then
		initial:Destroy()
		initial = nil
	end

	if not initial then
		initial = Instance.new("TextLabel")
		initial.Name = "Initial"
		initial.Parent = avatar
	end

	initial.BackgroundTransparency = 1
	initial.Size = UDim2.fromScale(1, 1)
	initial.Font = Enum.Font.GothamBold
	initial.TextScaled = true
	initial.TextColor3 = Color3.fromRGB(235, 245, 250)
	initial.ZIndex = avatar.ZIndex + 2

	return avatar, avatarImage, initial
end

local function applyAvatarThumbnail(data, value) -- 1 equivalent call inferred from this helper
	local _card = data.card
	local avatarImage = data.avatarImage
	local initial = data.initial

	if not (avatarImage and avatarImage.Parent) then
		return
	end

	local image = value or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	avatarImage.Image = image
	avatarImage.Visible = true

	if initial then
		initial.Visible = image == "rbxasset://textures/ui/GuiImagePlaceholder.png"
	end
end

local function finishAvatarRequest(p, value) -- 1 equivalent call inferred from this helper
	local v17 = v11[p]
	v11[p] = nil

	if not v17 then
		return
	end

	for _, v18 in ipairs(v17) do
		local _card = v18.card
		local avatarImage = v18.avatarImage
		local initial = v18.initial

		if not (avatarImage and avatarImage.Parent) then
			continue
		end

		local image = value or "rbxasset://textures/ui/GuiImagePlaceholder.png"
		avatarImage.Image = image
		avatarImage.Visible = true

		if initial then
			initial.Visible = image == "rbxasset://textures/ui/GuiImagePlaceholder.png"
		end
	end
end

local function requestAvatarThumbnail(userId) -- 1 equivalent call inferred from this helper
	local v17 = tonumber(userId)

	if v17 and not (v17 <= 0 or v9[v17] or v10[v17]) then
		v10[v17] = true
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetUserThumbnailAsync(v17, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)

			local v18 = (not success or type(result) ~= "string" or result == "")
				and "rbxasset://textures/ui/GuiImagePlaceholder.png"
				or result

			v9[v17] = v18
			v10[v17] = nil
			finishAvatarRequest(v17, v18) -- inferred equivalent call
		end)
	end
end

local function setPlayerAvatar(clone, cachedPlayer, displayName, name)
	local _, avatarImage2, initial2 = getAvatarImageObjects(clone)

	if not avatarImage2 then
		return
	end

	local v17 = tostring(displayName or "")
	local v18 = tostring(name or "")
	v18 = v17 ~= "" and v17 or v18
	initial2.Text = string.upper((string.sub(v18, 1, 1)))

	local userId = tonumber(cachedPlayer.UserId or cachedPlayer.userId or cachedPlayer[3])
	local v19 = { card = clone, avatarImage = avatarImage2, initial = initial2 }

	if userId and not (userId <= 0) then
		local v20 = v9[userId]

		if v20 then
			local _card = v19.card
			local avatarImage = v19.avatarImage
			local initial = v19.initial

			if avatarImage then
				if not avatarImage.Parent then
					return
				end

				local image = v20 or "rbxasset://textures/ui/GuiImagePlaceholder.png"
				avatarImage.Image = image
				avatarImage.Visible = true

				if initial then
					initial.Visible = image == "rbxasset://textures/ui/GuiImagePlaceholder.png"
				end
			end
		else
			applyAvatarThumbnail(v19, "rbxasset://textures/ui/GuiImagePlaceholder.png") -- inferred equivalent call
			v11[userId] = v11[userId] or {}
			table.insert(v11[userId], v19)
			requestAvatarThumbnail(userId) -- inferred equivalent call
		end
	else
		local v20 = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		local _card = v19.card
		local avatarImage = v19.avatarImage
		local initial = v19.initial

		if avatarImage then
			if not avatarImage.Parent then
				return
			end

			local image = v20 or "rbxasset://textures/ui/GuiImagePlaceholder.png"
			avatarImage.Image = image
			avatarImage.Visible = true

			if initial then
				initial.Visible = image == "rbxasset://textures/ui/GuiImagePlaceholder.png"
			end
		end
	end
end

local function makeEmptyPlayerMessage(_) end

local function populatePlayerList(serverId, p)
	if v2 ~= serverId then
		return
	end

	local cachedPlayerList = getCachedPlayerList(serverId) -- inferred equivalent call

	if cachedPlayerList then
		clearPlayerList()
		local count3 = 0

		for _, cachedPlayer in ipairs(cachedPlayerList) do
			if
				type(cachedPlayer) ~= "table"
				or cachedPlayer.isHiddenFromSearch
				or not (cachedPlayer.Name ~= LocalPlayer.Name or not visible)
			then
				continue
			end

			count3 += 1
			local clone = playerCardTemplate:Clone()
			clone.Name = "PlayerCard_" .. tostring(cachedPlayer.UserId or count3)
			clone.Visible = true
			clone.LayoutOrder = count3
			local name = tostring(cachedPlayer.Name or "unknown")
			local displayName = tostring(cachedPlayer.DisplayName or name)
			setText(clone:FindFirstChild("NameLabel"), string.format("%s (@%s)", displayName, name))
			setPlayerAvatar(clone, cachedPlayer, displayName, name)
			local friendIcon = clone:FindFirstChild("FriendIcon")

			if friendIcon then
				friendIcon.Visible = false
			end

			clone.Parent = playersScroll
		end

		updateCanvas(playersScroll, uiListLayout2) -- inferred equivalent call
		fn3()

		if p then
			requestPlayerList(serverId)
		end
	else
		clearPlayerList()

		fn3()
		requestPlayerList(serverId)
	end
end

local function togglePlayerList(serverId)
	local now = os.clock()

	if now - v14 < 0.25 then
		return
	end

	v14 = now

	if playerListPanel.Visible and v2 == serverId then
		hidePlayerList() -- inferred equivalent call
		v2 = nil
	else
		v2 = serverId
		local v17 = v3[serverId] or {}
		title.Text = "Server " .. displayServerId(serverId, v17.isPrivateServer, v17.isVoiceOnly) .. " Players" -- inferred equivalent call
		populatePlayerList(serverId, true)
	end
end

local function appendRenderOrder(value) -- 1 equivalent call inferred from this helper
	if v7[value] then
		return
	end

	v7[value] = true
	table.insert(v6, value)
end

local function setFrameOrder(p, p2)
	if p2 == currentServerId then
		p.LayoutOrder = -1
		return
	end

	for i, v17 in ipairs(v6) do
		if v17 == p2 then
			p.LayoutOrder = i
			break
		end
	end
end

local function setJoinState(button, value, p)
	local actionFrame = button:FindFirstChild("ActionFrame")
	local joinBtn = actionFrame and actionFrame:FindFirstChild("JoinBtn")

	if not joinBtn then
		return
	end

	if p then
		joinBtn.BackgroundColor3 = color5
		joinBtn.AutoButtonColor = false
		setText(joinBtn, "Current")
	else
		joinBtn.BackgroundColor3 = color3
		joinBtn.AutoButtonColor = true
		setText(joinBtn, "Join")
		v5["Join_" .. value] = joinBtn.MouseButton1Click:Connect(function()
			playClick() -- inferred equivalent call
			TeleportPlayerRemote:FireServer(value)
		end)
		local size = joinBtn.Size
		v5["Hover_" .. value] = joinBtn.MouseEnter:Connect(function()
			TweenService:Create(joinBtn, tweenInfo, {
				BackgroundColor3 = color4,
				Size = UDim2.new(size.X.Scale, size.X.Offset + 4, size.Y.Scale, size.Y.Offset + 2)
			}):Play()
		end)
		v5["HoverLeave_" .. value] = joinBtn.MouseLeave:Connect(function()
			TweenService:Create(joinBtn, tweenInfo, { BackgroundColor3 = color3, Size = size }):Play()
		end)
	end

	joinBtn.Active = not p

	local textLabel3 = joinBtn:FindFirstChild("TextLabel")

	if textLabel3 then
		textLabel3.TextColor3 = p and color6 or Color3.new(1, 1, 1)
	end
end

local function createOrUpdateServerFrame(value, p, value2, p2, value3, p3, playerList, p4, p5)
	if type(value) ~= "string" or value == "" then
		return
	end

	local playerCount2 = tonumber(p) or 0
	local maxPlayers = tonumber(p4) or MaxPlayers

	if playerCount2 <= 0 and value ~= currentServerId and p5 ~= true then
		local v17 = v4[value]

		if v17 then
			v17:Destroy()
		end

		disconnectServer(value)
		v4[value] = nil
		v3[value] = nil
	else
		local button = v4[value]

		if not button then
			button = serverRowTemplate:Clone()
			button.Name = "Server_" .. value
			button.Visible = true
			button.Parent = serverList
			applyRowLayout(button, v16 or "wide")
			v4[value] = button
			appendRenderOrder(value) -- inferred equivalent call
		end

		local now = os.clock()
		local v17 = v3[value] or {}
		local playerCount = tonumber(v17.playerCount)
		local v18 = (type)(playerList) == "table"
		local v19

		if playerCount == nil then
			v19 = false
		else
			v19 = playerCount ~= playerCount2
		end

		v17.playerCount = playerCount2
		v17.maxPlayers = maxPlayers
		v17.serverRegion = value2 or "Unknown"
		v17.isPrivateServer = p2 == true
		v17.isVoiceOnly = p5 == true
		v17.serverFlag = value3 or ""
		v17.uptime = tonumber(p3) or 0

		if v18 then
			v17.playerList = playerList
			v17.playerListTimestamp = now
		elseif v19 then
			v17.playerListTimestamp = nil
		end

		v17.timestamp = now
		v3[value] = v17

		if v2 == value and playerListPanel.Visible then
			if v18 then
				task.defer(function()
					if v2 == value and playerListPanel.Visible then
						populatePlayerList(value, false)
					end
				end)
			elseif v19 then
				requestPlayerList(value)
			end
		end

		local enabled = value == currentServerId
		button.BackgroundColor3 = enabled and color9 or color7
		local v20 = button

		if value == currentServerId then
			v20.LayoutOrder = -1
		else
			for i, v21 in ipairs(v6) do
				if v21 == value then
					v20.LayoutOrder = i
					break
				end
			end
		end

		setText(button:FindFirstChild("ID"), displayServerId(value, v17.isPrivateServer, v17.isVoiceOnly)) -- inferred equivalent call
		setText(
			button:FindFirstChild("Region"),
			(v17.serverRegion == "" and "Unknown" or v17.serverRegion or "Unknown") .. (v17.serverFlag == "" and "" or " " .. v17.serverFlag or "")
		)
		setText(button:FindFirstChild("Uptime"), formatUptime(v17.uptime))
		setText(button:FindFirstChild("Players"), tostring(playerCount2) .. "/" .. tostring(maxPlayers))
		setVoiceBadge(button, v17.isVoiceOnly) -- inferred equivalent call

		local currentServerStroke = button:FindFirstChild("CurrentServerStroke")

		if currentServerStroke and currentServerStroke:IsA("UIStroke") then
			currentServerStroke.Enabled = enabled
			currentServerStroke.Transparency = enabled and 0 or 1
		end

		disconnectServer(value)
		setJoinState(button, value, enabled)

		local players = button:FindFirstChild("Players")
		local playersHoverArea = players and players:FindFirstChild("PlayersHoverArea")

		if playersHoverArea and playersHoverArea:IsA("TextButton") then
			local textColor3 = players.TextColor3
			local v21 = false
			v5["Players_" .. value] = playersHoverArea.MouseButton1Click:Connect(function()
				playClick() -- inferred equivalent call
				togglePlayerList(value)
			end)
			v5["PlayersEnter_" .. value] = playersHoverArea.MouseEnter:Connect(function()
				v21 = true

				if v4[value] == button then
					TweenService:Create(players, tweenInfo, { TextColor3 = color14 }):Play()
				end
			end)
			v5["PlayersLeave_" .. value] = playersHoverArea.MouseLeave:Connect(function()
				v21 = false

				if v4[value] == button then
					TweenService:Create(players, tweenInfo, { TextColor3 = textColor3 }):Play()
					task.delay(tweenInfo.Time + 0.02, function()
						if not v21 and v4[value] == button then
							players.TextColor3 = textColor3
						end
					end)
				end
			end)
		elseif button:IsA("TextButton") then
			v5["Row_" .. value] = button.MouseButton1Click:Connect(function()
				playClick() -- inferred equivalent call
				togglePlayerList(value)
			end)
		end

		if button:IsA("GuiButton") then
			v5["RowEnter_" .. value] = button.MouseEnter:Connect(function()
				if v4[value] == button and value ~= currentServerId then
					TweenService:Create(button, tweenInfo, { BackgroundColor3 = color8 }):Play()
				end
			end)
			v5["RowLeave_" .. value] = button.MouseLeave:Connect(function()
				if v4[value] == button then
					TweenService:Create(button, tweenInfo, {
						BackgroundColor3 = value == currentServerId and color9 or color7
					}):Play()
				end
			end)
		end
	end
end

local function clearServerRows()
	for k, v17 in pairs(v4) do
		disconnectServer(k)

		if v17 then
			v17:Destroy()
		end
	end

	v4 = {}
	v3 = {}
	v6 = {}
	v7 = {}
	v2 = nil
	hidePlayerList() -- inferred equivalent call
end

local function updateStatus() -- 8 equivalent calls inferred from this helper
	serverBrowserStatusRow.Visible = false
	serverBrowserStatusRow.AutoButtonColor = false
	serverBrowserStatusRow.Text = ""
end

fn = function(p, p2)
	local reset = p == true

	if flag and not reset then
		return
	end

	if reset or v12 then
		if not reset then
			local v17 = #v6

			if v13 <= v17 then
				if p2 and #v6 < 500 then
					v13 = math.min(500, v13 + 40)
				else
					updateStatus() -- inferred equivalent call
					return
				end
			end
		end

		if reset then
			clearServerRows()
			cursor = nil
			v12 = true
			v13 = 200
		end

		flag = true
		count += 1
		local requestId = count
		local v17 = {
			requestId = requestId,
			reset = reset,
			pageSize = 40,
			cursor = cursor,
			sortOrder = sortOrder,
			query = searchBox.Text,
			voiceOnly = voiceOnly
		}
		updateStatus() -- inferred equivalent call
		local v18 = math.max(0, 0.55 - (os.clock() - lastTime))
		local function fireRequest() -- 1 equivalent call inferred from this helper
			if count ~= requestId or not v then
				return
			end

			lastTime = os.clock()
			RequestServerBrowserPage:FireServer(v17)
		end

		if v18 > 0 then
			task.delay(v18, fireRequest)
		else
			fireRequest() -- inferred equivalent call
		end

		task.delay(v18 + 8, function()
			if flag and count == requestId then
				flag = false
				updateStatus() -- inferred equivalent call
			end
		end)
	else
		updateStatus() -- inferred equivalent call
	end
end

local function fn5()
	if not v or flag or not v12 then
		return
	end

	local y = serverList.AbsoluteWindowSize.Y

	if y <= 0 then
		y = serverList.AbsoluteSize.Y
	end

	if serverList.AbsoluteCanvasSize.Y - (serverList.CanvasPosition.Y + y) > 160 then
		return
	end

	local v17 = #v6
	local v18 = v13 <= v17

	if not (v18 and #v6 >= 500) then
		fn(false, v18)
		return
	end

	updateStatus() -- inferred equivalent call
end

local function setOpen(p)
	local visible2 = p == true

	if v == visible2 then
		return
	end

	v = visible2
	parent:SetAttribute("ServerBrowserOpen", visible2)
	mainPanel.Visible = visible2
	fn4()

	if visible2 then
		fn(true, false)
		return
	end

	count += 1
	flag = false
	hidePlayerList() -- inferred equivalent call
	v2 = nil

	if sortDropdown then
		sortDropdown.Visible = false
	end
end

local function toggleOpen()
	local now = os.clock()

	if now - v15 < 0.25 then
		return
	end

	v15 = now
	setOpen(not v)
end

local function updateSortDisplay() -- 2 equivalent calls inferred from this helper
	updateVoiceOnlyToggle()

	if textLabel then
		textLabel.Text = "Sort: " .. sortOrder
	else
		sortBtn.Text = "Sort: " .. sortOrder
	end

	if arrowLabel then
		arrowLabel.Rotation = sortOrder == "Ascending" and 180 or 0
	end
end

local function setSort(p) -- 2 equivalent calls inferred from this helper
	local v17 = p == "Ascending" and "Ascending" or "Descending"

	if sortOrder == v17 then
		return
	end

	sortOrder = v17
	updateSortDisplay() -- inferred equivalent call

	if v then
		fn(true, false)
	end
end

local function hookPianoButton()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 15)

	if not playerGui then
		return
	end

	local pianoUI = playerGui:WaitForChild("PianoUI", 15)
	local menuOptions = pianoUI and pianoUI:WaitForChild("MenuOptions", 10)
	local buttons = menuOptions and menuOptions:WaitForChild("Buttons", 10)
	local serverList2 = buttons and buttons:WaitForChild("ServerList", 10)

	if serverList2 and serverList2:IsA("TextButton") then
		serverList2.MouseButton1Click:Connect(toggleOpen)
	else
		ClientDebugConfig.Warn("[ServerBrowser] PianoUI MenuOptions Buttons ServerList button was not found.")
	end
end

local function connectCloseButton(close3, fn6)
	close3.MouseButton1Click:Connect(function()
		playClick() -- inferred equivalent call
		fn6()
	end)
	local textLabel3 = close3:FindFirstChild("TextLabel")

	if textLabel3 then
		close3.MouseEnter:Connect(function()
			TweenService:Create(textLabel3, tweenInfo, {
				Rotation = 90,
				TextColor3 = Color3.fromRGB(255, 100, 100)
			}):Play()
		end)
		close3.MouseLeave:Connect(function()
			TweenService:Create(textLabel3, tweenInfo, {
				Rotation = 0,
				TextColor3 = Color3.fromRGB(150, 150, 150)
			}):Play()
		end)
	end
end

mainPanel.Visible = false
playerListPanel.Visible = false

if sortDropdown then
	sortDropdown.Visible = false
end

updateSortDisplay()
setHiddenFromSearch(false)
updateCanvas(serverList, uiListLayout)
updateCanvas(playersScroll, uiListLayout2)

task.spawn(hookPianoButton)
connectCloseButton(close, function()
	setOpen(false)
end)
connectCloseButton(close2, function()
	hidePlayerList() -- inferred equivalent call
	v2 = nil
end)

parent:GetAttributeChangedSignal("ServerBrowserOpen"):Connect(function()
	setOpen(parent:GetAttribute("ServerBrowserOpen") == true)
end)

serverBrowserStatusRow.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	if v12 and #v6 < 500 then
		fn(false, true)
	elseif #v6 == 0 then
		fn(true, true)
	end
end)

serverList:GetPropertyChangedSignal("CanvasPosition"):Connect(fn5)
serverList:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
	updateCanvas(serverList, uiListLayout) -- inferred equivalent call
	task.defer(fn5)
end)

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		task.defer(fn4)
	end)
end

playersScroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
	local parent2 = playersScroll
	local v17 = uiListLayout2

	if parent2 then
		if not v17 then
			return
		end

		parent2.CanvasSize = UDim2.new(0, 0, 0, v17.AbsoluteContentSize.Y + 14)
	end
end)

checkbox.MouseButton1Click:Connect(function()
	playClick() -- inferred equivalent call
	visible = not visible == true
	checkIcon.Visible = visible
	checkbox.BackgroundColor3 = visible and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(35, 35, 35)

	ToggleHideFromSearch:FireServer(visible)

	if v2 then
		requestPlayerList(v2)
	end

	task.delay(0.75, function()
		if v then
			fn(true, false)
		end
	end)
end)

ToggleHideFromSearch.OnClientEvent:Connect(function(p)
	setHiddenFromSearch(p == true) -- inferred equivalent call
end)

sortBtn.MouseButton1Click:Connect(function()
	playClick() -- inferred equivalent call

	if sortDropdown then
		sortDropdown.Visible = not sortDropdown.Visible
		return
	end

	local v17 = (sortOrder == "Descending" and "Ascending" or "Descending") == "Ascending" and "Ascending"
		or "Descending"

	if sortOrder == v17 then
		return
	end

	sortOrder = v17
	updateSortDisplay() -- inferred equivalent call

	if v then
		fn(true, false)
	end
end)

if vcToggle then
	vcToggle.MouseButton1Click:Connect(function()
		playClick() -- inferred equivalent call

		if sortDropdown then
			sortDropdown.Visible = false
		end

		local v17 = not voiceOnly == true

		if voiceOnly == v17 then
			updateVoiceOnlyToggle()
			return
		end

		voiceOnly = v17
		parent:SetAttribute("ServerBrowserVoiceOnly", voiceOnly)
		updateVoiceOnlyToggle()

		if v then
			fn(true, false)
		end
	end)
	vcToggle.MouseEnter:Connect(function()
		TweenService:Create(vcToggle, tweenInfo, {
			BackgroundColor3 = voiceOnly and color13 or color11
		}):Play()
	end)
	vcToggle.MouseLeave:Connect(function()
		TweenService:Create(vcToggle, tweenInfo, {
			BackgroundColor3 = voiceOnly and color12 or color10
		}):Play()
	end)
end

if sortDropdown then
	for _, button in ipairs(sortDropdown:GetChildren()) do
		if button:IsA("TextButton") then
			button.MouseButton1Click:Connect(function()
				playClick() -- inferred equivalent call
				local textLabel3 = button:FindFirstChild("TextLabel")
				local text = textLabel3 and textLabel3.Text or button.Text

				if string.find(string.lower(text), "asc", 1, true) then
					setSort("Ascending") -- inferred equivalent call
				else
					setSort("Descending") -- inferred equivalent call
				end

				sortDropdown.Visible = false
			end)
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	count2 += 1
	local v17 = count2
	task.delay(0.35, function()
		if v17 == count2 and v then
			fn(true, false)
		end
	end)
end)

SendServerBrowserPageToClient.OnClientEvent:Connect(function(data)
	if not (type(data) == "table" and data.requestId == count) then
		return
	end

	if (data.voiceOnly == true) == voiceOnly then
		flag = false
		cursor = data.cursor
		v12 = data.hasMore == true

		if data.reset == true then
			clearServerRows()
		end

		local servers = type(data.servers) == "table" and data.servers or {}

		for _, server in ipairs(servers) do
			if type(server) == "table" then
				createOrUpdateServerFrame(
					server.serverId,
					server.playerCount,
					server.serverRegion,
					server.isPrivateServer,
					server.serverFlag,
					server.uptime,
					nil,
					server.maxPlayers,
					server.isVoiceOnly
				)
			end
		end

		updateStatus() -- inferred equivalent call
		updateCanvas(serverList, uiListLayout) -- inferred equivalent call
		task.defer(fn5)
	else
		flag = false
		updateStatus() -- inferred equivalent call

		if v then
			task.defer(function()
				fn(true, false)
			end)
		end
	end
end)

SendPlayerListToClient.OnClientEvent:Connect(function(p, p2)
	if not v3[p] then
		v3[p] = {}
	end

	v3[p].playerList = type(p2) == "table" and p2 or {}
	v3[p].playerListTimestamp = os.clock()
	populatePlayerList(p)
end)

SendServerPingToClient.OnClientEvent:Connect(function(p, p2, p3, p4, p5, p6, playerList, p7, p8)
	if (p8 == true) == voiceOnly then
		if p == currentServerId or v4[p] then
			createOrUpdateServerFrame(p, p2, p3, p4, p5, p6, playerList, p7 or MaxPlayers, p8)
		end
	else
		local v17 = v4[p]

		if v17 then
			v17:Destroy()
			disconnectServer(p)
			v4[p] = nil
			v3[p] = nil

			for i = #v6, 1, -1 do
				if v6[i] == p then
					table.remove(v6, i)
					break
				end
			end

			v7[p] = nil
			updateStatus() -- inferred equivalent call
			local parent2 = serverList
			local v18 = uiListLayout

			if parent2 then
				if not v18 then
					return
				end

				parent2.CanvasSize = UDim2.new(0, 0, 0, v18.AbsoluteContentSize.Y + 14)
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape and v then
		setOpen(false)
	end
end)

if parent:GetAttribute("ServerBrowserOpen") == true then
	task.defer(function()
		setOpen(true)
	end)
end