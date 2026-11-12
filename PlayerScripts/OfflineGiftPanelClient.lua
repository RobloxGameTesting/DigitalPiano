local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local OfflineGiftPanelToggle = ReplicatedStorage:WaitForChild("OfflineGiftPanelToggle")
local offlineGiftPanelTemplate = ReplicatedStorage:WaitForChild("UI"):WaitForChild("OfflineGiftPanelTemplate")
local remotes = Workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local beginGamepassGift = remotes:WaitForChild("BeginGamepassGift")
local resolveGiftRecipient = remotes:WaitForChild("ResolveGiftRecipient")
local cancelPendingProductGift = remotes:WaitForChild("CancelPendingProductGift")

local offlineGiftPanel = nil
local panel = nil
local viewportSizeChangedConnection = nil
local promptProductPurchaseFinishedConnection = nil

local v = {
	blue = Color3.fromRGB(47, 123, 239),
	disabled = Color3.fromRGB(76, 88, 109),
	text = Color3.fromRGB(240, 245, 252),
	muted = Color3.fromRGB(160, 172, 191),
	row = Color3.fromRGB(40, 40, 40),
	rowSelected = Color3.fromRGB(54, 54, 54),
	rowStroke = Color3.fromRGB(60, 60, 60),
	rowStrokeSelected = Color3.fromRGB(92, 92, 92),
	rowMetaSelected = Color3.fromRGB(176, 184, 198)
}

local function trim(value) -- 4 equivalent calls inferred from this helper
	return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function setButtonText(button, value)
	if not button then
		return
	end

	local text = tostring(value or "")
	local textLabel = button:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		if button:IsA("TextButton") then
			button.Text = ""
			button.TextTransparency = 1
		end

		textLabel.Text = text
	elseif button:IsA("TextButton") then
		button.Text = text
		button.TextTransparency = 0
	end
end

local function setLabelText(instance, childName, value) -- 3 equivalent calls inferred from this helper
	local label = instance and instance:FindFirstChild(childName)

	if label and label:IsA("TextLabel") then
		label.Text = tostring(value or "")
	end
end

local function headshot(userId) -- 1 equivalent call inferred from this helper
	local v2 = math.floor(tonumber(userId) or 0)
	return "rbxthumb://type=AvatarHeadShot&id=" .. tostring(v2 <= 0 and 1 or v2) .. "&w=150&h=150"
end

local function setActionState(previewButton, p, p2) -- 2 equivalent calls inferred from this helper
	if not previewButton then
		return
	end

	previewButton.AutoButtonColor = p == true
	previewButton.Active = p == true
	previewButton.BackgroundColor3 = p == true and v.blue or v.disabled
	setButtonText(previewButton, p2)
end

local function closePanel() -- 1 equivalent call inferred from this helper
	if viewportSizeChangedConnection then
		viewportSizeChangedConnection:Disconnect()
		viewportSizeChangedConnection = nil
	end

	if promptProductPurchaseFinishedConnection then
		promptProductPurchaseFinishedConnection:Disconnect()
		promptProductPurchaseFinishedConnection = nil
	end

	if offlineGiftPanel then
		offlineGiftPanel:Destroy()
		offlineGiftPanel = nil
		panel = nil
	end
end

local function friendRowFromEntry(player)
	if type(player) ~= "table" then
		return nil
	end

	local userId = math.max(0, (math.floor(tonumber(player.Id or player.UserId) or 0)))

	if userId <= 0 or userId == LocalPlayer.UserId then
		return nil
	end

	return {
		Username = tostring(player.Username or player.UserName or userId),
		DisplayName = tostring(player.DisplayName or player.Username or player.UserName or "Friend"),
		UserId = userId,
		Source = "Friend"
	}
end

local function applyResponsiveLayout()
	if not panel then
		return
	end

	local currentCamera = Workspace.CurrentCamera
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
	local v2 = viewportSize.X <= 760 or viewportSize.Y <= 520
	local v3

	if v2 then
		if viewportSize.Y <= 430 then
			v3 = viewportSize.X > viewportSize.Y
		else
			v3 = false
		end
	else
		v3 = v2
	end

	local uiPadding = panel:FindFirstChildOfClass("UIPadding")
	local uiListLayout = panel:FindFirstChildOfClass("UIListLayout")
	local headerFrame = panel:FindFirstChild("HeaderFrame")
	local searchBox = panel:FindFirstChild("SearchBox")
	local selected = panel:FindFirstChild("Selected")
	local results = panel:FindFirstChild("Results")
	local divider1 = panel:FindFirstChild("Divider1")
	local divider2 = panel:FindFirstChild("Divider2")
	local previewButton = panel:FindFirstChild("PreviewButton")

	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.AutomaticSize = Enum.AutomaticSize.None

	if v2 then
		local v4 = v3 and 16 or 24
		local v5 = v3 and 10 or 20
		local v6 = v3 and 5 or 12
		local v7 = v3 and 34 or 40
		local v8 = v3 and 38 or 44
		local v9 = v3 and 18 or 20
		local v10 = v3 and 42 or 48
		local v11

		if v3 then
			v11 = math.min(390, (math.max(228, viewportSize.Y - 146)))
		else
			v11 = math.min(470, (math.max(340, viewportSize.Y - 80)))
		end

		local v12 = v5 * 2 + v7 + v8 + v9 + v10 + 2 + v6 * 6
		local v13 = math.max(v3 and 42 or 116, v11 - v12)
		local v14

		if v3 then
			v14 = math.min(v13, 150)
		else
			v14 = math.min(v13, 220)
		end

		panel.Position = UDim2.fromScale(0.5, v3 and 0.54 or 0.53)

		if v3 and viewportSize.X > 760 then
			panel.Size = UDim2.fromOffset(math.min(700, (math.max(420, viewportSize.X - 160))), v11)
		else
			panel.Size = UDim2.new(0.92, 0, 0, v11)
		end

		if uiPadding then
			uiPadding.PaddingTop = UDim.new(0, v5)
			uiPadding.PaddingBottom = UDim.new(0, v5)
			uiPadding.PaddingLeft = UDim.new(0, v4)
			uiPadding.PaddingRight = UDim.new(0, v4)
		end

		if uiListLayout then
			uiListLayout.Padding = UDim.new(0, v6)
		end

		if headerFrame and headerFrame:IsA("GuiObject") then
			headerFrame.Size = UDim2.new(1, 0, 0, v7)
		end

		if searchBox and searchBox:IsA("GuiObject") then
			searchBox.Size = UDim2.new(1, 0, 0, v8)
		end

		if selected and selected:IsA("TextLabel") then
			selected.Size = UDim2.new(1, 0, 0, v9)
			selected.TextSize = v3 and 12 or 14
		end

		if divider1 and divider1:IsA("GuiObject") then
			divider1.Size = UDim2.new(1, 10, 0, 1)
		end

		if divider2 and divider2:IsA("GuiObject") then
			divider2.Size = UDim2.new(1, 10, 0, 1)
		end

		if results and results:IsA("GuiObject") then
			results.Size = UDim2.new(1, 0, 0, v14)

			if results:IsA("ScrollingFrame") then
				results.ScrollBarThickness = v3 and 3 or 4
			end
		end

		if previewButton and previewButton:IsA("GuiObject") then
			previewButton.Size = UDim2.new(1, 0, 0, v10)
		end
	else
		panel.Position = UDim2.fromScale(0.52, 0.58)
		panel.Size = UDim2.fromOffset(440, 500)

		if uiPadding then
			uiPadding.PaddingTop = UDim.new(0, 24)
			uiPadding.PaddingBottom = UDim.new(0, 24)
			uiPadding.PaddingLeft = UDim.new(0, 24)
			uiPadding.PaddingRight = UDim.new(0, 24)
		end

		if uiListLayout then
			uiListLayout.Padding = UDim.new(0, 16)
		end

		if headerFrame and headerFrame:IsA("GuiObject") then
			headerFrame.Size = UDim2.new(1, 0, 0, 40)
		end

		if searchBox and searchBox:IsA("GuiObject") then
			searchBox.Size = UDim2.new(1, 0, 0, 44)
		end

		if selected and selected:IsA("TextLabel") then
			selected.Size = UDim2.new(1, 0, 0, 20)
			selected.TextSize = 14
		end

		if divider1 and divider1:IsA("GuiObject") then
			divider1.Size = UDim2.new(1, 10, 0, 1)
		end

		if divider2 and divider2:IsA("GuiObject") then
			divider2.Size = UDim2.new(1, 10, 0, 1)
		end

		if results and results:IsA("GuiObject") then
			results.Size = UDim2.new(1, 0, 0, 220)

			if results:IsA("ScrollingFrame") then
				results.ScrollBarThickness = 4
			end
		end

		if previewButton and previewButton:IsA("GuiObject") then
			previewButton.Size = UDim2.new(1, 0, 0, 48)
		end
	end
end

local function showPanel(p)
	closePanel() -- inferred equivalent call
	local v2 = type(p) == "table" and p or {}
	local itemTitle = tostring(v2.itemTitle or "this item")
	local v3 = math.max(0, (math.floor(tonumber(v2.assetId) or 0)))
	local purchaseKind = tostring(v2.purchaseKind or "")
	local v4 = nil
	local v5 = nil
	local selectionAccent = nil
	local v6 = nil
	local count = 0
	local v7 = nil
	local v8 = false
	local v9 = false
	local v10 = {}
	local count2 = 0
	local v11 = nil
	local flag = false

	offlineGiftPanel = offlineGiftPanelTemplate:Clone()
	offlineGiftPanel.Name = "OfflineGiftPanel"
	offlineGiftPanel.Enabled = true
	offlineGiftPanel:SetAttribute("OfflineGiftLive", true)
	offlineGiftPanel.Parent = PlayerGui

	local toast = offlineGiftPanel:FindFirstChild("Toast")

	if toast and toast:IsA("GuiObject") then
		toast.Visible = false
	end

	panel = offlineGiftPanel:WaitForChild("Panel")
	local headerFrame = panel:WaitForChild("HeaderFrame")
	local close = headerFrame:WaitForChild("Close")
	local searchBox = panel:WaitForChild("SearchBox")
	local results = panel:WaitForChild("Results")
	local selected = panel:WaitForChild("Selected")
	local previewButton = panel:WaitForChild("PreviewButton")
	local rowTemplate = results:FindFirstChild("RowTemplate") or results:FindFirstChild("Recipient1")
	local title = headerFrame and headerFrame:FindFirstChild("Title")

	if title and title:IsA("TextLabel") then
		title.Text = tostring("Global gift")
	end

	setLabelText(headerFrame, "Item", itemTitle) -- inferred equivalent call
	setButtonText(close, "x")
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search username or paste UserId"
	selected.Text = "Select a friend or searched player."

	if previewButton then
		previewButton.AutoButtonColor = false
		previewButton.Active = false
		previewButton.BackgroundColor3 = v.disabled
		setButtonText(previewButton, "Select Player")
	end

	if rowTemplate and rowTemplate:IsA("TextButton") then
		rowTemplate.Name = "RowTemplate"
		rowTemplate.Visible = false
	end

	for _, button in ipairs(results:GetChildren()) do
		if button:IsA("TextButton") and button ~= rowTemplate then
			button:Destroy()
		end
	end

	local function clearRows()
		for _, button in ipairs(results:GetChildren()) do
			if button:IsA("TextButton") and button ~= rowTemplate then
				button:Destroy()
			end
		end
	end

	local function styleRecipientRow(instance, p2)
		if not instance then
			return
		end

		local backgroundColor = if p2 then v.rowSelected else v.row
		instance.BackgroundColor3 = backgroundColor
		local uiStroke = instance:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			local color

			if p2 then
				color = v.rowStrokeSelected
			else
				color = v.rowStroke
			end

			uiStroke.Color = color
			uiStroke.Transparency = p2 and 0.08 or 0.5
			uiStroke.Thickness = p2 and 1.5 or 1
		end

		local name = instance:FindFirstChild("Name")

		if name and name:IsA("TextLabel") then
			name.TextColor3 = v.text
		end

		local meta = instance:FindFirstChild("Meta")

		if meta and meta:IsA("TextLabel") then
			local textColor = if p2 then v.rowMetaSelected else v.muted
			meta.TextColor3 = textColor
		end
	end

	local function stopSelectionAccentTween() -- 2 equivalent calls inferred from this helper
		if v6 then
			v6:Cancel()
			v6 = nil
		end
	end

	local function createSelectionAccent(parent)
		if selectionAccent and selectionAccent.Parent then
			return selectionAccent
		end

		selectionAccent = Instance.new("Frame")
		selectionAccent.Name = "SelectionAccent"
		selectionAccent.AnchorPoint = Vector2.new(0, 0.5)
		selectionAccent.Position = UDim2.new(0, 0, 0.5, 0)
		selectionAccent.Size = UDim2.fromOffset(3, 26)
		selectionAccent.BackgroundColor3 = v.blue
		selectionAccent.BackgroundTransparency = 1
		selectionAccent.BorderSizePixel = 0
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(1, 0)
		uiCorner.Parent = selectionAccent
		selectionAccent.Parent = parent
		return selectionAccent
	end

	local function centerY(p2) -- 2 equivalent calls inferred from this helper
		return p2.AbsolutePosition.Y + p2.AbsoluteSize.Y * 0.5
	end

	local function hideSelectionAccent(p2) -- 3 equivalent calls inferred from this helper
		local v12 = selectionAccent

		if not v12 then
			return
		end

		stopSelectionAccentTween() -- inferred equivalent call

		if p2 then
			local tween = TweenService:Create(
				v12,
				TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ BackgroundTransparency = 1 }
			)

			v6 = tween
			tween.Completed:Connect(function(p3)
				if p3 == Enum.PlaybackState.Completed and selectionAccent == v12 then
					v12:Destroy()
					selectionAccent = nil
				end

				if v6 == tween then
					v6 = nil
				end
			end)
			tween:Play()
		else
			v12:Destroy()

			if selectionAccent == v12 then
				selectionAccent = nil
			end
		end
	end

	local function moveSelectionAccent(p2, parent)
		if not parent then
			return
		end

		local selectionAccent2 = createSelectionAccent(parent)
		stopSelectionAccentTween() -- inferred equivalent call
		selectionAccent2.Parent = parent
		selectionAccent2.ZIndex = parent.ZIndex + 10
		selectionAccent2.Visible = true
		selectionAccent2.BackgroundTransparency = p2 and 0.08 or 1
		local v12 = not p2 and 0 or centerY(p2) - centerY(parent) -- inferred equivalent call

		selectionAccent2.Position = UDim2.new(0, 0, 0.5, v12)
		v6 = TweenService:Create(
			selectionAccent2,
			TweenInfo.new(p2 and 0.2 or 0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, 0, 0.5, 0), BackgroundTransparency = 0.08 }
		)

		v6:Play()
	end

	local function clearSelection(value) -- 2 equivalent calls inferred from this helper
		if v5 then
			hideSelectionAccent(true)
			styleRecipientRow(v5, false)
		end

		v4 = nil
		v5 = nil
		selected.Text = value or "Select a friend or searched player."
		local v12 = previewButton

		if not v12 then
			return
		end

		v12.AutoButtonColor = false
		v12.Active = false
		v12.BackgroundColor3 = v.disabled
		setButtonText(v12, "Select Player")
	end

	local function selectRow(player, clone)
		if flag then
			return
		end

		if v5 == clone then
			clearSelection() -- inferred equivalent call
		else
			local v12 = v5

			if v12 then
				styleRecipientRow(v12, false)
			end

			v4 = player
			v5 = clone
			styleRecipientRow(clone, true)
			moveSelectionAccent(v12, clone)
			selected.Text = "Selected @" .. tostring(player.Username or player.UserId)
			local v13 = previewButton
			local v14 = "Gift to @" .. tostring(player.Username or player.UserId)

			if not v13 then
				return
			end

			v13.AutoButtonColor = true
			v13.Active = true
			v13.BackgroundColor3 = v.blue or v.disabled
			setButtonText(v13, v14)
		end
	end

	local function addRow(player, layoutOrder)
		if not (rowTemplate and rowTemplate:IsA("TextButton")) then
			return
		end

		local clone = rowTemplate:Clone()
		clone.Name = "Recipient" .. tostring(layoutOrder)
		clone.LayoutOrder = layoutOrder
		clone.Visible = true
		clone.Parent = results
		clone.Text = ""
		clone.TextTransparency = 1
		styleRecipientRow(clone, false)

		local avatar = clone:FindFirstChild("Avatar")

		if avatar and avatar:IsA("ImageLabel") then
			avatar.Image = headshot(player.UserId) -- inferred equivalent call
		end

		setLabelText(clone, "Name", tostring(player.DisplayName or player.Username or "Player")) -- inferred equivalent call
		local v12 = "@" .. tostring(player.Username or player.UserId)
		local source = player.Source

		if type(source) == "string" and source ~= "" then
			v12 ..= "  " .. source
		end

		setLabelText(clone, "Meta", v12) -- inferred equivalent call
		clone.Activated:Connect(function()
			selectRow(player, clone)
		end)
	end

	local function renderRows(p2, value)
		hideSelectionAccent(false) -- inferred equivalent call
		clearRows()
		v4 = nil
		v5 = nil
		local v12 = previewButton

		if v12 then
			v12.AutoButtonColor = false
			v12.Active = false
			v12.BackgroundColor3 = v.disabled
			setButtonText(v12, "Select Player")
		end

		local v13 = type(p2) == "table" and p2 or {}

		if #v13 <= 0 then
			selected.Text = value or "No friends found. Search by username or UserId."
			return
		end

		selected.Text = "Select a friend or searched player."

		for i, v14 in ipairs(v13) do
			addRow(v14, i)
		end
	end

	local function appendFriendRows(p2)
		local v12 = type(p2) == "table" and p2 or {}

		for _, v13 in ipairs(v12) do
			count2 += 1
			addRow(v13, count2)
		end
	end

	local function renderLoadedFriends(value) -- 1 equivalent call inferred from this helper
		hideSelectionAccent(false) -- inferred equivalent call
		clearRows()
		v4 = nil
		v5 = nil
		count2 = 0
		local v12 = previewButton

		if v12 then
			v12.AutoButtonColor = false
			v12.Active = false
			v12.BackgroundColor3 = v.disabled
			setButtonText(v12, "Select Player")
		end

		if #v10 <= 0 then
			selected.Text = value or "No friends found. Search by username or UserId."
			return
		end

		selected.Text = "Select a friend or searched player."
		appendFriendRows(v10)
	end

	local fn

	local function maybeLoadMoreFriends()
		if trim(searchBox.Text) ~= "" or v9 or v8 or #v10 <= 0 then -- inferred equivalent call
			return
		end

		local y = results.AbsoluteWindowSize.Y

		if y <= 0 then
			y = results.AbsoluteSize.Y
		end

		local y2 = results.AbsoluteCanvasSize.Y
		local v12 = y2 <= y + 12
		local v13

		if results.CanvasPosition.Y > 0 then
			local v14 = results.CanvasPosition.Y + y
			v13 = y2 - 96 <= v14
		else
			v13 = false
		end

		if v12 or v13 then
			fn()
		end
	end

	fn = function()
		if v8 or v9 or trim(searchBox.Text) ~= "" then -- inferred equivalent call
			return
		end

		v8 = true

		if #v10 <= 0 then
			selected.Text = "Loading friends. Search by username or UserId."
		end

		task.spawn(function()
			local v12 = true
			local v13 = {}

			if v7 then
				if v7.IsFinished then
					v9 = true
					v12 = false
				elseif not pcall(function()
					v7:AdvanceToNextPageAsync()
				end) then
					v12 = false
					v9 = true
				end
			else
				local success, result = pcall(function()
					return Players:GetFriendsAsync(LocalPlayer.UserId)
				end)

				if success and result then
					v7 = result
				else
					v12 = false
					v9 = true
				end
			end

			if v12 and v7 then
				local success, result = pcall(function()
					return v7:GetCurrentPage()
				end)

				if success and type(result) == "table" then
					for _, v14 in ipairs(result) do
						local v15 = friendRowFromEntry(v14)

						if v15 then
							table.insert(v13, v15)
						end
					end

					v9 = v7.IsFinished == true
				else
					v12 = false
					v9 = true
				end
			end

			if not (offlineGiftPanel and panel and results.Parent) then
				return
			end

			v8 = false

			if trim(searchBox.Text) ~= "" then -- inferred equivalent call
				return
			end

			for _, v14 in ipairs(v13) do
				table.insert(v10, v14)
			end

			appendFriendRows(v13)

			if not v4 then
				if #v10 > 0 then
					selected.Text = "Select a friend or searched player."
				elseif v9 and v12 then
					selected.Text = "No friends found. Search by username or UserId."
				else
					selected.Text = "Friend list unavailable. Search by username or UserId."
				end
			end

			task.delay(0.1, maybeLoadMoreFriends)
		end)
	end

	local function runSearch(text)
		local v12 = trim(text) -- inferred equivalent call
		count += 1
		local v13 = count
		clearSelection() -- inferred equivalent call

		if v12 == "" then
			renderLoadedFriends(v8 and "Loading friends. Search by username or UserId." or "Friend list unavailable. Search by username or UserId.") -- inferred equivalent call

			if #v10 <= 0 then
				fn()
			else
				task.delay(0.1, maybeLoadMoreFriends)
			end
		else
			selected.Text = "Searching..."
			task.delay(0.45, function()
				if v13 ~= count or not offlineGiftPanel then
					return
				end

				local success, result = pcall(function()
					return resolveGiftRecipient:InvokeServer(v12)
				end)

				if v13 ~= count or not offlineGiftPanel then
					return
				end

				if success and type(result) == "table" and result.Ok == true then
					renderRows({
						{
							UserId = result.UserId,
							Username = result.Username,
							DisplayName = result.DisplayName
						}
					}, nil)
					return
				end

				local v14 = "Player could not be found."
				local v15

				if success and type(result) == "table" and result.Message then
					v15 = tostring(result.Message)
				else
					v15 = not success and "Search failed. Try again." or v14
				end

				renderRows({}, v15)
			end)
		end
	end

	local function beginGift()
		if flag then
			return
		end

		if purchaseKind ~= "Gamepass" then
			selected.Text = "Global gifting is available for gamepasses first."
			return
		end

		if v3 <= 0 then
			selected.Text = "This gamepass is missing an asset id."
			return
		end

		if not v4 then
			selected.Text = "Choose a recipient first."
			return
		end

		flag = true
		local v12 = previewButton

		if v12 then
			v12.AutoButtonColor = false
			v12.Active = false
			v12.BackgroundColor3 = v.disabled
			setButtonText(v12, "Preparing gift...")
		end

		selected.Text = "Preparing Roblox purchase prompt..."
		local success, result, v13, v14 = pcall(function()
			return beginGamepassGift:InvokeServer(v4.UserId, v3)
		end)

		local v15 = math.max(0, (math.floor(tonumber(v14) or 0)))

		if success and result == true and not (v15 <= 0) then
			v11 = v15
			selected.Text = tostring(v13 or "Complete the Robux prompt to send the gift.")
			local success2, result2 = pcall(function()
				MarketplaceService:PromptProductPurchase(LocalPlayer, v15)
			end)

			if not success2 then
				cancelPendingProductGift:FireServer(v15)
				v11 = nil
				flag = false
				selected.Text = "Could not open Roblox purchase prompt."
				warn("[OfflineGiftPanel] PromptProductPurchase failed:", result2)
				local v16 = previewButton
				local v17 = "Gift to @" .. tostring(v4.Username or v4.UserId)

				if not v16 then
					return
				end

				v16.AutoButtonColor = true
				v16.Active = true
				v16.BackgroundColor3 = v.blue or v.disabled
				setButtonText(v16, v17)
			end
		else
			flag = false
			v11 = nil
			selected.Text = not success and "Gift could not be started."
				or tostring(v13 or "Gift could not be started.")
			setActionState( -- inferred equivalent call
				previewButton,
				v4 ~= nil,
				v4 and "Gift to @" .. tostring(v4.Username or v4.UserId) or "Select Player"
			)
		end
	end

	close.Activated:Connect(closePanel)
	previewButton.Activated:Connect(beginGift)
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		runSearch(searchBox.Text)
	end)
	results:GetPropertyChangedSignal("CanvasPosition"):Connect(maybeLoadMoreFriends)

	promptProductPurchaseFinishedConnection = MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, p2, p3)
		local v12 = math.max(0, (math.floor(tonumber(p2) or 0)))

		if v11 == nil or v12 ~= v11 then
			return
		end

		if p3 then
			selected.Text = "Gift queued globally. If they are not reachable now, they will receive it when their data loads."
			local v13 = previewButton

			if v13 then
				v13.AutoButtonColor = false
				v13.Active = false
				v13.BackgroundColor3 = v.disabled
				setButtonText(v13, "Gift queued")
			end

			task.delay(1.25, closePanel)
		else
			cancelPendingProductGift:FireServer(v11)
			v11 = nil
			flag = false
			selected.Text = "Gift cancelled."
			setActionState( -- inferred equivalent call
				previewButton,
				v4 ~= nil,
				v4 and "Gift to @" .. tostring(v4.Username or v4.UserId) or "Select Player"
			)
		end
	end)

	applyResponsiveLayout()
	local position = panel.Position
	panel.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 18)
	TweenService:Create(panel, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = position
	}):Play()

	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		viewportSizeChangedConnection = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
	end

	hideSelectionAccent(false) -- inferred equivalent call
	clearRows()
	v4 = nil
	v5 = nil
	count2 = 0

	if previewButton then
		previewButton.AutoButtonColor = false
		previewButton.Active = false
		previewButton.BackgroundColor3 = v.disabled
		setButtonText(previewButton, "Select Player")
	end

	if #v10 <= 0 then
		selected.Text = "Loading friends. Search by username or UserId."
	else
		selected.Text = "Select a friend or searched player."
		appendFriendRows(v10)
	end

	fn()
end

OfflineGiftPanelToggle.Event:Connect(showPanel)