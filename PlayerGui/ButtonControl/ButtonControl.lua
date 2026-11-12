local Boards = game.Workspace:WaitForChild("Boards")
local retriever = Boards:WaitForChild("SettingsHandler"):WaitForChild("Retriever")
local v = retriever:InvokeServer("Authenticate")
local v2

if v == true then
	v2 = retriever:InvokeServer("GetData") or nil
else
	v2 = nil
end

local v3 = nil

for _, child in pairs(Boards:GetChildren()) do
	if child.Name == "Buttons" then
		local surfaceGui = child:WaitForChild("SurfaceGui")

		for _, child2 in pairs(surfaceGui.MainFrame.ScrollingFrame:GetChildren()) do
			local v4 = child2
			child2.TextButton.MouseButton1Click:connect(function()
				local MarketplaceService = game:GetService("MarketplaceService")
				MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, v4.Id.Value, true)
			end)
			local v5 = child2
			child2.MouseEnter:connect(function()
				v5.TextButton.Title.TextColor3 = Color3.new(1, 1, 1)
			end)
			local v6 = child2
			child2.MouseLeave:connect(function()
				v6.TextButton.Title.TextColor3 = Color3.new(0.360784, 0.721569, 0.529412)
			end)
			local v7 = child2
			child2.MouseEnter:connect(function()
				v7.TextButton.ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
			end)
			local v8 = child2
			child2.MouseLeave:connect(function()
				v8.TextButton.ImageLabel.ImageColor3 = Color3.new(0.360784, 0.721569, 0.529412)
			end)
		end

		surfaceGui.MainFrame.ScrollingFrame.ChildAdded:connect(function(data)
			data.TextButton.MouseButton1Click:connect(function()
				local MarketplaceService = game:GetService("MarketplaceService")
				MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, data.Id.Value, true)
			end)

			data.MouseEnter:connect(function()
				data.TextButton.Title.TextColor3 = Color3.new(1, 1, 1)
			end)

			data.MouseLeave:connect(function()
				data.TextButton.Title.TextColor3 = Color3.new(0.360784, 0.721569, 0.529412)
			end)

			data.MouseEnter:connect(function()
				data.TextButton.ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
			end)

			data.MouseLeave:connect(function()
				data.TextButton.ImageLabel.ImageColor3 = Color3.new(0.360784, 0.721569, 0.529412)
			end)
		end)
	elseif child.Name == "Screen" then
		local surfaceGui = child:WaitForChild("SurfaceGui")

		local function hideExternalPrompt(p) -- 5 equivalent calls inferred from this helper
			if p then
				p.Visible = false
				p.Active = false
				p.AutoButtonColor = false
			end
		end

		hideExternalPrompt(surfaceGui.MainFrame.Information.MessageOne:FindFirstChild("GetModel")) -- inferred equivalent call
		hideExternalPrompt(surfaceGui.MainFrame.Information.MessageTwo:FindFirstChild("Support")) -- inferred equivalent call
		hideExternalPrompt(surfaceGui.MainFrame.Information.MessageTwo:FindFirstChild("SupportTwo")) -- inferred equivalent call
		hideExternalPrompt(surfaceGui.MainFrame.Information.MessageTwo:FindFirstChild("SupportThree")) -- inferred equivalent call
		hideExternalPrompt(surfaceGui.MainFrame.Information.MessageTwo:FindFirstChild("SupportFour")) -- inferred equivalent call

		local flag = true

		surfaceGui.MainFrame.Footer.Title.InfoButton.MouseButton1Click:connect(function()
			if flag then
				flag = false
				surfaceGui.MainFrame.Title:TweenPosition(UDim2.new(-1, 0, 0.01, 0), "InOut", "Quart", 0.5, true)
				wait()
				surfaceGui.MainFrame.ScrollingFrame:TweenPosition(
					UDim2.new(-1, 0, 0.07, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				surfaceGui.MainFrame.Footer:TweenPosition(UDim2.new(-1, 0, 0.94, 0), "InOut", "Quart", 0.5, true)
				wait()

				surfaceGui.MainFrame.Information:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true)
				wait()
				surfaceGui.MainFrame.Information.Title:TweenPosition(
					UDim2.new(0.013, 0, 0.01, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				surfaceGui.MainFrame.Information.MessageOne:TweenPosition(
					UDim2.new(0.013, 0, 0.08, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				surfaceGui.MainFrame.Information.MessageTwo:TweenPosition(
					UDim2.new(0.013, 0, 0.35, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				surfaceGui.MainFrame.Information.Close:TweenPosition(
					UDim2.new(0.3, 0, 0.7, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait(0.5)

				flag = true
			end
		end)

		surfaceGui.MainFrame.Information.Close.MouseButton1Click:connect(function()
			if flag then
				flag = false
				surfaceGui.MainFrame.Information.Title:TweenPosition(
					UDim2.new(-1, 0, 0.01, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				surfaceGui.MainFrame.Information.MessageOne:TweenPosition(
					UDim2.new(-1, 0, 0.08, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				surfaceGui.MainFrame.Information.MessageTwo:TweenPosition(
					UDim2.new(-1, 0, 0.35, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				surfaceGui.MainFrame.Information.Close:TweenPosition(
					UDim2.new(-1, 0, 0.7, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				delay(0.5, function()
					surfaceGui.MainFrame.Information.Position = UDim2.new(-1, 0, 0, 0)
				end)
				wait()
				surfaceGui.MainFrame.Title:TweenPosition(UDim2.new(0.013, 0, 0.01, 0), "InOut", "Quart", 0.5, true)
				wait()
				surfaceGui.MainFrame.ScrollingFrame:TweenPosition(
					UDim2.new(0.013, 0, 0.07, 0),
					"InOut",
					"Quart",
					0.5,
					true
				)
				wait()
				surfaceGui.MainFrame.Footer:TweenPosition(UDim2.new(0.013, 0, 0.94, 0), "InOut", "Quart", 0.5, true)
				wait(0.5)
				flag = true
			end
		end)

		if v == true then
			surfaceGui.MainFrame.Footer.Title.Settings.Visible = true

			surfaceGui.MainFrame.Footer.Title.Settings.MouseButton1Click:connect(function()
				if flag then
					flag = false
					v2, v3 = retriever:InvokeServer("GetData")
					surfaceGui.MainFrame.Settings.SettingsList.ListSize.Number.Text = v2.ListSize
					surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Text = v2.Datastore
					surfaceGui.MainFrame.Settings.SettingsList.Refresh.Number.Text = v2.Refresh

					if v3 == true then
						surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Min.Visible = false
						surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Plus.Visible = false
						surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Text = "Disabled because AbortCustomPurchases"
					end

					surfaceGui.MainFrame.Title:TweenPosition(UDim2.new(-1, 0, 0.01, 0), "InOut", "Quart", 0.5, true)
					wait()
					surfaceGui.MainFrame.ScrollingFrame:TweenPosition(
						UDim2.new(-1, 0, 0.07, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Footer:TweenPosition(UDim2.new(-1, 0, 0.94, 0), "InOut", "Quart", 0.5, true)
					wait()

					surfaceGui.MainFrame.Settings:TweenPosition(UDim2.new(0, 0, 0, 0), "InOut", "Quart", 0.5, true)
					wait()
					surfaceGui.MainFrame.Settings.Title:TweenPosition(
						UDim2.new(0.013, 0, 0.01, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Information:TweenPosition(
						UDim2.new(0.013, 0, 0.08, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.SettingsList:TweenPosition(
						UDim2.new(0.013, 0, 0.16, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Save:TweenPosition(
						UDim2.new(0.013, 0, 0.4, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Cancel:TweenPosition(
						UDim2.new(0.587, 0, 0.4, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait(0.5)
					flag = true
				end
			end)

			surfaceGui.MainFrame.Settings.Cancel.MouseButton1Click:connect(function()
				if flag then
					flag = false
					surfaceGui.MainFrame.Settings.Title:TweenPosition(
						UDim2.new(-1, 0, 0.01, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Information:TweenPosition(
						UDim2.new(-1, 0, 0.08, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.SettingsList:TweenPosition(
						UDim2.new(-1, 0, 0.16, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Cancel:TweenPosition(
						UDim2.new(-1, 0, 0.4, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Save:TweenPosition(
						UDim2.new(-1, 0, 0.4, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					delay(0.5, function()
						surfaceGui.MainFrame.Settings.Position = UDim2.new(-1, 0, 0, 0)
					end)
					wait()
					surfaceGui.MainFrame.Title:TweenPosition(UDim2.new(0.013, 0, 0.01, 0), "InOut", "Quart", 0.5, true)
					wait()
					surfaceGui.MainFrame.ScrollingFrame:TweenPosition(
						UDim2.new(0.013, 0, 0.07, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Footer:TweenPosition(UDim2.new(0.013, 0, 0.94, 0), "InOut", "Quart", 0.5, true)
					wait(0.5)
					flag = true
				end
			end)

			surfaceGui.MainFrame.Settings.Save.MouseButton1Click:connect(function()
				if flag then
					flag = false
					surfaceGui.MainFrame.Settings.Save.TextLabel.Text = "Saving..."
					v2 = retriever:InvokeServer("SetData", v2)
					surfaceGui.MainFrame.Settings.Save.TextLabel.Text = "Save"
					surfaceGui.MainFrame.Settings.Title:TweenPosition(
						UDim2.new(-1, 0, 0.01, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Information:TweenPosition(
						UDim2.new(-1, 0, 0.08, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.SettingsList:TweenPosition(
						UDim2.new(-1, 0, 0.16, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Cancel:TweenPosition(
						UDim2.new(-1, 0, 0.4, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Settings.Save:TweenPosition(
						UDim2.new(-1, 0, 0.4, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					delay(0.5, function()
						surfaceGui.MainFrame.Settings.Position = UDim2.new(-1, 0, 0, 0)
					end)
					wait()
					surfaceGui.MainFrame.Title:TweenPosition(UDim2.new(0.013, 0, 0.01, 0), "InOut", "Quart", 0.5, true)
					wait()
					surfaceGui.MainFrame.ScrollingFrame:TweenPosition(
						UDim2.new(0.013, 0, 0.07, 0),
						"InOut",
						"Quart",
						0.5,
						true
					)
					wait()
					surfaceGui.MainFrame.Footer:TweenPosition(UDim2.new(0.013, 0, 0.94, 0), "InOut", "Quart", 0.5, true)
					wait(0.5)
					flag = true
				end
			end)

			surfaceGui.MainFrame.Settings.SettingsList.ListSize.Number.Min.MouseButton1Click:connect(function()
				local text = tonumber(surfaceGui.MainFrame.Settings.SettingsList.ListSize.Number.Text)

				if text > 1 then
					text -= 1
					surfaceGui.MainFrame.Settings.SettingsList.ListSize.Number.Text = text
					v2.ListSize = text
				end
			end)

			surfaceGui.MainFrame.Settings.SettingsList.ListSize.Number.Plus.MouseButton1Click:connect(function()
				local text = tonumber(surfaceGui.MainFrame.Settings.SettingsList.ListSize.Number.Text)

				if text < 100 then
					text += 1
					surfaceGui.MainFrame.Settings.SettingsList.ListSize.Number.Text = text
					v2.ListSize = text
				end
			end)

			surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Min.MouseButton1Click:connect(function()
				local text = tonumber(surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Text)

				if text > 1 then
					text -= 1
					surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Text = text
					v2.Datastore = text
				end
			end)

			surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Plus.MouseButton1Click:connect(function()
				local text = tonumber(surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Text)

				if text < 100 then
					text += 1
					surfaceGui.MainFrame.Settings.SettingsList.Datastore.Number.Text = text
					v2.Datastore = text
				end
			end)

			surfaceGui.MainFrame.Settings.SettingsList.Refresh.Number.Min.MouseButton1Click:connect(function()
				local text = tonumber(surfaceGui.MainFrame.Settings.SettingsList.Refresh.Number.Text)

				if text > 1 then
					text -= 1
					surfaceGui.MainFrame.Settings.SettingsList.Refresh.Number.Text = text
					v2.Refresh = text
				end
			end)

			surfaceGui.MainFrame.Settings.SettingsList.Refresh.Number.Plus.MouseButton1Click:connect(function()
				local text = tonumber(surfaceGui.MainFrame.Settings.SettingsList.Refresh.Number.Text)

				if text < 10 then
					text += 1
					surfaceGui.MainFrame.Settings.SettingsList.Refresh.Number.Text = text
					v2.Refresh = text
				end
			end)
		end
	end
end