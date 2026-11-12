local Players = game:GetService("Players")

local function setCharacterMovementEnabled(flag: boolean)
	local playerModule = Players.LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")

	if playerModule then
		local module = require(playerModule)
		module:GetControls():Enable(flag)
	end
end

return setCharacterMovementEnabled