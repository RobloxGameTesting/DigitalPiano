local TextChatUtility = {}
TextChatUtility.gamesToVerifyTextChatServiceUpdates = {}

task.defer(function()
	local RunService = game:GetService("RunService")
	local TextChatService = game:GetService("TextChatService")
	TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral", 10)
	RunService:IsServer()
end)

function TextChatUtility.verifyCanUpdate(): boolean
	local gamesToVerifyTextChatServiceUpdates = TextChatUtility.gamesToVerifyTextChatServiceUpdates
	return not table.find(gamesToVerifyTextChatServiceUpdates, game.GameId)
end

return TextChatUtility