local CommunitySheetsOverlayFactory = {}

local function configureTextObject(instance, p, value)
	if not (instance and (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox"))) then
		return
	end

	instance.TextWrapped = true
	instance.TextScaled = true
	local autoTextSizeConstraint = instance:FindFirstChild("AutoTextSizeConstraint")

	if not autoTextSizeConstraint then
		autoTextSizeConstraint = Instance.new("UITextSizeConstraint")
		autoTextSizeConstraint.Name = "AutoTextSizeConstraint"
		autoTextSizeConstraint.Parent = instance
	end

	autoTextSizeConstraint.MinTextSize = value or 8
	autoTextSizeConstraint.MaxTextSize = p or math.max(10, (math.floor(tonumber(instance.TextSize) or 14)))
end

local function ensureInstance(parent, className, name)
	local instance = parent:FindFirstChild(name)

	if instance and not instance:IsA(className) then
		instance:Destroy()
		instance = nil
	end

	if not instance then
		instance = Instance.new(className)
		instance.Name = name
		instance.Parent = parent
	end

	return instance
end

local function ensureCorner(parent, cornerRadius) -- 17 equivalent calls inferred from this helper
	local selected = parent:FindFirstChildOfClass("UICorner")

	if not selected then
		selected = Instance.new("UICorner")
		selected.Parent = parent
	end

	selected.CornerRadius = cornerRadius
	return selected
end

local function ensureStroke(instance, color, value, thickness) -- 7 equivalent calls inferred from this helper
	local v = instance:FindFirstChildOfClass("UIStroke")

	if not v then
		v = Instance.new("UIStroke")
		v.Parent = instance
	end

	v.Color = color
	v.Transparency = value or 0

	if thickness then
		v.Thickness = thickness
	end

	return v
end

local function styleOverlayButton(instance, zIndex)
	instance.Visible = false
	instance.Text = ""
	instance.AutoButtonColor = false
	instance.BorderSizePixel = 0
	instance.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	instance.BackgroundTransparency = 0.35
	instance.Size = UDim2.fromScale(1, 1)
	instance.Position = UDim2.fromScale(0, 0)
	instance.ZIndex = zIndex
end

local function makeLabel(instance, name, value, position, size, p, value2, color, zIndex)
	local instance2 = ensureInstance(instance, "TextLabel", name)
	instance2.BackgroundTransparency = 1
	instance2.Position = position
	instance2.Size = size
	instance2.Font = p or Enum.Font.Gotham
	instance2.TextSize = value2 or 13
	instance2.TextColor3 = color or Color3.fromRGB(188, 197, 211)
	instance2.TextXAlignment = Enum.TextXAlignment.Left
	instance2.TextYAlignment = Enum.TextYAlignment.Center
	instance2.Text = value or ""
	instance2.ZIndex = zIndex
	configureTextObject(instance2, value2 or 13, 8)
	return instance2
end

local function makeButton(instance, name, value, position, size, backgroundColor, zIndex)
	local instance2 = ensureInstance(instance, "TextButton", name)
	instance2.AutoButtonColor = true
	instance2.BorderSizePixel = 0
	instance2.Position = position
	instance2.Size = size
	instance2.Font = Enum.Font.GothamBold
	instance2.TextSize = 12
	instance2.TextColor3 = Color3.fromRGB(255, 255, 255)
	instance2.Text = value or ""
	instance2.BackgroundColor3 = backgroundColor
	instance2.ZIndex = zIndex
	configureTextObject(instance2, 12, 8)
	ensureCorner(instance2, UDim.new(0, 8)) -- inferred equivalent call
	return instance2
end

local function ensureModerationOverlay(parent)
	local instance = ensureInstance(parent, "TextButton", "ModerationOverlay")
	styleOverlayButton(instance, 9000)

	local instance2 = ensureInstance(instance, "Frame", "Panel")
	instance2.AnchorPoint = Vector2.new(0.5, 0.5)
	instance2.Position = UDim2.fromScale(0.5, 0.5)
	instance2.Size = UDim2.fromOffset(520, 360)
	instance2.BorderSizePixel = 0
	instance2.BackgroundColor3 = Color3.fromRGB(23, 27, 37)
	instance2.ZIndex = 9001
	ensureCorner(instance2, UDim.new(0, 12)) -- inferred equivalent call
	ensureStroke(instance2, Color3.fromRGB(72, 84, 105), 0.2) -- inferred equivalent call

	local label = makeLabel(
		instance2,
		"Title",
		"Moderate sheet",
		UDim2.fromOffset(24, 20),
		UDim2.new(1, -48, 0, 30),
		Enum.Font.GothamBold,
		20,
		Color3.fromRGB(255, 255, 255),
		9002
	)
	local label2 = makeLabel(
		instance2,
		"Message",
		"",
		UDim2.fromOffset(24, 58),
		UDim2.new(1, -48, 0, 124),
		Enum.Font.Gotham,
		13,
		Color3.fromRGB(188, 197, 211),
		9002
	)
	label2.TextYAlignment = Enum.TextYAlignment.Top

	local instance3 = ensureInstance(instance2, "TextBox", "ReasonBox")
	instance3.BackgroundColor3 = Color3.fromRGB(33, 38, 50)
	instance3.BorderSizePixel = 0
	instance3.Position = UDim2.fromOffset(24, 198)
	instance3.Size = UDim2.new(1, -48, 0, 42)
	instance3.Font = Enum.Font.Gotham
	instance3.TextSize = 13
	instance3.TextColor3 = Color3.fromRGB(235, 240, 250)
	instance3.PlaceholderText = "Reason for moderation"
	instance3.PlaceholderColor3 = Color3.fromRGB(128, 137, 154)
	instance3.ClearTextOnFocus = false
	instance3.Text = ""
	instance3.ZIndex = 9002
	configureTextObject(instance3, 13, 8)
	ensureCorner(instance3, UDim.new(0, 8)) -- inferred equivalent call

	return {
		Overlay = instance,
		Panel = instance2,
		Title = label,
		Message = label2,
		ReasonBox = instance3,
		HideButton = makeButton(
			instance2,
			"HideButton",
			"Hide",
			UDim2.new(0, 24, 1, -58),
			UDim2.new(0.2, -18, 0, 38),
			Color3.fromRGB(217, 145, 48),
			9002
		),
		ResolveButton = makeButton(
			instance2,
			"ResolveButton",
			"Clear Reports",
			UDim2.new(0.2, 14, 1, -58),
			UDim2.new(0.2, -18, 0, 38),
			Color3.fromRGB(48, 126, 217),
			9002
		),
		DeleteButton = makeButton(
			instance2,
			"DeleteButton",
			"Remove",
			UDim2.new(0.4, 4, 1, -58),
			UDim2.new(0.2, -18, 0, 38),
			Color3.fromRGB(212, 68, 84),
			9002
		),
		BlockButton = makeButton(
			instance2,
			"BlockButton",
			"Block",
			UDim2.new(0.6, -6, 1, -58),
			UDim2.new(0.2, -18, 0, 38),
			Color3.fromRGB(145, 84, 224),
			9002
		),
		CancelButton = makeButton(
			instance2,
			"CancelButton",
			"Cancel",
			UDim2.new(0.8, -16, 1, -58),
			UDim2.new(0.2, -18, 0, 38),
			Color3.fromRGB(54, 61, 76),
			9002
		)
	}
end

local function ensureMidiPublishOverlay(parent)
	local instance = ensureInstance(parent, "TextButton", "MidiPublishOverlay")
	styleOverlayButton(instance, 9100)

	local instance2 = ensureInstance(instance, "Frame", "Panel")
	instance2.AnchorPoint = Vector2.new(0.5, 0.5)
	instance2.Position = UDim2.fromScale(0.5, 0.5)
	instance2.Size = UDim2.fromOffset(544, 620)
	instance2.BorderSizePixel = 0
	instance2.BackgroundColor3 = Color3.fromRGB(27, 29, 37)
	instance2.ZIndex = 9101
	ensureCorner(instance2, UDim.new(0, 12)) -- inferred equivalent call
	ensureStroke(instance2, Color3.fromRGB(61, 70, 90), 0.35) -- inferred equivalent call

	local closeButton = instance2:FindFirstChild("CloseButton")

	if closeButton then
		closeButton:Destroy()
	end

	local formScroll = instance2:FindFirstChild("FormScroll")

	if formScroll then
		formScroll:Destroy()
	end

	makeLabel(
		instance2,
		"Title",
		"Publish MIDI",
		UDim2.fromOffset(24, 18),
		UDim2.new(1, -48, 0, 30),
		Enum.Font.GothamBold,
		21,
		Color3.fromRGB(245, 247, 252),
		9102
	)
	makeLabel(
		instance2,
		"Subtitle",
		"Share a MIDI file with the community using a direct download link.",
		UDim2.fromOffset(24, 50),
		UDim2.new(1, -48, 0, 42),
		Enum.Font.Gotham,
		13,
		Color3.fromRGB(150, 157, 174),
		9102
	)
	local label = makeLabel(
		instance2,
		"CostLabel",
		"Publishing costs 500 Notes. 0/5 daily uploads used.",
		UDim2.fromOffset(24, 92),
		UDim2.new(1, -48, 0, 22),
		Enum.Font.GothamBold,
		12,
		Color3.fromRGB(99, 184, 255),
		9102
	)
	makeLabel(
		instance2,
		"TitleLabel",
		"Song title",
		UDim2.fromOffset(24, 122),
		UDim2.fromOffset(120, 22),
		Enum.Font.GothamBold,
		12,
		Color3.fromRGB(216, 224, 238),
		9102
	)

	local instance3 = ensureInstance(instance2, "TextBox", "TitleBox")
	instance3.BackgroundColor3 = Color3.fromRGB(43, 48, 62)
	instance3.BorderSizePixel = 0
	instance3.Position = UDim2.fromOffset(24, 146)
	instance3.Size = UDim2.new(1, -48, 0, 42)
	instance3.Font = Enum.Font.Gotham
	instance3.TextSize = 13
	instance3.TextColor3 = Color3.fromRGB(235, 240, 250)
	instance3.PlaceholderText = "Song name"
	instance3.PlaceholderColor3 = Color3.fromRGB(128, 137, 154)
	instance3.ClearTextOnFocus = false
	instance3.Text = ""
	instance3.ZIndex = 9102
	configureTextObject(instance3, 13, 8)
	ensureCorner(instance3, UDim.new(0, 8)) -- inferred equivalent call

	makeLabel(
		instance2,
		"UrlLabel",
		"MIDI file link",
		UDim2.fromOffset(24, 198),
		UDim2.fromOffset(160, 22),
		Enum.Font.GothamBold,
		12,
		Color3.fromRGB(216, 224, 238),
		9102
	)
	local instance4 = ensureInstance(instance2, "TextBox", "UrlBox")
	instance4.BackgroundColor3 = instance3.BackgroundColor3
	instance4.BorderSizePixel = 0
	instance4.Position = UDim2.fromOffset(24, 222)
	instance4.Size = instance3.Size
	instance4.Font = instance3.Font
	instance4.TextSize = instance3.TextSize
	instance4.TextColor3 = instance3.TextColor3
	instance4.PlaceholderText = "https://example.com/song.mid"
	instance4.PlaceholderColor3 = instance3.PlaceholderColor3
	instance4.ClearTextOnFocus = false
	instance4.Text = ""
	instance4.ZIndex = 9102
	configureTextObject(instance4, 13, 8)
	ensureCorner(instance4, UDim.new(0, 8)) -- inferred equivalent call

	makeLabel(
		instance2,
		"ImageLabel",
		"MIDI card background (optional)",
		UDim2.fromOffset(24, 274),
		UDim2.new(1, -48, 0, 20),
		Enum.Font.GothamBold,
		12,
		Color3.fromRGB(216, 224, 238),
		9102
	)
	local instance5 = ensureInstance(instance2, "ImageLabel", "ImagePreview")
	instance5.BackgroundColor3 = Color3.fromRGB(43, 48, 62)
	instance5.BorderSizePixel = 0
	instance5.Position = UDim2.fromOffset(24, 298)
	instance5.Size = UDim2.new(1, -48, 0, 104)
	instance5.ScaleType = Enum.ScaleType.Crop
	instance5.Image = ""
	instance5.ZIndex = 9102
	ensureCorner(instance5, UDim.new(0, 8)) -- inferred equivalent call

	local instance6 = ensureInstance(instance2, "TextBox", "ImageIdBox")
	instance6.BackgroundColor3 = instance3.BackgroundColor3
	instance6.BorderSizePixel = 0
	instance6.Position = UDim2.new(0, 24, 0, 414)
	instance6.Size = UDim2.new(1, -176, 0, 40)
	instance6.Font = instance3.Font
	instance6.TextSize = instance3.TextSize
	instance6.TextColor3 = instance3.TextColor3
	instance6.PlaceholderText = "Asset ID"
	instance6.PlaceholderColor3 = instance3.PlaceholderColor3
	instance6.ClearTextOnFocus = false
	instance6.Text = ""
	instance6.ZIndex = 9102
	configureTextObject(instance6, 12, 8)
	ensureCorner(instance6, UDim.new(0, 8)) -- inferred equivalent call

	local button = makeButton(
		instance2,
		"BrowseImageButton",
		"Browse Image",
		UDim2.new(1, -140, 0, 414),
		UDim2.fromOffset(116, 40),
		Color3.fromRGB(30, 130, 200),
		9102
	)

	makeLabel(
		instance2,
		"DifficultyLabel",
		"Difficulty",
		UDim2.fromOffset(24, 468),
		UDim2.fromOffset(120, 20),
		Enum.Font.GothamBold,
		12,
		Color3.fromRGB(216, 224, 238),
		9102
	)
	local instance7 = ensureInstance(instance2, "Frame", "DifficultySelector")
	instance7.Position = UDim2.fromOffset(24, 492)
	instance7.Size = UDim2.new(1, -48, 0, 34)
	instance7.BackgroundColor3 = Color3.fromRGB(35, 41, 55)
	instance7.BorderSizePixel = 0
	instance7.ZIndex = 9102
	ensureCorner(instance7, UDim.new(0, 8)) -- inferred equivalent call
	local selectorStroke = ensureStroke(instance7, Color3.fromRGB(66, 72, 88), 0.55, 1) -- inferred equivalent call
	selectorStroke.Name = "SelectorStroke"
	selectorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local instance8 = ensureInstance(instance7, "Frame", "DifficultySelectionIndicator")
	instance8.Position = UDim2.new(0, 3, 0, 3)
	instance8.Size = UDim2.new(0.25, -6, 1, -6)
	instance8.BackgroundColor3 = Color3.fromRGB(20, 58, 48)
	instance8.BackgroundTransparency = 0.05
	instance8.BorderSizePixel = 0
	instance8.Active = false
	instance8.ZIndex = 9103
	ensureCorner(instance8, UDim.new(0, 7)) -- inferred equivalent call
	local selectionStroke = ensureStroke(instance8, Color3.fromRGB(52, 211, 153), 0.12, 1) -- inferred equivalent call
	selectionStroke.Name = "SelectionStroke"
	selectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	selectionStroke.LineJoinMode = Enum.LineJoinMode.Round

	local v = {
		{ Key = "Easy", Label = "Beginner" },
		{ Key = "Medium", Label = "Intermediate" },
		{ Key = "Hard", Label = "Advanced" },
		{ Key = "Expert", Label = "Expert" }
	}
	local instances = {}

	for i, v2 in ipairs(v) do
		local instance9 = ensureInstance(instance7, "TextButton", "Difficulty" .. v2.Key)
		instance9.AutoButtonColor = false
		instance9.BorderSizePixel = 0
		instance9.Position = UDim2.new((i - 1) / #v, 0, 0, 0)
		instance9.Size = UDim2.new(1 / #v, 0, 1, 0)
		instance9.Font = i == 1 and Enum.Font.GothamSemibold or Enum.Font.GothamMedium
		instance9.TextSize = 11
		instance9.TextColor3 = i == 1 and Color3.fromRGB(102, 255, 191) or Color3.fromRGB(190, 198, 214)
		instance9.Text = v2.Label
		instance9.BackgroundTransparency = 1
		instance9.ZIndex = 9104
		configureTextObject(instance9, 11, 8)
		instances[v2.Key] = instance9
	end

	return {
		Overlay = instance,
		Panel = instance2,
		TitleBox = instance3,
		UrlBox = instance4,
		ImageIdBox = instance6,
		ImagePreview = instance5,
		BrowseImageButton = button,
		Status = makeLabel(
			instance2,
			"Status",
			"",
			UDim2.fromOffset(24, 536),
			UDim2.new(1, -48, 0, 28),
			Enum.Font.Gotham,
			12,
			Color3.fromRGB(160, 168, 184),
			9102
		),
		CostLabel = label,
		SubmitButton = makeButton(
			instance2,
			"SubmitButton",
			"Publish",
			UDim2.new(1, -316, 1, -58),
			UDim2.fromOffset(138, 38),
			Color3.fromRGB(20, 160, 255),
			9102
		),
		CancelButton = makeButton(
			instance2,
			"CancelButton",
			"Cancel",
			UDim2.new(1, -162, 1, -58),
			UDim2.fromOffset(138, 38),
			Color3.fromRGB(54, 61, 76),
			9102
		),
		DifficultySelector = instance7,
		DifficultyIndicator = instance8,
		DifficultyButtons = instances
	}
end

function CommunitySheetsOverlayFactory.EnsureSupportCreatorOverlay(parent)
	local instance = ensureInstance(parent, "Frame", "SupportCreatorOverlay")
	instance.Size = UDim2.fromScale(1, 1)
	instance.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	instance.BackgroundTransparency = 0.35
	instance.BorderSizePixel = 0
	instance.Active = true
	instance.Visible = false
	instance.ZIndex = 9300

	local instance2 = ensureInstance(instance, "Frame", "Panel")
	instance2.AnchorPoint = Vector2.new(0.5, 0.5)
	instance2.Position = UDim2.fromScale(0.5, 0.5)
	instance2.Size = UDim2.fromOffset(430, 370)
	instance2.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
	instance2.BorderSizePixel = 0
	instance2.ZIndex = instance.ZIndex + 1
	ensureCorner(instance2, UDim.new(0, 14)) -- inferred equivalent call
	ensureStroke(instance2, Color3.fromRGB(72, 84, 105), 0.25) -- inferred equivalent call

	makeLabel(
		instance2,
		"Title",
		"Support Creator",
		UDim2.fromOffset(28, 22),
		UDim2.new(1, -92, 0, 32),
		Enum.Font.GothamBold,
		22,
		Color3.fromRGB(255, 255, 255),
		instance2.ZIndex + 1
	)
	makeLabel(
		instance2,
		"Subtitle",
		"Send Robux to this creator through Roblox transfer.",
		UDim2.fromOffset(28, 58),
		UDim2.new(1, -56, 0, 34),
		Enum.Font.Gotham,
		13,
		Color3.fromRGB(160, 168, 184),
		instance2.ZIndex + 1
	)
	makeLabel(
		instance2,
		"TargetLabel",
		"Supporting creator",
		UDim2.fromOffset(28, 106),
		UDim2.new(1, -56, 0, 46),
		Enum.Font.GothamSemibold,
		15,
		Color3.fromRGB(232, 238, 250),
		instance2.ZIndex + 1
	)
	makeLabel(
		instance2,
		"AmountLabel",
		"Robux amount",
		UDim2.fromOffset(28, 166),
		UDim2.new(1, -56, 0, 22),
		Enum.Font.GothamBold,
		12,
		Color3.fromRGB(216, 224, 238),
		instance2.ZIndex + 1
	)

	local instance3 = ensureInstance(instance2, "TextBox", "AmountBox")
	instance3.BackgroundColor3 = Color3.fromRGB(35, 41, 55)
	instance3.BorderSizePixel = 0
	instance3.Position = UDim2.fromOffset(28, 194)
	instance3.Size = UDim2.new(1, -56, 0, 48)
	instance3.Font = Enum.Font.GothamBold
	instance3.TextSize = 20
	instance3.TextColor3 = Color3.fromRGB(245, 248, 255)
	instance3.PlaceholderText = "Enter Robux amount"
	instance3.PlaceholderColor3 = Color3.fromRGB(132, 142, 164)
	instance3.ClearTextOnFocus = false
	instance3.Text = ""
	instance3.ZIndex = instance2.ZIndex + 1
	configureTextObject(instance3, 20, 10)
	ensureCorner(instance3, UDim.new(0, 9)) -- inferred equivalent call

	makeLabel(
		instance2,
		"Status",
		"Minimum amount is 10 Robux.",
		UDim2.fromOffset(28, 252),
		UDim2.new(1, -56, 0, 42),
		Enum.Font.Gotham,
		12,
		Color3.fromRGB(160, 168, 184),
		instance2.ZIndex + 1
	)
	local button = makeButton(
		instance2,
		"CancelButton",
		"Cancel",
		UDim2.new(1, -266, 1, -62),
		UDim2.fromOffset(110, 42),
		Color3.fromRGB(54, 61, 76),
		instance2.ZIndex + 1
	)
	local button2 = makeButton(
		instance2,
		"SubmitButton",
		"Send Robux",
		UDim2.new(1, -144, 1, -62),
		UDim2.fromOffset(116, 42),
		Color3.fromRGB(20, 160, 255),
		instance2.ZIndex + 1
	)
	local button3 = makeButton(
		instance2,
		"CloseButton",
		"x",
		UDim2.new(1, -58, 0, 18),
		UDim2.fromOffset(40, 40),
		Color3.fromRGB(43, 48, 62),
		instance2.ZIndex + 1
	)

	local success, result = pcall(function()
		return Font.new(
			"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json",
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		)
	end)

	if success then
		button3.FontFace = result
		button3.Font = Enum.Font.Unknown
	else
		button3.Font = Enum.Font.GothamBold
	end

	button3.TextSize = 20
	button3.TextScaled = false
	button3.TextWrapped = false
	button3.TextColor3 = Color3.fromRGB(210, 217, 230)
	ensureCorner(button3, UDim.new(1, 0)) -- inferred equivalent call

	button.Active = true
	button2.Active = true
	return instance
end

function CommunitySheetsOverlayFactory.EnsureMidiRepairOverlay(parent)
	local instance = ensureInstance(parent, "Frame", "MidiRepairOverlay")
	instance.Size = UDim2.fromScale(1, 1)
	instance.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	instance.BackgroundTransparency = 0.35
	instance.BorderSizePixel = 0
	instance.Active = true
	instance.Visible = false
	instance.ZIndex = 9350

	local instance2 = ensureInstance(instance, "Frame", "Panel")
	instance2.AnchorPoint = Vector2.new(0.5, 0.5)
	instance2.Position = UDim2.fromScale(0.5, 0.5)
	instance2.Size = UDim2.fromOffset(520, 430)
	instance2.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
	instance2.BorderSizePixel = 0
	instance2.ZIndex = instance.ZIndex + 1
	ensureCorner(instance2, UDim.new(0, 14)) -- inferred equivalent call
	ensureStroke(instance2, Color3.fromRGB(72, 84, 105), 0.22) -- inferred equivalent call

	makeLabel(
		instance2,
		"Title",
		"Repair MIDI Link",
		UDim2.fromOffset(28, 22),
		UDim2.new(1, -96, 0, 32),
		Enum.Font.GothamBold,
		22,
		Color3.fromRGB(255, 255, 255),
		instance2.ZIndex + 1
	)
	makeLabel(
		instance2,
		"Subtitle",
		"Update the original MIDI link without resetting likes, plays, or favorites.",
		UDim2.fromOffset(28, 58),
		UDim2.new(1, -56, 0, 42),
		Enum.Font.Gotham,
		13,
		Color3.fromRGB(160, 168, 184),
		instance2.ZIndex + 1
	)
	makeLabel(
		instance2,
		"TargetLabel",
		"Selected MIDI",
		UDim2.fromOffset(28, 110),
		UDim2.new(1, -56, 0, 30),
		Enum.Font.GothamSemibold,
		15,
		Color3.fromRGB(232, 238, 250),
		instance2.ZIndex + 1
	)

	local instance3 = ensureInstance(instance2, "Frame", "WarningPanel")
	instance3.Position = UDim2.fromOffset(28, 150)
	instance3.Size = UDim2.new(1, -56, 0, 58)
	instance3.BackgroundColor3 = Color3.fromRGB(50, 35, 28)
	instance3.BorderSizePixel = 0
	instance3.ZIndex = instance2.ZIndex + 1
	ensureCorner(instance3, UDim.new(0, 10)) -- inferred equivalent call
	ensureStroke(instance3, Color3.fromRGB(240, 117, 54), 0.25, 1) -- inferred equivalent call
	local label = makeLabel(
		instance3,
		"WarningText",
		"This upload needs a working direct MIDI link before players can load it again.",
		UDim2.fromOffset(14, 8),
		UDim2.new(1, -28, 1, -16),
		Enum.Font.GothamMedium,
		12,
		Color3.fromRGB(255, 198, 150),
		instance3.ZIndex + 1
	)
	label.TextYAlignment = Enum.TextYAlignment.Center

	makeLabel(
		instance2,
		"UrlLabel",
		"New direct MIDI link",
		UDim2.fromOffset(28, 222),
		UDim2.new(1, -56, 0, 22),
		Enum.Font.GothamBold,
		12,
		Color3.fromRGB(216, 224, 238),
		instance2.ZIndex + 1
	)
	local instance4 = ensureInstance(instance2, "TextBox", "UrlBox")
	instance4.BackgroundColor3 = Color3.fromRGB(35, 41, 55)
	instance4.BorderSizePixel = 0
	instance4.Position = UDim2.fromOffset(28, 250)
	instance4.Size = UDim2.new(1, -56, 0, 48)
	instance4.Font = Enum.Font.GothamMedium
	instance4.TextSize = 14
	instance4.TextColor3 = Color3.fromRGB(245, 248, 255)
	instance4.PlaceholderText = "https://example.com/song.mid"
	instance4.PlaceholderColor3 = Color3.fromRGB(132, 142, 164)
	instance4.ClearTextOnFocus = false
	instance4.Text = ""
	instance4.ZIndex = instance2.ZIndex + 1
	configureTextObject(instance4, 14, 8)
	ensureCorner(instance4, UDim.new(0, 9)) -- inferred equivalent call

	makeLabel(
		instance2,
		"Status",
		"The server will validate the MIDI before saving the new link.",
		UDim2.fromOffset(28, 310),
		UDim2.new(1, -56, 0, 46),
		Enum.Font.Gotham,
		12,
		Color3.fromRGB(160, 168, 184),
		instance2.ZIndex + 1
	)
	local button = makeButton(
		instance2,
		"CancelButton",
		"Cancel",
		UDim2.new(1, -266, 1, -62),
		UDim2.fromOffset(110, 42),
		Color3.fromRGB(54, 61, 76),
		instance2.ZIndex + 1
	)
	local button2 = makeButton(
		instance2,
		"SubmitButton",
		"Update Link",
		UDim2.new(1, -144, 1, -62),
		UDim2.fromOffset(116, 42),
		Color3.fromRGB(20, 160, 255),
		instance2.ZIndex + 1
	)
	local button3 = makeButton(
		instance2,
		"CloseButton",
		"x",
		UDim2.new(1, -58, 0, 18),
		UDim2.fromOffset(40, 40),
		Color3.fromRGB(43, 48, 62),
		instance2.ZIndex + 1
	)

	local success, result = pcall(function()
		return Font.new(
			"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json",
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		)
	end)

	if success then
		button3.FontFace = result
		button3.Font = Enum.Font.Unknown
	else
		button3.Font = Enum.Font.GothamBold
	end

	button3.TextSize = 20
	button3.TextScaled = false
	button3.TextWrapped = false
	button3.TextColor3 = Color3.fromRGB(210, 217, 230)
	ensureCorner(button3, UDim.new(1, 0)) -- inferred equivalent call

	return {
		Overlay = instance,
		Panel = instance2,
		TargetLabel = instance2:FindFirstChild("TargetLabel"),
		WarningPanel = instance3,
		WarningText = label,
		UrlBox = instance4,
		Status = instance2:FindFirstChild("Status"),
		SubmitButton = button2,
		CancelButton = button,
		CloseButton = button3
	}
end

function CommunitySheetsOverlayFactory.Build(parent)
	local moderationOverlay = ensureModerationOverlay(parent)
	local midiPublishOverlay = ensureMidiPublishOverlay(parent)
	local midiRepairOverlay = CommunitySheetsOverlayFactory.EnsureMidiRepairOverlay(parent)

	return {
		ModerationOverlay = moderationOverlay.Overlay,
		ModerationPanel = moderationOverlay.Panel,
		ModerationTitle = moderationOverlay.Title,
		ModerationMessage = moderationOverlay.Message,
		ModerationReasonBox = moderationOverlay.ReasonBox,
		ModerationHideButton = moderationOverlay.HideButton,
		ModerationResolveButton = moderationOverlay.ResolveButton,
		ModerationDeleteButton = moderationOverlay.DeleteButton,
		ModerationBlockButton = moderationOverlay.BlockButton,
		ModerationCancelButton = moderationOverlay.CancelButton,
		MidiPublishOverlay = midiPublishOverlay.Overlay,
		MidiPublishPanel = midiPublishOverlay.Panel,
		MidiPublishTitleBox = midiPublishOverlay.TitleBox,
		MidiPublishUrlBox = midiPublishOverlay.UrlBox,
		MidiPublishImageIdBox = midiPublishOverlay.ImageIdBox,
		MidiPublishImagePreview = midiPublishOverlay.ImagePreview,
		MidiPublishBrowseImageButton = midiPublishOverlay.BrowseImageButton,
		MidiPublishStatus = midiPublishOverlay.Status,
		MidiPublishCostLabel = midiPublishOverlay.CostLabel,
		MidiPublishSubmitButton = midiPublishOverlay.SubmitButton,
		MidiPublishCancelButton = midiPublishOverlay.CancelButton,
		MidiPublishDifficultySelector = midiPublishOverlay.DifficultySelector,
		MidiPublishDifficultyIndicator = midiPublishOverlay.DifficultyIndicator,
		MidiPublishDifficultyButtons = midiPublishOverlay.DifficultyButtons,
		MidiRepairOverlay = midiRepairOverlay.Overlay,
		MidiRepairPanel = midiRepairOverlay.Panel,
		MidiRepairTargetLabel = midiRepairOverlay.TargetLabel,
		MidiRepairWarningPanel = midiRepairOverlay.WarningPanel,
		MidiRepairWarningText = midiRepairOverlay.WarningText,
		MidiRepairUrlBox = midiRepairOverlay.UrlBox,
		MidiRepairStatus = midiRepairOverlay.Status,
		MidiRepairSubmitButton = midiRepairOverlay.SubmitButton,
		MidiRepairCancelButton = midiRepairOverlay.CancelButton,
		MidiRepairCloseButton = midiRepairOverlay.CloseButton
	}
end

return CommunitySheetsOverlayFactory