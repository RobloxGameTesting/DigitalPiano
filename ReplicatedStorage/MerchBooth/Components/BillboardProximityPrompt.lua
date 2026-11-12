local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
local assets = require(MerchBooth.assets)
local enums = require(MerchBooth.enums)
require(MerchBooth.Reducers.reducer)

local extended = Roact.Component:extend("BillboardProximityPrompt")

extended.defaultProps = { isEnabled = true, isVisible = false }

function extended:init()
	self:setState({ isVisible = self.props.isVisible })

	function self.onPromptShown(_)
		local props = self.props

		self:setState({ isVisible = true })

		if props.onShown then
			props.onShown()
		end
	end

	function self.onPromptHidden(_)
		local props = self.props

		self:setState({ isVisible = false })

		if props.onHidden then
			props.onHidden()
		end
	end

	function self.getActivationKeyCode()
		local props = self.props
		local v = nil

		if props.device == enums.Device.Computer then
			v = props.keyboardKeyCode
		elseif props.device == enums.Device.Gamepad then
			v = props.gamepadKeyCode
		end

		return if v ~= Enum.KeyCode.Unknown then v else nil
	end

	function self.getHeightOffset()
		local props = self.props

		if props.adornee:IsA("BasePart") then
			return (Vector3.new(0, props.adornee.Size.Y / 2 + 1, 0))
		end

		return Vector3.new(0, 0, 0)
	end
end

function extended.render(props)
	local props2 = props.props
	local state = props.state
	local activationKeyCode = props.getActivationKeyCode()

	local createFragment = Roact.createFragment
	local createElement = Roact.createElement
	local portal = Roact.Portal
	local v = { target = props2.adornee }

	local createElement2 = Roact.createElement
	local v2 = {
		["Enabled"] = nil,
		Enabled = props2.isEnabled,
		Style = Enum.ProximityPromptStyle.Custom,
		MaxActivationDistance = props2.config.proximityButtonActivationDistance,
		Exclusivity = props2.config.proximityButtonExclusivity,
		UIOffset = props2.config.proximityButtonOffset,
		RequiresLineOfSight = props2.config.proximityButtonRequiresLineOfSight,
		[Roact.Event.PromptShown] = props.onPromptShown,
		[Roact.Event.PromptHidden] = props.onPromptHidden
	}
	local keyboardKeyCode

	if activationKeyCode then
		keyboardKeyCode = props2.keyboardKeyCode
	end

	v2.KeyboardKeyCode = keyboardKeyCode
	local gamepadKeyCode

	if activationKeyCode then
		gamepadKeyCode = props2.gamepadKeyCode
	end

	v2.GamepadKeyCode = gamepadKeyCode

	local triggered = Roact.Event.Triggered
	local v3

	if activationKeyCode then
		v3 = props2.onActivated
	end

	v2[triggered] = v3
	return createFragment({
		createElement(portal, v, {
			ProximityPrompt = createElement2("ProximityPrompt", v2)
		}),
		Roact.createElement(Roact.Portal, { target = props2.billboardParent }, {
			[tostring(props2.assetId)] = Roact.createElement("BillboardGui", {
				Active = true,
				Adornee = props2.adornee,
				Size = UDim2.fromOffset(48, 48),
				StudsOffsetWorldSpace = props.getHeightOffset(),
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				ResetOnSpawn = false
			}, {
				Button = Roact.createElement(ExperienceComponents.PulseButton, {
					isVisible = state.isVisible,
					icon = assets.Eye,
					activationKeyCode = activationKeyCode,
					onActivated = props2.onActivated,
					pulses = props2.config.proximityButtonPulseCount,
					size = UDim2.fromScale(0.8, 0.8)
				})
			})
		})
	})
end

local function mapStateToProps(p)
	return { config = p.config, device = p.device }
end

return RoactRodux.connect(mapStateToProps)(extended)