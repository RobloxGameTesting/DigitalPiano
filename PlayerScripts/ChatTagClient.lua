local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)

if not Piano_Dependencies then
	ClientDebugConfig.Warn("[ChatTags Client] Failed to find Piano_Dependencies!")
	return
end

local Remotes = Piano_Dependencies:WaitForChild("Remotes", 10)

if not Remotes then
	ClientDebugConfig.Warn("[ChatTags Client] Failed to find Remotes folder!")
	return
end

local AdvancedChatTags = Remotes:WaitForChild("AdvancedChatTags", 30)

if not AdvancedChatTags then
	ClientDebugConfig.Warn("[ChatTags Client] Failed to find AdvancedChatTags RemoteEvent after startup wait.")
	return
end

local RequestAllPlayerTags = Remotes:WaitForChild("RequestAllPlayerTags", 30)

local v = {}

local v2 = {}

local function colorToHex(data) -- 3 equivalent calls inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(data.R * 255),
		math.floor(data.G * 255),
		(math.floor(data.B * 255))
	)
end

local function isSingleColor(list): boolean -- 1 equivalent call inferred from this helper
	if type(list) ~= "table" then
		return false
	end

	if #list == 1 then
		return true
	end

	local item = list[1]

	for i = 2, #list do
		if list[i] ~= item then
			return false
		end
	end

	return true
end

local function escapeRichText(value)
	return tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function getTextGraphemes(value)
	local v3 = tostring(value or "")
	local textGraphemes = {}

	if not pcall(function()
		for k, v4 in utf8.graphemes(v3) do
			table.insert(textGraphemes, v3:sub(k, v4))
		end
	end) then
		for i = 1, #v3 do
			table.insert(textGraphemes, v3:sub(i, i))
		end
	end

	return textGraphemes
end

local function createGradientText(value, p)
	local v3 = tostring(value or "")
	local v4 = p == "RAINBOW"
		and {
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(255, 127, 0),
			Color3.fromRGB(255, 255, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 0, 255),
			Color3.fromRGB(75, 0, 130),
			Color3.fromRGB(148, 0, 211)
		}
		or p

	if typeof(v4) ~= "Color3" and not isSingleColor(v4) then -- inferred equivalent call
		if type(v4) ~= "table" or #v4 == 0 then
			return escapeRichText(v3)
		end

		local textGraphemes = getTextGraphemes(v3)
		local v5 = #textGraphemes
		local v6 = ""

		for i, textGrapheme in ipairs(textGraphemes) do
			local v7 = (i - 1) / math.max(v5 - 1, 1)
			local count = #v4
			local v8 = v7 * (count - 1)
			local v9 = math.floor(v8) + 1
			local v10 = math.min(v9 + 1, count)
			local v11 = v8 - (v9 - 1)

			local v12 = v4[v9]
			local v13 = v4[v10]

			v6 ..= string.format(
				"<font color=\"%s\">%s</font>",
				colorToHex(Color3.new( -- inferred equivalent call
					v12.R + (v13.R - v12.R) * v11,
					v12.G + (v13.G - v12.G) * v11,
					v12.B + (v13.B - v12.B) * v11
				)),
				escapeRichText(textGrapheme)
			)
		end

		return v6
	end

	v4 = type(v4) == "table" and v4[1] or v4
	return string.format("<font color=\"%s\">%s</font>", colorToHex(v4), escapeRichText(v3)) -- inferred equivalent call
end

local function formatTag(data)
	local gradientText = createGradientText(data.Tag, data.Gradient)
	local v3 = colorToHex(type(data.Gradient) == "table" and data.Gradient[1] or data.Gradient) -- inferred equivalent call

	local v4 = not data.Icon and "" or data.Icon .. " "

	local v5 = data.ShowVerified and " ✓" or ""

	return string.format("<font color=\"%s\">[</font>%s%s%s<font color=\"%s\">]</font>", v3, v4, gradientText, v5, v3)
end

local function buildTagPrefix(list, items)
	if type(list) ~= "table" then
		return "", nil
	end

	local v3 = items and next(items) ~= nil
	local icons = {}
	local count = 0
	local v4 = {}
	local gradient = nil

	for _, item in ipairs(list) do
		if type(item) ~= "table" then
			continue
		end

		if item.Type == "Tag" and item.Tag and item.Gradient then
			local v5

			if v3 then
				v5 = items[item.Tag] == true
			else
				v5 = count < 2

				if v5 then
					count += 1
				end
			end

			if v5 then
				local success, result = pcall(formatTag, item)

				if success then
					table.insert(v4, result)

					gradient = item.Gradient
				end
			end
		elseif item.Type == "Icon" and item.Icon then
			table.insert(icons, item.Icon)
		end
	end

	local v5 = not (#v4 > 0) and "" or table.concat(v4, " ") .. " "

	if #icons > 0 then
		v5 ..= table.concat(icons, " ") .. " "
	end

	return v5, gradient
end

AdvancedChatTags.OnClientEvent:Connect(function(list, ...)
	if list == "PlayerTagsUpdate" then
		local v3, v4, v5 = ...
		v[v3] = v4
		v2[v3] = v5 or {}
		ClientDebugConfig.Print("[ChatTags Client] Updated tags for player " .. v3)
	elseif list == "PlayerPreferencesUpdate" then
		local v3, v4 = ...
		v2[v3] = v4 or {}
		local count = 0

		for _, v5 in pairs(v2[v3]) do
			if v5 then
				count += 1
			end
		end

		ClientDebugConfig.Print("[ChatTags Client] Updated preferences for player " .. v3 .. " (" .. count .. " tags enabled)")
	elseif type(list) == "table" then
		local v3 = ...
		v[LocalPlayer.UserId] = list

		if type(v3) == "table" then
			v2[LocalPlayer.UserId] = v3
		else
			local count = 0
			local v4 = {}

			for _, item in ipairs(list) do
				if item.Type ~= "Tag" then
					continue
				end

				local v5 = count < 2
				v4[item.Tag] = v5

				if v5 then
					count += 1
				end
			end

			v2[LocalPlayer.UserId] = v4
		end

		ClientDebugConfig.Print("[ChatTags Client] Initialized local player tags: " .. #list)
	end
end)

if RequestAllPlayerTags then
	task.spawn(function()
		for _ = 1, 5 do
			local success, result = pcall(function()
				return RequestAllPlayerTags:InvokeServer()
			end)

			if success and result and type(result) == "table" then
				local count = 0

				for k, v3 in pairs(result) do
					if not (type(v3) == "table" and v3.Tags) then
						continue
					end

					local v4 = tonumber(k) or k
					v[v4] = v3.Tags
					v2[v4] = v3.Preferences or {}
					count += 1
				end

				ClientDebugConfig.Print("[ChatTags Client] Loaded tags for " .. count .. " players")
				return
			end

			task.wait(2)
		end

		ClientDebugConfig.Warn("[ChatTags Client] Failed to load all player tags after retry")
	end)
else
	ClientDebugConfig.Warn("[ChatTags Client] RequestAllPlayerTags remote not found after startup wait.")
end

local function onLocalPreferencesUpdated()
	local child = ReplicatedStorage2:FindFirstChild("EnabledChatTags_" .. LocalPlayer.UserId)

	if not child then
		return
	end

	local nameSet = {}

	for _, child2 in ipairs(child:GetChildren()) do
		nameSet[child2.Name] = true
	end

	v2[LocalPlayer.UserId] = nameSet
	ClientDebugConfig.Print("[ChatTags Client] Updated local preferences from folder: " .. #child:GetChildren() .. " tags enabled")
end

ReplicatedStorage2.ChildAdded:Connect(function(child)
	if child.Name == "EnabledChatTags_" .. LocalPlayer.UserId then
		onLocalPreferencesUpdated()
		child.ChildAdded:Connect(onLocalPreferencesUpdated)
		child.ChildRemoved:Connect(onLocalPreferencesUpdated)
	end
end)

local child = ReplicatedStorage2:FindFirstChild("EnabledChatTags_" .. LocalPlayer.UserId)

if child then
	onLocalPreferencesUpdated()
	child.ChildAdded:Connect(onLocalPreferencesUpdated)
	child.ChildRemoved:Connect(onLocalPreferencesUpdated)
end

Players.PlayerRemoving:Connect(function(player)
	v[player.UserId] = nil
	v2[player.UserId] = nil
end)

local function shouldHideOtherPlayerChat(userId): boolean -- 2 equivalent calls inferred from this helper
	local v3 = math.floor(tonumber(userId) or 0)

	if v3 <= 0 or v3 == LocalPlayer.UserId then
		return false
	end

	return LocalPlayer:GetAttribute("HideOtherPlayers") == true
		or LocalPlayer:GetAttribute("HiddenPlayerChat_" .. tostring(v3)) == true
end

local function applyHiddenMessageProperties(textChatMessageProperties) -- 1 equivalent call inferred from this helper
	textChatMessageProperties.PrefixText = "<font transparency=\"1\">.</font>"
	textChatMessageProperties.Text = "<font transparency=\"1\">.</font>"
	textChatMessageProperties.Translation = "<font transparency=\"1\">.</font>"
	return textChatMessageProperties
end

TextChatService.OnIncomingMessage = function(p)
	local textChatMessageProperties = Instance.new("TextChatMessageProperties")

	if not p.TextSource then
		return textChatMessageProperties
	end

	local userId = p.TextSource.UserId

	if shouldHideOtherPlayerChat(userId) then -- inferred equivalent call
		return applyHiddenMessageProperties(textChatMessageProperties) -- inferred equivalent call
	else
		local v3 = v[userId]

		if not (v3 and #v3 > 0) then
			return textChatMessageProperties
		end

		local tagPrefix, v4 = buildTagPrefix(v3, v2[userId] or {})
		textChatMessageProperties.PrefixText = tagPrefix .. p.PrefixText

		if not v4 then
			return textChatMessageProperties
		end

		local prefixText = p.PrefixText

		local playerByUserId = Players:GetPlayerByUserId(userId)

		if playerByUserId then
			local displayName = playerByUserId.DisplayName

			textChatMessageProperties.PrefixText = tagPrefix .. prefixText:gsub(
				displayName,
				createGradientText(displayName, v4),
				1
			)
		end

		return textChatMessageProperties
	end
end

local function createHiddenBubbleProperties()
	local success, result = pcall(function()
		return Instance.new("BubbleChatMessageProperties")
	end)

	if not (success and result) then
		return nil
	end

	pcall(function()
		result.Text = "<font transparency=\"1\">.</font>"
	end)
	pcall(function()
		result.Translation = "<font transparency=\"1\">.</font>"
	end)
	pcall(function()
		result.BackgroundTransparency = 1
	end)
	pcall(function()
		result.TextColor3 = Color3.new(1, 1, 1)
	end)
	pcall(function()
		result.TailVisible = false
	end)
	return result
end

pcall(function()
	function TextChatService.OnBubbleAdded(p, _)
		if p.TextSource and shouldHideOtherPlayerChat(p.TextSource.UserId) then -- inferred equivalent call
			return createHiddenBubbleProperties()
		end

		return nil
	end
end)

ClientDebugConfig.Print("[ChatTags Client] Advanced Chat Tag System initialized!")