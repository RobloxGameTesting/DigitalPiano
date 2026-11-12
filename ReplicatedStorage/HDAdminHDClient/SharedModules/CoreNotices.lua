local HDAdminMain = _G.HDAdminMain
return {
	GetNotice = function(_, p)
		return ({
			WelcomeRank = {
				HDAdminMain.hdAdminCoreName,
				"Your rank is '%s'! Click to view the commands.",
				{ "ShowSpecificPage", "Commands", "Commands" }
			},
			WelcomeBooster = {
				HDAdminMain.hdAdminCoreName,
				"Your're a Booster! Click to view Booster Commands.",
				{ "OpenCommands", "Booster" }
			},
			SetRank = { HDAdminMain.hdAdminCoreName, "You've been %sed to '%s'!" },
			UnlockRank = { HDAdminMain.hdAdminCoreName, "You've unlocked the rank '%s'!" },
			UnRank = { HDAdminMain.hdAdminCoreName, "You've been unranked!" },
			UnRankFrom = { HDAdminMain.hdAdminCoreName, "You've been permUnranked from '%s'!" },
			DisabledByOwner = { HDAdminMain.hdAdminCoreName, "This command has been disabled by the game owner." },
			ParserInvalidCommandRank = {
				HDAdminMain.hdAdminCoreName,
				"'%s' is not a valid command! Try '%srank plr %s' instead."
			},
			ParserInvalidCommandNormal = { HDAdminMain.hdAdminCoreName, "'%s' is not a valid command!", "" },
			ParserInvalidPrefix = { HDAdminMain.hdAdminCoreName, "Invalid prefix! Try '%s%s' instead." },
			ParserInvalidVipServer = { HDAdminMain.hdAdminCoreName, "You cannot use '%s' in VIP Servers." },
			ParserInvalidBooster = { HDAdminMain.hdAdminCoreName, "You must be a Booster to use that command!" },
			ParserInvalidLoop = { HDAdminMain.hdAdminCoreName, "You do not have permission to use Loop commands!" },
			ParserInvalidRank = { HDAdminMain.hdAdminCoreName, "You do not have permission to use '%s'" },
			ParserBuyRank = { HDAdminMain.hdAdminCoreName, "Buy '%s' to unlock this command permanently" },
			ParserCommandBlock = { HDAdminMain.hdAdminCoreName, "Commands are temporarily disabled.'" },
			ParserInvalidRigType = { HDAdminMain.hdAdminCoreName, "%s must be %s to use that command." },
			ParserPlayerRankBlocked = {
				HDAdminMain.hdAdminCoreName,
				"You do not have the permissions to use '%s' on %s!"
			},
			ParserSpeakerRank = { HDAdminMain.hdAdminCoreName, "You %sed %s to '%s'" },
			ParserSpeakerUnrank = { HDAdminMain.hdAdminCoreName, "You unranked %s" },
			ParserPlrPunished = { HDAdminMain.hdAdminCoreName, "%s must be unpunished to use that command." },
			ReceivedPM = { HDAdminMain.hdAdminCoreName, "You have a message from %s! Click to open." },
			RemovePermRank = { HDAdminMain.hdAdminCoreName, "Successfully unranked %s!" },
			BroadcastSuccessful = {
				HDAdminMain.hdAdminCoreName,
				"Broadcast successful! Your announcement will appear shortly."
			},
			BroadcastFailed = { HDAdminMain.hdAdminCoreName, "Broadcast failed to send." },
			InformPrefix = { HDAdminMain.hdAdminCoreName, "The server prefix is '%s'" },
			GetSoundSuccess = { HDAdminMain.hdAdminCoreName, "The ID of the sound playing is: %s" },
			GetSoundFail = { HDAdminMain.hdAdminCoreName, "No sound is playing!" },
			UnderControl = { HDAdminMain.hdAdminCoreName, "You're being controlled by %s!" },
			ClickToTeleport = { "Teleport", "Click to teleport to '%s' [%s]" },
			BanSuccess = {
				HDAdminMain.hdAdminCoreName,
				"Successfully banned %s! Click to view the Banland.",
				{ "ShowSpecificPage", "Moderation", "Banland" }
			},
			UnBanSuccess = { HDAdminMain.hdAdminCoreName, "Successfully unbanned %s!" },
			QualifierLimitToSelf = { HDAdminMain.hdAdminCoreName, "'%ss' can only use commands on theirself!" },
			QualifierLimitToOnePerson = {
				HDAdminMain.hdAdminCoreName,
				"'%ss' can only use commands on one person at a time!"
			},
			ScaleLimit = { HDAdminMain.hdAdminCoreName, "The ScaleLimit is %s for ranks below '%s'" },
			RequestsLimit = { HDAdminMain.hdAdminCoreName, "You're sending requests too fast!" },
			AlertFail = { HDAdminMain.hdAdminCoreName, "Alert failed to send." },
			PollFail = { HDAdminMain.hdAdminCoreName, "Poll failed to send." },
			GearBlacklist = { HDAdminMain.hdAdminCoreName, "Cannot insert gear: %s. This item has been blacklisted." },
			BanFailLength = { HDAdminMain.hdAdminCoreName, "%sBan Length must be greater than 0!" },
			BanFailVIPServer = { HDAdminMain.hdAdminCoreName, "%s'permBan' is prohibited on VIP Servers!" },
			BanFailAllServers = {
				HDAdminMain.hdAdminCoreName,
				"You do not have permission to ban players from 'all servers'."
			},
			BanFailAlreadyBanned = { HDAdminMain.hdAdminCoreName, "%splayer has already been banned!" },
			BanFailRobloxRejected = { HDAdminMain.hdAdminCoreName, "%s%s" },
			BanFailPermission = { HDAdminMain.hdAdminCoreName, "You do not have permission to ban %s" },
			BanFailDataNotFound = { HDAdminMain.hdAdminCoreName, "%sData not found." },
			RestoreDefaultSettings = { "Settings", "Successfully restored all settings to default!" },
			CommandBarLocked = {
				HDAdminMain.hdAdminCoreName,
				"You do not have permission to use the commandBar%s! Rank required: '%s'"
			},
			FollowFail = { HDAdminMain.hdAdminCoreName, "Failed to teleport. %s is not in-game." },
			SaveMap1 = { HDAdminMain.hdAdminCoreName, "Saving a copy of the map..." },
			SaveMap2 = { HDAdminMain.hdAdminCoreName, "Map successfully saved!" },
			CommandLimit = { HDAdminMain.hdAdminCoreName, "The %s limit is %s for ranks below '%s'" },
			CommandLimitPerMinute = {
				HDAdminMain.hdAdminCoreName,
				"Sending commands too fast! CommandLimitPerMinute exceeded."
			},
			TextLimitMessage = {
				HDAdminMain.hdAdminCoreName,
				"You can only send your next message in %s due to Roblox's age safety policies."
			},
			TextLimitSurfaceText = {
				HDAdminMain.hdAdminCoreName,
				"You can only change this again in %s due to Roblox's age safety policies."
			},
			TextLimitChatText = {
				HDAdminMain.hdAdminCoreName,
				"You can only change this again in %s due to Roblox's age safety policies."
			},
			TextLimitReason = {
				HDAdminMain.hdAdminCoreName,
				"You can only add your next reason in %s due to Roblox's age safety policies."
			},
			SenderCannotChat = {
				HDAdminMain.hdAdminCoreName,
				"Roblox doesn't allow you to send text to other players in this experience."
			},
			PairRefused = { HDAdminMain.hdAdminCoreName, "Roblox doesn't allow you to message %s." },
			ChatLogsRemoved = {
				HDAdminMain.hdAdminCoreName,
				"Chat logs are no longer available. Roblox gives moderators read-only chat instead."
			},
			template = { HDAdminMain.hdAdminCoreName, "" }
		})[p]
	end
}