local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Otter = require(ExperienceComponents.Parent.Otter)
local Roact = require(ExperienceComponents.Parent.Roact)
local constants = require(ExperienceComponents.constants)
local PillButton = require(ExperienceComponents.Components.PillButton)

local extended = Roact.Component:extend("PulseButton")

extended.defaultProps = {
	isPulsing = true,
	isVisible = true,
	size = UDim2.fromOffset(48, 48),
	iconColor = constants.Black,
	backgroundColor = constants.White
}

function extended:init()
	local binding, setPulse = Roact.createBinding(1)
	self.pulse = binding
	self.setPulse = setPulse

	function self.startPulseLoop()
		local count = 0
		local function loop()
			local props = self.props

			if props.pulses and count >= props.pulses then
				return
			end

			if props.isVisible then
				local singleMotor = Otter.createSingleMotor(0)

				count += 1

				singleMotor:onStep(function(p: number)
					self.setPulse(p * 1)
				end)

				singleMotor:setGoal(Otter.spring(1, constants.Springs.Default))

				self.stopPulseMotor = singleMotor:onComplete(function()
					singleMotor:destroy()
					loop()
				end)
			end
		end

		self.stopPulseLoop()
		loop()
	end

	function self.stopPulseLoop()
		if self.stopPulseMotor then
			self.stopPulseMotor()
			self.stopPulseMotor = nil
		end
	end
end

function extended.render(p)
	local props = p.props

	local children = {}

	for i = 1, 3 do
		children["Ring" .. i] = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = p.pulse,
			BackgroundColor3 = props.backgroundColor,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			ZIndex = -1
		}, {
			Scale = Roact.createElement("UIScale", {
				Scale = p.pulse:map(function(p2)
					return 1 + p2 * (i / 3 * 1.75 + 1 - 1)
				end)
			}),
			Corner = Roact.createElement("UICorner", { CornerRadius = UDim.new(0.5, 0) })
		})
	end

	return Roact.createElement(PillButton, {
		layoutOrder = props.layoutOrder,
		size = props.size,
		icon = props.icon,
		keyCode = props.activationKeyCode,
		backgroundColor = props.backgroundColor,
		borderColor = props.backgroundColor,
		contentColor = props.iconColor,
		isVisible = props.isVisible,
		isSelectable = props.isVisible,
		isActive = props.isVisible,
		onActivated = props.onActivated
	}, {
		Rings = props.isPulsing and Roact.createFragment(children)
	})
end

function extended.didMount(p)
	p.startPulseLoop()
end

function extended.didUpdate(data, p)
	local props = data.props

	if props.pulses ~= p.pulses then
		data.startPulseLoop()
	end

	if props.isVisible ~= p.isVisible then
		if props.isVisible then
			data.startPulseLoop()
		else
			data.stopPulseLoop()
		end
	end
end

function extended.willUnmount(p)
	p.stopPulseLoop()
end

return extended