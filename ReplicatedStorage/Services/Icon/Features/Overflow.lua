local Overflow = {}
local childrenByName = {}
local v = {}
local iconsDictionary = nil
local CurrentCamera = workspace.CurrentCamera
local v2 = {}
local uidSet = {}
local Utility = require(script.Parent.Parent.Utility)
local v3 = nil

function Overflow.start(p)
	v3 = p
	iconsDictionary = v3.iconsDictionary
	local v4 = nil

	for _, v5 in pairs(v3.container) do
		if v4 == nil and v5.ScreenInsets == Enum.ScreenInsets.TopbarSafeInsets then
			v4 = v5
		end

		for _, child in pairs(v5.Holders:GetChildren()) do
			if child:GetAttribute("IsAHolder") then
				childrenByName[child.Name] = child
			end
		end
	end

	local v5 = false
	local stagger = Utility.createStagger(0.1, function(p2)
		if not v5 then
			return
		end

		if not p2 then
			Overflow.updateAvailableIcons("Center")
		end

		Overflow.updateBoundary("Left")
		Overflow.updateBoundary("Right")
	end)
	task.delay(1, function()
		v5 = true
		stagger()
	end)
	v3.iconAdded:Connect(stagger)
	v3.iconRemoved:Connect(stagger)
	v3.iconChanged:Connect(stagger)
	CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		stagger(true)
	end)
	v4:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		stagger(true)
	end)
end

function Overflow.getWidth(p, _)
	local widget = p.widget
	return widget:GetAttribute("TargetWidth") or widget.AbsoluteSize.X
end

function Overflow.getAvailableIcons(p)
	return v[p] or Overflow.updateAvailableIcons(p)
end

function Overflow.updateAvailableIcons(p)
	local _uiListLayout = childrenByName[p].UIListLayout
	local result = {}
	local count = 0

	for _, v4 in pairs(iconsDictionary) do
		local parentIconUID = v4.parentIconUID
		local v5 = not parentIconUID or uidSet[parentIconUID]
		local v6 = uidSet[v4.UID]

		if not v5 or v4.alignment ~= p or v6 then
			continue
		end

		table.insert(result, v4)
		count += 1
	end

	if count <= 0 then
		return {}
	end

	table.sort(result, function(a, b)
		local layoutOrder = a.widget.LayoutOrder
		local layoutOrder2 = b.widget.LayoutOrder
		local parentIconUID = a.parentIconUID
		local parentIconUID2 = b.parentIconUID

		if parentIconUID == parentIconUID2 then
			if layoutOrder < layoutOrder2 then
				return true
			end

			return not (layoutOrder2 < layoutOrder) and a.widget.AbsolutePosition.X < b.widget.AbsolutePosition.X
		end

		if parentIconUID2 then
			return false
		end

		if parentIconUID then
			return true
		end
	end)

	v[p] = result
	return result
end

function Overflow.getRealXPositions(p, list)
	local v4 = p == "Left"
	local v5 = childrenByName[p]
	local x = v5.AbsolutePosition.X
	local x2 = v5.AbsoluteSize.X
	local offset = v5.UIListLayout.Padding.Offset
	local v6 = v4 and x or x + x2
	local realXPositions = {}

	if v4 then
		Utility.reverseTable(list)
	end

	for i = #list, 1, -1 do
		local item = list[i]
		local width = Overflow.getWidth(item)

		if not v4 then
			v6 -= width
		end

		realXPositions[item.UID] = v6

		if v4 then
			v6 += width
		end

		v6 += v4 and offset or -offset
	end

	return realXPositions
end

function Overflow.updateBoundary(p)
	local v4 = childrenByName[p]
	local uiListLayout = v4.UIListLayout
	local x = v4.AbsolutePosition.X
	local v5 = v4.AbsoluteSize.X
	local offset = uiListLayout.Padding.Offset
	local offset2 = uiListLayout.Padding.Offset

	local v6 = Overflow.updateAvailableIcons(p)
	local total = 0
	local count = 0

	for _, v7 in pairs(v6) do
		total += Overflow.getWidth(v7) + offset2
		count += 1
	end

	if count <= 0 then
		return
	end

	local v7 = p == "Central"
	local v8 = p == "Left"
	local v9 = not v8
	local v10 = v2[p]

	if not v10 and not v7 and #v6 > 0 then
		v10 = v3.new()
		v10:setImage(6069276526, "Deselected")
		v10:setName("Overflow" .. p)
		v10:setOrder(v8 and -9999999 or 9999999)
		v10:setAlignment(p)
		v10:autoDeselect(false)
		v10.isAnOverflow = true

		v10:select("OverflowStart", v10)
		v10:setEnabled(false)
		v2[p] = v10
		uidSet[v10.UID] = true
	end

	local v11 = p == "Left" and "Right" or "Left"
	local v12 = Overflow.updateAvailableIcons(v11)
	local v13 = v8 and v12[1] or v9 and v12[#v12]
	local v14 = v2[v11]
	local v15

	if v8 then
		v15 = x + v5 or x
	else
		v15 = x
	end

	if v13 then
		local _widget = v13.widget
		local v16 = Overflow.getRealXPositions(v11, v12)[v13.UID]
		local width = Overflow.getWidth(v13)
		v15 = v8 and v16 - offset or v16 + width + offset
	end

	local availableIcons = Overflow.getAvailableIcons("Center")
	local availableIcon = availableIcons[v8 and 1 or #availableIcons]

	if availableIcon and not availableIcon.hasRelocatedInOverflow then
		local v16 = v8 and v6[#v6] or v9 and v6[1]
		local x2 = availableIcon.widget.AbsolutePosition.X
		local v17 = v16.widget.AbsolutePosition.X
		local width = Overflow.getWidth(v16)
		local v18 = v8 and x2 - offset or x2 + Overflow.getWidth(availableIcon) + offset
		v17 = v8 and v17 + width or v17

		if v8 then
			if v18 < v17 then
				availableIcon:align("Left")
				availableIcon.hasRelocatedInOverflow = true
			end
		elseif v9 and v17 < v18 then
			availableIcon:align("Right")
			availableIcon.hasRelocatedInOverflow = true
		end
	end

	if v10 then
		local instance = v10:getInstance("Menu")
		local v16 = x + v5

		if v14 then
			local x2 = v14.widget.AbsolutePosition.X
			local width = Overflow.getWidth(v14)
			local v17 = v8 and x2 - offset or x2 + width + offset
			local instance2 = v14:getInstance("Menu")
			local v18 = instance.AbsoluteCanvasSize.X >= instance2.AbsoluteCanvasSize.X

			local v19 = x + v5 / 2
			local v20 = v8 and v19 - offset / 2 or v19 + offset / 2

			if v18 then
				v20 = v17
			end

			v5 = v8 and v20 - x or v16 - v20
		end

		local maxWidth = instance and instance:GetAttribute("MaxWidth")
		local rounded = Utility.round(v5)

		if instance and maxWidth ~= rounded then
			instance:SetAttribute("MaxWidth", rounded)
		end
	end

	local realXPositions = Overflow.getRealXPositions(p, v6)
	local v16 = false

	for i = #v6, 1, -1 do
		local v17 = v6[i]
		local width = Overflow.getWidth(v17)
		local realXPosition = realXPositions[v17.UID]

		if v8 and v15 <= realXPosition + width or v9 and realXPosition <= v15 then
			v16 = true
		end
	end

	for i = #v6, 1, -1 do
		local v17 = v6[i]

		if uidSet[v17.UID] then
			continue
		end

		if v16 and not v17.parentIconUID then
			v17:joinMenu(v10)
		elseif not v16 and v17.parentIconUID then
			v17:leave()
		end
	end

	if v10.isEnabled ~= v16 then
		v10:setEnabled(v16)
	end

	if v10.isEnabled and not v10.overflowAlreadyOpened then
		v10.overflowAlreadyOpened = true
		v10:select()
	end
end

return Overflow