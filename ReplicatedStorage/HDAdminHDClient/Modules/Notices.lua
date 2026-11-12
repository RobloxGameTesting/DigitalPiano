local HDAdminMain = _G.HDAdminMain

local notices = HDAdminMain.gui.Notices
local template = notices.Template

local flag = true
local clones = {}
local v = {}

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.625, Enum.EasingStyle.Back, Enum.EasingDirection.In)

local function updateNotices(_)
	for k, v2 in pairs(v) do
		if v2.Complete.Value then
			continue
		end

		local v3 = tweenInfo
		local position

		if k == 1 then
			position = template.Position + UDim2.new(0, -v2.Size.X.Offset, 0, 0)
		else
			local _ = v[k - 1]
			position = UDim2.new(
				v2.Position.X.Scale,
				v2.Position.X.Offset,
				v2.Position.Y.Scale,
				template.Position.Y.Offset - (k - 1) * (template.Size.Y.Offset * 1.07)
			)
		end

		if position.Y.Offset > v2.Position.Y.Offset then
			v3 = tweenInfo2
		end

		if position then
			HDAdminMain.tweenService:Create(v2, v3, { Position = position }):Play()
		end
	end
end

local function endNotice(instance)
	if instance:FindFirstChild("Complete") and not instance.Complete.Value then
		instance.Complete.Value = true

		for k, v2 in pairs(v) do
			if v2 ~= instance then
				continue
			end

			table.remove(v, k)
			local v3 = HDAdminMain.tweenService:Create(instance, tweenInfo3, {
				Position = instance.Position + UDim2.new(0, instance.Size.X.Offset - 0, 0, 0)
			})
			v3:Play()
			v3.Completed:Wait()
			instance:Destroy()
		end
	end

	updateNotices()
end

local function Queue()
	if flag then
		flag = false

		repeat
			wait()

			if #clones > 0 then
				local v2 = clones[1]
				local customAudio = v2:GetAttribute("CustomAudio")
				v2.Parent = notices

				if customAudio then
					HDAdminMain.audio[customAudio]:Play()
				elseif v2.NoticeType.Value == "Error" then
					HDAdminMain.audio.Error:Play()
				else
					HDAdminMain.audio.Notice:Play()
				end

				table.insert(v, 1, v2)

				if v2.Countdown.Value < 900 then
					spawn(function()
						if v2.Countdown.Value > 0 then
							local now = os.time()

							repeat
								wait()
							until os.time() ~= now

							local text = v2.Desc.Text

							for i = 1, v2.Countdown.Value do
								if not v2:FindFirstChild("Desc") or v2.Desc.Text == "Teleporting..." then
									break
								end

								v2.Desc.Text = text .. " (" .. v2.Countdown.Value + 1 - i .. ")"
								wait(1)
							end
						else
							local lastTime = tick()

							repeat
								wait(0.1)
							until tick() - lastTime >= 7
						end

						endNotice(v2)
					end)
				end

				updateNotices(true)

				wait(0.5)
				table.remove(clones, 1)
			end
		until #clones < 1

		flag = true
	end
end

return {
	Notice = function(_, p, text, text2, list)
		if not (HDAdminMain.pdata and HDAdminMain.pdata.SetupData) then
			repeat
				wait(0.1)
			until HDAdminMain.pdata and HDAdminMain.pdata.SetupData
		end

		if HDAdminMain.settings.DisableAllNotices ~= true then
			task.defer(function()
				local mainFrame = HDAdminMain.gui:FindFirstChild("MainFrame")

				if not mainFrame then
					return
				end

				local v2 = mainFrame.AbsoluteSize.X * 0.75
				local absoluteSize = template.AbsoluteSize
				local v3 = v2 * (absoluteSize.Y / absoluteSize.X)
				local v4 = v3 / 6
				template.Position = UDim2.new(1, 0, 1, -v3)
				template.Size = UDim2.new(0, v2, 0, v3)
				template.Title.TextSize = v4
				template.Desc.UITextSizeConstraint.MaxTextSize = v4
				template.Desc.TextSize = v4

				local clone = template:Clone()
				clone.Visible = true
				clone.Title.Text = text
				clone.Desc.Text = text2
				clone.NoticeType.Value = p

				if type(list) == "table" then
					local v5 = true
					local function checkDe() -- 6 equivalent calls inferred from this helper
						if not v5 then
							return
						end

						v5 = false
						return true
					end
					local item = list[1]

					if item == "ShowSpecificPage" then
						clone.Countdown.Value = 20
						clone.TextButton.MouseButton1Down:Connect(function()
							if not checkDe() then -- inferred equivalent call
								return
							end

							HDAdminMain:GetModule("GUIs"):ShowSpecificPage(list[2], list[3])
							endNotice(clone)
						end)
					elseif item == "OpenCommands" then
						local item2 = list[2]
						clone.TextButton.MouseButton1Down:Connect(function()
							HDAdminMain:GetModule("GUIs"):ShowSpecificPage("Commands", "Commands", true)
							HDAdminMain:GetModule("PageCommands"):SetSearchText(item2)
							endNotice(clone)
						end)
					elseif item == "Teleport" then
						clone.Countdown.Value = 25
						clone.TextButton.MouseButton1Down:Connect(function()
							if not checkDe() then -- inferred equivalent call
								return
							end

							HDAdminMain.teleportService:Teleport(list[2])
							clone.Desc.Text = "Teleporting..."
						end)
					elseif item == "PM" then
						clone.Countdown.Value = 999
						clone.TextButton.MouseButton1Down:Connect(function()
							if not checkDe() then -- inferred equivalent call
								return
							end

							HDAdminMain:GetModule("cf"):CreateNewCommandMenu("privateMessage", { list[2], list[3] }, 4)
							endNotice(clone)
						end)
					elseif item == "CallFunctionOnClick" then
						local item2 = list[2]

						if item2 then
							clone.TextButton.MouseButton1Down:Connect(function()
								if not checkDe() then -- inferred equivalent call
									return
								end

								item2()
								endNotice(clone)
							end)
						end
					elseif item == "CallFunctionSpecialOnClick" then
						local item2 = list[2]
						clone:SetAttribute("CustomAudio", "Prompt")

						if item2 then
							clone.Countdown.Value = 60
							clone.TextButton.MouseButton1Down:Connect(function()
								if not checkDe() then -- inferred equivalent call
									return
								end

								item2()
								endNotice(clone)
							end)
						end
					elseif item == "CallFunctionWithTime" then
						local item2 = list[2]
						local item3 = list[3]
						clone:SetAttribute("CustomAudio", "Prompt")
						clone.Countdown.Value = item2

						if item3 then
							clone.TextButton.MouseButton1Down:Connect(function()
								if not checkDe() then -- inferred equivalent call
									return
								end

								item3()
								endNotice(clone)
							end)
						end
					end
				end

				clone.CloseX.MouseButton1Down:Connect(function()
					endNotice(clone)
				end)
				table.insert(clones, clone)
				Queue()
			end)
		end
	end
}