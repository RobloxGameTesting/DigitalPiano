local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local success, result = pcall(function()
	return PolicyService:GetPolicyInfoForPlayerAsync(LocalPlayer)
end)

if success and result then
	local allowedExternalLinkReferences = result.AllowedExternalLinkReferences
	local v = { "X", "Discord", "YouTube" }
	local count = 0

	for _, allowedExternalLinkReference in pairs(allowedExternalLinkReferences) do
		if table.find(v, allowedExternalLinkReference) then
			count += 1
		end
	end

	if count < #v then
		script.Parent.Text = "See HD Admin's description (in Marketplace) for updates"
	end
end