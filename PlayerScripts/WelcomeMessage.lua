local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

local function getGameDisplayName()
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
	end)

	if success and type(result) == "table" and type(result.Name) == "string" and result.Name ~= "" then
		return result.Name
	end

	return game.Name
end

task.wait(8)

TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral"):DisplaySystemMessage("<font color=\"#FFD700\">[SYSTEM]</font> Welcome to <b>" .. getGameDisplayName() .. "</b>, " .. LocalPlayer.DisplayName .. "!<br/>We have upgraded our Piano System to support <b>88 Keys</b>.<br/>We hope you like it! 🎉")