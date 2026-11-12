local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local assets = require(MerchBooth.assets)
local styles = require(MerchBooth.styles)

local extended = Roact.Component:extend("GamepadLegendLabel")

extended.defaultProps = { buttonSize = UDim2.fromOffset(32, 32) }

function extended.render(p)
	local props = p.props

	return Roact.createElement(
		"Frame",
		{
			LayoutOrder = props.layoutOrder,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1
		},
		{
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = styles.PaddingSmall
			}),
			ButtonIcon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Image = assets.Gamepad[props.button.Name],
				BackgroundTransparency = 1
			}),
			Label = Roact.createElement(ExperienceComponents.TextLabel, {
				LayoutOrder = 2,
				Text = props.text,
				Size = UDim2.fromScale(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY
			})
		}
	)
end

return extended