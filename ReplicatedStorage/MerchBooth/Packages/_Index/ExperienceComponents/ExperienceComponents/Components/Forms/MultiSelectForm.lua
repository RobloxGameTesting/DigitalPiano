local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local ScrollingFrame = require(ExperienceComponents.Components.ScrollingFrame)
local PrimaryButton = require(ExperienceComponents.Components.PrimaryButton)
local RadioButtonField = require(script.Parent.RadioButtonField)

local extended = Roact.Component:extend("MultiSelectForm")

extended.defaultProps = {
	submitText = "Submit",
	size = UDim2.fromScale(1, 1),
	applyButtonHeight = 48
}

function extended:init()
	function self.onSelectionChanged(currentOption)
		return function()
			local props = self.props

			self:setState({ currentOption = currentOption })

			if props.onSelectionChanged then
				props.onSelectionChanged(currentOption)
			end
		end
	end

	function self.onSubmit()
		local props = self.props
		local state = self.state

		if props.onSubmit then
			props.onSubmit(state.currentOption)
		end
	end

	function self.createOptionFields()
		local props = self.props
		local state = self.state
		local children = {}

		for i, option in ipairs(props.options) do
			children["Option" .. i] = Roact.createElement(RadioButtonField, {
				label = option.text,
				layoutOrder = i,
				hasDivider = i ~= #props.options,
				isGamepadSelection = i == 1,
				isSelected = state.currentOption == option,
				buttonColor = props.buttonColor,
				inactiveButtonColor = props.inactiveButtonColor,
				textSize = props.textSize,
				font = props.font,
				onActivated = self.onSelectionChanged(option)
			})
		end

		return Roact.createFragment(children)
	end
end

function extended.render(props)
	local props2 = props.props

	return Roact.createElement(
		"Frame",
		{ LayoutOrder = props2.layoutOrder, Size = props2.size, BackgroundTransparency = 1 },
		{
			Layout = Roact.createElement("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
			Options = Roact.createElement(ScrollingFrame, {
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 1, -props2.applyButtonHeight)
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Fields = props.createOptionFields()
			}),
			Submit = Roact.createElement(PrimaryButton, {
				layoutOrder = 2,
				size = UDim2.new(1, 0, 0, props2.applyButtonHeight),
				automaticSize = Enum.AutomaticSize.None,
				text = props2.submitText,
				onActivated = props.onSubmit,
				backgroundColor = props2.buttonColor,
				contentColor = props2.buttonTextColor,
				textSize = props2.textSize,
				cornerRadius = props2.cornerRadius,
				font = props2.buttonFont
			})
		}
	)
end

function extended.didMount(object)
	local props = object.props

	for _, option in ipairs(props.options) do
		if props.default == option then
			object:setState({ currentOption = option })
		end
	end
end

return extended