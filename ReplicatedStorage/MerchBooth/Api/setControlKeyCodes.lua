local MerchBooth = script:FindFirstAncestor("MerchBooth")

local setControls = require(MerchBooth.Actions.setControls)

return function(object)
	local function setControlKeyCodes(p: string, p2)
		object:dispatch(setControls(p, p2))
	end

	return setControlKeyCodes
end