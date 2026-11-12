local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage2:WaitForChild("ClientDebugConfig"))

local SoundService2 = game:GetService("SoundService")
SoundService = SoundService2
local TweenService2 = game:GetService("TweenService")
TweenService = TweenService2
local ContentProvider2 = game:GetService("ContentProvider")
ContentProvider = ContentProvider2
local Players2 = game:GetService("Players")
Players = Players2
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
ReplicatedStorage = ReplicatedStorage3
Piano_Dependencies = workspace.Piano_Dependencies

local SoundUtils = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("SoundUtils"))
local SoundEffects = require(Piano_Dependencies.Modules.Dependencies:WaitForChild("SoundEffects"))

LocalPlayer = Players.LocalPlayer

local v = 50

local v2 = {}

local v3 = {}
local v4 = {}
ServerSustainedNotes = v4
ServerNonSustainedNotes = v4

local v5 = {}
local object = setmetatable({}, { __mode = "k" })
local set = {}

local _ = { TotalNotesPlayed = 0, NotesPerKey = {}, NotesPerPiano = {}, SessionStartTime = tick() }

local function normalizeMaxExistingNotes(p) -- 3 equivalent calls inferred from this helper
	return (math.clamp(math.floor(tonumber(p) or 50), 5, 200))
end

local function getCurrentMaxExistingNotes() -- 2 equivalent calls inferred from this helper
	if LocalPlayer then
		local maxPianoSounds = LocalPlayer:GetAttribute("MaxPianoSounds")

		if maxPianoSounds ~= nil then
			v = normalizeMaxExistingNotes(maxPianoSounds) -- inferred equivalent call
		end
	end

	return normalizeMaxExistingNotes(v) -- inferred equivalent call
end

local function normalizeSoundId(p) -- 1 equivalent call inferred from this helper
	if p == nil then
		return ""
	end

	local v6 = tostring(p)

	if v6 == "" then
		return ""
	end

	if v6:find("rbxassetid://", 1, true) then
		return v6
	end

	if v6:match("^%d+$") then
		return "rbxassetid://" .. v6
	end

	return v6
end

local function getPoolFolder() -- 3 equivalent calls inferred from this helper
	local pianoSoundPool = SoundService:FindFirstChild("_PianoSoundPool")

	if not pianoSoundPool then
		pianoSoundPool = Instance.new("Folder")
		pianoSoundPool.Name = "_PianoSoundPool"
		pianoSoundPool.Parent = SoundService
	end

	return pianoSoundPool
end

local function getPoolKey(p)
	return normalizeSoundId(p) -- inferred equivalent call
end

local function cancelTrackedTween(p) -- 2 equivalent calls inferred from this helper
	if p and p.Tween then
		pcall(function()
			p.Tween:Cancel()
		end)
		p.Tween = nil
	end
end

local v6 = {}

local function clearPianoSoundEffects(instance)
	for _, child in ipairs(instance:GetChildren()) do
		if child:GetAttribute("PianoSoundEffect") == true then
			child:Destroy()
		end
	end
end

local function getSoundEffectOwnerKey(player)
	if typeof(player) == "Instance" and player:IsA("Player") then
		return "player_" .. tostring(player.UserId)
	end

	local v7 = tonumber(player)

	if v7 then
		return "player_" .. tostring((math.floor(v7)))
	end

	if type(player) == "string" and player ~= "" then
		return player:gsub("[^%w_%-]", "_")
	end

	if LocalPlayer then
		return "player_" .. tostring(LocalPlayer.UserId)
	end

	return "local"
end

local function getOrCreatePianoSoundGroup(p)
	local soundEffectOwnerKey = getSoundEffectOwnerKey(p)
	local v7 = v6[soundEffectOwnerKey]

	if v7 and v7.Parent ~= nil then
		return v7
	end

	local name = "_PianoEffects_" .. soundEffectOwnerKey
	local v8 = SoundService:FindFirstChild(name)

	if not (v8 and v8:IsA("SoundGroup")) then
		v8 = Instance.new("SoundGroup")
		v8.Name = name
		v8.Volume = 1
		v8.Parent = SoundService
	end

	v6[soundEffectOwnerKey] = v8
	return v8
end

local function applySpecToSoundGroup(pianoSoundGroup, instance)
	local success, result = pcall(Instance.new, instance.ClassName)

	if not (success and result) then
		return
	end

	result.Name = instance.Name or instance.ClassName
	result:SetAttribute("PianoSoundEffect", true)
	pcall(function()
		result.Enabled = true
	end)

	for k, v7 in pairs(instance.Properties or {}) do
		pcall(function()
			result[k] = v7
		end)
	end

	result.Parent = pianoSoundGroup
end

local function resolvePianoSoundGroup(soundEffects, soundEffectsOwnerKey)
	if soundEffects == nil then
		return nil
	end

	local state = SoundEffects.NormalizeState(soundEffects)
	local pianoSoundGroup = getOrCreatePianoSoundGroup(soundEffectsOwnerKey)
	local encodeState = SoundEffects.EncodeState(state)

	if pianoSoundGroup:GetAttribute("PianoSoundEffectsSignature") == encodeState then
		return pianoSoundGroup
	end

	clearPianoSoundEffects(pianoSoundGroup)

	for _, v7 in ipairs(SoundEffects.BuildSoundEffectSpecs(state)) do
		applySpecToSoundGroup(pianoSoundGroup, v7)
	end

	pianoSoundGroup:SetAttribute("PianoSoundEffectsSignature", encodeState)

	return pianoSoundGroup
end

local function configurePooledSound(pooledPianoSound, data)
	pooledPianoSound.Name = "PooledPianoSound"
	local soundId = data.SoundId
	local soundId2

	if soundId == nil then
		soundId2 = ""
	else
		soundId2 = tostring(soundId)

		if soundId2 == "" then
			soundId2 = ""
		elseif not soundId2:find("rbxassetid://", 1, true) and soundId2:match("^%d+$") then
			soundId2 = "rbxassetid://" .. soundId2
		end
	end

	pooledPianoSound.SoundId = soundId2
	pooledPianoSound.Volume = tonumber(data.Volume) or 0
	pooledPianoSound.TimePosition = tonumber(data.TimePosition) or 0
	pooledPianoSound.PlayOnRemove = data.PlayOnRemove == true
	pooledPianoSound.Looped = data.Looped == true

	local playbackSpeed = tonumber(data.PlaybackSpeed or data.Pitch) or 1
	pcall(function()
		pooledPianoSound.PlaybackSpeed = playbackSpeed
	end)
	pcall(function()
		pooledPianoSound.Pitch = playbackSpeed
	end)

	clearPianoSoundEffects(pooledPianoSound)
	pooledPianoSound.SoundGroup = resolvePianoSoundGroup(data.SoundEffects, data.SoundEffectsOwnerKey)
	pooledPianoSound.Parent = data.Parent or SoundService
end

local function acquirePooledSound(p)
	local soundId = p.SoundId
	local v7

	if soundId == nil then
		v7 = ""
	else
		v7 = tostring(soundId)

		if v7 == "" then
			v7 = ""
		elseif not v7:find("rbxassetid://", 1, true) and v7:match("^%d+$") then
			v7 = "rbxassetid://" .. v7
		end
	end

	local v8 = v5[v7]
	local v9 = nil

	while v8 and #v8 > 0 do
		local sound = table.remove(v8)

		if typeof(sound) == "Instance" and sound:IsA("Sound") and sound.Parent ~= nil then
			v9 = sound
			break
		end
	end

	local pooledSound = v9 or SoundUtils.create(p)

	local v10 = object[pooledSound] or { Pooled = true, Token = 0 }
	cancelTrackedTween(v10) -- inferred equivalent call
	v10.Pooled = true
	v10.InUse = true
	v10.Releasing = false
	v10.Key = v7
	v10.Token = (v10.Token or 0) + 1
	object[pooledSound] = v10

	configurePooledSound(pooledSound, p)
	return pooledSound
end

local function getSoundToken(p) -- 2 equivalent calls inferred from this helper
	local v7 = p and object[p]
	return v7 and v7.Token or nil
end

local function resolveSoundEntry(p) -- 2 equivalent calls inferred from this helper
	if type(p) == "table" and p.sound then
		return p.sound, p.token
	end

	return p, nil
end

local function startsWith(value, value2): boolean -- 2 equivalent calls inferred from this helper
	return type(value) == "string" and type(value2) == "string" and value2 ~= "" and value:sub(1, #value2) == value2
end

local function makeActiveEntry(sound) -- 2 equivalent calls inferred from this helper
	return { sound = sound, token = getSoundToken(sound) } -- inferred equivalent call
end

local function releasePooledSound(soundEntry, p)
	if not soundEntry then
		return
	end

	local v7 = object[soundEntry]

	if p ~= nil and (not v7 or v7.Token ~= p) then
		return
	end

	cancelTrackedTween(v7) -- inferred equivalent call
	pcall(function()
		soundEntry:Stop()
	end)

	if not (v7 and v7.Pooled) then
		pcall(function()
			soundEntry:Destroy()
		end)
		return
	end

	v7.Token = (v7.Token or 0) + 1
	v7.InUse = false
	v7.Releasing = false
	v7.ActiveKeyCode = nil
	v7.UseServerNoteTable = nil
	soundEntry.Volume = 0
	soundEntry.SoundGroup = nil
	clearPianoSoundEffects(soundEntry)
	pcall(function()
		soundEntry.TimePosition = 0
	end)

	local v8 = v7.Key

	if not v8 then
		local soundId = soundEntry.SoundId

		if soundId == nil then
			v8 = ""
		else
			v8 = tostring(soundId)

			if v8 == "" then
				v8 = ""
			elseif not v8:find("rbxassetid://", 1, true) and v8:match("^%d+$") then
				v8 = "rbxassetid://" .. v8
			end
		end
	end

	v7.Key = v8
	local instances = v5[v8]

	if not instances then
		instances = {}
		v5[v8] = instances
	end

	if #instances < 4 then
		soundEntry.Parent = getPoolFolder() -- inferred equivalent call
		table.insert(instances, soundEntry)
	else
		object[soundEntry] = nil
		pcall(function()
			soundEntry:Destroy()
		end)
	end
end

local function stopLimitedAudio(p) -- 1 equivalent call inferred from this helper
	local soundEntry, v7 = resolveSoundEntry(p) -- inferred equivalent call
	releasePooledSound(soundEntry, v7)
end

function NoteLimit(sound)
	table.insert(v2, 1, makeActiveEntry(sound)) -- inferred equivalent call
	local currentMaxExistingNotes = getCurrentMaxExistingNotes() -- inferred equivalent call

	while currentMaxExistingNotes < #v2 do
		stopLimitedAudio(table.remove(v2)) -- inferred equivalent call
	end
end

function NoteFadeout(p, p2, p3)
	task.spawn(function()
		local soundEntry, v7 = resolveSoundEntry(p) -- inferred equivalent call
		v7 = p3 ~= nil and p3 or v7

		if not soundEntry or soundEntry.Parent == nil then
			return
		end

		local v8 = object[soundEntry]

		if v7 ~= nil and (not v8 or v8.Token ~= v7) or v8 and v8.Releasing then
			return
		end

		if v8 then
			v8.Releasing = true
		end

		local v9 = tonumber(p2) or 0

		if v9 <= 0 then
			releasePooledSound(soundEntry, v7)
			return
		end

		local tween = TweenService:Create(soundEntry, TweenInfo.new(v9, Enum.EasingStyle.Linear), {
			Volume = 0
		})

		if v8 then
			v8.Tween = tween
		end

		tween:Play()
		tween.Completed:Wait()

		if v8 and v8.Tween == tween then
			v8.Tween = nil
		end

		releasePooledSound(soundEntry, v7)
	end)
end

local function scheduleNoteFadeout(p, p2, p3) -- 5 equivalent calls inferred from this helper
	local soundToken = getSoundToken(p) -- inferred equivalent call
	task.delay(tonumber(p2) or 0, function()
		NoteFadeout(p, p3, soundToken)
	end)
end

local function getActiveNoteTable(p) -- 1 equivalent call inferred from this helper
	return p and v4 or v3
end

local function fadeActiveRecord(p, p2, p3, p4) -- 4 equivalent calls inferred from this helper
	if not p3 then
		return
	end

	if p2 ~= nil and p and p[p2] == p3 then
		p[p2] = nil
	end

	NoteFadeout(p3, p4 or p3.fadeout or 0)
end

local function trackActiveNote(activeKeyCode, sound, p, fadeout, p2)
	if activeKeyCode == nil then
		return nil
	end

	local activeNoteTable = getActiveNoteTable(p2) -- inferred equivalent call
	local v7 = activeNoteTable[activeKeyCode]

	if v7 then
		fadeActiveRecord(activeNoteTable, activeKeyCode, v7, fadeout) -- inferred equivalent call
	end

	local activeEntry = makeActiveEntry(sound) -- inferred equivalent call
	local v8 = sound and object[sound]

	if v8 then
		v8.ActiveKeyCode = activeKeyCode
		v8.UseServerNoteTable = p2 == true
	end

	activeEntry.held = true
	activeEntry.sustained = p == true
	activeEntry.fadeout = fadeout
	activeNoteTable[activeKeyCode] = activeEntry
	return activeEntry
end

local function releaseActiveNote(p, p2, p3) -- 2 equivalent calls inferred from this helper
	if p2 == nil then
		return
	end

	local v7 = p[p2]

	if not v7 then
		return
	end

	v7.held = false
	v7.fadeout = p3 or v7.fadeout

	if not v7.sustained then
		fadeActiveRecord(p, p2, v7, p3) -- inferred equivalent call
	end
end

local function updateSustainRecords(items, p, p2)
	local sustained = p == true

	for k, item in pairs(items) do
		if not item then
			continue
		end

		item.sustained = sustained
		item.fadeout = p2 or item.fadeout

		if not (item.held or item.sustained) then
			fadeActiveRecord(items, k, item, p2) -- inferred equivalent call
		end
	end
end

local PianoLogic = {
	function(p, list, timePosition, p2, fadeout, _, _, p3, _, p4, p5, p6, activeKeyCode, p7, soundEffects, soundEffectsOwnerKey)
		local v7 = p + 15

		local pitch = 1
		local v8

		if v7 > 88 then
			pitch = 1.059463 ^ (v7 - 88)
			v8 = list[88]
		elseif v7 < 1 then
			pitch = 1.059463 ^ (-(1 - v7))
			v8 = list[1]
		else
			v8 = list[v7]
		end

		local sound = acquirePooledSound({
			SoundId = "rbxassetid://" .. v8,
			Volume = (p5 / 100) ^ 1.2 * (p4 / 100) * p6,
			TimePosition = timePosition,
			Pitch = pitch,
			PlayOnRemove = false,
			Parent = SoundService,
			SoundEffects = soundEffects,
			SoundEffectsOwnerKey = soundEffectsOwnerKey
		})

		SoundUtils.play(sound, false)

		NoteLimit(sound)

		trackActiveNote(activeKeyCode, sound, p3, fadeout, p7)
		scheduleNoteFadeout(sound, p2, fadeout) -- inferred equivalent call
	end,
	function(p, list, timePosition, p2, fadeout, _, _, p3, _, p4, p5, p6, activeKeyCode, p7, soundEffects, soundEffectsOwnerKey)
		local pitch = 1
		local v7

		if p > 61 then
			pitch = 1.059463 ^ (p - 61)
			v7 = list[61]
		elseif p < 1 then
			pitch = 1.059463 ^ (-(1 - p))
			v7 = list[1]
		else
			v7 = list[p]
		end

		local sound = acquirePooledSound({
			SoundId = "rbxassetid://" .. v7,
			Volume = (p5 / 100) ^ 1.2 * (p4 / 100) * p6,
			TimePosition = timePosition,
			Pitch = pitch,
			PlayOnRemove = false,
			Parent = SoundService,
			SoundEffects = soundEffects,
			SoundEffectsOwnerKey = soundEffectsOwnerKey
		})

		SoundUtils.play(sound, false)

		NoteLimit(sound)

		trackActiveNote(activeKeyCode, sound, p3, fadeout, p7)
		scheduleNoteFadeout(sound, p2, fadeout) -- inferred equivalent call
	end,
	function(p, list, timePosition, p2, fadeout, _, _, p3, _, p4, p5, p6, activeKeyCode, p7, soundEffects, soundEffectsOwnerKey)
		local v7 = p + 27

		local pitch = 1
		local v8

		if v7 > 88 then
			pitch = 1.059463 ^ (v7 - 88)
			v8 = list[88]
		elseif v7 < 1 then
			pitch = 1.059463 ^ (-(1 - v7))
			v8 = list[1]
		else
			v8 = list[v7]
		end

		local sound = acquirePooledSound({
			SoundId = "rbxassetid://" .. v8,
			Volume = (p5 / 100) ^ 1.2 * (p4 / 100) * p6,
			TimePosition = timePosition,
			Pitch = pitch,
			PlayOnRemove = false,
			Parent = SoundService,
			SoundEffects = soundEffects,
			SoundEffectsOwnerKey = soundEffectsOwnerKey
		})

		SoundUtils.play(sound, false)

		NoteLimit(sound)

		trackActiveNote(activeKeyCode, sound, p3, fadeout, p7)
		scheduleNoteFadeout(sound, p2, fadeout) -- inferred equivalent call
	end,
	function(p, p2, p3, p4, fadeout, _, _, p5, _, p6, p7, p8, activeKeyCode, p9, soundEffects, soundEffectsOwnerKey)
		local pitch = 1

		if p > 61 then
			pitch = 1.059463 ^ (p - 61)
		elseif p < 1 then
			pitch = 1.059463 ^ (-(1 - p))
		end

		local v7 = p > 61 and 61 or p < 1 and 1 or p
		local v8 = (v7 - 1) % 12 + 1
		local v9 = (math.ceil(v7 / 12) - 1) * 16 + 8 * (1 - v8 % 2)
		local v10 = math.ceil(v8 / 2)

		local sound = acquirePooledSound({
			SoundId = "rbxassetid://" .. (p2 and p2[v10]),
			Volume = (p7 / 100) ^ 1.2 * (p6 / 100) * p8,
			TimePosition = v9 + p3 or v9 + 0.027,
			Pitch = pitch,
			PlayOnRemove = false,
			Parent = SoundService,
			SoundEffects = soundEffects,
			SoundEffectsOwnerKey = soundEffectsOwnerKey
		})

		SoundUtils.play(sound, false)

		NoteLimit(sound)

		trackActiveNote(activeKeyCode, sound, p5, fadeout, p9)
		scheduleNoteFadeout(sound, p4, fadeout) -- inferred equivalent call
	end
}

function PianoLogic.PlayServerNote(_, soundId, volume, timePosition, pitch, p, p2, fadeout, activeKeyCode, soundEffects, soundEffectsOwnerKey)
	if soundId then
		local sound = acquirePooledSound({
			SoundId = soundId,
			Volume = volume,
			TimePosition = timePosition,
			Pitch = pitch,
			PlayOnRemove = false,
			Parent = SoundService,
			SoundEffects = soundEffects,
			SoundEffectsOwnerKey = soundEffectsOwnerKey
		})

		SoundUtils.play(sound, false)

		NoteLimit(sound)

		trackActiveNote(activeKeyCode, sound, p, fadeout, true)
		scheduleNoteFadeout(sound, p2, fadeout) -- inferred equivalent call
	end
end

function PianoLogic.FinishNonSustainNote(p, p2)
	releaseActiveNote(v3, p, p2) -- inferred equivalent call
end

function PianoLogic.ServerFinishNonSustainNote(p, p2)
	releaseActiveNote(v4, p, p2) -- inferred equivalent call
end

function PianoLogic.UpdateSustainState(p, p2)
	updateSustainRecords(v3, p, p2)
end

function PianoLogic.ServerUpdateSustainState(p, p2)
	updateSustainRecords(v4, p, p2)
end

function PianoLogic.FadeoutAllSustainedNotes(p)
	PianoLogic.UpdateSustainState(false, p)
end

function PianoLogic.ServerFadeoutAllSustainedNotes(p)
	PianoLogic.ServerUpdateSustainState(false, p)
end

function PianoLogic.ServerStopNotesByPrefix(value, p)
	local v7 = tostring(value or "")

	if v7 == "" then
		return
	end

	local v8 = tonumber(p) or 0

	for k, v9 in pairs(v4) do
		if startsWith(k, v7) then -- inferred equivalent call
			fadeActiveRecord(v4, k, v9, v8) -- inferred equivalent call
		end
	end

	for i = #v2, 1, -1 do
		local v9 = v2[i]
		local v10

		if type(v9) == "table" and v9.sound then
			v10 = v9.sound
			local _token = v9.token
		else
			v10 = v9
		end

		local v11 = v10 and object[v10]

		if not (v11 and v11.UseServerNoteTable == true and startsWith(v11.ActiveKeyCode, v7)) then -- inferred equivalent call
			continue
		end

		table.remove(v2, i)
		NoteFadeout(v9, v8)
	end
end

function PianoLogic.ResetPianoSoundGroup(p)
	local soundEffectOwnerKey = getSoundEffectOwnerKey(p)
	local soundGroup = v6[soundEffectOwnerKey]

	if not soundGroup or soundGroup.Parent == nil then
		soundGroup = SoundService:FindFirstChild("_PianoEffects_" .. soundEffectOwnerKey)
	end

	if soundGroup and soundGroup:IsA("SoundGroup") then
		clearPianoSoundEffects(soundGroup)
		soundGroup:SetAttribute("PianoSoundEffectsSignature", nil)
	end
end

function PianoLogic.PlayLocalAnimation(moduleScript, p, p2)
	if moduleScript then
		local module = require(moduleScript)

		if p2 == true then
			module.PianoAnimation(p, true)
		elseif p2 == false then
			module.PianoAnimation(p, false)
		end
	end
end

function PianoLogic.PrewarmSoundfont(items, value)
	if type(items) ~= "table" then
		return
	end

	local v7 = { (tostring(value or "")) }
	local set2 = {}

	for _, item in pairs(items) do
		local v8

		if item == nil then
			v8 = ""
		else
			v8 = tostring(item)

			if v8 == "" then
				v8 = ""
			elseif not v8:find("rbxassetid://", 1, true) and v8:match("^%d+$") then
				v8 = "rbxassetid://" .. v8
			end
		end

		if v8 == "" or set2[v8] then
			continue
		end

		set2[v8] = true
		table.insert(v7, v8)
	end

	if #v7 <= 1 then
		return
	end

	table.sort(v7)
	local joined = table.concat(v7, "|")

	if set[joined] then
		return
	end

	set[joined] = true

	task.spawn(function()
		local v8 = {}
		local count = 0

		for k in pairs(set2) do
			local v9

			if k == nil then
				v9 = ""
			else
				v9 = tostring(k)

				if v9 == "" then
					v9 = ""
				elseif not v9:find("rbxassetid://", 1, true) and v9:match("^%d+$") then
					v9 = "rbxassetid://" .. v9
				end
			end

			local v10 = v5[v9]

			if not v10 then
				v10 = {}
				v5[v9] = v10
			end

			for _ = 1, 1 do
				if not (#v10 < 4) then
					continue
				end

				local v11 = SoundUtils.create({
					SoundId = k,
					Volume = 0,
					TimePosition = 0,
					Pitch = 1,
					PlaybackSpeed = 1,
					PlayOnRemove = false,
					Parent = getPoolFolder() -- inferred equivalent call
				})

				configurePooledSound(v11, {
					SoundId = k,
					Volume = 0,
					TimePosition = 0,
					Pitch = 1,
					PlayOnRemove = false,
					Parent = getPoolFolder() -- inferred equivalent call
				})

				object[v11] = {
					Pooled = true,
					InUse = false,
					Releasing = false,
					Token = 0,
					Key = v9
				}

				table.insert(v10, v11)
				table.insert(v8, v11)
				count += 1

				if count % 16 == 0 then
					task.wait()
				end
			end
		end

		if #v8 > 0 then
			local success, result = pcall(function()
				ContentProvider:PreloadAsync(v8)
			end)

			if not success then
				ClientDebugConfig.Warn("[PianoLogic] Sound pool preload failed: " .. tostring(result))
			end
		end

		if count > 0 then
			ClientDebugConfig.Print("[PianoLogic] Prewarmed " .. tostring(count) .. " pooled piano sound(s)")
		end
	end)
end

function PianoLogic.SetMaxPianoSounds(p)
	v = normalizeMaxExistingNotes(p) -- inferred equivalent call

	if LocalPlayer then
		LocalPlayer:SetAttribute("MaxPianoSounds", v)
	end

	return v
end

function PianoLogic.GetMaxPianoSounds()
	return getCurrentMaxExistingNotes() -- inferred equivalent call
end

function PianoLogic.GetMaxPianoSoundsBounds(): (number, number, number)
	return 5, 200, 50
end

function PianoLogic.Transpose(p, total)
	total += p

	if total > 24 then
		return 24
	end

	return total < -24 and -24 or total
end

function PianoLogic.Volume(p, total)
	total += p

	if total > 200 then
		return 200
	end

	return total < 10 and 10 or total
end

return PianoLogic