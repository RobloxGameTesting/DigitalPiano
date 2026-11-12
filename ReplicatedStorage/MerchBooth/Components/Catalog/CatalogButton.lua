local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
require(MerchBooth.Reducers.reducer)
local enums = require(MerchBooth.enums)
local setMerchBoothVisible = require(MerchBooth.Actions.setMerchBoothVisible)
local assets = require(MerchBooth.assets)

local extended = Roact.Component:extend("CatalogButton")

function extended.render(p)
	local props = p.props

	local control = props.controls[enums.Controls.OpenMerchBooth]
	local control2 = props.controls[enums.Controls.CloseMerchBooth]

	local v = {
		layoutOrder = props.layoutOrder,
		isVisible = props.isCatalogOpen,
		isSelectable = false,
		keyCode = 0,
		icon = 0,
		contentColor = 0,
		backgroundColor = 0,
		borderColor = 0,
		onActivated = 0
	}
	local keyCode

	if props.device == enums.Device.Gamepad then
		keyCode = control2.gamepad
	else
		keyCode = control2.keyboard
	end

	v.keyCode = keyCode
	v.icon = assets.Close
	v.contentColor = props.config.textColor
	v.backgroundColor = props.config.backgroundColor
	v.borderColor = props.config.backgroundColor
	v.onActivated = props.closeMerchBooth

	local v2 = {
		layoutOrder = props.layoutOrder,
		isVisible = not props.isCatalogOpen,
		isSelectable = false,
		keyCode = 0,
		icon = 0,
		contentColor = 0,
		backgroundColor = 0,
		borderColor = 0,
		onActivated = 0
	}
	local keyCode2

	if props.device == enums.Device.Gamepad then
		keyCode2 = control.gamepad
	else
		keyCode2 = control.keyboard
	end

	v2.keyCode = keyCode2
	v2.icon = assets.ShoppingCart
	v2.contentColor = props.config.buttonTextColor
	v2.backgroundColor = props.config.buttonColor
	v2.borderColor = props.config.buttonColor
	v2.onActivated = props.openMerchBooth

	local createElement = Roact.createElement
	local pillButton = ExperienceComponents.PillButton

	if props.isCatalogOpen then
		v2 = v
	end

	return createElement(pillButton, v2)
end

local function mapStateToProps(data)
	return {
		isCatalogOpen = data.ui.merchBoothOpen,
		device = data.device,
		config = data.config,
		controls = data.controls
	}
end

local function mapDispatchToProps(callback)
	return {
		openMerchBooth = function()
			callback(setMerchBoothVisible(true))
		end,
		closeMerchBooth = function()
			callback(setMerchBoothVisible(false))
		end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(extended)