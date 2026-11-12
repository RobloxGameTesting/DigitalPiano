local UserInputService = game:GetService("UserInputService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(script.Parent.Parent.Packages.RoactRodux)
require(script.Parent.Parent.Reducers.reducer)
local getTextFromMode = require(MerchBooth.Modules.getTextFromMode)
local assets = require(MerchBooth.assets)
local enums = require(MerchBooth.enums)
local styles = require(MerchBooth.styles)
local ItemTag = require(script.Parent.ItemTag)
local ItemViewport = require(script.Parent.ItemViewport)

local extended = Roact.Component:extend("ItemTile")

extended.defaultProps = {
	size = UDim2.fromScale(1, 0),
	isGamepadSelection = false,
	UserInputService = UserInputService
}

function extended:init()
	local binding, setIsHovered = Roact.createBinding(false)
	self.isHovered = binding
	self.setIsHovered = setIsHovered

	function self.setHoverState(flag: boolean)
		return function()
			self.setIsHovered(flag)
		end
	end

	self.backgroundTransparencyMap = self.isHovered:map(function(flag: boolean): number
		return if flag then 0.6 else 1
	end)
end

local function getBadgeText(props)
	local displayType = tostring(props.displayType or props.category or "Item")

	if displayType == "Tag" then
		return "TITLE"
	elseif displayType == "Theme" then
		return "UI"
	elseif displayType == "Effect" then
		return "FX"
	elseif displayType == "Storage" then
		return "+10"
	end

	return tostring(props.name or "IT"):sub(1, 2):upper()
end

local function withActivation(onActivateds, props) -- 5 equivalent calls inferred from this helper
	onActivateds[Roact.Event.TouchTap] = props.onActivated
	onActivateds[Roact.Event.Activated] = props.onActivated
	return onActivateds
end

function extended.render(props)
	local props2 = props.props

	local v = props2.config.textSize * 3
	local v2 = props2.config.textSize * 2
	local udim = UDim2.fromOffset(0, v + v2 + styles.PaddingMicro.Offset * 2)
	local size = UDim2.fromScale(1, 1) - udim
	local v3 = props2.viewportObject ~= nil
	local v4 = not v3

	if v4 then
		if props2.purchaseKind == "ProfileStore" then
			v4 = type(props2.thumbnailImage) ~= "string" or props2.thumbnailImage == ""
		else
			v4 = false
		end
	end

	local text

	if props2.isOwned then
		text = getTextFromMode(enums.PrimaryButtonModes.Owned, props2.price)
	else
		text = props2.priceText or getTextFromMode(enums.PrimaryButtonModes.Purchase, props2.price)
	end

	local icon

	if props2.priceIcon ~= false then
		if props2.priceIcon then
			icon = props2.priceIcon
		elseif not (props2.isOwned or not (props2.price > 0)) then
			icon = assets.Robux
		end
	end

	local createElement = Roact.createElement
	local v5 = {
		LayoutOrder = props2.layoutOrder,
		Size = props2.size,
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		BackgroundColor3 = props2.config.secondaryButtonColor,
		BackgroundTransparency = props.backgroundTransparencyMap,
		AutoButtonColor = false,
		[Roact.Event.MouseEnter] = props.setHoverState(true),
		[Roact.Event.MouseLeave] = props.setHoverState(false)
	}
	withActivation(v5, props2) -- inferred equivalent call
	local children = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = styles.PaddingMicro
		}),
		GamepadSelection = props2.isGamepadSelection and Roact.createElement(ExperienceComponents.SelectParent),
		Corner = Roact.createElement("UICorner", { CornerRadius = props2.config.cornerRadiusSmall }),
		ViewportThumbnail = 0,
		BadgeThumbnail = 0,
		Thumbnail = 0,
		Name = 0,
		PriceLabel = 0
	}
	local viewportThumbnail

	if v3 then
		viewportThumbnail = Roact.createElement("Frame", {
			LayoutOrder = 1,
			Size = size,
			BackgroundTransparency = 1
		}, {
			Viewport = Roact.createElement(ItemViewport, {
				LayoutOrder = 1,
				itemInfo = { viewportObject = props2.viewportObject },
				previewMode = enums.PreviewModes.Object,
				previewRotationSpeed = 8,
				size = UDim2.fromScale(1, 1)
			}),
			ActivateArea = Roact.createElement("TextButton", withActivation({ -- inferred equivalent call
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 10
			}, props2))
		})
	else
		viewportThumbnail = v3
	end

	children.ViewportThumbnail = viewportThumbnail
	local badgeThumbnail

	if v4 then
		badgeThumbnail = Roact.createElement("ImageButton", withActivation({ -- inferred equivalent call
			LayoutOrder = 1,
			Size = size,
			BackgroundColor3 = props2.accentColor or props2.config.buttonColor,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			ImageTransparency = 1,
			AutoButtonColor = false
		}, props2), {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = props2.config.cornerRadiusSmall
			}),
			Stroke = Roact.createElement("UIStroke", {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.78
			}),
			Text = Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.86, 0.35),
				BackgroundTransparency = 1,
				Text = getBadgeText(props2),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = props2.config.headerFont
			}),
			Label = props2.label
		})
	else
		badgeThumbnail = v4
	end

	children.BadgeThumbnail = badgeThumbnail

	local thumbnail = not (v3 or v4)

	if thumbnail then
		thumbnail = Roact.createElement("ImageButton", withActivation({ -- inferred equivalent call
			LayoutOrder = 1,
			Image = props2.thumbnailImage or "rbxthumb://type=Asset&id=" .. props2.iconId .. "&w=420&h=420",
			Size = size,
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			AutoButtonColor = false
		}, props2), {
			Layout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom
			}),
			Label = props2.label
		})
	end

	children.Thumbnail = thumbnail

	children.Name = Roact.createElement("TextButton", withActivation({ -- inferred equivalent call
		LayoutOrder = 2,
		Text = props2.name,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		AutoLocalize = false,
		TextColor3 = props2.config.textColor,
		TextSize = props2.config.textSize,
		Font = props2.config.textFont,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		TextScaled = false,
		AutomaticSize = Enum.AutomaticSize.None,
		Size = UDim2.new(1, 0, 0, v),
		TextTruncate = Enum.TextTruncate.AtEnd
	}, props2))

	children.PriceLabel = Roact.createElement(ItemTag, {
		layoutOrder = 3,
		icon = icon,
		text = text,
		size = UDim2.new(1, 0, 0, v2),
		automaticSize = Enum.AutomaticSize.None,
		isEnabled = true,
		onActivated = props2.onActivated,
		backgroundColor = props2.config.secondaryButtonColor,
		inactiveBackgroundColor = props2.config.secondaryButtonColor,
		contentColor = props2.config.secondaryButtonTextColor,
		inactiveContentColor = props2.config.secondaryButtonTextColor,
		textSize = props2.config.textSize,
		cornerRadius = props2.config.cornerRadiusSmall,
		font = props2.config.headerFont
	})
	return createElement("ImageButton", v5, children)
end

local function mapStateToProps(p)
	return { config = p.config }
end

return RoactRodux.connect(mapStateToProps)(extended)