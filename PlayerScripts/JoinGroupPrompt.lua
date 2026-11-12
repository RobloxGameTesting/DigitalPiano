local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

task.wait(4)

local success, result = pcall(function()
	return LocalPlayer:IsInGroupAsync(14086245)
end)

if success and not result then
	pcall(function()
		GroupService:PromptJoinAsync(14086245)
	end)
end