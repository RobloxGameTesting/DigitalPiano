local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local ExternalEventConnection = require(ExperienceComponents.Parent.ExternalEventConnection)
local onInstanceLoaded = require(ExperienceComponents.Modules.onInstanceLoaded)
local getCurrentDevice = require(ExperienceComponents.Modules.getCurrentDevice)
local enums = require(ExperienceComponents.enums)

local extended = Roact.Component:extend("SelectParent")

extended.defaultProps = {
	playerGuiClass = "PlayerGui",
	GuiService = GuiService,
	UserInputService = UserInputService
}

function extended:init()
	self.ref = Roact.createRef()

	function self.setCurrentDevice()
		local lastInputType = self.props.UserInputService:GetLastInputType() or Enum.UserInputType.Keyboard

		self:setState({
			device = getCurrentDevice(lastInputType)
		})
	end
end

function extended.render(props)
	local props2 = props.props

	return Roact.createElement("Folder", { [Roact.Ref] = props.ref }, {
		LastInputTypeChanged = Roact.createElement(ExternalEventConnection, {
			event = props2.UserInputService.LastInputTypeChanged,
			callback = props.setCurrentDevice
		})
	})
end

function extended.didUpdate(p, _, p2)
	local state = p.state
	local props = p.props

	if state ~= p2 and state.device == enums.Device.Gamepad then
		props.GuiService.SelectedObject = state.selection
	end
end

function extended.didMount(object)
	local props = object.props
	local value = object.ref:getValue()

	object.setCurrentDevice()

	onInstanceLoaded(value, function()
		if not value:FindFirstAncestorOfClass(props.playerGuiClass) then
			return
		end

		object:setState({ selection = value.Parent })
	end)
end

return extended