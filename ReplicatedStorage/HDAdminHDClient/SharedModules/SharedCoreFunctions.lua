local SharedCoreFunctions = {}

local HDAdminMain = _G.HDAdminMain
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()

function SharedCoreFunctions.SetSeed(_, p: number)
	if p > 100000000 then
		local v = #tostring(100000000)
		p = tonumber((string.sub(tostring(p), -v)))
	end

	math.randomseed(p)
	return p
end

local v = {}
function SharedCoreFunctions.GetAnimationId(_, p)
	local v2 = tostring(p)
	local v3 = v[v2]

	if v3 then
		return v3
	end

	if isClient then
		local success, result = pcall(function()
			return HDAdminMain.signals.GetAnimationId:InvokeServer(p)
		end)

		if success and result then
			v[v2] = result
			return result
		end

		return 0
	else
		local success, result = pcall(function()
			local InsertService = game:GetService("InsertService")
			return InsertService:LoadAsset(p)
		end)

		if not success then
			return
		end

		local animation = success and result:FindFirstChildOfClass("Animation")

		if animation then
			v3 = tonumber(animation.AnimationId:match("%d+"))
			v[v2] = v3
			animation:Destroy()
		end

		return v3
	end
end

local names = nil
function SharedCoreFunctions.GetEmotesDict(_)
	if names then
		return names
	end

	local emotes = HDAdminMain:GetModule("cf"):GetEmotes()
	names = {}

	for _, emote in emotes do
		local id = emote.id
		names[tostring(id)] = emote.name
	end

	return names
end

local result = nil
local v2 = false
local flag = false
function SharedCoreFunctions:GetEmotes(p)
	if isClient then
		while flag do
			task.wait(0.5)
		end

		if result then
			return result
		end

		flag = true
		local success, result2 = pcall(function()
			return HDAdminMain.signals.GetEmotes:InvokeServer()
		end)

		flag = false

		if not success or typeof(result2) ~= "table" then
			return {}
		end

		result = result2
		return result
	else
		local function returnWithFavorites(list)
			local v3 = p and HDAdminMain.pd[p]
			local favoritedUGC = v3 and v3.FavoritedUGC

			if typeof(favoritedUGC) ~= "table" then
				return list
			end

			local set = {}

			for _, item in list do
				set[tostring(item.id)] = true
			end

			for k, v4 in favoritedUGC do
				local v5 = tostring(k)

				if set[v5] then
					continue
				end

				set[v5] = true
				local name = tostring(v4.name)
				table.insert(list, { id = tonumber(k), name = name })
			end

			return list
		end

		local AvatarEditorService = game:GetService("AvatarEditorService")

		if v2 == true then
			repeat
				task.wait(1)
			until v2 ~= true
		end

		if result then
			return returnWithFavorites(result)
		end

		local v3 = {}

		local catalogSearchParams = CatalogSearchParams.new()
		catalogSearchParams.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
		catalogSearchParams.CreatorType = Enum.CreatorTypeFilter.Group
		catalogSearchParams.CreatorId = 4676369
		catalogSearchParams.SortType = Enum.CatalogSortType.RecentlyCreated
		catalogSearchParams.Limit = 120
		v2 = true
		local v4 = 1
		local result2

		while true do
			local success
			success, result2 = pcall(function()
				return AvatarEditorService:SearchCatalog(catalogSearchParams)
			end)

			if success then
				break
			end

			task.wait(v4)
			v4 *= 2
		end

		repeat
			local currentPage = result2:GetCurrentPage()

			for _, v5 in currentPage do
				table.insert(v3, v5)
			end

			if result2.IsFinished then
				break
			end

			local success, result3 = pcall(function()
				result2:AdvanceToNextPageAsync()
			end)

			if not success then
				warn("Failed to advance to next page:", result3)
				break
			end

			task.wait(0.1)
		until result2.IsFinished

		v2 = false

		if #v3 == 0 then
			return returnWithFavorites({})
		end

		result = {}

		local module = HDAdminMain:GetModule("Emotes") or {}
		local names2 = {}
		local set = {}

		for _, v5 in module do
			local id = v5.id
			local name = v5.name
			names2[tostring(id)] = name
		end

		for _, v5 in v3 do
			local name = tostring(v5.Name)
			local id = v5.Id
			local name2 = names2[tostring(id)] or HDAdminMain:GetModule("cf"):normalizeName(name)

			table.insert(result, { id = id, name = name2 })

			set[tostring(id)] = true
		end

		for _, v5 in module do
			local id = tostring(v5.id)

			if set[id] then
				continue
			end

			set[id] = true
			table.insert(result, v5)
		end

		return returnWithFavorites(result)
	end
end

function SharedCoreFunctions.denormalizeName(_, value: string)
	if value == "" then
		return ""
	end

	local v3 = {}
	local v4 = 1

	for i = 2, #value do
		if not value:sub(i, i):match("%u") then
			continue
		end

		table.insert(v3, value:sub(v4, i - 1))
		v4 = i
	end

	table.insert(v3, value:sub(v4))

	for i, v5 in ipairs(v3) do
		v3[i] = v5:sub(1, 1):upper() .. v5:sub(2):lower()
	end

	return table.concat(v3, " ")
end

function SharedCoreFunctions:normalizeName(p: string)
	local v3 = {}

	for k in tostring(p):match("^%s*(.-)%s*$"):gsub("[^%a%s]", ""):gmatch("%S+") do
		table.insert(v3, k)
	end

	local count = #v3

	if count == 0 then
		return ""
	elseif count == 1 then
		return v3[1]:lower()
	end

	if count ~= 2 then
		return table.concat(v3, ""):lower()
	end

	local lower = v3[1]:lower()
	local v4 = v3[2]
	return lower .. v4:sub(1, 1):upper() .. v4:sub(2):lower()
end

local v3 = {
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
	"<",
	">",
	"?",
	"@",
	"{",
	"}",
	"[",
	"]",
	"!",
	"(",
	")",
	"=",
	"+",
	"~",
	"#"
}
local function getListForLimiter(p: string?)
	local result2 = {}

	if p == "Letters" then
		for _, v4 in v3 do
			table.insert(result2, v4)

			if v4 == "Z" then
				return result2
			end
		end
	elseif p == "LettersAndNumbers" then
		for _, v4 in v3 do
			table.insert(result2, v4)

			if v4 == "0" then
				return result2
			end
		end
	elseif p ~= nil then
		error(`Limiter '{p}' does not exist!`)
	end

	return v3
end

function SharedCoreFunctions.GenerateUID(_, value: number, p: string?)
	local listForLimiter = getListForLimiter(p)
	local v4 = #listForLimiter
	local uid = ""

	for _ = 1, value or 8 do
		uid ..= listForLimiter[math.random(1, v4)]
	end

	return uid
end

local messageOutConnection = nil
function SharedCoreFunctions.PromptGamepass(_, player, value)
	local function getRealPassId(p)
		local v4 = not p and value

		if tonumber(value) ~= nil or typeof(value) ~= "string" then
			return v4
		end

		if p then
			return HDAdminMain.accessories[value]
		end

		return HDAdminMain.products[value]
	end

	if HDAdminMain.runService:IsServer() then
		HDAdminMain.signals.PromptGamepass:FireClient(player, value)
	else
		task.defer(function()
			if value == "Booster" then
				if HDAdminMain.gui.MainFrame.Pages.Boost.Buy.Banner.Fade.Discount.Visible then
					value = HDAdminMain.accessories.Booster2
				else
					value = HDAdminMain.accessories.Booster
				end
			end

			local flag2 = false

			for _, accessory in HDAdminMain.accessories do
				if tostring(accessory) == tostring(value) then
					flag2 = true
					break
				end
			end

			if flag2 then
				HDAdminMain.signals.PurchaseAccessory:FireServer(value)
				return
			end

			local v4 = value

			if tonumber(value) == nil and typeof(value) == "string" then
				v4 = HDAdminMain.products[value]
			end

			local v5

			if tonumber(value) == nil and typeof(value) == "string" then
				v5 = HDAdminMain.accessories[value]
			else
				v5 = false
			end

			local v6 = v4 or v5 or 0
			local LogService = game:GetService("LogService")

			if messageOutConnection then
				messageOutConnection:Disconnect()
				messageOutConnection = nil
			end

			local gamepasses = HDAdminMain:GetModule("cf"):GetGamepasses()

			local v7 = tostring(v6)
			local v8 = nil

			for _, gamepass in pairs(gamepasses) do
				v8 = gamepass[v7]

				if v8 then
					break
				end
			end

			messageOutConnection = LogService.MessageOut:Connect(function(p, p2)
				if p2 == Enum.MessageType.MessageWarning and tostring(p):match("AllowThirdPartySales") then
					if
						v8
						and not v8.FromHD
						and (not v8.Rank or v8.Rank and HDAdminMain.pdata.Rank and v8.Rank <= HDAdminMain.pdata.Rank)
					then
						HDAdminMain:GetModule("Notices"):Notice(
							"Error",
							HDAdminMain.hdAdminCoreName,
							"ThirdPartySales must be enabled. Click to see how.",
							{
								"CallFunctionOnClick",
								function()
									HDAdminMain:GetModule("cf"):CreateNewCommandMenu("purchase", v6, 14)
								end
							}
						)
					elseif v5 then
						HDAdminMain.signals.PurchaseAccessory:FireServer(v5)
					else
						HDAdminMain:GetModule("cf"):CreateNewCommandMenu("purchase", v6, 13)
					end

					if messageOutConnection then
						messageOutConnection:Disconnect()
						messageOutConnection = nil
					end
				end
			end)
			task.delay(5, function()
				if messageOutConnection then
					messageOutConnection:Disconnect()
					messageOutConnection = nil
				end
			end)
			local RunService2 = game:GetService("RunService")

			if RunService2:IsStudio() then
				HDAdminMain:GetModule("Notices"):Notice(
					"Error",
					HDAdminMain.hdAdminCoreName,
					"This can only be purchased in-game."
				)
			else
				local _, _ = pcall(function()
					return HDAdminMain.marketplaceService:PromptGamePassPurchase(player, v6)
				end)
			end
		end)
	end
end

function SharedCoreFunctions.WaitForEvent(_, ...)
	local bindableEvent = ({ ... })[1]
	local v4

	if typeof(bindableEvent) == "Instance" and bindableEvent:IsA("BindableEvent") then
		v4 = bindableEvent
	else
		v4 = Instance.new("BindableEvent")
	end

	local connections = {}

	for _, v5 in pairs({ ... }) do
		if v5 ~= bindableEvent then
			connections[#connections + 1] = v5:Connect(function()
				v4:Fire()
			end)
		end
	end

	v4.Event:Wait()
	v4:Destroy()

	for _, connection in pairs(connections) do
		connection:Disconnect()
	end
end

function SharedCoreFunctions.HasBooster(_, p): boolean
	local v4 = p or HDAdminMain.player
	local success, result2 = pcall(function(): boolean
		if
			HDAdminMain.marketplaceService:UserOwnsGamePassAsync(v4.UserId, HDAdminMain.products.Booster)
			or HDAdminMain.marketplaceService:UserOwnsGamePassAsync(v4.UserId, HDAdminMain.products.Donor)
			or HDAdminMain.marketplaceService:PlayerOwnsAsset(v4, HDAdminMain.accessories.Booster)
			or HDAdminMain.marketplaceService:PlayerOwnsAsset(v4, HDAdminMain.accessories.Booster2)
		then
			return true
		end

		return false
	end)
	return success == true and result2 == true
end

function SharedCoreFunctions.CreateSound(_, items)
	local sound = Instance.new("Sound")

	for k, item in pairs(items) do
		if k == "SoundId" then
			item = "rbxassetid://" .. item
		end

		sound[k] = item
	end

	return sound
end

function SharedCoreFunctions.FormatNotice2(_, p, p2, ...)
	local notice = HDAdminMain:GetModule("CoreNotices"):GetNotice(p)
	notice[2] = string.format(notice[2], ...)
	notice[3] = p2
	return notice
end

function SharedCoreFunctions.FormatNotice(_, p, ...)
	local notice = HDAdminMain:GetModule("CoreNotices"):GetNotice(p)
	notice[2] = string.format(notice[2], ...)
	return notice
end

function SharedCoreFunctions.RandomiseTable(_, list, p)
	local v4 = p and math.floor(os.time() / p)
	local result2 = {}

	if list[1] == nil then
		return result2
	end

	for i = 1, #list do
		if p then
			math.randomseed(v4 + i)
		end

		table.insert(result2, math.random(1, #result2 + 1), list[i])
	end

	return result2
end

function SharedCoreFunctions.IsPunished(_, player): boolean
	return not (player and player.Character) or player.Character.Parent ~= workspace
end

function SharedCoreFunctions.UnSeatPlayer(_, p)
	local humanoid = SharedCoreFunctions:GetHumanoid(p)

	if humanoid then
		local seatPart = humanoid.SeatPart

		local seatWeld = seatPart and seatPart:FindFirstChild("SeatWeld")

		if seatWeld then
			seatWeld:Destroy()
			wait()
		end
	end
end

function SharedCoreFunctions.GetBanDateString(_, p, data)
	local v4 = p.min or data.min
	local v5 = p.hour or data.hour
	local day = p.day or data.day
	local v6 = HDAdminMain:GetModule("cf"):GetMonths()[p.month or data.month]
	local year = p.year or data.year

	if v4 < 10 then
		v4 = "0" .. v4
	end

	if v5 < 10 then
		v5 = "0" .. v5
	end

	local v7 = tonumber((string.sub(day, -1)))
	local v8 = "th"

	if v7 < 10 or v7 > 15 then
		if v7 == 1 then
			v8 = "st"
		elseif v7 == 2 then
			v8 = "nd"
		else
			v8 = if v7 == 3 then "rd" else v8
		end
	end

	local v9 = ""
	v9 = (not p or next(p) == nil) and data and " UTC" or v9

	return v5 .. ":" .. v4 .. ", " .. day .. v8 .. " " .. v6 .. " " .. year .. v9
end

function SharedCoreFunctions.GetTimeAmount(_, p, p2)
	local v4 = 0
	local v5 = ""
	local v6 = p2 < 0 and 0 or p2

	if p == "m" then
		v6 = v6 > 60 and 60 or v6
		v4 = v6 * 60
		v5 = "Minutes"
	elseif p == "h" then
		v6 = v6 > 24 and 24 or v6
		v4 = v6 * 3600
		v5 = "Hours"
	elseif p == "d" then
		v6 = v6 > 100000 and 100000 or v6
		v4 = v6 * 86400
		v5 = "Days"
	end

	return v4, v5, v6
end

function SharedCoreFunctions:GetMonths()
	return {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December"
	}
end

function SharedCoreFunctions.AnchorModel(_, folder, anchored)
	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") or part.Parent:IsA("Accessory") then
			continue
		end

		part.Anchored = anchored
	end
end

function SharedCoreFunctions.TweenModel(_, instance, p, p2)
	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Value = instance:GetPrimaryPartCFrame()
	local valueChangedConnection = nil
	valueChangedConnection = cframeValue:GetPropertyChangedSignal("Value"):Connect(function()
		if instance.PrimaryPart == nil then
			valueChangedConnection:Disconnect()
		else
			instance:SetPrimaryPartCFrame(cframeValue.Value)
		end
	end)
	local v4 = HDAdminMain.tweenService:Create(cframeValue, p2, { Value = p })
	v4:Play()
	v4.Completed:Connect(function()
		cframeValue:Destroy()
	end)
end

function SharedCoreFunctions.Movement(_, p, p2)
	if p2 == nil then
		p2 = HDAdminMain.player
	end

	local hrp = SharedCoreFunctions:GetHRP(p2)
	local humanoid = SharedCoreFunctions:GetHumanoid(p2)

	if hrp and humanoid then
		if p then
			hrp.Anchored = false
		else
			local walkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0
			wait()
			humanoid.WalkSpeed = walkSpeed
			hrp.Anchored = true
		end
	end
end

function SharedCoreFunctions:SetFakePart(instance, items, instance2)
	task.defer(function()
		local name = instance2.Name
		local fakeBodyPart = HDAdminMain:GetModule("MorphHandler"):CreateFakeBodyPart(instance, instance2)
		local connections = {}
		local function cleanup()
			for _, connection in pairs(connections) do
				connection:Disconnect()
			end

			fakeBodyPart:Destroy()

			if fakeBodyPart:GetAttribute("DisableMorphPart") then
				return
			end

			local child = instance:WaitForChild(name, 4)
			local humanoid = instance:FindFirstChildOfClass("Humanoid")

			if child and instance.Parent and humanoid and humanoid.Health > 0 then
				SharedCoreFunctions:SetFakePart(instance, items, child)
			end
		end
		table.insert(connections, instance2.Destroying:Once(cleanup))
		table.insert(connections, instance2:GetPropertyChangedSignal("Size"):Once(cleanup))

		for k, item in pairs(items) do
			if k == "Material" then
				fakeBodyPart.Material = item

				if item == Enum.Material.Glass then
					fakeBodyPart.Transparency = 0.5
				else
					fakeBodyPart.Transparency = 0
				end
			elseif k == "Reflectance" then
				fakeBodyPart.Reflectance = item
			elseif k == "Transparency" then
				fakeBodyPart.Transparency = item
			elseif k == "Color" then
				fakeBodyPart.Color = item
			end
		end
	end)
end

function SharedCoreFunctions.SetFakeBodyParts(_, folder, p)
	for _, descendant in pairs(folder:GetDescendants()) do
		local parent = descendant.Parent

		if not ((parent == folder or parent and parent:IsA("Accessory")) and HDAdminMain:GetModule("cf"):CheckBodyPart(descendant)) then
			continue
		end

		SharedCoreFunctions:SetFakePart(folder, p, descendant)
	end
end

function SharedCoreFunctions:CheckBodyPart(part): boolean
	if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and string.sub(part.Name, 1, 4) ~= "Fake" then
		return true
	end

	return false
end

function SharedCoreFunctions.CreateClone(_, instance)
	if instance == nil then
		instance = HDAdminMain.player.Character
	end

	local humanoid = instance:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	instance.Archivable = true
	local clone = instance:Clone()
	local humanoid2 = clone.Humanoid
	clone.Name = instance.Name .. "'s HDAdminClone"

	local v4 = clone:FindFirstChild("Chest") and true or false

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("Humanoid") then
			descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		elseif descendant:IsA("BillboardGui") then
			descendant:Destroy()
		elseif descendant:IsA("Weld") and descendant.Part1 ~= nil then
			descendant.Part0 = descendant.Parent

			if clone:FindFirstChild(descendant.Part1.Name) then
				descendant.Part1 = clone[descendant.Part1.Name]
			elseif not v4 then
				descendant:Destroy()
			end
		end
	end

	clone.Parent = workspace

	local tracksByName = {}
	humanoid:GetAppliedDescription()

	if not clone:FindFirstChild("Animate") then
		return clone, tracksByName
	end

	for _, child in pairs(clone.Animate:GetChildren()) do
		local v5 = child:GetChildren()[1]

		if v5 then
			tracksByName[child.Name] = humanoid2:LoadAnimation(v5)
		end
	end

	tracksByName.idle:Play()

	return clone, tracksByName
end

function SharedCoreFunctions.SetTransparency(_, folder, transparency, p)
	local playerFromCharacter = HDAdminMain.players:GetPlayerFromCharacter(folder)

	if
		playerFromCharacter
		and HDAdminMain.pd[playerFromCharacter]
		and HDAdminMain.pd[playerFromCharacter].Items.UnderControl
		and not p
		or not folder
	then
		return
	end

	local v4 = folder:FindFirstChild("FakeHead") and true or false

	for _, descendant in pairs(folder:GetDescendants()) do
		if
			descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart"
			or descendant.Name == "face" and descendant:IsA("Decal")
		then
			local originalTransparency = descendant:FindFirstChild("OriginalTransparency")

			if transparency == 1 and descendant.Transparency ~= 0 and not originalTransparency then
				local originalTransparency2 = Instance.new("IntValue")
				originalTransparency2.Name = "OriginalTransparency"
				originalTransparency2.Value = descendant.Transparency
				originalTransparency2.Parent = descendant
			elseif transparency == 0 and originalTransparency then
				descendant.Transparency = originalTransparency.Value
				originalTransparency:Destroy()
			elseif not v4 or folder:FindFirstChild(descendant.Name .. "Fake") == nil then
				descendant.Transparency = transparency
			end
		elseif
			descendant:IsA("ParticleEmitter") and descendant.Name == "BodyEffect"
			or descendant:IsA("PointLight")
		then
			if transparency == 1 then
				descendant.Enabled = false
			elseif transparency == 0 then
				descendant.Enabled = true
			end
		elseif descendant:IsA("BillboardGui") then
			if transparency == 1 then
				descendant.Enabled = false
			elseif transparency == 0 then
				descendant.Enabled = true
			end
		end
	end
end

function SharedCoreFunctions.GetMessageTime(_, value)
	local v4 = string.len(value) * 0.08 + 2

	return v4 > 10 and 10 or v4
end

function SharedCoreFunctions:GetProductInfo(p)
	local success, result2 = pcall(function()
		return HDAdminMain.marketplaceService:GetProductInfo(p)
	end)
	return not success and {} or result2
end

function SharedCoreFunctions.CheckIfValidSound(_, p): boolean
	return SharedCoreFunctions:GetProductInfo(p).AssetTypeId == 3
end

function SharedCoreFunctions.GetChar(_, player)
	if player == nil then
		player = HDAdminMain.player
	end

	if player then
		return player.Character
	end
end

function SharedCoreFunctions:GetHRP(player)
	if player == nil then
		player = HDAdminMain.player
	end

	if player and player.Character then
		return (player.Character:FindFirstChild("HumanoidRootPart"))
	end
end

local function getNeckAttachment(animationConstraint) -- 3 equivalent calls inferred from this helper
	if animationConstraint:IsA("AnimationConstraint") then
		return animationConstraint.Attachment0
	end

	return nil
end

function SharedCoreFunctions.GetNeckOffset(_, jointInstance)
	if jointInstance:IsA("JointInstance") then
		return jointInstance.C0
	end

	local neckAttachment = getNeckAttachment(jointInstance) -- inferred equivalent call

	if neckAttachment then
		return neckAttachment.CFrame
	end

	return CFrame.identity
end

function SharedCoreFunctions.SetNeckOffset(_, jointInstance, p)
	if jointInstance:IsA("JointInstance") then
		jointInstance.C0 = p
		return
	end

	local neckAttachment = getNeckAttachment(jointInstance) -- inferred equivalent call

	if neckAttachment then
		neckAttachment.CFrame = p
	end
end

function SharedCoreFunctions.TweenNeckOffset(_, jointInstance, p, tweenInfo)
	local TweenService = game:GetService("TweenService")

	if jointInstance:IsA("JointInstance") then
		TweenService:Create(jointInstance, tweenInfo, { C0 = p }):Play()
		return
	end

	local neckAttachment = getNeckAttachment(jointInstance) -- inferred equivalent call

	if neckAttachment then
		TweenService:Create(neckAttachment, tweenInfo, { CFrame = p }):Play()
	end
end

function SharedCoreFunctions.GetNeck(_, player)
	if player == nil then
		player = HDAdminMain.player
	end

	local head = player and player.Character and player.Character:FindFirstChild("Head")

	if not head then
		return
	end

	local neck = head:FindFirstChild("Neck")
	local torso = player.Character:FindFirstChild("Torso")

	if not neck and torso then
		neck = torso:FindFirstChild("Neck")
	end

	return neck
end

function SharedCoreFunctions.GetHead(_, player)
	if player == nil then
		player = HDAdminMain.player
	end

	if player and player.Character then
		return (player.Character:FindFirstChild("Head"))
	end
end

function SharedCoreFunctions.GetFace(_, player)
	if player == nil then
		player = HDAdminMain.player
	end

	if not (player and player.Character) then
		return
	end

	local head = player.Character:FindFirstChild("Head")

	if not head then
		return head
	end

	local face = head:FindFirstChild("face")
	return if face and face.ClassName == "Decal" then face else head
end

function SharedCoreFunctions:GetHumanoid(player)
	if player == nil then
		player = HDAdminMain.player
	end

	if player and player.Character then
		return (player.Character:FindFirstChild("Humanoid"))
	end
end

function SharedCoreFunctions.GetTorso(_, player)
	if player == nil then
		player = HDAdminMain.player
	end

	if player and player.Character then
		return player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
	end
end

function SharedCoreFunctions.SetJumpHeight(_, p, jumpHeight)
	local humanoid = SharedCoreFunctions:GetHumanoid(p)

	if humanoid then
		humanoid.JumpHeight = jumpHeight
		humanoid.JumpPower = math.sqrt(2 * workspace.Gravity * jumpHeight)
	end
end

function SharedCoreFunctions.GetDescription(_, p)
	local humanoid = SharedCoreFunctions:GetHumanoid(p)
	return humanoid and humanoid:GetAppliedDescription()
end

function SharedCoreFunctions:GetProductInfo(p, p2)
	local productInfo = {}
	local _, _ = pcall(function()
		productInfo = HDAdminMain.marketplaceService:GetProductInfo(p, p2)
	end)

	return productInfo
end

function SharedCoreFunctions.GetFriends(_, p)
	local idsByUsername = {}
	local success, result2 = pcall(function()
		return HDAdminMain.players:GetFriendsAsync(p)
	end)

	if not success then
		return idsByUsername
	end

	repeat
		local currentPage = result2:GetCurrentPage()

		for _, v4 in pairs(currentPage) do
			idsByUsername[v4.Username] = v4.Id
		end
	until not (result2.IsFinished or pcall(function()
		return result2:AdvanceToNextPageAsync()
	end)) or result2.IsFinished

	return idsByUsername
end

function SharedCoreFunctions.GetRankName(_, p)
	local rankName = ""

	for _, rank in pairs(HDAdminMain.settings.Ranks) do
		local v4 = rank[1]
		local v5 = rank[2]

		if p == v4 then
			rankName = v5
		end
	end

	return rankName
end

function SharedCoreFunctions.GetRankId(_, p)
	local rankId = 0

	for _, rank in pairs(HDAdminMain.settings.Ranks) do
		local v4 = rank[1]

		if p == rank[2] then
			rankId = v4
		end
	end

	return rankId
end

function SharedCoreFunctions.CheckRankExists(_, p): boolean
	for _, rank in pairs(HDAdminMain.settings.Ranks) do
		if string.lower(rank[2]) == p then
			return true
		end
	end

	return false
end

function SharedCoreFunctions.GetUserId(_, p)
	tick()
	local userId = HDAdminMain.UserIdsFromName[p]

	if not userId or userId <= 1 then
		userId = 1
		local _, _ = pcall(function()
			userId = HDAdminMain.players:GetUserIdFromNameAsync(p)
		end)
		HDAdminMain.UserIdsFromName[p] = userId
	end

	return userId
end

function SharedCoreFunctions.GetName(_, p)
	local v4 = tostring(p)
	local v5 = tonumber(p)
	local name = HDAdminMain.UsernamesFromUserId[v4]

	if name then
		return name
	end

	name = ""

	if v5 then
		local success, _ = pcall(function()
			name = HDAdminMain.players:GetNameFromUserIdAsync(v5)
		end)

		if success then
			HDAdminMain.UsernamesFromUserId[v4] = name
		end
	end

	return name
end

function SharedCoreFunctions.FindValue(_, items, p): boolean
	for _, item in pairs(items) do
		if tostring(item) == tostring(p) then
			return true
		end
	end

	return false
end

return SharedCoreFunctions