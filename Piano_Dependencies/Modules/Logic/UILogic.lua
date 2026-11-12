local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local TweenService2 = game:GetService("TweenService")
TweenService = TweenService2
local CurrentCamera = workspace.CurrentCamera
local UILogic = {}

local color = Color3.fromRGB(102, 255, 102)
local v = color
local v2 = color
local color2 = Color3.fromRGB(0, 115, 0)
local color3 = Color3.fromRGB(150, 150, 150)
local color4 = Color3.fromRGB(0, 0, 0)
local color5 = Color3.fromRGB(255, 255, 255)

local v3 = {}
local v4 = {}
local v5 = {}

local function getActiveColorForNote(p) -- 1 equivalent call inferred from this helper
	return if IsBlack(p) then v2 else v
end

local function getPracticeGuideColorAttribute(instance, attributeName) -- 4 equivalent calls inferred from this helper
	local attribute = instance and instance:GetAttribute(attributeName)
	return if typeof(attribute) == "Color3" then attribute else nil
end

local function getPracticeGuideBoolAttribute(uiGradient, attributeName) -- 1 equivalent call inferred from this helper
	local attribute = uiGradient and uiGradient:GetAttribute(attributeName)
	return if typeof(attribute) == "boolean" then attribute else nil
end

local function restorePracticeGuideTextState(folder)
	if not folder then
		return
	end

	if folder:IsA("TextButton") or folder:IsA("TextLabel") or folder:IsA("TextBox") then
		local practiceGuideColorAttribute = getPracticeGuideColorAttribute(folder, "PracticeGuideBaseTextColor") -- inferred equivalent call

		if practiceGuideColorAttribute then
			folder.TextColor3 = practiceGuideColorAttribute
			folder:SetAttribute("PracticeGuideBaseTextColor", nil)
		end
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if not (descendant:IsA("TextButton") or descendant:IsA("TextLabel") or descendant:IsA("TextBox")) then
			continue
		end

		local practiceGuideColorAttribute = getPracticeGuideColorAttribute(descendant, "PracticeGuideBaseTextColor") -- inferred equivalent call

		if not practiceGuideColorAttribute then
			continue
		end

		descendant.TextColor3 = practiceGuideColorAttribute
		descendant:SetAttribute("PracticeGuideBaseTextColor", nil)
	end
end

local function clearPracticeGuideVisualAttributes(guiObject)
	if not guiObject then
		return
	end

	guiObject:SetAttribute("PracticeGuideBaseBackgroundColor", nil)
	guiObject:SetAttribute("PracticeGuideBaseImageColor", nil)
	guiObject:SetAttribute("PracticeGuideTouched", nil)
	guiObject:SetAttribute("PracticeGuideActive", nil)
	guiObject:SetAttribute("PianoGuiPressedActive", nil)

	for _, uiGradient in ipairs(guiObject:GetChildren()) do
		if uiGradient:IsA("UIGradient") then
			uiGradient:SetAttribute("PracticeGuideBaseGradientEnabled", nil)
		end
	end
end

local function captureGuiVisual(guiObject)
	if not guiObject or v5[guiObject] then
		return
	end

	local gradients = {}

	for _, uiGradient in ipairs(guiObject:GetChildren()) do
		if not uiGradient:IsA("UIGradient") then
			continue
		end

		local enabled = getPracticeGuideBoolAttribute(uiGradient, "PracticeGuideBaseGradientEnabled") -- inferred equivalent call

		if enabled == nil or not enabled then
			enabled = uiGradient.Enabled
		end

		local v6 = {
			Gradient = uiGradient,
			Enabled = enabled,
			Color = uiGradient.Color,
			Transparency = uiGradient.Transparency
		}
		table.insert(gradients, v6)
	end

	local practiceGuideColorAttribute = getPracticeGuideColorAttribute(guiObject, "PracticeGuideBaseBackgroundColor") -- inferred equivalent call
	local practiceGuideColorAttribute2 = getPracticeGuideColorAttribute(guiObject, "PracticeGuideBaseImageColor") -- inferred equivalent call
	local backgroundColor

	if guiObject:IsA("GuiObject") then
		backgroundColor = practiceGuideColorAttribute or guiObject.BackgroundColor3 or nil
	end

	local imageColor

	if guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
		imageColor = practiceGuideColorAttribute2 or guiObject.ImageColor3 or nil
	end

	v5[guiObject] = {
		BackgroundColor3 = backgroundColor,
		ImageColor3 = imageColor,
		Gradients = gradients
	}
end

local function restoreGuiVisual(guiObject): boolean
	local v6 = guiObject and v5[guiObject]

	if not v6 then
		return false
	end

	if v6.BackgroundColor3 and guiObject:IsA("GuiObject") then
		guiObject.BackgroundColor3 = v6.BackgroundColor3
	end

	if v6.ImageColor3 and (guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel")) then
		guiObject.ImageColor3 = v6.ImageColor3
	end

	for _, gradient in ipairs(v6.Gradients) do
		local gradient2 = gradient.Gradient

		if not (gradient2 and gradient2.Parent) then
			continue
		end

		gradient2.Enabled = gradient.Enabled
		gradient2.Color = gradient.Color
		gradient2.Transparency = gradient.Transparency
	end

	restorePracticeGuideTextState(guiObject)
	clearPracticeGuideVisualAttributes(guiObject)
	v5[guiObject] = nil
	return true
end

local function setGuiColor(guiObject, p, p2) -- 10 equivalent calls inferred from this helper
	if not guiObject then
		return
	end

	if p2 then
		captureGuiVisual(guiObject)

		if guiObject:IsA("GuiObject") then
			guiObject:SetAttribute("PianoGuiPressedActive", true)
		end

		for _, uiGradient in ipairs(guiObject:GetChildren()) do
			if uiGradient:IsA("UIGradient") then
				uiGradient.Enabled = false
			end
		end
	end

	if guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
		guiObject.ImageColor3 = p
	elseif guiObject:IsA("TextButton") or guiObject:IsA("TextLabel") or guiObject:IsA("Frame") then
		guiObject.BackgroundColor3 = p
	elseif guiObject:IsA("GuiObject") then
		guiObject.BackgroundColor3 = p
	end
end

function IsBlack(p): boolean
	local v6 = p % 12
	return v6 == 2 or v6 == 4 or v6 == 7 or v6 == 9 or v6 == 11
end

function UILogic.FinishNote(instance, p)
	if not p then
		return
	end

	v3[p] = math.max((v3[p] or 1) - 1, 0)

	if v3[p] == 0 then
		v4[p] = nil
		local child = instance:FindFirstChild((tostring(p)))

		if child then
			child:SetAttribute("PianoGuiPressedActive", nil)
		end

		if child and not restoreGuiVisual(child) then
			if IsBlack(p) then
				setGuiColor(child, color4) -- inferred equivalent call
			else
				setGuiColor(child, color5) -- inferred equivalent call
			end
		end
	end
end

function UILogic.PlayNote(instance, p)
	if not p then
		return
	end

	v3[p] = (v3[p] or 0) + 1
	v4[p] = tick()

	local child = instance:FindFirstChild((tostring(p)))

	if child then
		setGuiColor(child, getActiveColorForNote(p), true) -- inferred equivalent call
	end
end

local function resetKeyFrameColors(instance)
	if not instance then
		return
	end

	for _, child in ipairs(instance:GetChildren()) do
		local name = tonumber(child.Name)

		if name then
			child:SetAttribute("PianoGuiPressedActive", nil)
		end

		if not name or restoreGuiVisual(child) then
			continue
		end

		if IsBlack(name) then
			setGuiColor(child, color4) -- inferred equivalent call
		else
			setGuiColor(child, color5) -- inferred equivalent call
		end
	end
end

function UILogic.ClearAllNotes(p)
	resetKeyFrameColors(p)
	v3 = {}
	v4 = {}
end

function UILogic.ClearAllKeyFrames(...)
	for i = 1, select("#", ...) do
		resetKeyFrameColors((select)(i, ...))
	end

	v3 = {}
	v4 = {}
end

function UILogic.CleanupStuckNotes(instance, value)
	local now = tick()
	local v6 = value or 5
	local v7 = {}

	for k, v8 in pairs(v4) do
		if v6 < now - v8 then
			table.insert(v7, k)
		end
	end

	for _, v8 in ipairs(v7) do
		v3[v8] = 0
		v4[v8] = nil
		local child = instance:FindFirstChild((tostring(v8)))

		if child then
			child:SetAttribute("PianoGuiPressedActive", nil)
		end

		if not child or restoreGuiVisual(child) then
			continue
		end

		if IsBlack(v8) then
			setGuiColor(child, color4) -- inferred equivalent call
		else
			setGuiColor(child, color5) -- inferred equivalent call
		end
	end

	if #v7 > 0 then
		ClientDebugConfig.Warn("[UILogic] Auto-cleaned stuck notes:", table.concat(v7, ", "))
	end
end

function UILogic:ShowHideFrame()
	self.Visible = not self.Visible
end

function UILogic:ForceShowFrame()
	self.Visible = true
end

function UILogic:UpdateTextLabel(p)
	self.Text = tostring(p)
end

function UILogic.SetActiveKeyHighlightColors(p, p2)
	if typeof(p) == "Color3" then
		v = p
	end

	if typeof(p2) == "Color3" then
		v2 = p2
	end
end

function UILogic.GetActiveKeyHighlightColors()
	return v, v2
end

function UILogic.GlowCheck(guiObject, p)
	if p == true then
		setGuiColor(guiObject, color) -- inferred equivalent call
	else
		setGuiColor(guiObject, color3) -- inferred equivalent call
	end
end

function UILogic.ShiftFlash(guiObject, p)
	if p == true then
		setGuiColor(guiObject, color) -- inferred equivalent call
	else
		setGuiColor(guiObject, color2) -- inferred equivalent call
	end
end

function UILogic:UpdateCanvasSize(p)
	self.CanvasSize = UDim2.new(0, p.AbsoluteContentSize.X, 0, p.AbsoluteContentSize.Y + 20)
end

return UILogic