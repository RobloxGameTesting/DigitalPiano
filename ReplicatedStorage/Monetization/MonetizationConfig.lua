local MonetizationConfig = {}

MonetizationConfig.DeveloperProductIds = {
	NotesStarter = 3608442846,
	NotesSmall = 3598833931,
	NotesMedium = 3598834056,
	NotesLarge = 3598834172,
	NotesMega = 3603461052,
	NotesUltimate = 3603461105,
	NotesGigantic = 3603461205,
	NotesExtreme = 3603461261,
	RecordingStorage = 0,
	RecordingSlot1 = 3598834427,
	RecordingSlot5 = 3598834487,
	RecordingSlot10 = 3598834553,
	DailyRewardSkip = 1806446838,
	DailyRewardSkipCycle2 = 1806446838,
	DailyRewardSkipCycle3 = 1806446838,
	DailyRewardSkipCycle4 = 1806446838,
	FreePushCooldownRemove = 1838908088,
	RewardedAdNotes = 3609895495,
	RainbowVisualizerGift = 3601083404,
	VIPGift = 3601083402,
	GreatPretenderGift = 1751665666,
	GrandPianoLobbyGift = 1751665674,
	PushToolGift = 1911807897,
	InvisibilityGift = 1751665667,
	ThirdEyeGift = 1911807878,
	HeartParticleEffectGift = 1751665668,
	MidiPlayerGift = 3599369149,
	X2NotesPlayedGift = 1911807888,
	X2NotesCurrencyGift = 3601081942
}

MonetizationConfig.GamepassGiftProductIds = {
	RainbowVisualizer = MonetizationConfig.DeveloperProductIds.RainbowVisualizerGift,
	VIP = MonetizationConfig.DeveloperProductIds.VIPGift,
	GreatPretender = MonetizationConfig.DeveloperProductIds.GreatPretenderGift,
	GrandPianoLobby = MonetizationConfig.DeveloperProductIds.GrandPianoLobbyGift,
	PushTool = MonetizationConfig.DeveloperProductIds.PushToolGift,
	Invisibility = MonetizationConfig.DeveloperProductIds.InvisibilityGift,
	ThirdEye = MonetizationConfig.DeveloperProductIds.ThirdEyeGift,
	HeartParticleEffect = MonetizationConfig.DeveloperProductIds.HeartParticleEffectGift,
	MidiPlayer = MonetizationConfig.DeveloperProductIds.MidiPlayerGift,
	X2NotesPlayed = MonetizationConfig.DeveloperProductIds.X2NotesPlayedGift,
	X2NotesCurrency = MonetizationConfig.DeveloperProductIds.X2NotesCurrencyGift
}

MonetizationConfig.GamePassIds = {
	RainbowVisualizer = 1031850464,
	VIP = 73845966,
	GreatPretender = 659202481,
	GrandPianoLobby = 686519318,
	PushTool = 870010644,
	Invisibility = 75633879,
	ThirdEye = 822775627,
	HeartParticleEffect = 695122656,
	MidiPlayer = 1855799886,
	X2NotesPlayed = 822390554,
	X2NotesCurrency = 1862996286
}

local v = {
	DeveloperProductIds = {
		NotesStarter = 3609897062,
		NotesSmall = 3606945233,
		NotesMedium = 3606945427,
		NotesLarge = 3606945484,
		NotesMega = 3606945666,
		NotesUltimate = 3606946015,
		NotesGigantic = 3606946120,
		NotesExtreme = 3606946209,
		RecordingStorage = 0,
		RecordingSlot1 = 3606946546,
		RecordingSlot5 = 3606946600,
		RecordingSlot10 = 3592410687,
		DailyRewardSkip = 3606947040,
		DailyRewardSkipCycle2 = 3606947040,
		DailyRewardSkipCycle3 = 3606947040,
		DailyRewardSkipCycle4 = 3606947040,
		FreePushCooldownRemove = 3606946938,
		RewardedAdNotes = 3609895574,
		RainbowVisualizerGift = 3606943381,
		VIPGift = 3606944048,
		GreatPretenderGift = 3606943116,
		GrandPianoLobbyGift = 3606943669,
		PushToolGift = 3606943511,
		InvisibilityGift = 3606943731,
		ThirdEyeGift = 3606943314,
		HeartParticleEffectGift = 3606943774,
		MidiPlayerGift = 3606943265,
		X2NotesPlayedGift = 3606943437,
		X2NotesCurrencyGift = 3606943579
	},
	GamePassIds = {
		RainbowVisualizer = 1893431845,
		VIP = 1892957926,
		GreatPretender = 1615947612,
		GrandPianoLobby = 1893209974,
		PushTool = 1892801917,
		Invisibility = 1890113906,
		ThirdEye = 1891649983,
		HeartParticleEffect = 1890899955,
		MidiPlayer = 1893821491,
		X2NotesPlayed = 1889867953,
		X2NotesCurrency = 1893617550
	}
}

local function applyIdOverrides(p, items) -- 2 equivalent calls inferred from this helper
	if type(p) ~= "table" or type(items) ~= "table" then
		return
	end

	for k, item in pairs(items) do
		p[k] = item
	end
end

local function rebuildGamepassGiftProductIds()
	MonetizationConfig.GamepassGiftProductIds = {
		RainbowVisualizer = MonetizationConfig.DeveloperProductIds.RainbowVisualizerGift,
		VIP = MonetizationConfig.DeveloperProductIds.VIPGift,
		GreatPretender = MonetizationConfig.DeveloperProductIds.GreatPretenderGift,
		GrandPianoLobby = MonetizationConfig.DeveloperProductIds.GrandPianoLobbyGift,
		PushTool = MonetizationConfig.DeveloperProductIds.PushToolGift,
		Invisibility = MonetizationConfig.DeveloperProductIds.InvisibilityGift,
		ThirdEye = MonetizationConfig.DeveloperProductIds.ThirdEyeGift,
		HeartParticleEffect = MonetizationConfig.DeveloperProductIds.HeartParticleEffectGift,
		MidiPlayer = MonetizationConfig.DeveloperProductIds.MidiPlayerGift,
		X2NotesPlayed = MonetizationConfig.DeveloperProductIds.X2NotesPlayedGift,
		X2NotesCurrency = MonetizationConfig.DeveloperProductIds.X2NotesCurrencyGift
	}
end

if game.GameId == 6914359556 or game.PlaceId == 124500265766244 then
	MonetizationConfig.ActiveMonetizationProfile = "PianoSimulator"
	applyIdOverrides(MonetizationConfig.DeveloperProductIds, v.DeveloperProductIds) -- inferred equivalent call
	applyIdOverrides(MonetizationConfig.GamePassIds, v.GamePassIds) -- inferred equivalent call
	rebuildGamepassGiftProductIds()
else
	MonetizationConfig.ActiveMonetizationProfile = "Default"
end

MonetizationConfig.CurrencyProducts = {
	{
		id = "NotesStarter",
		name = "Starter Notes Pack",
		notes = 100,
		productId = MonetizationConfig.DeveloperProductIds.NotesStarter,
		order = 1,
		icon = "rbxassetid://118207365007642",
		desc = "Adds 100 Notes to your balance"
	},
	{
		id = "NotesSmall",
		name = "Small Notes Pack",
		notes = 250,
		productId = MonetizationConfig.DeveloperProductIds.NotesSmall,
		order = 2,
		icon = "rbxassetid://118207365007642",
		desc = "Adds 250 Notes to your balance."
	},
	{
		id = "NotesMedium",
		name = "Medium Notes Pack",
		notes = 750,
		productId = MonetizationConfig.DeveloperProductIds.NotesMedium,
		order = 3,
		icon = "rbxassetid://86189074120834",
		desc = "Adds 750 Notes to your balance."
	},
	{
		id = "NotesLarge",
		name = "Large Notes Pack",
		notes = 2000,
		productId = MonetizationConfig.DeveloperProductIds.NotesLarge,
		order = 4,
		icon = "rbxassetid://124976349103111",
		desc = "Adds 2,000 Notes to your balance."
	},
	{
		id = "NotesMega",
		name = "Mega Notes Pack",
		notes = 5000,
		productId = MonetizationConfig.DeveloperProductIds.NotesMega,
		order = 5,
		icon = "rbxassetid://0",
		desc = "Adds 5,000 Notes to your balance."
	},
	{
		id = "NotesUltimate",
		name = "Ultimate Notes Pack",
		notes = 10000,
		productId = MonetizationConfig.DeveloperProductIds.NotesUltimate,
		order = 6,
		icon = "rbxassetid://0",
		desc = "Adds 10,000 Notes to your balance."
	},
	{
		id = "NotesGigantic",
		name = "Gigantic Notes Pack",
		notes = 20000,
		productId = MonetizationConfig.DeveloperProductIds.NotesGigantic,
		order = 7,
		icon = "rbxassetid://0",
		desc = "Adds 20,000 Notes to your balance."
	},
	{
		id = "NotesExtreme",
		name = "Extreme Notes Pack",
		notes = 50000,
		productId = MonetizationConfig.DeveloperProductIds.NotesExtreme,
		order = 8,
		icon = "rbxassetid://0",
		desc = "Adds 50,000 Notes to your balance."
	}
}

MonetizationConfig.RewardedAdRewards = {
	Notes = {
		id = "RewardedAdNotes",
		name = "Watch Ad for Notes",
		notes = 50,
		productId = MonetizationConfig.DeveloperProductIds.RewardedAdNotes,
		placementId = "",
		order = 0,
		icon = "rbxassetid://123624321344106",
		desc = "Watch a rewarded video ad to earn 50 Notes."
	}
}

MonetizationConfig.RecordingStorageProducts = {
	{
		id = "RecordingSlot1",
		name = "+1 Recording Slot",
		slots = 1,
		productId = MonetizationConfig.DeveloperProductIds.RecordingSlot1,
		order = 1,
		desc = "Adds 1 saved recording slot."
	},
	{
		id = "RecordingSlot5",
		name = "+5 Recording Slots",
		slots = 5,
		productId = MonetizationConfig.DeveloperProductIds.RecordingSlot5,
		order = 2,
		desc = "Adds 5 saved recording slots."
	},
	{
		id = "RecordingSlot10",
		name = "+10 Recording Slots",
		slots = 10,
		productId = MonetizationConfig.DeveloperProductIds.RecordingSlot10,
		order = 3,
		desc = "Adds 10 saved recording slots."
	}
}

MonetizationConfig.Gamepasses = {
	{
		id = "RainbowVisualizer",
		name = "Rainbow Visualizer",
		gamePassId = MonetizationConfig.GamePassIds.RainbowVisualizer,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.RainbowVisualizer,
		order = 1,
		icon = "RGB",
		desc = "Unlock rainbow visualizer mode."
	},
	{
		id = "VIP",
		name = "VIP [Admin Commands]",
		gamePassId = MonetizationConfig.GamePassIds.VIP,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.VIP,
		order = 2,
		icon = "VIP",
		desc = "Gives you a 👑VIP chat tag and access to HD Admin Commands and VIP Places"
	},
	{
		id = "GreatPretender",
		name = "Great Pretender (hides AUTOPLAY label)",
		gamePassId = MonetizationConfig.GamePassIds.GreatPretender,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.GreatPretender,
		order = 3,
		icon = "AUTO",
		desc = "Hides your AUTOPLAYING overhead tag from everyone. Can be toggle in the Settings"
	},
	{
		id = "GrandPianoLobby",
		name = "Grand Piano Lobby",
		gamePassId = MonetizationConfig.GamePassIds.GrandPianoLobby,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.GrandPianoLobby,
		order = 4,
		desc = "Access to the Grand Piano Lobby piano."
	},
	{
		id = "PushTool",
		name = "Push Tool PERMANENT!",
		gamePassId = MonetizationConfig.GamePassIds.PushTool,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.PushTool,
		order = 5,
		icon = "PUSH",
		desc = "Push players off the pianos with 5 Mins Cooldown. [NOTICE: You can only push players that are using Pianos in the lobby! Does not affect Grand Piano Lobby.]"
	},
	{
		id = "Invisibility",
		name = "Invisibility",
		gamePassId = MonetizationConfig.GamePassIds.Invisibility,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.Invisibility,
		order = 6,
		icon = "INVIS",
		desc = "Toggle invisibility."
	},
	{
		id = "ThirdEye",
		name = "Third Eye",
		gamePassId = MonetizationConfig.GamePassIds.ThirdEye,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.ThirdEye,
		order = 7,
		icon = "EYE",
		desc = "Reveal invisible players."
	},
	{
		id = "HeartParticleEffect",
		name = "Heart Particle Effect",
		gamePassId = MonetizationConfig.GamePassIds.HeartParticleEffect,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.HeartParticleEffect,
		order = 8,
		icon = "HEART",
		desc = "Switch default Synthesia tile effect to heart particles 💗."
	},
	{
		id = "MidiPlayer",
		name = "MIDI AutoPlayer",
		gamePassId = MonetizationConfig.GamePassIds.MidiPlayer,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.MidiPlayer,
		order = 9,
		icon = "MIDI",
		desc = [[
		Unlock our most advanced piano autoplayer!

		Play your favorite songs using MIDI files. This advanced autoplayer lets you load MIDI songs and play them directly on the piano.

		How to use:
		1. Find a MIDI file you want to play.
		2. Upload the MIDI file in Discord
		3. Copy the uploaded MIDI file link.
		4. Paste the link into the MIDI Player text box.
		5. Click Load and enjoy the song.

		Special thanks to @wyverndayo for making this possible.

		Need help or more MIDI Files? Join our Community Server!
		]]
	},
	{
		id = "X2NotesPlayed",
		name = "x2 Notesplayed",
		gamePassId = MonetizationConfig.GamePassIds.X2NotesPlayed,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.X2NotesPlayed,
		order = 10,
		icon = "x2",
		desc = "Doubles your Notes Played stat gains while you play."
	},
	{
		id = "X2NotesCurrency",
		name = "x2 Notes Currency",
		gamePassId = MonetizationConfig.GamePassIds.X2NotesCurrency,
		giftProductId = MonetizationConfig.GamepassGiftProductIds.X2NotesCurrency,
		order = 11,
		icon = "x2",
		desc = "Earn +100% more note currency from active piano rewards."
	}
}

function MonetizationConfig.GetCurrencyProductByProductId(p)
	local v2 = tonumber(p)

	if not v2 or v2 == 0 then
		return nil
	end

	for _, currencyProduct in ipairs(MonetizationConfig.CurrencyProducts) do
		if tonumber(currencyProduct.productId) == v2 then
			return currencyProduct
		end
	end

	return nil
end

function MonetizationConfig.GetCurrencyProductForShortfall(p)
	local v2 = math.max(1, (math.floor(tonumber(p) or 0)))
	local v3 = 1e999
	local v4 = -1e999
	local v5 = nil
	local v6 = nil

	for _, v7 in ipairs(MonetizationConfig.CurrencyProducts or {}) do
		local v8 = math.max(0, (math.floor(tonumber(v7.notes) or 0)))
		local productId = math.floor(tonumber(v7.productId) or 0)

		if not (v8 > 0 and productId > 0) then
			continue
		end

		if v2 <= v8 and v8 < v3 then
			v5 = v7
			v3 = v8
		end

		if not (v4 < v8) then
			continue
		end

		v6 = v7
		v4 = v8
	end

	return v5 or v6
end

function MonetizationConfig.GetRecordingStorageProductByProductId(p)
	local v2 = tonumber(p)

	if not v2 or v2 == 0 then
		return nil
	end

	for _, v3 in ipairs(MonetizationConfig.RecordingStorageProducts or {}) do
		if tonumber(v3.productId) == v2 then
			return v3
		end
	end

	return nil
end

function MonetizationConfig.GetRewardedAdReward(value)
	local v2 = tostring(value or "Notes")
	local selected = MonetizationConfig.RewardedAdRewards and MonetizationConfig.RewardedAdRewards[v2]
	return if type(selected) == "table" then selected else nil
end

function MonetizationConfig.GetRewardedAdRewardByProductId(p)
	local v2 = tonumber(p)

	if not v2 or v2 == 0 then
		return nil
	end

	for _, v3 in pairs(MonetizationConfig.RewardedAdRewards or {}) do
		if tonumber(v3.productId) == v2 then
			return v3
		end
	end

	return nil
end

function MonetizationConfig.GetDeveloperProductId(p)
	return MonetizationConfig.DeveloperProductIds[p] or 0
end

function MonetizationConfig.GetGamePassId(p)
	return MonetizationConfig.GamePassIds[p] or 0
end

return MonetizationConfig