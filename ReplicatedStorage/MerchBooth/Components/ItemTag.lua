local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local styles = require(MerchBooth.styles)

local extended = Roact.Component:extend("ItemTag")

extended.defaultProps = {
	isEnabled = false,
	backgroundColor = styles.Grey,
	inactiveBackgroundColor = styles.Grey,
	contentColor = styles.White,
	inactiveContentColor = styles.White,
	padding = styles.PaddingMicro
}

function extended.render(p)
	p.props.inactiveBackgroundColor = p.props.backgroundColor
	return Roact.createElement(ExperienceComponents.CompactButton, p.props)
end

return extended