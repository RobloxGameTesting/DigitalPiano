local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
local serverReducer = require(MerchBooth.Reducers.serverReducer)

return (Rodux.Store.new(serverReducer, nil, { Rodux.thunkMiddleware }))