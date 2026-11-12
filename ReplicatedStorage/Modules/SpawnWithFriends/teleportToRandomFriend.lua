local SpawnWithFriends = script:FindFirstAncestor("SpawnWithFriends")

local Players = game:GetService("Players")

local TeleportToPlayer = require(SpawnWithFriends.Packages.TeleportToPlayer)
local SpawnWithFriendsConfiguration = require(SpawnWithFriends.SpawnWithFriendsConfiguration)

local function log(...)
	if SpawnWithFriendsConfiguration.getValues().showLogs then
		print(...)
	end
end

local function teleportToRandomFriend(p): boolean
	local values = SpawnWithFriendsConfiguration.getValues()
	log(string.format("Teleporting %s to a random friend...", p.Name))

	local random = Random.new()
	local v = {}

	for _, child in ipairs(Players:GetChildren()) do
		if child == p then
			continue
		end

		local v2 = false

		if values.bypassFriendshipCheck then
			v2 = true
		else
			local success, result = pcall(function()
				v2 = child:IsFriendsWith(p.UserId)
			end)

			if not success then
				log("Failed to check friendship status", result)
			end
		end

		if not v2 then
			continue
		end

		local humanoidRootPart = child.Character and child.Character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and humanoidRootPart.Velocity.magnitude < values.maxCharacterVelocity then
			table.insert(v, random:NextInteger(1, #v + 1), child)
		end
	end

	if #v == 0 then
		log(string.format("Couldn't teleport %s to a friend: no friend is present in the server", p.Name))
		return false
	end

	for _, v2 in ipairs(v) do
		if TeleportToPlayer.teleport(p, v2, values.teleportDistance) then
			log(string.format("Successfully teleported %s to %s", p.Name, v2.Name))
			return true
		end
	end

	log(string.format("Couldn't teleport %s to a friend: no suitable teleportation point was found", p.Name))
	return false
end

return teleportToRandomFriend