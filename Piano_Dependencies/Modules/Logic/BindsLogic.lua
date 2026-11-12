local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local color = Color3.fromRGB(0, 170, 255)

local set = {}
local BindsLogic = {}

for i = 1, 61 do
	set[("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(i, i)] = true
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local getPianoUserSettings = remotes:WaitForChild("GetPianoUserSettings")
local savePianoUserSettings = remotes:WaitForChild("SavePianoUserSettings")

local function setCaptureActive(flag: boolean) -- 2 equivalent calls inferred from this helper
	pcall(function()
		ReplicatedStorage2:SetAttribute("BindsCaptureActive", flag and true or false)
	end)
end

local count = 0
local count2 = 0
local flag = false
local function scheduleKeybindSave(object) -- 3 equivalent calls inferred from this helper
	if not (object and object.GetSerializedKeyBinds) then
		return
	end

	count2 += 1
	count += 1
	local v = count
	task.delay(0.6, function()
		if v ~= count then
			return
		end

		savePianoUserSettings:FireServer({ NoteKeyBinds = object:GetSerializedKeyBinds() })
	end)
end

local v = {
	["!"] = true,
	["@"] = true,
	["$"] = true,
	["%"] = true,
	["^"] = true,
	["*"] = true,
	["("] = true
}
local function isBlackGlyph(value: string?) -- 1 equivalent call inferred from this helper
	return value and (value:match("%u") ~= nil or v[value] == true)
end

local _ = {
	["1"] = "!",
	["2"] = "@",
	["4"] = "$",
	["5"] = "%",
	["6"] = "^",
	["8"] = "*",
	["9"] = "("
}

local function keyToGlyph(input)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return nil
	end

	local keyCode = input.KeyCode
	local v2 = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)

	if keyCode.Name:match("^[A-Z]$") then
		local name = keyCode.Name:lower()

		if v2 then
			name = name:upper()
		end

		return set[name] and name or nil
	else
		local v3 = {
			[Enum.KeyCode.Zero] = "0",
			[Enum.KeyCode.One] = "1",
			[Enum.KeyCode.Two] = "2",
			[Enum.KeyCode.Three] = "3",
			[Enum.KeyCode.Four] = "4",
			[Enum.KeyCode.Five] = "5",
			[Enum.KeyCode.Six] = "6",
			[Enum.KeyCode.Seven] = "7",
			[Enum.KeyCode.Eight] = "8",
			[Enum.KeyCode.Nine] = "9"
		}

		local v4 = {
			[Enum.KeyCode.One] = "!",
			[Enum.KeyCode.Two] = "@",
			[Enum.KeyCode.Four] = "$",
			[Enum.KeyCode.Five] = "%",
			[Enum.KeyCode.Six] = "^",
			[Enum.KeyCode.Eight] = "*",
			[Enum.KeyCode.Nine] = "("
		}

		local v5 = v2 and v4[keyCode] or v3[keyCode]
		return if v5 and set[v5] and v5 then v5 else nil
	end
end

local v2 = {
	Major = {},
	Minor = {
		["3"] = "@",
		["6"] = "%",
		["7"] = "^",
		["0"] = "(",
		e = "W",
		r = "E",
		u = "Y",
		p = "O",
		a = "P",
		f = "D",
		j = "H",
		k = "J",
		x = "Z",
		b = "V",
		n = "B"
	},
	["Phrygian Dominant"] = {
		["2"] = "!",
		["6"] = "%",
		["7"] = "^",
		["9"] = "*",
		e = "W",
		r = "E",
		y = "T",
		p = "O",
		a = "P",
		d = "S",
		j = "H",
		k = "J",
		z = "L",
		b = "V",
		n = "B"
	}
}

local v3 = { ["Phrygian Dominant"] = true }

local v4 = {}
local function addConn(p) -- 6 equivalent calls inferred from this helper
	table.insert(v4, p)
	return p
end
local function disconnectAll()
	for i = #v4, 1, -1 do
		local connection = v4[i]

		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end

		v4[i] = nil
	end
end

local guiObjectsByName = {}
local v5 = {}
local defaultGlyphForNotes = {}
local v6 = {}
local v7 = {}

local function getDefaultGlyphForNote(p: number) -- 6 equivalent calls inferred from this helper
	return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(p, p)
end

local function rebuildReverseIndex()
	v6 = {}
	v7 = {}

	for k, v8 in pairs(defaultGlyphForNotes) do
		local v9 = string.lower(v8)
		v6[v9] = v6[v9] or {}
		table.insert(v6[v9], k)

		v7[v8] = v7[v8] or {}
		table.insert(v7[v8], k)
	end
end

local v8 = nil
local v9 = nil
local backgroundColor = nil
local backgroundTransparency2 = nil
local v10 = nil
local function clearPreviewHighlight() -- 6 equivalent calls inferred from this helper
	if v9 then
		if backgroundColor then
			v9.BackgroundColor3 = backgroundColor
		end

		if backgroundTransparency2 ~= nil then
			v9.BackgroundTransparency = backgroundTransparency2
		end
	end

	if v10 then
		v10.Enabled = true
		v10 = nil
	end

	v8 = nil
	v9 = nil
	backgroundColor = nil
	backgroundTransparency2 = nil
end
local function highlightPreview(p) -- 1 equivalent call inferred from this helper
	clearPreviewHighlight() -- inferred equivalent call
	local v11 = guiObjectsByName[p]

	if not v11 then
		ClientDebugConfig.Warn("[BindsLogic] No preview frame found for note", p)
		return
	end

	v8 = p
	v9 = v11
	local backgroundColor3 = v11.BackgroundColor3
	local backgroundTransparency = v11.BackgroundTransparency
	backgroundColor = backgroundColor3
	backgroundTransparency2 = backgroundTransparency

	local uiGradient = v11:FindFirstChildOfClass("UIGradient")

	if uiGradient then
		uiGradient.Enabled = false
		v10 = uiGradient
	end

	v11.BackgroundColor3 = color
	v11.BackgroundTransparency = 0
end

local flag2 = false
local inputBeganConnection = nil
local uiStroke = nil
local flag3 = false

local function startBlocker()
	if flag3 then
		return
	end

	flag3 = true
	ContextActionService:BindActionAtPriority("BindsCaptureBlock", function()
		return Enum.ContextActionResult.Sink
	end, false, 3000, Enum.KeyCode.Zero, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine, Enum.KeyCode.A, Enum.KeyCode.B, Enum.KeyCode.C, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.H, Enum.KeyCode.I, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.M, Enum.KeyCode.N, Enum.KeyCode.O, Enum.KeyCode.P, Enum.KeyCode.Q, Enum.KeyCode.R, Enum.KeyCode.S, Enum.KeyCode.T, Enum.KeyCode.U, Enum.KeyCode.V, Enum.KeyCode.W, Enum.KeyCode.X, Enum.KeyCode.Y, Enum.KeyCode.Z)
end
local function stopBlocker()
	if flag3 then
		flag3 = false
		pcall(function()
			ContextActionService:UnbindAction("BindsCaptureBlock")
		end)
	end
end

local function endCapture()
	setCaptureActive(false) -- inferred equivalent call
	flag2 = false

	if flag3 then
		flag3 = false
		pcall(function()
			ContextActionService:UnbindAction("BindsCaptureBlock")
		end)
	end

	if inputBeganConnection then
		pcall(function()
			inputBeganConnection:Disconnect()
		end)
		inputBeganConnection = nil
	end

	if uiStroke then
		pcall(function()
			uiStroke:Destroy()
		end)
		uiStroke = nil
	end
end

local function setBothRowTexts(p, text) -- 5 equivalent calls inferred from this helper
	local v11 = v5[p]

	if not v11 then
		return
	end

	if v11.lower and v11.lower:IsA("TextButton") then
		v11.lower.Text = text
	end

	if v11.upper and v11.upper:IsA("TextButton") then
		v11.upper.Text = text
	end
end

local function mapCharToIndex(p) -- 2 equivalent calls inferred from this helper
	return ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):find(p, 1, true) or 0
end

local function applyForNote(k, text, object, p) -- 1 equivalent call inferred from this helper
	setBothRowTexts(k, text) -- inferred equivalent call

	if object and object.SetKeyBind then
		local v11 = mapCharToIndex(text) -- inferred equivalent call

		if v11 == 0 then
			v11 = k
		end

		object:SetKeyBind(k, v11)

		if not p and object then
			if not object.GetSerializedKeyBinds then
				return
			end

			count2 += 1
			count += 1
			local v12 = count
			task.delay(0.6, function()
				if v12 ~= count then
					return
				end

				savePianoUserSettings:FireServer({ NoteKeyBinds = object:GetSerializedKeyBinds() })
			end)
		end
	end
end

local function refreshButtonTextsFromKeymap(object)
	if not (object and object.GetMappedNote) then
		return
	end

	for k, _ in pairs(v5) do
		local mappedNote = object:GetMappedNote(k)
		local v11 = defaultGlyphForNotes[k] or getDefaultGlyphForNote(k) -- inferred equivalent call

		if mappedNote ~= k then
			v11 = ("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(mappedNote, mappedNote)
		end

		setBothRowTexts(k, v11) -- inferred equivalent call
	end
end

local function isPreviewBlackKey(guiObject) -- 1 equivalent call inferred from this helper
	return guiObject:IsA("GuiObject") and (guiObject.Position.Y.Scale < 0.25 or guiObject.Size.Y.Scale < 0.75)
end

local function setGuiTreeZ(guiObject, zIndex)
	if guiObject:IsA("GuiObject") then
		guiObject.ZIndex = zIndex
	end

	for _, guiObject2 in ipairs(guiObject:GetDescendants()) do
		if guiObject2:IsA("GuiObject") then
			guiObject2.ZIndex = zIndex
		end
	end
end

local function normalizeNotebindsLayering(guiObject, guiObject2, keyboardFrame, buttonFrame)
	local v11 = guiObject:IsA("GuiObject") and math.max(guiObject.ZIndex, 1) or 1

	if guiObject2:IsA("GuiObject") then
		guiObject2.ZIndex = v11 + 1
	end

	for _, guiObject3 in ipairs(guiObject2:GetChildren()) do
		if not guiObject3:IsA("GuiObject") then
			continue
		end

		local previewBlackKey = isPreviewBlackKey(guiObject3) -- inferred equivalent call
		guiObject3.ZIndex = previewBlackKey and v11 + 4 or v11 + 2

		local noteLabel = guiObject3:FindFirstChild("NoteLabel")

		if noteLabel and noteLabel:IsA("GuiObject") then
			noteLabel.ZIndex = previewBlackKey and v11 + 5 or v11 + 3
		end
	end

	setGuiTreeZ(keyboardFrame, v11 + 6)
	setGuiTreeZ(buttonFrame, v11 + 8)
end

function BindsLogic.Initialize(instance, object)
	if not instance then
		return
	end

	local keyFrame = instance:FindFirstChild("KeyFrame")
	local keyboardFrame = instance:FindFirstChild("KeyboardFrame")
	local buttonFrame = instance:FindFirstChild("ButtonFrame")

	if not (keyFrame and keyboardFrame and buttonFrame) then
		ClientDebugConfig.Warn("[BindsLogic] Missing KeyFrame/KeyboardFrame/ButtonFrame")
		return
	end

	normalizeNotebindsLayering(instance, keyFrame, keyboardFrame, buttonFrame)

	local lowercase = keyboardFrame:FindFirstChild("Lowercase")
	local uppercase = keyboardFrame:FindFirstChild("Uppercase")

	local buttons = {}

	for _, button in ipairs(keyboardFrame:GetDescendants()) do
		if button:IsA("GuiButton") and button.Name == "Shift" then
			table.insert(buttons, button)
		end
	end

	local major = buttonFrame:FindFirstChild("Major")
	local minor = buttonFrame:FindFirstChild("Minor")
	local phrygianDominant = buttonFrame:FindFirstChild("PhrygianDominant")
	local reset = buttonFrame:FindFirstChild("Reset")

	guiObjectsByName = {}

	for _, guiObject in ipairs(keyFrame:GetChildren()) do
		if not (guiObject:IsA("Frame") or guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
			continue
		end

		local name = tonumber(guiObject.Name)

		if name then
			guiObjectsByName[name] = guiObject
		end
	end

	local count3 = 0

	for _ in pairs(guiObjectsByName) do
		count3 += 1
	end

	ClientDebugConfig.Print("[BindsLogic] Found", count3, "preview frames in KeyFrame")

	v5 = {}
	defaultGlyphForNotes = {}
	local function recordBtn(button) -- 2 equivalent calls inferred from this helper
		if not button:IsA("GuiButton") then
			return
		end

		local name = tonumber(button.Name)

		if not name then
			return
		end

		v5[name] = v5[name] or {}
		return name
	end

	if lowercase then
		for _, descendant in ipairs(lowercase:GetDescendants()) do
			local name = recordBtn(descendant) -- inferred equivalent call

			if name then
				v5[name].lower = descendant
			end
		end
	end

	if uppercase then
		for _, descendant in ipairs(uppercase:GetDescendants()) do
			local name = recordBtn(descendant) -- inferred equivalent call

			if name then
				v5[name].upper = descendant
			end
		end
	end

	for k, v11 in pairs(v5) do
		local defaultGlyphForNote = getDefaultGlyphForNote(k) -- inferred equivalent call
		defaultGlyphForNotes[k] = defaultGlyphForNote

		if v11.lower and v11.lower:IsA("TextButton") then
			v11.lower.Text = defaultGlyphForNote
		end

		if v11.upper and v11.upper:IsA("TextButton") then
			v11.upper.Text = defaultGlyphForNote
		end
	end

	rebuildReverseIndex()

	local function styleUppercaseRow()
		if not uppercase then
			return
		end

		for k, v11 in pairs(v5) do
			local upper = v11.upper

			if not (upper and upper:IsA("TextButton")) then
				continue
			end

			local blackGlyph = isBlackGlyph(defaultGlyphForNotes[k] or getDefaultGlyphForNote(k)) -- inferred equivalent call

			upper.AutoButtonColor = false
			upper.Active = blackGlyph
			upper.Selectable = blackGlyph
			upper.TextTransparency = blackGlyph and 0 or 0.65
		end
	end
	styleUppercaseRow()

	if object and object.ApplySerializedKeyBinds then
		if flag then
			refreshButtonTextsFromKeymap(object)
		else
			flag = true
			local v11 = count2
			task.spawn(function()
				local success, result = pcall(function()
					return getPianoUserSettings:InvokeServer()
				end)

				if success and typeof(result) == "table" and v11 == count2 then
					object:ApplySerializedKeyBinds(result.NoteKeyBinds)
					refreshButtonTextsFromKeymap(object)
					ClientDebugConfig.Print("[BindsLogic] Loaded saved note keybinds")
				end
			end)
		end
	end

	local function wireBtn(guiObject, k: number, flag4: boolean) -- 2 equivalent calls inferred from this helper
		addConn(guiObject.Activated:Connect(function() -- inferred equivalent call
			if flag4 then
				local v11 = defaultGlyphForNotes[k] or getDefaultGlyphForNote(k) -- inferred equivalent call

				if not v11 or v11:match("%u") == nil and v[v11] ~= true then
					return
				end
			end

			highlightPreview(k) -- inferred equivalent call
			endCapture()

			if guiObject:IsA("GuiObject") then
				uiStroke = Instance.new("UIStroke")
				uiStroke.Thickness = 2
				uiStroke.Color = color
				uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				uiStroke.Parent = guiObject
			end

			flag2 = true
			startBlocker()
			setCaptureActive(true) -- inferred equivalent call
			local _visible = uppercase and uppercase.Visible

			inputBeganConnection = UserInputService.InputBegan:Connect(function(input, _)
				if input.KeyCode == Enum.KeyCode.Escape then
					endCapture()
					clearPreviewHighlight() -- inferred equivalent call
				else
					if input.UserInputType ~= Enum.UserInputType.Keyboard then
						return
					end

					local text = keyToGlyph(input)

					if not (text and set[text]) then
						return
					end

					local v11 = k
					local v12 = object
					setBothRowTexts(v11, text) -- inferred equivalent call

					if v12 and v12.SetKeyBind then
						local v13 = mapCharToIndex(text) -- inferred equivalent call

						if v13 == 0 then
							v13 = v11
						end

						v12:SetKeyBind(v11, v13)
						scheduleKeybindSave(v12) -- inferred equivalent call
					end

					endCapture()
					clearPreviewHighlight() -- inferred equivalent call
				end
			end)
		end))
	end

	for k, v11 in pairs(v5) do
		if v11.lower then
			wireBtn(v11.lower, k, false) -- inferred equivalent call
		end

		if v11.upper then
			wireBtn(v11.upper, k, true) -- inferred equivalent call
		end
	end

	local function applyPresetSimple(p: string)
		if object and object.ResetAllKeyBinds then
			object:ResetAllKeyBinds()
			scheduleKeybindSave(object) -- inferred equivalent call
		end

		for k, _ in pairs(v5) do
			setBothRowTexts(k, defaultGlyphForNotes[k] or getDefaultGlyphForNote(k)) -- inferred equivalent call
		end

		local v11 = v2[p] or {}
		local v12 = v3[p] and v7 or v6

		for k, v13 in pairs(v11) do
			local v14 = v12[k]

			if not v14 then
				continue
			end

			for _, v15 in ipairs(v14) do
				local v16 = v5[v15]

				if not v16 then
					continue
				end

				local text

				if v16.lower and v16.lower:IsA("TextButton") then
					text = v16.lower.Text
				end

				if (not text or text == "") and v16.upper and v16.upper:IsA("TextButton") then
					text = v16.upper.Text
				end

				if text == defaultGlyphForNotes[v15] then
					setBothRowTexts(v15, v13) -- inferred equivalent call
				end
			end
		end

		for k, v13 in pairs(v5) do
			local v14

			if v13.lower and v13.lower:IsA("TextButton") and v13.lower.Text ~= "" then
				v14 = v13.lower.Text
			elseif v13.upper and v13.upper:IsA("TextButton") and v13.upper.Text ~= "" then
				v14 = v13.upper.Text
			else
				v14 = defaultGlyphForNotes[k] or getDefaultGlyphForNote(k) -- inferred equivalent call
			end

			applyForNote(k, v14, object, true) -- inferred equivalent call
		end

		scheduleKeybindSave(object) -- inferred equivalent call
		endCapture()
		clearPreviewHighlight() -- inferred equivalent call
	end
	BindsLogic._applyPresetSimple = applyPresetSimple

	if major then
		addConn(major.MouseButton1Click:Connect(function() -- inferred equivalent call
			applyPresetSimple("Major")
		end))
	end

	if minor then
		addConn(minor.MouseButton1Click:Connect(function() -- inferred equivalent call
			applyPresetSimple("Minor")
		end))
	end

	if phrygianDominant then
		addConn(phrygianDominant.MouseButton1Click:Connect(function() -- inferred equivalent call
			applyPresetSimple("Phrygian Dominant")
		end))
	end

	if reset then
		addConn(reset.MouseButton1Click:Connect(function() -- inferred equivalent call
			applyPresetSimple("Major")
		end))
	end

	if not (#buttons > 0 and lowercase and uppercase) then
		ClientDebugConfig.Warn("[BindsLogic] Shift UI not wired")

		return
	end

	uppercase.Visible = false
	lowercase.Visible = true

	local color2 = Color3.fromRGB(255, 255, 255)
	local color3 = Color3.fromRGB(0, 170, 255)

	local function updateShiftButtonStyle(p)
		for _, button in ipairs(buttons) do
			if not button:IsA("GuiButton") then
				continue
			end

			button.BackgroundColor3 = p and color3 or color2
			button.BackgroundTransparency = 0
		end
	end

	updateShiftButtonStyle(false)

	local flag4 = false
	local function onShiftToggle()
		if flag4 then
			return
		end

		flag4 = true

		if flag2 then
			endCapture()
		end

		clearPreviewHighlight() -- inferred equivalent call
		local visible = not uppercase.Visible
		uppercase.Visible = visible
		lowercase.Visible = not visible
		styleUppercaseRow()

		updateShiftButtonStyle(visible)

		flag4 = false
	end

	for _, v11 in ipairs(buttons) do
		if v11:GetAttribute("BindsLogic_ShiftWired") then
			continue
		end

		v11:SetAttribute("BindsLogic_ShiftWired", true)
		v11.Active = true
		addConn(v11.Activated:Connect(onShiftToggle)) -- inferred equivalent call
	end
end

function BindsLogic.ResetBindings()
	if BindsLogic._applyPresetSimple then
		BindsLogic._applyPresetSimple("Major")
	end
end

function BindsLogic.Cleanup()
	endCapture()
	clearPreviewHighlight() -- inferred equivalent call
	disconnectAll()
end

return BindsLogic