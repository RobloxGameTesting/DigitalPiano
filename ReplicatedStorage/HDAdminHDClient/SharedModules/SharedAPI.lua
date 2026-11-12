local HDAdminMain = _G.HDAdminMain
local SharedAPI = {}

function SharedAPI:GetRankName(p)
	return (HDAdminMain:GetModule("cf"):GetRankName(p))
end

function SharedAPI:GetRankId(p)
	return (HDAdminMain:GetModule("cf"):GetRankId(p))
end

function SharedAPI:Notice(p, p2)
	if HDAdminMain.player then
		if p2 then
			HDAdminMain:GetModule("Notices"):Notice("Notice", "Game Notice", p2)
		end
	else
		HDAdminMain:GetModule("cf"):Notice(p, "Game Notice", p2)
	end
end

function SharedAPI.Error(_, player, p)
	if HDAdminMain.player then
		if p then
			HDAdminMain:GetModule("Notices"):Notice("Error", "Game Notice", p)
		end
	else
		HDAdminMain.signals.Error:FireClient(player, { "Game Notice", p })
	end
end

return SharedAPI