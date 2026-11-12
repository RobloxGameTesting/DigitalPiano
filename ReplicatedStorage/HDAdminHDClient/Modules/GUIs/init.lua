local GUIs = {}

local HDAdminMain = _G.HDAdminMain
local module = HDAdminMain:GetModule("Signal").new()
local v = nil

local v2 = {
	About = { "Soon" },
	Revenue = { "Soon" },
	Commands = { "Commands" },
	Boost = { "Buy" },
	Moderation = { "Ranks", "Server Ranks", "Banland" },
	Settings = { "Custom" }
}

local mainFrame = HDAdminMain.gui.MainFrame
local dragBar = mainFrame.DragBar
local imageButton = HDAdminMain.gui.CustomTopBar.ImageButton
local pages = mainFrame.Pages
local v3 = pages.Home

local bindableEvent = Instance.new("BindableEvent")

local function displayHomeArrowIcons(visible)
	for _, child in pairs(mainFrame.Pages.Home:GetChildren()) do
		if child:FindFirstChild("Arrow") then
			child.Arrow.Visible = visible
		end
	end
end

local function updateDragBar(p, p2)
	local v4 = p or v3

	if p2 == nil then
		p2 = v3:GetAttribute("HideBack")
	end

	local v5 = v4.Name == "Home"
	local udim = UDim2.new(0.04, 0, 0.15, 0)

	if v5 then
		dragBar.Left.Title.Text = "Dashboard"
		dragBar.Left.Back.Visible = false
		dragBar.Left.Gap2.Visible = false
		dragBar.Left.Nanoblox.Visible = true
		dragBar.Left.Title.Position = udim
		displayHomeArrowIcons(true)
	else
		if p2 then
			dragBar.Left.Back.Visible = false
			dragBar.Left.Title.Position = udim
			dragBar.Left.Gap2.Visible = true
		else
			dragBar.Left.Back.Visible = true
			dragBar.Left.Title.Position = UDim2.new(0.15, 0, 0.15, 0)
			dragBar.Left.Gap2.Visible = false
		end

		local name = v4.Name
		local text = name == "Boost" and "Unlock" or name

		dragBar.Left.Nanoblox.Visible = false
		dragBar.Left.Title.Text = text
		displayHomeArrowIcons(false)
	end
end

local function updateSearchbar(instance, visible)
	local searchBar = instance:FindFirstChild("SearchBar")

	if searchBar then
		if visible == nil then
			visible = searchBar.Visible
		end

		if searchBar.Visible ~= visible then
			searchBar.Visible = visible
		end

		local v4 = visible and 0.92 or 1

		for _, scrollingFrame in pairs(instance:GetChildren()) do
			if scrollingFrame:IsA("ScrollingFrame") then
				scrollingFrame.Size = UDim2.new(1, 0, v4, 0)
			end
		end
	end
end

local function tweenPages(position, p, p2)
	local tweenInfo = TweenInfo.new(p2 and 0 or 0.3, Enum.EasingStyle.Quad)
	local v4 = v3
	local v5 = HDAdminMain.tweenService:Create(v3, tweenInfo, { Position = position })
	local v6 = HDAdminMain.tweenService:Create(p, tweenInfo, { Position = UDim2.new(0, 0, 0, 0) })

	if p.Name == "Home" then
		p.Position = UDim2.new(-1, 0, 0, 0)
	else
		p.Position = UDim2.new(1, 0, 0, 0)

		if p.Name == "Moderation" then
			spawn(function()
				HDAdminMain:GetModule("PageModeration"):UpdatePages()
			end)
		end
	end

	if v4.Name == "Home" and not p2 then
		updateSearchbar(p, true)
	end

	p.Visible = true
	v5:Play()
	v6:Play()
	v3 = p
	v = p.Name
	module:Fire(p.Name)
	updateDragBar()
	v6.Completed:Wait()
	v4.Visible = false
end

mainFrame.Visible = false
local flag = true

for _, button in pairs(pages.Home:GetChildren()) do
	if not button:IsA("TextButton") then
		continue
	end

	local fade = button.Fade
	local function pressButton() -- 1 equivalent call inferred from this helper
		if flag then
			flag = false
			local child = pages:FindFirstChild(button.Name)

			if child then
				tweenPages(UDim2.new(-1, 0, 0, 0), child)
			end

			flag = true
		end
	end
	local rankBlocker = button:FindFirstChild("RankBlocker")
	button.MouseButton1Click:Connect(function()
		if rankBlocker and rankBlocker.Visible then
			return
		end

		pressButton() -- inferred equivalent call
	end)
	button.InputBegan:Connect(function(_)
		HDAdminMain.tweenService:Create(fade, TweenInfo.new(0.2), { BackgroundTransparency = 0.95 }):Play()
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			return
		end

		HDAdminMain.tweenService:Create(fade, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
	end)
end

local function navigateNewPage(child, p, p2, p3, p4)
	local tweenInfo = TweenInfo.new(p4 and 0 or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local v4 = v2[child.Name]
	local scrollingFrame

	if tonumber(p) then
		local v5 = v4[p]
		scrollingFrame = v5 and child[v5]
	else
		scrollingFrame = nil
	end

	local v5 = v4[p2]
	local scrollingFrame2 = v5 and child[v5]

	if not scrollingFrame2 then
		return
	end

	if scrollingFrame and scrollingFrame:IsA("ScrollingFrame") then
		scrollingFrame.ScrollBarImageTransparency = 1
	end

	if scrollingFrame2:IsA("ScrollingFrame") then
		scrollingFrame2.ScrollBarImageTransparency = 0
	end

	updateSearchbar(child)

	for _, v6 in pairs(v4) do
		local v7 = child[v6]

		if v7 ~= scrollingFrame2 and v7 ~= scrollingFrame then
			v7.Position = UDim2.new(-2, 0, v7.Position.Y.Scale, 0)
		end
	end

	local v6 = p3 == "Right" and 1 or p3 == "Left" and -1 or nil

	local v7 = v6 * -1

	if child:FindFirstChild("NavigateButtons") then
		child.NavigateButtons.TextLabel.Text = scrollingFrame2.Name
	end

	scrollingFrame2.Position = UDim2.new(v6, 0, scrollingFrame2.Position.Y.Scale, scrollingFrame2.Position.Y.Offset)
	HDAdminMain.tweenService:Create(scrollingFrame2, tweenInfo, {
		Position = UDim2.new(0, 0, scrollingFrame2.Position.Y.Scale, 0)
	}):Play()

	if scrollingFrame then
		local v8 = HDAdminMain.tweenService:Create(scrollingFrame, tweenInfo, {
			Position = UDim2.new(v7, 0, scrollingFrame.Position.Y.Scale, 0)
		})
		v8:Play()
		spawn(function()
			v8.Completed:Wait()

			if scrollingFrame.Position.X.Scale == v7 then
				scrollingFrame.Position = UDim2.new(-2, 0, scrollingFrame.Position.Y.Scale, 0)
			end
		end)
	end
end

for _, child in pairs(pages:GetChildren()) do
	if not child:FindFirstChild("NavigateButtons") then
		continue
	end

	local v4 = v2[child.Name]
	local v5 = 0
	local v6 = 1

	for k, text in pairs(v4) do
		local v7 = child[text]

		if k == 1 then
			child.NavigateButtons.TextLabel.Text = text
		else
			v5 = 1
		end

		v7.Position = UDim2.new(v5, 0, v7.Position.Y.Scale, 0)
		v7.Visible = true
	end

	for _, button in pairs(child.NavigateButtons:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v7 = button
		button.MouseButton1Down:Connect(function()
			local v8 = v6

			if v7.Name == "Right" then
				v6 += 1

				if v6 > #v4 then
					v6 = 1
				end
			elseif v7.Name == "Left" then
				v6 -= 1

				if v6 < 1 then
					v6 = #v4
				end
			end

			navigateNewPage(child, v8, v6, v7.Name)
		end)
	end
end

local left = dragBar.Left
local right = dragBar.Right
local function applyCallback(p, fn) -- 4 equivalent calls inferred from this helper
	p.MouseButton1Down:Connect(function(...)
		if flag then
			flag = false
			fn(p)
			flag = true
		end
	end)
end
local function fn()
	tweenPages(UDim2.new(1, 0, 0, 0), pages.Home)
end

applyCallback(left.Back, fn) -- inferred equivalent call

local function fn2(p)
	if p.TextLabel.Text == "-" then
		HDAdminMain.tweenService:Create(pages, TweenInfo.new(0.5), {
			Position = UDim2.new(0, 0, -0.79, 0)
		}):Play()
		p.TextLabel.Text = "+"
	else
		pages.Parent.Visible = true
		HDAdminMain.tweenService:Create(pages, TweenInfo.new(0.5), {
			Position = UDim2.new(0, 0, 0.1, 0)
		}):Play()
		p.TextLabel.Text = "-"
	end
end

applyCallback(right.Minimise, fn2) -- inferred equivalent call

local function fn3()
	GUIs:CloseMainFrame()
end

applyCallback(right.Close, fn3) -- inferred equivalent call

local module2 = HDAdminMain:GetModule("CmdBar")
local toggleCmdbar = right.ToggleCmdbar
local backgroundTransparency = toggleCmdbar.BackgroundTransparency
local function updateCmdbarToggle() -- 2 equivalent calls inferred from this helper
	if module2.isOpen then
		toggleCmdbar.BackgroundTransparency = 0.25
	else
		toggleCmdbar.BackgroundTransparency = backgroundTransparency
	end

	toggleCmdbar.Visible = HDAdminMain.pdata.Rank > 0 and v == "Commands" and HDAdminMain.device == "Computer"
end
local function fn4()
	updateCmdbarToggle() -- inferred equivalent call

	if module2.isOpen then
		module2:CloseCmdBar()
	else
		module2:OpenCmdBar()
	end

	updateCmdbarToggle() -- inferred equivalent call
end

applyCallback(toggleCmdbar, fn4) -- inferred equivalent call
module2.cmdbarToggled:Connect(updateCmdbarToggle)
task.defer(function()
	HDAdminMain:GetModule("cf"):GetRankChangedSignal():Connect(updateCmdbarToggle)
end)
module:Connect(updateCmdbarToggle)

function GUIs:OpenMainFrame()
	local module3 = HDAdminMain:GetModule("TopbarIcons")
	local dashboard = module3.Dashboard
	local commands = module3.Commands

	if not (commands.isEnabled and commands.isSelected) then
		dashboard:select()
	end
end

function GUIs:CloseMainFrame()
	local module3 = HDAdminMain:GetModule("TopbarIcons")
	module3.Dashboard:deselect()
	module3.Commands:deselect()
end
task.defer(function()
	local module3 = HDAdminMain:GetModule("TopbarIcons")
	module3.Dashboard:bindEvent("deselected", function()
		bindableEvent:Fire()
	end)
	module3.Commands:bindEvent("deselected", function()
		bindableEvent:Fire()
	end)
end)
GUIs:CloseMainFrame()
updateDragBar()

local v4 = {}
function GUIs:ShowSpecificPage(p, p2, value, p3, p4, p5)
	local v5 = false

	if p == "Boost" and p2 == "Buy" then
		if not p5 then
			if value ~= true then
				task.defer(function()
					local module3 = HDAdminMain:GetModule("cf")

					if not module3:HasBooster() then
						module3:PromptGamepass(HDAdminMain.player, "Booster")
					end
				end)
			end

			v5 = value ~= false or false
		end

		bindableEvent.Event:Once(function()
			HDAdminMain:GetModule("PageBooster"):OfferOnClose()
			HDAdminMain:GetModule("GUIs"):ShowSpecificPage("Commands")
		end)
	end

	if value then
		v5 = true

		if typeof(value) ~= "string" then
			value = nil
		end
	end

	for _, child in pairs(pages:GetChildren()) do
		if child.Name == p then
			if v5 then
				updateSearchbar(child, p4 == true)
				bindableEvent.Event:Once(function()
					local module3 = HDAdminMain:GetModule("PageCommands")

					if module3:GetSearchText() == "Booster" then
						module3:SetSearchText("")
						HDAdminMain:GetModule("PageBooster"):OfferOnClose()
					end

					updateSearchbar(child, true)
				end)

				if value then
					local backOverride = dragBar.Left.Back.BackOverride
					local mouseButton1DownConnection = nil
					local function endConnection() -- 1 equivalent call inferred from this helper
						if mouseButton1DownConnection then
							mouseButton1DownConnection:Disconnect()
							mouseButton1DownConnection = nil
							backOverride.Visible = false
						end
					end
					backOverride.Visible = true
					mouseButton1DownConnection = backOverride.MouseButton1Down:Connect(function()
						endConnection() -- inferred equivalent call
						GUIs:ShowSpecificPage(value, p3, v4[value] == true, nil, nil, true)
					end)
					bindableEvent.Event:Once(endConnection)
					child:SetAttribute("HideBack", nil)
				else
					child:SetAttribute("HideBack", true)
					v4[p] = true
					bindableEvent.Event:Once(function()
						task.wait()
						child:SetAttribute("HideBack", nil)
						v4[p] = nil
						updateDragBar(child)
					end)
				end

				updateDragBar(child)
			end

			if p == "Boost" and p2 == "Buy" then
				child:SetAttribute("HideBack", true)
			end

			if v3 == child then
				child.Visible = true
				updateDragBar(child)
			else
				tweenPages(UDim2.new(-1, 0, 0, 0), child, true)
			end

			local v6 = v2[child.Name]

			if v6 then
				local v7 = nil
				local v8 = nil

				for k, v9 in pairs(v6) do
					local v10 = child[v9]

					if v10.Name == p2 then
						v8 = k
					elseif v10.Position.X.Scale == 0 then
						v7 = k
					end
				end

				if v7 == nil then
					for i = 1, #v6 do
						if i ~= v8 then
							v7 = i
						end
					end
				end

				if p == "Moderation" and v3.Name == "Moderation" then
					spawn(function()
						HDAdminMain:GetModule("PageModeration"):UpdatePages()
					end)
				end

				if p2 ~= nil then
					GUIs:OpenMainFrame()
				end

				if child:FindFirstChild("NavigateButtons") then
					navigateNewPage(child, v7, v8, "Left", true)
				end
			end
		else
			child.Visible = false
		end
	end

	v = p
	module:Fire(p)
end
GUIs:ShowSpecificPage("Home")

local function showLoading(child, p) -- 6 equivalent calls inferred from this helper
	if p then
		child.LoadingButton.Visible = true
		child.MainButton.Visible = false
	else
		child.LoadingButton.Visible = false
		child.MainButton.Visible = true
	end
end

for _, child in pairs(HDAdminMain.warnings:GetChildren()) do
	child.CloseX.MouseButton1Down:Connect(function()
		HDAdminMain.warnings.Visible = false
	end)
	local mainButton = child:FindFirstChild("MainButton")

	if not mainButton then
		continue
	end

	local flag2 = true
	mainButton.MouseButton1Down:Connect(function()
		if flag2 then
			flag2 = false

			if child.Name == "BuyFrame" then
				local value = mainButton.ProductId.Value

				if mainButton.ProductType.Value == "Gamepass" then
					HDAdminMain:GetModule("cf"):PromptGamepass(HDAdminMain.player, value)
				else
					HDAdminMain.marketplaceService:PromptPurchase(HDAdminMain.player, value)
				end
			elseif child.Name == "UnBan" then
				showLoading(child, true) -- inferred equivalent call
				HDAdminMain.signals.RequestCommandModification:InvokeServer(HDAdminMain.pdata.Prefix .. "undirectban " .. child.PlrName.Text)
				HDAdminMain:GetModule("PageModeration"):CreateBanland()
				showLoading(child, false) -- inferred equivalent call
				HDAdminMain.warnings.Visible = false
			elseif child.Name == "PermRank" then
				showLoading(child, true) -- inferred equivalent call
				local text = child.PlrName.Text
				local v5 = { HDAdminMain:GetModule("cf"):GetUserId(text), text }
				HDAdminMain.signals.RemovePermRank:InvokeServer(v5)
				HDAdminMain:GetModule("PageModeration"):CreateRanks()
				showLoading(child, false) -- inferred equivalent call
				HDAdminMain.warnings.Visible = false
			elseif child.Name == "Teleport" then
				showLoading(child, true) -- inferred equivalent call
				local value = child.MainButton.PlaceId.Value
				HDAdminMain.teleportService:Teleport(value)
				HDAdminMain.teleportService.TeleportInitFailed:Wait()
				showLoading(child, false) -- inferred equivalent call
			end

			flag2 = true
		end
	end)
end

HDAdminMain.warnings.Visible = false

function GUIs.DisplayPagesAccordingToRank(_, _)
	local home = pages and pages:FindFirstChild("Home")

	if not home then
		return
	end

	for childName, v5 in pairs(HDAdminMain.settings.RankRequiredToViewPage) do
		local child = home:FindFirstChild(childName)
		local v6 = tonumber(v5) or 0

		if not child then
			continue
		end

		local rankBlocker = child.RankBlocker

		if childName == "About" or not (HDAdminMain.pdata.Rank < v6) then
			child.RankBlocker.Visible = false
		else
			local rankName = HDAdminMain:GetModule("cf"):GetRankName(v6)
			rankBlocker.Visible = true
			rankBlocker.Active = false
			rankBlocker.TextLabel.Text = rankName .. "+"

			for _, guiObject in pairs(rankBlocker:GetChildren()) do
				if guiObject:IsA("GuiObject") then
					guiObject.Visible = false
				end
			end

			if not rankBlocker:GetAttribute("WarningActive") then
				rankBlocker:SetAttribute("WarningActive", true)
				rankBlocker.MouseButton1Click:Connect(function()
					HDAdminMain:GetModule("Notices"):Notice(
						"Error",
						HDAdminMain.hdAdminCoreName,
						`Rank '{rankName}' is required to view this page.`
					)
					HDAdminMain:GetModule("cf"):CheckPromptRank(v6)
				end)
			end
		end
	end
end

function GUIs.UpdateFont(_)
	task.defer(function()
		local count = 0
		local appFont = HDAdminMain.settings.AppFont

		if not appFont then
			return
		end

		local font = nil
		local typeName = typeof(appFont)

		if typeName == "number" then
			font = Font.fromId(appFont)
		elseif typeName == "EnumItem" then
			font = Font.fromEnum(appFont)
		elseif typeName == "string" and not appFont:match("rbxasset") then
			font = Font.fromName(appFont)
		end

		local fontFace = font or Font.new(appFont)

		if fontFace.Family == "rbxasset://fonts/families/SourceSansPro.json" then
			return
		end

		for _, descendant in pairs(HDAdminMain.gui:GetDescendants()) do
			if not (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
				continue
			end

			local parent = descendant.Parent
			local name = parent and parent.Name

			if not (name ~= "Minimise" and name ~= "Close") then
				continue
			end

			descendant.FontFace = fontFace
			count += 1

			if count % 20 == 0 then
				task.wait()
			end
		end

		HDAdminMain:GetModule("PageCommands"):CreateCommands()
	end)
end

local menuTemplates = HDAdminMain.gui.MenuTemplates

for _, frame in pairs(menuTemplates:GetChildren()) do
	if frame:IsA("Frame") then
		frame.Visible = false
	end
end

return GUIs