local RunService = game:GetService("RunService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local t = require(MerchBooth.Packages.t)
local addProximityButton = require(MerchBooth.Actions.addProximityButton)

local union = t.union(t.instanceIsA("BasePart"), t.instanceIsA("Model"), t.instanceIsA("Attachment"))

return function(object)
	local function addProximityButton2(p, p2: number)
		assert(RunService:IsServer(), "MerchBooth.addProximityButton must be called on the server")
		assert(
			union(p),
			"Bad argument #1 to MerchBooth.addProximityButton: expected a BasePart, Model or Attachment instance"
		)

		assert(t.number(p2), "Bad argument #2 to MerchBooth.addProximityButton: expected a number")

		object:dispatch(addProximityButton(tostring(p2), p))
	end

	return addProximityButton2
end