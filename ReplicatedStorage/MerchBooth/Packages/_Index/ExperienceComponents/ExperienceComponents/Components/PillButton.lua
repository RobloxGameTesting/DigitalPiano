local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Otter = require(ExperienceComponents.Parent.Otter)
local Roact = require(ExperienceComponents.Parent.Roact)
local TextLabel = require(ExperienceComponents.Components.TextLabel)
local KeyCodeIcon = require(ExperienceComponents.Components.KeyCodeIcon)
local ContextActionBinding = require(ExperienceComponents.Components.ContextActionBinding)
local constants = require(ExperienceComponents.constants)

local extended = Roact.Component:extend("PillButton")

local defaultProps = {
	backgroundColor = constants.Black,
	borderColor = constants.Black,
	contentColor = constants.White,
	textSize = 16,
	font = Enum.Font.GothamMedium,
	size = UDim2.new(),
	automaticSize = Enum.AutomaticSize.XY,
	borderSize = 1,
	isVisible = true,
	isActive = true,
	isSelectable = true,
	spring = Otter.spring
}

local v = { buttonSize = UDim2.fromScale(1, 1), isHovered = false, isPressed = false }

extended.defaultProps = defaultProps

function extended:init()
	local binding, setTransparency = Roact.createBinding(self.props.isVisible and 0 or 1)
	self.transparency = binding
	self.setTransparency = setTransparency
	self.motor = Otter.createSingleMotor(self.transparency:getValue())
	self.motor:onStep(self.setTransparency)

	function self.setVisibility(flag: boolean)
		local props = self.props

		self.motor:setGoal(props.spring(flag and 0 or 1, constants.Springs.Zippy))
	end

	function self.onHover()
		local props = self.props

		self:setState({ isHovered = true })

		if props.onHovered then
			props.onHovered()
		end
	end

	function self.onHoverEnded()
		local props = self.props

		self:setState({ isHovered = false })

		if props.onHoverEnded then
			props.onHoverEnded()
		end
	end

	function self.onButtonSizeChanged(p)
		self:setState({
			buttonSize = UDim2.fromOffset(p.AbsoluteSize.X, p.AbsoluteSize.Y)
		})
	end

	function self.onInputBegan(_, p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			self:setState({ isPressed = true })
		end
	end

	function self.onInputEnded(_, p)
		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			self:setState({ isPressed = false })
		end
	end

	function self.onSelectionChanged(_, flag: boolean)
		if not self.isMounted then
			return
		end

		if flag then
			self.onHover()
		else
			self.onHoverEnded()
		end
	end

	function self.getTransparency(): number
		local state = self.state

		if state.isPressed then
			return 0.25
		end

		return if state.isHovered then 0 else 0.15
	end

	self:setState(v)
end

function extended.getDerivedStateFromProps(p, p2)
	local buttonSize

	if p.automaticSize == Enum.AutomaticSize.None then
		buttonSize = p.size
	else
		buttonSize = p2.buttonSize
	end

	return { buttonSize = buttonSize }
end

function extended.render(props)
	local props2 = props.props
	local state = props.state

	local mapped = Roact.joinBindings({ props.transparency, props2.transparency }):map(function(list)
		local transparency = props.getTransparency()
		local item = list[1]
		local item2 = list[2]

		if item2 then
			return item2
		end

		if item then
			return (math.max(transparency, item))
		end

		return transparency
	end)

	local v2 = props2.keyCode and props2.keyCode ~= Enum.KeyCode.Unknown

	return Roact.createElement(
		"Frame",
		{ LayoutOrder = props2.layoutOrder, Size = state.buttonSize, BackgroundTransparency = 1 },
		{
			Button = Roact.createElement("ImageButton", {
				Active = props2.isActive,
				Selectable = props2.isSelectable,
				Size = props2.size,
				AutomaticSize = props2.automaticSize,
				BackgroundColor3 = props2.backgroundColor,
				BackgroundTransparency = mapped,
				AutoButtonColor = false,
				[Roact.Change.AbsoluteSize] = props.onButtonSizeChanged,
				[Roact.Event.MouseEnter] = props.onHover,
				[Roact.Event.MouseLeave] = props.onHoverEnded,
				[Roact.Event.InputBegan] = props.onInputBegan,
				[Roact.Event.InputEnded] = props.onInputEnded,
				[Roact.Event.SelectionChanged] = props.onSelectionChanged,
				[Roact.Event.Activated] = props2.onActivated
			}, {
				BorderRadius = Roact.createElement("UICorner", { CornerRadius = UDim.new(0.5, 0) }),
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = constants.PaddingSmall,
					PaddingRight = constants.PaddingSmall,
					PaddingBottom = constants.PaddingSmall,
					PaddingLeft = constants.PaddingSmall
				}),
				Border = Roact.createElement("UIStroke", {
					Color = props2.borderColor,
					Thickness = props2.borderSize + (props2.isActive and state.isHovered and 2 or 0),
					Transparency = mapped
				}),
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = constants.PaddingSmall
				}),
				Icon = props2.icon and Roact.createElement("ImageLabel", {
					LayoutOrder = 1,
					Image = props2.icon,
					ImageColor3 = props2.contentColor,
					AutomaticSize = Enum.AutomaticSize.XY,
					ImageTransparency = mapped,
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(32, 32)
				}),
				Text = props2.text and Roact.createElement(TextLabel, {
					LayoutOrder = 2,
					Text = props2.text,
					TextSize = props2.textSize,
					TextColor3 = props2.contentColor,
					TextTransparency = mapped,
					Font = props2.font,
					LineHeight = 1,
					RichText = true,
					Size = UDim2.new(),
					AutomaticSize = Enum.AutomaticSize.XY
				})
			}),
			Keybinds = v2 and Roact.createFragment({
				ActionBinding = props2.isVisible and Roact.createElement(ContextActionBinding, {
					inputState = Enum.UserInputState.End,
					inputTypes = { props2.keyCode },
					callback = props2.onActivated
				}),
				KeyCodeIcon = Roact.createElement(KeyCodeIcon, {
					keyCode = props2.keyCode,
					transparency = mapped,
					anchorPoint = Vector2.new(0.5, 0.5)
				})
			}),
			Children = Roact.createFragment(props2[Roact.Children])
		}
	)
end

function extended:didMount()
	self.isMounted = true

	local props = self.props
	self.setVisibility(props.isVisible)
end

function extended.didUpdate(p, p2)
	local props = p.props

	if props.isVisible ~= p2.isVisible then
		p.setVisibility(props.isVisible)
	end
end

function extended:willUnmount()
	self.isMounted = false
	self.motor:stop()
end

return extended