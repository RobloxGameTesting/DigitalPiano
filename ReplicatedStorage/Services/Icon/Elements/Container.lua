return function(data)
	local GuiService = game:GetService("GuiService")
	local isOldTopbar = data.isOldTopbar
	local v = {}
	local guiInset = GuiService:GetGuiInset()
	local isTenFootInterface = GuiService:IsTenFootInterface()
	local v2 = isOldTopbar and 12 or guiInset.Y - 46
	local v3 = isTenFootInterface and 10 or v2
	local topbarStandard = Instance.new("ScreenGui")
	topbarStandard:SetAttribute("StartInset", v3)
	topbarStandard.Name = "TopbarStandard"
	topbarStandard.Enabled = true
	topbarStandard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	topbarStandard.IgnoreGuiInset = true
	topbarStandard.ResetOnSpawn = false
	topbarStandard.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
	v[topbarStandard.Name] = topbarStandard
	topbarStandard.DisplayOrder = data.baseDisplayOrder
	data.baseDisplayOrderChanged:Connect(function()
		topbarStandard.DisplayOrder = data.baseDisplayOrder
	end)

	local holders = Instance.new("Frame")
	local v4 = isOldTopbar and 2 or 0
	local v5

	if isTenFootInterface then
		v4 += 13
		v5 = 50
	else
		v5 = -2
	end

	holders.Name = "Holders"
	holders.BackgroundTransparency = 1
	holders.Position = UDim2.new(0, 0, 0, v4)
	holders.Size = UDim2.new(1, 0, 1, v5)
	holders.Visible = true
	holders.ZIndex = 1
	holders.Parent = topbarStandard

	local topbarCentered = topbarStandard:Clone()
	local holders2 = topbarCentered.Holders
	local GuiService2 = game:GetService("GuiService")
	local function updateCenteredHoldersHeight() -- 1 equivalent call inferred from this helper
		holders2.Size = UDim2.new(1, 0, 0, GuiService2.TopbarInset.Height + v5)
	end
	topbarCentered.Name = "TopbarCentered"
	topbarCentered.ScreenInsets = Enum.ScreenInsets.None
	data.baseDisplayOrderChanged:Connect(function()
		topbarCentered.DisplayOrder = data.baseDisplayOrder
	end)
	v[topbarCentered.Name] = topbarCentered
	GuiService2:GetPropertyChangedSignal("TopbarInset"):Connect(updateCenteredHoldersHeight)
	updateCenteredHoldersHeight() -- inferred equivalent call
	local clone = topbarStandard:Clone()
	clone.Name ..= "Clipped"
	clone.DisplayOrder += 1
	data.baseDisplayOrderChanged:Connect(function()
		clone.DisplayOrder = data.baseDisplayOrder + 1
	end)
	v[clone.Name] = clone

	local clone2 = topbarCentered:Clone()
	clone2.Name ..= "Clipped"
	clone2.DisplayOrder += 1
	data.baseDisplayOrderChanged:Connect(function()
		clone2.DisplayOrder = data.baseDisplayOrder + 1
	end)
	v[clone2.Name] = clone2

	if isOldTopbar then
		task.defer(function()
			local function decideToHideTopbar() -- 1 equivalent call inferred from this helper
				if GuiService2.MenuIsOpen then
					data.setTopbarEnabled(false, true)
				else
					data.setTopbarEnabled()
				end
			end
			GuiService2:GetPropertyChangedSignal("MenuIsOpen"):Connect(decideToHideTopbar)
			decideToHideTopbar() -- inferred equivalent call
		end)
	end

	local left = Instance.new("ScrollingFrame")
	left:SetAttribute("IsAHolder", true)
	left.Name = "Left"
	left.Position = UDim2.fromOffset(v3, 0)
	left.Size = UDim2.new(1, -24, 1, 0)
	left.BackgroundTransparency = 1
	left.Visible = true
	left.ZIndex = 1
	left.Active = false
	left.ClipsDescendants = true
	left.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	left.CanvasSize = UDim2.new(0, 0, 1, -1)
	left.AutomaticCanvasSize = Enum.AutomaticSize.X
	left.ScrollingDirection = Enum.ScrollingDirection.X
	left.ScrollBarThickness = 0
	left.BorderSizePixel = 0
	left.Selectable = false
	left.ScrollingEnabled = false
	left.ElasticBehavior = Enum.ElasticBehavior.Never
	left.Parent = holders

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, v3)
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	uiListLayout.Parent = left

	local center = left:Clone()
	center.ScrollingEnabled = false
	center.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	center.Name = "Center"
	center.Parent = holders2

	local right = left:Clone()
	right.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	right.Name = "Right"
	right.AnchorPoint = Vector2.new(1, 0)
	right.Position = UDim2.new(1, -12, 0, 0)
	right.Parent = holders

	return v
end