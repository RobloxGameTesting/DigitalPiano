local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
local Otter = require(MerchBooth.Packages.Otter)
local setEquipModalVisible = require(MerchBooth.Actions.setEquipModalVisible)
local setMerchBoothFocused = require(MerchBooth.Actions.setMerchBoothFocused)
require(MerchBooth.Reducers.reducer)
local constants = require(MerchBooth.constants)
local enums = require(MerchBooth.enums)
require(MerchBooth.types)

local extended = Roact.Component:extend("EquipModal")

extended.defaultProps = { itemEquipped = MerchBooth.Remote.ItemEquipped, spring = Otter.spring }

function extended:init()
	local binding, setAlpha = Roact.createBinding(0)
	self.alpha = binding
	self.setAlpha = setAlpha
	self.motor = Otter.createSingleMotor(self.alpha:getValue())

	self:setState({ isAnimating = false })

	self.motor:onStep(function(p: number)
		self.setAlpha(p)
	end)

	self.motor:onComplete(function()
		self:setState({ isAnimating = false })
	end)

	self.positionMap = self.alpha:map(function(p: number)
		return UDim2.fromScale(0.5, p * 1.5 - 1)
	end)

	self.anchorPointMap = self.alpha:map(function(p: number)
		return Vector2.new(0.5, p * 0.5)
	end)

	function self.setGoal(p: number, flag: boolean?)
		local props = self.props
		local v = if flag then Otter.instant else props.spring

		self:setState({ isAnimating = true })

		self.motor:setGoal(v(p, constants.Springs.Default))
	end

	function self.onClose()
		local props = self.props

		self.setGoal(0)
		props.close()

		if props.toggleOverlay then
			props.toggleOverlay(false)
		end
	end

	function self.onEquip()
		local props = self.props

		props.itemEquipped:FireServer(props.currentItem.assetId, props.currentItem.assetType)
		self.setGoal(0, true)
		props.close()

		if props.toggleOverlay then
			props.toggleOverlay(false)
		end
	end
end

function extended.render(props)
	local props2 = props.props
	local state = props.state

	local v = not (props2.isShown or state.isAnimating)

	return Roact.createElement("Frame", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		AnchorPoint = props.anchorPointMap,
		Position = props.positionMap,
		ZIndex = 20
	}, {
		Modal = not v and Roact.createElement(ExperienceComponents.RobloxModal, {
			title = "Equip Item",
			description = "This item will be equipped to your avatar.",
			cancelText = "Later",
			acceptText = "Equip Item",
			usingGamepad = props2.device == enums.Device.Gamepad,
			onCancel = props.onClose,
			onAccept = props.onEquip
		}, {
			Layout = Roact.createElement("UIListLayout", {
				HorizontalAlignment = Enum.HorizontalAlignment.Center
			}),
			Thumbnail = props2.currentItem and Roact.createElement("ImageLabel", {
				Image = "rbxthumb://type=Asset&id=" .. props2.currentItem.assetId .. "&w=420&h=420",
				Size = UDim2.fromScale(0.5, 0.5),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				BackgroundTransparency = 1
			})
		})
	})
end

function extended.didUpdate(data, p)
	local props = data.props

	if props.isShown ~= p.isShown then
		data.setGoal(props.isShown and 1 or 0)
	end

	if p.merchBoothOpen and not props.merchBoothOpen then
		data.onClose()
	end
end

function extended.willUnmount(p)
	p.motor:stop()
end

local function mapStateToProps(data)
	local v = {
		device = data.device,
		merchBoothOpen = data.ui.merchBoothOpen,
		currentItem = 0,
		isShown = 0
	}
	local currentItem

	if data.ui.viewedItemId then
		currentItem = data.server.itemInfo[tostring(data.ui.viewedItemId)]
	end

	v.currentItem = currentItem
	v.isShown = data.ui.isEquipModalShown
	return v
end

local function mapDispatchToProps(callback)
	return {
		close = function()
			callback(setMerchBoothFocused(true))
			callback(setEquipModalVisible(false))
		end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(extended)