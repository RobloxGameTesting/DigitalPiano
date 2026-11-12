local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

local SoundFX = ReplicatedStorage2:WaitForChild("SoundFX")
local ClickSound = SoundFX:WaitForChild("ClickSound")
local Error = SoundFX:FindFirstChild("Error")

local Piano_Dependencies = workspace:WaitForChild("Piano_Dependencies")
local Modules = Piano_Dependencies:WaitForChild("Modules")
local Remotes = Piano_Dependencies:WaitForChild("Remotes")
local Logic = Modules:WaitForChild("Logic")

local RecordingLogic = require(Logic:WaitForChild("RecordingLogic"))
local PlaybackLogic = require(Logic:WaitForChild("PlaybackLogic"))

local SaveRecordingRemote = Remotes:WaitForChild("SaveRecordingRemote", 10)
local OverheadStatusUpdate = ReplicatedStorage2:WaitForChild("OverheadStatusUpdate", 10)
local LoadRecordingsRemote = Remotes:WaitForChild("LoadRecordingsRemote", 10)
local RecordingSavedRemote = Remotes:WaitForChild("RecordingSavedRemote", 10)
local DeleteRecordingRemote = Remotes:WaitForChild("DeleteRecordingRemote", 10)
local GetStorageInfoRemote = Remotes:WaitForChild("GetStorageInfoRemote", 10)
local CanPurchaseDeveloperProduct = Remotes:WaitForChild("CanPurchaseDeveloperProduct", 10)

local RecordingUIHandler = {}
RecordingUIHandler.CurrentPlayback = nil
RecordingUIHandler._isLoadingRecordings = false
RecordingUIHandler._connections = {}

local function getRecordingPressCount(data)
	if not data then
		return 0
	end

	if type(data.Notes) ~= "table" then
		return tonumber(data.TotalNotes) or 0
	end

	local count = 0

	for _, note in ipairs(data.Notes) do
		if note.Action == "Press" then
			count += 1
		end
	end

	return count
end

local v = nil

local v2 = nil
local v3 = nil

local function setOverheadStatus(p, p2) -- 4 equivalent calls inferred from this helper
	if v3 and v3() then
		return
	end

	if OverheadStatusUpdate then
		OverheadStatusUpdate:FireServer(p, p2)
	end
end

local function ShowRecordingOverhead() -- 1 equivalent call inferred from this helper
	setOverheadStatus("Recording", true) -- inferred equivalent call

	if v then
		v.Parent = nil
		v = nil
	end
end

local function HideRecordingOverhead() -- 2 equivalent calls inferred from this helper
	setOverheadStatus("Recording", false) -- inferred equivalent call

	if v then
		v.Parent = nil
		v = nil
	end
end

local function ShowPlaybackOverhead()
	setOverheadStatus("PlaybackRecording", true) -- inferred equivalent call

	if v2 then
		v2.Parent = nil
		v2 = nil
	end
end

local function HidePlaybackOverhead() -- 3 equivalent calls inferred from this helper
	setOverheadStatus("PlaybackRecording", false) -- inferred equivalent call

	if v2 then
		v2.Parent = nil
		v2 = nil
	end
end

function RecordingUIHandler.Initialize(data, p)
	for _, connection in ipairs(RecordingUIHandler._connections) do
		if connection and connection.Connected then
			connection:Disconnect()
		end
	end

	RecordingUIHandler._connections = {}

	local recordButton = data.RecordButton
	local playRecordButton = data.PlayRecordButton
	local v4

	if p then
		v4 = p.isPracticeMode or nil
	end

	v3 = v4
	local modal = data.Modal
	local saveTemplate = data.SaveTemplate
	local keysFrame = data.KeysFrame
	local logic_UI = data.Logic_UI

	if not (recordButton and modal and saveTemplate) then
		ClientDebugConfig.Warn("[RecordingUI] Missing required UI components")
		return
	end

	local sectionsScroll = modal.Body.SectionsScroll

	local function raiseRecordingCardLayer(guiObject)
		if not (guiObject and guiObject:IsA("GuiObject")) then
			return
		end

		local v5 = math.max(modal.ZIndex or 1, sectionsScroll.ZIndex or 1) + 2
		guiObject.ZIndex = math.max(guiObject.ZIndex, v5)

		for _, guiObject2 in ipairs(guiObject:GetDescendants()) do
			if guiObject2:IsA("GuiObject") then
				guiObject2.ZIndex = math.max(guiObject2.ZIndex, v5 + 1)
			end
		end
	end

	local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
	local MonetizationConfig = require(ReplicatedStorage3:WaitForChild("Monetization"):WaitForChild("MonetizationConfig"))
	local function getPreferredStorageProductId()
		for _, v5 in ipairs(MonetizationConfig.RecordingStorageProducts or {}) do
			local productId = math.floor(tonumber(v5.productId) or 0)

			if productId > 0 then
				return productId
			end
		end

		return 0
	end

	local preferredStorageProductId = getPreferredStorageProductId()
	local function playStorageErrorSound()
		if Error and Error:IsA("Sound") then
			local clone = Error:Clone()
			clone.Parent = SoundFX
			clone:Play()
			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, (math.max(1, clone.TimeLength + 0.25)))
		end
	end

	local function notifyStoragePurchaseBlocked(value) -- 2 equivalent calls inferred from this helper
		local text = tostring(value or "Storage is not available right now.")
		ClientDebugConfig.Warn("[RecordingUI] " .. text)
		playStorageErrorSound()
		pcall(function()
			local StarterGui = game:GetService("StarterGui")
			StarterGui:SetCore("SendNotification", {
				Title = "Recording Storage",
				Text = text,
				Duration = 4
			})
		end)
	end

	local function promptStorageUpgrade()
		if preferredStorageProductId == 0 then
			local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
			local openShop = ReplicatedStorage4:FindFirstChild("OpenShop")

			if openShop and openShop:IsA("BindableEvent") then
				openShop:Fire("Storage")
			end
		elseif CanPurchaseDeveloperProduct then
			local success, result, v5 = pcall(function()
				return CanPurchaseDeveloperProduct:InvokeServer(preferredStorageProductId)
			end)

			if success and result == true then
				MarketplaceService:PromptProductPurchase(LocalPlayer, preferredStorageProductId)
				return
			end

			notifyStoragePurchaseBlocked(success and v5 or "Storage purchase check failed. Try again.") -- inferred equivalent call
		else
			notifyStoragePurchaseBlocked("Storage purchase check is not ready yet.") -- inferred equivalent call
		end
	end
	local slotCounter = modal.Header:FindFirstChild("SlotCounter", true)
	local buyStorageButton = modal.Header:FindFirstChild("BuyStorageButton", true)
	local v5 = 10

	local function updateCounter(p2, p3) -- 3 equivalent calls inferred from this helper
		v5 = p3 or v5

		if slotCounter then
			slotCounter.Text = tostring(p2) .. "/" .. tostring(v5)
		end
	end
	RecordingUIHandler._updateCounter = updateCounter

	if slotCounter then
		slotCounter.AutomaticSize = Enum.AutomaticSize.X
		slotCounter.Size = UDim2.new(0, 0, slotCounter.Size.Y.Scale, slotCounter.Size.Y.Offset)
		v5 = v5 or v5

		if slotCounter then
			slotCounter.Text = tostring(0) .. "/" .. tostring(v5)
		end
	end

	if slotCounter and buyStorageButton then
		local function repositionBtn()
			buyStorageButton.Position = UDim2.new(
				slotCounter.Position.X.Scale,
				slotCounter.Position.X.Offset + slotCounter.AbsoluteSize.X + 8,
				0.5,
				0
			)
		end
		slotCounter:GetPropertyChangedSignal("AbsoluteSize"):Connect(repositionBtn)
		task.defer(repositionBtn)
	end

	local function showCapNotice()
		if modal:FindFirstChild("CapNoticeOverlay") then
			return
		end

		local capNoticeOverlay = Instance.new("Frame")
		local zIndex = math.max((modal.ZIndex or 1) + 50, 6500)
		capNoticeOverlay.Name = "CapNoticeOverlay"
		capNoticeOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
		capNoticeOverlay.BackgroundTransparency = 0.35
		capNoticeOverlay.BorderSizePixel = 0
		capNoticeOverlay.Size = UDim2.fromScale(1, 1)
		capNoticeOverlay.Active = true
		capNoticeOverlay.ZIndex = zIndex
		capNoticeOverlay.Parent = modal

		local dialog = Instance.new("Frame")
		dialog.Name = "Dialog"
		dialog.Size = UDim2.new(0, 360, 0, 160)
		dialog.AnchorPoint = Vector2.new(0.5, 0.5)
		dialog.Position = UDim2.fromScale(0.5, 0.5)
		dialog.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		dialog.BorderSizePixel = 0
		dialog.ZIndex = zIndex + 1
		dialog.Parent = capNoticeOverlay

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 8)
		uiCorner.Parent = dialog

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -20, 0, 38)
		textLabel.Position = UDim2.new(0, 10, 0, 10)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "Storage Full"
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextScaled = true
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.ZIndex = zIndex + 2
		textLabel.Parent = dialog

		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Size = UDim2.new(1, -20, 0, 48)
		textLabel2.Position = UDim2.new(0, 10, 0, 56)
		textLabel2.BackgroundTransparency = 1
		textLabel2.Text = "You've reached the maximum of 100 recording slots."
		textLabel2.TextWrapped = true
		textLabel2.TextScaled = true
		textLabel2.Font = Enum.Font.Gotham
		textLabel2.TextColor3 = Color3.fromRGB(230, 230, 230)
		textLabel2.ZIndex = zIndex + 2
		textLabel2.Parent = dialog

		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.new(0, 140, 0, 40)
		textButton.AnchorPoint = Vector2.new(0.5, 0)
		textButton.Position = UDim2.new(0.5, 0, 1, -50)
		textButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		textButton.Text = "OK"
		textButton.TextScaled = true
		textButton.Font = Enum.Font.GothamBold
		textButton.TextColor3 = Color3.new(1, 1, 1)
		textButton.ZIndex = zIndex + 3
		textButton.Parent = dialog

		local uiCorner2 = Instance.new("UICorner")
		uiCorner2.CornerRadius = UDim.new(0, 6)
		uiCorner2.Parent = textButton

		textButton.MouseButton1Click:Connect(function()
			ClickSound:Play()
			capNoticeOverlay:Destroy()
		end)
	end

	if buyStorageButton then
		local mouseButton1ClickConnection = buyStorageButton.MouseButton1Click:Connect(function()
			ClickSound:Play()

			if v5 >= 100 then
				showCapNotice()
			else
				promptStorageUpgrade()
			end
		end)
		table.insert(RecordingUIHandler._connections, mouseButton1ClickConnection)
	end

	task.spawn(function()
		if GetStorageInfoRemote then
			local success, result = pcall(function()
				return GetStorageInfoRemote:InvokeServer()
			end)

			if success and result then
				updateCounter(result.count, result.maxSlots) -- inferred equivalent call
			end
		end
	end)

	local openRecord = nil

	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		local pianoUI = playerGui:FindFirstChild("PianoUI")

		if pianoUI then
			local optionFrame = pianoUI.PianoContainer:FindFirstChild("OptionFrame")

			if optionFrame then
				openRecord = optionFrame:FindFirstChild("OpenRecord")
			end
		end
	end

	local function confirmDeletion(text)
		local confirmOverlay = Instance.new("Frame")
		local zIndex = math.max((modal.ZIndex or 1) + 50, 6500)
		confirmOverlay.Name = "ConfirmOverlay"
		confirmOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
		confirmOverlay.BackgroundTransparency = 0.35
		confirmOverlay.BorderSizePixel = 0
		confirmOverlay.Size = UDim2.fromScale(1, 1)
		confirmOverlay.Visible = true
		confirmOverlay.Active = true
		confirmOverlay.ZIndex = zIndex
		confirmOverlay.Parent = modal

		local dialog = Instance.new("Frame")
		dialog.Name = "Dialog"
		dialog.Size = UDim2.new(0, 360, 0, 160)
		dialog.AnchorPoint = Vector2.new(0.5, 0.5)
		dialog.Position = UDim2.fromScale(0.5, 0.5)
		dialog.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
		dialog.BorderSizePixel = 0
		dialog.ZIndex = zIndex + 1
		dialog.Parent = confirmOverlay

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 8)
		uiCorner.Parent = dialog

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Size = UDim2.new(1, -20, 0, 38)
		title.Position = UDim2.new(0, 10, 0, 10)
		title.BackgroundTransparency = 1
		title.Text = "Delete Recording"
		title.Font = Enum.Font.GothamBold
		title.TextScaled = true
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.ZIndex = zIndex + 2
		title.Parent = dialog

		local message = Instance.new("TextLabel")
		message.Name = "Message"
		message.Size = UDim2.new(1, -20, 0, 48)
		message.Position = UDim2.new(0, 10, 0, 56)
		message.BackgroundTransparency = 1
		message.Text = text
		message.TextWrapped = true
		message.TextScaled = true
		message.Font = Enum.Font.Gotham
		message.TextColor3 = Color3.fromRGB(230, 230, 230)
		message.ZIndex = zIndex + 2
		message.Parent = dialog

		local buttons = Instance.new("Frame")
		buttons.Name = "Buttons"
		buttons.Size = UDim2.new(1, -20, 0, 40)
		buttons.Position = UDim2.new(0, 10, 1, -50)
		buttons.BackgroundTransparency = 1
		buttons.ZIndex = zIndex + 2
		buttons.Parent = dialog

		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.FillDirection = Enum.FillDirection.Horizontal
		uiListLayout.Padding = UDim.new(0, 10)
		uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uiListLayout.Parent = buttons

		local function makeBtn(name, text2)
			local textButton = Instance.new("TextButton")
			textButton.Name = name
			textButton.Size = UDim2.new(0, 140, 1, 0)
			textButton.BackgroundColor3 = name == "Yes" and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(70, 70, 70)
			textButton.Text = text2
			textButton.TextScaled = true
			textButton.Font = Enum.Font.GothamBold
			textButton.TextColor3 = Color3.new(1, 1, 1)
			textButton.ZIndex = zIndex + 3
			local uiCorner2 = Instance.new("UICorner")
			uiCorner2.CornerRadius = UDim.new(0, 6)
			uiCorner2.Parent = textButton
			textButton.Parent = buttons
			return textButton
		end

		local btn = makeBtn("Yes", "Yes, delete")
		local btn2 = makeBtn("No", "No, cancel")

		local v6 = false
		local bindableEvent = Instance.new("BindableEvent")

		btn.MouseButton1Click:Connect(function()
			ClickSound:Play()
			v6 = true
			bindableEvent:Fire()
		end)
		btn2.MouseButton1Click:Connect(function()
			ClickSound:Play()
			v6 = false
			bindableEvent:Fire()
		end)

		bindableEvent.Event:Wait()
		confirmOverlay:Destroy()
		return v6
	end

	local function createRecordingCard(data2, p2)
		local clone = saveTemplate:Clone()
		clone.Name = "RecordingCard_" .. (data2.FileName or "Unknown")
		clone.Visible = true

		local content = clone:FindFirstChild("Content")

		if content then
			local fileName = content:FindFirstChild("FileName")
			local fileNameBox = content:FindFirstChild("FileNameBox")
			local loadButton = content:FindFirstChild("LoadButton")
			local saveButton = content:FindFirstChild("SaveButton")
			local deleteButton = content:FindFirstChild("DeleteButton")
			local fileInfo = content:FindFirstChild("FileInfo")

			if fileName and fileNameBox and loadButton and saveButton then
				fileName.Text = data2.FileName or "Untitled"
				fileNameBox.Text = data2.FileName or "Untitled"

				local v6 = data2 and data2.RecordingId ~= nil

				if fileInfo then
					if p2 and v6 then
						local duration = data2.Duration or 0
						local v7 = math.floor(duration / 60)
						local v8 = math.floor(duration % 60)
						local v9 = string.format("%d:%02d", v7, v8)

						local recordedDateLocal = data2.RecordedDateLocal or "Unknown date"
						local recordingPressCount = getRecordingPressCount(data2)
						local uniqueNotes = data2.UniqueNotes or 0

						fileInfo.Text = string.format(
							"%s | %s | %d notes (%d unique)",
							recordedDateLocal,
							v9,
							recordingPressCount,
							uniqueNotes
						)

						fileInfo.TextScaled = true
						fileInfo.TextWrapped = true
						fileInfo.Visible = true
					else
						fileInfo.Visible = false
					end
				end

				if p2 and v6 then
					fileNameBox.Visible = false
					saveButton.Visible = false
					fileName.Visible = true

					if deleteButton then
						deleteButton.Visible = true

						deleteButton.Position = saveButton.Position
						deleteButton.Size = saveButton.Size
						deleteButton.AnchorPoint = saveButton.AnchorPoint
						deleteButton.ZIndex = saveButton.ZIndex
					end
				else
					fileNameBox.Visible = true
					saveButton.Visible = true
					fileName.Visible = false

					if deleteButton then
						deleteButton.Visible = false
					end
				end

				if loadButton then
					loadButton.Visible = true
				end

				clone.Parent = sectionsScroll
				raiseRecordingCardLayer(clone)

				return clone, fileName, fileNameBox, loadButton, saveButton, deleteButton
			end

			ClientDebugConfig.Warn("[RecordingUI] SaveTemplate missing required elements")
			clone:Destroy()
			return nil
		end

		ClientDebugConfig.Warn("[RecordingUI] SaveTemplate missing Content frame")
		clone:Destroy()
		return nil
	end

	local function loadSavedRecordings()
		if RecordingUIHandler._isLoadingRecordings then
			return
		end

		RecordingUIHandler._isLoadingRecordings = true

		for _, frame in pairs(sectionsScroll:GetChildren()) do
			if frame:IsA("Frame") and frame ~= saveTemplate then
				frame:Destroy()
			end
		end

		if LoadRecordingsRemote then
			local success, result = pcall(function()
				return LoadRecordingsRemote:InvokeServer()
			end)

			if success then
				RecordingLogic.InitializeFileNumber(result)

				if GetStorageInfoRemote then
					task.spawn(function()
						local success2, result2 = pcall(function()
							return GetStorageInfoRemote:InvokeServer()
						end)

						if success2 and result2 then
							updateCounter(result2.count, result2.maxSlots) -- inferred equivalent call
						end
					end)
				else
					local v6 = result and #result or 0
					v5 = v5 or v5

					if slotCounter then
						slotCounter.Text = tostring(v6) .. "/" .. tostring(v5)
					end
				end

				if result and #result > 0 then
					for _, v6 in ipairs(result) do
						local recordingCard, _, _, v7, _, v8 = createRecordingCard(v6, true)

						if recordingCard and v7 then
							v7.MouseButton1Click:Connect(function()
								ClickSound:Play()

								if not (p.onRecording2DSourceReady and p.onRecording2DSourceReady(v6)) then
									RecordingUIHandler.PlayRecording(v6, p, playRecordButton, keysFrame, logic_UI)
								end

								if modal then
									modal.Visible = false
								end
							end)
						end

						if recordingCard and v8 and DeleteRecordingRemote then
							v8.MouseButton1Click:Connect(function()
								ClickSound:Play()
								local fileName = v6.FileName or "this recording"

								if not confirmDeletion(("Are you sure you want to delete \"%s\"?"):format(fileName)) then
									return
								end

								local recordingId = v6.RecordingId or v6.FileName

								if not recordingId then
									ClientDebugConfig.Warn("[RecordingUI] No identifier to delete.")
									return
								end

								DeleteRecordingRemote:FireServer(recordingId)
								task.delay(0.25, function()
									loadSavedRecordings()
								end)
							end)
						end
					end
				end
			else
				ClientDebugConfig.Warn("[RecordingUI] Failed to load recordings:", result)
			end

			RecordingUIHandler._isLoadingRecordings = false
		else
			ClientDebugConfig.Warn("[RecordingUI] LoadRecordingsRemote not available")
			RecordingUIHandler._isLoadingRecordings = false
		end
	end

	function RecordingUIHandler.OpenModal()
		if modal then
			modal.Visible = true
		end

		loadSavedRecordings()
	end

	if openRecord then
		local mouseButton1ClickConnection = openRecord.MouseButton1Click:Connect(function()
			ClickSound:Play()
			RecordingUIHandler.OpenModal()
		end)
		table.insert(RecordingUIHandler._connections, mouseButton1ClickConnection)
	end

	if playRecordButton then
		local mouseButton1ClickConnection = playRecordButton.MouseButton1Click:Connect(function()
			ClickSound:Play()

			if RecordingUIHandler.CurrentPlayback then
				if RecordingUIHandler.CurrentPlayback.IsPaused then
					RecordingUIHandler.CurrentPlayback:Resume()
					playRecordButton.Text = "Pause"
					playRecordButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
				else
					RecordingUIHandler.CurrentPlayback:Pause()
					playRecordButton.Text = "Resume"
					playRecordButton.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
				end
			else
				for _, frame in pairs(sectionsScroll:GetChildren()) do
					if frame:IsA("Frame") and frame ~= saveTemplate then
						frame:Destroy()
					end
				end

				RecordingUIHandler.OpenModal()
			end
		end)
		table.insert(RecordingUIHandler._connections, mouseButton1ClickConnection)
	end

	local mouseButton1ClickConnection = recordButton.MouseButton1Click:Connect(function()
		ClickSound:Play()

		if RecordingLogic.IsRecording() then
			local v6 = RecordingLogic.StopRecording()
			recordButton.Text = "Record"
			recordButton.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
			HideRecordingOverhead() -- inferred equivalent call

			if not v6 then
				ClientDebugConfig.Warn("[RecordingUI] Failed to stop recording")
				return
			end

			for _, frame in pairs(sectionsScroll:GetChildren()) do
				if frame:IsA("Frame") and frame ~= saveTemplate then
					frame:Destroy()
				end
			end

			modal.Visible = true

			local recordingCard, _, v7, v8, v9, v10 = createRecordingCard(v6, false)

			if not recordingCard then
				ClientDebugConfig.Warn("[RecordingUI] Failed to create recording card")
				return
			end

			if v10 then
				v10.Visible = false
			end

			v8.MouseButton1Click:Connect(function()
				ClickSound:Play()

				if not (p.onRecording2DSourceReady and p.onRecording2DSourceReady(v6)) then
					RecordingUIHandler.PlayRecording(v6, p, playRecordButton, keysFrame, logic_UI)
				end

				if modal then
					modal.Visible = false
				end
			end)

			local flag = false
			v9.MouseButton1Click:Connect(function()
				ClickSound:Play()

				if v3 and v3() then
					ClientDebugConfig.Warn("[RecordingUI] Practice mode recordings are local-only and cannot be saved.")
				elseif flag then
					flag = false
					v9.Text = "Save"
					promptStorageUpgrade()
				else
					local text = v7.Text

					if not text or text == "" then
						ClientDebugConfig.Warn("[RecordingUI] Enter a file name")
						return
					end

					v6.FileName = text

					if SaveRecordingRemote and RecordingSavedRemote then
						v9.Text = "Saving..."
						v9.Active = false
						local onClientEventConnection = nil
						onClientEventConnection = RecordingSavedRemote.OnClientEvent:Connect(function(p2, _, p3, p4)
							if p2 ~= true and p2 ~= false then
								return
							end

							onClientEventConnection:Disconnect()

							if p2 == true then
								updateCounter(p3, p4) -- inferred equivalent call
								modal.Visible = false
							else
								flag = true
								v9.Active = true
								v9.Text = "Full! (tap to buy)"
								task.delay(4, function()
									if flag and v9 and v9.Parent then
										flag = false
										v9.Text = "Save"
									end
								end)
							end
						end)
						SaveRecordingRemote:FireServer(v6)
						task.delay(10, function()
							if onClientEventConnection.Connected then
								onClientEventConnection:Disconnect()

								if v9 and v9.Parent then
									v9.Text = "Save"
									v9.Active = true
								end
							end
						end)
					else
						if not SaveRecordingRemote then
							ClientDebugConfig.Warn("[RecordingUI] SaveRecordingRemote not available")

							return
						end

						SaveRecordingRemote:FireServer(v6)
						modal.Visible = false
					end
				end
			end)
		else
			if v3 and v3() then
				ClientDebugConfig.Warn("[RecordingUI] Recording is disabled in Practice mode.")
				return
			end

			RecordingLogic.StartRecording()
			recordButton.Text = "Stop Recording"
			recordButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			ShowRecordingOverhead() -- inferred equivalent call
		end
	end)
	table.insert(RecordingUIHandler._connections, mouseButton1ClickConnection)

	local closeButton = modal.Header:FindFirstChild("CloseButton")

	if closeButton then
		local mouseButton1ClickConnection2 = closeButton.MouseButton1Click:Connect(function()
			ClickSound:Play()
			modal.Visible = false

			if not RecordingLogic.IsRecording() and recordButton then
				recordButton.Text = "Record"
				recordButton.BackgroundColor3 = Color3.fromRGB(38, 41, 46)
			end
		end)
		table.insert(RecordingUIHandler._connections, mouseButton1ClickConnection2)
	end

	task.spawn(function()
		if LoadRecordingsRemote then
			local success, result = pcall(function()
				return LoadRecordingsRemote:InvokeServer()
			end)

			if success and result then
				RecordingLogic.InitializeFileNumber(result)
			end
		end
	end)
end

function RecordingUIHandler.PlayRecording(p, data, p2, p3, data2)
	if RecordingUIHandler.CurrentPlayback then
		RecordingUIHandler.CurrentPlayback:Stop()

		if data.clearHighlights then
			data.clearHighlights()
		end
	end

	if p2 then
		p2.Text = "Pause"
		p2.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
	end

	if data.setPlaybackMode then
		data.setPlaybackMode(true)
	end

	task.spawn(ShowPlaybackOverhead)

	RecordingUIHandler.CurrentPlayback = PlaybackLogic.Play(p, {
		onNotePress = function(p4, p5, _, _)
			data.playNote(p4, p5, 0, nil)

			if data2 and not data.handlesUiHighlights then
				data2.PlayNote(p3, p4)
			end
		end,
		onNoteRelease = function(p4, _, _, _)
			data.finishNote(p4)

			if data2 and not data.handlesUiHighlights then
				data2.FinishNote(p3, p4)
			end
		end,
		onSustainToggle = function(p4)
			if data.toggleSustain then
				data.toggleSustain(p4)
			end
		end,
		onComplete = function()
			RecordingUIHandler.CurrentPlayback = nil

			if data.setPlaybackMode then
				data.setPlaybackMode(false)
			end

			HidePlaybackOverhead() -- inferred equivalent call

			if p2 then
				p2.Text = "Play/Pause"
				p2.BackgroundColor3 = Color3.fromRGB(60, 160, 255)
			end

			if data.clearHighlights then
				data.clearHighlights()
			elseif data2 then
				data2.ClearAllNotes(p3)
			end
		end
	})
end

function RecordingUIHandler.StopPlayback(p)
	if RecordingUIHandler.CurrentPlayback then
		RecordingUIHandler.CurrentPlayback:Stop()
		RecordingUIHandler.CurrentPlayback = nil

		if p and p.clearHighlights then
			p.clearHighlights()
		end

		if p and p.setPlaybackMode then
			p.setPlaybackMode(false)
		end

		HidePlaybackOverhead() -- inferred equivalent call
	end
end

function RecordingUIHandler.HideOverhead()
	HideRecordingOverhead() -- inferred equivalent call
end

function RecordingUIHandler.HidePlaybackOverhead()
	HidePlaybackOverhead() -- inferred equivalent call
end

if RecordingSavedRemote then
	RecordingSavedRemote.OnClientEvent:Connect(function(p, p2, p3, p4)
		if p == "storage_upgraded" or p == "storage_at_cap" then
			if RecordingUIHandler._updateCounter then
				RecordingUIHandler._updateCounter(p2, p3)
			end
		elseif p == "deleted" and RecordingUIHandler._updateCounter then
			RecordingUIHandler._updateCounter(p3, p4)
		end
	end)
end

return RecordingUIHandler