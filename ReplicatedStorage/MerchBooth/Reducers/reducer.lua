local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
local ui = require(script.Parent.ui)
local config = require(script.Parent.config)
local controls = require(script.Parent.controls)
local device = require(script.Parent.device)
local serverReducer = require(script.Parent.serverReducer)

return (Rodux.combineReducers({
	ui = ui,
	config = config,
	controls = controls,
	device = device,
	server = serverReducer
}))