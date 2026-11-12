local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Icon = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Icon"))
local SocialService = game:GetService("SocialService")
local LocalPlayer = game.Players.LocalPlayer

local function onButtonPressed()
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(LocalPlayer)
	end)

	if success and result == true then
		SocialService:PromptGameInvite(LocalPlayer)
	end
end

Icon.new():setName("InviteFriendsTopbar"):setImage(95669748730510):setImageScale(1):setCaption("Invite your friends to join!"):align("Right"):setOrder(2):oneClick().selected:Connect(function()
	local success, result = pcall(function()
		return SocialService:CanSendGameInviteAsync(LocalPlayer)
	end)

	if success and result == true then
		SocialService:PromptGameInvite(LocalPlayer)
	end
end)