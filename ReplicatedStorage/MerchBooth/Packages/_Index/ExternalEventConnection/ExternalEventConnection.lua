local Roact = require(script.Parent.Roact)

local extended = Roact.Component:extend("ExternalEventConnection")

function extended:init()
	self.connection = nil
end

function extended.render(p)
	return Roact.oneChild(p.props[Roact.Children])
end

function extended:didMount()
	self.connection = self.props.event:Connect(self.props.callback)
end

function extended:didUpdate(p)
	if self.props.event ~= p.event or self.props.callback ~= p.callback then
		self.connection:Disconnect()

		self.connection = self.props.event:Connect(self.props.callback)
	end
end

function extended:willUnmount()
	self.connection:Disconnect()

	self.connection = nil
end

return extended