local HDAdminMain = _G.HDAdminMain
local ClientAPI = {}

function ClientAPI.SetTopbarTransparency(_, p)
	p = tonumber(p) or 0.5
end

function ClientAPI.SetTopbarEnabled(_, p)
	local v = type(p) ~= "boolean" or p

	local dashboard = HDAdminMain:GetModule("TopbarIcons").Dashboard

	if dashboard then
		dashboard:setEnabled(v)
	end
end

function ClientAPI.GetDashboardIcon(_)
	return HDAdminMain:GetModule("TopbarIcons").Dashboard
end

return ClientAPI