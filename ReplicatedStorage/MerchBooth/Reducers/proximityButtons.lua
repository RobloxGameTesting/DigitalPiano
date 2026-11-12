local RunService = game:GetService("RunService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
local Cryo = require(MerchBooth.Packages.Cryo)
local addProximityButton = require(MerchBooth.Actions.addProximityButton)
local removeProximityButton = require(MerchBooth.Actions.removeProximityButton)

local AddProximityButton = MerchBooth.Remote.AddProximityButton
local RemoveProximityButton = MerchBooth.Remote.RemoveProximityButton

return (Rodux.createReducer({}, {
	[addProximityButton.name] = function(p, p2)
		if RunService:IsServer() then
			AddProximityButton:FireAllClients(p2.id, p2.adornee)
		end

		return Cryo.Dictionary.join(p, { [p2.adornee] = p2.id })
	end,
	[removeProximityButton.name] = function(p, p2)
		if RunService:IsServer() then
			RemoveProximityButton:FireAllClients(p2.adornee)
		end

		return Cryo.Dictionary.join(p, { [p2.adornee] = Cryo.None })
	end
}))