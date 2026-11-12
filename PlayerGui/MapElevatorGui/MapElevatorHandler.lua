local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local parent = script.Parent
local overlay = parent:WaitForChild("Overlay")
local main = parent:WaitForChild("Main")
local header = main:WaitForChild("Header")
local close = main:WaitForChild("Close")
local detailed = main:WaitForChild("Detailed")
local compact = main:WaitForChild("Compact")
local detailedMain = main:WaitForChild("DetailedMain")
local compactMain = main:WaitForChild("CompactMain")
local displayMain = detailedMain:WaitForChild("DisplayMain")
local previewShell = displayMain:WaitForChild("PreviewShell")
local pianoPreview = previewShell:WaitForChild("PianoPreview")
local viewportPreview = previewShell:WaitForChild("ViewportPreview")
local previewFallback = previewShell:WaitForChild("PreviewFallback")
local pianoName = displayMain:WaitForChild("PianoName")
local pianoDescription = displayMain:WaitForChild("PianoDescription")
local pianoPlayers = displayMain.PlayersFrame:WaitForChild("PianoPlayers")
local teleportButton = displayMain:WaitForChild("TeleportButton")
local searchBox = detailedMain:WaitForChild("SearchBox")
local detailedScroll = detailedMain:WaitForChild("DetailedScroll")
local uiListLayout = detailedScroll:WaitForChild("UIListLayout")
local searchBox2 = compactMain:WaitForChild("SearchBox")
local compactScroll = compactMain:WaitForChild("CompactScroll")
local compactGrid = compactScroll:WaitForChild("CompactGrid")
local status = main:WaitForChild("Status")
local v = {}
v.overlay = parent:WaitForChild("LoadingOverlay")
v.card = v.overlay:WaitForChild("Card")
v.spinner = v.card:WaitForChild("Spinner")
v.title = v.card:WaitForChild("Title")
v.subtitle = v.card:WaitForChild("Subtitle")
v.dots = {}

for i = 1, 4 do
	local guiObject = v.spinner:FindFirstChild("Dot" .. i)

	if guiObject and guiObject:IsA("GuiObject") then
		table.insert(v.dots, guiObject)
	end
end

local MapElevatorCatalog = require(ReplicatedStorage2:WaitForChild("MapElevatorCatalog"))
local MapLightingProfiles = require(ReplicatedStorage2:WaitForChild("MapLightingProfiles"))
local OpenMapElevator = ReplicatedStorage2:WaitForChild("OpenMapElevator")
local MapElevatorTeleportRequest = ReplicatedStorage2:WaitForChild("MapElevatorTeleportRequest")
local MapElevatorTeleportResult = ReplicatedStorage2:WaitForChild("MapElevatorTeleportResult")
local mapElevatorGetDestinations = ReplicatedStorage2:FindFirstChild("MapElevatorGetDestinations")
	or ReplicatedStorage2:WaitForChild("MapElevatorGetDestinations", 5)

local color = Color3.fromRGB(55, 128, 235)
local color2 = Color3.fromRGB(40, 46, 56)
Color3.fromRGB(50, 58, 70)
Color3.fromRGB(26, 30, 37)
local color3 = Color3.fromRGB(32, 38, 48)
local color4 = Color3.fromRGB(40, 47, 60)
local color5 = Color3.fromRGB(245, 248, 255)
local color6 = Color3.fromRGB(151, 163, 180)
Color3.fromRGB(34, 197, 94)
local color7 = Color3.fromRGB(239, 68, 68)
local tweenInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local flag = false
local visible = true
local v2 = {}
local v3 = nil
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = 0
local v8 = 0
local count = 0
local v9 = nil
local position4 = UDim2.fromScale(0.5, 0.5)
local udim = UDim2.fromOffset(0, 18)
local v10 = false
local position = nil
local position2 = nil
local v11 = nil
local count2 = 0
local v12 = 0
local v13 = false

local function setStatus(value, color8) -- 3 equivalent calls inferred from this helper
	status.Text = tostring(value or "")
	status.TextColor3 = color8 or color6
end

local function showLoading(value, value2)
	v.active = true
	v.title.Text = tostring(value or "Loading destination...")
	v.subtitle.Text = tostring(value2 or "Streaming map assets...")
	v.overlay.Visible = true
	v.card.Position = UDim2.fromScale(0.5, 0.53)
	TweenService:Create(v.card, tweenInfo, { Position = UDim2.fromScale(0.5, 0.5) }):Play()

	local token = {}
	v.token = token
	task.spawn(function()
		while v.active and v.token == token do
			for i, dot in ipairs(v.dots) do
				local v14 = (math.floor(os.clock() * 7) + i) % #v.dots == 0
				dot.BackgroundTransparency = v14 and 0 or 0.55
				dot.Size = UDim2.fromOffset(v14 and 8 or 6, v14 and 8 or 6)
			end

			task.wait(0.12)
		end

		for _, dot in ipairs(v.dots) do
			dot.BackgroundTransparency = 0.55
			dot.Size = UDim2.fromOffset(6, 6)
		end
	end)
end

local function hideLoading()
	v.active = false
	v.token = nil
	v.pendingId = nil
	task.delay(0.08, function()
		if not v.active then
			v.overlay.Visible = false
		end
	end)
end

local function clearContainer(instance)
	for _, guiObject in ipairs(instance:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

local function resolvePath(previewPath)
	if typeof(previewPath) ~= "string" or previewPath == "" then
		return nil
	end

	for _, descendant in ipairs(game:GetDescendants()) do
		if descendant:GetFullName() == previewPath then
			return descendant
		end
	end

	local v14 = game

	for childName in previewPath:gmatch("[^%.]+") do
		if childName == "game" then
			v14 = game
		elseif childName == "Workspace" or childName == "workspace" then
			v14 = workspace
		elseif childName ~= "" then
			v14 = v14 and v14:FindFirstChild(childName)
		end

		if not v14 then
			return nil
		end
	end

	return v14
end

local function stripPreviewClone(folder)
	local descendants = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("ProximityPrompt") or descendant:IsA("Sound") then
			table.insert(descendants, descendant)
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end

	for _, v14 in ipairs(descendants) do
		v14:Destroy()
	end

	if folder:IsA("BasePart") then
		folder.Anchored = true
		folder.CanCollide = false
		folder.CanTouch = false
		folder.CanQuery = false
	end
end

local function getPreviewBounds(instance)
	if instance:IsA("Model") then
		return instance:GetBoundingBox()
	end

	if instance:IsA("BasePart") then
		return instance.CFrame, instance.Size
	end

	local basePart = instance:FindFirstChildWhichIsA("BasePart", true)

	if basePart then
		return basePart.CFrame, basePart.Size
	end

	return nil, nil
end

local function clearPreviewWorld() -- 2 equivalent calls inferred from this helper
	for _, child in ipairs(viewportPreview:GetChildren()) do
		child:Destroy()
	end
end

local function colorOr(p, p2) -- 6 equivalent calls inferred from this helper
	return typeof(p) == "Color3" and p or p2
end

local function applyPreviewLighting(p)
	local v14 = MapLightingProfiles.Get(p and p.id)
	local lighting = v14 and v14.Lighting or {}
	local atmosphere = v14 and v14.Atmosphere or {}
	local colorCorrection = v14 and v14.ColorCorrection or {}
	local ambient = colorOr(lighting.Ambient, colorOr(lighting.OutdoorAmbient, Color3.fromRGB(72, 76, 86))) -- inferred equivalent call
	local v15 = colorOr(colorCorrection.TintColor, colorOr(lighting.ColorShift_Top, Color3.fromRGB(255, 255, 245))) -- inferred equivalent call
	local backgroundColor = colorOr(lighting.FogColor, colorOr(atmosphere.Color, Color3.fromRGB(20, 24, 32))) -- inferred equivalent call
	local brightness = tonumber(lighting.Brightness) or 2

	viewportPreview.Ambient = ambient
	viewportPreview.LightColor = v15:Lerp(Color3.new(1, 1, 1), (math.clamp(0.18 + brightness * 0.04, 0.18, 0.35)))
	viewportPreview.LightDirection = Vector3.new(-0.45, -0.85, -0.35)
	viewportPreview.BackgroundColor3 = backgroundColor
	viewportPreview.BackgroundTransparency = 0
end

local function showViewportPreview(data)
	clearPreviewWorld() -- inferred equivalent call
	applyPreviewLighting(data)
	previewFallback.Visible = false
	local path = resolvePath(data.previewPath or data.sourcePath)

	if path then
		local success, result = pcall(function()
			return path:Clone()
		end)

		if success and result then
			stripPreviewClone(result)
			local previewWorld = Instance.new("WorldModel")
			previewWorld.Name = "PreviewWorld"
			previewWorld.Parent = viewportPreview
			result.Parent = previewWorld
			local v14, v15

			if result:IsA("Model") then
				v14, v15 = result:GetBoundingBox()
			elseif result:IsA("BasePart") then
				v14 = result.CFrame
				v15 = result.Size
			else
				local basePart = result:FindFirstChildWhichIsA("BasePart", true)

				if basePart then
					v14 = basePart.CFrame
					v15 = basePart.Size
				end
			end

			if not (v14 and v15) then
				previewFallback.Visible = true
				return
			end

			if result:IsA("Model") then
				result:PivotTo(CFrame.new(-v14.Position) * result:GetPivot())
			else
				result.CFrame = CFrame.new()
			end

			local _, v16

			if result:IsA("Model") then
				_, v16 = result:GetBoundingBox()
			elseif result:IsA("BasePart") then
				_ = result.CFrame
				v16 = result.Size
			else
				local basePart = result:FindFirstChildWhichIsA("BasePart", true)

				if basePart then
					_ = basePart.CFrame
					v16 = basePart.Size
				end
			end

			local v17 = math.max(v16.X, v16.Y, v16.Z, 8)

			local previewCamera = Instance.new("Camera")
			previewCamera.Name = "PreviewCamera"
			previewCamera.FieldOfView = 36
			previewCamera.CFrame = CFrame.lookAt(
				Vector3.new(v17 * 0.78, v17 * 0.52, v17 * 0.9),
				(Vector3.new(0, math.min(v16.Y * 0.18, 8), 0))
			)
			previewCamera.Parent = viewportPreview
			viewportPreview.CurrentCamera = previewCamera
			viewportPreview.Visible = true
			return
		end
	end

	previewFallback.Visible = true
	viewportPreview.Visible = true
end

local function getServerPlayerCount(p) -- 2 equivalent calls inferred from this helper
	local playerCount = tonumber(p and p.playerCount)

	if playerCount then
		return (math.max(0, (math.floor(playerCount + 0.5))))
	end

	return nil
end

local function getServerPlayerNames(p)
	local playerNames = {}
	local playerNames2 = p and p.playerNames

	if typeof(playerNames2) ~= "table" then
		return playerNames
	end

	for _, playerName in ipairs(playerNames2) do
		if typeof(playerName) == "string" and playerName ~= "" then
			table.insert(playerNames, playerName)
		end
	end

	table.sort(playerNames)
	return playerNames
end

local function playersNearDestination(p)
	local displayNames = {}
	local position3 = p and p.position

	if not position3 then
		return displayNames
	end

	for _, v14 in ipairs(Players:GetPlayers()) do
		local character = v14.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - position3).Magnitude <= 130 then
			table.insert(displayNames, v14.DisplayName or v14.Name)
		end
	end

	table.sort(displayNames)
	return displayNames
end

local function updatePlayerText(p)
	local serverPlayerCount = getServerPlayerCount(p) -- inferred equivalent call

	if serverPlayerCount then
		local serverPlayerNames = getServerPlayerNames(p)

		if serverPlayerCount == 0 then
			pianoPlayers.Text = "Players nearby: none"
		elseif serverPlayerCount <= 3 and #serverPlayerNames == serverPlayerCount then
			pianoPlayers.Text = "Players nearby: " .. table.concat(serverPlayerNames, ", ")
		else
			pianoPlayers.Text = "Players nearby: " .. tostring(serverPlayerCount)
		end
	else
		local v14 = playersNearDestination(p)

		if #v14 == 0 then
			pianoPlayers.Text = "Players nearby: none"
		elseif #v14 <= 3 then
			pianoPlayers.Text = "Players nearby: " .. table.concat(v14, ", ")
		else
			pianoPlayers.Text = "Players nearby: " .. tostring(#v14)
		end
	end
end

local function setSelected(data) -- 1 equivalent call inferred from this helper
	v3 = data

	if data then
		pianoName.Text = data.title or data.name or "Destination"
		pianoDescription.Text = data.description or data.subtitle or "Teleport to this map."
		updatePlayerText(data)

		count2 += 1
		local v14 = count2
		pianoPreview.Visible = false
		previewFallback.Visible = false
		showViewportPreview(data)

		if data.previewImage then
			pianoPreview.Image = data.previewImage
			pianoPreview.Visible = true
			viewportPreview.Visible = false
			task.delay(0.65, function()
				if v14 ~= count2 then
					return
				end

				local v15 = false
				pcall(function()
					v15 = pianoPreview.IsLoaded
				end)

				if not v15 then
					pianoPreview.Visible = false
					viewportPreview.Visible = true
				end
			end)
		end
	else
		pianoName.Text = "Map Elevator"
		pianoDescription.Text = "Select a destination on the right to preview it."
		pianoPlayers.Text = "Players nearby: none"
		pianoPreview.Visible = false
		viewportPreview.Visible = true
		previewFallback.Visible = true
		clearPreviewWorld() -- inferred equivalent call
		applyPreviewLighting(nil)
	end
end

local function queryText() -- 1 equivalent call inferred from this helper
	return tostring((visible and searchBox or searchBox2).Text or ""):lower()
end

local function matchesQuery(data, p): boolean
	if p == "" then
		return true
	end

	return table.concat({
		data.title or "",
		data.name or "",
		data.subtitle or "",
		data.category or ""
	}, " "):lower():find(p, 1, true) ~= nil
end

local function getDestinationById(p) -- 2 equivalent calls inferred from this helper
	for _, v14 in ipairs(v2) do
		if v14.id == p then
			return v14
		end
	end

	return nil
end

local function requestTeleport(data)
	if data then
		local title = tostring(data.title or data.name or "destination")
		v.pendingId = data.id
		setStatus("Teleporting to " .. title .. "...", Color3.fromRGB(120, 210, 255)) -- inferred equivalent call
		showLoading("Loading " .. title, "Streaming the destination before placing you there.")
		MapElevatorTeleportRequest:FireServer(data.id)
		task.delay(12, function()
			if v.active and v.pendingId == data.id then
				v.active = false
				v.token = nil
				v.pendingId = nil
				task.delay(0.08, function()
					if not v.active then
						v.overlay.Visible = false
					end
				end)
				status.Text = tostring("Teleport is taking longer than expected. Try again.")
				status.TextColor3 = color7 or color6
			end
		end)
	else
		status.Text = tostring("Select a destination first.")
		status.TextColor3 = color7 or color6
	end
end

local function styleRow(button, p)
	local color8 = p and Color3.fromRGB(46, 80, 132) or color3
	TweenService:Create(button, tweenInfo, { BackgroundColor3 = color8 }):Play()
end

local function refreshRowSelection()
	for _, v14 in ipairs(v4) do
		styleRow(v14.button, v3 and v14.destination.id == v3.id)
	end

	for _, v14 in ipairs(v5) do
		styleRow(v14.button, v3 and v14.destination.id == v3.id)
	end
end

local function makeDetailedButton(destination, layoutOrder)
	local textButton = Instance.new("TextButton")
	textButton.Name = destination.id
	textButton.LayoutOrder = layoutOrder
	textButton.Size = UDim2.new(1, 0, 0, 58)
	textButton.BackgroundColor3 = color3
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = false
	textButton.Text = ""
	textButton.ZIndex = 7312
	textButton.Parent = detailedScroll
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = textButton

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.BackgroundColor3 = destination.color or color
	accent.BorderSizePixel = 0
	accent.Size = UDim2.new(0, 4, 1, 0)
	accent.ZIndex = 7313
	accent.Parent = textButton
	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 8)
	uiCorner2.Parent = accent

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(14, 8)
	title.Size = UDim2.new(1, -72, 0, 22)
	title.Font = Enum.Font.GothamBold
	title.Text = destination.title or destination.name
	title.TextColor3 = color5
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.ZIndex = 7314
	title.Parent = textButton

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromOffset(14, 31)
	subtitle.Size = UDim2.new(1, -72, 0, 18)
	subtitle.Font = Enum.Font.GothamMedium
	subtitle.Text = destination.category or "Map"
	subtitle.TextColor3 = color6
	subtitle.TextSize = 12
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.ZIndex = 7314
	subtitle.Parent = textButton

	local playerCount = Instance.new("TextLabel")
	playerCount.Name = "PlayerCount"
	playerCount.AnchorPoint = Vector2.new(1, 0.5)
	playerCount.Position = UDim2.new(1, -12, 0.5, 0)
	playerCount.Size = UDim2.fromOffset(46, 24)
	playerCount.BackgroundTransparency = 1
	playerCount.Font = Enum.Font.GothamBold
	playerCount.Text = "0"
	playerCount.TextColor3 = color6
	playerCount.TextSize = 13
	playerCount.TextXAlignment = Enum.TextXAlignment.Right
	playerCount.ZIndex = 7314
	playerCount.Parent = textButton

	textButton.MouseEnter:Connect(function()
		if not v3 or v3.id ~= destination.id then
			TweenService:Create(textButton, tweenInfo, { BackgroundColor3 = color4 }):Play()
		end

		setSelected(destination)
		refreshRowSelection()
	end)
	textButton.Activated:Connect(function()
		setSelected(destination)
		refreshRowSelection()
		requestTeleport(destination)
	end)
	table.insert(v4, { button = textButton, destination = destination, count = playerCount })
end

local function makeCompactButton(destination, layoutOrder)
	local textButton = Instance.new("TextButton")
	textButton.Name = destination.id
	textButton.LayoutOrder = layoutOrder
	textButton.BackgroundColor3 = color3
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = false
	textButton.Text = destination.title or destination.name
	textButton.TextColor3 = color5
	textButton.TextSize = 13
	textButton.Font = Enum.Font.GothamBold
	textButton.TextTruncate = Enum.TextTruncate.AtEnd
	textButton.ZIndex = 7312
	textButton.Parent = compactScroll
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = textButton
	textButton.MouseEnter:Connect(function()
		if not v3 or v3.id ~= destination.id then
			TweenService:Create(textButton, tweenInfo, { BackgroundColor3 = color4 }):Play()
		end

		setSelected(destination)
		refreshRowSelection()
	end)
	textButton.Activated:Connect(function()
		setSelected(destination)
		refreshRowSelection()
		requestTeleport(destination)
	end)
	table.insert(v5, { button = textButton, destination = destination })
end

local function updateCounts()
	for _, v14 in ipairs(v4) do
		local serverPlayerCount = getServerPlayerCount(v14.destination) -- inferred equivalent call
		v14.count.Text = tostring(serverPlayerCount or #playersNearDestination(v14.destination))
	end

	if v3 then
		updatePlayerText(v3)
	end
end

local function updateCanvas() -- 1 equivalent call inferred from this helper
	detailedScroll.CanvasSize = UDim2.fromOffset(0, uiListLayout.AbsoluteContentSize.Y + 20)
	compactScroll.CanvasSize = UDim2.fromOffset(0, compactGrid.AbsoluteContentSize.Y + 20)
end

local function updateCompactGrid()
	local v14 = math.max(1, compactScroll.AbsoluteSize.X - 20)
	local v15 = math.max(1, (math.floor((v14 + 8) / 178)))
	local v16 = math.floor((v14 - (v15 - 1) * 8) / v15)
	compactGrid.CellSize = UDim2.fromOffset(math.max(150, v16), 46)
	updateCanvas() -- inferred equivalent call
end

local function render()
	clearContainer(detailedScroll)
	clearContainer(compactScroll)
	table.clear(v4)
	table.clear(v5)
	local text = queryText() -- inferred equivalent call
	local count3 = 0

	for _, v14 in ipairs(v2) do
		if not matchesQuery(v14, text) then
			continue
		end

		count3 += 1
		makeDetailedButton(v14, count3)
		makeCompactButton(v14, count3)
	end

	if count3 == 0 then
		status.Text = tostring("No destinations match the search.")
		status.TextColor3 = color7 or color6
	else
		setStatus("Loaded " .. tostring(count3) .. " destination" .. (count3 == 1 and "." or "s."), color6) -- inferred equivalent call
	end

	if v3 and matchesQuery(v3, text) or not (count3 > 0) then
		if count3 == 0 then
			setSelected(nil) -- inferred equivalent call
		end
	else
		for _, v14 in ipairs(v2) do
			if matchesQuery(v14, text) then
				setSelected(v14)
				break
			end
		end
	end

	refreshRowSelection()
	updateCounts()
	task.defer(updateCompactGrid)
	task.defer(updateCanvas)
end

local function zoneFromDestination(data)
	if type(data) ~= "table" or data.sourceType ~= "ElevatorFloor" then
		return nil
	end

	local cframe

	if typeof(data.zoneCFrame) == "CFrame" then
		cframe = data.zoneCFrame or nil
	end

	if not cframe and typeof(data.position) == "Vector3" then
		cframe = CFrame.new(data.position)
	end

	if not cframe then
		return nil
	end

	local zoneSize = typeof(data.zoneSize) == "Vector3" and data.zoneSize or Vector3.new(15, 0.1, 15)
	return {
		id = tostring(data.id or data.name or data.sourcePath or "elevator"),
		title = tostring(data.title or data.name or "Map Elevator"),
		sourcePath = tostring(data.sourcePath or ""),
		cframe = cframe,
		size = zoneSize
	}
end

local function rebuildElevatorZones(options)
	v6 = {}

	for _, v14 in ipairs(options or {}) do
		local v15 = zoneFromDestination(v14)

		if v15 then
			table.insert(v6, v15)
		end
	end
end

local function fetchDestinations()
	if mapElevatorGetDestinations and mapElevatorGetDestinations:IsA("RemoteFunction") then
		local success, result = pcall(function()
			return mapElevatorGetDestinations:InvokeServer()
		end)

		if success and typeof(result) == "table" then
			return result
		end
	end

	return MapElevatorCatalog.GetDestinations()
end

local function refreshDestinations(p) -- 1 equivalent call inferred from this helper
	local v14 = fetchDestinations()

	if p and p ~= count then
		return
	end

	local id = v3 and v3.id
	v2 = v14

	if id then
		v3 = getDestinationById(id) -- inferred equivalent call
	end

	rebuildElevatorZones(v2)
	v12 = os.clock()
	render()
end

local function setMode(p)
	visible = p == true
	detailedMain.Visible = visible
	compactMain.Visible = not visible
	detailed.BackgroundColor3 = visible and color or color2
	detailed.TextColor3 = visible and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(203, 213, 225)
	compact.BackgroundColor3 = visible and color2 or color
	compact.TextColor3 = visible and Color3.fromRGB(203, 213, 225) or Color3.fromRGB(255, 255, 255)
	local text = visible and searchBox2.Text or searchBox.Text
	searchBox.Text = text
	searchBox2.Text = text
	render()
end

local function updatePanelSize()
	local currentCamera = workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v14 = math.clamp(viewportSize.X - 44, 620, 860)
	local v15 = math.clamp(viewportSize.Y - 80, 430, 560)
	main.Size = UDim2.fromOffset(v14, v15)
	local v16 = math.clamp(math.floor(v14 * 0.43), 300, 360)
	displayMain.Size = UDim2.new(0, v16, 1, -112)
	searchBox.Position = UDim2.fromOffset(v16 + 34, 60)
	searchBox.Size = UDim2.new(1, -(v16 + 52), 0, 42)
	detailedScroll.Position = UDim2.fromOffset(v16 + 34, 114)
	detailedScroll.Size = UDim2.new(1, -(v16 + 52), 1, -166)
	task.defer(updateCompactGrid)
	task.defer(updateCanvas)
end

local function open()
	updatePanelSize()

	if not flag then
		flag = true
		overlay.Visible = true
		main.Visible = true
		main.Position = position4 + udim
		TweenService:Create(main, tweenInfo, { Position = position4 }):Play()
	end

	count += 1
	local v14 = count

	if #v2 == 0 then
		status.Text = tostring("Loading destinations...")
		status.TextColor3 = color6 or color6
	end

	task.spawn(function()
		refreshDestinations(v14) -- inferred equivalent call
	end)
end

local function close2()
	if not flag then
		return
	end

	flag = false
	v9 = nil
	v7 = os.clock() + 1.5
	position4 = main.Position
	TweenService:Create(main, tweenInfo, {
		Position = position4 + udim
	}):Play()
	task.delay(0.16, function()
		if not flag then
			overlay.Visible = false
			main.Visible = false
		end
	end)
end

local function pointerOutsideMain(input): boolean -- 1 equivalent call inferred from this helper
	if not (input and input.Position) then
		return false
	end

	local position3 = input.Position
	local absolutePosition = main.AbsolutePosition
	local absoluteSize = main.AbsoluteSize
	return position3.X < absolutePosition.X
		or position3.Y < absolutePosition.Y
		or position3.X > absolutePosition.X + absoluteSize.X
		or position3.Y > absolutePosition.Y + absoluteSize.Y
end

local function updateDrag(p)
	if not (v10 and position and position2) then
		return
	end

	local v14 = p.Position - position
	main.Position = UDim2.new(
		position2.X.Scale,
		position2.X.Offset + v14.X,
		position2.Y.Scale,
		position2.Y.Offset + v14.Y
	)

	position4 = main.Position
end

header.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	v10 = true
	position = input.Position
	position2 = main.Position
	input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			v10 = false
		end
	end)
end)

header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		v11 = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == v11 and v10 and position then
		if not position2 then
			return
		end

		local v14 = input.Position - position
		main.Position = UDim2.new(
			position2.X.Scale,
			position2.X.Offset + v14.X,
			position2.Y.Scale,
			position2.Y.Offset + v14.Y
		)

		position4 = main.Position
	end
end)

local function isRootNearZone(humanoidRootPart, p, value)
	if not humanoidRootPart or not p or typeof(p.cframe) ~= "CFrame" or typeof(p.size) ~= "Vector3" then
		return false
	end

	local pointToObjectSpace = p.cframe:PointToObjectSpace(humanoidRootPart.Position)
	local v14 = value or 3
	local v15 = math.abs(pointToObjectSpace.X) <= p.size.X * 0.5 + v14
	local v16 = math.abs(pointToObjectSpace.Z) <= p.size.Z * 0.5 + v14

	if v15 then
		if v16 then
			if pointToObjectSpace.Y > -5 then
				return pointToObjectSpace.Y < 14
			end

			return false
		end
	else
		return v15
	end

	return v16
end

local function openFromElevatorZone(p) -- 1 equivalent call inferred from this helper
	v9 = p
	open()
end

local function maybeOpenFromNearbyElevatorZone()
	if flag or os.clock() < v7 then
		return
	end

	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	for _, v14 in ipairs(v6) do
		if isRootNearZone(humanoidRootPart, v14, 3) then
			v7 = os.clock() + 1
			openFromElevatorZone(v14) -- inferred equivalent call
			break
		end
	end
end

local function updateElevatorAutoClose()
	if not flag or v.active or not v9 then
		return
	end

	local character = LocalPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if isRootNearZone(humanoidRootPart, v9, 4) then
		return
	end

	close2()
end

close.Activated:Connect(close2)
detailed.Activated:Connect(function()
	setMode(true)
end)
compact.Activated:Connect(function()
	setMode(false)
end)
teleportButton.Activated:Connect(function()
	requestTeleport(v3)
end)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	if visible then
		searchBox2.Text = searchBox.Text
		render()
	end
end)
searchBox2:GetPropertyChangedSignal("Text"):Connect(function()
	if not visible then
		searchBox.Text = searchBox2.Text
		render()
	end
end)
uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
compactGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
compactScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCompactGrid)
overlay.InputEnded:Connect(function(input)
	if
		flag
		and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
		and pointerOutsideMain(input) -- inferred equivalent call
	then
		close2()
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not flag then
		return
	end

	if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
		close2()
	end
end)
MapElevatorTeleportResult.OnClientEvent:Connect(function(p, value, p2)
	setStatus(value, p and Color3.fromRGB(88, 214, 141) or color7) -- inferred equivalent call

	if p then
		v7 = os.clock() + 2
		v12 = 0
		local v14 = getDestinationById(p2) or v3 -- inferred equivalent call
		task.spawn(function()
			if v14 and v14.position then
				pcall(function()
					LocalPlayer:RequestStreamAroundAsync(v14.position, 4)
				end)
			end

			task.wait(0.45)
			v.active = false
			v.token = nil
			v.pendingId = nil
			task.delay(0.08, function()
				if not v.active then
					v.overlay.Visible = false
				end
			end)

			close2()
		end)
	else
		v.active = false
		v.token = nil
		v.pendingId = nil
		task.delay(0.08, function()
			if not v.active then
				v.overlay.Visible = false
			end
		end)
	end
end)

local function invalidateDestinationCounts()
	if flag then
		v12 = 0
	end
end
Players.PlayerAdded:Connect(invalidateDestinationCounts)
Players.PlayerRemoving:Connect(invalidateDestinationCounts)

RunService.Heartbeat:Connect(function()
	local now = os.clock()

	if flag and not v13 and now - v12 >= 5 then
		v13 = true
		count += 1
		local v14 = count
		task.spawn(function()
			pcall(refreshDestinations, v14)
			v13 = false
		end)
	end

	if now - v8 >= 0.1 then
		v8 = now
		maybeOpenFromNearbyElevatorZone()
	end

	if flag and not v.active then
		if not v9 then
			return
		end

		local character = LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if isRootNearZone(humanoidRootPart, v9, 4) then
			return
		end

		close2()
	end
end)

OpenMapElevator.Event:Connect(function()
	v9 = nil
	open()
end)
setMode(true)
updatePanelSize()
task.defer(refreshDestinations)

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if flag then
			updatePanelSize()
		end
	end)
end

ClientDebugConfig.Print("[MapElevator] Initialized")