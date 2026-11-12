local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local TextLabel = require(ExperienceComponents.Components.TextLabel)
local SelectParent = require(ExperienceComponents.Components.Gamepad.SelectParent)
local constants = require(ExperienceComponents.constants)
local RadioButton = require(script.Parent.RadioButton)

local extended = Roact.Component:extend("RadioButtonField")

extended.defaultProps = {
	hasDivider = true,
	isSelected = false,
	isGamepadSelection = false,
	height = UDim.new(0, 56),
	buttonColor = constants.White,
	inactiveButtonColor = constants.Faded
}

function extended:init()
	self:setState({ isHovered = false })

	function self.setHoverState(isHovered: boolean)
		return function()
			self:setState({ isHovered = isHovered })
		end
	end
end

function extended.render(props)
	local props2 = props.props
	local state = props.state

	local createElement = Roact.createElement
	local v = {
		LayoutOrder = props2.layoutOrder,
		Size = UDim2.new(UDim.new(1, 0), props2.height),
		Selectable = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		[Roact.Event.MouseEnter] = props.setHoverState(true),
		[Roact.Event.MouseLeave] = props.setHoverState(false),
		[Roact.Event.Activated] = props2.onActivated
	}
	local v2 = {
		SelectParent = props2.isGamepadSelection and Roact.createElement(SelectParent),
		Field = 0,
		Divider = 0
	}

	local createElement2 = Roact.createElement
	local v3 = { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }

	local children = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		Label = 0,
		RadioButton = 0
	}

	local createElement3 = Roact.createElement
	local v4 = {
		LayoutOrder = 1,
		Text = props2.label,
		Size = UDim2.new(1, -32, 0, 0),
		Selectable = false,
		TextColor3 = 0,
		TextSize = 0,
		Font = 0
	}
	local textColor

	if props2.isSelected or state.isHovered then
		textColor = props2.buttonColor
	else
		textColor = props2.inactiveButtonColor
	end

	v4.TextColor3 = textColor

	v4.TextSize = props2.textSize
	v4.Font = props2.font
	children.Label = createElement3(TextLabel, v4)

	children.RadioButton = Roact.createElement(RadioButton, {
		layoutOrder = 2,
		isHovered = state.isHovered,
		isSelected = props2.isSelected,
		buttonColor = props2.buttonColor,
		inactiveButtonColor = props2.inactiveButtonColor,
		onActivated = props2.onActivated
	})
	v2.Field = createElement2("Frame", v3, children)

	v2.Divider = props2.hasDivider and Roact.createElement("Frame", {
		LayoutOrder = 3,
		Position = UDim2.new(0, 0, 1, -1),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = props2.buttonColor,
		BackgroundTransparency = 0.8
	})
	return createElement("ImageButton", v, v2)
end

return extended