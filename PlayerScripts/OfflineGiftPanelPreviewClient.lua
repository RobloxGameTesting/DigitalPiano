local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local OfflineGiftPreviewToggle = ReplicatedStorage:WaitForChild("OfflineGiftPreviewToggle")

local v = nil
local v2 = nil
local viewportSizeChangedConnection = nil
local v3 = nil

local v4 = {
	background = Color3.fromRGB(15, 18, 24),
	panel = Color3.fromRGB(25, 31, 41),
	panelSoft = Color3.fromRGB(34, 41, 53),
	field = Color3.fromRGB(12, 15, 20),
	stroke = Color3.fromRGB(69, 82, 104),
	blue = Color3.fromRGB(47, 123, 239),
	text = Color3.fromRGB(240, 245, 252),
	muted = Color3.fromRGB(160, 172, 191)
}

local function make(className, options, parent)
	local instance = Instance.new(className)

	for k, v5 in pairs(options or {}) do
		instance[k] = v5
	end

	instance.Parent = parent
	return instance
end

local function corner(parent, cornerRadius) -- 4 equivalent calls inferred from this helper
	make("UICorner", {
		CornerRadius = UDim.new(0, cornerRadius or 8)
	}, parent)
end

local function stroke(parent, p, value, value2) -- 2 equivalent calls inferred from this helper
	make("UIStroke", {
		Color = p or v4.stroke,
		Transparency = value or 0,
		Thickness = value2 or 1
	}, parent)
end

local function padding(parent, value, value2, p, p2)
	make("UIPadding", {
		PaddingLeft = UDim.new(0, value or 0),
		PaddingTop = UDim.new(0, value2 or 0),
		PaddingRight = UDim.new(0, p or value or 0),
		PaddingBottom = UDim.new(0, p2 or value2 or 0)
	}, parent)
end

local function label(parent, name, text, value, p, p2, options)
	local v5 = options or {}
	v5.Name = name
	v5.Text = text
	v5.TextSize = value or 14
	v5.Font = p or Enum.Font.Gotham
	v5.TextColor3 = p2 or v4.text
	v5.BackgroundTransparency = 1
	v5.BorderSizePixel = 0
	v5.TextXAlignment = v5.TextXAlignment or Enum.TextXAlignment.Left
	v5.TextYAlignment = v5.TextYAlignment or Enum.TextYAlignment.Center

	if v5.TextWrapped == nil then
		v5.TextWrapped = true
	end

	return make("TextLabel", v5, parent)
end

local function button(parent, name, text, p, p2, options)
	local v5 = options or {}
	v5.Name = name
	v5.Text = text
	v5.BackgroundColor3 = p or v4.blue
	v5.TextColor3 = p2 or Color3.new(1, 1, 1)
	v5.Font = v5.Font or Enum.Font.GothamBold
	v5.TextSize = v5.TextSize or 13
	v5.BorderSizePixel = 0
	v5.AutoButtonColor = true
	v5.TextWrapped = true
	local parent2 = make("TextButton", v5, parent)
	corner(parent2, v5.CornerRadius or 8) -- inferred equivalent call
	return parent2
end

local function headshot(userId) -- 1 equivalent call inferred from this helper
	local v5 = math.floor(tonumber(userId) or 1)
	return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(v5 <= 0 and 1 or v5) .. "&w=150&h=150"
end

local function fallbackFriends()
	return {
		{
			Username = "MusicFriend",
			DisplayName = "Music Friend",
			UserId = LocalPlayer.UserId > 0 and LocalPlayer.UserId or 1,
			Source = "Friend preview"
		},
		{
			Username = "PianoBuddy",
			DisplayName = "Piano Buddy",
			UserId = 1,
			Source = "Friend preview"
		},
		{
			Username = "OfflinePianist",
			DisplayName = "Offline Pianist",
			UserId = 156,
			Source = "Friend preview"
		}
	}
end

local function fetchFriends()
	local friends = {}
	local success, result = pcall(function()
		return Players:GetFriendsAsync(LocalPlayer.UserId)
	end)

	if success and result then
		repeat
			local success2, result2 = pcall(function()
				return result:GetCurrentPage()
			end)

			if not success2 then
				break
			end

			for _, v5 in ipairs(result2) do
				table.insert(friends, {
					Username = v5.Username or v5.UserName or tostring(v5.Id),
					DisplayName = v5.DisplayName or v5.Username or v5.UserName or "Friend",
					UserId = v5.Id,
					Source = "Friend"
				})

				if #friends >= 24 then
					break
				end
			end
		until #friends >= 24 or result.IsFinished or not pcall(function()
			result:AdvanceToNextPageAsync()
		end)
	end

	if #friends == 0 then
		friends = fallbackFriends()
	end

	v3 = friends
	return friends
end

local function clearRows(instance)
	for _, uiListLayout in ipairs(instance:GetChildren()) do
		if not uiListLayout:IsA("UIListLayout") then
			uiListLayout:Destroy()
		end
	end
end

local function closePanel() -- 1 equivalent call inferred from this helper
	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
		viewportSizeChangedConnection = nil
	end

	if v then
		v:Destroy()
		v = nil
		v2 = nil
	end
end

local function applyResponsiveLayout()
	if not v2 then
		return
	end

	local currentCamera = Workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)

	if viewportSize.X <= 760 or viewportSize.Y <= 520 then
		v2.AnchorPoint = Vector2.new(0.5, 0)
		v2.Position = UDim2.fromScale(0.5, 0.08)
		v2.Size = UDim2.new(0.9, 0, 0, 306)
	else
		v2.AnchorPoint = Vector2.new(0.5, 0.5)
		v2.Position = UDim2.fromScale(0.52, 0.58)
		v2.Size = UDim2.fromOffset(410, 332)
	end
end

local function showPanel(p)
	closePanel() -- inferred equivalent call
	local itemTitle = tostring((type(p) == "table" and p or {}).itemTitle or "this item")
	local username = nil

	v = make("ScreenGui", {
		Name = "OfflineGiftPanelPreview",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		DisplayOrder = 4310,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}, PlayerGui)

	v:SetAttribute("CodexPreviewOnly", true)
	v:SetAttribute("NoBackendCalls", true)

	v2 = make("Frame", { Name = "Panel", BackgroundColor3 = v4.panel, BorderSizePixel = 0 }, v)
	corner(v2, 10) -- inferred equivalent call
	stroke(v2, Color3.fromRGB(80, 145, 255), 0.18) -- inferred equivalent call
	padding(v2, 14, 12, 14, 14)

	label(v2, "Title", "Global gift", 20, Enum.Font.GothamBlack, v4.text, {
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -38, 0, 26),
		TextWrapped = false,
		TextTruncate = Enum.TextTruncate.AtEnd
	})

	button(v2, "Close", "X", Color3.fromRGB(49, 58, 73), v4.text, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(30, 30),
		TextSize = 12
	})

	label(v2, "Item", itemTitle, 12, Enum.Font.Gotham, v4.muted, {
		Position = UDim2.new(0, 0, 0, 30),
		Size = UDim2.new(1, 0, 0, 18),
		TextWrapped = false,
		TextTruncate = Enum.TextTruncate.AtEnd
	})

	local parent = make("TextBox", {
		Name = "SearchBox",
		Position = UDim2.new(0, 0, 0, 58),
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = v4.field,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = "Search username or paste UserId",
		PlaceholderColor3 = v4.muted,
		Text = "",
		TextColor3 = v4.text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	}, v2)
	corner(parent) -- inferred equivalent call
	padding(parent, 10, 0, 10, 0)

	local parent2 = make("ScrollingFrame", {
		Name = "Results",
		Position = UDim2.new(0, 0, 0, 104),
		Size = UDim2.new(1, 0, 1, -184),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(88, 104, 132),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0)
	}, v2)

	make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }, parent2)

	local v5 = label(v2, "Selected", "Select a friend or searched player.", 12, Enum.Font.Gotham, v4.muted, {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -48),
		Size = UDim2.new(1, 0, 0, 18),
		TextWrapped = false,
		TextTruncate = Enum.TextTruncate.AtEnd
	})

	local v6 = button(
		v2,
		"PreviewButton",
		"Preview only - backend not connected",
		Color3.fromRGB(76, 88, 109),
		Color3.fromRGB(224, 231, 242),
		{
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 40),
			TextSize = 13
		}
	)

	local function selectRow(player) -- 1 equivalent call inferred from this helper
		username = player.Username or player.DisplayName or "Player"
		v5.Text = "Selected @" .. username .. " (preview only)"
		v6.Text = "Would gift to @" .. username
		v6.BackgroundColor3 = v4.blue
	end

	local function addRow(player, i)
		local parent3 = button(parent2, "Recipient" .. tostring(i), "", v4.panelSoft, v4.text, {
			LayoutOrder = i,
			Size = UDim2.new(1, -4, 0, 54),
			TextTransparency = 1
		})

		stroke(parent3, v4.stroke, 0.35) -- inferred equivalent call

		corner(make("ImageLabel", { -- inferred equivalent call
			Name = "Avatar",
			Position = UDim2.new(0, 8, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = v4.field,
			BorderSizePixel = 0,
			Image = headshot(player.UserId) -- inferred equivalent call
		}, parent3), 19)

		label(parent3, "Name", player.DisplayName or player.Username or "Player", 13, Enum.Font.GothamBold, v4.text, {
			Position = UDim2.new(0, 56, 0, 8),
			Size = UDim2.new(1, -66, 0, 18),
			TextWrapped = false,
			TextTruncate = Enum.TextTruncate.AtEnd
		})

		label(
			parent3,
			"Meta",
			"@" .. tostring(player.Username or player.UserId or "Player") .. "  " .. tostring(player.Source or "Preview"),
			11,
			Enum.Font.Gotham,
			v4.muted,
			{
				Position = UDim2.new(0, 56, 0, 28),
				Size = UDim2.new(1, -66, 0, 16),
				TextWrapped = false,
				TextTruncate = Enum.TextTruncate.AtEnd
			}
		)

		parent3.MouseButton1Click:Connect(function()
			selectRow(player) -- inferred equivalent call
		end)
	end

	local function renderRows(value)
		clearRows(parent2)
		local username2 = tostring(value or "")
		local v7

		if username2 == "" then
			v7 = v3 or fallbackFriends()
		else
			local v8 = tonumber(username2)

			v7 = v8 and v8 > 0 and {
				{
					Username = tostring((math.floor(v8))),
					DisplayName = "UserId " .. tostring((math.floor(v8))),
					UserId = math.floor(v8),
					Source = "Searched UserId"
				}
			} or {
				{
					Username = username2,
					DisplayName = "Search result preview",
					UserId = 1,
					Source = "Username lookup needed"
				}
			}
		end

		for i, v8 in ipairs(v7) do
			addRow(v8, i)
		end
	end

	parent:GetPropertyChangedSignal("Text"):Connect(function()
		username = nil
		v5.Text = parent.Text == "" and "Select a friend or searched player."
			or "Search preview. Select the result row."
		v6.Text = "Preview only - backend not connected"
		v6.BackgroundColor3 = Color3.fromRGB(76, 88, 109)
		renderRows(parent.Text)
	end)

	v2.Close.MouseButton1Click:Connect(closePanel)
	v6.MouseButton1Click:Connect(function()
		if username then
			v5.Text = "Preview selected @" .. username .. ". Real gift would wait for receipt."
		else
			v5.Text = "Choose a recipient first."
		end
	end)

	renderRows("")
	task.spawn(function()
		fetchFriends()

		if v and parent.Text == "" then
			renderRows("")
		end
	end)

	applyResponsiveLayout()
	local position = v2.Position
	v2.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 18)

	TweenService:Create(v2, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = position
	}):Play()

	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
	end
end

OfflineGiftPreviewToggle.Event:Connect(showPanel)