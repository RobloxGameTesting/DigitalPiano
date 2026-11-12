local SpawnWithFriendsConfiguration = require(script.SpawnWithFriendsConfiguration)
local TeleportToPlayer = require(script.Packages.TeleportToPlayer)
local teleportToRandomFriend = require(script.teleportToRandomFriend)

return {
	configure = SpawnWithFriendsConfiguration.configure,
	teleportToRandomFriend = teleportToRandomFriend,
	setTeleportationValidator = TeleportToPlayer.setTeleportationValidator
}