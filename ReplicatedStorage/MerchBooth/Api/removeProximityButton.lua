local RunService = game:GetService("RunService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local t = require(MerchBooth.Packages.t)
local removeProximityButton = require(MerchBooth.Actions.removeProximityButton)

local union = t.union(t.instanceIsA("BasePart"), t.instanceIsA("Model"), t.instanceIsA("Attachment"))

return function(object)
	local function removeProximityButton2(p)
		assert(RunService:IsServer(), "MerchBooth.removeProximityButton must be called on the server")
		assert(
			union(p),
			"Bad argument #1 to MerchBooth.removeProximityButton: expected a BasePart, Model or Attachment instance"
		)

		object:dispatch(removeProximityButton(p))
	end

	return removeProximityButton2
end