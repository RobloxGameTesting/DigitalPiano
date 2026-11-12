local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
local reducer = require(MerchBooth.Reducers.reducer)

return (Rodux.Store.new(reducer, nil, { Rodux.thunkMiddleware }))