local CmdBar = {}

local HDAdminMain = _G.HDAdminMain
CmdBar.cmdbarToggled = HDAdminMain:GetModule("Signal").new()
CmdBar.isOpen = false

local customTopBar = HDAdminMain.gui.CustomTopBar
local v = { "Chat", "PlayerList" }
local coreGuiEnableds = {}
local cmdBar = HDAdminMain.gui.CmdBar
local v2 = false
local states = {}
local backgroundTransparency = 1
local visible = true

local v3 = {
	maxSuggestions = 5,
	mainParent = cmdBar,
	textBox = cmdBar.SearchFrame.TextBox,
	rframe = cmdBar.ResultsFrame,
	suggestionPos = 1,
	suggestionDisplayed = 0,
	forceExecute = false,
	highlightColor = Color3.fromRGB(50, 50, 50),
	otherColor = Color3.fromRGB(80, 80, 80),
	suggestionLabels = {},
	currentBarCommand = nil
}

local function selectSuggestion(data)
	local v4 = ""
	local suggestionLabel = data.suggestionLabels["Label" .. data.suggestionPos]

	if data.specificArg then
		local text = suggestionLabel.Name .. " "

		data.textBox.Text = text
		coroutine.wrap(function()
			for _ = 1, 10 do
				data.textBox:ReleaseFocus()
				wait()
			end
		end)()
		wait()
		data.textBox.Text = text
	else
		local v5 = {}
		local v6 = -1
		local v7 = string.sub(data.textBox.Text, 1, 1)
		data.textBox.Text:gsub("([^" .. HDAdminMain.pdata.SplitKey .. "]+)", function(p)
			v6 += 1

			if v6 > suggestionLabel.ArgPos - 1 then
				return
			end

			table.insert(v5, p .. " ")
		end)

		if
			v6 == 0
			and (v7 == HDAdminMain.settings.UniversalPrefix or v7 == HDAdminMain.settings.ChatPrefix or v7 == HDAdminMain.pdata.Prefix)
		then
			v4 = v7
		end

		local text = ((v4 .. table.concat(v5, "")) .. suggestionLabel.Name) .. HDAdminMain.pdata.SplitKey

		data.textBox.Text = text
		wait()
		data.textBox.Text = text

		data.textBox.CursorPosition = #text + 1
	end
end

cmdBar.Visible = false

local function createSuggestionLabels(state)
	for i = 1, state.maxSuggestions do
		local clone = state.rframe.LabelTemplate:Clone()
		clone.Name = "Label" .. i
		clone.Visible = false
		clone.Parent = state.rframe
		clone.MouseEnter:Connect(function()
			state.suggestionPos = i
		end)
		clone.MouseButton1Up:Connect(function()
			state.suggestionPos = i
			selectSuggestion(state)
		end)
	end
end

local function setupEnterPress(data) -- 1 equivalent call inferred from this helper
	data.textBox.FocusLost:connect(function(p)
		if data.mainParent.Name == "CmdBar" and not data.specificArg then
			if data.suggestionDisplayed > 0 and not forceExecute and HDAdminMain.device ~= "Mobile" then
				selectSuggestion(data)
			elseif p then
				if forceExecute then
					selectSuggestion(data)
				end

				CmdBar:CloseCmdBar()

				if #data.textBox.Text > 1 then
					local v4 = data.textBox.Text
					local v5 = string.sub(v4, 1, 1)

					if
						v5 ~= HDAdminMain.settings.UniversalPrefix
						and v5 ~= HDAdminMain.settings.ChatPrefix
						and v5 ~= HDAdminMain.pdata.Prefix
					then
						v4 = HDAdminMain.pdata.Prefix .. v4
					end

					if string.sub(v4, -1) == " " then
						v4 = string.sub(v4, 1, -1)
					end

					HDAdminMain.signals.RequestCommandSilent:InvokeServer(v4)
				end
			end
		elseif data.suggestionDisplayed > 0 then
			selectSuggestion(data, data.specificArg)
		end
	end)
end

function CmdBar:SetupTextbox(p, state)
	local function collectArguments(list, list2, argPos, name)
		if string.sub(string.lower(name), 1, #list2) == list2 then
			table.insert(list, { Name = name, ArgPos = argPos })

			if #list == state.maxSuggestions then
				return true
			end
		end
	end
	local specificArg = state.specificArg
	states[p] = state
	createSuggestionLabels(state)
	setupEnterPress(state) -- inferred equivalent call
	local position = nil
	state.textBox.Changed:connect(function(p2)
		local v4 = string.sub(state.textBox.Text, 1, 1)

		if
			specificArg
			or v4 == HDAdminMain.settings.UniversalPrefix
			or v4 == HDAdminMain.settings.ChatPrefix
			or v4 == HDAdminMain.pdata.Prefix
		then
			if p2 == "Text" then
				local v5 = -1
				local v6 = nil
				local v7 = {}

				if specificArg then
					table.insert(v7, state.textBox.Text)
					v5 = 1
				else
					state.textBox.Text:gsub("([^" .. HDAdminMain.pdata.SplitKey .. "]+)", function(p3)
						v5 += 1

						if v5 == 0 then
							v6 = p3
						elseif v5 > 0 then
							table.insert(v7, p3)
						end
					end)

					if v5 > 0 and not state.currentBarCommand then
						local v8 = string.sub(v6, 1, 1)

						if
							v8 == HDAdminMain.settings.UniversalPrefix
							or v8 == HDAdminMain.settings.ChatPrefix
							or v8 == HDAdminMain.pdata.Prefix
						then
							v6 = string.sub(v6, 2)
						end

						v6 = string.lower(v6)

						for _, currentBarCommand in pairs(HDAdminMain.commandInfo) do
							if string.lower(currentBarCommand.Name) == v6 then
								state.currentBarCommand = currentBarCommand
							elseif currentBarCommand.Aliases then
								for _, alias in pairs(currentBarCommand.Aliases) do
									if string.lower(alias) == v6 then
										state.currentBarCommand = currentBarCommand
									end
								end
							end
						end
					elseif v5 <= 0 then
						state.currentBarCommand = nil
					end
				end

				local v8 = {}
				state.suggestionPos = 1

				if #state.textBox.Text > 1 or specificArg and #state.textBox.Text > 0 then
					if v5 == 0 then
						local v9 = string.lower((string.sub(state.textBox.Text, 2)))
						string.lower((string.sub(state.textBox.Text, 1, 1)))

						for _, v10 in pairs(HDAdminMain.commandInfo) do
							if v10.IsBooster then
								continue
							end

							local name = string.lower(v10.Name)
							local _ = v10.Prefixes[1]
							local exactMatchStart = string.sub(name, 1, #v9) == v9

							if exactMatchStart or name:match(v9) then
								table.insert(v8, {
									ExactMatchStart = exactMatchStart,
									Name = v10.Name,
									Args = v10.Args,
									Prefixes = v10.Prefixes,
									ArgPos = 0
								})
							end

							local unFunction = v10.UnFunction

							if unFunction then
								local exactMatchStart2 = string.sub(string.lower(unFunction), 1, #v9) == v9

								if exactMatchStart2 or unFunction:match(v9) then
									table.insert(v8, {
										ExactMatchStart = exactMatchStart2,
										Name = unFunction,
										Args = {},
										Prefixes = v10.Prefixes,
										ArgPos = 0
									})
								end
							end

							local function registerAliases(p3)
								local v11 = v10[p3]

								if v11 then
									for _, name2 in pairs(v11) do
										local exactMatchStart2 = string.sub(string.lower(name2), 1, #v9) == v9

										if exactMatchStart2 or name2:match(v9) then
											table.insert(v8, {
												ExactMatchStart = exactMatchStart2,
												Name = name2,
												Args = {},
												Prefixes = v10.Prefixes,
												ArgPos = 0
											})
										end
									end
								end
							end
							registerAliases("Aliases")
							registerAliases("UndoAliases")
						end
					elseif state.currentBarCommand or specificArg then
						local v9

						if specificArg then
							v9 = specificArg
						else
							v9 = state.currentBarCommand.Args[v5]
						end

						local v10 = string.lower(v7[v5])
						local v11 = string.sub(state.textBox.Text, -1)

						if v11 ~= " " and v11 ~= HDAdminMain.pdata.SplitKey then
							if v9 == "player" or v9 == "playerarg" then
								for _, qualifier in pairs(HDAdminMain.qualifiers) do
									if collectArguments(v8, v10, v5, qualifier) then
										break
									end
								end

								for _, child in pairs(HDAdminMain.players:GetChildren()) do
									local argPos = v5

									if collectArguments(v8, v10, argPos, child.Name) then
										break
									end
								end
							elseif v9 == "colour" or v9 == "color" or v9 == "color3" then
								for _, color in pairs(HDAdminMain.colors) do
									if collectArguments(v8, v10, v5, color) then
										break
									end
								end
							elseif v9 == "material" then
								for _, material in pairs(HDAdminMain.materials) do
									if collectArguments(v8, v10, v5, material) then
										break
									end
								end
							elseif v9 == "rank" then
								for _, rank in pairs(HDAdminMain.settings.Ranks) do
									local argPos = v5

									if collectArguments(v8, v10, argPos, rank[2]) then
										break
									end
								end
							elseif v9 == "team" or v9 == "teamcolor" then
								for _, child in pairs(HDAdminMain.teams:GetChildren()) do
									local argPos = v5

									if collectArguments(v8, v10, argPos, child.Name) then
										break
									end
								end
							elseif v9 == "morph" then
								for k, _ in pairs(HDAdminMain.morphNames) do
									if collectArguments(v8, v10, v5, k) then
										break
									end
								end
							elseif v9 == "tools" or v9 == "gears" or v9 == "tool" or v9 == "gear" then
								for k, _ in pairs(HDAdminMain.toolNames) do
									if collectArguments(v8, v10, v5, k) then
										break
									end
								end
							end
						end
					end
				end

				table.sort(v8, function(a, b): boolean
					local exactMatchStart = a.ExactMatchStart
					local exactMatchStart2 = b.ExactMatchStart

					if exactMatchStart and not exactMatchStart2 then
						return true
					end

					if exactMatchStart2 and not exactMatchStart then
						return false
					end

					local name = a.Name
					local name2 = b.Name
					local v9 = name and #name or 0
					local v10 = name2 and #name2 or 0

					if name and name2 and v9 == v10 then
						return name:lower() < name2:lower()
					end

					return v9 < v10
				end)

				state.suggestionDisplayed = #v8

				if
					state.currentBarCommand
					and #state.currentBarCommand.Args == v5
					and state.suggestionDisplayed > 0
				then
					forceExecute = true
				else
					forceExecute = false
				end

				for i = 1, state.maxSuggestions do
					local v9 = v8[i]
					local child = state.rframe:FindFirstChild("Label" .. i)

					if not child then
						continue
					end

					if v9 then
						local v10 = v9.Args and true or false

						local v11 = v10
							and (v9.Prefixes[1] == HDAdminMain.settings.UniversalPrefix or v9.Prefixes[1] == HDAdminMain.settings.ChatPrefix)
							and true
							or false

						local v12 = {}

						if v10 then
							for _, arg in pairs(v9.Args) do
								if not v11 or arg ~= "player" or arg == "playerarg" then
									table.insert(v12, "<" .. arg .. ">")
								end
							end
						end

						child.TextLabel.Text = v9.Name .. " " .. table.concat(v12, " ")

						if i == state.suggestionPos then
							child.BackgroundColor3 = state.highlightColor
						else
							child.BackgroundColor3 = state.otherColor
						end

						state.suggestionLabels["Label" .. i] = v9

						if state.mainParent.Name ~= "CmdBar" then
							local y = state.rframe.LabelTemplate.AbsoluteSize.Y
							local v13 = y * i
							local v14 = state.rframe.AbsolutePosition.Y + v13

							if HDAdminMain.gui.Notices.AbsoluteSize.Y < v14 + 5 then
								if not position then
									position = state.mainParent.Position
								end

								state.mainParent.Position = state.mainParent.Position - UDim2.new(0, 0, 0, y)
							end
						end

						child.Visible = true
					else
						child.Visible = false
					end
				end

				if position and #v8 < 1 then
					state.mainParent.Position = position
					position = nil
				end

				if #v8 < 1 and state.mainParent.Name ~= "CmdBar" then
					state.mainParent.ClipsDescendants = true
				else
					state.mainParent.ClipsDescendants = false
				end
			end
		else
			state.textBox.Text = HDAdminMain.pdata.Prefix

			if state.textBox.CursorPosition < 2 then
				state.textBox.CursorPosition = 2
			end
		end
	end)
end
CmdBar:SetupTextbox("cmdbar1", v3)

function CmdBar.ToggleBar(_, p)
	if p == Enum.KeyCode.Quote then
		if HDAdminMain.gui.CmdBar.Visible then
			HDAdminMain:GetModule("CmdBar"):CloseCmdBar()
		else
			HDAdminMain:GetModule("CmdBar"):OpenCmdBar()
		end
	elseif p == Enum.KeyCode.Semicolon then
		local cmdbar2 = HDAdminMain.settings.Cmdbar2

		if HDAdminMain.pdata.Rank > 0 or cmdbar2 <= 0 then
			if HDAdminMain.pdata.Rank < cmdbar2 then
				local formatNotice = HDAdminMain:GetModule("cf"):FormatNotice(
					"CommandBarLocked",
					"2",
					HDAdminMain:GetModule("cf"):GetRankName(cmdbar2)
				)
				HDAdminMain:GetModule("Notices"):Notice("Error", formatNotice[1], formatNotice[2])
			else
				local cmdbar2_2 = states.cmdbar2

				if not cmdbar2_2 then
					HDAdminMain:GetModule("ClientCommands").cmdbar2.Function()
				elseif cmdbar2_2.mainParent.Visible then
					cmdbar2_2.mainParent.Visible = false
				else
					cmdbar2_2.mainParent.Visible = true
				end
			end
		end
	end
end

function CmdBar:OpenCmdBar(): boolean
	local v4 = v3
	local cmdbar = HDAdminMain.settings.Cmdbar

	if not (HDAdminMain.pdata.Rank > 0 or cmdbar <= 0) or v2 then
		return false
	end

	v2 = true

	if HDAdminMain.pdata.Rank < cmdbar then
		local formatNotice = HDAdminMain:GetModule("cf"):FormatNotice(
			"CommandBarLocked",
			"",
			HDAdminMain:GetModule("cf"):GetRankName(cmdbar)
		)
		HDAdminMain:GetModule("Notices"):Notice("Error", formatNotice[1], formatNotice[2])
	else
		local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid()
		local v5 = humanoid and humanoid.MoveDirection.Magnitude > 0
		task.defer(function()
			v4.textBox.TextEditable = true

			for _ = 1, 5 do
				if v5 then
					v4.textBox:ReleaseFocus()
				else
					v4.textBox:CaptureFocus()
				end

				task.wait(0.03)
			end
		end)
		CmdBar.isOpen = true
		CmdBar.cmdbarToggled:Fire(true)

		for _, v6 in pairs(v) do
			coreGuiEnableds[v6] = HDAdminMain.starterGui:GetCoreGuiEnabled(v6)
			HDAdminMain.starterGui:SetCoreGuiEnabled(Enum.CoreGuiType[v6], false)
		end

		customTopBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		backgroundTransparency = customTopBar.BackgroundTransparency
		visible = customTopBar.Visible
		customTopBar.BackgroundTransparency = 0
		customTopBar.Visible = true
		v4.textBox.Text = ""
		cmdBar.Visible = true
		wait()
		v4.textBox.Text = HDAdminMain.pdata.Prefix
		v4.textBox.CursorPosition = 3
		return true
	end

	return false
end

function CmdBar:CloseCmdBar()
	if not v2 then
		return
	end

	v2 = false
	local v4 = v3
	task.defer(function()
		for _ = 1, 5 do
			v4.textBox:ReleaseFocus()
			task.wait(0.02)
		end

		v4.textBox.TextEditable = false
	end)
	cmdBar.Visible = false

	for _, v5 in pairs(v) do
		local v6 = coreGuiEnableds[v5]

		if v6 then
			HDAdminMain.starterGui:SetCoreGuiEnabled(Enum.CoreGuiType[v5], v6)
		end
	end

	CmdBar.isOpen = false
	CmdBar.cmdbarToggled:Fire(false)
	customTopBar.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	customTopBar.BackgroundTransparency = backgroundTransparency
	customTopBar.Visible = visible
end

function CmdBar.PressedArrowKey(_, p)
	for _, v4 in pairs(states) do
		if not (v4.mainParent.Visible and v4.textBox:IsFocused()) then
			continue
		end

		local child = v4.rframe:FindFirstChild("Label" .. v4.suggestionPos)

		if p == Enum.KeyCode.Down then
			v4.suggestionPos += 1

			if v4.suggestionPos > v4.suggestionDisplayed then
				v4.suggestionPos = 1
			end
		elseif p == Enum.KeyCode.Up then
			v4.suggestionPos -= 1

			if v4.suggestionPos < 1 then
				v4.suggestionPos = v4.suggestionDisplayed
			end
		elseif p == Enum.KeyCode.Right then
			selectSuggestion(v4)
		end

		local v5 = v4.rframe["Label" .. v4.suggestionPos]

		if v5 == child then
			continue
		end

		child.BackgroundColor3 = v4.otherColor
		v5.BackgroundColor3 = v4.highlightColor
	end
end

return CmdBar