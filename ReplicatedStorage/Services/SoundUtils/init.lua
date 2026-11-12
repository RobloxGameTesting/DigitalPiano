game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local InstanceUtils = require(script.InstanceUtils)
local TableUtil = require(script.TableUtil)

local SoundUtils = { _soundCt = 0 }

local v = { _globalProfiles = {} }

v.__index = v

local class = {}
class.__index = class

local sound = {
	Parent = workspace,
	SoundId = "",
	Name = "Sound",
	RollOffMaxDistance = 10000,
	RollOffMinDistance = 10000,
	RollOffMode = Enum.RollOffMode.InverseTapered,
	Looped = false,
	PlaybackSpeed = 1,
	Playing = false,
	TimePosition = 0,
	Volume = 0.5
}

local v2 = {
	Name = `SoundProfile{HttpService:GenerateGUID(false)}`,
	RollOffMaxDistance = 10000,
	RollOffMinDistance = 10000,
	RollOffMode = Enum.RollOffMode.InverseTapered,
	Looped = false,
	PlaybackSpeed = 1,
	Playing = false,
	TimePosition = 0,
	Volume = 0.5
}

local function getProfileByName(p: string) -- 4 equivalent calls inferred from this helper
	return v._globalProfiles[p]
end

local function updateGlobalProfileReference(p: string, profile) -- 3 equivalent calls inferred from this helper
	v._globalProfiles[p] = profile
end

function SoundUtils.create(value)
	local v3

	if type(value) == "string" then
		local profileByName = getProfileByName(value) -- inferred equivalent call

		if type(profileByName) == "table" then
			v3 = TableUtil.Sync({ Parent = workspace, SoundId = "" }, profileByName)
		else
			warn(`Profile '{value}' not found, using default config`)
			v3 = sound
		end
	else
		v3 = TableUtil.Sync(value or sound, sound)
	end

	local sound2 = Instance.new("Sound")
	SoundUtils._soundCt += 1
	InstanceUtils.configure(sound2, v3)
	return sound2
end

function SoundUtils.createFromProfile(p: string, options)
	local profileByName = getProfileByName(p) -- inferred equivalent call

	if type(profileByName) == "table" then
		local v3 = TableUtil.Reconcile(options or {}, profileByName)
		return SoundUtils.create(v3)
	end

	warn(`Profile '{p}' not found, using default config`)
	return SoundUtils.create(options or {})
end

function SoundUtils.createAll(list, flag: boolean)
	assert(type(list) == "table", `'configs' expected a table, got '{list}'`)
	local result = {}

	for name, item in ipairs(list) do
		local v3 = SoundUtils.create(item)
		name = flag and v3.Name or name
		result[name] = v3
	end

	if flag then
		return result
	end

	return table.unpack(result)
end

function SoundUtils.createAllFromProfile(items, flag: boolean)
	assert(type(items) == "table", `'profileConfigs' expected a table, got '{items}'`)
	local result = {}
	local v3 = 1

	for k, item in pairs(items) do
		if type(item) == "table" and item[1] ~= nil then
			for _, v4 in ipairs(item) do
				local v5 = SoundUtils.createFromProfile(k, v4)
				local v6

				if flag then
					v6 = v5.Name or v3
				else
					v6 = v3
				end

				result[v6] = v5
				v3 += 1
			end
		else
			local v4 = SoundUtils.createFromProfile(k, item)
			local v5

			if flag then
				v5 = v4.Name or v3
			else
				v5 = v3
			end

			result[v5] = v4
			v3 += 1
		end
	end

	if flag then
		return result
	end

	return table.unpack(result)
end

function SoundUtils.playAndWait(sound2, flag: boolean?)
	local v3 = typeof(sound2) == "Instance" and sound2:IsA("Sound")
	assert(v3, `Expected Sound instance, got '{sound2}'`)
	sound2:Play()

	if flag then
		Debris:AddItem(sound2, sound2.TimeLength)
	end

	if sound2.IsPlaying then
		sound2.Ended:Wait()
	end
end

function SoundUtils.play(sound2, flag: boolean?)
	local v3 = typeof(sound2) == "Instance" and sound2:IsA("Sound")
	assert(v3, `Expected Sound instance, got '{sound2}'`)
	sound2:Play()

	if flag then
		Debris:AddItem(sound2, sound2.TimeLength)
	end
end

function SoundUtils.playAsync(sound2, flag: boolean?, callback)
	local v3 = typeof(sound2) == "Instance" and sound2:IsA("Sound")
	assert(v3, `Expected Sound instance, got '{sound2}'`)
	sound2:Play()

	if flag then
		Debris:AddItem(sound2, sound2.TimeLength)
	end

	local endedConnection = nil
	endedConnection = sound2.Ended:Connect(function()
		if type(callback) == "function" then
			callback()
		end

		if endedConnection.Connected then
			endedConnection:Disconnect()
		end
	end)
	return endedConnection
end

function SoundUtils.acquireTimeUntilDone(sound2)
	local v3 = typeof(sound2) == "Instance" and sound2:IsA("Sound")
	assert(v3, `'sound' expected a Sound Instance, got '{sound2}'`)

	if sound2.IsPlaying then
		return sound2.TimeLength - sound2.TimePosition
	end

	return 0
end

function SoundUtils.newProfile(p)
	return v.new(p)
end

function SoundUtils.newPreloader()
	return class.new()
end

function SoundUtils.getProfile(p: string)
	return getProfileByName(p) -- inferred equivalent call
end

function SoundUtils.listProfiles()
	local result = {}

	for k, _ in pairs(v._globalProfiles) do
		table.insert(result, k)
	end

	return result
end

function SoundUtils.removeProfile(value: string)
	assert(typeof(value) == "string", `expected a string, got '{value}'`)

	if type(getProfileByName(value)) ~= "table" then -- inferred equivalent call
		return
	end

	updateGlobalProfileReference(value) -- inferred equivalent call
end

function SoundUtils.profileCount()
	local count = 0

	for _ in pairs(v._globalProfiles) do
		count += 1
	end

	return count
end

function SoundUtils.count()
	return SoundUtils._soundCt
end

function v.new(p)
	assert(type(p) == "table", `'profileConfig' expects a table, got '{p}'`)
	local self = setmetatable({ _profile = TableUtil.Sync(p, v2) }, v)

	updateGlobalProfileReference(self._profile.Name, self._profile) -- inferred equivalent call
	return self
end

function v:Sync(p)
	self._profile = TableUtil.Sync(p, self._profile)
	updateGlobalProfileReference(self._profile.Name, self._profile) -- inferred equivalent call
end

function v:GetProfile()
	return self._profile
end

function v:Destroy()
	v._globalProfiles[self._profile.Name] = nil

	for k, _ in pairs(self) do
		self[k] = nil
	end

	setmetatable(self, nil)
end

function class.new()
	return (setmetatable({
		_sounds = {},
		_isLoaded = false,
		_isLoading = false,
		_loadedCt = 0,
		_totalCt = 0
	}, class))
end

function class:Add(soundId: string, p: string?, profile: string?, overrides)
	assert(typeof(soundId) == "string", `'soundId' expected a string, got '{soundId}'`)
	assert(not self._isLoaded, "Cannot add sounds after preloader has been loaded")
	local name = p or `Sound_{#self._sounds + 1}`

	self._sounds[name] = {
		SoundId = soundId,
		Name = name,
		Profile = profile,
		Overrides = overrides
	}

	self._totalCt += 1
	return self
end

function class:AddBatch(items)
	assert(type(items) == "table", `'batch' expected a table, got '{items}'`)
	assert(not self._isLoaded, "Cannot add sounds after preloader has been loaded")

	for k, item in pairs(items) do
		assert(type(item) == "table", `Config for '{k}' expected a table, got '{item}'`)
		assert(typeof(item.SoundId) == "string", `SoundId for '{k}' expected a string, got '{item.SoundId}'`)
		local name = item.Name or k
		self._sounds[name] = {
			SoundId = item.SoundId,
			Name = name,
			Profile = item.Profile,
			Overrides = item.Overrides
		}

		self._totalCt += 1
	end

	return self
end

function class:LoadAndWait()
	if self._isLoaded then
		return
	end

	if self._isLoading then
		repeat
			task.wait()
		until not self._isLoading
	else
		self._isLoading = true

		self._loadedCt = 0
		local sounds = {}

		for k, sound2 in pairs(self._sounds) do
			local v3

			if sound2.Profile then
				local v4 = TableUtil.Reconcile(sound2.Overrides or {}, {
					SoundId = sound2.SoundId,
					Name = k
				})

				v3 = SoundUtils.createFromProfile(sound2.Profile, v4)
			else
				local v4 = TableUtil.Reconcile(sound2.Overrides or {}, {
					SoundId = sound2.SoundId,
					Name = k
				})

				v3 = SoundUtils.create(v4)
			end

			v3.Loaded:Wait()
			sounds[k] = v3
			self._loadedCt += 1
		end

		self._sounds = sounds
		self._isLoaded = true
		self._isLoading = false
	end
end

function class:LoadAsync(callback)
	if not self._isLoaded then
		coroutine.wrap(function()
			self:LoadAndWait()

			if type(callback) == "function" then
				callback()
			end
		end)()
	elseif type(callback) == "function" then
		callback()
	end
end

function class:GetSound(value: string)
	assert(typeof(value) == "string", `'name' expected a string, got '{value}'`)

	if self._isLoaded then
		return self._sounds[value]
	end

	warn("Attempting to get sound before loading is complete is likely a bug")
	return nil
end

function class:GetAllSounds()
	if self._isLoaded then
		return self._sounds
	end

	warn("Attempting to get sounds before loading is complete is likely a bug")
	return {}
end

function class:PlaySound(p: string, flag: boolean?): boolean
	local sound2 = self:GetSound(p)

	if typeof(sound2) == "Instance" and sound2:IsA("Sound") then
		SoundUtils.play(sound2, flag)
		return true
	end

	warn(`Sound '{p}' not found`)
	return false
end

function class:PlaySoundAndWait(p: string, flag: boolean?): boolean
	local sound2 = self:GetSound(p)

	if typeof(sound2) == "Instance" and sound2:IsA("Sound") then
		SoundUtils.playAndWait(sound2, flag)
		return true
	end

	warn(`Sound '{p}' not found`)
	return false
end

function class:PlaySoundAsync(p: string, flag: boolean?, callback)
	local sound2 = self:GetSound(p)

	if typeof(sound2) == "Instance" and sound2:IsA("Sound") then
		return SoundUtils.playAsync(sound2, flag, callback)
	end

	warn(`Sound '{p}' not found`)
	return nil
end

function class:IsLoaded()
	return self._isLoaded
end

function class:GetProgress()
	return self._loadedCt, self._totalCt
end

function class:GetProgressPercentage()
	if self._totalCount == 0 then
		return 100
	end

	return self._loadedCount / self._totalCount * 100
end

function class:ListSounds()
	local result = {}

	for k, _ in pairs(self._sounds) do
		table.insert(result, k)
	end

	return result
end

function class:Remove(value: string): boolean
	assert(typeof(value) == "string", `'name' expected a string, got '{value}'`)

	if self._isLoaded then
		warn("Removing sounds after loading is complete is likely a bug")
		return false
	end

	if not self._sounds[value] then
		return false
	end

	self._sounds[value] = nil
	self._totalCt -= 1
	return true
end

function class:Clear()
	if self._isLoaded then
		warn("Attempting to clear sounds after loading is complete is likely a bug")
		return
	end

	self._sounds = {}
	self._totalCt = 0
	self._loadedCt = 0
end

function class:Destroy()
	if self._isLoaded then
		for _, sound2 in pairs(self._sounds) do
			if typeof(sound2) == "Instance" then
				sound2:Destroy()
			end
		end
	end

	for k, _ in pairs(self) do
		self[k] = nil
	end

	setmetatable(self, nil)
end

return SoundUtils