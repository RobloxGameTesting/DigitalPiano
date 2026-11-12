local RunService = game:GetService("RunService")

return function(object, object2)
	local function getItems()
		if RunService:IsServer() then
			return object:getState().itemInfo
		end

		return object2:getState().server.itemInfo
	end

	return getItems
end