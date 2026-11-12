local merchBooth = script:FindFirstAncestor("MerchBooth")

local module = require(merchBooth)
local assets = require(merchBooth.assets)
local preloadAssets = require(merchBooth.Modules.preloadAssets)
preloadAssets()(assets)
module.setEnabled(true)