local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local buy = parent:WaitForChild("Main"):WaitForChild("Buy")
local close = parent:WaitForChild("Close")
local main = parent:WaitForChild("Main")
local title = parent:WaitForChild("Title")
local desc = parent:FindFirstChild("Desc")
local ends = main:WaitForChild("Ends")
local instructions = main:WaitForChild("Instructions")
local x = buy:FindFirstChild("X")

local MonetizationConfig = require(ReplicatedStorage:WaitForChild("Monetization"):WaitForChild("MonetizationConfig"))
local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local checkGamepassEntitlement = remotes:FindFirstChild("CheckGamepassEntitlement")
	or remotes:WaitForChild("CheckGamepassEntitlement", 10)
local shopPurchasesUpdated = remotes:FindFirstChild("ShopPurchasesUpdated")
	or remotes:WaitForChild("ShopPurchasesUpdated", 10)

local udim = UDim2.new(0.5, -128, -1, -130)
local udim2 = UDim2.new(0.5, -128, 0.5, -130)
local random = Random.new()
local count = 0
local v = nil

local v2 = {
	VIP = {
		title = "ADMIN COMMANDS",
		description = "HD Admin commands and VIP perks. Type ;cmds for the full command list."
	},
	RainbowVisualizer = {
		title = "RAINBOW VISUALIZER",
		description = "Unlock rainbow visualizer mode while you play."
	},
	GreatPretender = {
		title = "GREAT PRETENDER",
		description = "Hide your AUTOPLAYING overhead tag from everyone."
	},
	GrandPianoLobby = {
		title = "GRAND PIANO LOBBY",
		description = "Unlock access to the Grand Piano Lobby piano."
	},
	PushTool = {
		title = "PUSH TOOL",
		description = "Push piano players in the lobby with the permanent Push Tool."
	},
	Invisibility = {
		title = "INVISIBILITY",
		description = "Toggle invisibility and move around unseen."
	},
	ThirdEye = { title = "THIRD EYE", description = "Reveal invisible players around you." },
	HeartParticleEffect = {
		title = "HEART EFFECT",
		description = "Switch your Synthesia tile effect to heart particles."
	},
	MidiPlayer = {
		title = "MIDI AUTOPLAYER",
		description = "Load MIDI songs and let the piano play them automatically."
	},
	X2NotesPlayed = {
		title = "2X NOTES PLAYED",
		description = "Double your Notes Played stat gains while you play."
	},
	X2NotesCurrency = {
		title = "2X NOTES CURRENCY",
		description = "Earn more Notes currency from active piano rewards."
	}
}

local function setText(guiObject, value) -- 5 equivalent calls inferred from this helper
	if guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
		guiObject.Text = tostring(value or "")
	end
end

local function cleanText(value) -- 1 equivalent call inferred from this helper
	return (tostring(value or ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function limitText(value, p) -- 2 equivalent calls inferred from this helper
	local v3 = cleanText(value) -- inferred equivalent call
	local v4 = math.max(10, (math.floor(tonumber(p) or 120)))

	if #v3 <= v4 then
		return v3
	end

	return string.sub(v3, 1, v4 - 3) .. "..."
end

local function getConfiguredPasses()
	local configuredPasses = {}

	for _, v3 in ipairs(MonetizationConfig.Gamepasses or {}) do
		local gamePassId = math.floor(tonumber(v3.gamePassId) or 0)

		if not (gamePassId > 0) then
			continue
		end

		local v4 = {}

		for k, v5 in pairs(v3) do
			v4[k] = v5
		end

		v4.gamePassId = gamePassId
		table.insert(configuredPasses, v4)
	end

	table.sort(configuredPasses, function(a, b): boolean
		local order = tonumber(a.order) or 999
		local order2 = tonumber(b.order) or 999

		if order == order2 then
			return tostring(a.id or a.name or "") < tostring(b.id or b.name or "")
		end

		return order < order2
	end)

	return configuredPasses
end

local function playerOwnsGamepass(p)
	local gamePassId = math.floor(tonumber(p and p.gamePassId) or 0)

	if gamePassId <= 0 then
		return true
	end

	if checkGamepassEntitlement and checkGamepassEntitlement:IsA("RemoteFunction") then
		local success, result = pcall(function()
			return checkGamepassEntitlement:InvokeServer(gamePassId)
		end)

		if success then
			return result == true
		end
	end

	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, gamePassId)
	end)

	return success and result == true
end

local function chooseAdvertisedPass()
	local v3 = {}

	for _, v4 in ipairs(getConfiguredPasses()) do
		if playerOwnsGamepass(v4) then
			continue
		end

		if v4.id == "VIP" then
			return v4
		end

		table.insert(v3, v4)
	end

	if #v3 == 0 then
		return nil
	end

	return v3[random:NextInteger(1, #v3)]
end

local function getDisplayCopy(data)
	local v3 = v2[data.id] or {}
	local title2 = v3.title or data.name or "GAMEPASS"
	local description = v3.description or data.desc or "Permanent gamepass upgrade."
	local selected = limitText(title2, 34) -- inferred equivalent call
	return selected, limitText(description, 145) -- inferred equivalent call
end

local function applyPass(data)
	v = data
	local displayCopy, v3 = getDisplayCopy(data)
	parent:SetAttribute("CurrentGamePassId", data.gamePassId)
	parent:SetAttribute("CurrentGamePassKey", (tostring(data.id or "")))
	parent:SetAttribute("CurrentGamePassName", (tostring(data.name or displayCopy)))
	buy:SetAttribute("CurrentGamePassId", data.gamePassId)
	setText(title, displayCopy) -- inferred equivalent call
	setText(title:FindFirstChild("Title2"), displayCopy) -- inferred equivalent call
	setText(title:FindFirstChild("Title3"), displayCopy) -- inferred equivalent call
	setText(instructions, v3) -- inferred equivalent call
	local guiObject = ends

	if guiObject and (guiObject:IsA("TextLabel") or guiObject:IsA("TextButton")) then
		guiObject.Text = tostring("GAMEPASS UPGRADE")
	end

	local guiObject2 = x

	if guiObject2 and (guiObject2:IsA("TextLabel") or guiObject2:IsA("TextButton")) then
		guiObject2.Text = tostring("BUY")
	end

	if desc then
		setText(desc, data.name or displayCopy) -- inferred equivalent call
	end
end

local function showPopup()
	parent.Visible = true
	local tween = TweenService:Create(parent, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = udim2
	})

	tween:Play()
	tween.Completed:Wait()
	local fontsHelp = PlayerGui:FindFirstChild("FontsHelp")

	if fontsHelp then
		if fontsHelp:FindFirstChild("Right") then
			fontsHelp.Right.Visible = true
		end

		if fontsHelp:FindFirstChild("Left") then
			fontsHelp.Left.Visible = true
		end
	end
end

local function hidePopup() -- 5 equivalent calls inferred from this helper
	parent.Visible = false
	parent.Position = udim
	v = nil
	parent:SetAttribute("CurrentGamePassId", 0)
	buy:SetAttribute("CurrentGamePassId", 0)
end

local function refreshAdvertisedPass(visible) -- 3 equivalent calls inferred from this helper
	count += 1
	local v3 = count
	task.spawn(function()
		local v4 = chooseAdvertisedPass()

		if v3 ~= count then
			return
		end

		if v4 then
			applyPass(v4)

			if visible then
				showPopup()
			end
		else
			hidePopup() -- inferred equivalent call
		end
	end)
end

hidePopup() -- inferred equivalent call
close.MouseButton1Click:Connect(function()
	local clickSound = close:FindFirstChild("ClickSound")

	if clickSound then
		clickSound:Play()
	end

	hidePopup() -- inferred equivalent call
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= LocalPlayer then
		return
	end

	local v3

	if parent:GetAttribute("PurchasePromptedFromAd") == true then
		v3 = math.floor(tonumber(parent:GetAttribute("PromptedGamePassId")) or 0) == math.floor(tonumber(p2) or 0)
	else
		v3 = false
	end

	parent:SetAttribute("PurchasePromptedFromAd", false)
	parent:SetAttribute("PromptedGamePassId", 0)

	if p3 ~= true then
		return
	end

	task.delay(0.75, function()
		refreshAdvertisedPass(parent.Visible or v3) -- inferred equivalent call
	end)
	task.delay(2.5, function()
		local visible = parent.Visible
		count += 1
		local v4 = count
		task.spawn(function()
			local v5 = chooseAdvertisedPass()

			if v4 ~= count then
				return
			end

			if v5 then
				applyPass(v5)

				if visible then
					showPopup()
				end
			else
				hidePopup() -- inferred equivalent call
			end
		end)
	end)
end)

if shopPurchasesUpdated and shopPurchasesUpdated:IsA("RemoteEvent") then
	shopPurchasesUpdated.OnClientEvent:Connect(function()
		task.delay(0.25, function()
			local visible = parent.Visible
			count += 1
			local v3 = count
			task.spawn(function()
				local v4 = chooseAdvertisedPass()

				if v3 ~= count then
					return
				end

				if v4 then
					applyPass(v4)

					if visible then
						showPopup()
					end
				else
					hidePopup() -- inferred equivalent call
				end
			end)
		end)
	end)
end

LocalPlayer:GetAttributeChangedSignal("PianoProfileReady"):Connect(function()
	if LocalPlayer:GetAttribute("PianoProfileReady") == true then
		refreshAdvertisedPass(parent.Visible) -- inferred equivalent call
	end
end)

task.wait(2)
refreshAdvertisedPass(true) -- inferred equivalent call