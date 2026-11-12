local setConfig = require(script.Parent.Parent.Actions.setConfig)
require(script.Parent.Parent.Reducers.config)

return function(object, p)
	local v = p or game:GetService("RunService")

	local function configure(p2)
		assert(not v:IsServer(), "MerchBooth.configure must be called on the client")
		object:dispatch(setConfig(p2))
	end

	return configure
end