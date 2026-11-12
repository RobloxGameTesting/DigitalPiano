local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local parent = script.Parent
local card = parent:WaitForChild("Card")
local header = card:WaitForChild("Header")
local toolbar = card:WaitForChild("Toolbar")
local scroll = card:WaitForChild("Scroll")
local editor = scroll:WaitForChild("Editor")
local practiceDisplay = scroll:WaitForChild("PracticeDisplay")

local sizeMinus = toolbar:WaitForChild("SizeMinus")
local sizePlus = toolbar:WaitForChild("SizePlus")
local fontDropdown = toolbar:WaitForChild("FontDropdown")
local themeToggle = toolbar:WaitForChild("ThemeToggle")
local dropdownList = fontDropdown:WaitForChild("DropdownList")
local sizeIndicator = toolbar:WaitForChild("SizeIndicator")
local practice = toolbar:WaitForChild("Practice")
local practice2D = toolbar:WaitForChild("Practice2D")
local close = parent:WaitForChild("Close")
local resizeKnob = parent:WaitForChild("ResizeKnob")

local practiceTempoPrompt = parent:WaitForChild("PracticeTempoPrompt")
local tempoBox = practiceTempoPrompt:WaitForChild("TempoBox")
local start = practiceTempoPrompt:WaitForChild("Start")
local cancel = practiceTempoPrompt:WaitForChild("Cancel")

local v = {
	[" "] = true,
	["\n"] = true,
	["\r"] = true,
	["\t"] = true,
	["|"] = true,
	["-"] = true,
	[","] = true,
	[";"] = true
}

local v2 = "dark"
local flag = false
local v3 = {}
local v4 = 1
local set = {}
local v5 = nil
local folderSet = {}
local v6 = {}

local VPNotePlayed = ReplicatedStorage:FindFirstChild("VPNotePlayed")

if not VPNotePlayed then
	VPNotePlayed = Instance.new("BindableEvent")
	VPNotePlayed.Name = "VPNotePlayed"
	VPNotePlayed.Parent = ReplicatedStorage
end

local v7 = {
	dark = {
		root = Color3.fromRGB(25, 25, 25),
		panel = Color3.fromRGB(35, 35, 35),
		button = Color3.fromRGB(40, 40, 40),
		buttonHover = Color3.fromRGB(50, 50, 50),
		stroke = Color3.fromRGB(64, 68, 76),
		text = Color3.fromRGB(240, 240, 240),
		muted = Color3.fromRGB(170, 170, 170),
		placeholder = Color3.fromRGB(145, 145, 145),
		dropdown = Color3.fromRGB(30, 30, 30)
	},
	light = {
		root = Color3.fromRGB(235, 235, 235),
		panel = Color3.fromRGB(255, 255, 255),
		button = Color3.fromRGB(210, 210, 210),
		buttonHover = Color3.fromRGB(225, 225, 225),
		stroke = Color3.fromRGB(190, 190, 190),
		text = Color3.fromRGB(35, 35, 35),
		muted = Color3.fromRGB(85, 85, 85),
		placeholder = Color3.fromRGB(115, 115, 115),
		dropdown = Color3.fromRGB(240, 240, 240)
	}
}

local v8 = {
	{ name = "Amatic SC", font = Enum.Font.AmaticSC },
	{ name = "Antique", font = Enum.Font.Antique },
	{ name = "Arcade", font = Enum.Font.Arcade },
	{ name = "Arimo", font = Enum.Font.Arimo },
	{ name = "Arimo Bold", font = Enum.Font.ArimoBold },
	{ name = "Arial", font = Enum.Font.Arial },
	{ name = "Arial Bold", font = Enum.Font.ArialBold },
	{ name = "Bangers", font = Enum.Font.Bangers },
	{ name = "Bodoni", font = Enum.Font.Bodoni },
	{ name = "Builder Sans", font = Enum.Font.BuilderSans },
	{ name = "Builder Sans Bold", font = Enum.Font.BuilderSansBold },
	{ name = "Builder Sans ExtraBold", font = Enum.Font.BuilderSansExtraBold },
	{ name = "Builder Sans Medium", font = Enum.Font.BuilderSansMedium },
	{ name = "Cartoon", font = Enum.Font.Cartoon },
	{ name = "Code", font = Enum.Font.Code },
	{ name = "Creepster", font = Enum.Font.Creepster },
	{ name = "Denk One", font = Enum.Font.DenkOne },
	{ name = "Fantasy", font = Enum.Font.Fantasy },
	{ name = "Fondamento", font = Enum.Font.Fondamento },
	{ name = "Fredoka One", font = Enum.Font.FredokaOne },
	{ name = "Garamond", font = Enum.Font.Garamond },
	{ name = "Gotham", font = Enum.Font.Gotham },
	{ name = "Gotham Black", font = Enum.Font.GothamBlack },
	{ name = "Gotham Bold", font = Enum.Font.GothamBold },
	{ name = "Gotham Medium", font = Enum.Font.GothamMedium },
	{ name = "Grenze Gotisch", font = Enum.Font.GrenzeGotisch },
	{ name = "Highway", font = Enum.Font.Highway },
	{ name = "Indie Flower", font = Enum.Font.IndieFlower },
	{ name = "Josefin Sans", font = Enum.Font.JosefinSans },
	{ name = "Jura", font = Enum.Font.Jura },
	{ name = "Kalam", font = Enum.Font.Kalam },
	{ name = "Legacy", font = Enum.Font.Legacy },
	{ name = "Luckiest Guy", font = Enum.Font.LuckiestGuy },
	{ name = "Merriweather", font = Enum.Font.Merriweather },
	{ name = "Michroma", font = Enum.Font.Michroma },
	{ name = "Nunito", font = Enum.Font.Nunito },
	{ name = "Oswald", font = Enum.Font.Oswald },
	{ name = "Patrick Hand", font = Enum.Font.PatrickHand },
	{ name = "Permanent Marker", font = Enum.Font.PermanentMarker },
	{ name = "Roboto", font = Enum.Font.Roboto },
	{ name = "Roboto Condensed", font = Enum.Font.RobotoCondensed },
	{ name = "Roboto Mono", font = Enum.Font.RobotoMono },
	{ name = "Sarpanch", font = Enum.Font.Sarpanch },
	{ name = "SciFi", font = Enum.Font.SciFi },
	{ name = "Source Sans", font = Enum.Font.SourceSans },
	{ name = "Source Sans Bold", font = Enum.Font.SourceSansBold },
	{ name = "Source Sans Italic", font = Enum.Font.SourceSansItalic },
	{ name = "Source Sans Light", font = Enum.Font.SourceSansLight },
	{ name = "Source Sans Semibold", font = Enum.Font.SourceSansSemibold },
	{ name = "Special Elite", font = Enum.Font.SpecialElite },
	{ name = "Titillium Web", font = Enum.Font.TitilliumWeb },
	{ name = "Ubuntu", font = Enum.Font.Ubuntu }
}

local function getButtonLabel(instance) -- 6 equivalent calls inferred from this helper
	local textLabel = instance and instance:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		return textLabel
	end

	return nil
end

local function setButtonText(button, text) -- 11 equivalent calls inferred from this helper
	local buttonLabel = getButtonLabel(button) -- inferred equivalent call

	if buttonLabel then
		buttonLabel.Text = text
	elseif button and button:IsA("TextButton") then
		button.Text = text
	end
end

local function setButtonColor(button, backgroundColor)
	if button and button:IsA("GuiButton") then
		button.BackgroundColor3 = backgroundColor
	end
end

local function setStrokeColor(instance, color, p)
	local uiStroke = instance and instance:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Color = color
		uiStroke.Transparency = p or uiStroke.Transparency
	end
end

local function getPianoUI() -- 4 equivalent calls inferred from this helper
	return parent:FindFirstAncestor("PianoUI") or parent.Parent
end

local function escapeRichText(value)
	return (tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub(
		"'",
		"&apos;"
	))
end

local function charToDefaultNote(value)
	if typeof(value) ~= "string" or value == "" then
		return nil
	end

	return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(value, 1, true) or nil
end

local function isValidChar(value): boolean -- 2 equivalent calls inferred from this helper
	return typeof(value) == "string"
		and value ~= ""
		and ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(value, 1, true) ~= nil
end

local function updateCanvas()
	local v9 = math.max(scroll.AbsoluteWindowSize.X - 24, scroll.AbsoluteSize.X - 24, 1)
	local v10 = editor.Text == "" and " " or editor.Text or " "
	local v11 = math.max(
		math.ceil(TextService:GetTextSize(v10, editor.TextSize, editor.Font, Vector2.new(v9, 1e999)).Y) + 30,
		scroll.AbsoluteWindowSize.Y,
		scroll.AbsoluteSize.Y
	)
	editor.Size = UDim2.new(1, -16, 0, v11)
	practiceDisplay.Position = editor.Position
	practiceDisplay.Size = editor.Size
	practiceDisplay.Font = editor.Font
	practiceDisplay.TextSize = editor.TextSize
	scroll.CanvasSize = UDim2.fromOffset(0, v11 + 18)
end

local function updateResponsiveLayout()
	local v9 = math.max(parent.AbsoluteSize.X, parent.Size.X.Offset)
	local wraps

	if v9 > 0 then
		wraps = v9 < 560
	else
		wraps = false
	end

	local v10

	if v9 > 0 then
		v10 = v9 < 390
	else
		v10 = false
	end

	local v11 = wraps and 122 or 86
	toolbar.Size = UDim2.new(1, 0, 0, wraps and 70 or 34)
	scroll.Position = UDim2.new(0, 0, 0, v11)
	scroll.Size = UDim2.new(1, 0, 1, -v11)

	local uiListLayout = toolbar:FindFirstChildOfClass("UIListLayout")

	if uiListLayout then
		pcall(function()
			uiListLayout.Wraps = wraps
		end)
		uiListLayout.Padding = UDim.new(0, v10 and 4 or 6)
	end

	fontDropdown.Size = UDim2.fromOffset(wraps and 104 or 132, 30)
	practice.Size = UDim2.fromOffset(wraps and 88 or 100, 30)
	practice2D.Size = UDim2.fromOffset(wraps and 104 or 112, 30)

	if header then
		header.TextSize = wraps and 20 or 24
	end

	updateCanvas()
end

local function applyTheme()
	local v9 = v7[v2]
	parent.BackgroundColor3 = v9.root
	header.TextColor3 = v9.text
	scroll.BackgroundColor3 = v9.panel
	scroll.ScrollBarImageColor3 = v2 == "dark" and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(150, 150, 150)
	editor.TextColor3 = v9.text
	editor.PlaceholderColor3 = v9.placeholder
	practiceDisplay.TextColor3 = v9.text
	dropdownList.BackgroundColor3 = v9.dropdown
	dropdownList.ScrollBarImageColor3 = v2 == "dark" and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(150, 150, 150)

	for _, button in ipairs(dropdownList:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		button.BackgroundColor3 = v9.dropdown
		button.TextColor3 = v9.text
		local buttonLabel = getButtonLabel(button) -- inferred equivalent call

		if buttonLabel then
			buttonLabel.TextColor3 = v9.text
		end
	end

	for _, button in ipairs(toolbar:GetChildren()) do
		if not button:IsA("GuiButton") then
			continue
		end

		button.BackgroundColor3 = button == practice and flag and Color3.fromRGB(80, 150, 80) or v9.button
		local buttonLabel = getButtonLabel(button) -- inferred equivalent call

		if buttonLabel then
			buttonLabel.TextColor3 = v9.text
		end
	end

	if close:IsA("GuiButton") then
		close.BackgroundColor3 = v9.button
		local buttonLabel = getButtonLabel(close) -- inferred equivalent call

		if buttonLabel then
			buttonLabel.TextColor3 = v9.text
		end
	end

	if resizeKnob:IsA("GuiButton") then
		resizeKnob.BackgroundColor3 = v9.button
	end

	if themeToggle:IsA("ImageButton") then
		themeToggle.Image = v2 == "light" and "rbxassetid://128655635421195" or "rbxassetid://74288855801232"
		themeToggle.ImageColor3 = v9.text
	end

	sizeIndicator.BackgroundColor3 = v9.button
	sizeIndicator.TextColor3 = v9.text
	practiceTempoPrompt.BackgroundColor3 = v9.root

	for _, descendant in ipairs(practiceTempoPrompt:GetDescendants()) do
		if descendant:IsA("TextLabel") then
			descendant.TextColor3 = descendant.Name == "Subtitle" and v9.muted or v9.text
		elseif descendant:IsA("TextBox") then
			descendant.BackgroundColor3 = v9.panel
			descendant.TextColor3 = v9.text
			local uiStroke = descendant:FindFirstChildOfClass("UIStroke")

			if uiStroke then
				uiStroke.Color = v9.stroke
			end
		elseif descendant:IsA("TextButton") and descendant.Name ~= "Start" then
			descendant.BackgroundColor3 = v9.button
			descendant.TextColor3 = v9.text
		end
	end
end

local function setFontSize(p) -- 4 equivalent calls inferred from this helper
	local textSize = math.clamp(math.floor((tonumber(p) or 16) + 0.5), 8, 72)
	editor.TextSize = textSize
	practiceDisplay.TextSize = textSize
	sizeIndicator.Text = tostring(textSize)
	updateCanvas()
end

local function flashButton(instance, text, backgroundColor)
	local buttonLabel = getButtonLabel(instance) -- inferred equivalent call
	local text2

	if buttonLabel then
		text2 = getButtonLabel(instance).Text or instance.Text or "" -- inferred equivalent call
	else
		text2 = instance.Text or ""
	end

	local backgroundColor3 = instance.BackgroundColor3
	setButtonText(instance, text) -- inferred equivalent call

	if backgroundColor then
		instance.BackgroundColor3 = backgroundColor
	end

	task.delay(1.15, function()
		if instance and instance.Parent then
			setButtonText(instance, text2) -- inferred equivalent call
			instance.BackgroundColor3 = backgroundColor3
			applyTheme()
		end
	end)
end

local function parseSheet(text)
	local v9 = tostring(text or "")
	local v10 = 1
	local sheet = {}

	while v10 <= #v9 do
		local display = v9:sub(v10, v10)

		if v[display] then
			v10 += 1
		elseif display == "[" then
			local endPos = v9:find("]", v10 + 1, true)

			if endPos then
				local v11 = v9:sub(v10 + 1, endPos - 1)
				local set2 = {}
				local chars = {}
				local notes = {}

				for i = 1, #v11 do
					local v12 = v11:sub(i, i)

					if not isValidChar(v12) or set2[v12] then -- inferred equivalent call
						continue
					end

					set2[v12] = true
					table.insert(chars, v12)
					local v13

					if typeof(v12) == "string" and v12 ~= "" then
						v13 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(v12, 1, true)
							or nil
					end

					table.insert(notes, v13)
				end

				if #chars > 0 then
					table.insert(sheet, {
						chars = chars,
						notes = notes,
						display = "[" .. table.concat(chars, "") .. "]",
						startPos = v10,
						endPos = endPos
					})
				end

				v10 = endPos + 1
			else
				v10 += 1
			end
		else
			if isValidChar(display) then -- inferred equivalent call
				local v11

				if typeof(display) == "string" and display ~= "" then
					v11 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(display, 1, true)
						or nil
				end

				table.insert(sheet, {
					chars = { display },
					notes = { v11 },
					display = display,
					startPos = v10,
					endPos = v10
				})
			end

			v10 += 1
		end
	end

	return sheet
end

local function buildPracticeText()
	local text = tostring(editor.Text or "")
	local v9 = v3[v4]

	if not v9 then
		practiceDisplay.Text = "<font color=\"#888888\">" .. escapeRichText(text) .. "</font>"
		return
	end

	local v10 = text:sub(1, (math.max(v9.startPos - 1, 0)))
	local v11 = text:sub(v9.startPos, v9.endPos)
	local v12 = text:sub(v9.endPos + 1)
	practiceDisplay.Text = "<font color=\"#888888\">" .. escapeRichText(v10) .. "</font><font color=\"#FFA500\"><b>" .. escapeRichText(v11) .. "</b></font><font color=\"#FFFFFF\">" .. escapeRichText(v12) .. "</font>"
end

local function collectKeyButtons()
	local pianoUI = getPianoUI() -- inferred equivalent call
	local keyFrames = {}
	local pianoContainer = pianoUI and pianoUI:FindFirstChild("PianoContainer")
	local keyFrame = pianoContainer and pianoContainer:FindFirstChild("KeyFrame")
	local mobilePianoContainer = pianoUI and pianoUI:FindFirstChild("MobilePianoContainer")
	local keyFrame2 = mobilePianoContainer and mobilePianoContainer:FindFirstChild("KeyFrame")
	local keyFrame3 = keyFrame2 and keyFrame2:FindFirstChild("KeyFrame")

	if keyFrame then
		table.insert(keyFrames, keyFrame)
	end

	if keyFrame3 then
		table.insert(keyFrames, keyFrame3)
	elseif keyFrame2 then
		table.insert(keyFrames, keyFrame2)
	end

	local buttons = {}

	for _, folder in ipairs(keyFrames) do
		for _, button in ipairs(folder:GetDescendants()) do
			if button:IsA("GuiButton") and tonumber(button.Name) then
				table.insert(buttons, button)
			end
		end
	end

	return buttons
end

local color = Color3.fromRGB(255, 210, 48)
local color2 = Color3.fromRGB(24, 24, 24)

local function colorsClose(data, color3): boolean -- 2 equivalent calls inferred from this helper
	return math.abs(data.R - color3.R) <= 0.02
		and math.abs(data.G - color3.G) <= 0.02
		and math.abs(data.B - color3.B) <= 0.02
end

local function isGuideColored(guiObject)
	if not guiObject then
		return false
	end

	if guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
		return colorsClose(guiObject.ImageColor3, color) -- inferred equivalent call
	end

	if not guiObject:IsA("GuiObject") then
		return false
	end

	return colorsClose(guiObject.BackgroundColor3, color) -- inferred equivalent call
end

local function isBlackNote(name): boolean -- 1 equivalent call inferred from this helper
	local v9 = name % 12
	return v9 == 2 or v9 == 4 or v9 == 7 or v9 == 9 or v9 == 11
end

local function resetKeyToBaseVisual(guiObject)
	local name = tonumber(guiObject and guiObject.Name)

	if not (guiObject and name) then
		return
	end

	for _, uiGradient in ipairs(guiObject:GetChildren()) do
		if uiGradient:IsA("UIGradient") then
			uiGradient.Enabled = true
		end
	end

	local color3 = isBlackNote(name) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255) -- inferred equivalent call

	if guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
		guiObject.ImageColor3 = color3
	elseif guiObject:IsA("GuiObject") then
		guiObject.BackgroundColor3 = color3
	end
end

local function captureGuideOriginal(folder)
	if not folder or v6[folder] then
		return
	end

	local gradients = {}

	for _, uiGradient in ipairs(folder:GetChildren()) do
		if uiGradient:IsA("UIGradient") then
			table.insert(gradients, {
				Gradient = uiGradient,
				Enabled = uiGradient.Enabled,
				Color = uiGradient.Color,
				Transparency = uiGradient.Transparency
			})
		end
	end

	local textObjects = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
			continue
		end

		table.insert(textObjects, { Object = descendant, TextColor3 = descendant.TextColor3 })
	end

	if folder:IsA("TextButton") or folder:IsA("TextLabel") or folder:IsA("TextBox") then
		table.insert(textObjects, { Object = folder, TextColor3 = folder.TextColor3 })
	end

	local backgroundColor

	if folder:IsA("GuiObject") then
		backgroundColor = folder.BackgroundColor3 or nil
	end

	local imageColor

	if folder:IsA("ImageButton") or folder:IsA("ImageLabel") then
		imageColor = folder.ImageColor3 or nil
	end

	v6[folder] = {
		BackgroundColor3 = backgroundColor,
		ImageColor3 = imageColor,
		Gradients = gradients,
		TextObjects = textObjects
	}
end

local function syncGuideOriginalAttributes(folder)
	local v9 = folder and v6[folder]

	if not v9 then
		return
	end

	if v9.BackgroundColor3 then
		folder:SetAttribute("PracticeGuideBaseBackgroundColor", v9.BackgroundColor3)
	end

	if v9.ImageColor3 then
		folder:SetAttribute("PracticeGuideBaseImageColor", v9.ImageColor3)
	end

	for _, gradient in ipairs(v9.Gradients) do
		local gradient2 = gradient.Gradient

		if gradient2 and gradient2.Parent then
			gradient2:SetAttribute("PracticeGuideBaseGradientEnabled", gradient.Enabled)
		end
	end

	for _, textObject in ipairs(v9.TextObjects) do
		local object = textObject.Object

		if object and object.Parent then
			object:SetAttribute("PracticeGuideBaseTextColor", textObject.TextColor3)
		end
	end
end

local function clearGuideAttributes(folder)
	if not folder then
		return
	end

	folder:SetAttribute("PracticeGuideActive", nil)
	folder:SetAttribute("PracticeGuideTouched", nil)
	folder:SetAttribute("PracticeGuideBaseBackgroundColor", nil)
	folder:SetAttribute("PracticeGuideBaseImageColor", nil)

	for _, uiGradient in ipairs(folder:GetChildren()) do
		if uiGradient:IsA("UIGradient") then
			uiGradient:SetAttribute("PracticeGuideBaseGradientEnabled", nil)
		end
	end

	if folder:IsA("TextButton") or folder:IsA("TextLabel") or folder:IsA("TextBox") then
		folder:SetAttribute("PracticeGuideBaseTextColor", nil)
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("TextButton") or descendant:IsA("TextLabel") or descendant:IsA("TextBox")) then
			continue
		end

		descendant:SetAttribute("PracticeGuideBaseTextColor", nil)
	end
end

local function restoreGuideOriginal(guiObject)
	local v9 = guiObject and v6[guiObject]

	if v9 then
		if v9.BackgroundColor3 and guiObject:IsA("GuiObject") then
			guiObject.BackgroundColor3 = v9.BackgroundColor3
		end

		if v9.ImageColor3 and (guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel")) then
			guiObject.ImageColor3 = v9.ImageColor3
		end

		for _, gradient in ipairs(v9.Gradients) do
			local gradient2 = gradient.Gradient

			if not (gradient2 and gradient2.Parent) then
				continue
			end

			gradient2.Enabled = gradient.Enabled
			gradient2.Color = gradient.Color
			gradient2.Transparency = gradient.Transparency
		end

		for _, textObject in ipairs(v9.TextObjects) do
			local object = textObject.Object

			if object and object.Parent then
				object.TextColor3 = textObject.TextColor3
			end
		end

		v6[guiObject] = nil
	elseif guiObject and isGuideColored(guiObject) then
		resetKeyToBaseVisual(guiObject)
	end

	clearGuideAttributes(guiObject)
end

local function hideGuideOnKey(instance)
	local practiceGuideStroke = instance:FindFirstChild("PracticeGuideStroke")

	if practiceGuideStroke then
		practiceGuideStroke:Destroy()
	end

	local practiceGuideLabel = instance:FindFirstChild("PracticeGuideLabel")

	if practiceGuideLabel then
		practiceGuideLabel:Destroy()
	end

	instance:SetAttribute("PracticeGuideActive", false)

	if isGuideColored(instance) then
		restoreGuideOriginal(instance)
	end
end

local function clearStaleGuideColors(p)
	for _, v9 in ipairs(collectKeyButtons()) do
		local practiceGuideTouched = v9:GetAttribute("PracticeGuideTouched") == true
		local practiceGuideActive = v9:GetAttribute("PracticeGuideActive") == true
		local guideColored = isGuideColored(v9)
		local pianoGuiPressedActive = v9:GetAttribute("PianoGuiPressedActive") == true

		if p or practiceGuideTouched and not practiceGuideActive and guideColored then
			if guideColored then
				restoreGuideOriginal(v9)
			elseif pianoGuiPressedActive then
				v9:SetAttribute("PracticeGuideActive", false)
			elseif v6[v9] then
				restoreGuideOriginal(v9)
			else
				clearGuideAttributes(v9)
			end
		elseif practiceGuideTouched and not (practiceGuideActive or guideColored) then
			if pianoGuiPressedActive then
				v9:SetAttribute("PracticeGuideActive", false)
			elseif v6[v9] then
				restoreGuideOriginal(v9)
			else
				clearGuideAttributes(v9)
			end
		end
	end
end

local function cleanupGuideColorsFor(value) -- 1 equivalent call inferred from this helper
	local v9 = os.clock() + (value or 1.5)
	task.spawn(function()
		repeat
			clearStaleGuideColors(true)
			task.wait(0.08)
		until flag or v9 <= os.clock()
	end)
end

local function clearGuideHighlights()
	for k in pairs(folderSet) do
		if k and k.Parent then
			hideGuideOnKey(k)
		end
	end

	table.clear(folderSet)

	for _, v9 in ipairs(collectKeyButtons()) do
		hideGuideOnKey(v9)
	end
end

local function setGuideOnKey(folder, _)
	captureGuideOriginal(folder)
	syncGuideOriginalAttributes(folder)
	folder:SetAttribute("PracticeGuideTouched", true)
	folder:SetAttribute("PracticeGuideActive", true)

	for _, uiGradient in ipairs(folder:GetChildren()) do
		if uiGradient:IsA("UIGradient") then
			uiGradient.Enabled = false
		end
	end

	if folder:IsA("ImageButton") or folder:IsA("ImageLabel") then
		folder.ImageColor3 = color
	elseif folder:IsA("GuiObject") then
		folder.BackgroundColor3 = color
	end

	if folder:IsA("TextButton") or folder:IsA("TextLabel") or folder:IsA("TextBox") then
		folder.TextColor3 = color2
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
			continue
		end

		descendant.TextColor3 = color2
	end

	folderSet[folder] = true
end

local function getKeyLabelText(button)
	for _, childName in ipairs({ "Label", "QwertyNoteLabel" }) do
		local label = button:FindFirstChild(childName)

		if label and label:IsA("TextLabel") and label.Text ~= "" then
			return label.Text
		end
	end

	if button:IsA("TextButton") and button.Text ~= "" then
		return button.Text
	end

	return ""
end

local function updateGuideHighlights()
	clearGuideHighlights()
	local v9 = v3[v4]

	if not v9 then
		return
	end

	local v10 = collectKeyButtons()
	local v11 = false

	for i, note in ipairs(v9.notes) do
		local v12 = v9.chars[i] or v9.display

		for _, v13 in ipairs(v10) do
			if tonumber(v13.Name) ~= note then
				continue
			end

			setGuideOnKey(v13, v12)
			v11 = true
		end
	end

	if not v11 then
		for _, v12 in ipairs(v10) do
			local keyLabelText = getKeyLabelText(v12)

			for _, char in ipairs(v9.chars) do
				if keyLabelText == char then
					setGuideOnKey(v12, char)
				end
			end
		end
	end
end

local function nudgeScrollToCurrentToken()
	local v9 = v3[v4]

	if not v9 then
		return
	end

	local v10 = math.max(scroll.AbsoluteWindowSize.Y, scroll.AbsoluteSize.Y, 1)
	local v11 = math.max(0, scroll.CanvasSize.Y.Offset - v10)

	if v11 <= 0 then
		return
	end

	local v12 = tostring(editor.Text or ""):sub(1, (math.max(v9.startPos - 1, 0)))
	local v13 = math.max(scroll.AbsoluteWindowSize.X - 24, scroll.AbsoluteSize.X - 24, 1)
	local v14 = math.max(
		0,
		TextService:GetTextSize(
			(v12 == "" or not v12) and " " or v12,
			editor.TextSize,
			editor.Font,
			Vector2.new(v13, 1e999)
		).Y
	)
	local v15 = math.max(editor.TextSize + 8, 20)
	local y = scroll.CanvasPosition.Y
	local v16 = y + v10 * 0.18
	local v17 = y + v10 * 0.78
	local v18

	if v14 < v16 then
		v18 = math.max(0, v14 - v10 * 0.28)
	elseif v17 < v14 + v15 then
		v18 = v14 - v10 * 0.45
	else
		return
	end

	local v19 = math.clamp(v18, 0, v11)

	if math.abs(v19 - y) < 2 then
		return
	end

	TweenService:Create(scroll, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CanvasPosition = Vector2.new(0, v19)
	}):Play()
end

local function updatePracticeVisuals() -- 2 equivalent calls inferred from this helper
	buildPracticeText()
	updateGuideHighlights()
	nudgeScrollToCurrentToken()
end

local function stopPractice()
	if flag then
		flag = false
		table.clear(v3)
		table.clear(set)
		v4 = 1
		editor.TextTransparency = 0
		editor.Interactable = true
		editor.TextEditable = true
		practiceDisplay.Visible = false
	end

	clearGuideHighlights()
	clearStaleGuideColors(true)
	local v9 = os.clock() + 2.5
	task.spawn(function()
		repeat
			clearStaleGuideColors(true)
			task.wait(0.08)
		until flag or v9 <= os.clock()
	end)
	setButtonText(practice, "Practice") -- inferred equivalent call
	applyTheme()
end

local function finishPractice()
	setButtonText(practice, "Done") -- inferred equivalent call
	practice.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
	clearGuideHighlights()
	clearStaleGuideColors(true)
	cleanupGuideColorsFor(2.5) -- inferred equivalent call
	task.delay(0.9, function()
		if practice and practice.Parent then
			flag = true
			stopPractice()
		end
	end)
end

local function startPractice()
	local text = tostring(editor.Text or "")

	if text:gsub("%s+", "") == "" then
		flashButton(practice, "Paste Sheet", Color3.fromRGB(180, 70, 70))
		return
	end

	v3 = parseSheet(text)

	if #v3 == 0 then
		flashButton(practice, "No Notes", Color3.fromRGB(180, 70, 70))
		return
	end

	practiceTempoPrompt.Visible = false
	flag = true
	v4 = 1
	table.clear(set)
	editor.TextTransparency = 1
	editor.Interactable = false
	editor.TextEditable = false
	practiceDisplay.Visible = true
	setButtonText(practice, "Practice: ON") -- inferred equivalent call
	applyTheme()
	updatePracticeVisuals() -- inferred equivalent call
end

local function tokenMatchIndex(p, p2, p3)
	local v9 = tonumber(p3)

	for i, note in ipairs(p.notes) do
		if set[i] then
			continue
		end

		if v9 and note == v9 or p2 and p.chars[i] == p2 then
			return i
		end
	end

	return nil
end

local function tokenComplete(p): boolean -- 1 equivalent call inferred from this helper
	for i in ipairs(p.chars) do
		if not set[i] then
			return false
		end
	end

	return true
end

local function handlePracticeNote(p, p2)
	if not flag then
		return
	end

	local v9 = v3[v4]

	if not v9 then
		finishPractice()
		return
	end

	local v10 = tokenMatchIndex(v9, p, p2)

	if not v10 then
		return
	end

	set[v10] = true

	if not tokenComplete(v9) then -- inferred equivalent call
		updateGuideHighlights()

		return
	end

	v4 += 1
	table.clear(set)

	if v4 > #v3 then
		buildPracticeText()
		finishPractice()
	else
		updatePracticeVisuals() -- inferred equivalent call
	end
end

local function getPianoRoll2DHandler()
	local pianoUI = getPianoUI() -- inferred equivalent call
	local pianoMain = pianoUI and pianoUI:FindFirstChild("PianoMain")
	local pianoRoll2DHandler = pianoMain and pianoMain:FindFirstChild("PianoRoll2DHandler")

	if not pianoRoll2DHandler then
		return nil
	end

	local success, result = pcall(require, pianoRoll2DHandler)
	return if success then result else nil
end

local function getAutoPlayerTempo() -- 2 equivalent calls inferred from this helper
	local pianoUI = getPianoUI() -- inferred equivalent call
	local autoPlayer = pianoUI and pianoUI:FindFirstChild("AutoPlayer", true)
	local tempo = autoPlayer and autoPlayer:FindFirstChild("Tempo", true)
	return (math.clamp(tempo and tonumber(tempo.Text) or nil or 120, 20, 600))
end

local function parseTempo() -- 1 equivalent call inferred from this helper
	local v9 = tonumber(tempoBox.Text) or getAutoPlayerTempo() -- inferred equivalent call
	return (math.clamp(v9, 20, 600))
end

local function hidePracticePrompt() -- 3 equivalent calls inferred from this helper
	practiceTempoPrompt.Visible = false
end

local function showPracticePrompt()
	local text = tostring(editor.Text or "")

	if text:gsub("%s+", "") == "" then
		flashButton(practice2D, "Paste Sheet", Color3.fromRGB(180, 70, 70))
		return
	end

	stopPractice()
	v5 = text
	tempoBox.Text = tostring(getAutoPlayerTempo()) -- inferred equivalent call
	practiceTempoPrompt.Visible = true
	task.defer(function()
		if tempoBox and tempoBox.Parent then
			tempoBox:CaptureFocus()
		end
	end)
end

local function continuePractice2D()
	local pianoUI = getPianoUI() -- inferred equivalent call
	local pianoMain = pianoUI and pianoUI:FindFirstChild("PianoMain")
	local pianoRoll2DHandler = pianoMain and pianoMain:FindFirstChild("PianoRoll2DHandler")
	local result

	if pianoRoll2DHandler then
		local success
		success, result = pcall(require, pianoRoll2DHandler)

		if not success then
			result = nil
		end
	end

	if not result then
		flashButton(practice2D, "2D Missing", Color3.fromRGB(180, 70, 70))
		return
	end

	local v9 = v5 or tostring(editor.Text or "")

	if v9:gsub("%s+", "") == "" then
		flashButton(practice2D, "Paste Sheet", Color3.fromRGB(180, 70, 70))
		return
	end

	local tempo = parseTempo() -- inferred equivalent call

	if result.IsRunning and result.IsRunning("Sheets") and result.Stop then
		result.Stop(true)
	end

	if result.SetSheetSource then
		result.SetSheetSource("Sheet Practice", v9, tempo)
	end

	if result.ShowLoadedSourceModes then
		result.ShowLoadedSourceModes()
	end

	hidePracticePrompt() -- inferred equivalent call
end

local function setupFontMenu()
	dropdownList.Visible = false
	dropdownList.Position = UDim2.new(0, 0, 1, 6)
	dropdownList.Size = UDim2.fromOffset(190, 220)
	dropdownList.ZIndex = 6460
	dropdownList.ScrollBarThickness = 5
	dropdownList.ScrollingDirection = Enum.ScrollingDirection.Y
	dropdownList.CanvasSize = UDim2.fromOffset(0, #v8 * 32 + 8)
	dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.None

	for _, button in ipairs(dropdownList:GetChildren()) do
		if button:IsA("TextButton") then
			button:Destroy()
		end
	end

	local v9 = dropdownList:FindFirstChildOfClass("UIListLayout")

	if not v9 then
		v9 = Instance.new("UIListLayout")
		v9.Parent = dropdownList
	end

	v9.SortOrder = Enum.SortOrder.LayoutOrder
	v9.Padding = UDim.new(0, 4)

	local v10 = dropdownList:FindFirstChildOfClass("UIPadding")

	if not v10 then
		v10 = Instance.new("UIPadding")
		v10.Parent = dropdownList
	end

	v10.PaddingTop = UDim.new(0, 4)
	v10.PaddingBottom = UDim.new(0, 4)
	v10.PaddingLeft = UDim.new(0, 5)
	v10.PaddingRight = UDim.new(0, 5)

	local v11 = v7[v2]

	for i, v12 in ipairs(v8) do
		local textButton = Instance.new("TextButton")
		textButton.Name = "FontOption" .. i
		textButton.Size = UDim2.new(1, -10, 0, 28)
		textButton.BackgroundColor3 = v11.dropdown
		textButton.BorderSizePixel = 0
		textButton.AutoButtonColor = true
		textButton.Text = ""
		textButton.Font = v12.font
		textButton.TextColor3 = v11.text
		textButton.ZIndex = 6461
		textButton.LayoutOrder = i
		textButton.Parent = dropdownList

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 6)
		uiCorner.Parent = textButton

		local textLabel = Instance.new("TextLabel")
		textLabel.Name = "TextLabel"
		textLabel.BackgroundTransparency = 1
		textLabel.Position = UDim2.fromOffset(8, 0)
		textLabel.Size = UDim2.new(1, -16, 1, 0)
		textLabel.Font = v12.font
		textLabel.Text = v12.name
		textLabel.TextColor3 = v11.text
		textLabel.TextScaled = false
		textLabel.TextSize = 13
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.ZIndex = 6462
		textLabel.Parent = textButton

		textButton.MouseButton1Click:Connect(function()
			editor.Font = v12.font
			practiceDisplay.Font = v12.font
			setButtonText(fontDropdown, "Font: " .. v12.name) -- inferred equivalent call
			dropdownList.Visible = false
			updateCanvas()
		end)
	end
end

local function viewportSize()
	local currentCamera = workspace.CurrentCamera
	return currentCamera and currentCamera.ViewportSize or parent.AbsoluteSize
end

local uiDragDetectors = {}

for _, uiDragDetector in ipairs(parent:GetDescendants()) do
	if uiDragDetector:IsA("UIDragDetector") then
		table.insert(uiDragDetectors, uiDragDetector)
	end
end

local function setDragEnabled(enabled)
	for _, v9 in ipairs(uiDragDetectors) do
		pcall(function()
			v9.Enabled = enabled
		end)
	end
end

sizeMinus.MouseButton1Click:Connect(function()
	setFontSize(editor.TextSize - 2) -- inferred equivalent call
end)
sizePlus.MouseButton1Click:Connect(function()
	setFontSize(editor.TextSize + 2) -- inferred equivalent call
end)
sizeIndicator.FocusLost:Connect(function()
	setFontSize(sizeIndicator.Text) -- inferred equivalent call
end)
sizeIndicator:GetPropertyChangedSignal("Text"):Connect(function()
	local text = sizeIndicator.Text:gsub("[^%d]", "")

	if text ~= sizeIndicator.Text then
		sizeIndicator.Text = text
	end
end)

fontDropdown.MouseButton1Click:Connect(function()
	dropdownList.Visible = not dropdownList.Visible
end)
themeToggle.MouseButton1Click:Connect(function()
	v2 = v2 == "dark" and "light" or "dark"
	applyTheme()
end)
practice.MouseButton1Click:Connect(function()
	if flag then
		stopPractice()
	else
		startPractice()
	end
end)
practice2D.MouseButton1Click:Connect(showPracticePrompt)
close.MouseButton1Click:Connect(function()
	stopPractice()
	hidePracticePrompt() -- inferred equivalent call
	parent.Visible = false
end)
cancel.MouseButton1Click:Connect(hidePracticePrompt)
start.MouseButton1Click:Connect(continuePractice2D)
tempoBox.FocusLost:Connect(function(p)
	if p then
		continuePractice2D()
	end
end)

editor:GetPropertyChangedSignal("Text"):Connect(function()
	if not flag then
		updateCanvas()
	end
end)
editor:GetPropertyChangedSignal("TextSize"):Connect(updateCanvas)
editor:GetPropertyChangedSignal("Font"):Connect(updateCanvas)
scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateCanvas)
parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateResponsiveLayout)
parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if not parent.Visible then
		stopPractice()
		hidePracticePrompt() -- inferred equivalent call
	end
end)

local v9 = false
local position = nil
local absoluteSize = nil
local absolutePosition = nil
local v10 = nil

local function getResizeParentSize() -- 1 equivalent call inferred from this helper
	local parent2 = parent.Parent

	if parent2 and parent2:IsA("GuiObject") then
		return parent2.AbsoluteSize
	end

	local currentCamera = workspace.CurrentCamera
	return currentCamera and currentCamera.ViewportSize or Vector2.zero
end

local function getUDim2Pixels(position2, resizeParentSize) -- 1 equivalent call inferred from this helper
	return Vector2.new(
		position2.X.Scale * resizeParentSize.X + position2.X.Offset,
		position2.Y.Scale * resizeParentSize.Y + position2.Y.Offset
	)
end

resizeKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v9 = true
		position = input.Position
		absoluteSize = parent.AbsoluteSize
		absolutePosition = parent.AbsolutePosition
		local resizeParentSize = getResizeParentSize() -- inferred equivalent call
		v10 = parent.AbsolutePosition + parent.AbsoluteSize * parent.AnchorPoint - getUDim2Pixels(parent.Position, resizeParentSize) -- inferred equivalent call

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				v9 = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if
		not v9
		or input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch
	then
		return
	end

	if not (position and absoluteSize and absolutePosition and v10) then
		return
	end

	local v11 = input.Position - position
	local v12 = math.max(150, absoluteSize.X + v11.X)
	local v13 = math.max(100, absoluteSize.Y + v11.Y)

	local uiSizeConstraint = parent:FindFirstChildOfClass("UISizeConstraint")

	if uiSizeConstraint then
		if uiSizeConstraint.MaxSize.X > 0 then
			v12 = math.min(v12, uiSizeConstraint.MaxSize.X)
		end

		if uiSizeConstraint.MaxSize.Y > 0 then
			v13 = math.min(v13, uiSizeConstraint.MaxSize.Y)
		end

		if uiSizeConstraint.MinSize.X > 0 then
			v12 = math.max(v12, uiSizeConstraint.MinSize.X)
		end

		if uiSizeConstraint.MinSize.Y > 0 then
			v13 = math.max(v13, uiSizeConstraint.MinSize.Y)
		end
	end

	local vector2 = Vector2.new(v12, v13)
	local v14 = absolutePosition + vector2 * parent.AnchorPoint - v10

	parent.Size = UDim2.fromOffset(v12, v13)
	parent.Position = UDim2.fromOffset(v14.X, v14.Y)
end)
UserInputService.InputEnded:Connect(function(input)
	if
		input.UserInputType == Enum.UserInputType.Keyboard
		or input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	then
		task.delay(0.06, function()
			clearStaleGuideColors(not flag)
		end)
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not dropdownList.Visible then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local vector2 = Vector2.new(input.Position.X, input.Position.Y)
		local absolutePosition2 = dropdownList.AbsolutePosition
		local absoluteSize2 = dropdownList.AbsoluteSize
		local v11

		if
			vector2.X >= absolutePosition2.X
			and vector2.X <= absolutePosition2.X + absoluteSize2.X
			and vector2.Y >= absolutePosition2.Y
		then
			v11 = vector2.Y <= absolutePosition2.Y + absoluteSize2.Y
		else
			v11 = false
		end

		if not v11 then
			dropdownList.Visible = false
		end
	end
end)

if VPNotePlayed and VPNotePlayed:IsA("BindableEvent") then
	VPNotePlayed.Event:Connect(handlePracticeNote)
end

setButtonText(sizeMinus, "-") -- inferred equivalent call
setButtonText(sizePlus, "+") -- inferred equivalent call
setButtonText(practice, "Practice") -- inferred equivalent call
setButtonText(practice2D, "Practice 2D") -- inferred equivalent call
setButtonText(fontDropdown, "Font: Gotham") -- inferred equivalent call
setupFontMenu()
clearGuideHighlights()
setFontSize(16) -- inferred equivalent call
updateResponsiveLayout()
applyTheme()