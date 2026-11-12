local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rainbowVisualizer = require(ReplicatedStorage:WaitForChild("Monetization"):WaitForChild("MonetizationConfig")).GamePassIds.RainbowVisualizer
local color = Color3.fromRGB(0, 255, 0)
local color2 = Color3.fromRGB(214, 2, 6)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local function waitForStartupChild(instance, childName, p)
	if not instance then
		return nil
	end

	local child = instance:FindFirstChild(childName)

	if child then
		return child
	end

	local child2 = instance:WaitForChild(childName, 30)

	if not child2 then
		warn(("[ColourWheelGui] Missing %s under %s after startup wait%s"):format(
			childName,
			instance:GetFullName(),
			p and " for " .. p or ""
		))
	end

	return child2
end

local Piano_Dependencies = workspace:WaitForChild("Piano_Dependencies")
local Modules = Piano_Dependencies:WaitForChild("Modules")
local Dependencies = Modules:WaitForChild("Dependencies")
local Logic = Modules:WaitForChild("Logic")
local PianoVisualization = require(Dependencies:WaitForChild("PianoVisualization"))
local PianoModelKeyHighlight = require(Dependencies:WaitForChild("PianoModelKeyHighlight"))
local UILogic = require(Logic:WaitForChild("UILogic"))
local Remotes = Piano_Dependencies:WaitForChild("Remotes")
local VisualizerRemote = Remotes:WaitForChild("VisualizerRemote")
local SaveVisualizerSettings = Remotes:WaitForChild("SaveVisualizerSettings")
local VisualizerSettingsLoaded = Remotes:WaitForChild("VisualizerSettingsLoaded")
local CheckGamepassEntitlement = Remotes:WaitForChild("CheckGamepassEntitlement")
local ShopPurchasesUpdated = Remotes:WaitForChild("ShopPurchasesUpdated")
local OpenPianoColorWheel = ReplicatedStorage2:FindFirstChild("OpenPianoColorWheel")

if not OpenPianoColorWheel then
	OpenPianoColorWheel = Instance.new("BindableEvent")
	OpenPianoColorWheel.Name = "OpenPianoColorWheel"
	OpenPianoColorWheel.Parent = ReplicatedStorage2
end

local PianoRoll2DColorPicked = ReplicatedStorage2:FindFirstChild("PianoRoll2DColorPicked")

if not PianoRoll2DColorPicked then
	PianoRoll2DColorPicked = Instance.new("BindableEvent")
	PianoRoll2DColorPicked.Name = "PianoRoll2DColorPicked"
	PianoRoll2DColorPicked.Parent = ReplicatedStorage2
end

local parent = script.Parent
local colourWheel = parent:WaitForChild("ColourWheel")

local function bringColorWheelToFront() -- 2 equivalent calls inferred from this helper
	parent.DisplayOrder = math.max(parent.DisplayOrder, 2000)
	colourWheel.Active = true
end

bringColorWheelToFront() -- inferred equivalent call
local colourWheel2 = colourWheel:WaitForChild("ColourWheel")
local picker = colourWheel2:WaitForChild("Picker")
local colorPreview = picker:WaitForChild("Dot"):WaitForChild("ColorPreview")

local components = colourWheel:WaitForChild("Components")

local input = components:WaitForChild("R"):WaitForChild("InputBackground"):WaitForChild("Input")
local input2 = components:WaitForChild("G"):WaitForChild("InputBackground"):WaitForChild("Input")
local input3 = components:WaitForChild("B"):WaitForChild("InputBackground"):WaitForChild("Input")
local input4 = components:WaitForChild("Hex"):WaitForChild("InputBackground"):WaitForChild("Input")

local slider = components:WaitForChild("Darkness"):WaitForChild("Slider")
local line = slider:WaitForChild("Track"):WaitForChild("Line")
local slider2 = line:WaitForChild("Slider")
local uiGradient = line:WaitForChild("UIGradient")

local textButton = colourWheel:WaitForChild("ButtonClose"):WaitForChild("TextButton")

local buttons = colourWheel:WaitForChild("Buttons")

local rainbow = buttons:WaitForChild("Rainbow")
local textButton2 = rainbow:WaitForChild("TextButton")
local textLabel = rainbow:WaitForChild("TextLabel")

local textButton3 = buttons:WaitForChild("Confirm"):WaitForChild("TextButton")

local title = colourWheel:WaitForChild("Title")
local targetSelector = colourWheel:WaitForChild("TargetSelector")
local title2 = targetSelector:WaitForChild("Title")
local whiteKey = targetSelector:WaitForChild("WhiteKey")
local blackKey = targetSelector:WaitForChild("BlackKey")

local CurrentCamera = workspace.CurrentCamera

local clickSound = nil
pcall(function()
	clickSound = ReplicatedStorage2:WaitForChild("SoundFX"):WaitForChild("ClickSound")
end)

local v = false
local v2 = nil
local v3 = 0
local v4 = 0
local v5 = 1
local v6 = false
local flag = false
local v7 = nil
local v8 = 0

local v9 = nil
local piano = nil
local v10 = nil
local v11 = false
local v12 = nil
local v13 = "visualizer"
local v14 = nil

local color3 = Color3.fromRGB(45, 118, 235)
local color4 = Color3.fromRGB(34, 39, 44)

local function Color3ToHex(data) -- 3 equivalent calls inferred from this helper
	return string.format("#%02X%02X%02X", data.R * 255, data.G * 255, data.B * 255)
end

local function HexToColor3(value)
	local v15 = value:gsub("#", "")

	if #v15 ~= 6 then
		return
	end

	local v16 = tonumber(v15:sub(1, 2), 16) / 255
	local v17 = tonumber(v15:sub(3, 4), 16) / 255
	local v18 = tonumber(v15:sub(5, 6), 16) / 255
	return Color3.new(v16, v17, v18)
end

local function activePianoAllowsRainbow(): boolean -- 3 equivalent calls inferred from this helper
	return piano ~= nil and piano:GetAttribute("UseDefaultSynthesia") == true
end

local function isRainbowEffectiveForActivePiano() -- 6 equivalent calls inferred from this helper
	return v and activePianoAllowsRainbow() -- inferred equivalent call
end

local function refreshRainbowButton() -- 6 equivalent calls inferred from this helper
	local rainbowEffectiveForActivePiano = isRainbowEffectiveForActivePiano() -- inferred equivalent call
	textButton2.BackgroundColor3 = rainbowEffectiveForActivePiano and color or color2
	textLabel.Text = rainbowEffectiveForActivePiano and "Rainbow: ON" or "Rainbow: OFF"
end

local function RGBStringsToColor3(text, text2, text3) -- 1 equivalent call inferred from this helper
	local v15 = tonumber(text)
	local v16 = tonumber(text2)
	local v17 = tonumber(text3)

	if v15 and v16 and v17 then
		return Color3.fromRGB(math.clamp(v15, 0, 255), math.clamp(v16, 0, 255), (math.clamp(v17, 0, 255)))
	end
end

local function getSavedColorForTarget()
	if v13 == "synthWhite" then
		local whiteSynthesiaHex = v10 and v10.WhiteSynthesiaHex
			or LocalPlayer:GetAttribute("WhiteSynthesiaHex")
			or v10 and v10.VisualizerColorHex
			or "#FFFFFF"
		return HexToColor3(whiteSynthesiaHex) or Color3.fromRGB(255, 255, 255)
	elseif v13 == "synthBlack" then
		local blackSynthesiaHex = v10 and v10.BlackSynthesiaHex
			or LocalPlayer:GetAttribute("BlackSynthesiaHex")
			or v10 and v10.VisualizerColorHex
			or "#FFFFFF"
		return HexToColor3(blackSynthesiaHex) or Color3.fromRGB(255, 255, 255)
	elseif v13 == "whiteKey" then
		local whiteKeyHighlightHex = v10 and v10.WhiteKeyHighlightHex
			or LocalPlayer:GetAttribute("WhiteKeyHighlightHex")
			or "#66FF66"
		return HexToColor3(whiteKeyHighlightHex) or Color3.fromRGB(102, 255, 102)
	elseif v13 == "blackKey" then
		local blackKeyHighlightHex = v10 and v10.BlackKeyHighlightHex
			or LocalPlayer:GetAttribute("BlackKeyHighlightHex")
			or "#66FF66"
		return HexToColor3(blackKeyHighlightHex) or Color3.fromRGB(102, 255, 102)
	end

	if v13 == "pianoRollTile" or v13 == "pianoRollWhiteTile" then
		local pianoRoll2DWhiteTileColorHex = LocalPlayer:GetAttribute("PianoRoll2DWhiteTileColorHex")
			or LocalPlayer:GetAttribute("PianoRoll2DTileColorHex")
			or "#5FBEFF"
		return HexToColor3(pianoRoll2DWhiteTileColorHex) or Color3.fromRGB(95, 190, 255)
	end

	if v13 == "pianoRollBlackTile" then
		local pianoRoll2DBlackTileColorHex = LocalPlayer:GetAttribute("PianoRoll2DBlackTileColorHex") or "#1E3A5F"
		return HexToColor3(pianoRoll2DBlackTileColorHex) or Color3.fromRGB(30, 58, 95)
	end

	if v13 ~= "pianoRollImpact" then
		return HexToColor3(v10 and v10.VisualizerColorHex or "#FFFFFF") or Color3.fromRGB(255, 255, 255)
	end

	local pianoRoll2DImpactColorHex = LocalPlayer:GetAttribute("PianoRoll2DImpactColorHex") or "#5FBEFF"
	return HexToColor3(pianoRoll2DImpactColorHex) or Color3.fromRGB(95, 190, 255)
end

local function applySavedGuiHighlightColors()
	local whiteKeyHighlightHex = v10 and v10.WhiteKeyHighlightHex
		or LocalPlayer:GetAttribute("WhiteKeyHighlightHex")
		or "#66FF66"
	local blackKeyHighlightHex = v10 and v10.BlackKeyHighlightHex
		or LocalPlayer:GetAttribute("BlackKeyHighlightHex")
		or "#66FF66"
	local v15 = HexToColor3(whiteKeyHighlightHex) or Color3.fromRGB(102, 255, 102)
	local v16 = HexToColor3(blackKeyHighlightHex) or Color3.fromRGB(102, 255, 102)
	UILogic.SetActiveKeyHighlightColors(v15, v16)
	LocalPlayer:SetAttribute("WhiteKeyHighlightHex", Color3ToHex(v15))
	LocalPlayer:SetAttribute("BlackKeyHighlightHex", Color3ToHex(v16))
end

local function getSavedSynthesiaColors()
	local visualizerColorHex = v10 and v10.VisualizerColorHex
		or LocalPlayer:GetAttribute("CurrentColourHex")
		or "#FFFFFF"
	local whiteSynthesiaHex = v10 and v10.WhiteSynthesiaHex
		or LocalPlayer:GetAttribute("WhiteSynthesiaHex")
		or visualizerColorHex
	local blackSynthesiaHex = v10 and v10.BlackSynthesiaHex
		or LocalPlayer:GetAttribute("BlackSynthesiaHex")
		or visualizerColorHex
	return
		HexToColor3(whiteSynthesiaHex) or Color3.fromRGB(255, 255, 255),
		HexToColor3(blackSynthesiaHex) or Color3.fromRGB(255, 255, 255)
end

local function repaintHeldPianoKeys(instance)
	local scripts = instance and instance:FindFirstChild("Scripts")
	local pianoModule = scripts and scripts:FindFirstChild("PianoModule")

	if not pianoModule then
		return
	end

	pcall(function()
		local module = require(pianoModule)

		if module and module.RepaintHeldKeys then
			module.RepaintHeldKeys()
		end
	end)
end

local function syncSynthesiaKeyColorsToServer(instance, savedSynthesiaColors: Color3?, black: Color3?)
	if not instance or typeof(savedSynthesiaColors) ~= "Color3" or typeof(black) ~= "Color3" then
		return
	end

	VisualizerRemote:FireServer({
		op = "setKeyColors",
		white = savedSynthesiaColors,
		black = black,
		color = savedSynthesiaColors,
		piano = instance
	})
end

local function applySavedSynthesiaColorsToPiano(instance)
	if not instance or instance:GetAttribute("RainbowActive") == true then
		return nil
	end

	local savedSynthesiaColors, black = getSavedSynthesiaColors()
	PianoVisualization.SetVisualizerKeyColors(savedSynthesiaColors, black, instance)
	PianoModelKeyHighlight.ApplySynthesiaColors(instance, savedSynthesiaColors, black)
	repaintHeldPianoKeys(instance)
	syncSynthesiaKeyColorsToServer(instance, savedSynthesiaColors, black)
	return savedSynthesiaColors, black
end

local function vec2FromInput(input5)
	if input5.UserInputType == Enum.UserInputType.MouseMovement then
		return UserInputService:GetMouseLocation() - Vector2.new(0, GuiService:GetGuiInset().Y)
	end

	if input5.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(input5.Position.X, input5.Position.Y)
	end
end

local function pointInRect(p, absolutePosition, absoluteSize): boolean -- 6 equivalent calls inferred from this helper
	return p.X >= absolutePosition.X
		and p.X <= absolutePosition.X + absoluteSize.X
		and p.Y >= absolutePosition.Y
		and p.Y <= absolutePosition.Y + absoluteSize.Y
end

local flag2 = false
local v15 = nil
local v16 = Vector2.zero

local function pointerPosition(input5)
	if input5.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(input5.Position.X, input5.Position.Y)
	end

	return UserInputService:GetMouseLocation() - Vector2.new(0, GuiService:GetGuiInset().Y)
end

local function getPanelCenter() -- 1 equivalent call inferred from this helper
	local vector2 = Vector2.new(
		colourWheel.AbsoluteSize.X * colourWheel.AnchorPoint.X,
		colourWheel.AbsoluteSize.Y * colourWheel.AnchorPoint.Y
	)

	return colourWheel.AbsolutePosition + vector2
end

local function setPanelCenter(p)
	local viewportSize = CurrentCamera and CurrentCamera.ViewportSize or Vector2.new(1280, 720)
	local halfAbsoluteSize = colourWheel.AbsoluteSize / 2
	local vector2 = Vector2.new(
		math.clamp(p.X, halfAbsoluteSize.X, viewportSize.X - halfAbsoluteSize.X),
		(math.clamp(p.Y, halfAbsoluteSize.Y, viewportSize.Y - halfAbsoluteSize.Y))
	)

	colourWheel.Position = UDim2.fromOffset(vector2.X, vector2.Y)
end

local function isPanelDragPoint(p): boolean
	if
		not pointInRect(p, colourWheel.AbsolutePosition, colourWheel.AbsoluteSize) -- inferred equivalent call
		or p.Y > colourWheel.AbsolutePosition.Y + 52
		or textButton and pointInRect(p, textButton.AbsolutePosition, textButton.AbsoluteSize) -- inferred equivalent call
	then
		return false
	end

	return true
end

local function ownsRainbowPass()
	if v9 ~= nil then
		return v9
	end

	local success, result = pcall(function()
		return CheckGamepassEntitlement:InvokeServer(rainbowVisualizer)
	end)

	if not success then
		success, result = pcall(
			MarketplaceService.UserOwnsGamePassAsync,
			MarketplaceService,
			LocalPlayer.UserId,
			rainbowVisualizer
		)
	end

	v9 = success and result == true
	return v9
end

local function findPianoFromSeat(seatPart)
	if not seatPart then
		return nil
	end

	local v17 = seatPart:FindFirstAncestorOfClass("Model")

	while v17 do
		if v17:FindFirstChild("Keys") and v17:FindFirstChild("SeatOccupant") then
			return v17
		end

		v17 = v17.Parent
	end

	return nil
end

local function updateColorPreview(color5: Color3)
	colorPreview.ImageColor3 = color5
	input4.Text = Color3ToHex(color5) -- inferred equivalent call
	input.Text = tostring((math.floor(color5.R * 255)))
	input2.Text = tostring((math.floor(color5.G * 255)))
	input3.Text = tostring((math.floor(color5.B * 255)))

	v12 = color5
end

local fn

local function commitPendingColor() -- 4 equivalent calls inferred from this helper
	if v12 and fn then
		fn(v12)
	end
end

fn = function(vizColor: Color3)
	local v17 = Color3ToHex(vizColor) -- inferred equivalent call

	if v13 == "synthWhite" then
		SaveVisualizerSettings:FireServer({ WhiteSynthesiaHex = v17 })

		if not v10 then
			v10 = {}
		end

		v10.WhiteSynthesiaHex = v17
		LocalPlayer:SetAttribute("WhiteSynthesiaHex", v17)
		applySavedSynthesiaColorsToPiano(piano)
	elseif v13 == "synthBlack" then
		SaveVisualizerSettings:FireServer({ BlackSynthesiaHex = v17 })

		if not v10 then
			v10 = {}
		end

		v10.BlackSynthesiaHex = v17
		LocalPlayer:SetAttribute("BlackSynthesiaHex", v17)
		applySavedSynthesiaColorsToPiano(piano)
	elseif v13 == "whiteKey" then
		SaveVisualizerSettings:FireServer({ WhiteKeyHighlightHex = v17 })

		if not v10 then
			v10 = {}
		end

		v10.WhiteKeyHighlightHex = v17
		applySavedGuiHighlightColors()
	elseif v13 == "blackKey" then
		SaveVisualizerSettings:FireServer({ BlackKeyHighlightHex = v17 })

		if not v10 then
			v10 = {}
		end

		v10.BlackKeyHighlightHex = v17
		applySavedGuiHighlightColors()
	elseif
		v13 == "pianoRollTile"
		or v13 == "pianoRollWhiteTile"
		or v13 == "pianoRollBlackTile"
		or v13 == "pianoRollImpact"
	then
		PianoRoll2DColorPicked:Fire(v13, v17)
	else
		if v2 == vizColor then
			v12 = nil
			return
		end

		SaveVisualizerSettings:FireServer({
			VisualizerColorHex = v17,
			WhiteSynthesiaHex = v17,
			BlackSynthesiaHex = v17
		})

		if not v10 then
			v10 = {}
		end

		v10.VisualizerColorHex = v17
		v10.WhiteSynthesiaHex = v17
		v10.BlackSynthesiaHex = v17
		LocalPlayer:SetAttribute("CurrentColourHex", v17)
		LocalPlayer:SetAttribute("WhiteSynthesiaHex", v17)
		LocalPlayer:SetAttribute("BlackSynthesiaHex", v17)

		if piano and not isRainbowEffectiveForActivePiano() then -- inferred equivalent call
			PianoVisualization.SetVisualizerColor(vizColor, piano)

			if PianoVisualization.SetVisualizerKeyColors then
				PianoVisualization.SetVisualizerKeyColors(vizColor, vizColor, piano)
			end

			piano:SetAttribute("VizColor", vizColor)

			local scripts = piano:FindFirstChild("Scripts")
			local pianoModule = scripts and scripts:FindFirstChild("PianoModule")

			if pianoModule then
				pcall(function()
					local module = require(pianoModule)

					if module.RepaintHeldKeys then
						module.RepaintHeldKeys()
					end
				end)
			end

			VisualizerRemote:FireServer({ op = "setColor", color = vizColor, piano = piano })
		end

		v2 = vizColor
	end

	v12 = nil
end

local function applySavedColorToUI(imageColor)
	if not imageColor or typeof(imageColor) ~= "Color3" then
		return
	end

	colorPreview.ImageColor3 = imageColor
	input4.Text = Color3ToHex(imageColor) -- inferred equivalent call
	input.Text = tostring((math.floor(imageColor.R * 255)))
	input2.Text = tostring((math.floor(imageColor.G * 255)))
	input3.Text = tostring((math.floor(imageColor.B * 255)))

	local hsv, v17, v18 = imageColor:ToHSV()
	v3 = hsv
	v4 = v17
	v5 = v18

	local v19 = hsv * 2 * 3.141592653589793
	local v20 = 3.141592653589793 - v19
	local v21 = v17 * 0.5
	picker.Position = UDim2.new(0.5 + math.cos(v20) * v21, 0, 0.5 + math.sin(v20) * v21, 0)

	slider2.Position = UDim2.new(1 - v18, 0, 0.5, 0)

	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(hsv, v17, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
	})

	v12 = nil
	v2 = imageColor
end

local function refreshTargetSelector()
	local visible = v14 == "synthesia" or v14 == "keyHighlight"
	targetSelector.Visible = visible
	title.Text = v14 == "synthesia" and "Synthesia Color"
		or v14 == "keyHighlight" and "GUI Key Highlight Color"
		or v14 == "pianoRoll2D"
		and (v13 == "pianoRollImpact" and "2D Burst Color" or v13 == "pianoRollBlackTile" and "2D Black Tile Color" or "2D White Tile Color")
		or "Color picker"

	if rainbow then
		rainbow.Visible = v14 ~= "keyHighlight" and v14 ~= "pianoRoll2D"
	end

	if not visible then
		return
	end

	title2.Text = v14 == "synthesia" and "Falling Bar Key" or "GUI Highlight Key"
	local v17 = v13 == "synthWhite" or v13 == "whiteKey"
	whiteKey.BackgroundColor3 = v17 and color3 or color4
	blackKey.BackgroundColor3 = not v17 and color3 or color4
end

local function setSplitColorTarget(p)
	commitPendingColor() -- inferred equivalent call

	if v14 == "synthesia" then
		v13 = p == "black" and "synthBlack" or "synthWhite"
	elseif v14 == "keyHighlight" then
		v13 = p == "black" and "blackKey" or "whiteKey"
	else
		return
	end

	v2 = nil
	applySavedColorToUI(getSavedColorForTarget())
	refreshTargetSelector()
end

local function applyUiToPianoColor(_) -- 1 equivalent call inferred from this helper
	applySavedColorToUI(getSavedColorForTarget())
end

local function onSeatChanged()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seatPart = humanoid and humanoid.SeatPart
	local pianoFromSeat = findPianoFromSeat(seatPart)

	if piano ~= pianoFromSeat then
		piano = pianoFromSeat
		v2 = nil
		applyUiToPianoColor() -- inferred equivalent call
		refreshRainbowButton() -- inferred equivalent call

		if piano and v10 and v10.VisualizerColorHex and not isRainbowEffectiveForActivePiano() then -- inferred equivalent call
			local color5 = applySavedSynthesiaColorsToPiano(piano)
				or HexToColor3(v10.VisualizerColorHex)
				or Color3.fromRGB(255, 255, 255)

			piano:SetAttribute("VizColor", color5)
			repaintHeldPianoKeys(piano)

			task.wait(0.1)
			VisualizerRemote:FireServer({ op = "setColor", color = color5, piano = piano })
			v2 = color5
		end
	end
end

local seatPartChangedConnection = nil

local function connectSeatWatcher(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
		or waitForStartupChild(character, "Humanoid", "seat watcher")

	if not humanoid then
		return
	end

	if seatPartChangedConnection then
		seatPartChangedConnection:Disconnect()
		seatPartChangedConnection = nil
	end

	seatPartChangedConnection = humanoid:GetPropertyChangedSignal("SeatPart"):Connect(onSeatChanged)
	onSeatChanged()
end

LocalPlayer.CharacterAdded:Connect(connectSeatWatcher)

if LocalPlayer.Character then
	connectSeatWatcher(LocalPlayer.Character)
end

local function updateColour(_: Vector2, flag3: boolean)
	local absolutePosition = colourWheel2.AbsolutePosition
	local absoluteSize = colourWheel2.AbsoluteSize
	local vector2 = Vector2.new(absolutePosition.X + absoluteSize.X / 2, absolutePosition.Y + absoluteSize.Y / 2)

	local vector2_2 = Vector2.new(
		picker.AbsolutePosition.X + picker.AbsoluteSize.X / 2,
		picker.AbsolutePosition.Y + picker.AbsoluteSize.Y / 2
	)

	local v17 = math.atan2(vector2_2.Y - vector2.Y, vector2_2.X - vector2.X)
	local v18 = (3.141592653589793 - v17) / 6.283185307179586
	local v19 = (vector2 - vector2_2).Magnitude / (colourWheel2.AbsoluteSize.X / 2)

	if not flag3 then
		v3 = math.clamp(v18, 0, 1)
		v4 = math.clamp(v19, 0, 1)
	end

	local x = slider2.AbsolutePosition.X
	local x2 = line.AbsolutePosition.X
	local x3 = line.AbsoluteSize.X
	v5 = 1 - math.clamp((x - x2) / x3, 0, 1)

	local color5 = Color3.fromHSV(v3, v4, (math.clamp(v5, 0, 1)))

	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(v3, v4, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
	})

	updateColorPreview(color5)
end

task.wait(0.1)
updateColour(Vector2.new(0, 0), true)

VisualizerSettingsLoaded.OnClientEvent:Connect(function(p)
	if not p then
		return
	end

	v11 = true
	v10 = p

	if p.VisualizerColorHex then
		local imageColor = HexToColor3(p.VisualizerColorHex) or Color3.fromRGB(255, 255, 255)
		LocalPlayer:SetAttribute("CurrentColourHex", Color3ToHex(imageColor))
		applySavedColorToUI(imageColor)
	end

	v = p.RainbowEnabled == true and ownsRainbowPass()

	applySavedGuiHighlightColors()
	applySavedSynthesiaColorsToPiano(piano)
	applySavedColorToUI(getSavedColorForTarget())
	refreshRainbowButton() -- inferred equivalent call
end)

LocalPlayer:GetAttributeChangedSignal("CurrentColourHex"):Connect(function()
	if v10 then
		v10.VisualizerColorHex = LocalPlayer:GetAttribute("CurrentColourHex") or "#FFFFFF"
	end

	if v13 == "visualizer" then
		applySavedColorToUI(getSavedColorForTarget())
	end
end)

LocalPlayer:GetAttributeChangedSignal("WhiteSynthesiaHex"):Connect(function()
	if v10 then
		v10.WhiteSynthesiaHex = LocalPlayer:GetAttribute("WhiteSynthesiaHex") or v10.VisualizerColorHex or "#FFFFFF"
	end

	applySavedSynthesiaColorsToPiano(piano)

	if v13 == "synthWhite" then
		applySavedColorToUI(getSavedColorForTarget())
	end
end)

LocalPlayer:GetAttributeChangedSignal("BlackSynthesiaHex"):Connect(function()
	if v10 then
		v10.BlackSynthesiaHex = LocalPlayer:GetAttribute("BlackSynthesiaHex") or v10.VisualizerColorHex or "#FFFFFF"
	end

	applySavedSynthesiaColorsToPiano(piano)

	if v13 == "synthBlack" then
		applySavedColorToUI(getSavedColorForTarget())
	end
end)

LocalPlayer:GetAttributeChangedSignal("WhiteKeyHighlightHex"):Connect(function()
	if v10 then
		v10.WhiteKeyHighlightHex = LocalPlayer:GetAttribute("WhiteKeyHighlightHex") or "#66FF66"
	end

	applySavedGuiHighlightColors()

	if v13 == "whiteKey" then
		applySavedColorToUI(getSavedColorForTarget())
	end
end)

LocalPlayer:GetAttributeChangedSignal("BlackKeyHighlightHex"):Connect(function()
	if v10 then
		v10.BlackKeyHighlightHex = LocalPlayer:GetAttribute("BlackKeyHighlightHex") or "#66FF66"
	end

	applySavedGuiHighlightColors()

	if v13 == "blackKey" then
		applySavedColorToUI(getSavedColorForTarget())
	end
end)

input4.FocusLost:Connect(function(p)
	if not p then
		return
	end

	local hexToColor3 = HexToColor3(input4.Text)

	if not hexToColor3 then
		return
	end

	local hsv, v17, v18 = hexToColor3:ToHSV()
	v3 = hsv
	v4 = v17
	v5 = v18

	local v19 = hsv * 2 * 3.141592653589793
	local v20 = 3.141592653589793 - v19
	local v21 = v17 * 0.5
	picker.Position = UDim2.new(0.5 + math.cos(v20) * v21, 0, 0.5 + math.sin(v20) * v21, 0)

	slider2.Position = UDim2.new(1 - v18, 0, 0.5, 0)

	updateColour(Vector2.new(0, 0), true)

	fn(hexToColor3)
end)

local function applyRGBInputs()
	local rGBStringsToColor3 = RGBStringsToColor3(input.Text, input2.Text, input3.Text) -- inferred equivalent call

	if not rGBStringsToColor3 then
		return
	end

	local hsv, v17, v18 = rGBStringsToColor3:ToHSV()
	v3 = hsv
	v4 = v17
	v5 = v18

	local v19 = hsv * 2 * 3.141592653589793
	local v20 = 3.141592653589793 - v19
	local v21 = v17 * 0.5
	picker.Position = UDim2.new(0.5 + math.cos(v20) * v21, 0, 0.5 + math.sin(v20) * v21, 0)

	slider2.Position = UDim2.new(1 - v18, 0, 0.5, 0)

	updateColour(Vector2.new(0, 0), true)

	fn(rGBStringsToColor3)
end

input.FocusLost:Connect(function(p)
	if p then
		applyRGBInputs()
	end
end)
input2.FocusLost:Connect(function(p)
	if p then
		applyRGBInputs()
	end
end)
input3.FocusLost:Connect(function(p)
	if p then
		applyRGBInputs()
	end
end)

local function beginUIGrab()
	v8 += 1

	if v8 == 1 then
		local success, result = pcall(function()
			return LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 8)
		end)

		if success and result then
			local success2, result2 = pcall(require, result)

			if success2 and result2 then
				pcall(function()
					result2:GetControls():Disable()
				end)
				pcall(function()
					result2:GetCameras():Disable()
				end)
			end
		end

		ContextActionService:BindActionAtPriority("ColorWheel_BlockInput", function()
			return Enum.ContextActionResult.Sink
		end, false, 3000, Enum.UserInputType.Touch, Enum.UserInputType.MouseMovement)
	end
end

local function endUIGrab()
	if v8 > 0 then
		v8 -= 1

		if v8 == 0 then
			pcall(function()
				ContextActionService:UnbindAction("ColorWheel_BlockInput")
			end)
			local success, result = pcall(function()
				return LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 2)
			end)

			if success and result then
				local success2, result2 = pcall(require, result)

				if success2 and result2 then
					pcall(function()
						result2:GetCameras():Enable()
					end)
					pcall(function()
						result2:GetControls():Enable()
					end)
				end
			end
		end
	end
end

colourWheel2.MouseButton1Down:Connect(function()
	v6 = true
	beginUIGrab()
end)

slider.MouseButton1Down:Connect(function()
	flag = true
	beginUIGrab()
end)

UserInputService.InputBegan:Connect(function(input5)
	if not colourWheel.Visible then
		return
	end

	local v17 = (input5.UserInputType == Enum.UserInputType.MouseButton1 or input5.UserInputType == Enum.UserInputType.Touch)
		and pointerPosition(input5)

	if v17 then
		local v18 = pointInRect(v17, colourWheel.AbsolutePosition, colourWheel.AbsoluteSize) -- inferred equivalent call
		local v19

		if v18 and not (v17.Y > colourWheel.AbsolutePosition.Y + 52) then
			if textButton then
				v19 = not pointInRect(v17, textButton.AbsolutePosition, textButton.AbsoluteSize) -- inferred equivalent call
			else
				v19 = true
			end
		else
			v19 = false
		end

		if v19 then
			flag2 = true
			v15 = input5
			v16 = v17 - getPanelCenter() -- inferred equivalent call
			beginUIGrab()
			return
		end
	end

	if input5.UserInputType == Enum.UserInputType.Touch then
		local vector2 = Vector2.new(input5.Position.X, input5.Position.Y)

		if pointInRect(vector2, colourWheel2.AbsolutePosition, colourWheel2.AbsoluteSize) then -- inferred equivalent call
			v6 = true
			v7 = input5
			beginUIGrab()
		elseif pointInRect(vector2, line.AbsolutePosition, line.AbsoluteSize) then -- inferred equivalent call
			flag = true
			v7 = input5
			beginUIGrab()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input5)
	if input5.UserInputType == Enum.UserInputType.MouseButton1 or input5.UserInputType == Enum.UserInputType.Touch then
		local flag3

		if flag2 and (input5.UserInputType == Enum.UserInputType.MouseButton1 or v15 == input5) then
			flag2 = false
			v15 = nil
			flag3 = true
		else
			flag3 = false
		end

		if (v6 or flag) and (not v7 or v7 == input5) then
			commitPendingColor() -- inferred equivalent call
			v6 = false
			flag = false
			v7 = nil
			flag3 = true
		end

		if flag3 then
			endUIGrab()
		end
	end
end)

UserInputService.InputChanged:Connect(function(input5)
	if
		input5.UserInputType ~= Enum.UserInputType.MouseMovement and input5.UserInputType ~= Enum.UserInputType.Touch
		or input5.UserInputType == Enum.UserInputType.Touch and v7 and input5 ~= v7
	then
		return
	end

	local v17 = vec2FromInput(input5)

	if not v17 then
		return
	end

	if flag2 then
		if input5.UserInputType == Enum.UserInputType.Touch and v15 and input5 ~= v15 then
			return
		end

		setPanelCenter(v17 - v16)
	else
		local vector2 = Vector2.new(
			colourWheel2.AbsolutePosition.X + colourWheel2.AbsoluteSize.X / 2,
			colourWheel2.AbsolutePosition.Y + colourWheel2.AbsoluteSize.Y / 2
		)

		local magnitude = (v17 - vector2).Magnitude

		if v6 and magnitude <= colourWheel2.AbsoluteSize.X / 2 then
			picker.Position = UDim2.fromOffset(
				v17.X - colourWheel2.AbsolutePosition.X,
				v17.Y - colourWheel2.AbsolutePosition.Y
			)

			updateColour(vector2, false)
		elseif flag then
			local x = line.AbsolutePosition.X
			local x2 = line.AbsoluteSize.X
			local v18 = math.clamp(v17.X - x, 0, x2)
			slider2.Position = UDim2.new(v18 / x2, 0, 0.5, 0)
			updateColour(vector2, true)
		end
	end
end)
local backgroundColor
local rainbowEffectiveForActivePiano = isRainbowEffectiveForActivePiano() -- inferred equivalent call

if rainbowEffectiveForActivePiano then
	backgroundColor = color or color2
else
	backgroundColor = color2
end

textButton2.BackgroundColor3 = backgroundColor
textLabel.Text = rainbowEffectiveForActivePiano and "Rainbow: ON" or "Rainbow: OFF"

ShopPurchasesUpdated.OnClientEvent:Connect(function()
	v9 = nil
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= LocalPlayer or p2 ~= rainbowVisualizer then
		return
	end

	if p3 then
		v9 = true
		v = true
		refreshRainbowButton() -- inferred equivalent call

		if activePianoAllowsRainbow() and piano then -- inferred equivalent call
			VisualizerRemote:FireServer({ op = "rainbow", enable = true, piano = piano })
		end

		SaveVisualizerSettings:FireServer({ RainbowEnabled = true })
	end
end)

local flag3 = false
textButton2.MouseButton1Click:Connect(function()
	if flag3 then
		return
	end

	flag3 = true

	if clickSound then
		pcall(function()
			clickSound:Play()
		end)
	end

	if ownsRainbowPass() then
		local v17 = not isRainbowEffectiveForActivePiano() -- inferred equivalent call

		if v17 and not activePianoAllowsRainbow() then -- inferred equivalent call
			v = false
			refreshRainbowButton() -- inferred equivalent call
			flag3 = false
			return
		end

		v = v17
		refreshRainbowButton() -- inferred equivalent call

		if isRainbowEffectiveForActivePiano() then -- inferred equivalent call
			if piano then
				VisualizerRemote:FireServer({ op = "rainbow", enable = true, piano = piano })
			end

			SaveVisualizerSettings:FireServer({ RainbowEnabled = true })
		else
			if piano then
				VisualizerRemote:FireServer({ op = "rainbow", enable = false, piano = piano })
				task.wait(0.1)
				local imageColor3 = colorPreview.ImageColor3
				PianoVisualization.SetVisualizerColor(imageColor3, piano)
				VisualizerRemote:FireServer({ op = "setColor", color = imageColor3, piano = piano })
				v2 = imageColor3
			end

			SaveVisualizerSettings:FireServer({ RainbowEnabled = false })
		end

		flag3 = false
	else
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, rainbowVisualizer)
		flag3 = false
	end
end)

VisualizerRemote.OnClientEvent:Connect(function(value, imageColor, p)
	if typeof(value) ~= "string" then
		return
	end

	if value == "setColor" then
		if typeof(imageColor) == "Color3" and p then
			PianoVisualization.SetVisualizerColor(imageColor, p)

			if piano and p == piano then
				v2 = imageColor

				if v13 == "visualizer" then
					applySavedColorToUI(imageColor)
				end
			end
		end
	elseif value == "rainbow" and piano and imageColor == piano then
		v = p and true or false
		refreshRainbowButton() -- inferred equivalent call
	end
end)

local rotation = colourWheel.Rotation
local backgroundTransparency = colourWheel.BackgroundTransparency
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tween = TweenService:Create(CurrentCamera, tweenInfo, { FieldOfView = 50 })
local tween2 = TweenService:Create(CurrentCamera, tweenInfo, { FieldOfView = 70 })

local function openPanel()
	bringColorWheelToFront() -- inferred equivalent call
	colourWheel.Visible = true
	colourWheel.Rotation = math.random(-3.5, 3.5)
	colourWheel.BackgroundTransparency = 1
	TweenService:Create(colourWheel, tweenInfo2, {
		BackgroundTransparency = backgroundTransparency,
		Rotation = rotation
	}):Play()
	tween:Play()
end

local function closePanel()
	local tween3 = TweenService:Create(colourWheel, tweenInfo3, { BackgroundTransparency = 1 })
	local tween4 = TweenService:Create(colourWheel, tweenInfo3, { Rotation = rotation })
	tween3:Play()
	tween4:Play()
	tween3.Completed:Connect(function()
		colourWheel.Visible = false
	end)
	tween2:Play()
end

whiteKey.MouseButton1Click:Connect(function()
	if clickSound then
		pcall(function()
			clickSound:Play()
		end)
	end

	commitPendingColor() -- inferred equivalent call

	if v14 == "synthesia" then
		v13 = "synthWhite"

		v2 = nil
		applySavedColorToUI(getSavedColorForTarget())
		refreshTargetSelector()
	elseif v14 == "keyHighlight" then
		v13 = "whiteKey"

		v2 = nil
		applySavedColorToUI(getSavedColorForTarget())
		refreshTargetSelector()
	end
end)

blackKey.MouseButton1Click:Connect(function()
	if clickSound then
		pcall(function()
			clickSound:Play()
		end)
	end

	commitPendingColor() -- inferred equivalent call

	if v14 == "synthesia" then
		v13 = "synthBlack"

		v2 = nil
		applySavedColorToUI(getSavedColorForTarget())
		refreshTargetSelector()
	elseif v14 == "keyHighlight" then
		v13 = "blackKey"

		v2 = nil
		applySavedColorToUI(getSavedColorForTarget())
		refreshTargetSelector()
	end
end)

OpenPianoColorWheel.Event:Connect(function(p)
	if p == "synthesia" then
		v14 = "synthesia"
		v13 = "synthWhite"
	elseif p == "keyHighlight" then
		v14 = "keyHighlight"
		v13 = "whiteKey"
	elseif p == "synthWhite" or p == "synthBlack" then
		v14 = "synthesia"
		v13 = p
	elseif p == "whiteKey" or p == "blackKey" then
		v14 = "keyHighlight"
		v13 = p
	elseif p == "pianoRollTile" or p == "pianoRollWhiteTile" or p == "pianoRollBlackTile" or p == "pianoRollImpact" then
		v14 = "pianoRoll2D"
		v13 = p
	else
		v14 = nil
		v13 = "visualizer"
	end

	v2 = nil
	applySavedColorToUI(getSavedColorForTarget())
	refreshTargetSelector()
	openPanel()
end)

textButton.MouseButton1Click:Connect(function()
	if clickSound then
		pcall(function()
			clickSound:Play()
		end)
	end

	closePanel()
end)

textButton3.MouseButton1Click:Connect(function()
	if clickSound then
		pcall(function()
			clickSound:Play()
		end)
	end

	closePanel()
end)

closePanel()