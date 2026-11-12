local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local assets = require(ExperienceComponents.assets)
local constants = require(ExperienceComponents.constants)
local TextLabel = require(script.Parent.TextLabel)

local extended = Roact.Component:extend("KeyCodeIcon")

extended.defaultProps = {
	position = UDim2.fromScale(1, 1),
	anchorPoint = Vector2.new(0.4, 0.4),
	size = 24,
	transparency = 0
}

function extended.render(p)
	local props = p.props

	if not props.keyCode then
		return
	end

	local image = assets.Gamepad[props.keyCode.Name]

	if image then
		return Roact.createElement("ImageLabel", {
			Image = image,
			ImageTransparency = props.transparency,
			Size = UDim2.fromOffset(props.size, props.size),
			Position = props.position,
			AnchorPoint = props.anchorPoint,
			BackgroundTransparency = 1
		})
	end

	return Roact.createElement("ImageLabel", {
		Image = assets.KeyBacking,
		ImageTransparency = props.transparency,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(6, 6, 26, 26),
		Size = UDim2.fromOffset(props.size, props.size),
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		BackgroundTransparency = 1
	}, {
		Key = Roact.createElement(TextLabel, {
			Text = props.keyCode.Name,
			TextTransparency = props.transparency,
			Size = UDim2.fromScale(1, 1),
			Font = constants.HeaderFont,
			TextColor3 = constants.White,
			TextScaled = false,
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center
		})
	})
end

return extended