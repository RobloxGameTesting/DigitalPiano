local ChatHandler = {}

local HDAdminMain = _G.HDAdminMain

task.defer(function()
	if not HDAdminMain.player.Character then
		HDAdminMain.player.CharacterAdded:Wait()
	end

	task.wait(1)
	local TextChatService = game:GetService("TextChatService")
	local fixChat = Instance.new("TextChatCommand")
	fixChat.PrimaryAlias = "/zzz"
	fixChat.Enabled = true
	fixChat.AutocompleteVisible = true
	fixChat.Name = "FixChat"
	fixChat.Parent = TextChatService
	task.delay(0.25, function()
		fixChat.Enabled = false
		fixChat.AutocompleteVisible = false
		task.wait(0.25)
		fixChat:Destroy()
	end)
end)

local TextChatService = HDAdminMain.TextChatService
local function bindToEvent(p)
	TextChatService[p]:Connect(function(state)
		local textSource = state.TextSource
		local child = textSource and HDAdminMain.players:FindFirstChild(textSource.Name)

		if not (child and child:GetAttribute("HDChatConfigEnabled")) then
			return
		end

		local function escapeRich(p2) -- 2 equivalent calls inferred from this helper
			return tostring(p2):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
		end

		local chatTag = child:GetAttribute("ChatTag")
		local chatTagColor = child:GetAttribute("ChatTagColor")
		local chatName = child:GetAttribute("ChatName")
		local chatNameColor = child:GetAttribute("ChatNameColor")

		if not state.TextSource then
			return state
		end

		local v = chatTag and `[{escapeRich(chatTag)}]` -- inferred equivalent call

		if v and chatTagColor then
			v = `<font color='#{chatTagColor:ToHex()}'>{v}</font>`
		end

		local v2

		if chatName then
			v2 = `{escapeRich(chatName)} (@{child.Name})` -- inferred equivalent call
		else
			v2 = child.DisplayName
		end

		local prefixText2 = `{v2}:`

		if prefixText2 and chatNameColor then
			prefixText2 = `<font color='#{chatNameColor:ToHex()}'>{prefixText2}</font>`
		end

		if v then
			prefixText2 = v .. " " .. prefixText2
		end

		local prefixText = state.PrefixText
		local v3 = string.match(prefixText, "<.*>(.*)<.*>")

		if not chatTag and v3 then
			local v4, v5 = string.find(string.reverse(prefixText), string.reverse(v3))
			local v6 = string.len(prefixText) - v5 + 1
			local v7 = string.len(prefixText) - v4 + 1

			if v6 and v7 then
				local v8 = string.sub(prefixText, 1, v6 - 1)
				local v9 = string.match(v8, "<.*>(.*)<.*>")
				local v10 = string.sub(prefixText, v7 + 1)

				if v9 then
					v8 ..= " "
				end

				prefixText2 = v8 .. prefixText2 .. v10
			end
		end

		state.PrefixText = prefixText2

		return state
	end)
end

local function fn(state)
	local textSource = state.TextSource
	local child = textSource and HDAdminMain.players:FindFirstChild(textSource.Name)

	if not (child and child:GetAttribute("HDChatConfigEnabled")) then
		return
	end

	local function escapeRich(p) -- 2 equivalent calls inferred from this helper
		return tostring(p):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
	end

	local chatTag = child:GetAttribute("ChatTag")
	local chatTagColor = child:GetAttribute("ChatTagColor")
	local chatName = child:GetAttribute("ChatName")
	local chatNameColor = child:GetAttribute("ChatNameColor")

	if not state.TextSource then
		return state
	end

	local v = chatTag and `[{escapeRich(chatTag)}]` -- inferred equivalent call

	if v and chatTagColor then
		v = `<font color='#{chatTagColor:ToHex()}'>{v}</font>`
	end

	local v2

	if chatName then
		v2 = `{escapeRich(chatName)} (@{child.Name})` -- inferred equivalent call
	else
		v2 = child.DisplayName
	end

	local prefixText2 = `{v2}:`

	if prefixText2 and chatNameColor then
		prefixText2 = `<font color='#{chatNameColor:ToHex()}'>{prefixText2}</font>`
	end

	if v then
		prefixText2 = v .. " " .. prefixText2
	end

	local prefixText = state.PrefixText
	local v3 = string.match(prefixText, "<.*>(.*)<.*>")

	if not chatTag and v3 then
		local v4, v5 = string.find(string.reverse(prefixText), string.reverse(v3))
		local v6 = string.len(prefixText) - v5 + 1
		local v7 = string.len(prefixText) - v4 + 1

		if v6 and v7 then
			local v8 = string.sub(prefixText, 1, v6 - 1)
			local v9 = string.match(v8, "<.*>(.*)<.*>")
			local v10 = string.sub(prefixText, v7 + 1)

			if v9 then
				v8 ..= " "
			end

			prefixText2 = v8 .. prefixText2 .. v10
		end
	end

	state.PrefixText = prefixText2

	return state
end

TextChatService.SendingMessage:Connect(fn)
TextChatService.MessageReceived:Connect(fn)

local primaryAliasSet = {}
local function createChatCommand(primaryAlias) -- 6 equivalent calls inferred from this helper
	if primaryAliasSet[primaryAlias] then
		return
	end

	primaryAliasSet[primaryAlias] = true
	local textChatCommand = Instance.new("TextChatCommand")
	textChatCommand.AutocompleteVisible = true
	textChatCommand.Enabled = true
	textChatCommand.PrimaryAlias = primaryAlias
	textChatCommand.Parent = TextChatService
end
function ChatHandler.GenerateChatCommands(_)
	for _, chatCommand in pairs(HDAdminMain.infoOnAllCommands.ChatCommands) do
		createChatCommand(chatCommand) -- inferred equivalent call
	end
end

local RunService = game:GetService("RunService")
local _ = not RunService:IsStudio()
function ChatHandler.DecideWelcomePrompt(_)
	createChatCommand("/dance") -- inferred equivalent call
	createChatCommand("/backflip") -- inferred equivalent call
	createChatCommand("/commands") -- inferred equivalent call
	createChatCommand("/helicopter") -- inferred equivalent call
	createChatCommand("/plane") -- inferred equivalent call
end

return ChatHandler