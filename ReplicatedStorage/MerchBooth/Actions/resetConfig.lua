local Rodux = require(script.Parent.Parent.Packages.Rodux)

local function resetConfig()
	return {}
end

return Rodux.makeActionCreator(script.Name, resetConfig)