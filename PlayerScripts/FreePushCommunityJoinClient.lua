local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local GroupService = game:GetService("GroupService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")

local PromptCommunityJoin = ReplicatedStorage2:WaitForChild("PromptCommunityJoin")
local CommunityJoinResult = ReplicatedStorage2:WaitForChild("CommunityJoinResult")
local FreePushAnnouncement = ReplicatedStorage2:WaitForChild("FreePushAnnouncement")
local FreePushSendNotification = ReplicatedStorage2:WaitForChild("FreePushSendNotification")
local PlayErrorSound = ReplicatedStorage2:WaitForChild("PlayErrorSound")
local SoundFX = ReplicatedStorage2:WaitForChild("SoundFX")

local function notify(title, value, duration) -- 2 equivalent calls inferred from this helper
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = tostring(title or "Piano Sim"),
			Text = tostring(value or ""),
			Duration = tonumber(duration) or 3
		})
	end)
end

local function escapeRichText(value) -- 1 equivalent call inferred from this helper
	return tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function stripSystemPrefix(value) -- 1 equivalent call inferred from this helper
	return tostring(value or ""):gsub("^%s*%[SYSTEM%]%s*", "")
end

local function getTextChannel()
	local textChannels = TextChatService:FindFirstChild("TextChannels")
		or TextChatService:WaitForChild("TextChannels", 15)

	if textChannels then
		return textChannels:FindFirstChild("RBXSystem")
			or textChannels:FindFirstChild("RBXGeneral")
			or textChannels:WaitForChild("RBXGeneral", 5)
	end

	return nil
end

local function postSystemChat(value)
	local v = stripSystemPrefix(value) -- inferred equivalent call

	if v == "" then
		return
	end

	local textChannel = getTextChannel()

	if textChannel and textChannel.DisplaySystemMessage and pcall(function()
		textChannel:DisplaySystemMessage(
			"<font color='#5AFF7D'><b>[SYSTEM]</b></font> " .. escapeRichText(v), -- inferred equivalent call
			"FreePushSystem"
		)
	end) then
		return
	end

	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "[SYSTEM] " .. v,
			Color = Color3.fromRGB(90, 255, 125),
			Font = Enum.Font.GothamBold
		})
	end)
end

PromptCommunityJoin.OnClientEvent:Connect(function(p)
	local v = math.floor(tonumber(p) or 0)
	local v2 = "None"

	if v > 0 then
		local success, result = pcall(function()
			return GroupService:PromptJoinAsync(v)
		end)

		if success and typeof(result) == "EnumItem" then
			v2 = result.Name
		elseif not success then
			ClientDebugConfig.Warn("[FreePushCommunityJoinClient] PromptJoinAsync failed:", (tostring(result)))
		end
	end

	CommunityJoinResult:FireServer(v2)
end)

FreePushAnnouncement.OnClientEvent:Connect(function(p)
	postSystemChat(p)
end)

FreePushSendNotification.OnClientEvent:Connect(function(data)
	if type(data) == "table" then
		notify(data.Title, data.Text, data.Duration) -- inferred equivalent call
	else
		notify("Free Push", data, 3) -- inferred equivalent call
	end
end)

PlayErrorSound.OnClientEvent:Connect(function()
	local err = SoundFX:FindFirstChild("Error")

	if not (err and err:IsA("Sound")) then
		ClientDebugConfig.Warn("[FreePushCommunityJoinClient] Missing ReplicatedStorage.SoundFX.Error")
		return
	end

	local freePushErrorSound = err:Clone()
	freePushErrorSound.Name = "FreePushErrorSound"
	freePushErrorSound.Parent = SoundService
	freePushErrorSound.TimePosition = 0
	freePushErrorSound:Play()
	freePushErrorSound.Ended:Connect(function()
		freePushErrorSound:Destroy()
	end)
	task.delay(math.max(3, freePushErrorSound.TimeLength + 1), function()
		if freePushErrorSound.Parent then
			freePushErrorSound:Destroy()
		end
	end)
end)