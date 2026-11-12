local MonetizationConfig = require(script.Parent:WaitForChild("MonetizationConfig"))
local ItemTrackingConfig = require(script.Parent:WaitForChild("ItemTrackingConfig"))

local PianoShopCatalog = {}

PianoShopCatalog.Categories = {
	Titles = true,
	Tags = true,
	Themes = true,
	Benches = true,
	Effects = true,
	Storage = true,
	Notes = true,
	Gamepasses = true
}

local v = {}

local function addCustomTitle(p, pianoItemId, title, description, price, color)
	table.insert(v, {
		assetId = 920000000 + p,
		pianoItemId = pianoItemId,
		category = "Titles",
		title = title,
		description = description,
		displayType = "Tag",
		price = price,
		color = color,
		purchaseKind = "ProfileStore"
	})
end

table.insert(v, {
	assetId = 920000001,
	pianoItemId = "TagPianist",
	category = "Titles",
	title = "Pianist",
	description = "A clean starter title for regular players.",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(45, 118, 235),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000002,
	pianoItemId = "TagComposer",
	category = "Titles",
	title = "Composer",
	description = "A title for players who write and share songs.",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(90, 150, 245),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000003,
	pianoItemId = "TagMaestro",
	category = "Titles",
	title = "Maestro",
	description = "A polished title for advanced performers.",
	displayType = "Tag",
	price = 500,
	color = Color3.fromRGB(255, 190, 50),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000004,
	pianoItemId = "TagVirtuoso",
	category = "Titles",
	title = "Virtuoso",
	description = "A premium title for elite pianists.",
	displayType = "Tag",
	price = 800,
	color = Color3.fromRGB(190, 120, 255),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000005,
	pianoItemId = "TagAnimeFan",
	category = "Titles",
	title = "Anime Fan",
	description = "Plays piano like the anime opening is about to start.",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(255, 118, 182),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000006,
	pianoItemId = "TagSensei",
	category = "Titles",
	title = "Sensei",
	description = "Teaches others while missing half the notes.",
	displayType = "Tag",
	price = 250,
	color = Color3.fromRGB(245, 158, 11),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000007,
	pianoItemId = "TagSenpai",
	category = "Titles",
	title = "Senpai",
	description = "Waiting to be noticed since 2016.",
	displayType = "Tag",
	price = 250,
	color = Color3.fromRGB(244, 114, 182),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000008,
	pianoItemId = "TagKawaii",
	category = "Titles",
	title = "Kawaii",
	description = "Japanese Version of Cute",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(255, 139, 203),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000009,
	pianoItemId = "TagOtaku",
	category = "Titles",
	title = "Otaku",
	description = "Has 500 anime songs ready but only plays one.",
	displayType = "Tag",
	price = 250,
	color = Color3.fromRGB(139, 92, 246),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000010,
	pianoItemId = "TagShonenStar",
	category = "Titles",
	title = "Shonen Star",
	description = "Friendship power increases piano accuracy by 0.1%.",
	displayType = "Tag",
	price = 400,
	color = Color3.fromRGB(249, 115, 22),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000011,
	pianoItemId = "TagFinalBoss",
	category = "Titles",
	title = "Final Boss",
	description = "The server music stops when this player joins.",
	displayType = "Tag",
	price = 750,
	color = Color3.fromRGB(239, 68, 68),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000012,
	pianoItemId = "TagKeyboardWarrior",
	category = "Titles",
	title = "Keyboard Warrior",
	description = "Fighting invisible enemies one key at a time.",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(34, 211, 238),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000013,
	pianoItemId = "TagSkillIssue",
	category = "Titles",
	title = "Skill Issue",
	description = "Not lag. Not the piano. Just pure skill issue.",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(132, 204, 22),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000014,
	pianoItemId = "TagTouchGrass",
	category = "Titles",
	title = "Touch Grass",
	description = "Bought this title but still has not gone outside.",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(34, 197, 94),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000015,
	pianoItemId = "TagTheChosenOne",
	category = "Titles",
	title = "The Chosen One",
	description = "Chosen by destiny...",
	displayType = "Tag",
	price = 750,
	color = Color3.fromRGB(250, 204, 21),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000016,
	pianoItemId = "TagAutoPlayerEnjoyer",
	category = "Titles",
	title = "Auto Player Enjoyer",
	description = "Hands free, ego full.",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(59, 130, 246),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000017,
	pianoItemId = "TagMomSaidOneMoreSong",
	category = "Titles",
	title = "Mom Said One More Song",
	description = "The one more song lasted 3 hours.",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(168, 85, 247),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000018,
	pianoItemId = "TagOneFpsPianist",
	category = "Titles",
	title = "1 FPS Pianist",
	description = "Every note is delayed but the confidence is real.",
	displayType = "Tag",
	price = 250,
	color = Color3.fromRGB(148, 163, 184),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000019,
	pianoItemId = "TagLetHimCook",
	category = "Titles",
	title = "Let Him Cook",
	description = "Nobody knows what he is cooking, but it sounds loud.",
	displayType = "Tag",
	price = 400,
	color = Color3.fromRGB(251, 146, 60),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000020,
	pianoItemId = "TagOvercooked",
	category = "Titles",
	title = "Overcooked",
	description = "He cooked too hard",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(248, 113, 113),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000021,
	pianoItemId = "TagMinus999Aura",
	category = "Titles",
	title = "-999 Aura",
	description = "Entered the server and did not pass the vibe check",
	displayType = "Tag",
	price = 500,
	color = Color3.fromRGB(126, 34, 206),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000022,
	pianoItemId = "TagPlus999Aura",
	category = "Titles",
	title = "+999 Aura",
	description = "Stands still and somehow looks legendary.",
	displayType = "Tag",
	price = 500,
	color = Color3.fromRGB(234, 179, 8),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000023,
	pianoItemId = "TagSkibidi",
	category = "Titles",
	title = "Skibidi",
	description = "Brainrot levels are dangerously high.",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(20, 184, 166),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000024,
	pianoItemId = "TagAlpha",
	category = "Titles",
	title = "Alpha",
	description = "Says I lead but follows the autoplayer.",
	displayType = "Tag",
	price = 500,
	color = Color3.fromRGB(220, 38, 38),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000025,
	pianoItemId = "TagBeta",
	category = "Titles",
	title = "Beta",
	description = "Still updating. Please wait for the full release.",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(96, 165, 250),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000026,
	pianoItemId = "TagTryhard",
	category = "Titles",
	title = "Tryhard",
	description = "Sweating on a piano game like it is ranked.",
	displayType = "Tag",
	price = 400,
	color = Color3.fromRGB(99, 102, 241),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000027,
	pianoItemId = "TagL",
	category = "Titles",
	title = "L",
	description = "For when winning is not part of the plan.",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(239, 68, 68),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000028,
	pianoItemId = "TagW",
	category = "Titles",
	title = "W",
	description = "Simple title. Massive flex.",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(16, 185, 129),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000029,
	pianoItemId = "TagNightcore",
	category = "Titles",
	title = "Nightcore",
	description = "Every song must be faster for no reason.",
	displayType = "Tag",
	price = 250,
	color = Color3.fromRGB(217, 70, 239),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000030,
	pianoItemId = "TagDreamer",
	category = "Titles",
	title = "Dreamer",
	description = "Plays like they are in a sad edit at 3 AM.",
	displayType = "Tag",
	price = 200,
	color = Color3.fromRGB(56, 189, 248),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000031,
	pianoItemId = "TagRichKid",
	category = "Titles",
	title = "Rich Kid",
	description = "Bought the title before reading the description.",
	displayType = "Tag",
	price = 500,
	color = Color3.fromRGB(245, 158, 11),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000032,
	pianoItemId = "TagSigma",
	category = "Titles",
	title = "Sigma",
	description = "Plays alone, refuses help, misses notes silently.",
	displayType = "Tag",
	price = 750,
	color = Color3.fromRGB(124, 58, 237),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000033,
	pianoItemId = "TagGoat",
	category = "Titles",
	title = "G.O.A.T",
	description = "The greatest of all time, according to themselves.",
	displayType = "Tag",
	price = 1000,
	color = Color3.fromRGB(255, 215, 0),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000034,
	pianoItemId = "TagWomenCoffee",
	category = "Titles",
	title = "Women ☕",
	description = "Women ☕",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(236, 72, 153),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000035,
	pianoItemId = "TagMenCoffee",
	category = "Titles",
	title = "Men ☕",
	description = "Men ☕",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(180, 83, 9),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000036,
	pianoItemId = "TagRizz",
	category = "Titles",
	title = "Rizz",
	description = "No skill, just pure rizz.",
	displayType = "Tag",
	price = 400,
	color = Color3.fromRGB(236, 72, 153),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000037,
	pianoItemId = "TagShy",
	category = "Titles",
	title = "Shy",
	description = "Too shy to perform, but still wants everyone to notice.",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(196, 181, 253),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000038,
	pianoItemId = "TagBuiltDiff",
	category = "Titles",
	title = "Built Diff",
	description = "Not better, not worse, just built very strangely.",
	displayType = "Tag",
	price = 600,
	color = Color3.fromRGB(22, 163, 74),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000039,
	pianoItemId = "TagBaiNaBai",
	category = "Titles",
	title = "Bai na Bai",
	description = "Bai na Bai",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(6, 182, 212),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000040,
	pianoItemId = "TagCute",
	category = "Titles",
	title = "Cute",
	description = "Small title, maximum cuteness.",
	displayType = "Tag",
	price = 200,
	color = Color3.fromRGB(244, 114, 182),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000041,
	pianoItemId = "TagBeautiful",
	category = "Titles",
	title = "Beautiful",
	description = "Plays one note and suddenly thinks they are in a music video.",
	displayType = "Tag",
	price = 300,
	color = Color3.fromRGB(251, 113, 133),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000042,
	pianoItemId = "TagGorgeous",
	category = "Titles",
	title = "Gorgeous",
	description = "For players who want their title to sparkle harder than their skills.",
	displayType = "Tag",
	price = 500,
	color = Color3.fromRGB(217, 70, 239),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000043,
	pianoItemId = "TagLimitBreaker",
	category = "Titles",
	title = "Limit Breaker",
	description = "Bro broke the limit... and maybe the keyboard too.",
	displayType = "Tag",
	price = 800,
	color = Color3.fromRGB(249, 115, 22),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000044,
	pianoItemId = "TagPlsRobux",
	category = "Titles",
	title = "Pls Robux",
	description = "A peaceful way to beg without actually begging.",
	displayType = "Tag",
	price = 250,
	color = Color3.fromRGB(34, 197, 94),
	purchaseKind = "ProfileStore"
})
table.insert(v, {
	assetId = 920000045,
	pianoItemId = "TagThumbsUp",
	category = "Titles",
	title = "👍",
	description = "👍",
	displayType = "Tag",
	price = 150,
	color = Color3.fromRGB(59, 130, 246),
	purchaseKind = "ProfileStore"
})

table.insert(v, {
	assetId = 920000101,
	pianoItemId = "BenchRoyal",
	category = "Benches",
	title = "Royal Bench",
	description = "Play like a true king",
	displayType = "Bench",
	price = 400,
	color = Color3.fromRGB(160, 105, 70),
	purchaseKind = "ProfileStore"
})

table.insert(v, {
	assetId = 920000103,
	pianoItemId = "BenchWoodenStool",
	category = "Benches",
	title = "Wooden Stool",
	description = "A compact wooden stool for a casual piano setup.",
	displayType = "Bench",
	price = 300,
	color = Color3.fromRGB(150, 95, 55),
	purchaseKind = "ProfileStore"
})

table.insert(v, {
	assetId = 920000104,
	pianoItemId = "BenchPlasticChair",
	category = "Benches",
	title = "Plastic Chair",
	description = "A simple plastic chair cosmetic for piano seating.",
	displayType = "Bench",
	price = 250,
	color = Color3.fromRGB(210, 220, 235),
	purchaseKind = "ProfileStore"
})

local function addCustomBench(p, pianoItemId, title, description, price, color, items)
	local v2 = {
		assetId = 920000000 + p,
		pianoItemId = pianoItemId,
		category = "Benches",
		title = title,
		description = description,
		displayType = "Bench",
		price = price,
		color = color,
		purchaseKind = "ProfileStore"
	}

	if type(items) == "table" then
		for k, item in pairs(items) do
			v2[k] = item
		end
	end

	table.insert(v, v2)
end

addCustomBench(
	105,
	"BenchBeachChairNoUmbrellaGreen",
	"Green Beach Chair",
	"A laid-back beach chair for relaxed performances.",
	350,
	Color3.fromRGB(90, 185, 65)
)
addCustomBench(
	106,
	"BenchBeachChairUmbrellaBlue",
	"Blue Umbrella Beach Chair",
	"A fresh beach chair with its own shade.",
	650,
	Color3.fromRGB(35, 170, 215)
)
addCustomBench(
	107,
	"BenchBeachChairUmbrellaRed",
	"Red Umbrella Beach Chair",
	"A fresh beach chair with its own shade.",
	650,
	Color3.fromRGB(235, 45, 38)
)
addCustomBench(
	108,
	"BenchBeachChairUmbrellaGreen",
	"Green Umbrella Beach Chair",
	"A fresh beach chair with its own shade.",
	650,
	Color3.fromRGB(90, 185, 65)
)
addCustomBench(
	109,
	"BenchCampingChair",
	"Camping Chair",
	"A portable seat for campfire-style piano sessions.",
	500,
	Color3.fromRGB(65, 115, 75)
)
addCustomBench(110, "BenchCatBench", "Cat Bench", "Meow :3", 300, Color3.fromRGB(245, 190, 120))
addCustomBench(
	111,
	"BenchVIPBench",
	"VIP Bench",
	"A premium-looking bench with a fancy VIP feel.",
	1200,
	Color3.fromRGB(170, 65, 225)
)
addCustomBench(
	112,
	"BenchCursedThrone",
	"Cursed Throne",
	"An exclusive throne forged from cursed skulls. It protects its owner from being pushed by other players.",
	999999999,
	Color3.fromRGB(95, 20, 35),
	{
		trackExisting = true,
		serialed = true,
		developerExclusive = true,
		developerLabel = "Developer Item",
		developerAccentColor = Color3.fromRGB(88, 195, 173),
		offSale = true,
		pushImmune = true
	}
)

table.insert(v, {
	assetId = 920000201,
	pianoItemId = "EffectFireEyes",
	category = "Effects",
	title = "Fire Eyes",
	description = "Need some eyedrops for those?",
	displayType = "Effect",
	price = 1500,
	color = Color3.fromRGB(255, 94, 0),
	purchaseKind = "ProfileStore"
})

table.insert(v, {
	assetId = 920000202,
	pianoItemId = "EffectPianoOnFire",
	category = "Effects",
	title = "Piano On Fire",
	description = "Sets supported pianos ablaze while you play. Works on default Synthesia pianos only.",
	displayType = "Piano Effect",
	price = 3000,
	color = Color3.fromRGB(255, 94, 0),
	purchaseKind = "ProfileStore"
})

function PianoShopCatalog.IsCategory(value): boolean
	return type(value) == "string" and PianoShopCatalog.Categories[value] == true
end

function PianoShopCatalog.GetItems()
	local items = {}
	local count = 0

	local function add(items2)
		count += 1
		local v2 = {}

		for k, item in pairs(items2) do
			v2[k] = item
		end

		v2.layoutOrder = count
		v2.iconId = v2.iconId or 13846572781
		ItemTrackingConfig.ApplyToCatalogItem(v2)
		table.insert(items, v2)
	end

	for _, v2 in ipairs(MonetizationConfig.Gamepasses or {}) do
		local gamePassId = tonumber(v2.gamePassId) or 0

		if gamePassId > 0 then
			add({
				assetId = gamePassId,
				pianoItemId = "Gamepass:" .. tostring(gamePassId),
				category = "Gamepasses",
				title = v2.name,
				description = v2.desc or "Permanent game pass upgrade.",
				displayType = "Game Pass",
				price = 0,
				icon = v2.icon,
				iconId = gamePassId,
				productTypeName = "GamePass",
				purchaseKind = "Gamepass",
				giftProductId = tonumber(v2.giftProductId) or 0
			})
		end
	end

	for _, v2 in ipairs(v) do
		add(v2)
	end

	for _, v2 in ipairs(MonetizationConfig.RecordingStorageProducts or {}) do
		local productId = tonumber(v2.productId) or 0

		if productId > 0 then
			add({
				assetId = productId,
				pianoItemId = "RecordingStorage:" .. tostring(v2.id or productId),
				category = "Storage",
				title = v2.name,
				description = v2.desc or "Adds " .. tostring(v2.slots or 0) .. " saved recording slot(s).",
				displayType = "Storage",
				price = 0,
				icon = v2.icon,
				iconId = v2.iconId or productId,
				productTypeName = "Product",
				purchaseKind = "DeveloperProduct"
			})
		end
	end

	local v2 = MonetizationConfig.GetRewardedAdReward and MonetizationConfig.GetRewardedAdReward("Notes")

	if type(v2) == "table" then
		local v3 = math.max(0, (math.floor(tonumber(v2.notes) or 0)))
		add({
			assetId = 920000901,
			pianoItemId = tostring(v2.id or "RewardedAdNotes"),
			category = "Notes",
			title = v2.name or "Watch Ad for Notes",
			description = v2.desc or "Watch a rewarded video ad to earn " .. tostring(v3) .. " Notes.",
			displayType = "Rewarded Ad",
			price = 0,
			priceText = "Watch Ad",
			priceIcon = false,
			icon = v2.icon,
			iconId = v2.iconId or 13846572781,
			productTypeName = "Product",
			purchaseKind = "RewardedAd",
			rewardedAdKey = "Notes",
			rewardedAdProductId = tonumber(v2.productId) or 0,
			hideExperienceOnlyWarning = true,
			color = Color3.fromRGB(42, 185, 132)
		})
	end

	for _, v3 in ipairs(MonetizationConfig.CurrencyProducts or {}) do
		local productId = tonumber(v3.productId) or 0

		if productId > 0 then
			add({
				assetId = productId,
				category = "Notes",
				title = v3.name,
				description = v3.desc or "Adds " .. tostring(v3.notes or 0) .. " Notes to your balance.",
				displayType = "Developer Product",
				price = 0,
				icon = v3.icon,
				iconId = productId,
				productTypeName = "Product",
				purchaseKind = "DeveloperProduct"
			})
		end
	end

	return items
end

return PianoShopCatalog