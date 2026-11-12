local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")

local v = {
	Resolution = { is = "Vector2", default = Vector2.new(1280, 720) },
	ScaleRange = { is = "NumberRange", default = NumberRange.new(0, 1e999) }
}

local v2 = {}
local v3 = {}

local function removeFromList(list, p) -- 4 equivalent calls inferred from this helper
	local index = table.find(list, p)

	if index then
		table.remove(list, index)
	end
end

local function update(uiScale)
	if not uiScale:IsA("UIScale") or uiScale:IsDescendantOf(StarterGui) then
		return
	end

	local v4 = {}

	for attributeName, v5 in pairs(v) do
		local v6 = uiScale:GetAttribute(attributeName)

		if typeof(v6) ~= v5.is then
			v6 = v5.default
			ClientDebugConfig.Warn(`no '{attributeName}' attribute found for {uiScale:GetFullName()}, using '{v5.default}' instead`)
		end

		v4[attributeName] = v6
	end

	if not uiScale.Parent then
		return
	end

	local guiBase2d = uiScale.Parent:FindFirstAncestorWhichIsA("GuiBase2d")
	local v5, camera

	if
		guiBase2d
		and (not guiBase2d:IsA("ScreenGui") or not guiBase2d.IgnoreGuiInset and guiBase2d.ScreenInsets ~= Enum.ScreenInsets.None)
	then
		v5 = guiBase2d.AbsoluteSize
		camera = guiBase2d
	else
		v5 = workspace.CurrentCamera.ViewportSize
		camera = workspace.CurrentCamera
	end

	local listener = v2[camera]

	if not listener then
		local v6 = nil
		v6 = {
			source = camera,
			scales = {},
			signal = camera:GetPropertyChangedSignal(camera:IsA("Camera") and "ViewportSize" or "AbsoluteSize"):Connect(function()
				for k in v6.scales do
					update(k)
				end
			end)
		}

		listener = v6
		v2[camera] = listener
	end

	local v6 = listener.scales[uiScale]

	if not v6 then
		v6 = { listener = listener, signals = {}, text_constraints = {} }

		listener.scales[uiScale] = v6
		v3[uiScale] = v6

		if guiBase2d then
			local function setupCleanup(uiTextSizeConstraint) -- 1 equivalent call inferred from this helper
				local ancestryChangedConnection = nil
				ancestryChangedConnection = uiTextSizeConstraint.AncestryChanged:Connect(function()
					if uiTextSizeConstraint:IsDescendantOf(guiBase2d) then
						return
					end

					removeFromList(v6.signals, ancestryChangedConnection) -- inferred equivalent call
					removeFromList(v6.text_constraints, uiTextSizeConstraint) -- inferred equivalent call
				end)

				table.insert(v6.signals, ancestryChangedConnection)
			end

			for _, uiTextSizeConstraint in guiBase2d:GetDescendants() do
				if not uiTextSizeConstraint:IsA("UITextSizeConstraint") then
					continue
				end

				table.insert(v6.text_constraints, uiTextSizeConstraint)

				uiTextSizeConstraint:SetAttribute(
					"__uitools_reference_range",
					NumberRange.new(uiTextSizeConstraint.MinTextSize, uiTextSizeConstraint.MaxTextSize)
				)
				local ancestryChangedConnection = nil
				ancestryChangedConnection = uiTextSizeConstraint.AncestryChanged:Connect(function()
					if uiTextSizeConstraint:IsDescendantOf(guiBase2d) then
						return
					end

					removeFromList(v6.signals, ancestryChangedConnection) -- inferred equivalent call
					removeFromList(v6.text_constraints, uiTextSizeConstraint) -- inferred equivalent call
				end)

				table.insert(v6.signals, ancestryChangedConnection)
			end

			table.insert(v6.signals, guiBase2d.DescendantAdded:Connect(function(uiTextSizeConstraint)
				if not uiTextSizeConstraint:IsA("UITextSizeConstraint") then
					return
				end

				table.insert(v6.text_constraints, uiTextSizeConstraint)

				local __uitools_reference_range = uiTextSizeConstraint:GetAttribute("__uitools_reference_range")

				if typeof(__uitools_reference_range) == "NumberRange" then
					uiTextSizeConstraint.MinTextSize = __uitools_reference_range.Min * uiScale.Scale
					uiTextSizeConstraint.MaxTextSize = __uitools_reference_range.Max * uiScale.Scale
				end

				setupCleanup(uiTextSizeConstraint) -- inferred equivalent call
			end))
		end
	end

	local y = v5.Y < v5.X and v5.Y or v5.X

	uiScale.Scale = math.clamp(
		1 / v4.Resolution.Y * math.clamp(1 / v4.Resolution.X * v5.X / (1 / v4.Resolution.Y * y), 0, 1) * y,
		v4.ScaleRange.Min,
		v4.ScaleRange.Max
	)

	if not plugin then
		for _, text_constraint in v6.text_constraints do
			local __uitools_reference_range = text_constraint:GetAttribute("__uitools_reference_range")

			if typeof(__uitools_reference_range) ~= "NumberRange" then
				continue
			end

			text_constraint.MinTextSize = __uitools_reference_range.Min * uiScale.Scale
			text_constraint.MaxTextSize = __uitools_reference_range.Max * uiScale.Scale
		end
	end
end

local function updateAll()
	for _, uiScale in CollectionService:GetTagged("UIScaleRuntimeObject") do
		if uiScale:IsA("UIScale") then
			update(uiScale)
		end
	end
end

updateAll()

local function cleanupScale(uiScale)
	if not uiScale:IsA("UIScale") then
		return
	end

	local v4 = v3[uiScale]

	if not v4 then
		return
	end

	uiScale.Scale = 1

	v3[uiScale] = nil

	if v4.signals then
		for _, signal in v4.signals do
			signal:Disconnect()
		end
	end

	v4.listener.scales[uiScale] = nil

	if next(v4.listener.scales) == nil then
		v4.listener.signal:Disconnect()
		v2[v4.listener.source] = nil
	end
end

CollectionService:GetInstanceAddedSignal("UIScaleRuntimeObject"):Connect(update)
CollectionService:GetInstanceRemovedSignal("UIScaleRuntimeObject"):Connect(cleanupScale)