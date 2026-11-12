local Roact = require(script.Parent.Parent.Parent.Roact)
local constants = require(script.Parent.Parent.constants)
local PrimaryButton = require(script.Parent.PrimaryButton)

local extended = Roact.Component:extend("CompactButton")

extended.defaultProps = {
	isEnabled = true,
	size = UDim2.fromScale(0, 0),
	automaticSize = Enum.AutomaticSize.XY,
	textSize = constants.TextSize - 2,
	padding = constants.PaddingSmall,
	backgroundColor = constants.Dark,
	inactiveBackgroundColor = constants.Dark,
	contentColor = constants.White,
	inactiveContentColor = constants.Faded,
	cornerRadius = constants.PaddingSmall,
	font = constants.HeaderFont
}

function extended.render(p)
	return Roact.createElement(PrimaryButton, p.props)
end

return extended