local MarketplaceService = game:GetService("MarketplaceService")

local function getProductInfoAsync(p, p2)
	return MarketplaceService:GetProductInfo(p, p2)
end

return getProductInfoAsync