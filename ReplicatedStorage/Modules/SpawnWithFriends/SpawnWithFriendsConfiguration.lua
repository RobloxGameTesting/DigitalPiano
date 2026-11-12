local SpawnWithFriends = script:FindFirstAncestor("SpawnWithFriends")

local t = require(SpawnWithFriends.Packages.t)
local Configuration = require(script.Parent.Configuration)

local strictInterface = t.strictInterface({
	teleportToFriendOnRespawn = t.optional(t.boolean),
	teleportDistance = t.optional(t.numberPositive),
	showLogs = t.optional(t.boolean),
	maxCharacterVelocity = t.optional(t.numberPositive),
	bypassFriendshipCheck = t.optional(t.boolean)
})
return Configuration.new({
	teleportToFriendOnRespawn = true,
	teleportDistance = 5,
	showLogs = false,
	maxCharacterVelocity = 48,
	bypassFriendshipCheck = false
}, strictInterface)