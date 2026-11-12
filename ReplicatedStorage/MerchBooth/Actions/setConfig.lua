local Rodux = require(script.Parent.Parent.Packages.Rodux)

local function setConfig(config)
	return { config = config }
end

return Rodux.makeActionCreator(script.Name, setConfig)