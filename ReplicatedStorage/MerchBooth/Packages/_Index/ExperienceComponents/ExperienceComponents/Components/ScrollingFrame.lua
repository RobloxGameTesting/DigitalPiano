local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)

local extended = Roact.Component:extend("ScrollingFrame")

extended.defaultProps = {
	Selectable = false,
	Size = UDim2.fromScale(1, 1),
	CanvasSize = UDim2.fromScale(1, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ScrollBarThickness = 3,
	BackgroundTransparency = 1,
	BorderSizePixel = 0
}

function extended.render(p)
	return Roact.createElement("ScrollingFrame", p.props)
end

return extended