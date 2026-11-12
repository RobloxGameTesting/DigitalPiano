local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Cryo = require(MerchBooth.Packages.Cryo)
local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
require(MerchBooth.Reducers.reducer)
local assets = require(MerchBooth.assets)
require(MerchBooth.Reducers.serverReducer)
local matchAssetTypeToAccessoryType = require(MerchBooth.Modules.matchAssetTypeToAccessoryType)
local formatProductTypeString = require(MerchBooth.Modules.formatProductTypeString)
local setViewedItem = require(MerchBooth.Actions.setViewedItem)
local enums = require(MerchBooth.enums)
local styles = require(MerchBooth.styles)
require(MerchBooth.types)
local ItemTile = require(MerchBooth.Components.ItemTile)
local GamepadLegendLabel = require(MerchBooth.Components.GamepadLegendLabel)

local v = {
	{
		label = "Gamepasses",
		categories = { Gamepasses = true }
	},
	{
		label = "Titles",
		categories = { Titles = true, Tags = true }
	},
	{
		label = "Benches",
		categories = { Benches = true }
	},
	{
		label = "Effects",
		categories = { Effects = true, Themes = true }
	},
	{
		label = "Upgrades",
		categories = { Notes = true, Storage = true }
	}
}

local function getCategoryForRequest(pianoShopRequestedCategory)
	if type(pianoShopRequestedCategory) ~= "string" or pianoShopRequestedCategory == "" then
		return nil
	end

	for _, v2 in ipairs(v) do
		if v2.label == pianoShopRequestedCategory or v2.categories[pianoShopRequestedCategory] == true then
			return v2.categories
		end
	end

	return nil
end

local function getCategoryLabel(p) -- 1 equivalent call inferred from this helper
	for _, v2 in ipairs(v) do
		if v2.categories == p then
			return v2.label
		end
	end

	return ""
end

local extended = Roact.Component:extend("CatalogModal")

extended.defaultProps = {
	size = UDim2.fromScale(1, 1),
	itemsPerRow = 2,
	gamepadLegendHeight = 32,
	MarketplaceService = MarketplaceService
}

function extended:init()
	self:setState({
		activePianoCategory = getCategoryForRequest(ReplicatedStorage:GetAttribute("PianoShopRequestedCategory")) or v[1].categories
	})

	local binding, setGridWidth = Roact.createBinding(0)
	self.gridWidth = binding
	self.setGridWidth = setGridWidth
	local binding2, setHeaderHeight = Roact.createBinding(0)
	self.headerHeight = binding2
	self.setHeaderHeight = setHeaderHeight

	function self.setPianoCategory(activePianoCategory)
		return function()
			ReplicatedStorage:SetAttribute("PianoShopRequestedCategory", getCategoryLabel(activePianoCategory)) -- inferred equivalent call
			self:setState({ activePianoCategory = activePianoCategory })
		end
	end

	function self.getSortedItems()
		local props = self.props
		local activePianoCategory = self.state and self.state.activePianoCategory

		local function itemMatchesBaseFilters(data): boolean
			if data.hiddenFromCatalog then
				return false
			end

			if data.purchaseKind or not props.catalogFilter then
				return true
			end

			if data.productType == Enum.InfoType.Asset then
				return matchAssetTypeToAccessoryType(data.assetType) == props.catalogFilter
			end

			return data.productType == props.catalogFilter
		end

		local filtered = Cryo.List.filter(Cryo.Dictionary.values(props.itemInfo), itemMatchesBaseFilters)
		local v2, effectivePianoCategory

		if activePianoCategory then
			v2 = Cryo.List.filter(filtered, function(p): boolean
				return activePianoCategory[p.category] == true
			end)

			if #v2 == 0 then
				effectivePianoCategory = activePianoCategory

				for _, v3 in ipairs(v) do
					local categories = v3.categories

					if not categories then
						continue
					end

					local filtered2 = Cryo.List.filter(filtered, function(p): boolean
						return categories[p.category] == true
					end)

					if #filtered2 > 0 then
						v2 = filtered2
						effectivePianoCategory = categories
						break
					end
				end
			else
				effectivePianoCategory = activePianoCategory
			end
		else
			v2 = filtered
			effectivePianoCategory = activePianoCategory
		end

		self.effectivePianoCategory = effectivePianoCategory

		return (Cryo.List.sort(v2, props.catalogSortFunction))
	end

	function self.onHeaderSizeChanged(p)
		self.setHeaderHeight(p.AbsoluteSize.Y)
	end

	function self.onCanvasSizeChanged(p)
		local x = p.AbsoluteCanvasSize.X

		if self.gridWidth:getValue() ~= x then
			self.setGridWidth(x)
		end
	end
end

function extended:didMount()
	self.categoryAttributeConnection = ReplicatedStorage:GetAttributeChangedSignal("PianoShopRequestedCategory"):Connect(function()
		local activePianoCategory = getCategoryForRequest(ReplicatedStorage:GetAttribute("PianoShopRequestedCategory"))
			or v[1].categories
		self.effectivePianoCategory = nil
		self:setState({ activePianoCategory = activePianoCategory })
	end)
end

function extended:willUnmount()
	if self.categoryAttributeConnection then
		self.categoryAttributeConnection:Disconnect()
		self.categoryAttributeConnection = nil
	end
end

function extended.render(props)
	local props2 = props.props
	local sortedItems = props.getSortedItems()
	local effectivePianoCategory = props.effectivePianoCategory or props.state and props.state.activePianoCategory
	local children = {}

	for i, v2 in ipairs(v) do
		local categories = v2.categories
		local v3 = effectivePianoCategory == categories
		local v4 = "Category" .. tostring(i)
		local createElement = Roact.createElement
		local v5 = {}
		v5.LayoutOrder = i
		v5.Size = UDim2.fromOffset(v2.label == "Gamepasses" and 112 or 92, 28)
		local backgroundColor

		if v3 then
			backgroundColor = props2.config.buttonColor
		else
			backgroundColor = props2.config.secondaryButtonColor
		end

		v5.BackgroundColor3 = backgroundColor
		v5.BorderSizePixel = 0
		v5.Text = v2.label
		local textColor

		if v3 then
			textColor = props2.config.buttonTextColor
		else
			textColor = props2.config.secondaryButtonTextColor
		end

		v5.TextColor3 = textColor
		v5.TextSize = props2.config.textSize
		v5.Font = props2.config.headerFont
		v5.AutoButtonColor = true
		v5[Roact.Event.Activated] = props.setPianoCategory(categories)
		children[v4] = createElement("TextButton", v5, {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = props2.config.cornerRadiusSmall
			})
		})
	end

	local mapped = Cryo.List.map(sortedItems, function(props3, p: number)
		return Roact.createElement(ItemTile, {
			isGamepadSelection = p == 1,
			layoutOrder = props3.layoutOrder or p,
			iconId = props3.iconId,
			thumbnailImage = props3.thumbnailImage,
			viewportObject = props3.viewportObject,
			purchaseKind = props3.purchaseKind,
			displayType = props3.displayType,
			category = props3.category,
			accentColor = props3.color,
			name = props3.title,
			price = props3.price,
			priceText = props3.priceText,
			priceIcon = props3.priceIcon,
			giftProductId = props3.giftProductId,
			isOwned = props3.isOwned,
			onActivated = function()
				if props2.onItemSelected then
					props2.onItemSelected(props3.assetId)
				end
			end
		})
	end)

	local control = props2.controls[enums.Controls.Filter]
	local v2 = #sortedItems == 0

	local createElement = Roact.createElement
	local v3 = {
		LayoutOrder = props2.layoutOrder,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	}

	local children2 = {
		Layout = Roact.createElement("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		Header = 0,
		Content = 0,
		GamepadLegend = 0
	}

	local createElement2 = Roact.createElement
	local onHeaderSizeChangedsByAbsoluteSize = {
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderMode = Enum.BorderMode.Inset,
		BackgroundTransparency = 1,
		[Roact.Change.AbsoluteSize] = props.onHeaderSizeChanged
	}
	local v4 = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = styles.PaddingSmall
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.Padding,
			PaddingRight = styles.Padding,
			PaddingLeft = styles.Padding
		}),
		Title = Roact.createElement(ExperienceComponents.TextLabel, {
			LayoutOrder = 1,
			Text = "Shop",
			TextColor3 = props2.config.textColor,
			TextSize = props2.config.headerTextSize,
			Font = props2.config.headerFont
		}),
		CategoryTabs = Roact.createElement("ScrollingFrame", {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			ScrollingDirection = Enum.ScrollingDirection.X,
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			CanvasSize = UDim2.fromScale(0, 0)
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2)
			}),
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = styles.PaddingMicro
			}),
			Tabs = Roact.createFragment(children)
		}),
		Filtering = 0
	}

	local filtering = props2.config.useFilters and not v2

	if filtering then
		local createFragment = Roact.createFragment
		local v5 = {
			FilterAction = props2.onOpenFilters and Roact.createElement(ExperienceComponents.ContextActionBinding, {
				inputTypes = { control.gamepad, control.keyboard },
				inputState = Enum.UserInputState.Begin,
				callback = props2.onOpenFilters
			}),
			FilterButton = 0
		}

		local filterButton = props2.config.useFilters and not v2

		if filterButton then
			local createElement3 = Roact.createElement
			local compactButton = ExperienceComponents.CompactButton
			local v6 = {
				layoutOrder = 2,
				text = "Filter: " .. (not props2.catalogFilter and "All" or formatProductTypeString(props2.catalogFilter.Name)),
				backgroundColor = 0,
				contentColor = 0,
				inactiveBackgroundColor = 0,
				inactiveContentColor = 0,
				textSize = 0,
				cornerRadius = 0,
				font = 0,
				icon = 0,
				onActivated = 0
			}
			local backgroundColor

			if props2.catalogFilter then
				backgroundColor = props2.config.secondaryButtonTextColor
			else
				backgroundColor = props2.config.secondaryButtonColor
			end

			v6.backgroundColor = backgroundColor
			local contentColor

			if props2.catalogFilter then
				contentColor = props2.config.secondaryButtonColor
			else
				contentColor = props2.config.secondaryButtonTextColor
			end

			v6.contentColor = contentColor

			v6.inactiveBackgroundColor = props2.config.secondaryButtonColor
			v6.inactiveContentColor = props2.config.secondaryTextColor
			v6.textSize = props2.config.textSize
			v6.cornerRadius = props2.config.cornerRadiusSmall
			v6.font = props2.config.headerFont

			v6.icon = assets.Filter
			v6.onActivated = props2.onOpenFilters
			filterButton = createElement3(compactButton, v6)
		end

		v5.FilterButton = filterButton
		filtering = createFragment(v5)
	end

	v4.Filtering = filtering
	children2.Header = createElement2("Frame", onHeaderSizeChangedsByAbsoluteSize, v4)

	local createElement3 = Roact.createElement
	local v5 = {
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Size = props.headerHeight:map(function(p: number)
			local v5 = props2.device ~= enums.Device.Gamepad and 0 or props2.gamepadLegendHeight

			return UDim2.new(1, 0, 1, -(p + v5 + styles.Padding.Offset))
		end)
	}

	local v6 = {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.Padding,
			PaddingRight = styles.Padding,
			PaddingLeft = styles.Padding
		}),
		ScrollingFrame = 0,
		EmptyShopFrame = 0
	}

	local scrollingFrame = not v2

	if scrollingFrame then
		scrollingFrame = Roact.createElement(
			ExperienceComponents.ScrollingFrame,
			{
				ScrollBarImageColor3 = props2.config.scrollBarColor,
				[Roact.Change.AbsoluteCanvasSize] = props.onCanvasSizeChanged
			},
			{
				Layout = Roact.createElement("UIGridLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					CellSize = props.gridWidth:map(function(p: number)
						local v7 = p / props2.itemsPerRow - styles.PaddingSmall.Offset
						return UDim2.fromOffset(v7, v7 / (17 / 30))
					end),
					CellPadding = UDim2.new(styles.PaddingSmall, styles.PaddingSmall)
				}),
				Items = Roact.createFragment(mapped)
			}
		)
	end

	v6.ScrollingFrame = scrollingFrame

	v6.EmptyShopFrame = v2
		and Roact.createElement(
			"Frame",
			{ BorderSizePixel = 0, BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) },
			{
				EmptyShopImage = Roact.createElement("ImageLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = assets.EmptyShop,
					ScaleType = Enum.ScaleType.Fit,
					LayoutOrder = 1,
					Size = UDim2.fromScale(0.5, 0.5)
				}),
				EmptyShopMessage = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					TextColor3 = styles.White,
					Font = styles.Font,
					TextSize = styles.HeaderTextSize,
					TextWrapped = true,
					TextTransparency = 0.5,
					Size = UDim2.fromScale(1, 0.1),
					Text = "Shop is empty, try again later!",
					LayoutOrder = 2
				}),
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center
				})
			}
		)
	children2.Content = createElement3("Frame", v5, v6)
	local gamepadLegend

	if props2.device == enums.Device.Gamepad then
		gamepadLegend = Roact.createElement(
			"Frame",
			{
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, props2.gamepadLegendHeight),
				BackgroundTransparency = 1
			},
			{
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = styles.PaddingMicro,
					PaddingRight = styles.Padding,
					PaddingBottom = styles.PaddingMicro
				}),
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = styles.Padding
				}),
				FilterLegend = Roact.createElement(GamepadLegendLabel, {
					layoutOrder = 1,
					text = "Filter",
					button = control.gamepad
				}),
				ViewItemLegend = Roact.createElement(GamepadLegendLabel, {
					layoutOrder = 2,
					text = "View Item",
					button = Enum.KeyCode.ButtonA
				})
			}
		)
	else
		gamepadLegend = false
	end

	children2.GamepadLegend = gamepadLegend
	return createElement("Frame", v3, children2)
end

local function mapStateToProps(data)
	return {
		catalogFilter = data.ui.catalogFilter,
		catalogSortFunction = data.ui.catalogSortFunction,
		config = data.config,
		controls = data.controls,
		device = data.device,
		itemInfo = data.server.itemInfo
	}
end

local function mapDispatchToProps(callback)
	return {
		onItemSelected = function(p)
			callback(setViewedItem(p))
		end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(extended)