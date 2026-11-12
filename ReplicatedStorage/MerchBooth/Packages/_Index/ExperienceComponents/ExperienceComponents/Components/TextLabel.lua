local Cryo = require(script.Parent.Parent.Parent.Cryo)
local Roact = require(script.Parent.Parent.Parent.Roact)
local constants = require(script.Parent.Parent.constants)

local extended = Roact.Component:extend("TextLabel")

extended.defaultProps = {
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextScaled = true,
	TextWrapped = true,
	Size = UDim2.fromScale(1, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	TextSize = constants.TextSize,
	Font = constants.Font,
	LineHeight = constants.LineHeight,
	TextColor3 = constants.White
}

function extended.render(p)
	local joined = Cryo.Dictionary.join({
		TextSize = Roact.createElement("UITextSizeConstraint", {
			MaxTextSize = p.props.TextSize,
			MinTextSize = 12
		})
	}, p.props[Roact.Children] or {})

	local v = Cryo.Dictionary.join(p.props, { [Roact.Children] = Cryo.None })

	return Roact.createElement("TextLabel", v, joined)
end

return extended