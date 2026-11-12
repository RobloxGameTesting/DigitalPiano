local GamepadService = game:GetService("GamepadService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Gamepad = {}
local v = nil

function Gamepad.start(p)
	v = p
	v.highlightKey = Enum.KeyCode.DPadUp
	v.highlightIcon = false

	task.delay(1, function()
		local iconsDictionary = v.iconsDictionary
		local function getIconFromSelectedObject() -- 2 equivalent calls inferred from this helper
			local selectedObject = GuiService.SelectedObject
			local correspondingIconUID = selectedObject and selectedObject:GetAttribute("CorrespondingIconUID")
			return correspondingIconUID and iconsDictionary[correspondingIconUID]
		end

		local v2 = nil

		local v3 = false
		local v4 = false
		require(script.Parent.Parent.Utility)
		local Selection = require(script.Parent.Parent.Elements.Selection)
		local function updateSelectedObject()
			local iconFromSelectedObject = getIconFromSelectedObject() -- inferred equivalent call
			local gamepadEnabled = UserInputService.GamepadEnabled

			if iconFromSelectedObject then
				if gamepadEnabled then
					local instance = iconFromSelectedObject:getInstance("ClickRegion")
					local selection = iconFromSelectedObject.selection

					if not selection then
						selection = iconFromSelectedObject.janitor:add(Selection(v))
						selection:SetAttribute("IgnoreVisibilityUpdater", true)
						selection.Parent = iconFromSelectedObject.widget
						iconFromSelectedObject.selection = selection
						iconFromSelectedObject:refreshAppearance(selection)
					end

					instance.SelectionImageObject = selection.Selection
				end

				if v2 and v2 ~= iconFromSelectedObject then
					v2:setIndicator()
				end

				local buttonB

				if gamepadEnabled and not (v4 or iconFromSelectedObject.parentIconUID) then
					buttonB = Enum.KeyCode.ButtonB
				end

				v2 = iconFromSelectedObject
				v.lastHighlightedIcon = iconFromSelectedObject
				iconFromSelectedObject:setIndicator(buttonB)
			else
				local highlightKey

				if gamepadEnabled and not v3 then
					highlightKey = v.highlightKey
				end

				if not v2 then
					v2 = Gamepad.getIconToHighlight()
				end

				if highlightKey == v.highlightKey then
					v3 = true
				end

				if v2 then
					v2:setIndicator(highlightKey)
				end
			end
		end
		GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(updateSelectedObject)

		local function checkGamepadEnabled() -- 1 equivalent call inferred from this helper
			if not UserInputService.GamepadEnabled then
				v3 = false
				v4 = false
			end

			updateSelectedObject()
		end
		UserInputService:GetPropertyChangedSignal("GamepadEnabled"):Connect(checkGamepadEnabled)
		checkGamepadEnabled() -- inferred equivalent call
		UserInputService.InputBegan:Connect(function(input, _)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if getIconFromSelectedObject() then -- inferred equivalent call
					GuiService.SelectedObject = nil
				end
			else
				if input.KeyCode ~= v.highlightKey then
					return
				end

				local iconToHighlight = Gamepad.getIconToHighlight()

				if iconToHighlight then
					if GamepadService.GamepadCursorEnabled then
						task.wait(0.2)
						GamepadService:DisableGamepadCursor()
					end

					GuiService.SelectedObject = iconToHighlight:getInstance("ClickRegion")
				end
			end
		end)
	end)
end

function Gamepad.getIconToHighlight()
	local iconsDictionary = v.iconsDictionary
	local iconToHighlight = v.highlightIcon or v.lastHighlightedIcon

	if iconToHighlight then
		return iconToHighlight
	end

	local x = nil

	for _, v2 in pairs(iconsDictionary) do
		if v2.parentIconUID then
			continue
		end

		local x2 = v2.widget.AbsolutePosition.X

		if not (not x or x2 < x) then
			continue
		end

		x = v2.widget.AbsolutePosition.X
		iconToHighlight = v2
	end

	return iconToHighlight
end

function Gamepad.registerButton(selectedObject)
	local v2 = false
	selectedObject.InputBegan:Connect(function(_)
		v2 = true
		task.wait()
		task.wait()
		v2 = false
	end)
	local inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
		task.wait()

		if input.KeyCode == Enum.KeyCode.ButtonA and v2 then
			task.wait(0.2)
			GamepadService:DisableGamepadCursor()
			GuiService.SelectedObject = selectedObject
		else
			local v3 = GuiService.SelectedObject == selectedObject

			if table.find({ "ButtonB", "ButtonSelect" }, input.KeyCode.Name) and v3 then
				GuiService.SelectedObject = nil
			end
		end
	end)
	selectedObject.Destroying:Once(function()
		inputBeganConnection:Disconnect()
	end)
end

return Gamepad