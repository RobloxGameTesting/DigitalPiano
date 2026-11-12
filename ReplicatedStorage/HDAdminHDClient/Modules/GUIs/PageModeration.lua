local PageModeration = {}

local HDAdminMain = _G.HDAdminMain

local moderation = HDAdminMain.gui.MainFrame.Pages.Moderation
local buyFrame = HDAdminMain.warnings.BuyFrame
local unBan = HDAdminMain.warnings.UnBan
local v = {
	ranks = moderation.Ranks,
	serverRanks = moderation["Server Ranks"],
	banland = moderation.Banland
}

local v2 = {
	rankTitle = v.ranks.TemplateRankTitle,
	rankItem = v.ranks.TemplateRankItem,
	space = v.ranks.TemplateSpace,
	admin = v.serverRanks.TemplateAdmin,
	ban = v.banland.TemplateBan,
	banTitle = v.banland.TemplateTitle
}

local v3 = {
	{ "friends", HDAdminMain.ownerName .. "'s Friends", "For friends of the Owner" },
	{ "freeadmin", "Free Admin", "For everyone" },
	{ "vipserverowner", "VIP Server Owner", "For VIP Server owners" },
	{ "vipserverplayer", "VIP Server Player", "For VIP Server players" }
}

function PageModeration.SetupRanks(_)
	PageModeration:CreateRanks()
end

function PageModeration:CreateRanks()
	coroutine.wrap(function()
		local v4 = HDAdminMain.signals.RetrieveRanksInfo:InvokeServer()
		local permRanks = v4.PermRanks
		local ranks = v4.Ranks
		local permissions = v4.Permissions

		local v5 = {}
		local v6 = {}

		for _, rank in pairs(ranks) do
			table.insert(v5, 1, { rank[1], rank[2], {} })
		end

		for k, v7 in pairs(v5) do
			v6[v7[1]] = k
		end

		for k, permission in pairs(permissions) do
			if k == "owner" and v6[5] then
				table.insert(v5[v6[5]][3], {
					HDAdminMain.ownerName,
					"Owner",
					HDAdminMain:GetModule("cf"):GetUserImage(HDAdminMain.ownerId)
				})
			elseif k == "specificusers" then
				for k2, v7 in pairs(permission) do
					if not (#k2 > 1) then
						continue
					end

					local v8 = v5[v6[v7]]
					local v9 = {
						k2,
						"Specific User",
						HDAdminMain:GetModule("cf"):GetUserImage(HDAdminMain:GetModule("cf"):GetUserId(k2))
					}
					table.insert(v8[3], v9)
				end

				for _, permRank in pairs(permRanks) do
					if permRank.RemoveRank then
						continue
					end

					local v7 = v5[v6[permRank.Rank]]

					if not v7 then
						continue
					end

					local v8 = {
						HDAdminMain:GetModule("cf"):GetName(permRank.UserId),
						"PermRank",
						HDAdminMain:GetModule("cf"):GetUserImage(permRank.UserId),
						permRank
					}
					table.insert(v7[3], v8)
				end
			elseif k == "assets" then
				for k2, v7 in pairs(permission) do
					local v8 = v5[v6[v7.Rank]]

					if not v8 then
						continue
					end

					local v9 = {
						v7.Name,
						"Asset",
						HDAdminMain:GetModule("cf"):GetAssetImage(k2),
						tonumber(k2),
						v7.PriceInRobux
					}
					table.insert(v8[3], v9)
				end
			elseif k == "groups" then
				for k2, v7 in pairs(permission) do
					for k3, role in pairs(v7.Roles) do
						if not role.Rank then
							continue
						end

						local v8 = v5[v6[role.Rank]]

						if not v8 then
							continue
						end

						local v9 = {
							v7.Name .. " | " .. k3,
							"Group",
							v7.EmblemUrl,
							(tonumber(k2))
						}
						table.insert(v8[3], v9)
					end
				end
			elseif v3[k] then
				local v7 = v3[k]
				local permission2 = permissions[v7[1]]

				if permission2 > 0 then
					local v8 = v5[v6[permission2]]

					if v8 then
						local v9 = { v7[2], v7[3], string.upper((string.sub(v7[1], 1, 1))) }
						table.insert(v8[3], v9)
					end
				end
			end
		end

		local v7 = HDAdminMain.pdata.Rank >= (HDAdminMain.commandRanks.permrank or 4)

		HDAdminMain:GetModule("cf"):ClearPage(v.ranks)
		local count = 0

		for _, v8 in pairs(v5) do
			local text = v8[1]
			local text2 = v8[2]
			local v9 = v8[3]

			count += 1
			local clone = v2.rankTitle:Clone()
			clone.Name = "Label" .. count
			clone.RankIdFrame.TextLabel.Text = text
			clone.RankName.Text = text2
			clone.Visible = true
			clone.Parent = v.ranks

			for _, v10 in pairs(v9) do
				count += 1
				local text3 = v10[1]
				local text4 = v10[2]
				local v11 = v10[3]
				local clone2 = v2.rankItem:Clone()
				clone2.Name = "Label" .. count
				clone2.ItemTitle.Text = text3
				clone2.ItemDesc.Text = text4

				if #tostring(v11) == 1 then
					clone2.ItemIcon.Text = v11
					clone2.ItemIcon.Visible = true
					clone2.ItemImage.Visible = false
				else
					if tonumber(v11) then
						v11 = "rbxassetid://" .. v11
					end

					clone2.ItemImage.Image = tostring(v11)
				end

				clone2.Unlock.Visible = false
				clone2.ViewMore.Visible = false
				local v12

				if text4 == "Gamepass" or text4 == "Asset" then
					local v13 = v10[4]
					local v14 = v10[5]
					clone2.ItemImage.BackgroundTransparency = 1
					clone2.Unlock.Visible = true
					clone2.Unlock.MouseButton1Down:Connect(function()
						buyFrame.ProductName.Text = text3
						buyFrame.ProductImage.Image = v11
						buyFrame.PurchaseToUnlock.TextLabel.Text = text2
						buyFrame.InGame.TextLabel.Text = HDAdminMain.gameName
						buyFrame.MainButton.Price.Text = (v14 or 0) .. " "
						buyFrame.MainButton.ProductId.Value = v13
						buyFrame.MainButton.ProductType.Value = text4
						HDAdminMain:GetModule("cf"):ShowWarning("BuyFrame")
					end)
					v12 = 0.4
				elseif text4 == "PermRank" then
					local v13 = v10[4]

					if v7 then
						local viewMore = clone2.ViewMore
						viewMore.Visible = true
						viewMore.MouseButton1Down:Connect(function()
							HDAdminMain:GetModule("cf"):ShowPermRankedUser({ text3, v13.UserId, v13.RankedBy })
						end)
					end

					v12 = 0.6
				else
					v12 = 0.7
				end

				clone2.ItemTitle.Size = UDim2.new(v12, 0, clone2.ItemTitle.Size.Y.Scale, 0)
				clone2.ItemDesc.Size = UDim2.new(v12, 0, clone2.ItemDesc.Size.Y.Scale, 0)
				clone2.Visible = true
				clone2.Parent = v.ranks
			end
		end

		if count >= 2 then
			for _ = 1, 2 do
				local label1 = v.ranks.Label1
				local rank = v.ranks["Label" .. count]
				v.ranks.CanvasSize = UDim2.new(
					0,
					0,
					0,
					rank.AbsolutePosition.Y + rank.AbsoluteSize.Y - label1.AbsolutePosition.Y
				)
			end
		end
	end)()
end

function PageModeration:CreateServerRanks()
	coroutine.wrap(function()
		local v4 = HDAdminMain.signals.RetrieveServerRanks:InvokeServer()

		local v5 = {}
		local v6 = {}

		for _, rank in pairs(HDAdminMain.settings.Ranks) do
			table.insert(v5, 1, { rank[1], rank[2], {} })
		end

		for k, v7 in pairs(v5) do
			v6[v7[1]] = k
		end

		for _, v7 in pairs(v4) do
			local player = v7.Player
			local rankId = v7.RankId
			local rankType = v7.RankType
			local v8 = v5[v6[rankId]]

			if v8 then
				table.insert(v8[3], { player, rankType })
			end
		end

		for _, v7 in pairs(v5) do
			local v8 = v7[3]
			table.sort(v8, function(a, b): boolean
				return a[2] < b[2]
			end)
		end

		HDAdminMain:GetModule("cf"):ClearPage(v.serverRanks)

		local v7 = {}

		for k, rankType in pairs(HDAdminMain.rankTypes) do
			v7[rankType] = k
		end

		local count = 0

		for _, v8 in pairs(v5) do
			local _ = v8[1]
			local v9 = v8[2]
			local v10 = v8[3]

			for _, v11 in pairs(v10) do
				count += 1
				local v12 = v11[1]
				local v13 = v7[v11[2]]
				local clone = v2.admin:Clone()
				clone.Name = "Label" .. count
				clone.PlrName.Text = v12.Name
				clone.PlrRank.Text = v9 .. " (" .. v13 .. ")"
				clone.PlayerImage.Image = HDAdminMain:GetModule("cf"):GetUserImage(v12.UserId)
				clone.BackgroundColor3 = HDAdminMain:GetModule("cf"):GetLabelBackgroundColor(count)
				clone.Visible = true
				clone.Parent = v.serverRanks
			end
		end

		v.serverRanks.CanvasSize = UDim2.new(0, 0, 0, count * v2.admin.AbsoluteSize.Y)
	end)()
end

local v4 = true
function PageModeration:CreateBanland()
	coroutine.wrap(function()
		if not v4 then
			return
		end

		v4 = false

		local total = 0

		if HDAdminMain.pdata.Rank < HDAdminMain.settings.ViewBanland then
			HDAdminMain:GetModule("cf"):ClearPage(v.banland)
			local titleLabel = v2.banTitle:Clone()
			titleLabel.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
			titleLabel.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			titleLabel.TextLabel.Text = "Must be rank '" .. HDAdminMain:GetModule("cf"):GetRankName(HDAdminMain.settings.ViewBanland) .. "' or higher to view the Banland"
			titleLabel.Name = "TitleLabel"
			titleLabel.Visible = true
			titleLabel.Parent = v.banland
		else
			local v5 = HDAdminMain.signals.RetrieveBanland:InvokeServer()

			local v6 = HDAdminMain.pdata.Rank >= (HDAdminMain.commandRanks.directban or 4)

			HDAdminMain:GetModule("cf"):ClearPage(v.banland)

			local v7 = { "Current Server", "All Servers" }

			for k, v8 in pairs(v5) do
				if #v8 > 0 then
					local titleLabel = v2.banTitle:Clone()
					titleLabel.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
					titleLabel.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					titleLabel.TextLabel.Text = v7[k]
					titleLabel.Name = "TitleLabel"
					total += v2.banTitle.AbsoluteSize.Y
					titleLabel.Visible = true
					titleLabel.Parent = v.banland
				end

				for k2, v9 in pairs(v8) do
					local userId = v9.UserId

					if not (userId > 0) then
						continue
					end

					total += v2.ban.AbsoluteSize.Y
					local settingsBan = v9.SettingsBan
					local banLabel = v2.ban:Clone()
					banLabel.Name = "BanLabel"
					banLabel.PlrName.Text = HDAdminMain:GetModule("cf"):GetName(userId)

					local banTime = v9.BanTime
					local text = not tonumber(banTime) and (settingsBan and "Auto Settings Ban" or "Infinite")
						or HDAdminMain:GetModule("cf"):GetBanDateString(os.date("*t", banTime))

					banLabel.BanLength.Text = text
					banLabel.PlayerImage.Image = HDAdminMain:GetModule("cf"):GetUserImage(userId)
					banLabel.BackgroundColor3 = HDAdminMain:GetModule("cf"):GetLabelBackgroundColor(k2)
					local viewMore = banLabel.ViewMore

					if v6 and not settingsBan then
						viewMore.Visible = true
						local v10 = v9
						viewMore.MouseButton1Down:Connect(function()
							HDAdminMain:GetModule("cf"):ShowBannedUser({
								banLabel.PlrName.Text,
								userId,
								v10.Reason,
								v10.BannedBy
							})
						end)
					else
						viewMore.Visible = false
					end

					banLabel.Visible = true
					banLabel.Parent = v.banland
				end
			end
		end

		v.banland.CanvasSize = UDim2.new(0, 0, 0, total)

		v4 = true
	end)()
end

function PageModeration:UpdatePages()
	PageModeration:CreateServerRanks()
	PageModeration:CreateBanland()
	PageModeration:CreateRanks()
end

spawn(function()
	while wait(20) do
		if moderation.Visible and HDAdminMain.gui.MainFrame.Visible then
			PageModeration:UpdatePages()
		end
	end
end)

return PageModeration