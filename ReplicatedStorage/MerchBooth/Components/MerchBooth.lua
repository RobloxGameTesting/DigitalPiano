local merchBooth = script:FindFirstAncestor("MerchBooth")

local Cryo = require(merchBooth.Packages.Cryo)
local ExperienceComponents = require(merchBooth.Packages.ExperienceComponents)
local Otter = require(merchBooth.Packages.Otter)
local Roact = require(merchBooth.Packages.Roact)
local RoactRodux = require(merchBooth.Packages.RoactRodux)
require(merchBooth.Reducers.reducer)
local enums = require(merchBooth.enums)
require(merchBooth.Reducers.serverReducer)
local constants = require(merchBooth.constants)
require(merchBooth.types)
local styles = require(merchBooth.styles)
local setMerchBoothVisible = require(merchBooth.Actions.setMerchBoothVisible)
local getAvailableAccessoryTypes = require(merchBooth.Modules.getAvailableAccessoryTypes)
local formatProductTypeString = require(merchBooth.Modules.formatProductTypeString)
local FocusLost = require(script.Parent.FocusLost)
local CatalogButton = require(script.Parent.Catalog.CatalogButton)
local CatalogModal = require(script.Parent.Catalog.CatalogModal)
local CatalogFilters = require(script.Parent.Catalog.CatalogFilters)
local ItemDetail = require(script.Parent.ItemDetail)
local ItemPreview = require(script.Parent.ItemPreview)

local numberRange = NumberRange.new(0.5, 1)
local numberRange2 = NumberRange.new(0, 1)
local udim = UDim2.fromOffset(64, 64)

local defaultProps = {
	maxSizeLandscape = Vector2.new(400, 800),
	screenOrientation = Enum.ScreenOrientation.LandscapeLeft,
	headerHeight = 64
}

local extended = Roact.Component:extend("MerchBoothApp")

extended.defaultProps = defaultProps

function extended:init()
	self.containerRef = Roact.createRef()

	self:setState({ isViewRendered = self.props.isOpen, areFiltersOpen = false })

	local createBinding = Roact.createBinding
	local v

	if self.props.isOpen then
		v = numberRange2.Max
	else
		v = numberRange2.Min
	end

	local binding, setAlpha = createBinding(v)
	self.alpha = binding
	self.setAlpha = setAlpha
	self.alphaMotor = Otter.createSingleMotor(self.alpha:getValue())

	self.alphaMotor:onStep(function(p: number)
		local state = self.state
		local isViewRendered = p ~= numberRange2.Min

		if state.isViewRendered ~= isViewRendered then
			self:setState({ isViewRendered = isViewRendered })
		end

		self.setAlpha(p)
	end)

	local createBinding2 = Roact.createBinding
	local v2

	if self.props.currentItem then
		v2 = numberRange.Min
	else
		v2 = numberRange.Max
	end

	local binding2, setViewHeight = createBinding2(v2)
	self.viewSizeScaler = binding2
	self.setViewHeight = setViewHeight

	self.viewSizeMotor = Otter.createSingleMotor(self.viewSizeScaler:getValue())
	self.viewSizeMotor:onStep(self.setViewHeight)

	self.positionMap = self.alpha:map(function(p: number)
		return UDim2.fromScale((1 - p) * 1.5, 0)
	end)

	self.landscapeViewSize = self.viewSizeScaler:map(function(p: number)
		return UDim2.fromScale(p, 1)
	end)

	self.portraitViewSize = self.viewSizeScaler:map(function(p: number)
		return UDim2.fromScale(1, p)
	end)

	function self.setFilterVisibility(areFiltersOpen: boolean)
		return function()
			self:setState({ areFiltersOpen = areFiltersOpen })
		end
	end

	function self.getFilters()
		local availableAccessoryTypes = getAvailableAccessoryTypes(self.props.itemInfo)

		return Cryo.List.map(availableAccessoryTypes, function(p)
			return {
				text = formatProductTypeString(p.Name),
				value = p
			}
		end)
	end

	local binding3, setLandscapeWidthOffset = Roact.createBinding(0)
	self.landscapeWidthOffset = binding3
	self.setLandscapeWidthOffset = setLandscapeWidthOffset

	function self.onCatalogContainerSizeChanged(p)
		self.setLandscapeWidthOffset(p.AbsoluteSize.X + styles.Padding.Offset)
	end

	function self.close()
		local props = self.props

		if props.isOpen then
			props.onClose()
		end
	end
end

function extended.render(props)
	local props2 = props.props
	local state = props.state
	local control = props2.controls[enums.Controls.ProximityPrompts]
	local v = props2.device == enums.Device.Mobile
	local v2 = not v or props2.screenOrientation == Enum.ScreenOrientation.Portrait
	local v3 = v and not v2
	local isOpen = v and props2.isOpen or not props2.catalogButtonVisible

	local v4 = v and v2

	local udim2 = UDim2.fromScale(1, 1)

	if v4 then
		udim2 -= UDim2.fromOffset(0, props2.headerHeight)
	elseif v3 then
		udim2 -= UDim2.fromOffset(udim.X.Offset, 0)
	end

	local createElement = Roact.createElement
	local v5 = { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }

	local v6 = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = styles.Padding
		}),
		Padding = not isOpen and Roact.createElement("UIPadding", {
			PaddingTop = styles.Padding,
			PaddingRight = styles.Padding,
			PaddingBottom = styles.Padding,
			PaddingLeft = styles.Padding
		}),
		FocusLost = props2.isMerchBoothFocused and Roact.createElement(FocusLost, {
			ref = props.containerRef,
			callback = props.close
		}),
		InteractAction = Roact.createElement(ExperienceComponents.ContextActionBinding, {
			inputState = Enum.UserInputState.Begin,
			inputTypes = { control.keyboard },
			callback = props.close
		}),
		Container = 0,
		CatalogButtonContainer = 0
	}

	local createElement2 = Roact.createElement
	local containerRefsByRef = {
		LayoutOrder = 1,
		Size = props.landscapeWidthOffset:map(function(p: number)
			if v then
				return (UDim2.fromScale(1, 1))
			end

			return (UDim2.new(1, -p, 1, 0))
		end),
		BackgroundTransparency = 1,
		[Roact.Ref] = props.containerRef
	}
	local v7 = {
		Padding = not v and Roact.createElement("UIPadding", {
			PaddingTop = styles.Padding,
			PaddingRight = styles.Padding,
			PaddingBottom = styles.Padding,
			PaddingLeft = styles.Padding
		}),
		SizeConstraint = not v and Roact.createElement("UISizeConstraint", {
			MaxSize = props2.maxSizeLandscape
		}),
		AnimationWrapper = 0
	}

	local createElement3 = Roact.createElement
	local v8 = {
		Position = props.positionMap,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		BackgroundColor3 = props2.config.backgroundColor,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1)
	}
	local children = {
		Padding = v3 and Roact.createElement("UIPadding", {
			PaddingTop = styles.Padding,
			PaddingRight = styles.Padding,
			PaddingBottom = styles.Padding,
			PaddingLeft = styles.Padding
		}),
		BorderRadius = not v and Roact.createElement("UICorner", {
			CornerRadius = props2.config.cornerRadius
		}),
		SelectionGroup = not state.areFiltersOpen and Roact.createElement(ExperienceComponents.SelectionGroup),
		Layout = 0,
		Header = 0,
		Content = 0,
		CatalogButton = 0
	}

	local createElement4 = Roact.createElement
	local v9 = {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = 0,
		VerticalAlignment = 0,
		FillDirection = 0
	}
	local padding

	if not v4 then
		padding = styles.Padding
	end

	v9.Padding = padding
	local verticalAlignment

	if v3 then
		verticalAlignment = Enum.VerticalAlignment.Center
	end

	v9.VerticalAlignment = verticalAlignment
	local fillDirection

	if v3 then
		fillDirection = Enum.FillDirection.Horizontal
	end

	v9.FillDirection = fillDirection
	children.Layout = createElement4("UIListLayout", v9)

	children.Header = v4
		and Roact.createElement(
			"Frame",
			{
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, props2.headerHeight),
				BackgroundTransparency = 1
			},
			{
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = styles.PaddingSmall,
					PaddingRight = styles.PaddingSmall,
					PaddingBottom = styles.PaddingSmall,
					PaddingLeft = styles.PaddingSmall
				}),
				Layout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = Enum.HorizontalAlignment.Right
				}),
				CatalogButton = Roact.createElement(CatalogButton)
			}
		)

	local createElement5 = Roact.createElement

	local createElement6 = Roact.createElement
	local size

	if v2 then
		size = UDim2.fromScale(1, 0.5)
	else
		size = UDim2.fromScale(0.5, 1)
	end

	local v10 = {
		Background = createElement6("Frame", { Size = size, BackgroundTransparency = 1, ZIndex = 1 }, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Right
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = styles.Padding,
				PaddingRight = styles.Padding,
				PaddingBottom = styles.Padding,
				PaddingLeft = styles.Padding
			}),
			ItemPreview = props2.currentItem and Roact.createElement(ItemPreview, {
				layoutOrder = 2
			})
		}),
		View = 0
	}

	local view = state.isViewRendered

	if view then
		local createElement7 = Roact.createElement
		local size2

		if v2 then
			size2 = props.portraitViewSize
		else
			size2 = props.landscapeViewSize
		end

		view = createElement7("Frame", {
			Size = size2,
			BackgroundColor3 = props2.config.backgroundColor,
			BorderSizePixel = 0,
			ZIndex = 2,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1)
		}, {
			BorderRadius = not v4 and Roact.createElement("UICorner", {
				CornerRadius = props2.config.cornerRadius
			}),
			ItemDetail = props2.currentItem and not state.areFiltersOpen and Roact.createElement(ItemDetail, {
				itemInfo = props2.currentItem,
				onClose = props.onItemDetailClosed,
				isOverlayActive = props2.isOverlayActive,
				toggleOverlay = props2.toggleOverlay
			}),
			Catalog = not props2.currentItem and not state.areFiltersOpen and Roact.createElement(CatalogModal, {
				itemsPerRow = v2 and 3 or 5,
				onOpenFilters = props.setFilterVisibility(true)
			}),
			CatalogFilters = state.areFiltersOpen and Roact.createElement(CatalogFilters, {
				filters = props.getFilters(),
				onFilterSelected = props.setFilterVisibility(false)
			})
		})
	end

	v10.View = view
	children.Content = createElement5("Frame", {
		LayoutOrder = 2,
		BackgroundTransparency = 1,
		Size = udim2
	}, v10)

	children.CatalogButton = v3 and Roact.createElement(CatalogButton, { layoutOrder = 3 })
	v7.AnimationWrapper = createElement3("Frame", v8, children)
	v6.Container = createElement2("Frame", containerRefsByRef, v7)

	local catalogButtonContainer = not isOpen

	if catalogButtonContainer then
		catalogButtonContainer = Roact.createElement(
			"Frame",
			{
				LayoutOrder = 2,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				[Roact.Change.AbsoluteSize] = props.onCatalogContainerSizeChanged
			},
			{
				CatalogButton = Roact.createElement(CatalogButton)
			}
		)
	end

	v6.CatalogButtonContainer = catalogButtonContainer
	return createElement("Frame", v5, v6)
end

function extended.didUpdate(object, p)
	local props = object.props

	if props.isOpen ~= p.isOpen then
		object:setState({ areFiltersOpen = false })

		if props.isOpen then
			object.alphaMotor:setGoal(Otter.spring(numberRange2.Max, constants.Springs.Bouncy))
		else
			object.alphaMotor:setGoal(Otter.spring(numberRange2.Min, constants.Springs.Zippy))
		end
	end

	if props.currentItem ~= p.currentItem then
		local viewSizeMotor = object.viewSizeMotor
		local spring = Otter.spring
		local v

		if props.currentItem then
			v = numberRange.Min
		else
			v = numberRange.Max
		end

		viewSizeMotor:setGoal(spring(v, constants.Springs.Zippy))
	end
end

function extended.didMount(p)
	local props = p.props
	p.alphaMotor:setGoal(Otter.instant(props.isOpen and 1 or 0))
end

function extended.willUnmount(p)
	p.alphaMotor:stop()
end

local function mapStateToProps(data)
	local v = {
		config = data.config,
		catalogButtonVisible = data.ui.catalogButtonVisible,
		isOpen = data.ui.merchBoothOpen,
		isMerchBoothFocused = data.ui.isMerchBoothFocused,
		currentItem = 0,
		itemInfo = 0,
		device = 0,
		controls = 0
	}
	local currentItem

	if data.ui.viewedItemId then
		currentItem = data.server.itemInfo[tostring(data.ui.viewedItemId)]
	end

	v.currentItem = currentItem
	v.itemInfo = data.server.itemInfo
	v.device = data.device
	v.controls = data.controls
	return v
end

local function mapDispatchToProps(callback)
	return {
		onClose = function()
			callback(setMerchBoothVisible(false))
		end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(extended)