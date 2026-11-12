local HDAdminMain = _G.HDAdminMain
local playerGui = HDAdminMain.playerGui
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HDAdmin = ReplicatedStorage:FindFirstChild("HDAdmin")
local topbar = HDAdmin and HDAdmin:FindFirstChild("Topbar+")

if topbar then
	local IconController = require(topbar.IconController)
	local icon = IconController:createIcon("HDAdmin", 4882428756, 0)
	icon:setToggleMenu(HDAdminMain.gui.MainFrame)
	return {
		Dashboard = icon,
		Commands = IconController:createIcon("HDCommands", 81506631564371, 0)
	}
else
	local icon = HDAdminMain.client.Assets.Icon
	local mainFrame = HDAdminMain.gui.MainFrame
	local module = require(icon)
	return {
		Dashboard = module.new():setImage(139559302589584, "deselected"):setImage(90888779036359, "selected"):setImageScale(
			0.45,
			"deselected"
		):setImageScale(
			0.45,
			"selected"
		):bindToggleItem(mainFrame):setOrder(0):setEnabled(false),
		Commands = module.new():setImage(81506631564371, "deselected"):setImage(111054392340110, "selected"):setImageScale(
			0.55,
			"deselected"
		):setImageScale(
			0.55,
			"selected"
		):bindEvent(
			"selected",
			function()
				task.defer(function()
					mainFrame.Visible = true
					HDAdminMain:GetModule("GUIs"):ShowSpecificPage("Commands", "Commands", true, nil, true)
				end)
			end
		):bindEvent(
			"deselected",
			function()
				mainFrame.Visible = false
			end
		):setOrder(0):setEnabled(false)
	}
end