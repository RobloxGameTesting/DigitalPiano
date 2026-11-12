local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Cryo = require(MerchBooth.Packages.Cryo)
local Roact = require(MerchBooth.Packages.Roact)

local extended = Roact.Component:extend("TextButton")

extended.defaultProps = {
	BackgroundTransparency = 0,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = true,
	Size = UDim2.fromScale(1, 0),
	AutomaticSize = Enum.AutomaticSize.Y
}

function extended.render(p)
	return Roact.createElement("TextButton", Cryo.Dictionary.join(p.props, { config = Cryo.None }))
end

return extended