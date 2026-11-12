local HDAdminMain = _G.HDAdminMain

local v = 0

local v2 = {
	[HDAdminMain.gui.MainFrame] = 0.78,
	[HDAdminMain.gui.MenuTemplates.Template5] = 0.78,
	[HDAdminMain.gui.MenuTemplates.Template6] = 0.78,
	[HDAdminMain.gui.MenuTemplates.Template7] = 0.78,
	[HDAdminMain.gui.MenuTemplates.Template9] = 0.78,
	[HDAdminMain.gui.MenuTemplates.Template10] = 1.17,
	[HDAdminMain.gui.MenuTemplates.Template11] = 1.17,
	[HDAdminMain.gui.MenuTemplates.Template12] = 0.78,
	[HDAdminMain.gui.MenuTemplates.Template16] = 0.78
}

local _ = {
	Phone = 0.9,
	PhoneVertical = 0.5,
	Tablet = 0.7,
	TabletVertical = 0.6,
	Computer = 0.6
}

local function updateUIs()
	local _parent = HDAdminMain.gui.Parent
	local v3 = HDAdminMain.gui.AbsoluteSize.Y > HDAdminMain.gui.AbsoluteSize.X
	local v4 = HDAdminMain.device == "Mobile"

	local v5 = v4 and (HDAdminMain.tablet and (v3 and 0.6 or 0.7) or v3 and 0.5 or 0.9) or 0.6
	local v6 = v3 and v4

	for k, v7 in pairs(v2) do
		local v8

		if v7 > 1 then
			v8 = v5 / 1.5
		else
			v8 = v5
		end

		k.Position = UDim2.new(0, 0, (1 - v8) / 2, 0)
		k.Size = UDim2.new(0, 0, v8, 0)
		local v9 = k.AbsoluteSize.Y * v7
		local customYScalePos = k:GetAttribute("CustomYScalePos")

		k.Position = UDim2.new(
			(v6 or not customYScalePos) and 0.5 or customYScalePos,
			-v9 / 2,
			k.Position.Y.Scale,
			k.Position.Y.Offset
		)
		k.Size = UDim2.new(0, v9, k.Size.Y.Scale, k.Size.Y.Offset)
	end
end

local function screenChanged() -- 1 equivalent call inferred from this helper
	v += 1
	wait(0.5)
	v -= 1

	if v == 0 then
		updateUIs()

		HDAdminMain:GetModule("PageAbout"):CreateCredits()
	end
end

HDAdminMain.gui.Changed:Connect(function(p)
	if p == "AbsoluteSize" then
		screenChanged() -- inferred equivalent call
	end
end)
updateUIs()
return {}