local RunService = game:GetService("RunService")
game:GetService("GroupService")
game:GetService("Players")

if not RunService:IsStudio() then
	local VERSION = require(script.Parent.VERSION)
	print(`🍍 Running TopbarPlus {VERSION} by ForeverHD`)
end

return {}