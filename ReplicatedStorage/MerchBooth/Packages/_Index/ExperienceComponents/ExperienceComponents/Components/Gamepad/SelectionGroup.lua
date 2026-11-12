local GuiService = game:GetService("GuiService")

local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Roact = require(ExperienceComponents.Parent.Roact)
local onInstanceLoaded = require(ExperienceComponents.Modules.onInstanceLoaded)

local v = 1

local extended = Roact.Component:extend("SelectionGroup")

extended.defaultProps = { GuiService = GuiService }

function extended:init()
	self.groupName = "SelectionGroup" .. v
	self.ref = Roact.createRef()

	v += 1
end

function extended.render(p)
	return Roact.createElement("Folder", { [Roact.Ref] = p.ref })
end

function extended.didMount(data)
	local props = data.props
	local value = data.ref:getValue()

	onInstanceLoaded(value, function()
		props.GuiService:AddSelectionParent(data.groupName, value.Parent)
	end)
end

function extended.willUnmount(p)
	p.props.GuiService:RemoveSelectionGroup(p.groupName)
end

return extended