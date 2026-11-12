local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local assets = require(ExperienceComponents.assets)
local constants = require(ExperienceComponents.constants)
local TextLabel = require(ExperienceComponents.Components.TextLabel)
local DropdownItem = require(script.DropdownItem)

local extended = Roact.Component:extend("Dropdown")

extended.defaultProps = {
	height = constants.TextSize * 2.5,
	isOpen = false,
	expandUp = false
}

function extended:init()
	local props = self.props

	local v = { isOpen = props.isOpen, width = 0 }

	self:setState(v)

	function self.onDropdownToggled()
		self:setState(function(p)
			return {
				isOpen = not p.isOpen
			}
		end)
	end

	function self.createItemActivatedListener(p: string)
		return function()
			self:setState({ item = p, isOpen = false })

			if props.onItemActivated then
				props.onItemActivated(p)
			end
		end
	end

	function self.onAbsoluteContentSizeChanged(p)
		self:setState(function(p2)
			if p2.width == v.width then
				return { width = p.AbsoluteContentSize.X }
			end
		end)
	end
end

function extended.render(props)
	local props2 = props.props
	local state = props.state

	local children = {}

	for i, item in ipairs(props2.items) do
		children[item] = Roact.createElement(DropdownItem, {
			text = item,
			layoutOrder = i,
			onActivated = props.createItemActivatedListener(item)
		})
	end

	local createElement = Roact.createElement
	local v = {
		Size = UDim2.fromOffset(0, props2.height),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1
	}

	local children2 = {
		Button = Roact.createElement("ImageButton", {
			BackgroundColor3 = constants.Dark,
			Size = UDim2.new(1, 0, 0, props2.height),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 2,
			[Roact.Event.Activated] = props.onDropdownToggled
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = constants.PaddingSmall,
				[Roact.Change.AbsoluteContentSize] = props.onAbsoluteContentSizeChanged
			}),
			Border = Roact.createElement("UIStroke", { Color = constants.Faded }),
			Corner = Roact.createElement("UICorner", { CornerRadius = constants.PaddingSmall }),
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = constants.PaddingSmall,
				PaddingRight = constants.PaddingSmall,
				PaddingBottom = constants.PaddingSmall,
				PaddingLeft = constants.PaddingSmall
			}),
			Label = Roact.createElement(TextLabel, {
				LayoutOrder = 1,
				Size = UDim2.fromOffset(state.width or 0, 0),
				Text = state.item or props2.defaultValue,
				AutomaticSize = Enum.AutomaticSize.XY
			}),
			Arrow = Roact.createElement(
				"Frame",
				{ LayoutOrder = 2, Size = UDim2.fromOffset(8, 8), BackgroundTransparency = 1 },
				{
					Icon = Roact.createElement("ImageLabel", {
						Image = assets.Caret,
						Size = UDim2.fromScale(1, 1),
						ScaleType = Enum.ScaleType.Fit,
						BackgroundTransparency = 1,
						Rotation = state.isOpen and 180 or 0
					})
				}
			)
		}),
		List = 0
	}

	local createElement2 = Roact.createElement
	local v2 = {
		Visible = state.isOpen,
		Size = UDim2.fromOffset(state.width + constants.Padding.Offset * 2, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = 0,
		AnchorPoint = 0,
		BackgroundColor3 = 0,
		BackgroundTransparency = 0.2
	}
	local position

	if props2.expandUp then
		position = UDim2.fromScale(0.5, 0)
	else
		position = UDim2.fromScale(0.5, 1)
	end

	v2.Position = position
	local anchorPoint

	if props2.expandUp then
		anchorPoint = Vector2.new(0.5, 1)
	else
		anchorPoint = Vector2.new(0.5, 0)
	end

	v2.AnchorPoint = anchorPoint
	v2.BackgroundColor3 = constants.Black
	children2.List = createElement2("Frame", v2, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		}),
		Border = Roact.createElement("UIStroke", { Color = constants.Faded }),
		Corner = Roact.createElement("UICorner", { CornerRadius = constants.PaddingSmall }),
		Items = Roact.createFragment(children)
	})
	return createElement("Frame", v, children2)
end

function extended.didUpdate(object, p)
	local props = object.props

	if props.isOpen ~= p.isOpen then
		object:setState({ isOpen = props.isOpen })
	end
end

return extended