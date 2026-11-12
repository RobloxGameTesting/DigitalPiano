local ClientCoreFunctions = {}

local HDAdminMain = _G.HDAdminMain

local unBan = HDAdminMain.warnings.UnBan
local permRank = HDAdminMain.warnings.PermRank
local menuTemplates = HDAdminMain.gui.MenuTemplates
local module = HDAdminMain:GetModule("Signal").new()
local v = 1

local function setupOriginalZIndex(folder, p)
	for _, guiObject in pairs(folder:GetDescendants()) do
		if not (guiObject:IsA("GuiObject") and guiObject:FindFirstChild("OriginalZIndex") == nil) then
			continue
		end

		local originalZIndex = Instance.new("IntValue")
		originalZIndex.Name = "OriginalZIndex"
		local zIndex = guiObject.ZIndex

		if p then
			zIndex += 10000
		end

		originalZIndex.Value = zIndex
		originalZIndex.Parent = guiObject
	end
end
local function updateZIndex(_, p)
	for k, folder in pairs(HDAdminMain.commandMenus) do
		for _, guiObject in pairs(folder:GetDescendants()) do
			if not (guiObject:IsA("GuiObject") and guiObject:FindFirstChild("OriginalZIndex") and (not p or folder == p)) then
				continue
			end

			guiObject.ZIndex = guiObject.OriginalZIndex.Value + (k - 1) * 10 - 1000
		end
	end
end

function ClientCoreFunctions.CheckPromptRank(_, p)
	local v2 = HDAdminMain:GetModule("cf"):GetGamepasses()[tostring(p)]
	local v3 = nil

	if v2 then
		for _, v4 in pairs(v2) do
			v3 = v4
			break
		end
	end

	if v3 then
		local _name = v3.Name
		local gamepassId = v3.GamepassId
		task.defer(function()
			HDAdminMain.marketplaceService:PromptGamePassPurchase(HDAdminMain.player, gamepassId)
		end)
	end
end

local v2 = nil
function ClientCoreFunctions:GetGamepasses()
	if v2 then
		return v2
	end

	local v3 = HDAdminMain.signals.RetrieveGamepasses:InvokeServer()

	if not v3 then
		return
	end

	v2 = v3
	return v3
end

function ClientCoreFunctions.ReplicateEffect(_, p, p2)
	HDAdminMain.signals.ReplicateEffect:FireServer(p, p2)
end

local module2 = nil
local v3 = nil
function ClientCoreFunctions:GetRankChangedSignal()
	if module2 then
		return module2
	end

	module2 = HDAdminMain:GetModule("Signal").new()
	return module2
end

function ClientCoreFunctions.WaitForLoadedRank(_)
	if v3 then
		return v3
	end

	return ClientCoreFunctions:GetRankChangedSignal():Wait()
end

function ClientCoreFunctions.RankChangedUpdater(_)
	task.defer(function()
		if HDAdminMain.initialized then
			repeat
				task.wait(0.5)
			until HDAdminMain.initialized
		end

		local rankChangedSignal = ClientCoreFunctions:GetRankChangedSignal()
		local rank = HDAdminMain.pdata.Rank
		v3 = rank
		rankChangedSignal:Fire(rank)
		HDAdminMain:GetModule("PageAbout"):UpdateRankName()
		HDAdminMain:GetModule("GUIs"):DisplayPagesAccordingToRank(true)
		HDAdminMain:GetModule("PageCommands"):CreateCommands()
		ClientCoreFunctions:UpdateIconVisiblity()
	end)
end

function ClientCoreFunctions:UpdateIconVisiblity()
	local v4 = false
	local v5 = false
	local rankRequiredToViewDashboardIcon = HDAdminMain.settings.RankRequiredToViewDashboardIcon
		or HDAdminMain.settings.RankRequiredToViewIcon
	local rankRequiredToViewCommandsIcon = HDAdminMain.settings.RankRequiredToViewCommandsIcon
		or HDAdminMain.settings.RankRequiredToViewIcon
	local rank = HDAdminMain.pdata.Rank or 0

	if rankRequiredToViewDashboardIcon <= rank then
		v4 = true
	elseif rankRequiredToViewCommandsIcon <= rank then
		v5 = true
	end

	local module3 = HDAdminMain:GetModule("TopbarIcons")
	local dashboard = module3.Dashboard
	local commands = module3.Commands
	dashboard:setEnabled(v4)
	commands:setEnabled(v5)
end

function ClientCoreFunctions.DeactivateCommand(_, p)
	HDAdminMain.commandsAllowedToUse[p] = nil
	HDAdminMain.commandsActive[p] = nil

	if not HDAdminMain.commandsToDisableCompletely[p] then
		local child = HDAdminMain.gui:FindFirstChild("CommandMenu" .. p)
		HDAdminMain:GetModule("cf"):DestroyCommandMenuFrame(child)
	end
end

function ClientCoreFunctions.EndCommand(_, p)
	HDAdminMain.commandsActive[p] = nil
	HDAdminMain:GetModule("cf"):UpdateCommandMenu(p)
end

function ClientCoreFunctions:ActivateClientCommand(p, p2)
	if
		HDAdminMain.commandsAllowedToUse[p]
		and not (HDAdminMain.commandsActive[p] or p2 and p2.DontForceActivate and HDAdminMain.gui:FindFirstChild("CommandMenu" .. p))
	then
		HDAdminMain.commandsActive[p] = true
		spawn(function()
			HDAdminMain:GetModule("cf"):UpdateCommandMenu(p)
			local v4 = HDAdminMain:GetModule("ClientCommands")[p]

			local activate = v4 and v4.Activate

			if activate then
				activate(v4)
			end

			HDAdminMain.commandsActive[p] = nil
		end)
	end
end

function ClientCoreFunctions:GetCF(p, p2)
	local cframe = p.CFrame
	local cframe2 = CFrame.new(cframe.p)
	local eulerAnglesXYZ, v4, v5 = (workspace.CurrentCamera.CFrame - workspace.CurrentCamera.CFrame.p):toEulerAnglesXYZ()
	return cframe2 * CFrame.Angles(p2 and v5 or eulerAnglesXYZ, v4, v5)
end

function ClientCoreFunctions.GetNextMovement(_, p, p2)
	local total = Vector3.new()
	local v4 = {
		Left = Vector3.new(-1, 0, 0),
		Right = Vector3.new(1, 0, 0),
		Forwards = Vector3.new(0, 0, -1),
		Backwards = Vector3.new(0, 0, 1),
		Up = Vector3.new(0, 1, 0),
		Down = Vector3.new(0, -1, 0)
	}

	if HDAdminMain.device == "Computer" then
		for _, v5 in pairs(HDAdminMain.movementKeysPressed) do
			local v6 = v4[v5]

			if v6 then
				total += v6
			end
		end
	else
		local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid()
		local hrp = HDAdminMain:GetModule("cf"):GetHRP()

		if humanoid and hrp then
			local moveDirection = humanoid.MoveDirection

			for k, position in pairs(v4) do
				if not (((ClientCoreFunctions:GetCF(hrp, true) * CFrame.new(position) - hrp.CFrame.p).p - moveDirection).magnitude <= 1.05 and moveDirection ~= Vector3.new(0, 0, 0)) then
					continue
				end

				total += position
			end
		end
	end

	return CFrame.new(total * p2 * p), total
end

function ClientCoreFunctions.GetAssetImage(_, p)
	return "https://www.roblox.com/asset-thumbnail/image?assetId=" .. p .. "&width=420&height=420&format=png"
end

function ClientCoreFunctions:GetUserImage(p)
	return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p .. "&width=420&height=420&format=png"
end

function ClientCoreFunctions.ShowPermRankedUser(_, list)
	local item = list[1]
	local item2 = list[2]
	local item3 = list[3]
	permRank.PlrName.Text = item
	permRank.PlrImage.Image = ClientCoreFunctions:GetUserImage(item2)
	permRank.RankedBy.TextLabel.Text = HDAdminMain:GetModule("cf"):GetName(item3)
	HDAdminMain:GetModule("cf"):ShowWarning("PermRank")
end

function ClientCoreFunctions.ShowBannedUser(_, list)
	local item = list[1]
	local item2 = list[2]
	local item3 = list[3]
	local item4 = list[4]
	local textLabel = unBan.Reason.TextLabel
	unBan.PlrName.Text = item
	unBan.PlrImage.Image = ClientCoreFunctions:GetUserImage(item2)
	unBan.BannedBy.TextLabel.Text = HDAdminMain:GetModule("cf"):GetName(item4)
	textLabel.Text = "'" .. item3 .. "'"

	if textLabel.Text == "" or textLabel.Text == " " then
		textLabel.Text = "Empty"
		textLabel.Font = Enum.Font.SourceSansItalic
	else
		textLabel.Font = Enum.Font.SourceSans
	end

	HDAdminMain:GetModule("cf"):ShowWarning("UnBan")
end

function ClientCoreFunctions:ShowWarning(p)
	for _, child in pairs(HDAdminMain.warnings:GetChildren()) do
		if child.Name == p then
			child.Visible = true
			HDAdminMain.warnings.Visible = true
		else
			child.Visible = false
		end
	end
end

function ClientCoreFunctions.SetCameraSubject(_, cameraSubject)
	local face = HDAdminMain:GetModule("cf"):GetFace()

	if face then
		local transparency = face.Transparency
		HDAdminMain.camera.CameraSubject = cameraSubject
		face.Transparency = transparency
	end
end

function ClientCoreFunctions:DestroyCommandMenuFrame(instance)
	if instance then
		for k, v4 in pairs(HDAdminMain.commandMenus) do
			if v4 == instance then
				table.remove(HDAdminMain.commandMenus, k)
			end
		end

		instance:Destroy()
	end
end

function ClientCoreFunctions:UpdateCommandMenu(p, p2)
	if p2 == nil or p2.Parent == nil then
		p2 = HDAdminMain.gui:FindFirstChild("CommandMenu" .. p)
	end

	if p2 then
		local mainFrame = p2.MainFrame

		if mainFrame:FindFirstChild("Status") then
			if
				HDAdminMain.commandsToDisableCompletely[p] and HDAdminMain.commandsAllowedToUse[p]
				or HDAdminMain.commandsActive[p]
			then
				mainFrame.Status.TextLabel.Text = "On"
				mainFrame.Status.TextLabel.TextColor3 = Color3.fromRGB(0, 225, 0)
				mainFrame.ChangeStatus.TextLabel.Text = "DISABLE"
			else
				mainFrame.Status.TextLabel.Text = "Off"
				mainFrame.Status.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
				mainFrame.ChangeStatus.TextLabel.Text = "ENABLE"
			end
		end
	end
end
function ClientCoreFunctions:CreateNewCommandMenu(value, p, p2, p3, _)
	local v4 = tonumber(p2)
	local value2 = HDAdminMain:GetModule("cf"):FindValue({
		4,
		5,
		8,
		11,
		12,
		13,
		14,
		16,
		18
	}, v4)
	local value3 = HDAdminMain:GetModule("cf"):FindValue({ 4 }, v4)
	local value4 = HDAdminMain:GetModule("cf"):FindValue({
		17,
		5,
		6,
		7,
		9,
		12,
		13,
		14,
		16,
		18
	}, v4)
	local name2 = "CommandMenu" .. value

	if value3 then
		name2 = "CommandMenu" .. value .. v
		v += 1
	end

	local parent2 = HDAdminMain.gui:FindFirstChild(name2)

	if parent2 and value4 then
		parent2:Destroy()
		parent2 = nil
	end

	if not parent2 then
		local menuTemplate = menuTemplates["Template" .. v4]
		local mainFrame = menuTemplate.MainFrame
		parent2 = menuTemplate:Clone()
		parent2.Name = name2
		local dragBar = parent2.DragBar
		local mainFrame2 = parent2.MainFrame
		local function splitStringByCapitalLetters(value5) -- 1 equivalent call inferred from this helper
			return value5:gsub("(%u)", " %1"):gsub("^%s", "")
		end

		local parts = splitStringByCapitalLetters(value):split(" ") -- inferred equivalent call

		for k, part in pairs(parts) do
			parts[k] = part:lower():gsub("^%l", string.upper)
		end

		local joined = table.concat(parts, " ")

		dragBar.Title.Text = joined
		HDAdminMain:GetModule("InputHandler"):MakeFrameDraggable(parent2)
		dragBar.Close.MouseButton1Down:Connect(function()
			if value2 then
				ClientCoreFunctions:DestroyCommandMenuFrame(parent2)
			else
				parent2.Visible = false
			end
		end)
		local scale = mainFrame2.Position.Y.Scale
		local v5 = -(1 - dragBar.Size.Y.Scale - scale)
		local minimise = dragBar:FindFirstChild("Minimise")

		if minimise then
			minimise.MouseButton1Down:Connect(function()
				if minimise.TextLabel.Text == "-" then
					HDAdminMain.tweenService:Create(mainFrame2, TweenInfo.new(0.5), {
						Position = UDim2.new(0, 0, v5, -1)
					}):Play()
					minimise.TextLabel.Text = "+"
				else
					HDAdminMain.tweenService:Create(mainFrame2, TweenInfo.new(0.5), {
						Position = UDim2.new(0, 0, scale, 0)
					}):Play()
					minimise.TextLabel.Text = "-"
				end
			end)
		end

		local function updateCanvasSize(p4, p5, p6) -- 9 equivalent calls inferred from this helper
			p4.CanvasSize = UDim2.new(0, 0, 0, p5.AbsolutePosition.Y - p6.AbsolutePosition.Y + p5.AbsoluteSize.Y)
		end

		local function selectToggle(instance, childName, list)
			local item = list[1]
			local item2 = list[2]
			local item3 = list[3]
			local item4 = list[4]
			local item5 = list[5]

			if not instance:FindFirstChild(childName) then
				childName = item[instance.Name]
			end

			if
				instance.Name == "AC Server"
				and childName == "All"
				and HDAdminMain.pdata.Rank < HDAdminMain.commandRanks.globalvote
			then
				HDAdminMain:GetModule("Notices"):Notice(
					"Error",
					HDAdminMain.hdAdminCoreName,
					"Must be '" .. HDAdminMain:GetModule("cf"):GetRankName(HDAdminMain.commandRanks.globalvote) .. "' to use ;globalVote"
				)
				return
			end

			for _, button in pairs(instance:GetChildren()) do
				if button:IsA("TextButton") then
					item2(button, childName, instance)
				end
			end

			if item4 and item5 then
				updateCanvasSize(item3, item4, item5) -- inferred equivalent call
			end
		end

		local function setupDefaultToggles(items, scrollFrame, textBox, p4, fn, instance, value5)
			local v6 = false
			textBox.Focused:Connect(function()
				v6 = true
			end)
			textBox.FocusLost:Connect(function()
				wait()
				v6 = false
			end)

			for k, _ in pairs(items) do
				local v7 = scrollFrame[k]

				for _, button in pairs(v7:GetChildren()) do
					if not button:IsA("TextButton") then
						continue
					end

					local v8 = button
					button.MouseButton1Down:Connect(function()
						if not v6 then
							selectToggle(v7, v8.Name, p4)
						end
					end)
				end

				fn(v7)
			end

			if instance then
				for _, child in pairs(instance:GetChildren()) do
					local textBox2 = child:FindFirstChild("TextBox")

					if not textBox2 then
						continue
					end

					local text2 = textBox2.Text
					textBox2.Focused:Connect(function()
						v6 = true
					end)
					textBox2.FocusLost:connect(function(_)
						local text = tonumber(textBox2.Text)

						if text then
							if text < 0 then
								text2 = 0
							elseif child.Name == "Minutes" and text > 60 then
								text2 = 60
							elseif child.Name == "Hours" and text > 24 then
								text2 = 24
							elseif child.Name == "Days" and text > 100000 then
								text2 = 100000
							else
								text2 = text
							end
						end

						textBox2.Text = text2
						wait()
						v6 = false
					end)
				end
			end

			if value5 then
				local v7 = string.lower(value5)

				for _, qualifier in pairs(HDAdminMain.qualifiers) do
					if qualifier == v7 then
						value5 = qualifier
						break
					end
				end

				if not value5 then
					for _, child in pairs(HDAdminMain.players:GetChildren()) do
						if string.sub(string.lower(child.Name), 1, #v7) == v7 then
							value5 = child.Name
							break
						end
					end
				end

				textBox.Text = value5 or ""
			end
		end

		local function setupFinalResult(p4, axSubmit, azLoading, fn, fn2, fn3)
			local finalResult = p4.FinalResult
			local frame = finalResult.Frame
			local _example = frame.Example
			local loading = frame.Loading
			local broadcast = frame.Broadcast
			finalResult.Visible = false
			frame.CloseX.MouseButton1Down:Connect(function()
				finalResult.Visible = false
			end)
			broadcast.MouseButton1Down:Connect(function()
				loading.Visible = true
				broadcast.Visible = false
				local v6, v7 = fn3()

				if v6 ~= false or not v7 then
					ClientCoreFunctions:DestroyCommandMenuFrame(p4)

					return
				end

				loading.Visible = false
				broadcast.Visible = true
				HDAdminMain:GetModule("Notices"):Notice(
					"Error",
					HDAdminMain.hdAdminCoreName,
					`Request failed: {tostring(v7)}`
				)
			end)
			axSubmit.MouseButton1Down:Connect(function()
				azLoading.Visible = true
				axSubmit.Visible = false
				local v6 = fn()

				if type(v6) == "table" then
					fn2(v6)
				else
					local text = tostring(v6) or "Error"
					azLoading.TextLabel.Text = text
					wait(1)
					azLoading.TextLabel.Text = "Loading..."
				end

				azLoading.Visible = false
				axSubmit.Visible = true
			end)
		end

		local function setupPollResults(parent, data)
			local answerTemplate = parent.AnswerTemplate
			answerTemplate.Visible = false
			parent.Question.TextLabel.Text = data.Question

			for _, button in pairs(parent:GetChildren()) do
				if button:IsA("TextButton") and button ~= answerTemplate then
					button:Destroy()
				end
			end

			for k, answer in pairs(data.Answers) do
				local clone = answerTemplate:Clone()
				clone.Visible = true
				clone.Name = "Answer" .. k
				clone.TextLabel.Text = k .. ". " .. answer
				clone.BackgroundColor3 = ClientCoreFunctions:GetLabelBackgroundColor(k)

				local fade = clone.Fade

				if data.Remote then
					clone.MouseButton1Up:Connect(function()
						parent.Parent.Parent.Visible = false
						pcall(function()
							data.Remote:FireServer(k)
						end)
					end)
				end

				clone.InputBegan:Connect(function(_)
					HDAdminMain.tweenService:Create(fade, TweenInfo.new(0.2), {
						BackgroundTransparency = 0.8
					}):Play()
				end)
				clone.InputEnded:Connect(function(_)
					HDAdminMain.tweenService:Create(fade, TweenInfo.new(0.2), {
						BackgroundTransparency = 1
					}):Play()
				end)

				clone.Parent = parent
			end

			spawn(function()
				wait(0.1)
				updateCanvasSize(parent, parent["Answer" .. #data.Answers], parent.Question) -- inferred equivalent call
			end)
		end

		if v4 == 1 or v4 == 17 then
			local udim = UDim2.new(1, -255, 1, -155)

			if HDAdminMain.device ~= "Mobile" and parent2.Position ~= udim then
				parent2.Position = udim
				parent2.Size = UDim2.new(0, 250, 0, 150)
			end

			local v6 = p[2]
			local v7 = value == "dance"
			local infoFrame = mainFrame2:FindFirstChild("InfoFrame")

			if infoFrame then
				infoFrame.Visible = false
			end

			local desc = mainFrame2:FindFirstChild("Desc")

			if desc then
				desc.Visible = false
			end

			mainFrame2.InputFrame.Visible = false
			local v8 = p[1]

			if v8 == "Info" and desc then
				mainFrame2.Desc.Text = p[2]
				mainFrame2.Desc.Visible = true
			elseif v8 == "Input" then
				local textBox = mainFrame2.InputFrame.Frame.TextBox
				local commandSpeed = HDAdminMain.commandSpeeds[value]
				mainFrame2.InputFrame.InputName.Text = v6 .. ":"
				textBox.Text = commandSpeed

				local character = HDAdminMain.player.Character

				if v7 and character then
					task.delay(0.2, function()
						local function listenForAnimation()
							local v9 = nil

							for _, child in pairs(character:GetChildren()) do
								if child:GetAttribute("HDDance") then
									v9 = child
									break
								end
							end

							if not v9 then
								return v9
							end

							local hdSpeed = v9:GetAttribute("HDSpeed")

							if hdSpeed then
								textBox.Text = hdSpeed
							end

							v9.Destroying:Once(function()
								task.delay(0.2, function()
									if not listenForAnimation() then
										ClientCoreFunctions:DestroyCommandMenuFrame(parent2)
									end
								end)
							end)

							return v9
						end

						listenForAnimation()
					end)
				end

				if HDAdminMain.infoFramesViewed[v6] and infoFrame then
					HDAdminMain.infoFramesViewed[v6] = nil

					if v6 == "Speed" then
						local v9 = HDAdminMain.device == "Computer" and {
							{ "Movement", "WASD" },
							{ "Toggle flight", "E" },
							{ "Up & Down", "R & F" }
						} or {
							{ "Movement", "Thumbstick" },
							{ "Toggle flight", "Double-jump" }
						}

						for i = 1, 3 do
							local v10 = infoFrame["Info" .. i]
							local v11 = v9[i]

							if v11 then
								v10.Text = v11[1] .. ":"
								v10.TextLabel.Text = v11[2]
								v10.Visible = true
							else
								v10.Visible = false
							end
						end

						if not v7 then
							infoFrame.Okay.MouseButton1Down:Connect(function()
								infoFrame.Visible = false
							end)
							infoFrame.Visible = true
						end
					end
				end

				local text = textBox.Text
				textBox.FocusLost:Connect(function()
					local text2 = tonumber(textBox.Text) or commandSpeed

					textBox.Text = "..."
					local v9 = HDAdminMain.signals.RequestCommandModification:InvokeServer(HDAdminMain.pdata.Prefix .. value .. " me " .. text2)
					local animations = HDAdminMain.settings.CommandLimits.animations

					if v7 then
						local limit = animations.Limit
						local minimum = animations.Minimum

						if limit < text2 then
							text2 = limit
						elseif text2 < minimum then
							text2 = minimum
						end

						textBox.Text = text2
					elseif not v9 then
						textBox.Text = text
					end

					text = textBox.Text
				end)
				mainFrame2.InputFrame.Visible = true
			end

			ClientCoreFunctions:UpdateCommandMenu(value, parent2)
			local changeStatus = mainFrame2:FindFirstChild("ChangeStatus")
			local textLabel = changeStatus and changeStatus.TextLabel
			mainFrame2.ChangeStatus.MouseButton1Down:Connect(function()
				mainFrame2.Loading.Visible = true

				if HDAdminMain.commandsToDisableCompletely[value] then
					local text = textLabel and textLabel.Text or "DISABLE"
					local v9

					if text == "DISABLE" or text == "STOP" then
						v9 = "!Un" .. value
					else
						v9 = "!" .. value
					end

					HDAdminMain.signals.RequestCommandModification:InvokeServer(v9)

					if v7 then
						task.defer(function()
							ClientCoreFunctions:DestroyCommandMenuFrame(parent2)
						end)
					end

					wait(1)
				elseif HDAdminMain.commandsActive[value] then
					HDAdminMain.commandsActive[value] = nil
				else
					HDAdminMain:GetModule("cf"):ActivateClientCommand(value)
					wait(0.5)
				end

				ClientCoreFunctions:UpdateCommandMenu(value, parent2)

				if parent2 and parent2.Parent then
					mainFrame2.Loading.Visible = false
				end
			end)

			parent2.ZIndex += 11
			local getFrame = mainFrame2:FindFirstChild("GetFrame")

			if v7 and getFrame then
				local textBox = getFrame.LinkUGC.Holder.TextBox
				local hdPrevDance = nil
				local connection = nil
				local connection2 = nil
				local function updateEmoteId()
					if parent2.Parent then
						hdPrevDance = HDAdminMain.player:GetAttribute("HDPrevDance")
						textBox.Text = `roblox.com/catalog/{hdPrevDance}`

						if connection then
							connection:Disconnect()
						end

						if connection2 then
							connection2:Disconnect()
						end

						connection = ClientCoreFunctions:SetupUnlockUGC(hdPrevDance, getFrame.UnlockUGC)
						connection2 = ClientCoreFunctions:SetupFavoriteUGC(hdPrevDance, getFrame.FavoriteUGC)
					end
				end
				updateEmoteId()
				task.delay(0.25, updateEmoteId)
				task.delay(0.5, updateEmoteId)
				task.delay(1, updateEmoteId)
				dragBar.Title.Text = "Emote"
				textBox.TextSize = mainFrame2.InputFrame.Frame.TextBox.AbsoluteSize.Y
			end
		elseif v4 == 2 then
			if value == "cmdbar2" then
				dragBar.Title.Text = "Cmdbar2"
			end

			if HDAdminMain.device ~= "Mobile" then
				parent2.Position = UDim2.new(0, 35, 1, -105)
				parent2.Size = UDim2.new(0, 315, 0, 70)
			end

			local searchFrame = mainFrame2.SearchFrame
			local textBox = searchFrame.TextBox
			local v6 = {
				maxSuggestions = 3,
				mainParent = mainFrame2.Parent,
				textBox = textBox,
				rframe = searchFrame.ResultsFrame,
				suggestionPos = 1,
				suggestionDisplayed = 0,
				forceExecute = false,
				highlightColor = Color3.fromRGB(50, 50, 50),
				otherColor = Color3.fromRGB(80, 80, 80),
				suggestionLabels = {},
				currentBarCommand = nil
			}

			HDAdminMain:GetModule("CmdBar"):SetupTextbox(value, v6)
			local loading = mainFrame2.Loading
			mainFrame2.Execute.MouseButton1Down:Connect(function()
				loading.Visible = true

				if #textBox.Text > 1 then
					local v7 = textBox.Text
					local v8 = string.sub(v7, 1, 1)

					if
						v8 ~= HDAdminMain.settings.UniversalPrefix
						and v8 ~= HDAdminMain.settings.ChatPrefix
						and v8 ~= HDAdminMain.pdata.Prefix
					then
						v7 = HDAdminMain.pdata.Prefix .. v7
					end

					if string.sub(v7, -1) == " " then
						v7 = string.sub(v7, 1, -1)
					end

					HDAdminMain.signals.RequestCommandSilent:InvokeServer(v7)
				end

				loading.Visible = false
			end)
		elseif v4 == 3 then
			if value == "cmdbar2" then
				dragBar.Title.Text = "Cmdbar2"
			end

			if HDAdminMain.device ~= "Mobile" then
				parent2.Position = UDim2.new(0, 40, 1, -145)
				parent2.Size = UDim2.new(0, 315, 0, 105)
			end

			local searchFrame = mainFrame2.PlayerFrame.SearchFrame
			local textBox = searchFrame.TextBox
			textBox.Text = p and p.TargetName or HDAdminMain.player.Name

			local v6 = {
				maxSuggestions = 3,
				mainParent = mainFrame2.Parent,
				textBox = textBox,
				rframe = searchFrame.ResultsFrame,
				suggestionPos = 1,
				suggestionDisplayed = 0,
				forceExecute = false,
				highlightColor = Color3.fromRGB(50, 50, 50),
				otherColor = Color3.fromRGB(80, 80, 80),
				suggestionLabels = {},
				currentBarCommand = nil,
				specificArg = "player"
			}

			HDAdminMain:GetModule("CmdBar"):SetupTextbox(value, v6)

			local messageFrame = mainFrame2:FindFirstChild("MessageFrame")

			if messageFrame then
				messageFrame.Visible = false
			end
		elseif v4 == 4 then
			local v6 = p[1]
			local text = p[2]
			dragBar.Title.Text = "Message from " .. v6.Name
			mainFrame2.MessageFrame.Message.Text = text

			local replyFrame = mainFrame2:FindFirstChild("ReplyFrame")
			local send = mainFrame2:FindFirstChild("Send")

			if replyFrame then
				replyFrame.Visible = false
			end

			if send then
				send.Visible = false
			end
		elseif v4 == 5 then
			local v6 = math.ceil(mainFrame.ScrollFrame.AbsoluteSize.Y / 11)
			local template = mainFrame.ScrollFrame.Template
			local v7 = v6 / 3
			local scrollFrame = mainFrame2.ScrollFrame
			local loadMore = mainFrame2.LoadMore
			local displaying = loadMore.Displaying
			local load = loadMore.Load
			scrollFrame.Template:Destroy()
			parent2.Parent = HDAdminMain.gui

			local function getLabelText(data) -- 2 equivalent calls inferred from this helper
				local message = data.message
				local timeAdded = data.timeAdded
				local v8 = os.date("*t", timeAdded)
				local speakerName = data.speakerName
				local v9 = v8.hour
				local v10 = v8.min

				if v9 < 10 then
					v9 = "0" .. v9
				end

				if v10 < 10 then
					v10 = "0" .. v10
				end

				return "[" .. v9 .. ":" .. v10 .. "] " .. speakerName .. ": " .. message
			end

			local clones = {}

			local v8 = 0
			local v9 = 0
			local function displayElements(p4, p5)
				v8 = math.min(p4 + p5 - 1, #clones)

				for i = p4, v8 do
					local v10 = clones[i]
					local textLabel = v10.TextLabel
					local x = HDAdminMain.textService:GetTextSize(
						textLabel.Text,
						tonumber(textLabel.TextSize),
						textLabel.Font,
						Vector2.new(1e999, v6)
					).X

					if v9 < x then
						v9 = x
					end

					v10.Parent = scrollFrame
				end

				displaying.Text = ("%d/%d"):format(v8, #clones)
				local visible = v8 < #clones
				loadMore.Visible = visible
				scrollFrame.Size = visible and UDim2.new(1, 0, 0.84, 0) or UDim2.new(1, 0, 0.92, 0)
				scrollFrame.CanvasSize = UDim2.new(0, v9, 0, v8 * v6)
			end
			load.MouseButton1Click:Connect(function()
				displayElements(v8 + 1, 20)
			end)
			local function clearLogElements()
				clones = {}

				for _, child in pairs(scrollFrame:GetChildren()) do
					if child.Name ~= "UIListLayout" then
						child:Destroy()
					end
				end

				displaying.Text = "0/0"
				v8 = 0
				v9 = 0
				load.Visible = true
			end
			local function updateLog(items)
				clearLogElements()

				for k, item in pairs(items) do
					local clone = template:Clone()
					local textLabel = clone.TextLabel
					textLabel.Text = getLabelText(item) -- inferred equivalent call
					clone.BackgroundColor3 = ClientCoreFunctions:GetLabelBackgroundColor(k)
					clone.Visible = true
					clone.Name = "Record" .. k
					clone.Size = UDim2.new(1, 0, 0, v6)
					textLabel.Position = UDim2.new(0, v7, 0.5, 0)
					textLabel.Size = UDim2.new(1, -v7 * 2, textLabel.Size.Y.Scale, 0)
					clones[#clones + 1] = clone
				end

				displayElements(1, 20)
			end
			updateLog(p)

			local flag = true
			local textBox = mainFrame2.SearchBar.Frame.TextBox

			textBox.FocusLost:connect(function(_)
				if flag then
					flag = false
					local text = string.lower(textBox.Text)
					local v10 = {}

					for _, v11 in pairs(p) do
						local v12 = string.lower(getLabelText(v11)) -- inferred equivalent call

						if string.find(v12, text, 1, true) then
							table.insert(v10, v11)
						end
					end

					updateLog(v10)
					setupOriginalZIndex(scrollFrame)
					updateZIndex(HDAdminMain.commandMenus, scrollFrame)
					wait(0.5)
					flag = true
				end
			end)
		elseif v4 == 6 then
			local scrollFrame = mainFrame2.ScrollFrame
			local v6 = {
				["AG Server"] = "All",
				["AJ Length"] = "Infinite",
				["AHB Alts Decide"] = "Yes"
			}
			local v7 = {}
			local searchFrame = scrollFrame["AC Target Player"].SearchFrame
			local textBox = searchFrame.TextBox
			local targetPlayer = p.targetPlayer
			local ajaTime = scrollFrame["AJA Time"]
			local aaSpace = scrollFrame["AA Space"]
			local azSpace = scrollFrame["AZ Space"]
			local axBan = scrollFrame["AX Ban"]
			local textBox2 = scrollFrame["AM Reason"].SearchFrame.TextBox
			local ahaAltsTitle = scrollFrame["AHA Alts Title"]
			local ahbAltsDecide = scrollFrame["AHB Alts Decide"]
			local ahcAltsSpace = scrollFrame["AHC Alts Space"]
			local v8 = {
				v6,
				function(state, p4, p5)
					if state.Name == p4 then
						state.BackgroundTransparency = 0.1
						state.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
						v7[p5.Name] = p4

						if p5.Name == "AJ Length" then
							if state.Name == "Time" then
								ajaTime.Visible = true
							else
								ajaTime.Visible = false
							end
						elseif p5.Name == "AG Server" then
							local visible = state.Name == "All"
							ahaAltsTitle.Visible = visible
							ahbAltsDecide.Visible = visible
							ahcAltsSpace.Visible = visible

							if not v7["AHB Alts Decide"] then
								v7["AHB Alts Decide"] = v6["AHB Alts Decide"]
							end
						end
					else
						state.BackgroundTransparency = 0.8
						state.TextLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
					end
				end,
				scrollFrame,
				azSpace,
				aaSpace
			}
			setupDefaultToggles(v6, scrollFrame, textBox, v8, function(p4)
				if p4.Name == "AG Server" then
					selectToggle(p4, p.server, v8)
				elseif p4.Name == "AJ Length" then
					selectToggle(p4, p.length, v8)
				end
			end, ajaTime, targetPlayer)
			local v9 = {
				maxSuggestions = 3,
				mainParent = mainFrame2.Parent,
				textBox = textBox,
				rframe = searchFrame.ResultsFrame,
				suggestionPos = 1,
				suggestionDisplayed = 0,
				forceExecute = false,
				highlightColor = Color3.fromRGB(50, 50, 50),
				otherColor = Color3.fromRGB(80, 80, 80),
				suggestionLabels = {},
				currentBarCommand = nil,
				specificArg = "player"
			}

			HDAdminMain:GetModule("CmdBar"):SetupTextbox(value, v9)

			local timeDetails = p.timeDetails

			if timeDetails then
				timeDetails:gsub("%d+%a", function(value5)
					local v10 = tonumber(value5:match("%d+"))

					if v10 then
						local match = value5:match("%a")
						local _, v11, text = HDAdminMain:GetModule("cf"):GetTimeAmount(match, v10)
						ajaTime[v11].TextBox.Text = text
					end
				end)
			end

			local reason = p.reason

			if reason and reason ~= "" and reason ~= " " then
				textBox2.Text = reason
			end

			axBan.MouseButton1Down:Connect(function()
				local text = textBox2.Text
				local text2 = textBox.Text
				local text3 = ajaTime.Minutes.TextBox.Text
				local text4 = ajaTime.Hours.TextBox.Text
				local text5 = ajaTime.Days.TextBox.Text
				local v10 = {
					server = v7["AG Server"],
					length = v7["AJ Length"],
					lengthTime = text3 .. "m" .. text4 .. "h" .. text5 .. "d",
					banAlts = v7["AHB Alts Decide"]
				}
				ClientCoreFunctions:DestroyCommandMenuFrame(parent2)
				HDAdminMain.signals.RequestCommandModification:InvokeServer(
					HDAdminMain.pdata.Prefix .. "directBan" .. HDAdminMain.pdata.SplitKey .. text2 .. HDAdminMain.pdata.SplitKey .. text,
					v10
				)
			end)
			spawn(function()
				wait(0.1)
				updateCanvasSize(scrollFrame, azSpace, aaSpace) -- inferred equivalent call
			end)
		elseif v4 == 7 then
			local scrollFrame = mainFrame2.ScrollFrame
			local v6 = { ["AG DisplayFrom"] = "Enabled" }
			local v7 = {}
			local searchFrame = scrollFrame["AJ MessageColor"].SearchFrame
			local textBox = searchFrame.TextBox
			local axSubmit = scrollFrame["AX Submit"]
			local azLoading = scrollFrame["AZ Loading"]
			local afTitle = scrollFrame["AF Title"]
			local textBox2 = scrollFrame["AC MessageTitle"].SearchFrame.TextBox
			local textBox3 = scrollFrame["AM Message"].SearchFrame.TextBox
			local v8 = {
				v6,
				function(state, p4, p5)
					if state.Name == p4 then
						state.BackgroundTransparency = 0.1
						state.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
						v7[p5.Name] = p4
					else
						state.BackgroundTransparency = 0.8
						state.TextLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
					end
				end,
				scrollFrame
			}
			afTitle.TextLabel.Text = "Display 'From " .. HDAdminMain.player.Name .. "'"
			setupDefaultToggles(v6, scrollFrame, textBox, v8, function(p4)
				if p4.Name == "AG DisplayFrom" then
					selectToggle(p4, "Enabled", v8)
				end
			end)
			local v9 = {
				maxSuggestions = 3,
				mainParent = mainFrame2.Parent,
				textBox = textBox,
				rframe = searchFrame.ResultsFrame,
				suggestionPos = 1,
				suggestionDisplayed = 0,
				forceExecute = false,
				highlightColor = Color3.fromRGB(50, 50, 50),
				otherColor = Color3.fromRGB(80, 80, 80),
				suggestionLabels = {},
				currentBarCommand = nil,
				specificArg = "color"
			}

			HDAdminMain:GetModule("CmdBar"):SetupTextbox(value, v9)

			local finalResult = parent2.FinalResult
			local example = finalResult.Frame.Example
			setupFinalResult(parent2, axSubmit, azLoading, function()
				local displayFrom = v7["AG DisplayFrom"] == "Enabled"

				return (HDAdminMain.signals.RetrieveBroadcastData:InvokeServer({
					["Title"] = textBox2.Text,
					DisplayFrom = displayFrom,
					Color = textBox.Text,
					Message = textBox3.Text
				}))
			end, function(data)
				example.Title.Text = data.Title
				local displayFrom = data.DisplayFrom
				example.Pic.Visible = displayFrom
				example.SubTitle.Visible = displayFrom

				if displayFrom then
					example.Pic.Image = ClientCoreFunctions:GetUserImage(data.SenderId)
					example.SubTitle.Text = "From " .. data.SenderName
				end

				example.Desc.TextColor3 = Color3.new(data.Color[1], data.Color[2], data.Color[3])
				example.Desc.Text = data.Message
				finalResult.Visible = true
			end, function()
				return HDAdminMain.signals.ExecuteBroadcast:InvokeServer()
			end)
		elseif v4 == 8 then
			local text = p[1]
			local text2 = p[2]
			local _ = p[3]
			local mute = dragBar.Mute
			local textLabel = mute.TextLabel

			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://" .. (HDAdminMain.pdata.Alert2SoundId or HDAdminMain.pdata.AlertSoundId)
			sound.Volume = HDAdminMain.pdata.AlertVolume
			sound.Pitch = HDAdminMain.pdata.AlertPitch
			sound.Looped = true
			sound.Parent = parent2
			sound:Play()
			dragBar.Title.Text = text
			mainFrame2.MessageFrame.Message.Text = text2
			mute.MouseButton1Down:Connect(function()
				if textLabel.Text == "🔊" then
					textLabel.Text = "🔇"
					sound:Pause()
				else
					textLabel.Text = "🔊"
					sound:Play()
				end
			end)
		elseif v4 == 9 then
			local scrollFrame = mainFrame2.ScrollFrame
			local v6 = { ["AC Server"] = "Current", ["AG ShowResultsTo"] = "You" }
			local v7 = {}
			local adTargetPlayer = scrollFrame["AD Target Player"]
			local searchFrame = adTargetPlayer.SearchFrame
			local textBox = searchFrame.TextBox
			local targetPlayer = p.targetPlayer
			local aaSpace = scrollFrame["AA Space"]
			local azSpace = scrollFrame["AZ Space"]
			local azLoading = scrollFrame["AZ Loading"]
			local axSubmit = scrollFrame["AX Submit"]
			local textBox2 = scrollFrame["AP Question"].SearchFrame.TextBox
			local v8 = {
				v6,
				function(state, p4, p5)
					local name = p5.Name

					if state.Name == p4 then
						state.BackgroundTransparency = 0.1
						state.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
						v7[p5.Name] = p4

						if name == "AC Server" then
							if state.Name == "Current" then
								adTargetPlayer.Visible = true
							else
								adTargetPlayer.Visible = false
							end
						end
					else
						state.BackgroundTransparency = 0.8
						state.TextLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
					end
				end,
				scrollFrame,
				azSpace,
				aaSpace
			}
			setupDefaultToggles(v6, scrollFrame, textBox, v8, function(p4)
				if p4.Name == "AC Server" then
					selectToggle(p4, p.server, v8)
				elseif v6[p4.Name] then
					selectToggle(p4, v6[p4.Name], v8)
				end
			end, nil, targetPlayer)
			local v9 = {
				maxSuggestions = 3,
				mainParent = mainFrame2.Parent,
				textBox = textBox,
				rframe = searchFrame.ResultsFrame,
				suggestionPos = 1,
				suggestionDisplayed = 0,
				forceExecute = false,
				highlightColor = Color3.fromRGB(50, 50, 50),
				otherColor = Color3.fromRGB(80, 80, 80),
				suggestionLabels = {},
				currentBarCommand = nil,
				specificArg = "player"
			}

			HDAdminMain:GetModule("CmdBar"):SetupTextbox(value, v9)
			local question = p.question

			if question and question ~= "" and question ~= " " then
				textBox2.Text = question
			end

			local asAnswer = scrollFrame["AS Answer"]
			local atAddAnswer = scrollFrame["AT AddAnswer"]
			local clones = {}
			asAnswer.Visible = false
			local function removeAnswerBox(clone)
				for k, v10 in pairs(clones) do
					if v10 == clone then
						table.remove(clones, k)
						break
					end
				end

				clone:Destroy()
				updateCanvasSize(scrollFrame, azSpace, aaSpace) -- inferred equivalent call
			end
			local function createAnswerBox()
				local clone = asAnswer:Clone()
				clone.Visible = true
				clone.Parent = scrollFrame
				clone.RemoveBox.MouseButton1Down:Connect(function()
					removeAnswerBox(clone)
				end)
				table.insert(clones, clone)
				updateCanvasSize(scrollFrame, azSpace, aaSpace) -- inferred equivalent call
				return clone
			end

			local answers = p.answers

			if type(answers) == "table" then
				for _, answer in pairs(answers) do
					if not (answer and answer ~= "" and answer ~= " ") then
						continue
					end

					createAnswerBox().SearchFrame.TextBox.Text = answer

					if #clones >= 10 then
						break
					end
				end
			end

			atAddAnswer.Add.MouseButton1Down:Connect(function()
				if #clones >= 10 then
					HDAdminMain:GetModule("Notices"):Notice(
						"Error",
						HDAdminMain.hdAdminCoreName,
						"Cannot exceed " .. 10 .. " answers!"
					)
					return
				end

				local answerBox = createAnswerBox()
				scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasPosition.Y + answerBox.AbsoluteSize.Y)
			end)

			local textBox3 = scrollFrame["AC VoteTime"].SearchFrame.TextBox
			local v10 = textBox3.Text
			textBox3.FocusLost:connect(function(_)
				local text = tonumber(textBox3.Text)
				local text2

				if text then
					text2 = text < 1 and 1 or text > 60 and 60 or text
				else
					text2 = v10
				end

				textBox3.Text = text2
				v10 = text2
			end)

			spawn(function()
				wait(0.1)
				updateCanvasSize(scrollFrame, azSpace, aaSpace) -- inferred equivalent call
			end)

			local finalResult = parent2.FinalResult
			local example = finalResult.Frame.Example
			setupFinalResult(parent2, axSubmit, azLoading, function()
				local text = textBox3.Text
				local text2 = textBox2.Text
				local acServer = v7["AC Server"]
				local agShowResultsTo = v7["AG ShowResultsTo"]
				local playerArg = textBox.Text:gsub(" ", function(_): string
					return ""
				end)
				local texts = {}

				for _, v11 in pairs(clones) do
					table.insert(texts, v11.SearchFrame.TextBox.Text)
				end

				return (HDAdminMain.signals.RetrievePollData:InvokeServer({
					["VoteTime"] = text,
					Question = text2,
					Answers = texts,
					Server = acServer,
					ShowResultsTo = agShowResultsTo,
					PlayerArg = playerArg
				}))
			end, function(p4)
				setupPollResults(example, p4)
				finalResult.Visible = true
			end, function()
				return HDAdminMain.signals.ExecutePoll:InvokeServer()
			end)
		elseif v4 == 10 then
			HDAdminMain.audio.Notice:Play()
			local scrollFrame = mainFrame2.ScrollFrame
			local textLabel = scrollFrame.Question.TextLabel
			local title = dragBar.Title

			local voteTime = p.VoteTime
			local v6 = voteTime + 1
			setupPollResults(scrollFrame, p)
			textLabel.Text = p.Question
			coroutine.wrap(function()
				for i = 1, voteTime do
					title.Text = p.SenderName .. "'s Poll (" .. v6 - i .. ")"
					wait(1)
				end

				ClientCoreFunctions:DestroyCommandMenuFrame(parent2)
			end)()
		elseif v4 == 11 then
			HDAdminMain.audio.Notice:Play()
			local randomiseTable = HDAdminMain:GetModule("cf"):RandomiseTable({
				Color3.fromRGB(220, 30, 30),
				Color3.fromRGB(220, 93, 29),
				Color3.fromRGB(188, 161, 23),
				Color3.fromRGB(107, 186, 22),
				Color3.fromRGB(19, 179, 46),
				Color3.fromRGB(20, 197, 197),
				Color3.fromRGB(24, 120, 255),
				Color3.fromRGB(101, 24, 255),
				Color3.fromRGB(217, 24, 255),
				Color3.fromRGB(255, 24, 128)
			})

			local scrollFrame = mainFrame2.ScrollFrame
			local textLabel = scrollFrame.Question.TextLabel
			local _title = dragBar.Title

			textLabel.Text = p.Question
			local resultTemplate = scrollFrame.ResultTemplate
			resultTemplate.Visible = false
			local v6 = #p.Results

			for k, result in pairs(p.Results) do
				local clone = resultTemplate:Clone()
				clone.Visible = true
				clone.Name = "Answer" .. k
				clone.Bar.BackgroundColor3 = randomiseTable[k]
				local v7 = k .. ". " .. result.Answer .. " ("

				if k == v6 then
					v7 = result.Answer .. " ("
					clone.Bar.BackgroundColor3 = Color3.fromRGB(175, 175, 175)
				end

				clone.TextLabel.Text = v7 .. "0)"
				clone.BackgroundColor3 = ClientCoreFunctions:GetLabelBackgroundColor(k)
				clone.Bar.Size = UDim2.new(0, 0, 1, 0)
				delay((k - 1) / 10, function()
					local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quart)
					local intValue = Instance.new("IntValue")
					intValue.Value = 0
					HDAdminMain.tweenService:Create(clone.Bar, tweenInfo, {
						Size = UDim2.new(result.Percentage, 0, 1, 0)
					}):Play()
					HDAdminMain.tweenService:Create(intValue, tweenInfo, { Value = result.Votes }):Play()
					intValue.Changed:Connect(function(p4)
						clone.TextLabel.Text = v7 .. p4 .. ")"
					end)
					wait(2)
					intValue:Destroy()
				end)
				clone.Parent = scrollFrame
			end

			spawn(function()
				wait(0.1)
				updateCanvasSize(scrollFrame, scrollFrame["Answer" .. #p.Answers], scrollFrame.Question) -- inferred equivalent call
			end)
		elseif v4 == 12 then
			local scrollFrame = mainFrame2.ScrollFrame
			local v6 = { ["AC Server"] = "Current" }
			local v7 = {}
			local adTargetPlayer = scrollFrame["AD Target Player"]
			local searchFrame = adTargetPlayer.SearchFrame
			local textBox = searchFrame.TextBox
			local targetPlayer = p.targetPlayer
			local aaSpace = scrollFrame["AA Space"]
			local azSpace = scrollFrame["AZ Space"]
			local axSpace = scrollFrame["AX Space"]
			local azLoading = scrollFrame["AZ Loading"]
			local axSubmit = scrollFrame["AX Submit"]
			local textBox2 = scrollFrame["AG MessageTitle"].SearchFrame.TextBox
			local textBox3 = scrollFrame["AM Message"].SearchFrame.TextBox
			local v8 = {
				v6,
				function(state, p4, p5)
					local name = p5.Name

					if state.Name == p4 then
						state.BackgroundTransparency = 0.1
						state.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
						v7[p5.Name] = p4

						if name == "AC Server" then
							if state.Name == "Current" then
								adTargetPlayer.Visible = true
								axSpace.Visible = false
							else
								adTargetPlayer.Visible = false
								axSpace.Visible = true
							end
						end
					else
						state.BackgroundTransparency = 0.8
						state.TextLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
					end
				end,
				scrollFrame,
				azSpace,
				aaSpace
			}
			setupDefaultToggles(v6, scrollFrame, textBox, v8, function(p4)
				if p4.Name == "AC Server" then
					selectToggle(p4, p.server, v8)
				elseif v6[p4.Name] then
					selectToggle(p4, v6[p4.Name], v8)
				end
			end, nil, targetPlayer)
			local v9 = {
				maxSuggestions = 3,
				mainParent = mainFrame2.Parent,
				textBox = textBox,
				rframe = searchFrame.ResultsFrame,
				suggestionPos = 1,
				suggestionDisplayed = 0,
				forceExecute = false,
				highlightColor = Color3.fromRGB(50, 50, 50),
				otherColor = Color3.fromRGB(80, 80, 80),
				suggestionLabels = {},
				currentBarCommand = nil,
				specificArg = "player"
			}

			HDAdminMain:GetModule("CmdBar"):SetupTextbox(value, v9)
			local message = p.message

			if message and message ~= "" and message ~= " " then
				textBox3.Text = message
			end

			textBox2.Text = "Alert from " .. HDAdminMain.player.Name

			local finalResult = parent2.FinalResult
			local example = finalResult.Frame.Example
			setupFinalResult(parent2, axSubmit, azLoading, function()
				local text = textBox2.Text
				local text2 = textBox3.Text
				local acServer = v7["AC Server"]
				local playerArg = textBox.Text:gsub(" ", function(_): string
					return ""
				end)

				return (HDAdminMain.signals.RetrieveAlertData:InvokeServer({
					["Title"] = text,
					Message = text2,
					Server = acServer,
					PlayerArg = playerArg
				}))
			end, function(p4)
				example.Title.Text = p4.Title
				example.Message.Text = p4.Message
				finalResult.Visible = true
			end, function()
				return HDAdminMain.signals.ExecuteAlert:InvokeServer()
			end)
		elseif v4 == 13 then
			local textBox = mainFrame2.LinkFrame.TextBox
			local v6 = tostring(p)
			local v7 = "roblox.com/game-pass/" .. v6
			local visibleChangedConnection = nil
			local textChangedConnection = nil
			local imageLabel = mainFrame2.MessageFrame.ImageLabel
			local title = dragBar.Title
			task.defer(function()
				local _, result = pcall(function()
					return HDAdminMain.marketplaceService:GetProductInfo(v6, Enum.InfoType.GamePass).Name
				end)

				title.Text = `Unlock {result}`
			end)
			textBox.PlaceholderText = v7
			textBox.Text = v7
			imageLabel.Image = `rbxthumb://type=GamePass&id={v6}&w=150&h=150`
			visibleChangedConnection = parent2:GetPropertyChangedSignal("Visible"):Connect(function()
				if not parent2.Visible then
					visibleChangedConnection:Disconnect()
					textChangedConnection:Disconnect()
				end
			end)
			textChangedConnection = textBox:GetPropertyChangedSignal("Text"):Connect(function()
				textBox.Text = v7
			end)
		elseif v4 == 14 then
			parent2.ClickAway.MouseButton1Click:Once(function()
				ClientCoreFunctions:DestroyCommandMenuFrame(parent2)
			end)
		elseif v4 == 15 then
			parent2.ClickAway.MouseButton1Click:Once(function()
				ClientCoreFunctions:DestroyCommandMenuFrame(parent2)
			end)
		elseif v4 == 16 then
			parent2.ZIndex += 10
			parent2.Position = HDAdminMain.gui.MainFrame.Position
			parent2:SetAttribute("AlsoDragMainFrame", true)
			local v6 = nil

			for _, v7 in HDAdminMain.commandInfo do
				if v7 and v7.Name == "emote" then
					v6 = v7
					break
				end
			end

			if not v6 then
				return
			end

			local scrollFrame = parent2.MainFrame.ScrollFrame
			local emotes = HDAdminMain:GetModule("cf"):GetEmotes()

			local _pages = HDAdminMain.gui.MainFrame.Pages
			local commandTemplate = HDAdminMain:GetModule("PageCommands"):GetCommandTemplate()
			local v7 = nil
			local prefix = HDAdminMain.pdata.Prefix or ";"
			local topLabel = commandTemplate:Clone()
			topLabel.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
			topLabel.TextLabel.Position = UDim2.new(0.04, 0, 0.5, 0)
			topLabel.Arrow:Destroy()
			topLabel.LayoutOrder = -1
			topLabel.TextLabel.Text = `Type {prefix}emotes to view`
			topLabel.Name = "TopLabel"
			topLabel.Visible = true
			topLabel.Parent = scrollFrame

			local clones = {}
			local v8 = {}
			local v9 = {}
			local function createLabel(p4)
				local id = p4.id
				local v10 = tostring(id)
				local name = p4.name
				local clone = commandTemplate:Clone()
				table.insert(v9, v10)
				clone.LayoutOrder = #v9
				clones[v10] = clone
				v8[v10] = p4
				ClientCoreFunctions:SetupUnlockUGC(id, clone.UnlockUGC)
				ClientCoreFunctions:SetupFavoriteUGC(id, clone.FavoriteUGC)
				clone.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone.RunCommand.Visible = true
				clone.RunIcon.Visible = true
				clone.PendingIcon.Visible = true
				clone.Expand.Visible = false
				clone.Arrow.Visible = false
				HDAdminMain:GetModule("PageCommands"):SetupUICommandRunner(clone, v6, " me " .. name)
				clone.TextLabel.Text = name
				clone.Name = name
				clone.Visible = true
				clone.Parent = scrollFrame
				v7 = clone
			end
			local function updateOrder()
				local favoritedUGC = HDAdminMain.pdata.FavoritedUGC or {}
				table.sort(v9, function(a, b)
					local v10 = favoritedUGC[a]
					local v11 = favoritedUGC[b]

					if v10 and v11 then
						return (v10.addedTime or 0) > (v11.addedTime or 0)
					end

					if v10 or v11 then
						return v10 and not v11
					end

					local v12 = clones[a]
					local v13 = clones[b]
					return v12.LayoutOrder < v13.LayoutOrder
				end)
				local count = 0

				for _, v10 in v9 do
					local v11 = clones[v10]
					count += 1
					v11.LayoutOrder = count
					v11.BackgroundColor3 = HDAdminMain:GetModule("cf"):GetLabelBackgroundColor(count)
					v7 = v11
				end

				updateCanvasSize(scrollFrame, v7, topLabel) -- inferred equivalent call
			end

			for k, emote in emotes do
				createLabel(emote, k)
			end

			updateOrder()

			local connection = module:Connect(function(p4, p5)
				if p5 and not clones[tostring(p4)] then
					local nameFromEmoteId = ClientCoreFunctions:GetNameFromEmoteId(p4)
					createLabel({ id = tonumber(p4), name = nameFromEmoteId })
				end

				task.defer(updateOrder)
			end)
			parent2.Destroying:Once(function()
				connection:Disconnect()
			end)

			task.delay(0.1, function()
				updateCanvasSize(scrollFrame, v7, topLabel) -- inferred equivalent call
			end)
		elseif v4 == 18 then
			parent2.ClickAway.MouseButton1Click:Once(function()
				ClientCoreFunctions:DestroyCommandMenuFrame(parent2)
			end)
			local unlock = mainFrame2.Unlock
			local v6 = p[1]
			local v7 = false
			unlock.MouseButton1Click:Connect(function()
				if not v7 then
					v7 = true
					HDAdminMain.signals.PurchaseAccessory:FireServer(v6)
					task.delay(1, function()
						v7 = false
					end)
				end
			end)
			local nameFromEmoteId = ClientCoreFunctions:GetNameFromEmoteId(v6)
			local animationId = HDAdminMain:GetModule("cf"):GetAnimationId(v6)
			local denormalizeName = HDAdminMain:GetModule("cf"):denormalizeName(nameFromEmoteId)
			local viewportFrame = mainFrame2.ViewportFrame
			mainFrame2.Title.Text = denormalizeName
			ClientCoreFunctions:SetupAnimatedRig(viewportFrame, animationId)
		end

		setupOriginalZIndex(parent2, p3)
		table.insert(HDAdminMain.commandMenus, parent2)
		updateZIndex(HDAdminMain.commandMenus)
	end

	parent2.Parent = HDAdminMain.gui
	parent2.Visible = true
end

function ClientCoreFunctions.RegisterEmoteId(_, p)
	module:Fire(p, true)
end

function ClientCoreFunctions:GetNameFromEmoteId(p)
	local emotes = HDAdminMain:GetModule("cf"):GetEmotes()

	local v4 = tonumber(p)

	for _, emote in emotes do
		if tonumber(emote.id) == v4 then
			return emote.name
		end
	end

	return "unknown"
end

local flag = false
function ClientCoreFunctions:SetupFavoriteUGC(p, instance)
	instance.Visible = true
	local v4 = tostring(p)
	local AvatarEditorService = game:GetService("AvatarEditorService")
	local v5 = (HDAdminMain.pdata.FavoritedUGC or {})[v4] == nil
	local function updateStar(p2)
		local nameFromEmoteId = ClientCoreFunctions:GetNameFromEmoteId(p)
		local v6 = `Removed '{nameFromEmoteId}' {p} from favorites`

		local v7 = not v5
		local v8

		if v7 then
			v6 = `Added '{nameFromEmoteId}' {p} to favorites`
			v8 = 101602995984924
		else
			v8 = 117947994309914
		end

		if instance.Parent then
			instance.ImageLabel.Image = "rbxassetid://" .. v8
		end

		if p2 then
			module:Fire(p, v7)
			HDAdminMain:GetModule("Notices"):Notice("Notice", HDAdminMain.hdAdminCoreName, v6, {
				"CallFunctionWithTime",
				3
			})
		end
	end
	local connection = module:Connect(function(p2, p3)
		if p2 == p then
			v5 = not p3
			updateStar()
		end
	end)
	instance.Destroying:Once(function()
		connection:Disconnect()
	end)
	updateStar()
	local function registerServer(p2, p3, p4)
		local success, result, v6 = pcall(function()
			return HDAdminMain.signals.FavoriteUGC:InvokeServer({ p2, p3, p4 })
		end)

		if not success then
			v6 = result
			result = false
		end

		if not result then
			HDAdminMain:GetModule("Notices"):Notice("Error", HDAdminMain.hdAdminCoreName, (tostring(v6)))
			flag = false
		end

		if success and result and p4 then
			local favoritedUGC = HDAdminMain.pdata.FavoritedUGC

			if typeof(v6) == "table" then
				favoritedUGC[v4] = v6
			end
		end

		return result, v6
	end

	return instance.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		local promptSetFavoriteCompletedConnection = AvatarEditorService.PromptSetFavoriteCompleted:Once(function(p2)
			if p2 ~= Enum.AvatarPromptResult.PermissionDenied then
				local v6 = v5
				v5 = not v5
				registerServer(p, v6, true)
				updateStar(true)
			end

			flag = false
		end)
		flag = true

		if registerServer(p, v5, false) then
			AvatarEditorService:PromptSetFavorite(p, Enum.AvatarItemType.Asset, v5)
		else
			promptSetFavoriteCompletedConnection:Disconnect()
		end
	end)
end

function ClientCoreFunctions:SetupUnlockUGC(p, p2)
	local v4 = false
	p2.Visible = true
	return p2.MouseButton1Click:Connect(function()
		if not v4 then
			v4 = true
			task.delay(1, function()
				v4 = false
			end)
			HDAdminMain:GetModule("cf"):CreateNewCommandMenu("Unlock", { p }, 18, true)
		end
	end)
end

function ClientCoreFunctions.GetMousePoint(_, _)
	local screenPointToRay = HDAdminMain.camera:ScreenPointToRay(
		HDAdminMain.lastHitPosition.X,
		HDAdminMain.lastHitPosition.Y
	)
	local ray = Ray.new(screenPointToRay.Origin, screenPointToRay.Direction * 100)
	local partOnRay, v4 = workspace:FindPartOnRay(ray, HDAdminMain.player.Character)
	return partOnRay, v4
end

function ClientCoreFunctions:GetLabelBackgroundColor(p)
	if p % 2 == 0 then
		return (Color3.fromRGB(50, 50, 50))
	end

	return (Color3.fromRGB(40, 40, 40))
end

function ClientCoreFunctions.GenerateTagFromId(_, p)
	local alphabet = HDAdminMain.alphabet
	local count = #alphabet
	local v4 = math.ceil(p / #alphabet)
	local v5 = math.ceil(p / (#alphabet) ^ 2)
	local v6 = alphabet[p % count] or alphabet[count]
	local v7 = alphabet[v4 % count] or alphabet[count]
	return (alphabet[v5 % count] or alphabet[count]) .. v7 .. v6
end

function ClientCoreFunctions.ClearPage(_, instance)
	for _, frame in pairs(instance:GetChildren()) do
		if frame.Name == "UIListLayout" or string.sub(frame.Name, 1, 8) == "Template" then
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		else
			frame:Destroy()
		end
	end
end

function ClientCoreFunctions.UpdateClientData(_)
	HDAdminMain.pdata = HDAdminMain.rfunction:InvokeServer("RetrievePlayerData")
end

function ClientCoreFunctions:SetupAnimatedRig(parent, p)
	local viewportCamera = parent:FindFirstChild("ViewportCamera")

	if not viewportCamera then
		viewportCamera = Instance.new("Camera")
		viewportCamera.Name = "ViewportCamera"
		viewportCamera.Parent = parent
		parent.CurrentCamera = viewportCamera
	end

	local viewportWorldModel = parent.ViewportWorldModel
	local clone = HDAdminMain.client.Assets.BlockyR15:Clone()
	local humanoid = clone.Humanoid
	local humanoidRootPart = clone.HumanoidRootPart
	local cframe = CFrame.Angles(0, 3.141592653589793, 0)
	local cframe2 = CFrame.new(0, -0.4, 15.75)
	viewportCamera.FieldOfView = 20
	viewportCamera.CFrame = humanoidRootPart.CFrame * cframe * cframe2
	clone.Parent = viewportWorldModel
	task.defer(function()
		pcall(function()
			clone.Humanoid:ApplyDescription(
				HDAdminMain.player.Character.Humanoid:GetAppliedDescription(),
				Enum.AssetTypeVerification.Always
			)
		end)
	end)

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. p
	animation.Parent = parent

	local result = nil
	local success = true
	local function trackCallback(callback)
		task.spawn(function()
			while not result and success == true do
				task.wait()
			end

			if not success then
				return
			end

			callback(result)
		end)
	end
	task.defer(function()
		success, result = pcall(function()
			return humanoid.Animator:LoadAnimation(animation)
		end)

		if not success then
			return
		end

		result.Looped = true
		result:Play()
	end)
	return clone, trackCallback
end

return ClientCoreFunctions