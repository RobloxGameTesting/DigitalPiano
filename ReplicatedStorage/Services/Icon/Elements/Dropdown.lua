return function(object)
	local dropdown = Instance.new("Frame")
	dropdown.Name = "Dropdown"
	dropdown.AutomaticSize = Enum.AutomaticSize.XY
	dropdown.BackgroundTransparency = 1
	dropdown.BorderSizePixel = 0
	dropdown.AnchorPoint = Vector2.new(0.5, 0)
	dropdown.Position = UDim2.new(0.5, 0, 1, 10)
	dropdown.ZIndex = -2
	dropdown.ClipsDescendants = true
	dropdown.Parent = object.widget

	local dropdownCorner = Instance.new("UICorner")
	dropdownCorner.Name = "DropdownCorner"
	dropdownCorner.CornerRadius = UDim.new(0, 10)
	dropdownCorner.Parent = dropdown

	local dropdownScroller = Instance.new("ScrollingFrame")
	dropdownScroller.Name = "DropdownScroller"
	dropdownScroller.AutomaticSize = Enum.AutomaticSize.X
	dropdownScroller.BackgroundTransparency = 1
	dropdownScroller.BorderSizePixel = 0
	dropdownScroller.AnchorPoint = Vector2.new(0, 0)
	dropdownScroller.Position = UDim2.new(0, 0, 0, 0)
	dropdownScroller.ZIndex = -1
	dropdownScroller.ClipsDescendants = true
	dropdownScroller.Visible = true
	dropdownScroller.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	dropdownScroller.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	dropdownScroller.Active = false
	dropdownScroller.ScrollingEnabled = true
	dropdownScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dropdownScroller.ScrollBarThickness = 5
	dropdownScroller.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	dropdownScroller.ScrollBarImageTransparency = 0.8
	dropdownScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
	dropdownScroller.Selectable = false
	dropdownScroller.Active = true
	dropdownScroller.Parent = dropdown

	local dropdownPadding = Instance.new("UIPadding")
	dropdownPadding.Name = "DropdownPadding"
	dropdownPadding.PaddingTop = UDim.new(0, 8)
	dropdownPadding.PaddingBottom = UDim.new(0, 8)
	dropdownPadding.Parent = dropdownScroller

	local dropdownList = Instance.new("UIListLayout")
	dropdownList.Name = "DropdownList"
	dropdownList.FillDirection = Enum.FillDirection.Vertical
	dropdownList.SortOrder = Enum.SortOrder.LayoutOrder
	dropdownList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dropdownList.HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly
	dropdownList.Parent = dropdownScroller

	local dropdownJanitor = object.dropdownJanitor
	local iconModule = require(object.iconModule)
	object.dropdownChildAdded:Connect(function(object2)
		local _, v = object2:modifyTheme({
			{ "Widget", "BorderSize", 0 },
			{ "IconCorners", "CornerRadius", UDim.new(0, 4) },
			{ "Widget", "MinimumWidth", 190 },
			{ "Widget", "MinimumHeight", 56 },
			{ "IconLabel", "TextSize", 19 },
			{ "PaddingLeft", "Size", UDim2.fromOffset(25, 0) },
			{ "Notice", "Position", UDim2.new(1, -24, 0, 5) },
			{ "ContentsList", "HorizontalAlignment", Enum.HorizontalAlignment.Left },
			{ "Selection", "Size", UDim2.new(1, -8, 1, -8) },
			{ "Selection", "Position", UDim2.new(0, 4, 0, 4) }
		})

		task.defer(function()
			object2.joinJanitor:add(function()
				object2:removeModification(v)
			end)
		end)
	end)
	object.dropdownSet:Connect(function(list)
		for _, dropdownIcon in pairs(object.dropdownIcons) do
			iconModule.getIconByUID(dropdownIcon):destroy()
		end

		local _ = #list

		if type(list) == "table" then
			for _, item in pairs(list) do
				item:joinDropdown(object)
			end
		end
	end)

	local Utility = require(script.Parent.Parent.Utility)
	local function updateVisibility() -- 1 equivalent call inferred from this helper
		Utility.setVisible(dropdown, object.isSelected, "InternalDropdown")
	end
	dropdownJanitor:add(object.toggled:Connect(updateVisibility))
	updateVisibility() -- inferred equivalent call
	local count = 0
	local flag = false
	local function updateMaxIcons()
		count += 1

		if flag then
			return
		end

		local v = count
		flag = true
		task.defer(function()
			flag = false

			if count ~= v then
				updateMaxIcons()
			end
		end)

		local maxIcons = dropdown:GetAttribute("MaxIcons")

		if not maxIcons then
			return
		end

		local v2 = {}

		for _, guiObject in pairs(dropdownScroller:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				table.insert(v2, { guiObject, guiObject.AbsolutePosition.Y })
			end
		end

		table.sort(v2, function(a, b): boolean
			return a[2] < b[2]
		end)
		local total = 0
		local flag2 = false

		for i = 1, maxIcons do
			local v3 = v2[i]

			if not v3 then
				break
			end

			local v4 = v3[1]
			total += v4.AbsoluteSize.Y
			local widgetUID = v4:GetAttribute("WidgetUID")
			local v5 = widgetUID and iconModule.getIconByUID(widgetUID)

			if not v5 then
				continue
			end

			local nextSelectionUp

			if not flag2 then
				nextSelectionUp = object:getInstance("ClickRegion")
				flag2 = true
			end

			local instance = v5:getInstance("ClickRegion")
			instance.NextSelectionUp = nextSelectionUp
		end

		local v3 = total + dropdownPadding.PaddingTop.Offset + dropdownPadding.PaddingBottom.Offset
		dropdownScroller.Size = UDim2.fromOffset(0, v3)
	end
	dropdownJanitor:add(dropdownScroller:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateMaxIcons))
	dropdownJanitor:add(dropdownScroller.ChildAdded:Connect(updateMaxIcons))
	dropdownJanitor:add(dropdownScroller.ChildRemoved:Connect(updateMaxIcons))
	dropdownJanitor:add(dropdown:GetAttributeChangedSignal("MaxIcons"):Connect(updateMaxIcons))
	dropdownJanitor:add(object.childThemeModified:Connect(updateMaxIcons))
	updateMaxIcons()

	return dropdown
end