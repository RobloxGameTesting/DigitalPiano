local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")

local clickSound = ReplicatedStorage2:WaitForChild("SoundFX"):WaitForChild("ClickSound")

local LocalPlayer = Players.LocalPlayer
local pianoUI = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PianoUI")

local stats = pianoUI:FindFirstChild("Stats") or pianoUI:WaitForChild("Leaderboard")
local body = stats:WaitForChild("Background"):WaitForChild("Body")
local list = body:WaitForChild("List")
local stats2 = body:WaitForChild("Stats")
local buttonContainer = stats:WaitForChild("ButtonContainer")
local topNotesBtn = buttonContainer:WaitForChild("TopNotesBtn")
local timePlayedBtn = buttonContainer:WaitForChild("TimePlayedBtn")
local yourStats = buttonContainer:WaitForChild("YourStats")
local subtitle = stats:WaitForChild("Subtitle")
local close = stats:WaitForChild("Close"):WaitForChild("Close")

local time = stats2:WaitForChild("Time")
local notes = stats2:WaitForChild("Notes")
local loginStreak = stats2:WaitForChild("LoginStreak")
local notesEarned = stats2:WaitForChild("NotesEarned")
local robuxSpent = stats2:WaitForChild("RobuxSpent")
local gameDonated = stats2:FindFirstChild("GameDonated")
local raised = stats2:FindFirstChild("Raised")
local playerDonated = stats2:FindFirstChild("PlayerDonated")

local PlayerTemplate = script:WaitForChild("PlayerTemplate")

local getLeaderboardData = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes"):WaitForChild("GetLeaderboardData")

local color = Color3.fromRGB(45, 118, 235)
local color2 = Color3.fromRGB(50, 50, 50)

local v = false

local v2 = {}
local v3 = {}

local v4 = nil
local v5 = {}
local v6 = {}

local function copyLeaderboardData(list2)
	local result = {}

	if type(list2) ~= "table" then
		return result
	end

	for i, item in ipairs(list2) do
		result[i] = {
			UserId = tonumber(item.UserId) or 0,
			Value = tonumber(item.Value) or 0
		}
	end

	return result
end

local function formatNumberWithCommas(p)
	local v7 = tostring(p)

	repeat
		local v8
		v7, v8 = string.gsub(v7, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v8 == 0

	return v7
end

local function formatTime(p)
	local v7 = math.floor(p / 60)
	local v8 = math.floor(v7 / 60)
	local v9 = math.floor(v8 / 24)
	local v10 = v8 % 24
	local v11 = v7 % 60

	if v9 > 0 then
		if v10 > 0 then
			return string.format("%dD %dH", v9, v10)
		end

		return string.format("%dD", v9)
	elseif v8 > 0 then
		if v11 > 0 then
			return string.format("%dH %dM", v8, v11)
		end

		return string.format("%dH", v8)
	elseif v11 == 1 then
		return "1 Minute"
	else
		return string.format("%d Minutes", v11)
	end
end

local function formatNotes(value)
	if value >= 1000000000000 then
		return string.format("%.1fT+ Notes", value / 1000000000000)
	end

	if value >= 1000000000 then
		return string.format("%.1fB+ Notes", value / 1000000000)
	end

	if value >= 1000000 then
		return string.format("%.1fM+ Notes", value / 1000000)
	end

	return formatNumberWithCommas(value) .. " Notes"
end

local function formatDetailedTime(p)
	if p < 60 then
		if p == 1 then
			return "1 Second"
		end

		return (string.format("%d Seconds", p))
	else
		local v7 = math.floor(p / 60)
		local v8 = math.floor(v7 / 60)
		local v9 = math.floor(v8 / 24)

		local v10 = math.floor(v9 / 365)
		local v11 = v9 - v10 * 365
		local v12 = math.floor(v11 / 30)
		local v13 = v11 - v12 * 30
		local v14 = v8 % 24
		local v15 = v7 % 60

		local v16 = {}

		if v10 > 0 then
			table.insert(v16, v10 == 1 and "1 Year" or string.format("%d Years", v10))
		end

		if v12 > 0 then
			table.insert(v16, v12 == 1 and "1 Month" or string.format("%d Months", v12))
		end

		if v13 > 0 then
			table.insert(v16, v13 == 1 and "1 Day" or string.format("%d Days", v13))
		end

		if v14 > 0 then
			table.insert(v16, v14 == 1 and "1 Hour" or string.format("%d Hours", v14))
		end

		if v15 > 0 and v10 == 0 and v12 == 0 then
			table.insert(v16, v15 == 1 and "1 Minute" or string.format("%d Minutes", v15))
		end

		if #v16 == 0 then
			return "Less than 1 minute"
		end

		return table.concat(v16, ", ")
	end
end

local function getPlayerThumbnail(p)
	if v2[p] then
		return v2[p]
	end

	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)

	if not success then
		return "rbxasset://textures/ui/GuiImagePlaceholder.png"
	end

	v2[p] = result
	return result
end

local function getUsername(userId) -- 1 equivalent call inferred from this helper
	if v3[userId] then
		return v3[userId]
	end

	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(userId)
	end)

	if success and result then
		local v7 = "@" .. result
		v3[userId] = v7
		return v7
	end

	return "Loading..."
end

local function updateButtonColors() -- 1 equivalent call inferred from this helper
	topNotesBtn.BackgroundColor3 = color
	timePlayedBtn.BackgroundColor3 = color2
	subtitle.Text = "Top 50 players with total notes played"
end

local function clearList()
	for _, frame in ipairs(list:GetChildren()) do
		if frame:IsA("Frame") and frame.Name ~= "UIListLayout" then
			frame:Destroy()
		end
	end
end

local function populateLeaderboard(list2)
	clearList()

	if v4 then
		v4 = false
	end

	local now = tick()
	v4 = now

	local v7 = {}

	for i, item in ipairs(list2) do
		if i > 50 then
			break
		end

		local userId = item.UserId
		local value = item.Value

		local clone = PlayerTemplate:Clone()
		clone.Name = "Player" .. i
		clone.LayoutOrder = i

		local background = clone:WaitForChild("Background")
		local icon = background:WaitForChild("Icon")
		local place = background:WaitForChild("Place")
		local player = background:WaitForChild("Player")
		local value2 = background:WaitForChild("Value")

		place.Text = "" .. i

		value2.Text = formatNotes(value)

		icon.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		player.Text = "@Loading..."

		clone.Parent = list

		table.insert(v7, { userId = userId, icon = icon, playerLabel = player })
	end

	task.spawn(function()
		for i = 1, #v7, 5 do
			if v4 ~= now then
				break
			end

			local v8 = math.min(i + 5 - 1, #v7)

			for j = i, v8 do
				local v9 = v7[j]

				local icon = v9.icon
				local userId = v9.userId
				local result

				if v2[userId] then
					result = v2[userId]
				else
					local success
					success, result = pcall(function()
						return Players:GetUserThumbnailAsync(
							userId,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size150x150
						)
					end)

					if success then
						v2[userId] = result
					else
						result = "rbxasset://textures/ui/GuiImagePlaceholder.png"
					end
				end

				icon.Image = result

				local playerLabel = v9.playerLabel
				playerLabel.Text = getUsername(v9.userId) -- inferred equivalent call
			end

			if v8 < #v7 then
				task.wait(0.5)
			end
		end
	end)
end

local function refreshLeaderboard(p)
	local topNotes = v5.TopNotes

	if not p and topNotes and topNotes.Data and os.clock() - topNotes.LoadedAt < 120 then
		populateLeaderboard(copyLeaderboardData(topNotes.Data))
	elseif v6.TopNotes then
		if topNotes and topNotes.Data then
			populateLeaderboard(copyLeaderboardData(topNotes.Data))
		end
	else
		v6.TopNotes = true
		local success, result = pcall(function()
			return getLeaderboardData:InvokeServer("TopNotes")
		end)

		v6.TopNotes = nil

		if success and result then
			v5.TopNotes = { Data = copyLeaderboardData(result), LoadedAt = os.clock() }

			if not v then
				populateLeaderboard(copyLeaderboardData(result))
			end
		elseif topNotes and topNotes.Data then
			populateLeaderboard(copyLeaderboardData(topNotes.Data))
		else
			ClientDebugConfig.Warn("[LeaderboardUI] Failed to fetch leaderboard data")
		end
	end
end

local function updatePlayerStats()
	local hiddenStats = LocalPlayer:FindFirstChild("HiddenStats")

	local v7 = 0
	local v8 = 0
	local v9 = 0
	local v10 = 0
	local v11 = 0
	local v12 = 0
	local v13 = 0
	local v14 = 0

	if hiddenStats then
		local notesPlayed = hiddenStats:FindFirstChild("Notes Played")

		if notesPlayed then
			v7 = notesPlayed.Value
		end

		local timePlayed = hiddenStats:FindFirstChild("Time Played")

		if timePlayed then
			v8 = timePlayed.Value
		end

		local longestLoginStreak = hiddenStats:FindFirstChild("Longest Login Streak")

		if longestLoginStreak then
			v9 = longestLoginStreak.Value
		end

		local totalNotesEarned = hiddenStats:FindFirstChild("Total Notes Earned")

		if totalNotesEarned then
			v10 = totalNotesEarned.Value
		end

		local totalRobuxSpent = hiddenStats:FindFirstChild("Total Robux Spent")

		if totalRobuxSpent then
			v11 = totalRobuxSpent.Value
		end

		local gameDonated2 = hiddenStats:FindFirstChild("Game Donated")

		if gameDonated2 then
			v12 = gameDonated2.Value
		end

		local robuxDonated = hiddenStats:FindFirstChild("Robux Donated")

		if robuxDonated then
			v13 = robuxDonated.Value
		end

		local robuxRaised = hiddenStats:FindFirstChild("Robux Raised")

		if robuxRaised then
			v14 = robuxRaised.Value
		end
	end

	local frame = time:FindFirstChild("Frame")

	local value = frame and frame:FindFirstChild("Value")

	if value then
		value.Text = formatDetailedTime(v8)
	end

	local frame2 = notes:FindFirstChild("Frame")

	local value2 = frame2 and frame2:FindFirstChild("Value")

	if value2 then
		value2.Text = formatNumberWithCommas(v7)
	end

	local frame3 = loginStreak:FindFirstChild("Frame")

	local value3 = frame3 and frame3:FindFirstChild("Value")

	if value3 then
		value3.Text = v9 == 1 and "1 Day" or formatNumberWithCommas(v9) .. " Days"
	end

	local frame4 = notesEarned:FindFirstChild("Frame")

	local value4 = frame4 and frame4:FindFirstChild("Value")

	if value4 then
		value4.Text = formatNumberWithCommas(v10)
	end

	local frame5 = robuxSpent:FindFirstChild("Frame")

	local value5 = frame5 and frame5:FindFirstChild("Value")

	if value5 then
		value5.Text = formatNumberWithCommas(v11) .. " Robux"
	end

	local gameDonatedFrame = gameDonated and gameDonated:FindFirstChild("Frame")

	local value6 = gameDonatedFrame and gameDonatedFrame:FindFirstChild("Value")

	if value6 then
		value6.Text = formatNumberWithCommas(v12) .. " Robux"
	end

	local raisedFrame = raised and raised:FindFirstChild("Frame")

	local value7 = raisedFrame and raisedFrame:FindFirstChild("Value")

	if value7 then
		value7.Text = formatNumberWithCommas(v14) .. " Robux"
	end

	local playerDonatedFrame = playerDonated and playerDonated:FindFirstChild("Frame")

	local value8 = playerDonatedFrame and playerDonatedFrame:FindFirstChild("Value")

	if value8 then
		value8.Text = formatNumberWithCommas(v13) .. " Robux"
	end
end

local function showPlayerStats()
	v = true
	list.Visible = false
	stats2.Visible = true
	subtitle.Text = "Your Statistics"

	updatePlayerStats()

	topNotesBtn.BackgroundColor3 = color2
	timePlayedBtn.BackgroundColor3 = color2
	yourStats.BackgroundColor3 = color
end

local function showLeaderboard()
	v = false
	list.Visible = true
	stats2.Visible = false
	yourStats.BackgroundColor3 = color2
	updateButtonColors() -- inferred equivalent call
	refreshLeaderboard()
end

local LeaderboardUI = {
	Initialize = function()
		v = true
		list.Visible = false
		stats2.Visible = true
		subtitle.Text = "Your Statistics"

		topNotesBtn.Visible = false
		timePlayedBtn.Visible = false
		yourStats.Visible = false
		yourStats.Text = "Stats"
		yourStats.BackgroundColor3 = color
		buttonContainer.Visible = false

		updatePlayerStats()

		yourStats.MouseButton1Click:Connect(function()
			clickSound:Play()
			v = true
			list.Visible = false
			stats2.Visible = true
			subtitle.Text = "Your Statistics"

			updatePlayerStats()

			topNotesBtn.BackgroundColor3 = color2
			timePlayedBtn.BackgroundColor3 = color2
			yourStats.BackgroundColor3 = color
		end)

		close.MouseButton1Click:Connect(function()
			clickSound:Play()
			stats.Visible = false
		end)

		RunService.Heartbeat:Connect(function()
			if stats2.Visible then
				updatePlayerStats()
			end
		end)
	end,
	Refresh = function()
		updatePlayerStats()
	end
}

ClientDebugConfig.Print("[LeaderboardUI.lua] Ready")
return LeaderboardUI