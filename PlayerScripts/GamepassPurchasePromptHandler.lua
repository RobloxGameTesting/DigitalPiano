local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes"):WaitForChild("PromptGamePassPurchaseRemote").OnClientEvent:Connect(function(p)
	local v = math.floor(tonumber(p) or 0)

	if v <= 0 then
		return
	end

	MarketplaceService:PromptGamePassPurchase(LocalPlayer, v)
end)