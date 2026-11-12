local HDAdminMain = _G.HDAdminMain

local v = { custom = HDAdminMain.gui.MainFrame.Pages.Settings.Custom }

local appThemes = HDAdminMain.settings.AppThemes

local aspectRatio = 6.1 / #appThemes
local abThemeSelection = v.custom["AB ThemeSelection"]

local function updateThemeSelection(p, p2)
	if p == nil then
		for _, appTheme in pairs(appThemes) do
			if appTheme[1] == HDAdminMain.pdata.AppTheme then
				p = appTheme[1]
				p2 = appTheme[2]
				break
			end
		end
	end

	if p then
		local parents = {}

		for _, boolValue in pairs(HDAdminMain.gui:GetDescendants()) do
			if boolValue:IsA("BoolValue") and boolValue.Name == "Theme" then
				table.insert(parents, boolValue.Parent)
			end
		end

		for _, guiObject in pairs(parents) do
			local v2

			if guiObject.Theme.Value then
				local hsv, v3, v4 = Color3.toHSV(p2)
				v2 = Color3.fromHSV(hsv, v3, v4 * 1.35)
			else
				v2 = p2
			end

			if guiObject:IsA("TextLabel") then
				local hsv, v3, v4 = Color3.toHSV(p2)
				v2 = Color3.fromHSV(hsv, v3, v4 * 2)
				guiObject.TextColor3 = v2
			else
				guiObject.BackgroundColor3 = v2
			end

			if guiObject:IsA("ImageButton") or guiObject:IsA("ImageLabel") then
				guiObject.ImageColor3 = v2
			end
		end

		for _, button in pairs(abThemeSelection:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			if button.Name == p then
				button.BorderSizePixel = 1
			else
				button.BorderSizePixel = 0
			end
		end
	end
end

local flag = true

for _, appTheme in pairs(appThemes) do
	local name = appTheme[1]
	local backgroundColor = appTheme[2]
	local clone = abThemeSelection.ThemeTemplate:Clone()
	clone.Name = name
	clone.UIAspectRatioConstraint.AspectRatio = aspectRatio
	clone.BackgroundColor3 = backgroundColor
	clone.MouseButton1Down:Connect(function()
		if flag then
			flag = false
			HDAdminMain.signals.ChangeSetting:InvokeServer({ "AppTheme", name })
			updateThemeSelection(name, backgroundColor)
			flag = true
		end
	end)
	clone.Visible = true
	clone.Parent = abThemeSelection
end

local function updateSettings()
	for _, child in pairs(v.custom:GetChildren()) do
		local v2 = string.sub(child.Name, 5)

		if not child:FindFirstChild("SettingValue") then
			continue
		end

		child.SettingName.TextLabel.Text = v2 .. ":"
		local v3 = HDAdminMain.pdata[v2]
		child.SettingValue.TextBox.Text = tostring(v3)
		local v4 = nil
		local v5 = nil

		if string.sub(v2, 1, 5) == "Error" then
			v4 = "Error"
			v5 = 6
		elseif string.sub(v2, 1, 6) == "Notice" then
			v4 = "Notice"
			v5 = 7
		end

		if not v4 then
			continue
		end

		local v6 = HDAdminMain.audio[v4]
		local v7 = string.sub(v2, v5)

		if v7 == "SoundId" then
			v3 = "rbxassetid://" .. v3
		end

		v6[v7] = v3
	end

	updateThemeSelection()
end

for _, child in pairs(v.custom:GetChildren()) do
	local v2 = string.sub(child.Name, 5)

	if not child:FindFirstChild("SettingValue") then
		continue
	end

	local flag2 = true
	local textBox = child.SettingValue.TextBox
	local textLabel = child.SettingValue.TextLabel
	child.SettingValue.TextBox.FocusLost:connect(function(_)
		if flag2 then
			local text = child.SettingValue.TextBox.Text
			flag2 = false
			textBox.Visible = false
			textLabel.Visible = true
			textLabel.Text = "Loading..."
			local text2 = HDAdminMain.signals.ChangeSetting:InvokeServer({ v2, text })
			task.wait(0.1)

			if text2 == "Success" then
				updateSettings()

				local v3 = string.sub(v2, 1, 5)
				local v4 = v3 ~= "Error" and v3 ~= "Alert" and "Notice" or v3

				if v2 == "Prefix" then
					HDAdminMain:GetModule("PageCommands"):CreateCommands()
				end

				local v5 = "Successfully changed '" .. v2 .. "' to '" .. text .. "'"

				if v4 == "Alert" then
					HDAdminMain:GetModule("cf"):CreateNewCommandMenu("settings", { "Settings Alert", v5 }, 8, true)
				else
					HDAdminMain:GetModule("Notices"):Notice(v4, "Settings", v5)
				end
			else
				textLabel.Text = text2
				wait(1)
			end

			textBox.Visible = true
			textLabel.Visible = false
			child.SettingValue.TextBox.Text = tostring(HDAdminMain.pdata[v2])
			flag2 = true
		end
	end)
end

updateSettings()

local axRestore = v.custom["AX Restore"]
local loading = axRestore.Loading
local v2 = 0
axRestore.MouseButton1Down:Connect(function()
	if v2 < 2 then
		local hsv, v3, v4 = Color3.toHSV(axRestore.BackgroundColor3)
		loading.BackgroundColor3 = Color3.fromHSV(hsv, v3, v4 * 0.5)
		loading.Visible = true

		if v2 == 0 then
			v2 = 1
			loading.Blocker.Visible = false
			loading.TextLabel.Text = "Confirm?"
			wait(1)
		elseif v2 == 1 then
			v2 = 2
			loading.Blocker.Visible = true
			loading.TextLabel.Text = "Loading..."
			local text = HDAdminMain.signals.RestoreDefaultSettings:InvokeServer()

			if text == "Success" then
				updateSettings()
				HDAdminMain:GetModule("PageCommands"):CreateCommands()
				local formatNotice = HDAdminMain:GetModule("cf"):FormatNotice("RestoreDefaultSettings")
				HDAdminMain:GetModule("Notices"):Notice("Notice", formatNotice[1], formatNotice[2])
			else
				axRestore.TextLabel.Text = text
			end

			wait(1)
		end

		v2 = 0
		loading.Visible = false
		loading.Blocker.Visible = false
	end
end)

local aaSpace = v.custom["AA Space"]
local azSpace = v.custom["AZ Space"]
v.custom.CanvasSize = UDim2.new(
	0,
	0,
	0,
	azSpace.AbsolutePosition.Y - aaSpace.AbsolutePosition.Y + azSpace.AbsoluteSize.Y * 1
)
return {}