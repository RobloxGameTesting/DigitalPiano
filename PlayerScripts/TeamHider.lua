local ReplicatedStorage = game.ReplicatedStorage
local Teams = game.Teams

local function SetTeamVisibility(p, p2)
	if p2 then
		p.Parent = ReplicatedStorage
	else
		p.Parent = Teams
	end
end

game.ReplicatedStorage.HideTeam.OnClientEvent:Connect(SetTeamVisibility)