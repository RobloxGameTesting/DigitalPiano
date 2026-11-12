local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Cryo = require(MerchBooth.Packages.Cryo)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
require(MerchBooth.Reducers.reducer)
local enums = require(MerchBooth.enums)

local extended = Roact.Component:extend("SelectableTextLabel")

function extended.render(p)
	local props = p.props
	local device = props.device

	local joined = Cryo.Dictionary.join(props, { device = Cryo.None })

	if device == enums.Device.Computer then
		return Roact.createElement("TextBox", Cryo.Dictionary.join({
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			TextEditable = false,
			Selectable = false
		}, joined))
	end

	return Roact.createElement(ExperienceComponents.TextLabel, Cryo.Dictionary.join(joined, {
		TextScaled = false
	}))
end

local function mapStateToProps(p)
	return { device = p.device }
end

return RoactRodux.connect(mapStateToProps)(extended)