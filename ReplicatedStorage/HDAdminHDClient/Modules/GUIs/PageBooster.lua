local HDAdminMain = _G.HDAdminMain
local PageBooster = {}
local banner = HDAdminMain.gui.MainFrame.Pages.Boost.Buy.Banner
local buttons = banner.Buttons
local unlock = buttons.Unlock
local unlocked = buttons.Unlocked
local textLabel = unlock.TextLabel
local discount = banner.Fade.Discount
local counter = discount.Counter
local discount2 = unlock.Discount

local v = false
local v2 = nil
local v3 = true
local function getOfferStartTime(p)
	local success, result = pcall(function()
		return HDAdminMain.signals.RetrieveOfferStartTime:InvokeServer(p)
	end)

	if not success then
		return nil
	end

	v2 = result
	return result
end

function PageBooster:UpdateBoostStatus(p)
	HDAdminMain:GetModule("ChatHandler"):DecideWelcomePrompt(p)
end
function PageBooster.OfferOnClose(_)
	if v2 == nil and v3 then
		v3 = false
		PageBooster:CheckOffer(false, true)
		task.delay(0.2, function()
			v3 = true
		end)
	end
end
function PageBooster:CheckOffer(p, p2)
	local v4
	v4 = false
	local success, result = pcall(function()
		return HDAdminMain.signals.RetrieveOfferStartTime:InvokeServer(v4)
	end)

	if success then
		v2 = result
	else
		result = nil
	end

	local v5 = result or 0

	local visible = nil
	local function updatePage()
		local now = os.time()
		local v6 = v5 + 900 - now
		visible = now - v5 <= 900 and not unlocked.Visible
		discount.Visible = visible
		discount2.Visible = visible
		textLabel.Text = visible and 479 or 599

		if visible and not v then
			task.spawn(function()
				v = true

				for i = v6, 0, -1 do
					counter.Text = "<b>" .. string.format("%02i:%02i", math.floor(i / 60), i % 60) .. "</b>"

					if unlocked.Visible then
						break
					end

					task.wait(1)
				end

				discount.Visible = false
				discount2.Visible = false
				textLabel.Text = 599
			end)
		end
	end
	updatePage()

	local v6 = nil

	if not unlocked.Visible then
		if p == true and (visible or v5 == 0) then
			v6 = "Get 20% off more commands. Click to view."
		elseif p == false and (visible or v5 == 0 or p2 == true) then
			v6 = "Get 20% off Chat Commands. Click to view."
		elseif p2 == true or typeof(p) == "boolean" then
			v6 = "Unlock bonus Chat Commands. Click to view."
		else
			v6 = v6
		end
	end

	if v6 then
		HDAdminMain:GetModule("Notices"):Notice("Notice", "System", v6, {
			"CallFunctionSpecialOnClick",
			function()
				local v7
				v7 = true
				local success2, result2 = pcall(function()
					return HDAdminMain.signals.RetrieveOfferStartTime:InvokeServer(v7)
				end)

				if success2 then
					v2 = result2
				else
					result2 = nil
				end

				v5 = result2
				updatePage()
				HDAdminMain:GetModule("GUIs"):ShowSpecificPage("Boost", "Buy", nil, nil, nil, true)
			end
		})
	end
end
local function updateBuyVisible(p)
	local visible = p or HDAdminMain.modules.cf:HasBooster()
	unlock.Visible = not visible
	unlocked.Visible = visible
	local module = HDAdminMain:GetModule("ChatHandler")

	if visible then
		module:GenerateChatCommands()
	end

	if p then
		PageBooster:UpdateBoostStatus(visible)
	end
end
task.defer(updateBuyVisible)
task.defer(PageBooster.UpdateBoostStatus)
task.defer(PageBooster.CheckOffer)
unlock.MouseButton1Down:Connect(function()
	HDAdminMain.modules.cf:PromptGamepass(HDAdminMain.player, "Booster")
end)
HDAdminMain.marketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p == HDAdminMain.player and (p2 == HDAdminMain.products.Booster or p2 == HDAdminMain.products.Donor) and p3 then
		unlock.Visible = false
		unlocked.Visible = true
		HDAdminMain:GetModule("ChatHandler"):GenerateChatCommands()

		PageBooster:UpdateBoostStatus(true)
	end
end)
HDAdminMain.marketplaceService.PromptBulkPurchaseFinished:Connect(function(p, p2, p3)
	if p == HDAdminMain.player and p2 == Enum.MarketplaceBulkPurchasePromptStatus.Completed then
		local booster = tostring(HDAdminMain.accessories.Booster)
		local booster2 = tostring(HDAdminMain.accessories.Booster2)
		local items = p3.Items
		local v4 = false

		if items then
			for _, item in pairs(items) do
				local id = tostring(item.id)

				if (id == booster or id == booster2) and item.status == Enum.MarketplaceItemPurchaseStatus.Success then
					v4 = id
					break
				end
			end
		end

		if v4 then
			unlock.Visible = false
			unlocked.Visible = true
			HDAdminMain:GetModule("ChatHandler"):GenerateChatCommands()

			PageBooster:UpdateBoostStatus(true)

			HDAdminMain.signals.BulkPurchaseFinished:FireServer(v4)
			HDAdminMain:GetModule("Notices"):Notice(
				"Notice",
				"System",
				"Successfully purchased Chat Command! Click to use.",
				{ "OpenCommands", "Booster" }
			)
		end
	end
end)

local textButton = buttons.View.TextButton
function PageBooster:ShowBoostCommands()
	HDAdminMain:GetModule("GUIs"):ShowSpecificPage("Commands", "Commands", "Boost", "Buy")
	HDAdminMain:GetModule("PageCommands"):SetSearchText("Booster")
end
textButton.MouseButton1Down:Connect(function()
	PageBooster:ShowBoostCommands()
end)

return PageBooster