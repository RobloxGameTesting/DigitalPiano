local Players = game:GetService("Players")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
require(MerchBooth.Reducers.reducer)

local extended = Roact.Component:extend("TrackCharacterPosition")

extended.defaultProps = { Players = Players }

function extended:init()
	self.isMounted = false

	function self.beginTrackingPosition()
		local props = self.props

		task.spawn(function()
			while props.adornee and self.isMounted do
				local humanoid = self.getHumanoid()
				local rootPart = humanoid and humanoid.RootPart

				if
					rootPart
					and (rootPart.Position - props.adornee.Position).Magnitude > props.config.proximityButtonActivationDistance
				then
					props.onDistanceExceeded()
				end

				task.wait()
			end
		end)
	end

	function self.getHumanoid()
		local localPlayer = self.props.Players.LocalPlayer
		local character = localPlayer and localPlayer.Character

		if character then
			return character:FindFirstChild("Humanoid")
		end

		return nil
	end
end

function extended.render(_): nil
	return nil
end

function extended:didMount()
	self.isMounted = true
	self.beginTrackingPosition()
end

function extended:willUnmount()
	self.isMounted = false
end

local function mapStateToProps(p)
	return { config = p.config }
end

return RoactRodux.connect(mapStateToProps)(extended)