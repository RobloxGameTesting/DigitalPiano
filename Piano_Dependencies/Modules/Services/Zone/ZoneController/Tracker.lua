local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Heartbeat = RunService.Heartbeat
local Signal = require(script.Parent.Parent.Signal)
local Janitor = require(script.Parent.Parent.Janitor)

local Tracker = {}
Tracker.__index = Tracker
local classSet = {}
Tracker.trackers = classSet
Tracker.itemAdded = Signal.new()
Tracker.itemRemoved = Signal.new()
Tracker.bodyPartsToIgnore = {
	UpperTorso = true,
	LowerTorso = true,
	Torso = true,
	LeftHand = true,
	RightHand = true,
	LeftFoot = true,
	RightFoot = true
}

function Tracker.getCombinedTotalVolumes()
	local combinedTotalVolumes = 0

	for k, _ in pairs(classSet) do
		combinedTotalVolumes += k.totalVolume
	end

	return combinedTotalVolumes
end

function Tracker.getCharacterSize(instance)
	local part = instance and instance:FindFirstChild("Head")
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and part) then
		return nil
	end

	if not part:IsA("BasePart") then
		part = humanoidRootPart
	end

	local y = part.Size.Y
	local size = humanoidRootPart.Size
	return
		size * Vector3.new(2, 2, 1) + Vector3.new(0, y, 0),
		humanoidRootPart.CFrame * CFrame.new(0, y / 2 - size.Y / 2, 0)
end

function Tracker.new(name)
	local class = {}
	setmetatable(class, Tracker)

	class.name = name
	class.totalVolume = 0
	class.parts = {}
	class.partToItem = {}
	class.items = {}
	class.whitelistParams = nil
	class.characters = {}
	class.baseParts = {}
	class.exitDetections = {}
	class.janitor = Janitor.new()

	if name == "player" then
		local function updatePlayerCharacters()
			local characterSet = {}

			for _, v in pairs(Players:GetPlayers()) do
				local character = v.Character

				if character then
					characterSet[character] = true
				end
			end

			class.characters = characterSet
		end

		local function playerAdded(player)
			local function charAdded(character)
				local humanoid = character:WaitForChild("Humanoid", 3)

				if humanoid then
					updatePlayerCharacters()
					class:update()

					for _, numberValue in pairs(humanoid:GetChildren()) do
						if numberValue:IsA("NumberValue") then
							numberValue.Changed:Connect(function()
								class:update()
							end)
						end
					end
				end
			end

			if player.Character then
				charAdded(player.Character)
			end

			player.CharacterAdded:Connect(charAdded)
			player.CharacterRemoving:Connect(function(character)
				class.exitDetections[character] = nil
			end)
		end

		Players.PlayerAdded:Connect(playerAdded)

		for _, v in pairs(Players:GetPlayers()) do
			playerAdded(v)
		end

		Players.PlayerRemoving:Connect(function(_)
			updatePlayerCharacters()
			class:update()
		end)
	elseif name == "item" then
		local function updateItem(data, p) -- 2 equivalent calls inferred from this helper
			if data.isCharacter then
				class.characters[data.item] = p
			elseif data.isBasePart then
				class.baseParts[data.item] = p
			end

			class:update()
		end
		Tracker.itemAdded:Connect(function(data)
			updateItem(data, true) -- inferred equivalent call
		end)
		Tracker.itemRemoved:Connect(function(data)
			class.exitDetections[data.item] = nil
			updateItem(data) -- inferred equivalent call
		end)
	end

	classSet[class] = true
	task.defer(class.update, class)
	return class
end

function Tracker:_preventMultiFrameUpdates(p, ...): boolean
	self._preventMultiDetails = self._preventMultiDetails or {}
	local v = self._preventMultiDetails[p]

	if not v then
		v = { calling = false, callsThisFrame = 0, updatedThisFrame = false }

		self._preventMultiDetails[p] = v
	end

	v.callsThisFrame += 1

	if v.callsThisFrame ~= 1 then
		return true
	end

	local v2 = table.pack(...)
	task.defer(function()
		local callsThisFrame = v.callsThisFrame
		v.callsThisFrame = 0

		if callsThisFrame > 1 then
			self[p](self, unpack(v2))
		end
	end)
	return false
end

function Tracker:update()
	if self:_preventMultiFrameUpdates("update") then
		return
	end

	self.totalVolume = 0
	self.parts = {}
	self.partToItem = {}
	self.items = {}

	for k, _ in pairs(self.characters) do
		local characterSize = Tracker.getCharacterSize(k)

		if not characterSize then
			continue
		end

		local v = characterSize.X * characterSize.Y * characterSize.Z
		self.totalVolume += v

		local v2 = self.janitor:add(Janitor.new(), "destroy", "trackCharacterParts-" .. self.name)
		local function updateTrackerOnParentChanged(instance)
			v2:add(instance.AncestryChanged:Connect(function()
				if not instance:IsDescendantOf(game) and instance.Parent == nil and v2 ~= nil then
					v2:destroy()
					v2 = nil
					self:update()
				end
			end), "Disconnect")
		end

		for _, part in pairs(k:GetChildren()) do
			if not part:IsA("BasePart") or Tracker.bodyPartsToIgnore[part.Name] then
				continue
			end

			self.partToItem[part] = k
			table.insert(self.parts, part)
			local v3 = part
			local ancestryChangedConnection = part.AncestryChanged:Connect(function()
				if not v3:IsDescendantOf(game) and v3.Parent == nil and v2 ~= nil then
					v2:destroy()
					v2 = nil
					self:update()
				end
			end)
			v2:add(ancestryChangedConnection, "Disconnect")
		end

		local ancestryChangedConnection = k.AncestryChanged:Connect(function()
			if not k:IsDescendantOf(game) and k.Parent == nil and v2 ~= nil then
				v2:destroy()
				v2 = nil
				self:update()
			end
		end)
		v2:add(ancestryChangedConnection, "Disconnect")

		table.insert(self.items, k)
	end

	for k, _ in pairs(self.baseParts) do
		local size = k.Size
		local v = size.X * size.Y * size.Z
		self.totalVolume += v
		self.partToItem[k] = k
		table.insert(self.parts, k)
		table.insert(self.items, k)
	end

	self.whitelistParams = OverlapParams.new()
	self.whitelistParams.FilterType = Enum.RaycastFilterType.Whitelist
	self.whitelistParams.MaxParts = #self.parts
	self.whitelistParams.FilterDescendantsInstances = self.parts
end

return Tracker