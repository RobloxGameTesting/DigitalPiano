local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local constants = require(script.Parent.constants)
local SelectionGroup = require(ExperienceComponents.Components.Gamepad.SelectionGroup)
local RobloxModalButton = require(script.Parent.RobloxModalButton)

local extended = Roact.Component:extend("RobloxModal")

extended.defaultProps = {
	width = UDim.new(0, 350),
	usingGamepad = false,
	buttonHeight = 32,
	cancelPrimaryColor = constants.BackgroundColor,
	cancelAccentColor = constants.TextColor,
	acceptPrimaryColor = constants.ButtonColor,
	acceptAccentColor = constants.BackgroundColor
}

function extended.render(p)
	local props = p.props
	local v = props[Roact.Children]

	return Roact.createElement(
		"Frame",
		{
			BackgroundColor3 = constants.BackgroundColor,
			BorderSizePixel = 0,
			Size = UDim2.new(props.width, UDim.new(0, 0)),
			AutomaticSize = Enum.AutomaticSize.Y
		},
		{
			SelectionGroup = Roact.createElement(SelectionGroup),
			Corner = Roact.createElement("UICorner", { CornerRadius = constants.Padding }),
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = constants.Padding
			}),
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = constants.Padding,
				PaddingRight = constants.Padding,
				PaddingBottom = constants.Padding,
				PaddingLeft = constants.Padding
			}),
			Title = Roact.createElement("TextLabel", {
				LayoutOrder = 1,
				Text = props.title,
				Font = constants.TitleFont,
				TextSize = constants.TitleSize,
				TextColor3 = constants.TitleColor,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextWrapped = true,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y
			}),
			Divider = Roact.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundTransparency = 0.9,
				BackgroundColor3 = constants.TitleColor,
				BorderSizePixel = 0
			}),
			Children = v and Roact.createElement(
				"Frame",
				{
					LayoutOrder = 3,
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1
				},
				v
			),
			Description = Roact.createElement("TextLabel", {
				LayoutOrder = 4,
				Font = constants.Font,
				TextSize = constants.TextSize,
				Text = props.description,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextColor3 = constants.TextColor,
				TextWrapped = true,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y
			}),
			Buttons = Roact.createElement(
				"Frame",
				{
					LayoutOrder = 5,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, props.buttonHeight)
				},
				{
					Layout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = constants.Padding
					}),
					CancelButton = Roact.createElement(RobloxModalButton, {
						layoutOrder = 1,
						text = props.cancelText,
						isSolid = false,
						size = UDim2.new(0.5, -constants.Padding.Offset / 2, 1, 0),
						usingGamepad = props.usingGamepad,
						gamepadKeyCode = Enum.KeyCode.ButtonB,
						primaryColor = props.cancelPrimaryColor,
						accentColor = props.cancelAccentColor,
						hoveredColorShift = 1.5,
						onActivated = props.onCancel
					}),
					AcceptButton = Roact.createElement(RobloxModalButton, {
						layoutOrder = 2,
						text = props.acceptText,
						size = UDim2.new(0.5, -constants.Padding.Offset / 2, 1, 0),
						usingGamepad = props.usingGamepad,
						gamepadKeyCode = Enum.KeyCode.ButtonA,
						primaryColor = props.acceptPrimaryColor,
						accentColor = props.acceptAccentColor,
						hoveredColorShift = 0.8,
						isGamepadSelection = true,
						onActivated = props.onAccept
					})
				}
			)
		}
	)
end

return extended