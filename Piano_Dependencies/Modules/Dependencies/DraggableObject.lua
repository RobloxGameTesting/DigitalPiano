local newUDim2 = UDim2.new

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local v = {
	Bar = true,
	Fill = true,
	Knob = true,
	Minus = true,
	Plus = true,
	Slider = true,
	Speed = true,
	Thumb = true,
	Track = true
}

local DraggableObject = {}
DraggableObject.__index = DraggableObject

local function clamp(value, min, max) -- 2 equivalent calls inferred from this helper
	if max < min then
		max, min = min, max
	end

	return (math.clamp(value, min, max))
end

local function clampAxis(value, p, p2) -- 2 equivalent calls inferred from this helper
	if p <= p2 - 16 then
		return clamp(value, 8, p2 - p - 8) -- inferred equivalent call
	end

	return clamp(value, 56 - p, p2 - 56) -- inferred equivalent call
end

local function getViewportSize() -- 1 equivalent call inferred from this helper
	local currentCamera = workspace.CurrentCamera

	return if currentCamera then currentCamera.ViewportSize else nil
end

local function isSliderLikeName(name): boolean
	if v[name] then
		return true
	end

	local v2 = string.lower(name)
	return v2:find("slider", 1, true) ~= nil or v2:find("thumb", 1, true) ~= nil or v2:find("knob", 1, true) ~= nil
end

local function isInteractiveDragTarget(instance, ancestor): boolean
	while instance and instance ~= ancestor do
		if instance:IsA("GuiButton") or instance:IsA("TextBox") or instance:IsA("ScrollingFrame") then
			return true
		end

		if instance:IsA("GuiObject") and isSliderLikeName(instance.Name) then
			return true
		end

		instance = instance.Parent
	end

	return false
end

local function shouldStartDrag(object, input)
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not (playerGui and input.Position) then
		return true
	end

	local success, result = pcall(function()
		return playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
	end)

	if not success then
		return true
	end

	local v2 = false

	for _, v3 in ipairs(result) do
		if v3 == object then
			v2 = true
		elseif v3:IsDescendantOf(object) and isInteractiveDragTarget(v3, object) then
			return false
		end
	end

	return v2 or true
end

local function getClampedPosition(object, position, absolutePosition, p)
	local viewportSize = getViewportSize() -- inferred equivalent call

	if not (viewportSize and absolutePosition) then
		return newUDim2(position.X.Scale, position.X.Offset + p.X, position.Y.Scale, position.Y.Offset + p.Y)
	end

	local absoluteSize = object.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return newUDim2(position.X.Scale, position.X.Offset + p.X, position.Y.Scale, position.Y.Offset + p.Y)
	end

	local v2 = absolutePosition.X + p.X
	local v3 = absolutePosition.Y + p.Y
	local v4 = clampAxis(v2, absoluteSize.X, viewportSize.X) -- inferred equivalent call
	local v5 = clampAxis(v3, absoluteSize.Y, viewportSize.Y) -- inferred equivalent call

	return newUDim2(
		position.X.Scale,
		position.X.Offset + p.X + (v4 - v2),
		position.Y.Scale,
		position.Y.Offset + p.Y + (v5 - v3)
	)
end

function DraggableObject.new(object)
	local v2 = {
		["Object"] = object,
		DragStarted = nil,
		DragEnded = nil,
		Dragged = nil,
		Dragging = false
	}

	setmetatable(v2, DraggableObject)

	return v2
end

function DraggableObject:Enable()
	local object = self.Object
	local v2 = nil
	local position = nil
	local position2 = nil
	local absolutePosition = nil
	local flag = false

	local function update(input) -- 1 equivalent call inferred from this helper
		local v3 = input.Position - position
		local clampedPosition = getClampedPosition(object, position2, absolutePosition, v3)
		object.Position = clampedPosition

		return clampedPosition
	end

	self.InputBegan = object.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if not shouldStartDrag(object, input) then
				return
			end

			flag = true

			local changedConnection = nil
			changedConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and (self.Dragging or flag) then
					self.Dragging = false
					changedConnection:Disconnect()

					if self.DragEnded and not flag then
						self.DragEnded()
					end

					flag = false
				end
			end)
		end
	end)

	self.InputChanged = object.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			v2 = input
		end
	end)

	self.InputChanged2 = UserInputService.InputChanged:Connect(function(input)
		if object.Parent == nil then
			self:Disable()
			return
		end

		if flag then
			flag = false

			if self.DragStarted then
				self.DragStarted()
			end

			self.Dragging = true
			position = input.Position
			position2 = object.Position
			absolutePosition = object.AbsolutePosition
		end

		if input == v2 and self.Dragging then
			local position3 = update(input) -- inferred equivalent call

			if self.Dragged then
				self.Dragged(position3)
			end
		end
	end)
end

function DraggableObject:Disable()
	if self.InputBegan then
		self.InputBegan:Disconnect()
		self.InputBegan = nil
	end

	if self.InputChanged then
		self.InputChanged:Disconnect()
		self.InputChanged = nil
	end

	if self.InputChanged2 then
		self.InputChanged2:Disconnect()
		self.InputChanged2 = nil
	end

	if self.Dragging then
		self.Dragging = false

		if self.DragEnded then
			self.DragEnded()
		end
	end
end

return DraggableObject