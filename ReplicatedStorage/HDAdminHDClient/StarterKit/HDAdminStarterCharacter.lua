local ReplicatedStorage = game:GetService("ReplicatedStorage")
local main = require(ReplicatedStorage:WaitForChild("HDAdminSetup", 999)):GetMain()

main.humanoidRigType = (main.player.Character or main.player.CharacterAdded:Wait()):WaitForChild("Humanoid").RigType
wait(1)

for k, _ in pairs(main.commandSpeeds) do
	if not main.commandsActive[k] then
		continue
	end

	main.commandsActive[k] = nil
	main:GetModule("cf"):ActivateClientCommand(k)
end