local HDAdminMain = _G.HDAdminMain
return {
	SetupMainVariables = function(_, p)
		HDAdminMain.hdAdminGroup = { Id = 4676369, Info = {} }

		HDAdminMain.hdAdminGroupInfo = {}

		HDAdminMain.settingsBanRecords = {}
		HDAdminMain.alphabet = {
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
			"z"
		}
		HDAdminMain.UserIdsFromName = {}
		HDAdminMain.UsernamesFromUserId = {}
		HDAdminMain.validSettings = {
			"AppTheme",
			"NoticeSoundId",
			"NoticeVolume",
			"NoticePitch",
			"ErrorSoundId",
			"ErrorVolume",
			"ErrorPitch",
			"Alert2SoundId",
			"AlertVolume",
			"AlertPitch",
			"Prefix"
		}
		HDAdminMain.commandInfoToShowOnClient = {
			"Name",
			"Contributors",
			"Prefixes",
			"Rank",
			"Aliases",
			"UndoAliases",
			"Tags",
			"Description",
			"Args",
			"Loopable",
			"IsBooster",
			"IgnoreDisplay",
			"CanUndo",
			"Groups",
			"DisabledByOwner",
			"Override",
			"EmoteId",
			"SortRandomToTop"
		}
		HDAdminMain.productCooldown = 60
		HDAdminMain.products = { Booster = 1007884962, LaserEyes = 1007746205, Donor = 5745895 }

		HDAdminMain.accessories = { Booster = 91265843061691, Booster2 = 78104307094868 }

		HDAdminMain.materials = {
			"Plastic",
			"Wood",
			"Concrete",
			"CorrodedMetal",
			"DiamondPlate",
			"Foil",
			"Grass",
			"Ice",
			"Marble",
			"Granite",
			"Brick",
			"Pebble",
			"Sand",
			"Fabric",
			"SmoothPlastic",
			"Metal",
			"WoodPlanks",
			"Cobblestone",
			"Neon",
			"Glass"
		}
		HDAdminMain.rankTypes = { Auto = 4, Perm = 3, Server = 2, Temp = 1 }

		if p == "Server" then
			HDAdminMain.pd = {}
			HDAdminMain.sd = {}
			HDAdminMain.permissions = {
				specificUsers = {},
				gamepasses = {},
				assets = {},
				groups = {},
				friends = 0,
				freeAdmin = 0,
				vipServerOwner = 0,
				vipServerPlayer = 0,
				owner = true
			}

			HDAdminMain.commandInfo = {}
			HDAdminMain.commandRanks = {}
			HDAdminMain.infoOnAllCommands = {
				Contributors = {},
				Tags = {},
				Prefixes = {},
				Aliases = {},
				UndoAliases = {},
				ChatCommands = {},
				Override = {}
			}

			HDAdminMain.morphNames = {}
			HDAdminMain.toolNames = {}

			HDAdminMain.commands = {}
			HDAdminMain.playersRanked = {}
			HDAdminMain.playersUnranked = {}
			HDAdminMain.settings.UniversalPrefix = "!"
			HDAdminMain.settings.ChatPrefix = "/"
			HDAdminMain.serverAdmins = {}
			HDAdminMain.owner = {}
			HDAdminMain.ownerId = game.CreatorId
			HDAdminMain.isGroupGame = false

			if game.CreatorType == Enum.CreatorType.Group then
				local success = nil
				local result = nil

				for _ = 1, 10 do
					success, result = pcall(function()
						return HDAdminMain.groupService:GetGroupInfoAsync(game.CreatorId).Owner
					end)

					if success then
						break
					end

					task.wait(1)
				end

				if success then
					HDAdminMain.ownerId = result.Id
					HDAdminMain.ownerName = result.Name
					HDAdminMain.isGroupGame = true
				end
			end

			local success, result = pcall(function()
				return HDAdminMain.marketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
			end)

			local gameInfo = not success and { Name = "GameNameFailedToLoad" } or result

			HDAdminMain.gameInfo = gameInfo
			HDAdminMain.gameName = gameInfo.Name
			HDAdminMain.listOfTools = {}
			HDAdminMain.ranksAllowedToJoin = 0
			HDAdminMain.logs = { command = {} }

			HDAdminMain.isStudio = HDAdminMain.runService:IsStudio()
			HDAdminMain.serverBans = {}
			HDAdminMain.blacklistedVipServerCommands = {}
			HDAdminMain.banned = {}
			HDAdminMain.commandBlocks = {}

			for i = 1, 3 do
				pcall(function()
					HDAdminMain.physicsService:RegisterCollisionGroup("Group" .. i)
				end)
			end

			HDAdminMain.physicsService:CollisionGroupSetCollidable("Group1", "Group2", false)
		elseif p == "Client" then
			HDAdminMain.qualifiers = {
				"me",
				"all",
				"others",
				"random",
				"admins",
				"nonAdmins",
				"friends",
				"nonFriends",
				"NBC",
				"BC",
				"TBC",
				"OBC",
				"R6",
				"R15",
				"rthro",
				"nonRthro"
			}
			HDAdminMain.colors = {}
			HDAdminMain.topbarEnabled = true
			HDAdminMain.blur = Instance.new("BlurEffect", HDAdminMain.camera)
			HDAdminMain.blur.Size = 0

			HDAdminMain.commandMenus = {}
			HDAdminMain.commandsToDisableCompletely = { laserEyes = true, dance = true }

			HDAdminMain.commandsActive = {}
			HDAdminMain.commandsAllowedToUse = {}
			HDAdminMain.commandsWithMenus = {
				Type1 = {
					laserEyes = { "Info", "Press and hold to activate." },
					fly = { "Input", "Speed" },
					fly2 = { "Input", "Speed" },
					noclip = { "Input", "Speed" },
					noclip2 = { "Input", "Speed" }
				},
				Type2 = { cmdbar2 = {} },
				Type3 = { chatHijacker = {} },
				Type17 = {
					dance = { "Input", "Speed" }
				}
			}

			HDAdminMain.commandSpeeds = {
				fly = 50,
				fly2 = 50,
				noclip = 100,
				noclip2 = 25,
				dance = 1
			}

			for k, commandSpeed in pairs(HDAdminMain.commandSpeeds) do
				local commandLimit = HDAdminMain.settings.CommandLimits[k]

				if not commandLimit then
					continue
				end

				local limit = commandLimit.Limit

				if limit < commandSpeed then
					HDAdminMain.commandSpeeds[k] = limit
				end
			end

			HDAdminMain.infoFramesViewed = { Speed = true }
		end

		table.sort(HDAdminMain.settings.Ranks, function(a, b): boolean
			return a[1] < b[1]
		end)
	end
}