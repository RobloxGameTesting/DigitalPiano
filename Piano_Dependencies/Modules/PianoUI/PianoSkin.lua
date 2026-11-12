local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local v = {
	BG0 = Color3.fromRGB(10, 11, 14),
	BG1 = Color3.fromRGB(16, 18, 22),
	BG2 = Color3.fromRGB(24, 26, 32),
	Card = Color3.fromRGB(22, 24, 30),
	Panel = Color3.fromRGB(26, 28, 36),
	Accent = Color3.fromRGB(70, 145, 255),
	AccentHi = Color3.fromRGB(110, 185, 255),
	AccentLo = Color3.fromRGB(40, 95, 210),
	Success = Color3.fromRGB(45, 200, 125),
	Warn = Color3.fromRGB(255, 190, 90),
	Danger = Color3.fromRGB(255, 95, 110),
	Text = Color3.fromRGB(245, 246, 250),
	SubText = Color3.fromRGB(190, 196, 210),
	Muted = Color3.fromRGB(130, 138, 155),
	Stroke = Color3.fromRGB(82, 92, 112),
	StrokeSoft = Color3.fromRGB(55, 63, 78),
	Glass = Color3.fromRGB(255, 255, 255),
	Corner = 10,
	CornerLg = 14,
	StrokePx = 1.6,
	StrokeGlow = 2.8
}

local v2 = {
	WhiteTop = Color3.fromRGB(250, 252, 255),
	WhiteBottom = Color3.fromRGB(228, 232, 242),
	WhiteEdge = Color3.fromRGB(210, 214, 224),
	WhiteInner = Color3.fromRGB(255, 255, 255),
	WhiteGroove1 = Color3.fromRGB(198, 205, 218),
	WhiteGroove2 = Color3.fromRGB(230, 235, 245),
	BlackTop = Color3.fromRGB(60, 64, 74),
	BlackBottom = Color3.fromRGB(22, 24, 30),
	BlackEdge = Color3.fromRGB(36, 40, 50),
	BlackInner = Color3.fromRGB(86, 92, 105)
}

local function ensure(parent, className, name)
	if not parent then
		return nil
	end

	local v3

	if name then
		v3 = parent:FindFirstChild(name)
	end

	local v4 = v3 or parent:FindFirstChildOfClass(className)

	if v4 and (not name or v4.Name == name) then
		return v4
	end

	local instance = Instance.new(className)

	if name then
		instance.Name = name
	end

	instance.Parent = parent
	return instance
end

local function setFont(guiObject, value, p) -- 7 equivalent calls inferred from this helper
	if not (guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton"))) then
		return
	end

	guiObject.Font = p and Enum.Font.GothamSemibold or Enum.Font.Gotham
	guiObject.TextSize = value or 14
	guiObject.TextColor3 = v.Text
	guiObject.RichText = true
	guiObject.TextStrokeTransparency = 1
end

local function styleCard(parent, p)
	if not parent then
		return
	end

	parent.BackgroundColor3 = v.Card
	parent.BackgroundTransparency = 0.06
	local v3

	if parent then
		v3 = nil or parent:FindFirstChildOfClass("UICorner")

		if not v3 then
			v3 = Instance.new("UICorner")

			v3.Parent = parent
		end
	end

	v3.CornerRadius = UDim.new(0, p or v.Corner)
	local v4

	if parent then
		v4 = nil or parent:FindFirstChildOfClass("UIStroke")

		if not v4 then
			v4 = Instance.new("UIStroke")

			v4.Parent = parent
		end
	end

	v4.Thickness = v.StrokePx
	v4.Color = v.Stroke
	v4.Transparency = 0.18
	local uiGradient = parent:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", parent)
	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, v.Glass)
	})

	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.93),
		NumberSequenceKeypoint.new(1, 0.98)
	})
end

local function styleButton(button, p)
	if not button then
		return
	end

	button.AutoButtonColor = false

	if button:IsA("TextButton") then
		button.BackgroundColor3 = p and v.Accent or v.BG2
		button.BackgroundTransparency = p and 0 or 0.02
		button.TextColor3 = p and Color3.new(1, 1, 1) or v.Text
		setFont(button, 14, true)
	else
		button.BackgroundColor3 = v.BG2
		button.BackgroundTransparency = 0.02
	end

	local v3

	if button then
		v3 = nil or button:FindFirstChildOfClass("UICorner")

		if not v3 then
			v3 = Instance.new("UICorner")

			v3.Parent = button
		end
	end

	v3.CornerRadius = UDim.new(0, v.Corner)
	local v4

	if button then
		v4 = nil or button:FindFirstChildOfClass("UIStroke")

		if not v4 then
			v4 = Instance.new("UIStroke")

			v4.Parent = button
		end
	else
		v4 = nil
	end

	v4.Thickness = v.StrokePx + 0.4
	v4.Color = p and v.AccentHi or v.StrokeSoft
	v4.Transparency = 0.15

	local tween = TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})

	local tween2 = TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		BackgroundTransparency = p and 0 or 0.02
	})

	button.MouseEnter:Connect(function()
		tween:Play()
	end)
	button.MouseLeave:Connect(function()
		tween2:Play()
	end)
	button.MouseButton1Down:Connect(function()
		v4.Thickness = v.StrokeGlow
		TweenService:Create(v4, TweenInfo.new(0.18), {
			Thickness = v.StrokePx + 0.4
		}):Play()
	end)
end

local function setGradientBar(instance, p, p2)
	if not instance then
		return
	end

	instance.BackgroundTransparency = 1
	instance.ImageTransparency = 1
	local uiGradient = instance:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", instance)
	uiGradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p2) })

	uiGradient.Rotation = 0
end

local function styleSmallLabel(p, p2) -- 3 equivalent calls inferred from this helper
	if not p then
		return
	end

	setFont(p, 13, p2)
	p.TextColor3 = v.SubText
end

local function styleKey(button, p)
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	button.BackgroundTransparency = 0
	local edge

	if button then
		edge = button:FindFirstChild("Edge") or button:FindFirstChildOfClass("UIStroke")

		if not edge or edge.Name ~= "Edge" then
			edge = Instance.new("UIStroke")

			edge.Name = "Edge"

			edge.Parent = button
		end
	end

	edge.Thickness = 1
	edge.Transparency = 0.08
	edge.Color = p and v2.BlackEdge or v2.WhiteEdge
	local corner

	if button then
		corner = button:FindFirstChild("Corner") or button:FindFirstChildOfClass("UICorner")

		if not corner or corner.Name ~= "Corner" then
			corner = Instance.new("UICorner")

			corner.Name = "Corner"

			corner.Parent = button
		end
	end

	corner.CornerRadius = UDim.new(0, 4)

	local fill = button:FindFirstChild("Fill") or Instance.new("UIGradient")
	fill.Name = "Fill"
	fill.Rotation = 90
	fill.Color = p
		and ColorSequence.new({
			ColorSequenceKeypoint.new(0, v2.BlackTop),
			ColorSequenceKeypoint.new(1, v2.BlackBottom)
		})
		or ColorSequence.new({ ColorSequenceKeypoint.new(0, v2.WhiteTop), ColorSequenceKeypoint.new(1, v2.WhiteBottom) })

	fill.Parent = button

	local shine = button:FindFirstChild("Shine") or Instance.new("Frame")
	shine.Name = "Shine"
	shine.BackgroundTransparency = 1
	shine.BorderSizePixel = 0
	shine.ZIndex = (button.ZIndex or 1) + 1
	shine.Size = UDim2.fromScale(1, 1)
	shine.Parent = button

	local uiGradient = shine:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", shine)
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, p and 0.72 or 0.82),
		NumberSequenceKeypoint.new(0.15, p and 0.85 or 0.93),
		NumberSequenceKeypoint.new(0.4, 1),
		NumberSequenceKeypoint.new(1, 1)
	})

	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, p and v2.BlackInner or v2.WhiteInner),
		ColorSequenceKeypoint.new(1, p and v2.BlackInner or v2.WhiteInner)
	})

	local grooveL = button:FindFirstChild("GrooveL") or Instance.new("Frame")
	grooveL.Name = "GrooveL"
	grooveL.BackgroundColor3 = p and v2.BlackEdge or v2.WhiteGroove1
	grooveL.BorderSizePixel = 0
	grooveL.AnchorPoint = Vector2.new(0.5, 0)
	grooveL.Size = UDim2.new(0, 1, 1, -2)
	grooveL.Position = UDim2.new(0.2, 0, 0, 1)
	grooveL.ZIndex = (button.ZIndex or 1) + 1
	grooveL.Parent = button

	local grooveR = button:FindFirstChild("GrooveR") or Instance.new("Frame")
	grooveR.Name = "GrooveR"
	grooveR.BackgroundColor3 = p and v2.BlackEdge or v2.WhiteGroove2
	grooveR.BorderSizePixel = 0
	grooveR.AnchorPoint = Vector2.new(0.5, 0)
	grooveR.Size = UDim2.new(0, 1, 1, -2)
	grooveR.Position = UDim2.new(0.8, 0, 0, 1)
	grooveR.ZIndex = (button.ZIndex or 1) + 1
	grooveR.Parent = button

	local label = button:FindFirstChild("Label")

	if label and label:IsA("TextLabel") then
		label.BackgroundTransparency = 1
		label.TextColor3 = p and Color3.fromRGB(225, 230, 240) or Color3.fromRGB(30, 36, 44)
		setFont(label, 11, true)
	end

	local pressOverlay = button:FindFirstChild("PressOverlay") or Instance.new("Frame")
	pressOverlay.Name = "PressOverlay"
	pressOverlay.BackgroundColor3 = p and Color3.new(1, 1, 1) or Color3.new(0, 0, 0)
	pressOverlay.BackgroundTransparency = 1
	pressOverlay.BorderSizePixel = 0
	pressOverlay.Size = UDim2.fromScale(1, 1)
	pressOverlay.ZIndex = (button.ZIndex or 1) + 2
	pressOverlay.Parent = button

	local tween = TweenService:Create(
		pressOverlay,
		TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			BackgroundTransparency = p and 0.9 or 0.15
		}
	)

	local tween2 = TweenService:Create(
		pressOverlay,
		TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1 }
	)

	button.MouseButton1Down:Connect(function()
		tween:Play()
	end)
	button.MouseButton1Up:Connect(function()
		tween2:Play()
	end)
	button.MouseLeave:Connect(function()
		tween2:Play()
	end)
end

return {
	Apply = function(self)
		if not (self and self:IsA("ScreenGui")) then
			return
		end

		self.IgnoreGuiInset = true
		self.ResetOnSpawn = false

		local pianoContainer = self:FindFirstChild("PianoContainer")

		if pianoContainer and pianoContainer:IsA("ImageLabel") then
			pianoContainer.BackgroundColor3 = v.BG1
			pianoContainer.ImageTransparency = 1
			local uiGradient = pianoContainer:FindFirstChildOfClass("UIGradient")
				or Instance.new("UIGradient", pianoContainer)
			uiGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, v.BG1),
				ColorSequenceKeypoint.new(1, v.BG0)
			})
			uiGradient.Rotation = 90
			local v3

			if pianoContainer then
				v3 = nil or pianoContainer:FindFirstChildOfClass("UICorner")

				if not v3 then
					v3 = Instance.new("UICorner")

					v3.Parent = pianoContainer
				end
			end

			v3.CornerRadius = UDim.new(0, v.CornerLg)
			local v4

			if pianoContainer then
				v4 = nil or pianoContainer:FindFirstChildOfClass("UIStroke")

				if not v4 then
					v4 = Instance.new("UIStroke")

					v4.Parent = pianoContainer
				end
			end

			v4.Thickness = 1.2
			v4.Color = v.Stroke
			v4.Transparency = 0.18
		end

		local keyFrame = pianoContainer and pianoContainer:FindFirstChild("KeyFrame")

		if keyFrame and keyFrame:IsA("Frame") then
			keyFrame.BackgroundColor3 = v.Panel
			keyFrame.BackgroundTransparency = 0.06
			local v3

			if keyFrame then
				v3 = nil or keyFrame:FindFirstChildOfClass("UICorner")

				if not v3 then
					v3 = Instance.new("UICorner")

					v3.Parent = keyFrame
				end
			end

			v3.CornerRadius = UDim.new(0, v.Corner)
			local v4

			if keyFrame then
				v4 = nil or keyFrame:FindFirstChildOfClass("UIStroke")

				if not v4 then
					v4 = Instance.new("UIStroke")

					v4.Parent = keyFrame
				end
			end

			v4.Color = v.Stroke
			v4.Thickness = 1
			v4.Transparency = 0.22

			for _, button in ipairs(keyFrame:GetChildren()) do
				if not button:IsA("ImageButton") then
					continue
				end

				local name = tonumber(button.Name)

				local v5 = name and ({
					[1] = true,
					[4] = true,
					[6] = true,
					[9] = true,
					[11] = true
				})[(name % 12 + 12) % 12]
				local v6 = tostring(button.Name):find("-") ~= nil

				styleKey(button, v5 or v6)
			end
		end

		local velocityBar = pianoContainer and pianoContainer:FindFirstChild("VelocityBar")

		if velocityBar and velocityBar:IsA("ImageButton") then
			styleButton(velocityBar, false)
			setGradientBar(velocityBar:FindFirstChild("Bar"), v.AccentHi, v.AccentLo)
		end

		local screen = pianoContainer and pianoContainer:FindFirstChild("Screen")

		if screen and screen:IsA("ImageLabel") then
			styleCard(screen, v.CornerLg)
			local volume = screen:FindFirstChild("Volume")
			local transposition = screen:FindFirstChild("Transposition")

			if volume and volume:IsA("TextLabel") then
				setFont(volume, 12, true)
				local value = volume:FindFirstChild("Value")

				if value then
					setFont(value, 16, true)
					value.TextColor3 = v.Text
				end
			end

			if transposition and transposition:IsA("TextLabel") then
				setFont(transposition, 12, true)
				local value = transposition:FindFirstChild("Value")

				if value then
					setFont(value, 16, true)
					value.TextColor3 = v.Text
				end
			end
		end

		local soundfonts = pianoContainer and pianoContainer:FindFirstChild("Soundfonts")

		if soundfonts and soundfonts:IsA("ImageLabel") then
			styleCard(soundfonts, v.Corner)
			local label = soundfonts:FindFirstChild("Label")

			if label then
				setFont(label, 14, true)
			end

			local scrollingFrame = soundfonts:FindFirstChild("ScrollingFrame")

			if scrollingFrame then
				scrollingFrame.BackgroundTransparency = 1

				for _, button in ipairs(scrollingFrame:GetChildren()) do
					if not button:IsA("TextButton") then
						continue
					end

					styleButton(button, false)
					setFont(button, 14, true)
					local uiStroke = button:FindFirstChildOfClass("UIStroke")

					if uiStroke then
						uiStroke.Color = v.Accent
					end
				end
			end
		end

		local optionFrame = pianoContainer and pianoContainer:FindFirstChild("OptionFrame")

		if optionFrame and optionFrame:IsA("Frame") then
			optionFrame.BackgroundColor3 = v.Panel
			optionFrame.BackgroundTransparency = 0.06
			local v3

			if optionFrame then
				v3 = nil or optionFrame:FindFirstChildOfClass("UICorner")

				if not v3 then
					v3 = Instance.new("UICorner")

					v3.Parent = optionFrame
				end
			end

			v3.CornerRadius = UDim.new(0, v.Corner)

			local function styleIcon(guiObject) -- 1 equivalent call inferred from this helper
				if not guiObject then
					return
				end

				styleButton(guiObject, false)
				local textLabel = guiObject:FindFirstChild("TextLabel")

				if textLabel then
					styleSmallLabel(textLabel, true) -- inferred equivalent call
				end
			end

			for _, guiObject in ipairs(optionFrame:GetChildren()) do
				if guiObject:IsA("TextButton") then
					styleButton(
						guiObject,
						guiObject.Name == "PlayRecord" or guiObject.Name == "Record" or guiObject.Name == "OpenRecord"
					)
				elseif guiObject:IsA("ImageButton") then
					styleIcon(guiObject) -- inferred equivalent call
				elseif guiObject:IsA("TextLabel") then
					styleSmallLabel(guiObject, true) -- inferred equivalent call
				end
			end

			local sustain = optionFrame:FindFirstChild("Sustain")

			if sustain and sustain:IsA("ImageButton") then
				local led = sustain:FindFirstChild("LED")

				if led and led:IsA("ImageLabel") then
					setGradientBar(led, v.Success, v.Accent)
					led.ImageTransparency = 0.1
				end
			end
		end

		local sheets = pianoContainer and pianoContainer:FindFirstChild("Sheets")

		if sheets and sheets:IsA("ImageButton") then
			styleButton(sheets, false)
			local scrollingFrame = sheets:FindFirstChild("ScrollingFrame")

			if scrollingFrame then
				scrollingFrame.BackgroundTransparency = 1
				local sheetBox = scrollingFrame:FindFirstChild("SheetBox")

				if sheetBox and sheetBox:IsA("TextBox") then
					sheetBox.BackgroundColor3 = v.BG2
					sheetBox.BackgroundTransparency = 0.05
					local v3

					if sheetBox then
						v3 = nil or sheetBox:FindFirstChildOfClass("UICorner")

						if not v3 then
							v3 = Instance.new("UICorner")

							v3.Parent = sheetBox
						end
					end

					v3.CornerRadius = UDim.new(0, v.Corner)
					local v4

					if sheetBox then
						v4 = nil or sheetBox:FindFirstChildOfClass("UIStroke")

						if not v4 then
							v4 = Instance.new("UIStroke")

							v4.Parent = sheetBox
						end
					end

					v4.Thickness = v.StrokePx
					v4.Color = v.Stroke
					v4.Transparency = 0.35
					setFont(sheetBox, nil, false) -- inferred equivalent call
					sheetBox.PlaceholderColor3 = v.Muted
				end
			end
		end

		local autoPlayer = pianoContainer and pianoContainer:FindFirstChild("AutoPlayer")

		if autoPlayer and autoPlayer:IsA("Frame") then
			styleCard(autoPlayer, v.Corner)
			local notes = autoPlayer:FindFirstChild("Notes")

			if notes and notes:IsA("TextBox") then
				notes.BackgroundColor3 = v.BG2
				notes.BackgroundTransparency = 0.05
				setFont(notes, nil, false) -- inferred equivalent call
				local v3

				if notes then
					v3 = nil or notes:FindFirstChildOfClass("UICorner")

					if not v3 then
						v3 = Instance.new("UICorner")

						v3.Parent = notes
					end
				end

				v3.CornerRadius = UDim.new(0, v.Corner)
				local v4

				if notes then
					v4 = nil or notes:FindFirstChildOfClass("UIStroke")

					if not v4 then
						v4 = Instance.new("UIStroke")

						v4.Parent = notes
					end
				end

				v4.Thickness = v.StrokePx
				v4.Color = v.Stroke
				v4.Transparency = 0.35
			end

			local tempo = autoPlayer:FindFirstChild("Tempo")

			if tempo and tempo:IsA("TextBox") then
				tempo.BackgroundColor3 = v.BG2
				tempo.BackgroundTransparency = 0.05
				setFont(tempo, nil, true) -- inferred equivalent call
				local v3

				if tempo then
					v3 = nil or tempo:FindFirstChildOfClass("UICorner")

					if not v3 then
						v3 = Instance.new("UICorner")

						v3.Parent = tempo
					end
				end

				v3.CornerRadius = UDim.new(0, v.Corner)
				local v4

				if tempo then
					v4 = nil or tempo:FindFirstChildOfClass("UIStroke")

					if not v4 then
						v4 = Instance.new("UIStroke")

						v4.Parent = tempo
					end
				end

				v4.Thickness = v.StrokePx
				v4.Color = v.Stroke
				v4.Transparency = 0.35
			end

			local play = autoPlayer:FindFirstChild("Play")
			local mode = autoPlayer:FindFirstChild("Mode")

			if play and play:IsA("TextButton") then
				styleButton(play, true)
			end

			if mode and mode:IsA("TextButton") then
				styleButton(mode, false)
			end
		end

		local binds = pianoContainer and pianoContainer:FindFirstChild("Binds")

		if binds and binds:IsA("Frame") then
			styleCard(binds, v.Corner)

			for _, guiObject in ipairs(binds:GetChildren()) do
				if guiObject:IsA("TextButton") then
					styleButton(guiObject, guiObject.Name == "Save")
				end

				if guiObject:IsA("TextLabel") then
					styleSmallLabel(guiObject, true) -- inferred equivalent call
				end
			end

			local pianoContainer2 = binds:FindFirstChild("PianoContainer")

			if pianoContainer2 and pianoContainer2:IsA("ImageLabel") then
				pianoContainer2.BackgroundColor3 = v.BG2
				pianoContainer2.ImageTransparency = 1
				local v3

				if pianoContainer2 then
					v3 = nil or pianoContainer2:FindFirstChildOfClass("UICorner")

					if not v3 then
						v3 = Instance.new("UICorner")

						v3.Parent = pianoContainer2
					end
				end

				v3.CornerRadius = UDim.new(0, v.Corner)
				local v4

				if pianoContainer2 then
					v4 = nil or pianoContainer2:FindFirstChildOfClass("UIStroke")

					if not v4 then
						v4 = Instance.new("UIStroke")

						v4.Parent = pianoContainer2
					end
				end

				v4.Color = v.Stroke
				v4.Thickness = 1
				v4.Transparency = 0.35
			end
		end

		local modal = pianoContainer and pianoContainer:FindFirstChild("Modal")

		if modal and modal:IsA("Frame") then
			styleCard(modal, v.CornerLg)
			local header = modal:FindFirstChild("Header")
			local body = modal:FindFirstChild("Body")

			if header and header:IsA("Frame") then
				header.BackgroundColor3 = v.BG2
				local v3

				if header then
					v3 = nil or header:FindFirstChildOfClass("UICorner")

					if not v3 then
						v3 = Instance.new("UICorner")

						v3.Parent = header
					end
				end

				v3.CornerRadius = UDim.new(0, v.Corner)
				setFont(header:FindFirstChild("TitleLabel"), 16, true) -- inferred equivalent call

				local closeButton = header:FindFirstChild("CloseButton")

				if closeButton and closeButton:IsA("TextButton") then
					styleButton(closeButton, false)
					setFont(closeButton, nil, true) -- inferred equivalent call
				end
			end

			if body and body:IsA("Frame") then
				body.BackgroundColor3 = v.BG1
				local v3

				if body then
					v3 = nil or body:FindFirstChildOfClass("UICorner")

					if not v3 then
						v3 = Instance.new("UICorner")

						v3.Parent = body
					end
				end

				v3.CornerRadius = UDim.new(0, v.Corner)
			end
		end

		local pianoMain = self:FindFirstChild("PianoMain")

		if pianoMain and pianoMain:IsA("LocalScript") then
			local saveTemplate = pianoMain:FindFirstChild("SaveTemplate")

			if saveTemplate and saveTemplate:IsA("Frame") then
				styleCard(saveTemplate, v.Corner)
				local content = saveTemplate:FindFirstChild("Content")

				if content and content:IsA("Frame") then
					setFont(content:FindFirstChild("FileName"), nil, true) -- inferred equivalent call

					local fileNameBox = content:FindFirstChild("FileNameBox")

					if fileNameBox and fileNameBox:IsA("TextBox") then
						fileNameBox.BackgroundColor3 = v.BG2
						fileNameBox.BackgroundTransparency = 0.05
						local v3

						if fileNameBox then
							v3 = nil or fileNameBox:FindFirstChildOfClass("UICorner")

							if not v3 then
								v3 = Instance.new("UICorner")

								v3.Parent = fileNameBox
							end
						end

						v3.CornerRadius = UDim.new(0, v.Corner)
						local v4

						if fileNameBox then
							v4 = nil or fileNameBox:FindFirstChildOfClass("UIStroke")

							if not v4 then
								v4 = Instance.new("UIStroke")

								v4.Parent = fileNameBox
							end
						end

						v4.Color = v.Stroke
						v4.Transparency = 0.35
						v4.Thickness = v.StrokePx
						setFont(fileNameBox, nil, false) -- inferred equivalent call
						fileNameBox.PlaceholderColor3 = v.Muted
					end

					local saveButton = content:FindFirstChild("SaveButton")
					local loadButton = content:FindFirstChild("LoadButton")
					local deleteButton = content:FindFirstChild("DeleteButton")

					if saveButton and saveButton:IsA("TextButton") then
						styleButton(saveButton, true)
					end

					if loadButton and loadButton:IsA("TextButton") then
						styleButton(loadButton, false)
					end

					if deleteButton and deleteButton:IsA("TextButton") then
						styleButton(deleteButton, false)
						local uiStroke = deleteButton:FindFirstChildOfClass("UIStroke")

						if uiStroke then
							uiStroke.Color = v.Danger
						end
					end
				end
			end
		end

		local uiScale = pianoContainer and pianoContainer:FindFirstChildOfClass("UIScale")

		if uiScale then
			uiScale.Scale = UserInputService.TouchEnabled and 1.12 or 1
		end

		if not self:FindFirstChild("Dimmer") then
			local dimmer = Instance.new("Frame")
			dimmer.Name = "Dimmer"
			dimmer.BackgroundColor3 = Color3.new(0, 0, 0)
			dimmer.BackgroundTransparency = 0.45
			dimmer.BorderSizePixel = 0
			dimmer.Size = UDim2.fromScale(1, 1)
			dimmer.ZIndex = 0
			dimmer.LayoutOrder = -1000
			dimmer.Parent = self
		end
	end
}