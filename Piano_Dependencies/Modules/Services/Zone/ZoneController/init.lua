local Janitor = require(script.Parent.Janitor)
local Enum2 = require(script.Parent.Enum)
require(script.Parent.Signal)
local Tracker = require(script.Tracker)
local CollectiveWorldModel = require(script.CollectiveWorldModel)
local enums = Enum2.enums
local Players = game:GetService("Players")
local v = {}
local total = 0
local v2 = {}
local v3 = {}
local zoneParts = {}
local v4 = {}
local zoneParts2 = {}
local v5 = {}
local v6 = 0
local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat
local v7 = {}
local localPlayer = RunService:IsClient() and Players.LocalPlayer

local ZoneController = {}
local trackers = { ["player"] = Tracker.new("player"), item = Tracker.new("item") }
ZoneController.trackers = trackers

local function dictLength(activeTriggers) -- 2 equivalent calls inferred from this helper
	local count = 0

	for _, _ in pairs(activeTriggers) do
		count += 1
	end

	return count
end

local function fillOccupants(p, p2, player) -- 4 equivalent calls inferred from this helper
	local charactersByPlayer = p[p2]

	if not charactersByPlayer then
		charactersByPlayer = {}
		p[p2] = charactersByPlayer
	end

	charactersByPlayer[player] = player:IsA("Player") and player.Character or true
end

local v8 = {
	player = function(p)
		return ZoneController._getZonesAndItems("player", v, total, true, p)
	end,
	localPlayer = function(p)
		local v8 = {}
		local character = localPlayer.Character

		if not character then
			return v8
		end

		local touchingZones = ZoneController.getTouchingZones(character, true, p, trackers.player)

		for _, touchingZone in pairs(touchingZones) do
			if touchingZone.activeTriggers.localPlayer then
				fillOccupants(v8, touchingZone, localPlayer) -- inferred equivalent call
			end
		end

		return v8
	end,
	item = function(p)
		return ZoneController._getZonesAndItems("item", v, total, true, p)
	end
}

function ZoneController:_registerZone()
	v3[self] = true
	local registeredJanitor = self.janitor:add(Janitor.new(), "destroy")
	self._registeredJanitor = registeredJanitor
	registeredJanitor:add(self.updated:Connect(function()
		ZoneController._updateZoneDetails()
	end), "Disconnect")
	ZoneController._updateZoneDetails()
end

function ZoneController:_deregisterZone()
	v3[self] = nil
	self._registeredJanitor:destroy()
	self._registeredJanitor = nil
	ZoneController._updateZoneDetails()
end

function ZoneController._registerConnection(object, p)
	local count = dictLength(object.activeTriggers) -- inferred equivalent call
	v6 += 1

	if count == 0 then
		v[object] = true
		ZoneController._updateZoneDetails()
	end

	local v9 = v2[p]
	v2[p] = v9 and v9 + 1 or 1
	object.activeTriggers[p] = true

	if object.touchedConnectionActions[p] then
		object:_formTouchedConnection(p)
	end

	if v8[p] then
		ZoneController._formHeartbeat(p)
	end
end

function ZoneController:updateDetection()
	for k, v9 in pairs({
		enterDetection = "_currentEnterDetection",
		exitDetection = "_currentExitDetection"
	}) do
		local v10 = self[k]
		local combinedTotalVolumes = Tracker.getCombinedTotalVolumes()

		if v10 == enums.Detection.Automatic then
			if combinedTotalVolumes > 729000 then
				v10 = enums.Detection.Centre
			else
				v10 = enums.Detection.WholeBody
			end
		end

		self[v9] = v10
	end
end

function ZoneController._formHeartbeat(p)
	if v7[p] then
		return
	end

	local v9 = 0
	v7[p] = Heartbeat:Connect(function()
		local now = os.clock()

		if v9 <= now then
			local v10 = nil
			local v11 = nil

			for k, _ in pairs(v) do
				if not k.activeTriggers[p] then
					continue
				end

				local accuracy = k.accuracy

				if v10 == nil or accuracy < v10 then
					v10 = accuracy
				end

				ZoneController.updateDetection(k)
				local currentEnterDetection = k._currentEnterDetection

				if v11 == nil or currentEnterDetection < v11 then
					v11 = currentEnterDetection
				end
			end

			local v12 = v8[p](v11)

			local v13 = {}
			local v14 = {}

			for k, v15 in pairs(v12) do
				local v16 = k.settingsGroupName and ZoneController.getGroup(k.settingsGroupName)

				if not (v16 and v16.onlyEnterOnceExitedAll == true) then
					continue
				end

				for k2, _ in pairs(v15) do
					local v17 = v13[k.settingsGroupName]

					if not v17 then
						v17 = {}
						v13[k.settingsGroupName] = v17
					end

					v17[k2] = k
				end

				v14[k] = v15
			end

			for k, v15 in pairs(v14) do
				local v16 = v13[k.settingsGroupName]

				if not v16 then
					continue
				end

				for k2, _ in pairs(v15) do
					local v17 = v16[k2]

					if v17 and v17 ~= k then
						v15[k2] = nil
					end
				end
			end

			local v15 = { {}, {} }

			for k, _ in pairs(v) do
				if not k.activeTriggers[p] then
					continue
				end

				local accuracy = k.accuracy
				local v16 = v12[k] or {}
				local flag = false

				for _, _ in pairs(v16) do
					flag = true
					break
				end

				if flag and v10 < accuracy then
					v10 = accuracy
				end

				local v17 = k:_updateOccupants(p, v16)
				v15[1][k] = v17.exited
				v15[2][k] = v17.entered
			end

			local v16 = { "Exited", "Entered" }

			for k, v17 in pairs(v15) do
				local v18 = p .. v16[k]

				for k2, v19 in pairs(v17) do
					local v20 = k2[v18]

					if not v20 then
						continue
					end

					for _, v21 in pairs(v19) do
						v20:Fire(v21)
					end
				end
			end

			v9 = now + enums.Accuracy.getProperty(v10)
		end
	end)
end

function ZoneController._deregisterConnection(object, p)
	v6 -= 1

	if v2[p] == 1 then
		v2[p] = nil
		local connection = v7[p]

		if connection then
			v7[p] = nil
			connection:Disconnect()
		end
	else
		v2[p] -= 1
	end

	object.activeTriggers[p] = nil

	if dictLength(object.activeTriggers) == 0 then -- inferred equivalent call
		v[object] = nil
		ZoneController._updateZoneDetails()
	end

	if object.touchedConnectionActions[p] then
		object:_disconnectTouchedConnection(p)
	end
end

function ZoneController._updateZoneDetails()
	zoneParts = {}
	v4 = {}
	zoneParts2 = {}
	v5 = {}
	total = 0

	for k, _ in pairs(v3) do
		local v9 = v[k]

		if v9 then
			total += k.volume
		end

		for _, zonePart in pairs(k.zoneParts) do
			if v9 then
				table.insert(zoneParts, zonePart)
				v4[zonePart] = k
			end

			table.insert(zoneParts2, zonePart)
			v5[zonePart] = k
		end
	end
end

function ZoneController._getZonesAndItems(p, items, total2, p2, p3)
	if not total2 then
		for k, _ in pairs(items) do
			total2 += k.volume
		end
	end

	local zonesAndItems = {}
	local v9 = trackers[p]

	if v9.totalVolume < total2 then
		for _, character in pairs(v9.items) do
			local touchingZones = ZoneController.getTouchingZones(character, p2, p3, v9)

			for _, touchingZone in pairs(touchingZones) do
				if not (not p2 or touchingZone.activeTriggers[p]) then
					continue
				end

				local v10

				if p == "player" then
					v10 = Players:GetPlayerFromCharacter(character)
				else
					v10 = character
				end

				if v10 then
					fillOccupants(zonesAndItems, touchingZone, v10) -- inferred equivalent call
				end
			end
		end
	else
		for k, _ in pairs(items) do
			if not (not p2 or k.activeTriggers[p]) then
				continue
			end

			local partBoundsInBox = CollectiveWorldModel:GetPartBoundsInBox(
				k.region.CFrame,
				k.region.Size,
				v9.whitelistParams
			)
			local set = {}

			for _, v10 in pairs(partBoundsInBox) do
				local v11 = v9.partToItem[v10]

				if not set[v11] then
					set[v11] = true
				end
			end

			for character, _ in pairs(set) do
				if p == "player" then
					local playerFromCharacter = Players:GetPlayerFromCharacter(character)

					if k:findPlayer(playerFromCharacter) then
						fillOccupants(zonesAndItems, k, playerFromCharacter) -- inferred equivalent call
					end
				elseif k:findItem(character) then
					fillOccupants(zonesAndItems, k, character) -- inferred equivalent call
				end
			end
		end
	end

	return zonesAndItems
end

function ZoneController.getZones()
	local zones = {}

	for k, _ in pairs(v3) do
		table.insert(zones, k)
	end

	return zones
end

function ZoneController.getTouchingZones(part, p, p2, p3)
	local v9

	if p3 then
		v9 = p3.exitDetections[part]
		p3.exitDetections[part] = nil
	end

	local v10 = v9 or p2

	local v11 = nil
	local v12 = nil
	local isA = part:IsA("BasePart")
	local v13 = not isA
	local v14 = {}

	if isA then
		v11 = part.Size
		v12 = part.CFrame
		table.insert(v14, part)
	elseif v10 == enums.Detection.WholeBody then
		v11, v12 = Tracker.getCharacterSize(part)
		v14 = part:GetChildren()
	else
		local humanoidRootPart = part:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			v11 = humanoidRootPart.Size
			v12 = humanoidRootPart.CFrame
			table.insert(v14, humanoidRootPart)
		end
	end

	if not (v11 and v12) then
		return {}
	end

	local filterDescendantsInstances = p and zoneParts or zoneParts2
	local v15 = p and v4 or v5
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Whitelist
	overlapParams.MaxParts = #filterDescendantsInstances
	overlapParams.FilterDescendantsInstances = filterDescendantsInstances

	local partBoundsInBox = CollectiveWorldModel:GetPartBoundsInBox(v12, v11, overlapParams)
	local set = {}
	local result = {}

	local filterDescendantsInstances2 = {}

	for _, v16 in pairs(partBoundsInBox) do
		local v17 = v15[v16]

		if v17 and v17.allZonePartsAreBlocks then
			set[v17] = true
			result[v16] = v17
		else
			table.insert(filterDescendantsInstances2, v16)
		end
	end

	local count = #filterDescendantsInstances2
	local count2 = 0

	if count > 0 then
		local overlapParams2 = OverlapParams.new()
		overlapParams2.FilterType = Enum.RaycastFilterType.Whitelist
		overlapParams2.MaxParts = count
		overlapParams2.FilterDescendantsInstances = filterDescendantsInstances2

		for _, part2 in pairs(v14) do
			local flag = false

			if not part2:IsA("BasePart") or v13 and Tracker.bodyPartsToIgnore[part2.Name] then
				continue
			end

			local partsInPart = CollectiveWorldModel:GetPartsInPart(part2, overlapParams2)

			for _, v16 in pairs(partsInPart) do
				if result[v16] then
					continue
				end

				local v17 = v15[v16]

				if v17 then
					set[v17] = true
					result[v16] = v17
					count2 += 1
				end

				if count2 == count then
					flag = true
					break
				end
			end

			if flag then
				break
			end
		end
	end

	local currentExitDetection = nil
	local result2 = {}

	for k, _ in pairs(set) do
		if currentExitDetection == nil or k._currentExitDetection < currentExitDetection then
			currentExitDetection = k._currentExitDetection
		end

		table.insert(result2, k)
	end

	if currentExitDetection and p3 then
		p3.exitDetections[part] = currentExitDetection
	end

	return result2, result
end

local v9 = {}
function ZoneController.setGroup(name, items)
	local result = v9[name]

	if not result then
		result = {}
		v9[name] = result
	end

	result.onlyEnterOnceExitedAll = true

	result._name = name
	result._memberZones = {}

	if typeof(items) == "table" then
		for k, item in pairs(items) do
			result[k] = item
		end
	end

	return result
end

function ZoneController.getGroup(p)
	return v9[p]
end

local v10 = nil
local name = string.format("ZonePlus%sContainer", RunService:IsClient() and "Client" or "Server")
function ZoneController.getWorkspaceContainer()
	local v11 = v10 or workspace:FindFirstChild(name)

	if v11 then
		return v11
	end

	v11 = Instance.new("Folder")
	v11.Name = name
	v11.Parent = workspace
	v10 = v11

	return v11
end

return ZoneController