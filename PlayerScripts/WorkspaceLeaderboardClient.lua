local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local WorkspaceLeaderboardTabOverlay = PlayerGui:FindFirstChild("WorkspaceLeaderboardTabOverlay")

if WorkspaceLeaderboardTabOverlay then
	WorkspaceLeaderboardTabOverlay:Destroy()
end

local Piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 30)

if not Piano_Dependencies then
	ClientDebugConfig.Warn("[WorkspaceLeaderboardClient] Workspace.Piano_Dependencies did not load")
	return
end

local Remotes = Piano_Dependencies:WaitForChild("Remotes", 30)

if not Remotes then
	ClientDebugConfig.Warn("[WorkspaceLeaderboardClient] Workspace.Piano_Dependencies.Remotes did not load")
	return
end

local GetWorkspaceLeaderboardData = Remotes:WaitForChild("GetWorkspaceLeaderboardData", 30)

if not GetWorkspaceLeaderboardData then
	ClientDebugConfig.Warn("[WorkspaceLeaderboardClient] GetWorkspaceLeaderboardData remote did not load")
	return
end

local v = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"HumanoidRootPart",
	"LeftUpperArm",
	"RightUpperArm",
	"LeftUpperLeg",
	"RightUpperLeg"
}

local v2 = { Floater = true }

local v3 = {
	{ Key = "Weekly", Label = "WEEKLY" },
	{ Key = "Monthly", Label = "MONTHLY" },
	{ Key = "AllTime", Label = "ALL TIME" }
}

local v4 = {
	{
		ModelName = "NotesPlayedLeaderboardUpdate",
		Category = "TopNotes",
		Title = "Most Notes Played",
		HeaderTitle = "Top 50 Notes Played",
		AvatarLabel = "TOP 1 Notes Played",
		ValueHeader = "Notes"
	},
	{
		ModelName = "TimePlayedLeaderboardUpdate",
		Category = "TimePlayed",
		Title = "Most Time Played",
		HeaderTitle = "Top 50 Time Played",
		AvatarLabel = "TOP 1 Time Played",
		ValueHeader = "Time"
	},
	{
		ModelName = "DonatedLeaderboard",
		Category = "RobuxDonated",
		Title = "Most Donated",
		HeaderTitle = "Top 50 Robux Donated",
		AvatarLabel = "TOP 1 DONATED",
		ValueHeader = "Donated"
	},
	{
		ModelName = "RaisedLeaderboard",
		Category = "RobuxRaised",
		Title = "Most Raised",
		HeaderTitle = "Top 50 Robux Raised",
		AvatarLabel = "TOP 1 RAISED",
		ValueHeader = "Raised"
	},
	{
		ModelName = "ReputationLeaderboard",
		Category = "Reputation",
		Title = "Most Reputation",
		HeaderTitle = "Top 50 Reputation",
		AvatarLabel = "TOP 1 Reputation",
		ValueHeader = "Reputation"
	}
}

local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = {}
local v14 = {}
local v15 = {}
local switchPeriodsByButton = {}
local v16 = {}
local v17 = 0

local v18 = {
	Weekly = { X = 356, Y = 22, W = 172, H = 48 },
	Monthly = { X = 536, Y = 22, W = 172, H = 48 },
	AllTime = { X = 716, Y = 22, W = 172, H = 48 }
}

local function debugLog(...) end

local function formatNumberWithCommas(p)
	local v19 = tostring((math.floor(tonumber(p) or 0)))

	repeat
		local v20
		v19, v20 = v19:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v20 == 0

	return v19
end

local function formatNotes(p) -- 1 equivalent call inferred from this helper
	return formatNumberWithCommas(p) .. " Notes"
end

local function formatTime(p)
	local v19 = math.max(0, (math.floor(tonumber(p) or 0)))
	local v20 = math.floor(v19 / 60)
	local v21 = math.floor(v20 / 60)
	local v22 = math.floor(v21 / 24)

	if v22 > 0 then
		return string.format("%dD %dH", v22, v21 % 24)
	end

	if v21 > 0 then
		return string.format("%dH %dM", v21, v20 % 60)
	end

	if v20 > 0 then
		return string.format("%dM", v20)
	end

	return string.format("%dS", v19)
end

local function formatValue(category, value)
	if category == "TimePlayed" then
		return formatTime(value)
	end

	if category == "RobuxDonated" or category == "RobuxRaised" then
		return utf8.char(57346) .. formatNumberWithCommas(value)
	end

	if category == "Reputation" then
		return formatNumberWithCommas(value) .. " Rep"
	end

	return formatNotes(value) -- inferred equivalent call
end

local function getOrCreate(parent, className, key) -- 17 equivalent calls inferred from this helper
	local v19 = parent:FindFirstChild(key)

	if v19 and v19.ClassName ~= className then
		v19:Destroy()
		v19 = nil
	end

	if not v19 then
		v19 = Instance.new(className)
		v19.Name = key
		v19.Parent = parent
	end

	return v19
end

local function styleText(p, textSize, color) -- 8 equivalent calls inferred from this helper
	p.BackgroundTransparency = 1
	p.Font = Enum.Font.GothamBold
	p.TextScaled = false
	p.TextSize = textSize
	p.TextColor3 = color or Color3.fromRGB(245, 247, 255)
	p.TextStrokeTransparency = 0.75
end

local function styleButton(parent)
	parent.AutoButtonColor = true
	parent.Font = Enum.Font.GothamBold
	parent.TextScaled = false
	parent.TextSize = 22
	parent.TextColor3 = Color3.fromRGB(245, 247, 255)
	parent.TextStrokeTransparency = 1
	parent.BorderSizePixel = 0
	parent.Active = true
	parent.Selectable = true
	parent.Size = UDim2.new(0.32, -8, 0, 44)
	parent.ZIndex = 30
	local uiCorner = getOrCreate(parent, "UICorner", "UICorner") -- inferred equivalent call
	uiCorner.CornerRadius = UDim.new(0, 8)
	local uiStroke = getOrCreate(parent, "UIStroke", "UIStroke") -- inferred equivalent call
	uiStroke.Thickness = 1
	uiStroke.Color = Color3.fromRGB(57, 66, 88)
	uiStroke.Transparency = 0.55
end

local function setGuiInputEnabled(p, p2)
	pcall(function()
		p.Active = p2
	end)
	pcall(function()
		p.Selectable = p2
	end)
end

local function setButtonSelected(button, p)
	button.BackgroundColor3 = p and Color3.fromRGB(45, 132, 229) or Color3.fromRGB(27, 35, 55)
	button.TextColor3 = p and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(214, 220, 235)
	button.TextStrokeTransparency = 1
	button.Size = UDim2.new(0.32, -8, 0, 44)

	local uiStroke = button:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Thickness = 1
		uiStroke.Transparency = p and 1 or 0.55
		uiStroke.Color = p and Color3.fromRGB(45, 132, 229) or Color3.fromRGB(57, 66, 88)
	end
end

local function prepareBoardInputParts(instance, part)
	if part and part:IsA("BasePart") then
		part.CanQuery = true
	end

	for _, childName in ipairs({ "Leaderboard", "Light" }) do
		local part2 = instance:FindFirstChild(childName)

		if part2 and part2:IsA("BasePart") then
			part2.CanQuery = false
		end
	end
end

local function hideLegacyRows(leaderboard)
	for _, childName in ipairs({ "Names", "Score", "Photos", "Order" }) do
		local folder = leaderboard:FindFirstChild(childName)

		if not folder then
			continue
		end

		for _, guiObject in ipairs(folder:GetDescendants()) do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			guiObject.Visible = false
			guiObject.ZIndex = 0
			setGuiInputEnabled(guiObject, false)
		end
	end
end

local function disableCompetingScoreBlockGuis(scoreBlock, leaderboard)
	for _, surfaceGui in ipairs(scoreBlock:GetChildren()) do
		if surfaceGui:IsA("SurfaceGui") and surfaceGui ~= leaderboard then
			surfaceGui.Enabled = false
		end
	end
end

local function getRigRootPart(model, humanoid)
	if humanoid then
		local rootPart = nil
		pcall(function()
			rootPart = humanoid.RootPart
		end)

		if rootPart and rootPart:IsA("BasePart") then
			return rootPart
		end
	end

	local humanoidRootPart = model and model:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	return nil
end

local function waitForAvatarRigReady(model, p)
	local v19 = p == nil and 5 or p

	local v20 = os.clock() + (math.max)(0, v19)

	while model do
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		local rigRootPart = getRigRootPart(model, humanoid)

		if humanoid and rigRootPart then
			if model:IsA("Model") and not model.PrimaryPart then
				pcall(function()
					model.PrimaryPart = rigRootPart
				end)
			end

			return humanoid, rigRootPart
		elseif v20 <= os.clock() then
			break
		else
			task.wait(0.1)
		end
	end

	return nil, nil
end

local function hasRequiredAvatarParts(result)
	for _, childName in ipairs(v) do
		local part = result and result:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			return false, childName
		end
	end

	return true, nil
end

local function captureRigPartState(folder)
	local result = {}

	if not folder then
		return result
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			result[part.Name] = {
				Anchored = part.Anchored,
				CanCollide = part.CanCollide,
				CanTouch = part.CanTouch,
				CanQuery = part.CanQuery,
				Massless = part.Massless,
				Transparency = part.Transparency,
				CastShadow = part.CastShadow,
				CollisionGroup = part.CollisionGroup
			}
		end
	end

	return result
end

local function applyRigPartState(folder, options)
	local v19 = options or {}

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local v20 = v19[part.Name]

		if v20 then
			part.Anchored = v20.Anchored
			part.CanCollide = v20.CanCollide
			part.CanTouch = v20.CanTouch
			part.CanQuery = v20.CanQuery
			part.Massless = v20.Massless
			part.Transparency = v20.Transparency
			part.CastShadow = v20.CastShadow
			pcall(function()
				part.CollisionGroup = v20.CollisionGroup
			end)
		else
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
		end
	end
end

local function copyRigHumanoidState(result, instance)
	local humanoid = result and result:FindFirstChildOfClass("Humanoid")
	local humanoid2 = instance and instance:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid2 then
		for _, v19 in ipairs({
			"DisplayDistanceType",
			"HealthDisplayType",
			"NameDisplayDistance",
			"HealthDisplayDistance",
			"BreakJointsOnDeath",
			"RequiresNeck",
			"AutoRotate"
		}) do
			pcall(function()
				humanoid[v19] = humanoid2[v19]
			end)
		end
	end
end

local function moveBoardDecorationsToAvatarModel(avatarModel, rig)
	if not avatarModel then
		return
	end

	for childName in pairs(v2) do
		local child = rig and rig:FindFirstChild(childName)
		local child2 = avatarModel:FindFirstChild(childName)

		if not (child and child ~= child2) then
			continue
		end

		if child2 then
			child:Destroy()
		else
			child.Parent = avatarModel
		end
	end
end

local function removeGeneratedBoardDecorations(result)
	if not result then
		return
	end

	for childName in pairs(v2) do
		local child = result:FindFirstChild(childName)

		if child then
			child:Destroy()
		end
	end
end

local function buildBoardUi(instance, data)
	local scoreBlock = instance:FindFirstChild("ScoreBlock")

	if not scoreBlock then
		return nil
	end

	local leaderboard = scoreBlock:FindFirstChild("Leaderboard")

	if not (leaderboard and leaderboard:IsA("SurfaceGui")) then
		return nil
	end

	prepareBoardInputParts(instance, scoreBlock)

	local child = PlayerGui:FindFirstChild("WorkspaceLeaderboard_" .. data.ModelName)

	if child then
		child:Destroy()
	end

	disableCompetingScoreBlockGuis(scoreBlock, leaderboard)
	leaderboard.Enabled = true
	leaderboard.CanvasSize = Vector2.new(900, 650)
	leaderboard.LightInfluence = 0
	pcall(function()
		leaderboard.Active = true
	end)
	hideLegacyRows(leaderboard)
	local parent = getOrCreate(leaderboard, "Frame", "BoardRoot") -- inferred equivalent call
	parent.Size = UDim2.fromScale(1, 1)
	parent.Position = UDim2.fromScale(0, 0)
	parent.BackgroundColor3 = Color3.fromRGB(16, 24, 40)
	parent.BackgroundTransparency = 0.04
	parent.BorderSizePixel = 0
	parent.Visible = true
	parent.ZIndex = 1
	setGuiInputEnabled(parent, false)
	local uiPadding = getOrCreate(parent, "UIPadding", "UIPadding") -- inferred equivalent call
	uiPadding.PaddingTop = UDim.new(0, 14)
	uiPadding.PaddingBottom = UDim.new(0, 14)
	uiPadding.PaddingLeft = UDim.new(0, 14)
	uiPadding.PaddingRight = UDim.new(0, 14)
	local parent2 = getOrCreate(parent, "Frame", "TopBar") -- inferred equivalent call
	parent2.Size = UDim2.new(1, 0, 0, 64)
	parent2.Position = UDim2.fromOffset(0, 0)
	parent2.BackgroundTransparency = 1
	parent2.BorderSizePixel = 0
	parent2.ZIndex = 20
	setGuiInputEnabled(parent2, false)
	local title2 = getOrCreate(parent2, "TextLabel", "Title") -- inferred equivalent call
	title2.Size = UDim2.new(0.36, -8, 1, 0)
	title2.Position = UDim2.fromOffset(0, 0)
	title2.TextXAlignment = Enum.TextXAlignment.Left
	title2.Text = data.Title
	title2.ZIndex = 21
	setGuiInputEnabled(title2, false)
	styleText(title2, 28, Color3.fromRGB(255, 213, 74)) -- inferred equivalent call
	local tabs = getOrCreate(parent2, "Frame", "PeriodTabs") -- inferred equivalent call
	tabs.Size = UDim2.new(0.64, 0, 1, 0)
	tabs.Position = UDim2.fromScale(0.36, 0)
	tabs.BackgroundTransparency = 1
	tabs.BorderSizePixel = 0
	tabs.ZIndex = 22
	setGuiInputEnabled(tabs, false)
	local uiListLayout = getOrCreate(tabs, "UIListLayout", "UIListLayout") -- inferred equivalent call
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	for i, v19 in ipairs(v3) do
		local parent3 = getOrCreate(tabs, "TextButton", v19.Key) -- inferred equivalent call
		parent3.Name = v19.Key
		parent3.LayoutOrder = i
		parent3.Text = v19.Label
		styleButton(parent3)
	end

	local parent3 = getOrCreate(parent, "Frame", "Header") -- inferred equivalent call
	parent3.Size = UDim2.new(1, -10, 0, 32)
	parent3.Position = UDim2.new(0, 0, 0, 74)
	parent3.BackgroundColor3 = Color3.fromRGB(26, 34, 50)
	parent3.BackgroundTransparency = 0.15
	parent3.BorderSizePixel = 0
	parent3.ZIndex = 5
	setGuiInputEnabled(parent3, false)
	local uiCorner = getOrCreate(parent3, "UICorner", "UICorner") -- inferred equivalent call
	uiCorner.CornerRadius = UDim.new(0, 6)
	local rank = getOrCreate(parent3, "TextLabel", "Rank") -- inferred equivalent call
	rank.Size = UDim2.new(0.1, 0, 1, 0)
	rank.Position = UDim2.fromScale(0, 0)
	rank.Text = "#"
	styleText(rank, 18, Color3.fromRGB(198, 205, 222)) -- inferred equivalent call
	local player = getOrCreate(parent3, "TextLabel", "Player") -- inferred equivalent call
	player.Size = UDim2.new(0.46, -48, 1, 0)
	player.Position = UDim2.fromScale(0.18, 0)
	player.Text = "Player"
	player.TextXAlignment = Enum.TextXAlignment.Left
	styleText(player, 18, Color3.fromRGB(198, 205, 222)) -- inferred equivalent call
	local value = getOrCreate(parent3, "TextLabel", "Value") -- inferred equivalent call
	value.Size = UDim2.new(0.34, -8, 1, 0)
	value.Position = UDim2.fromScale(0.66, 0)
	value.Text = data.ValueHeader
	value.TextXAlignment = Enum.TextXAlignment.Right
	styleText(value, 18, Color3.fromRGB(198, 205, 222)) -- inferred equivalent call

	local headerTitle = nil
	local leaderboard2 = instance:FindFirstChild("Leaderboard")
	local leaderboardGui = leaderboard2 and leaderboard2:FindFirstChild("LeaderboardGui")
	local leaderboardContainer = leaderboardGui and leaderboardGui:FindFirstChild("LeaderboardContainer")
	local buttons = leaderboardContainer and leaderboardContainer:FindFirstChild("Buttons")
	local title = buttons and buttons:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		headerTitle = title
	end

	local firstPlaceAvatar = instance:FindFirstChild("First Place Avatar")
	local rows = getOrCreate(parent, "ScrollingFrame", "Rows") -- inferred equivalent call
	rows.Size = UDim2.new(1, 0, 1, -116)
	rows.Position = UDim2.new(0, 0, 0, 112)
	rows.BackgroundTransparency = 1
	rows.BorderSizePixel = 0
	rows.ZIndex = 3
	setGuiInputEnabled(rows, false)
	rows.ScrollBarThickness = 10
	rows.ScrollBarImageColor3 = Color3.fromRGB(255, 213, 74)
	rows.ScrollingDirection = Enum.ScrollingDirection.Y
	rows.AutomaticCanvasSize = Enum.AutomaticSize.Y
	rows.CanvasSize = UDim2.fromOffset(0, 0)
	local uiPadding2 = getOrCreate(rows, "UIPadding", "UIPadding") -- inferred equivalent call
	uiPadding2.PaddingRight = UDim.new(0, 10)
	local uiListLayout2 = getOrCreate(rows, "UIListLayout", "UIListLayout") -- inferred equivalent call
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout2.Padding = UDim.new(0, 6)

	return {
		Model = instance,
		ScoreBlock = scoreBlock,
		SurfaceGui = leaderboard,
		TemplateSurfaceGui = leaderboard,
		TemplateTabs = nil,
		TemplateTitle = nil,
		Rows = rows,
		Tabs = tabs,
		Title = title2,
		HeaderTitle = headerTitle,
		AvatarModel = firstPlaceAvatar,
		CurrentAvatarKey = nil,
		SwitchPeriod = {},
		TabZones = {}
	}
end

local function getUsername(userId) -- 2 equivalent calls inferred from this helper
	local v19 = tonumber(userId) or 0

	if v6[v19] then
		return v6[v19]
	end

	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(v19)
	end)

	if success and result then
		local v20 = "@" .. result
		v6[v19] = v20
		return v20
	end

	return "Loading..."
end

local function getThumbnail(userId) -- 1 equivalent call inferred from this helper
	local v19 = tonumber(userId) or 0

	if v5[v19] then
		return v5[v19]
	end

	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(v19, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)
	local v20 = success and result or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	v5[v19] = v20
	return v20
end

local function clearRows(rows)
	for _, guiObject in ipairs(rows:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end
end

local function renderMessage(state, text)
	clearRows(state.Rows)

	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.LayoutOrder = 1
	message.Size = UDim2.new(1, -10, 0, 90)
	message.BackgroundColor3 = Color3.fromRGB(26, 34, 50)
	message.BackgroundTransparency = 0.15
	message.BorderSizePixel = 0
	message.Text = text
	styleText(message, 24, Color3.fromRGB(235, 239, 250)) -- inferred equivalent call
	message.Parent = state.Rows

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = message
end

local function createRow(rows, layoutOrder, item, p)
	local frame = Instance.new("Frame")
	frame.Name = "Row" .. tostring(layoutOrder)
	frame.LayoutOrder = layoutOrder
	frame.Size = UDim2.new(1, -10, 0, 50)
	frame.BackgroundColor3 = layoutOrder % 2 == 0 and Color3.fromRGB(24, 32, 47) or Color3.fromRGB(31, 40, 57)
	frame.BackgroundTransparency = 0.02
	frame.BorderSizePixel = 0
	frame.Parent = rows

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 7)
	uiCorner.Parent = frame

	local rank = Instance.new("TextLabel")
	rank.Name = "Rank"
	rank.Size = UDim2.new(0.1, 0, 1, 0)
	rank.Position = UDim2.fromScale(0, 0)
	rank.Text = tostring(layoutOrder)
	styleText(rank, 22, layoutOrder == 1 and Color3.fromRGB(255, 213, 74) or Color3.fromRGB(235, 239, 250)) -- inferred equivalent call
	rank.Parent = frame

	local avatar = Instance.new("ImageLabel")
	avatar.Name = "Avatar"
	avatar.Size = UDim2.fromOffset(40, 40)
	avatar.Position = UDim2.new(0.105, 0, 0.5, -20)
	avatar.BackgroundColor3 = Color3.fromRGB(12, 18, 30)
	avatar.Image = v5[tonumber(item.UserId) or 0] or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	avatar.Parent = frame
	task.spawn(function()
		local thumbnail = getThumbnail(item.UserId) -- inferred equivalent call

		if avatar.Parent then
			avatar.Image = thumbnail
		end
	end)

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(1, 0)
	uiCorner2.Parent = avatar

	local player = Instance.new("TextLabel")
	player.Name = "Player"
	player.Size = UDim2.new(0.46, -48, 1, 0)
	player.Position = UDim2.new(0.18, 0, 0, 0)
	player.TextXAlignment = Enum.TextXAlignment.Left
	player.TextTruncate = Enum.TextTruncate.AtEnd
	player.Text = v6[tonumber(item.UserId) or 0] or "Loading..."
	styleText(player, 22, Color3.fromRGB(245, 247, 255)) -- inferred equivalent call
	player.Parent = frame
	task.spawn(function()
		for _ = 1, 3 do
			local username = getUsername(item.UserId) -- inferred equivalent call

			if not player.Parent then
				break
			end

			player.Text = username

			if username ~= "Loading..." then
				break
			end

			task.wait(2)
		end
	end)

	local value = Instance.new("TextLabel")
	value.Name = "Value"
	value.Size = UDim2.new(0.34, -8, 1, 0)
	value.Position = UDim2.fromScale(0.66, 0)
	value.TextXAlignment = Enum.TextXAlignment.Right
	value.TextTruncate = Enum.TextTruncate.AtEnd
	value.Text = formatValue(p.Category, item.Value)
	styleText(value, 21, Color3.fromRGB(214, 220, 235)) -- inferred equivalent call
	value.Parent = frame
end

local function bindFirstPlaceTagToRoot(instance, p)
	local firstPlaceTag = instance and instance:FindFirstChild("FirstPlaceTag")
	local rig = instance and instance:FindFirstChild("Rig")
	local part = p or rig and rig:FindFirstChild("HumanoidRootPart")

	if firstPlaceTag and firstPlaceTag:IsA("BillboardGui") and part and part:IsA("BasePart") then
		firstPlaceTag.Adornee = part
	end

	return firstPlaceTag
end

local function updateFirstPlaceTag(avatarModel, p, text)
	local billboardGui = bindFirstPlaceTagToRoot(avatarModel)

	if billboardGui and billboardGui:IsA("BillboardGui") then
		billboardGui.StudsOffset = Vector3.new(0, 5, 0)
	end

	local billboardGuiContainer = billboardGui and billboardGui:FindFirstChild("Container")
	local pName = billboardGuiContainer and billboardGuiContainer:FindFirstChild("pName")
	local extra = billboardGuiContainer and billboardGuiContainer:FindFirstChild("Extra")

	if extra and extra:IsA("TextLabel") then
		extra.Text = p.AvatarLabel
	end

	if pName and pName:IsA("TextLabel") then
		pName.Text = text
	end
end

local function getAvatarDescription(userId)
	local v19 = tonumber(userId) or 0

	if v11[v19] then
		return v11[v19]
	end

	if v19 <= 0 then
		return nil
	end

	local result = nil

	for i = 1, 4 do
		local success
		success, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(v19)
		end)

		if success and result then
			v11[v19] = result
			return result
		elseif i < 4 then
			task.wait(i * 1.25)
		end
	end

	ClientDebugConfig.Warn("[WorkspaceLeaderboardClient] Failed to load avatar description", v19, result)
	return nil
end

local function stopFirstPlaceAnimation(p) -- 4 equivalent calls inferred from this helper
	local v19 = v13[p]

	if v19 then
		pcall(function()
			v19:Stop(0.1)
		end)
	end

	v13[p] = nil
	v14[p] = nil
end

local function playFirstPlaceAnimation(avatarModel, rig): boolean
	local animationToPlay = avatarModel and avatarModel:FindFirstChild("AnimationToPlay")
	local humanoid = rig and rig:FindFirstChildOfClass("Humanoid")

	if not (animationToPlay and humanoid) then
		return false
	end

	local v19 = humanoid:FindFirstChildOfClass("Animator")

	if not v19 then
		v19 = Instance.new("Animator")
		v19.Parent = humanoid
	end

	local v20 = v13[avatarModel]

	if v20 then
		local v21 = false
		pcall(function()
			v21 = v20.IsPlaying
		end)

		if v21 and v14[avatarModel] == rig then
			return true
		end

		stopFirstPlaceAnimation(avatarModel) -- inferred equivalent call
	end

	local result = nil

	for i = 1, 4 do
		local success, result2 = pcall(function()
			return v19:LoadAnimation(animationToPlay)
		end)

		if success and result2 then
			local success2
			success2, result = pcall(function()
				result2.Looped = true
				result2.Priority = Enum.AnimationPriority.Idle
				result2:Play(0.15)
			end)

			if success2 then
				v13[avatarModel] = result2
				v14[avatarModel] = rig
				return true
			end
		else
			result = result2
		end

		if i < 4 then
			task.wait(i * 0.75)
		end
	end

	ClientDebugConfig.Warn(
		"[WorkspaceLeaderboardClient] Failed to play leaderboard avatar animation",
		avatarModel and avatarModel:GetFullName() or "?",
		result
	)
	return false
end

local function createClientAvatarRigFromDescription(avatarDescription, rig)
	local success, result = pcall(function()
		return Players:CreateHumanoidModelFromDescription(avatarDescription, Enum.HumanoidRigType.R15)
	end)

	if not success or typeof(result) ~= "Instance" or not result:IsA("Model") then
		return nil, nil, nil, result
	end

	removeGeneratedBoardDecorations(result)
	local requiredAvatarParts, v19 = hasRequiredAvatarParts(result)

	if not requiredAvatarParts then
		result:Destroy()
		return nil, nil, nil, "Generated rig missing " .. tostring(v19)
	end

	local v20, primaryPart = waitForAvatarRigReady(result, 5)

	if not (v20 and primaryPart) then
		result:Destroy()
		return nil, nil, nil, "Generated rig missing Humanoid or HumanoidRootPart"
	end

	applyRigPartState(result, captureRigPartState(rig))
	copyRigHumanoidState(result, rig)
	pcall(function()
		result.PrimaryPart = primaryPart
	end)

	return result, v20, primaryPart, nil
end

local function updateFirstPlaceAvatar(state, p, p2, p3)
	local avatarModel = state.AvatarModel or state.Model:FindFirstChild("First Place Avatar")

	if not avatarModel then
		return
	end

	if p2 then
		local userId = tonumber(p2.UserId)

		if userId and not (userId <= 0) then
			local username = getUsername(userId) -- inferred equivalent call
			updateFirstPlaceTag(avatarModel, p, username)

			local joined = table.concat(
				{ p.ModelName, tostring(p3 or v7[p.ModelName] or "AllTime"), (tostring(userId)) },
				":"
			)

			if state.CurrentAvatarKey == joined then
				playFirstPlaceAnimation(avatarModel, avatarModel:FindFirstChild("Rig"))
				return
			end

			if state.PendingAvatarKey == joined then
				return
			end

			state.PendingAvatarKey = joined

			local v19 = (v12[p.ModelName] or 0) + 1
			v12[p.ModelName] = v19
			task.spawn(function()
				local avatarDescription = getAvatarDescription(userId)

				if v12[p.ModelName] ~= v19 then
					return
				end

				if avatarDescription then
					local rig = avatarModel:FindFirstChild("Rig")
					moveBoardDecorationsToAvatarModel(avatarModel, rig)
					local _, v20 = waitForAvatarRigReady(rig, 5)
					bindFirstPlaceTagToRoot(avatarModel, v20)

					if rig and v20 then
						local pivot = rig:GetPivot()
						local rig2, v21, v22, v23 = createClientAvatarRigFromDescription(avatarDescription, rig)

						if v12[p.ModelName] == v19 then
							if rig2 then
								stopFirstPlaceAnimation(avatarModel) -- inferred equivalent call
								rig2.Name = "Rig"
								rig2:PivotTo(pivot)
								rig2.Parent = avatarModel
								rig:Destroy()
								bindFirstPlaceTagToRoot(avatarModel, v22)

								pcall(function()
									v21.DisplayName = username:gsub("^@", "")
								end)
								state.CurrentAvatarKey = joined
								state.PendingAvatarKey = nil
								avatarModel:SetAttribute("ClientLeaderboardAvatarKey", joined)
								playFirstPlaceAnimation(avatarModel, rig2)
								return
							end

							ClientDebugConfig.Warn(
								"[WorkspaceLeaderboardClient] Failed to create leaderboard avatar rig",
								p.ModelName,
								userId,
								v23
							)
						else
							if rig2 then
								rig2:Destroy()
							end

							return
						end
					else
						ClientDebugConfig.Warn(
							"[WorkspaceLeaderboardClient] First place avatar rig was not ready for description",
							p.ModelName,
							userId
						)
					end
				end

				if state.PendingAvatarKey == joined then
					state.PendingAvatarKey = nil
				end
			end)
			return
		end
	end

	state.CurrentAvatarKey = nil
	state.PendingAvatarKey = nil
	stopFirstPlaceAnimation(avatarModel) -- inferred equivalent call
	updateFirstPlaceTag(avatarModel, p, "No data yet")
end

local function applyTabState(instance, p)
	if not instance then
		return
	end

	for _, v19 in ipairs(v3) do
		local key = v19.Key
		local button = instance:FindFirstChild(key)

		if button and button:IsA("TextButton") then
			setButtonSelected(button, key == p)
		end
	end
end

local function updateTabState(data, p, p2)
	if data.Title and data.Title:IsA("TextLabel") then
		data.Title.Text = p.Title
	end

	if data.TemplateTitle and data.TemplateTitle:IsA("TextLabel") then
		data.TemplateTitle.Text = p.Title
	end

	if data.HeaderTitle and data.HeaderTitle:IsA("TextLabel") then
		local text = p.HeaderTitle or "Top 50"

		if p2 == "Weekly" then
			text ..= " - Weekly"
		elseif p2 == "Monthly" then
			text ..= " - Monthly"
		end

		data.HeaderTitle.Text = text
	end

	applyTabState(data.Tabs, p2)
	applyTabState(data.TemplateTabs, p2)
end

local function getLocalPlayerValue(category)
	local hiddenStats = LocalPlayer:FindFirstChild("HiddenStats")

	if category == "TopNotes" then
		local notesPlayed = hiddenStats and hiddenStats:FindFirstChild("Notes Played")
		return notesPlayed and tonumber(notesPlayed.Value) or 0
	elseif category == "TimePlayed" then
		local timePlayed = hiddenStats and hiddenStats:FindFirstChild("Time Played")
		return timePlayed and tonumber(timePlayed.Value) or 0
	elseif category == "RobuxDonated" then
		local robuxDonated = hiddenStats and hiddenStats:FindFirstChild("Robux Donated")
		return robuxDonated and tonumber(robuxDonated.Value) or 0
	elseif category == "RobuxRaised" then
		local robuxRaised = hiddenStats and hiddenStats:FindFirstChild("Robux Raised")
		return robuxRaised and tonumber(robuxRaised.Value) or 0
	end

	if category ~= "Reputation" then
		return 0
	end

	local reputation = hiddenStats and hiddenStats:FindFirstChild("Reputation")
	return reputation and tonumber(reputation.Value) or 0
end

local function shouldShowEntryValue(category, p): boolean -- 2 equivalent calls inferred from this helper
	local v19 = math.max(0, (math.floor(tonumber(p) or 0)))
	return category ~= "RobuxDonated" and category ~= "RobuxRaised" or v19 > 0
end

local function getLocalFallbackData(p, p2)
	local v19 = p2 or v7[p.ModelName] or "AllTime"
	local v20

	if v19 == "AllTime" then
		v20 = getLocalPlayerValue(p.Category) or 0
	else
		local v21 = v9[p.ModelName]
		local v22 = v21 and v21[v19]
		v20 = v22 and v22[p.Category] or 0
	end

	local v21 = math.max(0, (math.floor(v20)))

	if shouldShowEntryValue(p.Category, v21) then -- inferred equivalent call
		return {
			{ UserId = LocalPlayer.UserId, Value = v21 }
		}
	end

	return {}
end

local function renderRows(state, p, list, p2, p3)
	local v19 = p3 == nil or p3

	clearRows(state.Rows)

	if type(list) == "table" and #list ~= 0 then
		local count = 0
		local v20 = nil

		for _, item in ipairs(list) do
			if count >= 50 then
				break
			end

			if not (item and tonumber(item.UserId) and tonumber(item.Value) and shouldShowEntryValue(p.Category, item.Value)) then -- inferred equivalent call
				continue
			end

			count += 1

			createRow(state.Rows, count, item, p)
			v20 = v20 or item
		end

		if count == 0 then
			renderMessage(state, "No leaderboard data yet")
		end

		if v19 then
			updateFirstPlaceAvatar(state, p, v20, p2)
		end
	else
		local localFallbackData = getLocalFallbackData(p, p2)

		if type(localFallbackData) == "table" and #localFallbackData > 0 then
			renderRows(state, p, localFallbackData, p2, false)
		else
			renderMessage(state, "No leaderboard data yet")
		end

		if v19 then
			local avatarModel = state.AvatarModel or state.Model:FindFirstChild("First Place Avatar")

			if not avatarModel then
				return
			end

			state.CurrentAvatarKey = nil
			state.PendingAvatarKey = nil
			stopFirstPlaceAnimation(avatarModel) -- inferred equivalent call
			updateFirstPlaceTag(avatarModel, p, "No data yet")
		end
	end
end

local function invokeLeaderboardWithTimeout(category, p, p2)
	local flag = false
	local success = false
	local result = nil

	task.spawn(function()
		success, result = pcall(function()
			return GetWorkspaceLeaderboardData:InvokeServer(category, p)
		end)

		flag = true
	end)

	local lastTime = os.clock()

	while not flag and os.clock() - lastTime < p2 do
		task.wait(0.1)
	end

	if flag then
		return success, result
	end

	return false, "Timed out waiting for workspace leaderboard callback"
end

local function refreshBoard(p, p2, p3)
	local v19 = p3 or v7[p2.ModelName] or "AllTime"
	v7[p2.ModelName] = v19
	updateTabState(p, p2, v19)

	local v20 = p2.ModelName .. ":" .. v19
	local v21 = v10[v20]
	local v22

	if p2.Category == "TopNotes" then
		v22 = v19 ~= "AllTime"
	else
		v22 = false
	end

	if not v22 and v21 and os.clock() - v21.UpdatedAt < 45 then
		renderRows(p, p2, v21.Data, v19, true)
		return
	end

	local v23 = (v8[p2.ModelName] or 0) + 1
	v8[p2.ModelName] = v23
	renderRows(p, p2, getLocalFallbackData(p2, v19), v19, false)

	task.spawn(function()
		local v24 = nil

		for _ = 1, 3 do
			local v25
			v25, v24 = invokeLeaderboardWithTimeout(p2.Category, v19, 8)

			if v8[p2.ModelName] ~= v23 then
				return
			end

			if v25 and type(v24) == "table" then
				v10[v20] = { Data = v24, UpdatedAt = os.clock() }

				renderRows(p, p2, v24, v19, true)
				return
			end

			task.wait(2)
		end

		ClientDebugConfig.Warn("[WorkspaceLeaderboardClient] Failed to fetch leaderboard", p2.Category, v19, v24)
		renderRows(p, p2, getLocalFallbackData(p2, v19), v19, false)
	end)
end

local function connectTabs(boardUi, p)
	for _, v19 in ipairs(v3) do
		local key = v19.Key
		local button = boardUi.Tabs:FindFirstChild(key)

		if not (button and button:IsA("TextButton")) then
			continue
		end

		local function switchPeriod(_)
			local now = os.clock()

			if (v7[p.ModelName] or "AllTime") == key then
				return
			end

			local v20 = v16[p.ModelName]

			if v20 and v20.Period == key and now - v20.Time < 0.2 then
				return
			end

			v16[p.ModelName] = { Period = key, Time = now }

			v17 = now
			refreshBoard(boardUi, p, key)
		end

		local function switchFrom(p2) -- 3 equivalent calls inferred from this helper
			return function()
				switchPeriod(p2)
			end
		end

		boardUi.SwitchPeriod[key] = switchPeriod
		switchPeriodsByButton[button] = switchPeriod
		button.Activated:Connect(switchFrom("Activated")) -- inferred equivalent call
		button.MouseButton1Click:Connect(switchFrom("MouseButton1Click")) -- inferred equivalent call
		button.MouseButton1Down:Connect(switchFrom("MouseButton1Down")) -- inferred equivalent call
		button.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				switchPeriod("ButtonInputBegan")
			end
		end)
	end
end

local function isBoardModelReady(instance) -- 1 equivalent call inferred from this helper
	local scoreBlock = instance and instance:FindFirstChild("ScoreBlock")
	local leaderboard = scoreBlock and scoreBlock:FindFirstChild("Leaderboard")
	return scoreBlock and scoreBlock:IsA("BasePart") and leaderboard and leaderboard:IsA("SurfaceGui")
end

local function registerBoard(list, p, child, config): boolean
	if p[config.ModelName] then
		return true
	end

	if not isBoardModelReady(child) then -- inferred equivalent call
		return false
	end

	local boardUi = buildBoardUi(child, config)

	if not boardUi then
		return false
	end

	connectTabs(boardUi, config)
	v9[config.ModelName] = {
		Weekly = {
			TopNotes = 0,
			TimePlayed = 0,
			RobuxDonated = 0,
			RobuxRaised = 0,
			Reputation = 0
		},
		Monthly = {
			TopNotes = 0,
			TimePlayed = 0,
			RobuxDonated = 0,
			RobuxRaised = 0,
			Reputation = 0
		}
	}

	v7[config.ModelName] = "AllTime"
	refreshBoard(boardUi, config, "AllTime")
	table.insert(list, { Board = boardUi, Config = config })
	p[config.ModelName] = true
	debugLog("RegisteredBoard", config.ModelName)
	return true
end

local function setupBoards()
	local leaderboard = Workspace:WaitForChild("Leaderboard", 45)

	if not leaderboard then
		ClientDebugConfig.Warn("[WorkspaceLeaderboardClient] Workspace.Leaderboard not found")
		return {}
	end

	local v19 = os.clock() + 45
	local v20 = {}
	local v21 = {}

	while os.clock() < v19 do
		for _, v22 in ipairs(v4) do
			if v20[v22.ModelName] then
				continue
			end

			local child = leaderboard:FindFirstChild(v22.ModelName)

			if child then
				registerBoard(v21, v20, child, v22)
			end
		end

		if #v21 >= #v4 then
			break
		end

		task.wait(0.25)
	end

	for _, v22 in ipairs(v4) do
		if not v20[v22.ModelName] then
			ClientDebugConfig.Warn("[WorkspaceLeaderboardClient] Board did not initialize", v22.ModelName)
		end
	end

	return v21
end

local function getBoardCanvasPoint(board, p)
	local currentCamera = Workspace.CurrentCamera
	local scoreBlock = board.ScoreBlock

	if not (currentCamera and scoreBlock and scoreBlock:IsA("BasePart")) then
		return nil
	end

	local viewportPointToRay = currentCamera:ViewportPointToRay(p.X, p.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { scoreBlock }

	local raycastResult = Workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 1000,
		raycastParams
	)

	if not raycastResult or raycastResult.Instance ~= scoreBlock then
		return nil
	end

	local pointToObjectSpace = scoreBlock.CFrame:PointToObjectSpace(raycastResult.Position)
	local canvasSize = board.SurfaceGui.CanvasSize
	return Vector2.new(
		(pointToObjectSpace.X / scoreBlock.Size.X + 0.5) * canvasSize.X,
		(0.5 - pointToObjectSpace.Y / scoreBlock.Size.Y) * canvasSize.Y
	)
end

local function canvasPointInsideRect(p, data) -- 1 equivalent call inferred from this helper
	if data then
		if p.X >= data.X and p.X <= data.X + data.W and p.Y >= data.Y then
			data = p.Y <= data.Y + data.H
		else
			data = false
		end
	end

	return data
end

local function getDynamicTabRect(guiObject)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return nil
	end

	local absolutePosition = guiObject.AbsolutePosition
	local absoluteSize = guiObject.AbsoluteSize

	if absoluteSize.X <= 2 or absoluteSize.Y <= 2 then
		return nil
	end

	return {
		X = absolutePosition.X,
		Y = absolutePosition.Y,
		W = absoluteSize.X,
		H = absoluteSize.Y
	}
end

local function getClickedPeriod(board, boardCanvasPoint)
	for _, v19 in ipairs(v3) do
		local child = board.Tabs and board.Tabs:FindFirstChild(v19.Key)
		local v20 = getDynamicTabRect(child)

		if not v20 then
			continue
		end

		if v20 then
			if boardCanvasPoint.X >= v20.X and boardCanvasPoint.X <= v20.X + v20.W and boardCanvasPoint.Y >= v20.Y then
				v20 = boardCanvasPoint.Y <= v20.Y + v20.H
			else
				v20 = false
			end
		end

		if v20 then
			return v19.Key
		end
	end

	for _, v19 in ipairs(v3) do
		if canvasPointInsideRect(boardCanvasPoint, v18[v19.Key]) then -- inferred equivalent call
			return v19.Key
		end
	end

	return nil
end

local function getAdjustedScreenPoints(p)
	local guiInset = GuiService:GetGuiInset()
	return {
		p,
		Vector2.new(p.X, p.Y - guiInset.Y),
		Vector2.new(p.X - guiInset.X, p.Y - guiInset.Y),
		Vector2.new(p.X - guiInset.X, p.Y)
	}
end

local function handleManualBoardTabInput(vector2): boolean
	if os.clock() - v17 < 0.05 then
		return false
	end

	local v19 = false

	for _, v20 in ipairs(getAdjustedScreenPoints(vector2)) do
		for _, v21 in ipairs(v15) do
			local board = v21.Board
			local boardCanvasPoint = getBoardCanvasPoint(board, v20)

			if not boardCanvasPoint then
				continue
			end

			v19 = true
			local v22 = "x=" .. tostring((math.floor(boardCanvasPoint.X))) .. " y=" .. tostring((math.floor(boardCanvasPoint.Y)))
			local clickedPeriod = getClickedPeriod(board, boardCanvasPoint)

			local v23 = clickedPeriod and board.SwitchPeriod[clickedPeriod]

			if v23 then
				debugLog("RaycastHit", "board=" .. v21.Config.ModelName, "period=" .. clickedPeriod, v22)
				v23("RaycastFallback")
				return true
			end

			debugLog("RaycastBoardNoTab", "board=" .. v21.Config.ModelName, v22)
		end
	end

	if not v19 then
		debugLog(
			"RaycastMissAllBoards",
			"screenX=" .. tostring((math.floor(vector2.X))),
			"screenY=" .. tostring((math.floor(vector2.Y)))
		)
	end

	return false
end

local v19 = setupBoards()
v15 = v19

local function invalidateDonationLeaderboards()
	for k in pairs(v10) do
		if k:match("^DonatedLeaderboard:") or k:match("^RaisedLeaderboard:") then
			v10[k] = nil
		end
	end
end

task.spawn(function()
	local donationSystemMessage = Remotes:WaitForChild("DonationSystemMessage", 30)

	if donationSystemMessage and donationSystemMessage:IsA("RemoteEvent") then
		donationSystemMessage.OnClientEvent:Connect(function()
			invalidateDonationLeaderboards()
			task.delay(1, function()
				for _, v20 in ipairs(v15) do
					if v20.Config.Category == "RobuxDonated" or v20.Config.Category == "RobuxRaised" then
						refreshBoard(v20.Board, v20.Config, v7[v20.Config.ModelName])
					end
				end
			end)
		end)
	end
end)

local function findTabSwitchFromGuiObject(p)
	while p and p ~= PlayerGui do
		local v20 = switchPeriodsByButton[p]

		if v20 then
			return v20
		end

		p = p.Parent
	end

	return nil
end

local function trySwitchTabAtScreenPosition(vector2): boolean
	for _, v20 in ipairs(getAdjustedScreenPoints(vector2)) do
		local success, result = pcall(function()
			return PlayerGui:GetGuiObjectsAtPosition(v20.X, v20.Y)
		end)

		if not success then
			continue
		end

		for _, v21 in ipairs(result) do
			local v22 = v21
			local v23

			while true do
				if not v22 or v22 == PlayerGui then
					v23 = nil
					break
				end

				v23 = switchPeriodsByButton[v22]

				if v23 then
					break
				end

				v22 = v22.Parent
			end

			if v23 then
				debugLog("GuiObjectsAtPositionHit", v21:GetFullName())
				v23("GuiObjectsAtPosition")
				return true
			end
		end
	end

	return false
end

UserInputService.InputBegan:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local v20 = input.Position

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			v20 = UserInputService:GetMouseLocation()
		end

		local vector2 = Vector2.new(v20.X, v20.Y)

		if trySwitchTabAtScreenPosition(vector2) then
			return
		end

		handleManualBoardTabInput(vector2)
	end
end)

task.spawn(function()
	for _, duration in ipairs({ 8, 25, 65 }) do
		task.wait(duration)

		for _, v20 in ipairs(v19) do
			refreshBoard(v20.Board, v20.Config, v7[v20.Config.ModelName])
		end
	end
end)

task.spawn(function()
	while LocalPlayer.Parent do
		task.wait(120)

		for _, v20 in ipairs(v19) do
			refreshBoard(v20.Board, v20.Config, v7[v20.Config.ModelName])
		end
	end
end)

debugLog("Leaderboards Ready", "boards=" .. tostring(#v19))