local UserInputService = game:GetService("UserInputService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Roact = require(MerchBooth.Packages.Roact)
local ExternalEventConnection = require(MerchBooth.Packages.ExternalEventConnection)

local extended = Roact.Component:extend("FocusLost")

extended.defaultProps = { UserInputService = UserInputService }

function extended:init()
	function self.wasRefClicked(p): boolean
		local value = self.props.ref:getValue()

		local basePlayerGui = value and value:FindFirstAncestorWhichIsA("BasePlayerGui")

		if basePlayerGui then
			for _, v in ipairs(basePlayerGui:GetGuiObjectsAtPosition(p.Position.X, p.Position.Y)) do
				if v == value or v:IsDescendantOf(value) then
					return true
				end
			end
		end

		return false
	end

	function self.handleFocusLost(p)
		local props = self.props

		if
			(p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch)
			and not self.wasRefClicked(p)
		then
			props.callback()
		end
	end
end

function extended.render(p)
	local props = p.props

	return Roact.createFragment({
		InputEnded = Roact.createElement(ExternalEventConnection, {
			callback = p.handleFocusLost,
			event = props.UserInputService.InputEnded
		}),
		TouchTap = Roact.createElement(ExternalEventConnection, {
			callback = p.handleFocusLost,
			event = props.UserInputService.TouchTap
		})
	})
end

return extended