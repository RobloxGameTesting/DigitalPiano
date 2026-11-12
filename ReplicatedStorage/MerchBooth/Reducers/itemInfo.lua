local RunService = game:GetService("RunService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
local Cryo = require(MerchBooth.Packages.Cryo)
require(MerchBooth.types)
local setItemInfo = require(MerchBooth.Actions.setItemInfo)
local removeItemInfo = require(MerchBooth.Actions.removeItemInfo)
local updateItemInfo = require(MerchBooth.Actions.updateItemInfo)

local SetItemInfo = MerchBooth.Remote.SetItemInfo
local RemoveItemInfo = MerchBooth.Remote.RemoveItemInfo

return (Rodux.createReducer({}, {
	[setItemInfo.name] = function(p, p2)
		if RunService:IsServer() then
			SetItemInfo:FireAllClients(p2)
		end

		return Cryo.Dictionary.join(p, { [p2.itemId] = p2.info })
	end,
	[removeItemInfo.name] = function(p, p2)
		if RunService:IsServer() then
			RemoveItemInfo:FireAllClients(p2)
		end

		return Cryo.Dictionary.join(p, { [p2.itemId] = Cryo.None })
	end,
	[updateItemInfo.name] = function(p, p2)
		local v = p[p2.itemId]

		if not v then
			return p
		end

		return Cryo.Dictionary.join(p, {
			[p2.itemId] = Cryo.Dictionary.join(v, p2.info)
		})
	end
}))