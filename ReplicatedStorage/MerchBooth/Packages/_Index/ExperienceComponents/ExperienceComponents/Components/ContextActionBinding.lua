local ContextActionService = game:GetService("ContextActionService")

local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local plugHoles = require(ExperienceComponents.Modules.plugHoles)

local function arrayEquals(inputTypes, inputTypes2): boolean -- 1 equivalent call inferred from this helper
	for i, item in ipairs(inputTypes) do
		if inputTypes2[i] ~= item then
			return false
		end
	end

	return true
end

local extended = Roact.Component:extend("ContextActionBinding")

local v = 1

extended.defaultProps = {
	priority = Enum.ContextActionPriority.Medium,
	ContextActionService = ContextActionService
}

function extended:init()
	function self.callback(_, _, p)
		local props = self.props

		if not props.inputState or props.inputState == p.UserInputState then
			props.callback(p)
		end
	end

	function self.bind()
		local props = self.props

		local v2 = plugHoles(props.inputTypes)

		props.ContextActionService:BindActionAtPriority(
			self.actionName,
			self.callback,
			false,
			props.priority.Value,
			table.unpack(v2)
		)
	end

	function self.unbind()
		self.props.ContextActionService:UnbindAction(self.actionName)
	end
end

function extended.render(_): nil
	return nil
end

function extended:didMount()
	local props = self.props
	local actionName

	if props.name then
		actionName = props.name
	else
		actionName = "ContextActionBinding" .. v
	end

	self.actionName = actionName
	v += 1

	self.bind()
end

function extended.didUpdate(data, p)
	local props = data.props

	if props ~= p and not arrayEquals(props.inputTypes, p.inputTypes) then -- inferred equivalent call
		data.unbind()
		data.bind()
	end
end

function extended.willUnmount(p)
	p.unbind()
end

return extended