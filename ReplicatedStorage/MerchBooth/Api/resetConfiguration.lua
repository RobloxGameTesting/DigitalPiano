local resetConfig = require(script.Parent.Parent.Actions.resetConfig)

return function(object)
	local function resetConfiguration()
		object:dispatch(resetConfig())
	end

	return resetConfiguration
end