local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local ContextActionBinding = require(ExperienceComponents.Components.ContextActionBinding)
local SelectParent = require(ExperienceComponents.Components.Gamepad.SelectParent)
local constants = require(script.Parent.constants)

local extended = Roact.Component:extend("RobloxModalButton")

local function shift(color: Color3, hoveredColorShift: number) -- 2 equivalent calls inferred from this helper
	local hsv, v, v2 = color:ToHSV()
	return Color3.fromHSV(hsv, v, (math.clamp(v2 * hoveredColorShift, 0, 1)))
end

extended.defaultProps = {
	layoutOrder = 0,
	isSolid = true,
	size = UDim2.fromScale(1, 1),
	usingGamepad = false,
	isGamepadSelection = false,
	primaryColor = constants.ButtonColor,
	accentColor = constants.TextColor,
	hoveredColorShift = 0.9
}

function extended:init()
	self:setState({ isHovered = false })

	function self.setHoverState(isHovered: boolean)
		return function()
			self:setState({ isHovered = isHovered })
		end
	end

	function self.getColors()
		local props = self.props

		if not self.state.isHovered then
			return { text = props.accentColor, background = props.primaryColor }
		end

		return {
			text = shift(props.accentColor, props.hoveredColorShift), -- inferred equivalent call
			background = shift(props.primaryColor, props.hoveredColorShift) -- inferred equivalent call
		}
	end
end

function extended.render(props)
	local props2 = props.props
	local colors = props.getColors()

	local createElement = Roact.createElement
	local v = {
		LayoutOrder = props2.layoutOrder,
		Size = props2.size,
		BackgroundTransparency = props2.isSolid and 0 or 1,
		BackgroundColor3 = colors.background,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		[Roact.Event.MouseEnter] = props.setHoverState(true),
		[Roact.Event.MouseLeave] = props.setHoverState(false),
		[Roact.Event.Activated] = props2.onActivated
	}
	local children = {
		SelectParent = props2.isGamepadSelection and Roact.createElement(SelectParent),
		Corner = Roact.createElement("UICorner", { CornerRadius = constants.PaddingSmall }),
		Outline = 0,
		ActionBinding = 0,
		Label = 0,
		GamepadIcon = 0
	}

	local createElement2 = Roact.createElement
	local color

	if props2.isSolid then
		color = colors.background
	else
		color = colors.text
	end

	children.Outline = createElement2("UIStroke", {
		Color = color,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})

	children.ActionBinding = props2.usingGamepad and Roact.createElement(ContextActionBinding, {
		inputTypes = { props2.gamepadKeyCode },
		callback = props2.onActivated
	})

	children.Label = Roact.createElement("TextLabel", {
		LayoutOrder = 1,
		Text = props2.text,
		Font = constants.TitleFont,
		TextSize = constants.TextSize,
		TextColor3 = colors.text,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1
	})

	children.GamepadIcon = props2.usingGamepad and Roact.createElement("ImageLabel", {
		LayoutOrder = 2,
		Image = "rbxassetid://8971710558",
		ImageColor3 = colors.text,
		Size = UDim2.fromScale(0.7, 0.7),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -constants.PaddingSmall.Offset, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5)
	}, {
		Label = Roact.createElement("TextLabel", {
			Text = props2.gamepadKeyCode.Name:gsub("Button", ""),
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = colors.background,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1
		})
	})
	return createElement("ImageButton", v, children)
end

return extended