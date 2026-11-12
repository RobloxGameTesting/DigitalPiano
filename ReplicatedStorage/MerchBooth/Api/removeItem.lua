local RunService = game:GetService("RunService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local t = require(MerchBooth.Packages.t)
local removeItemInfo = require(MerchBooth.Actions.removeItemInfo)

return function(object)
	local function removeItem(p: number)
		assert(RunService:IsServer(), "MerchBooth.removeItemAsync must be called on the server")
		assert(t.number(p), "Bad argument #1 to MerchBooth.removeItemAsync: expected a number")

		object:dispatch(removeItemInfo((tostring(p))))
	end

	return removeItem
end