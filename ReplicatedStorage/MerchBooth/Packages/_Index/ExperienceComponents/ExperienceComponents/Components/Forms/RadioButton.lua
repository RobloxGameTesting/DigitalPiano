local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local assets = require(ExperienceComponents.assets)
local constants = require(ExperienceComponents.constants)

local extended = Roact.Component:extend("RadioButton")

extended.defaultProps = {
	isSelected = false,
	isHovered = false,
	size = UDim2.fromOffset(24, 24),
	buttonColor = constants.White,
	inactiveButtonColor = constants.Faded
}

function extended:init()
	function self.onActivated()
		local props = self.props

		if not props.isSelected and props.onActivated then
			props.onActivated()
		end
	end

	function self.onHoverChanged(flag: boolean)
		return function()
			local props = self.props

			if props.onHoverChanged then
				props.onHoverChanged(flag)
			end
		end
	end
end

function extended.render(props)
	local props2 = props.props

	local createElement = Roact.createElement
	local v = {
		["LayoutOrder"] = nil,
		["LayoutOrder"] = nil,
		["LayoutOrder"] = nil,
		["LayoutOrder"] = nil,
		["LayoutOrder"] = nil,
		LayoutOrder = props2.layoutOrder,
		Selectable = false,
		Size = props2.size,
		Image = assets.RadioButtonOuter
	}
	local imageColor

	if props2.isSelected or props2.isHovered then
		imageColor = props2.buttonColor
	else
		imageColor = props2.inactiveButtonColor
	end

	v.ImageColor3 = imageColor
	v.BackgroundTransparency = 1
	v[Roact.Event.Activated] = props.onActivated
	v[Roact.Event.MouseEnter] = props.onHoverChanged(true)
	v[Roact.Event.MouseLeave] = props.onHoverChanged(false)
	return createElement("ImageButton", v, {
		SelectionIndicator = props2.isSelected and Roact.createElement("ImageLabel", {
			Image = assets.RadioButtonInner,
			Size = UDim2.fromScale(2 / 3, 2 / 3),
			ImageColor3 = props2.buttonColor,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1
		})
	})
end

return extended