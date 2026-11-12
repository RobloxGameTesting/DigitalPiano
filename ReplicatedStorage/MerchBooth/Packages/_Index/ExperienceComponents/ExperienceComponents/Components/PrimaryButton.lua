local Roact = require(script.Parent.Parent.Parent.Roact)
local constants = require(script.Parent.Parent.constants)
local SelectParent = require(script.Parent.Gamepad.SelectParent)

local extended = Roact.Component:extend("PrimaryButton")

extended.defaultProps = {
	isEnabled = true,
	isGamepadSelection = false,
	isSolidColor = true,
	size = UDim2.fromScale(1, 0),
	automaticSize = Enum.AutomaticSize.Y,
	textSize = constants.TextSize,
	padding = constants.Padding,
	backgroundColor = constants.White,
	inactiveBackgroundColor = constants.Faded,
	contentColor = constants.Black,
	inactiveContentColor = constants.White,
	cornerRadius = constants.PaddingSmall,
	font = constants.HeaderFont
}

function extended:init()
	function self.getBackgroundColor()
		local props = self.props

		if not props.isSolidColor then
			return props.contentColor
		end

		if props.isEnabled then
			return props.backgroundColor
		end

		return props.inactiveBackgroundColor
	end

	function self.getContentColor()
		local props = self.props

		if not props.isSolidColor then
			return props.backgroundColor
		end

		if props.isEnabled then
			return props.contentColor
		end

		return props.inactiveContentColor
	end
end

function extended.render(props)
	local props2 = props.props

	local contentColor = props.getContentColor()

	local createElement = Roact.createElement
	local v = {
		["LayoutOrder"] = props2.layoutOrder,
		BackgroundColor3 = props.getBackgroundColor(),
		Size = props2.size,
		AutomaticSize = props2.automaticSize,
		BorderSizePixel = 0,
		Selectable = props2.isEnabled,
		AutoButtonColor = props2.isEnabled
	}
	local activated = Roact.Event.Activated
	local v2

	if props2.isEnabled then
		v2 = props2.onActivated
	end

	v[activated] = v2
	return createElement("ImageButton", v, {
		GamepadSelection = props2.isGamepadSelection and Roact.createElement(SelectParent),
		Corner = Roact.createElement("UICorner", { CornerRadius = props2.cornerRadius }),
		Border = not props2.isSolidColor and Roact.createElement("UIStroke", {
			Color = contentColor
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = props2.padding,
			PaddingRight = props2.padding,
			PaddingBottom = props2.padding,
			PaddingLeft = props2.padding
		}),
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = constants.PaddingMicro
		}),
		Icon = props2.icon and Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			Image = props2.icon,
			ImageColor3 = contentColor,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(props2.textSize, props2.textSize)
		}),
		Text = Roact.createElement("TextLabel", {
			LayoutOrder = 2,
			Text = props2.text,
			TextSize = props2.textSize,
			Font = props2.font,
			TextColor3 = contentColor,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1
		})
	})
end

return extended