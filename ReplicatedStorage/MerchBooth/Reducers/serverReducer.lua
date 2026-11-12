local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
local itemInfo = require(script.Parent.itemInfo)
local proximityButtons = require(script.Parent.proximityButtons)

return (Rodux.combineReducers({ itemInfo = itemInfo, proximityButtons = proximityButtons }))