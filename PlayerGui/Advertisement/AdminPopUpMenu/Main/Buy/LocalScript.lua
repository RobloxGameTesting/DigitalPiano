local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local parent = script.Parent
local adminPopUpMenu = parent:FindFirstAncestor("AdminPopUpMenu")
local LocalPlayer = Players.LocalPlayer

parent.MouseButton1Click:Connect(function()
	local currentGamePassId = parent:GetAttribute("CurrentGamePassId")

	if not currentGamePassId and adminPopUpMenu then
		currentGamePassId = adminPopUpMenu:GetAttribute("CurrentGamePassId")
	end

	local v = math.floor(tonumber(currentGamePassId) or 0)

	if v <= 0 then
		return
	end

	if adminPopUpMenu then
		adminPopUpMenu:SetAttribute("PurchasePromptedFromAd", true)
		adminPopUpMenu:SetAttribute("PromptedGamePassId", v)
	end

	MarketplaceService:PromptGamePassPurchase(LocalPlayer, v)
end)