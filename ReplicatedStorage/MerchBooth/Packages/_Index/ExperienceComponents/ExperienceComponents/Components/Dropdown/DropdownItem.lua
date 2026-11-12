local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local constants = require(ExperienceComponents.constants)
local TextLabel = require(ExperienceComponents.Components.TextLabel)

local extended = Roact.Component:extend("DropdownItem")

function extended:init()
	self:setState({ isHovered = false })

	function self.onHover()
		self:setState({ isHovered = true })
	end

	function self.onHoverEnd()
		self:setState({ isHovered = false })
	end
end

function extended.render(props)
	local props2 = props.props
	local state = props.state

	return Roact.createElement("ImageButton", {
		LayoutOrder = props2.layoutOrder,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = constants.Grey,
		BackgroundTransparency = state.isHovered and 0.5 or 1,
		[Roact.Event.MouseEnter] = props.onHover,
		[Roact.Event.MouseLeave] = props.onHoverEnd,
		[Roact.Event.Activated] = props2.onActivated
	}, {
		Corner = Roact.createElement("UICorner", { CornerRadius = constants.PaddingSmall }),
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = constants.PaddingSmall,
			PaddingRight = constants.PaddingSmall,
			PaddingBottom = constants.PaddingSmall,
			PaddingLeft = constants.PaddingSmall
		}),
		Label = Roact.createElement(TextLabel, { Text = props2.text })
	})
end

return extended