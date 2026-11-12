local Players = game:GetService("Players")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
require(MerchBooth.Reducers.reducer)
local assets = require(MerchBooth.assets)
require(MerchBooth.types)
local enums = require(MerchBooth.enums)
local generateDummyWithItem = require(MerchBooth.Modules.generateDummyWithItem)
local ItemViewport = require(script.Parent.ItemViewport)

local extended = Roact.Component:extend("ItemPreview")

local function getPreviewImage(itemInfo) -- 1 equivalent call inferred from this helper
	if not itemInfo then
		return assets.EmptyShop
	end

	if type(itemInfo.thumbnailImage) == "string" and itemInfo.thumbnailImage ~= "" then
		return itemInfo.thumbnailImage
	end

	local iconId = tonumber(itemInfo.iconId) or tonumber(itemInfo.assetId) or 0

	if iconId > 0 then
		return "rbxthumb://type=Asset&id=" .. tostring(iconId) .. "&w=420&h=420"
	end

	return assets.EmptyShop
end

local function getBadgeText(itemInfo)
	local displayType = tostring(itemInfo.displayType or itemInfo.category or "Item")

	if displayType == "Tag" then
		return "TITLE"
	elseif displayType == "Theme" then
		return "UI"
	elseif displayType == "Effect" then
		return "FX"
	elseif displayType == "Storage" then
		return "+10"
	end

	return tostring(itemInfo.title or "IT"):sub(1, 2):upper()
end

function extended:init()
	self:setState({ previewMode = enums.PreviewModes.Object })

	function self.toggleTryOn()
		self:setState(function(p)
			local previewMode

			if p.previewMode == enums.PreviewModes.Character then
				previewMode = enums.PreviewModes.Object
			else
				previewMode = enums.PreviewModes.Character
			end

			return { previewMode = previewMode }
		end)
	end
end

function extended:didMount()
	local props = self.props
	self.isMounted = true

	local itemInfo = props.itemInfo

	if itemInfo and itemInfo.productType == Enum.InfoType.Asset then
		task.spawn(function()
			local previewAvatar = generateDummyWithItem(itemInfo, Players.LocalPlayer)

			if self.isMounted then
				self:setState({ previewAvatar = previewAvatar })
			end
		end)
	end
end

function extended.render(props)
	local props2 = props.props
	local state = props.state

	local v = props2.config.textSize * 2
	local itemInfo = props2.itemInfo
	local v2 = itemInfo and itemInfo.viewportObject ~= nil
	local v3

	if itemInfo then
		if itemInfo.productType == Enum.InfoType.Asset then
			v3 = false
		else
			v3 = not v2
		end
	else
		v3 = itemInfo
	end

	local v4

	if itemInfo then
		if itemInfo.purchaseKind == "ProfileStore" then
			v4 = not v2 and (type(itemInfo.thumbnailImage) ~= "string" or itemInfo.thumbnailImage == "")
		else
			v4 = false
		end
	else
		v4 = itemInfo
	end

	local createElement = Roact.createElement
	local v5 = {
		LayoutOrder = props2.layoutOrder,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}

	local v6 = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}),
		BadgePreview = v4 and Roact.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = itemInfo.color or props2.config.buttonColor,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0
		}, {
			Corner = Roact.createElement("UICorner", { CornerRadius = props2.config.cornerRadius }),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.72
			}),
			Text = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.32),
				BackgroundTransparency = 1,
				Text = getBadgeText(itemInfo),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = props2.config.titleFont
			})
		}),
		ImagePreview = 0,
		ItemViewport = 0,
		TryOn = 0
	}

	local imagePreview = v3 and not v4

	if imagePreview then
		imagePreview = Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = getPreviewImage(props2.itemInfo), -- inferred equivalent call
			ScaleType = Enum.ScaleType.Fit
		})
	end

	v6.ImagePreview = imagePreview

	v6.ItemViewport = not v3 and Roact.createElement(ItemViewport, {
		layoutOrder = 1,
		previewMode = state.previewMode,
		itemInfo = props2.itemInfo,
		previewAvatar = state.previewAvatar,
		size = UDim2.fromScale(1, 1) - UDim2.fromOffset(0, v)
	})

	local tryOn = props2.itemInfo

	if tryOn then
		if props2.itemInfo.productType == Enum.InfoType.Asset then
			local createElement2 = Roact.createElement
			local compactButton = ExperienceComponents.CompactButton
			local v7 = {
				layoutOrder = 2,
				size = UDim2.fromOffset(0, v),
				automaticSize = Enum.AutomaticSize.X,
				text = state.previewMode == enums.PreviewModes.Object and "Try On" or "View Item",
				icon = 0,
				onActivated = 0,
				backgroundColor = 0,
				inactiveBackgroundColor = 0,
				contentColor = 0,
				inactiveContentColor = 0,
				textSize = 0,
				cornerRadius = 0,
				font = 0
			}
			local icon

			if state.previewMode == enums.PreviewModes.Object then
				icon = assets.Clothing
			else
				icon = assets.Rotation
			end

			v7.icon = icon
			v7.onActivated = props.toggleTryOn

			v7.backgroundColor = props2.config.secondaryButtonColor
			v7.inactiveBackgroundColor = props2.config.secondaryButtonColor
			v7.contentColor = props2.config.secondaryButtonTextColor
			v7.inactiveContentColor = props2.config.secondaryTextColor
			v7.textSize = props2.config.textSize
			v7.cornerRadius = props2.config.cornerRadiusSmall
			v7.font = props2.config.headerFont
			tryOn = createElement2(compactButton, v7)
		else
			tryOn = false
		end
	end

	v6.TryOn = tryOn
	return createElement("Frame", v5, v6)
end

function extended:willUnmount()
	local state = self.state
	self.isMounted = false

	if state.previewAvatar then
		state.previewAvatar:Destroy()
	end
end

local function mapStateToProps(data)
	local v = { config = data.config, itemInfo = 0 }
	local itemInfo

	if data.ui.viewedItemId then
		itemInfo = data.server.itemInfo[tostring(data.ui.viewedItemId)]
	end

	v.itemInfo = itemInfo
	return v
end

return RoactRodux.connect(mapStateToProps)(extended)