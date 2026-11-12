local PageCommands = {}

local HDAdminMain = _G.HDAdminMain

local pages = HDAdminMain.gui.MainFrame.Pages
local commands = pages.Commands
local v = { commands = commands.Commands, morphs = commands.Morphs, details = pages.About.Details }

local templateOne = v.commands.TemplateOne
local templateTwo = v.commands.TemplateTwo
local templateGamepass = v.commands.TemplateGamepass
local template = v.morphs.Template
local v2 = { "Aliases", "Undo", "Desc", "Rank", "Loop", "Tags" }
local v3 = { "Aliases", "UnFunction", "Description", "Rank", "Loopable", "Tags", "Contributors" }

local frame = commands.SearchBar.Frame
local textBox = frame.TextBox
local cancelButton = frame.CancelButton
local function searchUpdated()
	task.spawn(function()
		local commands2 = v.commands
		PageCommands["Create" .. commands2.Name]()
		commands2.CanvasPosition = Vector2.new(0, 0)
	end)
end
local function textChanged() -- 2 equivalent calls inferred from this helper
	local text = textBox.Text
	cancelButton.Visible = text ~= "" and text ~= " "
end
cancelButton.MouseButton1Click:Connect(function()
	textBox.Text = ""
	textChanged() -- inferred equivalent call
	task.spawn(function()
		local commands2 = v.commands
		PageCommands["Create" .. commands2.Name]()
		commands2.CanvasPosition = Vector2.new(0, 0)
	end)
end)
textBox:GetPropertyChangedSignal("Text"):Connect(textChanged)
textBox.FocusLost:Connect(function(p)
	if not p then
		task.wait(0.1)
	end

	task.spawn(function()
		local commands2 = v.commands
		PageCommands["Create" .. commands2.Name]()
		commands2.CanvasPosition = Vector2.new(0, 0)
	end)
end)
function PageCommands.SetSearchText(_, text)
	textBox.Text = text
	textChanged() -- inferred equivalent call
	task.spawn(function()
		local commands2 = v.commands
		PageCommands["Create" .. commands2.Name]()
		commands2.CanvasPosition = Vector2.new(0, 0)
	end)
end
function PageCommands.GetSearchText(_, _)
	return textBox.Text
end

function PageCommands.GetCommandTemplate(_)
	return templateOne, template
end

local v4 = false
local v5 = false
local module = HDAdminMain:GetModule("Signal").new()
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Circular)
local v6 = {}
local flag = false
local function sortCommands(commandInfo)
	local v7 = {}
	local v8 = nil

	if not commandInfo or flag then
		return
	end

	flag = true

	for k, item in commandInfo do
		item._pos = k

		if not item.SortRandomToTop then
			continue
		end

		if v8 == nil then
			v8 = k
		end

		table.insert(v7, item)
	end

	if not v8 then
		return
	end

	local userId = HDAdminMain.player.UserId
	local v9 = math.floor(os.time() / 43200) * userId
	HDAdminMain:GetModule("cf"):SetSeed(v9)
	local name = tostring(v7[math.random(1, #v7)].Name):lower()
	table.sort(commandInfo, function(a, b): boolean
		local override = a.Override
		local override2 = b.Override
		local v10 = override and override:sub(2) or a.Name
		local v11 = override2 and override2:sub(2) or b.Name
		local lower = tostring(v10):lower()
		local lower2 = tostring(v11):lower()
		local sortRandomToTop = a.SortRandomToTop or a.EmoteId
		local sortRandomToTop2 = b.SortRandomToTop or b.EmoteId

		if lower == name and sortRandomToTop2 then
			return true
		end

		return (lower2 ~= name or not sortRandomToTop) and (a._pos or 9999) < (b._pos or 9999)
	end)
end
function PageCommands:UpdateRunCommandIndicator(p, options)
	local v7 = options or {}
	local v8 = nil

	for k, v9 in pairs(v6) do
		if k.Name == p then
			v8 = v9
			break
		else
			local groups = k.Groups

			if groups then
				for _, v10 in pairs(v7) do
					if table.find(groups, v10) then
						k.ShowRevoke = nil
						v8 = v9
						break
					end
				end
			end
		end
	end

	if v8 then
		v8(nil, true)
	end
end
local count = 0
function PageCommands:SetupCommands(items, parent, count2)
	local rank = HDAdminMain.pdata.Rank or 0
	local function updateRotation(p, p2, p3)
		local rotation = p2 and 0 or 90
		local arrow = p.Arrow

		if p3 then
			arrow.Rotation = rotation
		else
			HDAdminMain.tweenService:Create(arrow, tweenInfo, { Rotation = rotation }):Play()
		end
	end
	count += 1
	local v7 = count
	local y = templateOne.TextLabel.TextBounds.Y

	for k, item in items do
		if k % 20 == 0 then
			task.wait()
		end

		if count ~= v7 then
			return
		end

		local v8 = item.Name
		local override = item.Override

		if override then
			v8 = override:sub(2)
		end

		local rank2 = item.Rank or 5
		count2 += 1
		local name

		if parent.Name == "Buy" then
			name = "AE Command" .. count2
		else
			name = HDAdminMain:GetModule("cf"):GenerateTagFromId(count2)
		end

		local clone = templateOne:Clone()
		clone.BackgroundColor3 = HDAdminMain:GetModule("cf"):GetLabelBackgroundColor(k)
		clone.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		local flag2 = false
		local prefixes = item.Prefixes

		if
			prefixes
			and (prefixes[1] == HDAdminMain.settings.UniversalPrefix or prefixes[1] == HDAdminMain.settings.ChatPrefix)
		then
			clone.TextLabel.Text = HDAdminMain.settings.ChatPrefix .. v8
			flag2 = true
		else
			clone.TextLabel.Text = HDAdminMain.pdata.Prefix .. v8
		end

		local textLabel = clone.TextLabel
		local textSize = HDAdminMain.textService:GetTextSize(
			textLabel.Text,
			y,
			Enum.Font.Roboto,
			textLabel.AbsoluteSize
		)

		task.defer(function()
			local emoteId = item.EmoteId

			if item.IsBooster and emoteId then
				local module2 = HDAdminMain:GetModule("cf")

				if module2:GetEmotesDict()[tostring(emoteId)] then
					module2:SetupUnlockUGC(emoteId, clone.UnlockUGC)
					module2:SetupFavoriteUGC(emoteId, clone.FavoriteUGC)
				end
			end
		end)

		if item.SpecialColor then
			local originalName = item.OriginalName
			local formatted = `<font color="#{item.SpecialColor:ToHex()}">{item.SpecialColorName}</font>`
			textLabel.RichText = true
			textLabel.Text = originalName .. formatted
		end

		local detailsLabel = textLabel:Clone()
		detailsLabel.Position = textLabel.Position + UDim2.new(0, textSize.X + 5, 0, 0)
		detailsLabel.TextColor3 = Color3.fromRGB(175, 175, 175)
		detailsLabel.Name = "DetailsLabel"
		local v9 = {}

		for _, arg in pairs(item.Args) do
			if (not item.IsBooster or arg ~= "player") and arg ~= "details" then
				table.insert(
					v9,
					"<" .. (arg == "playerarg" and "player" or arg == "userid" and "userId/username" or arg) .. ">"
				)
			end
		end

		detailsLabel.Text = item.IsBooster and "" or table.concat(v9, "  ")
		detailsLabel.Parent = clone

		clone.Name = name
		clone.Arrow.Rotation = 90

		clone.Visible = true
		local clones = {}

		local function pressButton()
			if #clones > 0 then
				parent.CanvasSize -= UDim2.new(0, 0, 0, #clones * templateTwo.AbsoluteSize.Y)

				for _, v10 in pairs(clones) do
					v10:Destroy()
				end

				clones = {}
			end

			if clone.Arrow.Rotation == 90 then
				local arrow = clone.Arrow

				HDAdminMain.tweenService:Create(arrow, tweenInfo, { Rotation = 0 }):Play()

				local undoAliases = item.UndoAliases
				local count3 = 0

				for k2, v10 in pairs(v2) do
					local text = item[v3[k2]]

					if not (text and (type(text) ~= "table" and type(text) ~= "string" or #text > 0)) then
						continue
					end

					count3 += 1
					local clone2 = templateTwo:Clone()
					clone2.Name = name .. " Info" .. HDAdminMain.alphabet[count3]
					clone2.Title.Text = v10 .. ":"

					if count3 % 2 == 0 then
						clone2.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
					else
						clone2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					end

					local textLabel2 = clone2.TextLabel
					clone2.Parent = parent

					local v11 = HDAdminMain.pdata.Prefix

					if flag2 then
						v11 = HDAdminMain.settings.ChatPrefix
					end

					if v10 == "Loop" then
						if text == true then
							textLabel2.Text = "Yes"
						else
							textLabel2.Text = "No"
						end
					elseif v10 == "Undo" and not undoAliases then
						textLabel2.Text = v11 .. item.UnFunction
					elseif v10 == "Alias" or v10 == "Undos" or undoAliases and v10 == "Undo" then
						local v12 = {}

						if v10 == "Undo" then
							text = undoAliases
						end

						for _, item2 in pairs(text) do
							table.insert(v12, v11 .. item2)
						end

						local unFunction = v10 == "Undo" and item.UnFunction

						if unFunction then
							table.insert(v12, v11 .. unFunction)
						end

						textLabel2.Text = table.concat(v12, " | ")
					elseif type(text) == "table" then
						textLabel2.Text = table.concat(text, ", ")
					elseif v10 == "Rank" then
						if item.RankName == "Booster" then
							textLabel2.Text = item.Rank
						else
							textLabel2.Text = item.Rank .. " (" .. item.RankName .. ")"
						end
					else
						textLabel2.Text = text

						if v10 == "Desc" then
							local absoluteSize = clone2.Title.AbsoluteSize
							local absoluteSize2 = clone2.AbsoluteSize
							local _ = (clone2.Title.AbsolutePosition.Y - clone2.AbsolutePosition.Y) / 2
							local absoluteSize3 = textLabel2.AbsoluteSize
							local y2 = absoluteSize3.Y
							local _font = textLabel2.Font
							local vector2 = Vector2.new(absoluteSize3.X, absoluteSize3.Y * 100)
							local textSize2 = HDAdminMain.textService:GetTextSize(text, y2, Enum.Font.Roboto, vector2)
							clone2.UIAspectRatioConstraint:Destroy()
							textLabel2.Size = UDim2.new(0, textSize2.X, 0, textSize2.Y)
							clone2.Title.Size = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y)
							clone2.Size = UDim2.new(
								0,
								absoluteSize2.X,
								0,
								absoluteSize2.Y + (textSize2.Y - math.ceil(absoluteSize3.Y))
							)
							clone2.Title.Position = UDim2.new(clone2.Title.Position.X.Scale, 0, 0.5, 0)
							clone2.TextLabel.Position = UDim2.new(clone2.TextLabel.Position.X.Scale, 0, 0.5, 0)
						end
					end

					clone2.Visible = true
					table.insert(clones, clone2)
				end

				local v10 = #clones * templateTwo.AbsoluteSize.Y
				parent.CanvasSize += UDim2.new(0, 0, 0, v10)

				if clone.AbsolutePosition.Y > parent.AbsolutePosition.Y + parent.AbsoluteSize.Y - v10 / 1.5 then
					parent.CanvasPosition += Vector2.new(0, v10)
				end
			else
				local arrow = clone.Arrow

				HDAdminMain.tweenService:Create(arrow, tweenInfo, { Rotation = 90 }):Play()
			end
		end
		local expand = clone.Expand

		if item.IsBooster then
			expand.Visible = false
			clone.Arrow.Visible = false
		end

		if HDAdminMain.device == "Mobile" then
			expand.MouseButton1Click:Connect(function()
				pressButton()
			end)
		else
			expand.MouseButton1Click:Connect(function()
				pressButton()
			end)
		end

		local runCommand = clone.RunCommand
		local runIcon = clone.RunIcon
		local pendingIcon = clone.PendingIcon
		local _revokeIcon = clone.RevokeIcon
		HDAdminMain:GetModule("PageCommands"):SetupUICommandRunner(clone, item)

		local v10 = ((not (rank2 <= rank or item.IsBooster) or item.DisabledByOwner) and true or false) and 0.5 or 0

		runIcon.ImageTransparency = v10
		pendingIcon.ImageTransparency = v10
		textLabel.TextTransparency = v10
		detailsLabel.TextTransparency = v10

		local v11 = textLabel.Position + UDim2.new(0, textSize.X, 0, 0)
		local udim = UDim2.new(v11.X.Scale, v11.X.Offset + 3, 0.9, 0)
		runCommand.Size = udim
		runCommand.Position = UDim2.new(0, 0, 0.5, 0)
		runCommand.AnchorPoint = Vector2.new(0, 0.5)
		expand.Size = UDim2.new(1 - udim.X.Scale, -udim.X.Offset, 0.9, 0)
		expand.AnchorPoint = Vector2.new(1, 0.5)
		expand.Position = UDim2.new(1, 0, 0.5, 0)

		PageCommands:UpdateRunCommandIndicator(item.Name)

		clone.Parent = parent
	end

	return count2
end

function PageCommands:SetupUICommandRunner(data, state, value)
	local runCommand = data.RunCommand
	local runIcon = data.RunIcon
	local pendingIcon = data.PendingIcon
	local revokeIcon = data.RevokeIcon
	local showRevoke2 = value or ""
	runIcon.Visible = true
	pendingIcon.Visible = true
	local name = state.Name
	local groups = state.Groups or {}
	local v7 = #groups
	local fn
	local function showRevoke() -- 2 equivalent calls inferred from this helper
		pendingIcon.Visible = false
		revokeIcon.Visible = true
		v6[state] = fn
	end
	fn = function(p, p2, p3)
		if p or p3 then
			state.ShowRevoke = nil
		end

		local visible = revokeIcon.Visible
		local v8

		if p == nil then
			v8 = p2 and true or visible
		else
			v8 = p
		end

		if p == nil and not v8 and v5 then
			return
		end

		local flag2

		if v5 or p2 then
			flag2 = false
		else
			v5 = true
			flag2 = true
		end

		if v8 then
			v6[state] = nil
		end

		runIcon.Visible = false
		runCommand.Visible = false
		revokeIcon.Visible = false
		pendingIcon.Visible = true
		task.defer(function()
			if p2 then
				return
			end

			repeat
				pendingIcon.Rotation += 15
				task.wait(0.001)
			until runIcon.Visible or revokeIcon.Visible or not pendingIcon.Visible

			pendingIcon.Rotation = 0
		end)

		local prefix = state.Prefixes[1]
		local v9 = HDAdminMain.pdata.Prefix

		if prefix and (prefix == HDAdminMain.settings.ChatPrefix or prefix == HDAdminMain.settings.UniversalPrefix) then
			v9 = prefix
		end

		local v10 = v9 .. (v8 and "un" or "") .. name .. showRevoke2
		local textChannels = HDAdminMain.textChatService:FindFirstChild("TextChannels")

		if textChannels then
			local _rbxGeneral = textChannels.RBXGeneral
		end

		if p == nil then
			for _, group in pairs(groups) do
				module:Fire(group)
			end
		end

		local v11 = (p == true or p2) and true or HDAdminMain.signals.RequestCommand:InvokeServer(v10)

		if p ~= true and not p2 then
			task.wait(0.5)
		end

		if not (v11 or p2) then
			v8 = not v8
		end

		if state.CanUndo and not v8 then
			state.ShowRevoke = showRevoke2
			showRevoke() -- inferred equivalent call
		else
			runIcon.Visible = true
			v6[state] = nil
		end

		runCommand.Visible = true

		if flag2 then
			v5 = false
		end
	end
	runCommand.MouseButton1Click:Connect(function()
		if state.ShowRevoke == showRevoke2 and revokeIcon.Visible == true then
			fn(nil, nil, true)
		else
			fn()
		end
	end)
	task.defer(function()
		for _ = 1, 20 do
			if state.ShowRevoke == showRevoke2 then
				showRevoke() -- inferred equivalent call
				break
			end

			task.wait(0.1)
		end
	end)

	if v7 > 0 then
		module:Connect(function(p)
			for _, group in pairs(groups) do
				if p == group and revokeIcon.Visible then
					fn(true)
					break
				end
			end
		end)
	end
end

local v7 = nil
local v8 = 0
function PageCommands.CreateCommands(_)
	if not v4 then
		v4 = true
		sortCommands(HDAdminMain.commandInfo)

		v8 = v.commands.CanvasPosition.Y
		HDAdminMain:GetModule("cf"):ClearPage(v.commands)

		local gamepasses = HDAdminMain:GetModule("cf"):GetGamepasses()

		local _textBox = commands.SearchBar.Frame.TextBox
		local text = commands.SearchBar.Frame.TextBox.Text
		local function getRankName(p) -- 2 equivalent calls inferred from this helper
			if p.IsBooster then
				return "Booster"
			end

			return p.RankName or "Unknown"
		end

		local v9 = false
		local v10 = {}
		local v11 = {}
		local v12 = 0

		for _, rank in pairs(HDAdminMain.settings.Ranks) do
			if rank[2] == "Booster" then
				v9 = true
			end
		end

		if not v9 then
			table.insert(HDAdminMain.settings.Ranks, { 5.1, "Booster", {} })
		end

		for k, rank in pairs(HDAdminMain.settings.Ranks) do
			local v13 = rank[1]
			local v14 = rank[2]
			table.insert(v10, { v13, v14, {} })
			v11[v14] = k
		end

		for _, v13 in pairs(HDAdminMain.commandInfo) do
			if v13.IgnoreDisplay or not (not v13.IsBooster or tostring(text):lower() == "booster") then
				continue
			end

			local name = string.lower(v13.Name)

			local v14 = string.lower(getRankName(v13)) == string.lower(text) or false -- inferred equivalent call

			if #text > 0 then
				local aliases = v13.Aliases

				if typeof(aliases) == "table" then
					for _, alias in aliases do
						if string.lower((string.sub(text, 1, #alias))) == alias then
							v14 = true
							break
						end
					end
				end
			end

			if not (string.match(name, text) or v14) then
				continue
			end

			local v15 = v11[getRankName(v13)] -- inferred equivalent call

			if not v15 then
				local rank = v13.Rank

				for _, rank2 in pairs(HDAdminMain.settings.Ranks) do
					local v16 = rank2[1]
					local v17 = rank2[2]

					if rank < v16 then
						v15 = v11[v17]
						break
					end
				end
			end

			if v15 then
				table.insert(v10[v15][3], v13)
			end
		end

		local _rank = HDAdminMain.pdata.Rank or 0

		for _, v13 in pairs(v10) do
			local v14 = v13[1]
			local text2 = v13[2]
			local v15 = v13[3]
			local v16 = true
			local gamepass = gamepasses[tostring(v14)]
			local showOnlyUsableAndBuyableCommands = HDAdminMain.settings.ShowOnlyUsableAndBuyableCommands

			if
				(showOnlyUsableAndBuyableCommands or HDAdminMain.settings.OnlyShowUsableCommands)
				and HDAdminMain.pdata.Rank < v14
				and text2 ~= "Booster"
				and not (showOnlyUsableAndBuyableCommands and gamepass)
			then
				v16 = false
			end

			if not (#v15 > 0 and v16) then
				continue
			end

			local clone = templateOne:Clone()
			clone.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
			clone.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

			if v14 == 5 then
				clone.TextLabel.Text = text2
			elseif text2 == "Booster" then
				clone.TextLabel.Text = "Type /commands to view"
			else
				clone.TextLabel.Text = text2 .. " +"
			end

			local v17 = v12 + 1
			clone.Name = HDAdminMain:GetModule("cf"):GenerateTagFromId(v17)
			clone.TextLabel.Position = UDim2.new(0.04, 0, 0.5, 0)
			clone.Arrow:Destroy()
			clone.Visible = true
			clone.Parent = v.commands

			if gamepass then
				for k, v18 in pairs(gamepass) do
					local v19 = tonumber(k)
					local clone2 = templateGamepass:Clone()
					clone2.Name = HDAdminMain:GetModule("cf"):GenerateTagFromId(v17)
					clone2.Parent = v.commands
					v17 += 1
					clone2.ItemTitle.Text = v18.Name
					clone2.ItemImage.Image = "rbxassetid://" .. v18.IconImageAssetId
					clone2.ItemDesc.Text = `Unlock {text2} commands`
					clone2.Unlock.Visible = true
					clone2.Visible = true
					local unlock = clone2.Unlock
					local unlocked = clone2.Unlocked
					local v20 = false
					local function updateUnlock(visible)
						unlock.Visible = false
						unlocked.Visible = true

						if visible == nil then
							visible = HDAdminMain.marketplaceService:UserOwnsGamePassAsync(
								HDAdminMain.player.UserId,
								v19
							)
						end

						unlock.Visible = not visible
						unlocked.Visible = visible

						if not (visible or v20) then
							v20 = true
							unlock.MouseButton1Click:Connect(function()
								HDAdminMain:GetModule("cf"):PromptGamepass(HDAdminMain.player, v19)
							end)
						end
					end
					task.spawn(updateUnlock)
				end
			end

			v12 = PageCommands:SetupCommands(v15, v.commands, v17)
		end

		if v7 == text and v8 then
			local function updateCanvas() -- 1 equivalent call inferred from this helper
				v.commands.CanvasPosition = Vector2.new(0, v8)
			end

			updateCanvas() -- inferred equivalent call
			task.defer(updateCanvas)
		end

		v7 = text

		coroutine.wrap(function()
			wait(0.5)
			v4 = false
		end)()
	end
end

function PageCommands.CreateVoiceChat(_) end

function PageCommands.CreateMorphs(_)
	HDAdminMain:GetModule("cf"):ClearPage(v.morphs)

	local text = commands.SearchBar.Frame.TextBox.Text
	local v9 = {}

	for k, _ in pairs(HDAdminMain.morphNames) do
		local v10 = string.lower(k)

		if string.match(v10, text) then
			table.insert(v9, k)
		end
	end

	table.sort(v9)
	table.insert(v9, 1, HDAdminMain.pdata.Prefix .. "morph <player> <morphName>")

	for k, v10 in pairs(v9) do
		local clone = template:Clone()

		if k == 1 then
			clone.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
		else
			clone.BackgroundColor3 = HDAdminMain:GetModule("cf"):GetLabelBackgroundColor(k)
		end

		clone.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

		clone.TextLabel.Text = v10
		clone.Name = v10
		clone.Visible = true
		clone.Parent = v.morphs
	end

	v.morphs.CanvasSize = UDim2.new(0, 0, 0, #v9 * template.AbsoluteSize.Y)
end

local v9 = {
	{
		{ 0, "Colors" }
	},
	{
		{ 0, "Qualifiers (select certain players)" },
		{ "Me" },
		{ "All" },
		{ "Random" },
		{ "Admins/NonAdmins" },
		{ "Friends/NonFriends" },
		{ "NBC/BC/TBC/OBC/Premium(prem)" },
		{ "R6/R15" },
		{ "Rthro/NonRthro" },
		{ "@(RankName)" },
		{ "%(TeamName)" }
	},
	{
		{ 0, "Shortcuts" },
		{ "' (Quote) to toggle cmdbar (computer)" },
		{ "; (Semicolon) to toggle cmdbar2 (computer)" }
	},
	{
		{ 0, "Tips" },
		{ "/e for silent commands   (/e ;jump me)" },
		{ "Batch commands   (;jump me ;kill me)" },
		{ "Select multiple players   (;jump me,bc,r15)" },
		{ "Shorten names   (;jump ForeverHD = ;jump for)" },
		{ "Cases do not matter   (;jUmP mE = ;jump me)" }
	}
}
local v10 = nil

for k, v11 in pairs(v9) do
	if v11[1][1] == 0 and v11[1][2] == "Colors" then
		v10 = k
	end
end

for _, color in pairs(HDAdminMain.settings.Colors) do
	local v11 = color[1]
	local v12 = color[2]
	local v13 = { v12 .. " (" .. v11 .. ")" }
	table.insert(v9[v10], v13)
	table.insert(HDAdminMain.colors, v12)
end

function PageCommands.CreateDetails(_)
	HDAdminMain:GetModule("cf"):ClearPage(v.details)
	local count2 = 0

	for _, v11 in pairs(v9) do
		for k, v12 in pairs(v11) do
			local clone = template:Clone()

			if k == 1 then
				clone.BackgroundTransparency = 0.93
				clone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				clone.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.TextLabel.Text = v12[2]
			else
				clone.BackgroundTransparency = 1

				if k % 2 == 0 then
					clone.BackgroundTransparency -= 0.01
				end

				clone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				clone.TextLabel.Text = v12[1]
			end

			clone.Visible = true
			clone.Parent = v.details
			count2 += 1
		end
	end

	v.details.CanvasSize = UDim2.new(0, 0, 0, count2 * template.AbsoluteSize.Y)
end

return PageCommands