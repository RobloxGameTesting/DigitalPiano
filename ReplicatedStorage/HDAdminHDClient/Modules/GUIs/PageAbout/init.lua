local PageAbout = {}

local HDAdminMain = _G.HDAdminMain
local loadModule = HDAdminMain.loadModule
local v = loadModule("cf")
local v2 = loadModule("Credits")
local v3 = loadModule("Updates")

local pages = HDAdminMain.gui.MainFrame.Pages
local about = pages.About
local info = about.Info
local updates = about.Updates
local credits = about.Credits
local info2 = about.Soon.Info

local uiListLayout = info2:FindFirstChildOfClass("UIListLayout")
local messageFrame = info2.MessageFrame
local linkFrame = info2.LinkFrame
local versionInfo = info2.VersionInfo

if uiListLayout then
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
end

for k, v4 in pairs({ versionInfo, messageFrame, linkFrame }) do
	v4.LayoutOrder = k
end

messageFrame.Message2.Text = "✅ <b>Compliant with Oct 2026 TextChatService updates</b>"
local localScript = linkFrame.TextBox:FindFirstChildOfClass("LocalScript")

if localScript then
	localScript:Destroy()
end

linkFrame.TextBox.Text = "create.roblox.com/store/asset/88440273815249/HD-Admin-v131"

local spacer = Instance.new("Frame")
spacer.Name = "Spacer"
spacer.LayoutOrder = 4
spacer.BackgroundTransparency = 1
spacer.Parent = info2

local v2Message = messageFrame:Clone()
v2Message.Name = "V2Message"
v2Message.LayoutOrder = 5
v2Message.Message2.Text = "<b>We've released HD Admin v2 into Beta:</b>"
v2Message.Parent = info2

local tryLink = linkFrame:Clone()
tryLink.Name = "TryLink"
tryLink.LayoutOrder = 6
local localScript2 = tryLink.TextBox:FindFirstChildOfClass("LocalScript")

if localScript2 then
	localScript2:Destroy()
end

tryLink.TextBox.Text = "roblox.com/games/start?placeId=106966695720565"
tryLink.Parent = info2

local banner = Instance.new("ImageLabel")
banner.Name = "Banner"
banner.LayoutOrder = 7
banner.BackgroundTransparency = 1
banner.Image = "rbxassetid://130389915526594"
banner.ScaleType = Enum.ScaleType.Fit
local uiAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
uiAspectRatioConstraint.AspectRatio = 82 / 45
uiAspectRatioConstraint.AspectType = Enum.AspectType.FitWithinMaxSize
uiAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Width
uiAspectRatioConstraint.Parent = banner
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 4)
uiCorner.Parent = banner
banner.Parent = info2

local v4 = { versionInfo, messageFrame, linkFrame, v2Message, tryLink }
local function relayout()
	local y = info2.AbsoluteSize.Y

	if y <= 0 then
		return
	end

	local v5 = math.floor(y * 0.085)
	local v6 = math.max(3, (math.floor(y * 0.012)))

	if uiListLayout then
		uiListLayout.Padding = UDim.new(0, v6)
	end

	for _, v7 in pairs(v4) do
		v7.Size = UDim2.new(1, 0, 0, v5)
	end

	spacer.Size = UDim2.new(1, 0, 0, v6 * 2)
	local v7 = v5 * #v4 + v6 * 2 + v6 * (#v4 + 1)
	banner.Size = UDim2.new(1, 0, 0, (math.max(v5 * 2, y - v7)))
end
info2:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
task.defer(relayout)

local notice = pages.Home.About.Notice
task.defer(function()
	local module = HDAdminMain:GetModule("VERSION")
	local appVersion = module.getAppVersion()
	local latestVersion = module.getLatestVersion()
	local upToDate = module.isUpToDate()
	local lastCheckedVersion = HDAdminMain.pdata.LastCheckedVersion
	local v5 = HDAdminMain:GetModule("cf"):WaitForLoadedRank()
	local v6 = lastCheckedVersion == latestVersion
	local text

	if upToDate then
		text = `✅  <b>{appVersion}</b> - Your HD Admin is up-to-date!`
	else
		text = `⚠️  <b>{appVersion}</b> - Your HD Admin requires updating`
	end

	local color

	if upToDate then
		color = Color3.fromRGB(85, 255, 127)
	else
		color = Color3.fromRGB(255, 83, 83)
	end

	local versionInfo2 = info2.VersionInfo
	local dashboard = HDAdminMain:GetModule("TopbarIcons").Dashboard
	versionInfo2.TextLabel.Text = text
	versionInfo2.BackgroundColor3 = color
	versionInfo2.UIStroke.Color = color

	if not v6 and v5 and v5 >= 1 and HDAdminMain.userInputService.KeyboardEnabled and dashboard then
		local module2 = HDAdminMain:GetModule("Signal").new()
		dashboard:notify(module2)
		notice.Visible = true
		about:GetPropertyChangedSignal("Visible"):Once(function()
			module2:Fire()
			notice.Visible = false
			HDAdminMain.signals.UpdateSavedVersion:FireServer()
		end)
	end

	if not upToDate and v5 == 5 then
		task.delay(2, function()
			HDAdminMain:GetModule("Notices"):Notice(
				"Notice",
				HDAdminMain.hdAdminCoreName,
				"A new version of HD Admin is available. Enable AutoUpdate to benefit from the latest changes.",
				{
					"CallFunctionOnClick",
					function()
						HDAdminMain:GetModule("GUIs"):ShowSpecificPage("About", "Soon")
					end
				}
			)
		end)
	end
end)

function PageAbout.UpdateRankName(_) end
function PageAbout.UpdateProfileIcon(_) end

local template = updates.Template
template.Visible = false
function PageAbout.CreateUpdates(_)
	v:ClearPage(updates)
	local total = 0

	for _, v5 in pairs(v3) do
		total += #v5
		local v6 = 0

		for k, v7 in pairs(v5) do
			local clone = template:Clone()

			if k == 1 then
				v6 = v7[1]
				clone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				clone.TextLabel.Text = v7[2]
				clone.BackgroundTransparency = 0.93
			else
				clone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				clone.BackgroundTransparency = 1

				if k % 2 == 0 then
					clone.BackgroundTransparency -= 0.01
				end

				clone.TextLabel.Text = v7[1]

				if os.time() - 907200 < v6 then
					clone.New.Visible = true
					clone.TextLabel.Position = UDim2.new(0.16, 0, 0.15, 0)
					clone.TextLabel.Size = UDim2.new(0.8, 0, 0.7, 0)
				end
			end

			clone.Visible = true
			clone.Parent = updates
		end
	end

	updates.CanvasSize = UDim2.new(0, 0, 0, total * template.AbsoluteSize.Y)
end

local template2 = credits.Template
template2.Visible = false

function PageAbout.UpdateContributors(_)
	local v5 = {}

	for k, contributor in pairs(HDAdminMain.infoOnAllCommands.Contributors) do
		table.insert(v5, { k, contributor })
	end

	table.sort(v5, function(a, b): boolean
		return a[2] > b[2]
	end)

	for _, v6 in pairs(v5) do
		local v7 = {
			v6[1],
			{ "Commands: " .. v6[2] }
		}
		table.insert(v2[3], v7)
	end
end

function PageAbout.CreateCredits(_)
	v:ClearPage(credits)
	local total = 0

	for _, v5 in pairs(v2) do
		local aspectRatio = 6

		for k, v6 in pairs(v5) do
			local label

			if k == 1 then
				label = template:Clone()
				aspectRatio = v6[1]
				label.BackgroundTransparency = 0.93
				label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				label.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				label.TextLabel.Text = v6[2]
				label.Parent = credits
			else
				label = template2:Clone()
				label.Parent = credits
				label.UIAspectRatioConstraint.AspectRatio = aspectRatio
				label.BackgroundTransparency = 1

				if k % 2 == 0 then
					label.BackgroundTransparency -= 0.01
				end

				label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				label.PlrName.Text = v6[1]
				label.PlayerImage.Image = v:GetUserImage(v:GetUserId(v6[1]))
				local y = label.PlayerImage.AbsoluteSize.Y
				label.PlayerImage.Size = UDim2.new(0, y, 1, 0)

				for i = 1, 3 do
					local child = label:FindFirstChild("Desc" .. i)

					if not child then
						continue
					end

					local text = v6[2][i]

					if text then
						child.Text = text
					else
						child.Text = ""
					end

					local v7 = y * 1.15
					local v8, v9, v10

					if aspectRatio <= 5 then
						v8 = (i - 1) * 0.25 + 0.33
						v9 = 0.255
						v10 = 0.31
					else
						v8 = (i - 1) * 0.25 + 0.36
						v9 = 0.26
						v10 = 0.32
					end

					child.Position = UDim2.new(0, v7, v8, 0)
					child.Size = UDim2.new(0.75, 0, v9, 0)
					label.PlrName.Position = UDim2.new(
						0,
						v7,
						label.PlrName.Position.Y.Scale,
						label.PlrName.Position.Y.Offset
					)
					label.PlrName.Size = UDim2.new(0.75, 0, v10, 0)
				end
			end

			label.Name = "Label"
			label.Visible = true
			total += label.AbsoluteSize.Y
		end
	end

	credits.CanvasSize = UDim2.new(0, 0, 0, total)
end

return PageAbout