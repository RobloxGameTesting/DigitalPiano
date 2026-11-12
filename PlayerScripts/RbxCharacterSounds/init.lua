local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AtomicBinding = require(script:WaitForChild("AtomicBinding"))

local function loadFlag(p: string)
	local success, result = pcall(function()
		return UserSettings():IsUserFeatureEnabled(p)
	end)

	return success and result
end

local v = {
	Climbing = { SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3", Looped = true },
	Died = { SoundId = "rbxasset://sounds/uuhhh.mp3" },
	FreeFalling = { SoundId = "rbxasset://sounds/action_falling.mp3", Looped = true },
	GettingUp = { SoundId = "rbxasset://sounds/action_get_up.mp3" },
	Jumping = { SoundId = "rbxasset://sounds/action_jump.mp3" },
	Landing = { SoundId = "rbxasset://sounds/action_jump_land.mp3" },
	Splash = { SoundId = "rbxasset://sounds/impact_water.mp3" },
	Swimming = { SoundId = "rbxasset://sounds/action_swim.mp3", Looped = true, Pitch = 1.6 }
}

local function map(y: number, p: number, p2: number, p3: number, p4: number) -- 2 equivalent calls inferred from this helper
	return (y - p) * (p4 - p3) / (p2 - p) + p3
end

local function playSound(p) -- 5 equivalent calls inferred from this helper
	p.TimePosition = 0
	p.Playing = true
end

local function shallowCopy(items) -- 1 equivalent call inferred from this helper
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local function initializeSoundSystem(data)
	local _player = data.player
	local humanoid = data.humanoid
	local rootPart = data.rootPart

	local v2 = {}

	for k, v3 in pairs(v) do
		local sound = Instance.new("Sound")
		sound.Name = k

		sound.Archivable = false
		sound.RollOffMinDistance = 5
		sound.RollOffMaxDistance = 150
		sound.Volume = 0.65

		for k2, v4 in pairs(v3) do
			sound[k2] = v4
		end

		sound.Parent = rootPart
		v2[k] = sound
	end

	local v3 = {}

	local function stopPlayingLoopedSounds(p) -- 10 equivalent calls inferred from this helper
		local result = shallowCopy(v3) -- inferred equivalent call

		for k in pairs(result) do
			if k == p then
				continue
			end

			k.Playing = false
			v3[k] = nil
		end
	end

	local v4 = {
		[Enum.HumanoidStateType.FallingDown] = function()
			stopPlayingLoopedSounds(nil) -- inferred equivalent call
		end,
		[Enum.HumanoidStateType.GettingUp] = function()
			stopPlayingLoopedSounds(nil) -- inferred equivalent call
			playSound(v2.GettingUp) -- inferred equivalent call
		end,
		[Enum.HumanoidStateType.Jumping] = function()
			stopPlayingLoopedSounds(nil) -- inferred equivalent call
			playSound(v2.Jumping) -- inferred equivalent call
		end,
		[Enum.HumanoidStateType.Swimming] = function()
			local y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if y > 0.1 then
				v2.Splash.Volume = math.clamp(map(y, 100, 350, 0.28, 1), 0, 1) -- inferred equivalent call
				playSound(v2.Splash) -- inferred equivalent call
			end

			stopPlayingLoopedSounds(v2.Swimming) -- inferred equivalent call
			v2.Swimming.Playing = true
			v3[v2.Swimming] = true
		end,
		[Enum.HumanoidStateType.Freefall] = function()
			v2.FreeFalling.Volume = 0
			stopPlayingLoopedSounds(v2.FreeFalling) -- inferred equivalent call
			v3[v2.FreeFalling] = true
		end,
		[Enum.HumanoidStateType.Landed] = function()
			stopPlayingLoopedSounds(nil) -- inferred equivalent call
			local y = math.abs(rootPart.AssemblyLinearVelocity.Y)

			if y > 75 then
				v2.Landing.Volume = math.clamp(map(y, 50, 100, 0, 1), 0, 1) -- inferred equivalent call
				playSound(v2.Landing) -- inferred equivalent call
			end
		end,
		[Enum.HumanoidStateType.Climbing] = function()
			local climbing = v2.Climbing

			if math.abs(rootPart.AssemblyLinearVelocity.Y) > 0.1 then
				climbing.Playing = true
				stopPlayingLoopedSounds(climbing) -- inferred equivalent call
			else
				stopPlayingLoopedSounds(nil) -- inferred equivalent call
			end

			v3[climbing] = true
		end,
		[Enum.HumanoidStateType.Seated] = function()
			stopPlayingLoopedSounds(nil) -- inferred equivalent call
		end,
		[Enum.HumanoidStateType.Dead] = function()
			stopPlayingLoopedSounds(nil) -- inferred equivalent call
			playSound(v2.Died) -- inferred equivalent call
		end
	}

	local v5 = {
		[v2.Climbing] = function(_: number, p, vector3: Vector3)
			p.Playing = vector3.Magnitude > 0.1
		end,
		[v2.FreeFalling] = function(p: number, p2, vector3: Vector3)
			if vector3.Magnitude > 75 then
				p2.Volume = math.clamp(p2.Volume + p * 0.9, 0, 1)
			else
				p2.Volume = 0
			end
		end
	}

	local runningsByRunningNoPhysics = {
		[Enum.HumanoidStateType.RunningNoPhysics] = Enum.HumanoidStateType.Running
	}

	local v6 = runningsByRunningNoPhysics[humanoid:GetState()] or humanoid:GetState()

	local function transitionTo(p) -- 2 equivalent calls inferred from this helper
		local v7 = v4[p]

		if v7 then
			v7()
		end

		v6 = p
	end

	transitionTo(v6) -- inferred equivalent call
	local stateChangedConnection = humanoid.StateChanged:Connect(function(_, p)
		local v7 = runningsByRunningNoPhysics[p] or p

		if v7 ~= v6 then
			transitionTo(v7) -- inferred equivalent call
		end
	end)

	local steppedConnection = RunService.Stepped:Connect(function(_, dt: number)
		for k in pairs(v3) do
			local v7 = v5[k]

			if v7 then
				v7(dt, k, rootPart.AssemblyLinearVelocity)
			end
		end
	end)

	local function terminate()
		stateChangedConnection:Disconnect()
		steppedConnection:Disconnect()

		for _, v7 in pairs(v2) do
			v7:Destroy()
		end

		table.clear(v2)
	end

	return terminate
end

local v2 = AtomicBinding.new({ humanoid = "Humanoid", rootPart = "HumanoidRootPart" }, initializeSoundSystem)

local v3 = {}

local function characterAdded(character) -- 1 equivalent call inferred from this helper
	v2:bindRoot(character)
end

local function characterRemoving(character) -- 1 equivalent call inferred from this helper
	v2:unbindRoot(character)
end

local function playerAdded(player)
	local connections = v3[player]

	if not connections then
		connections = {}
		v3[player] = connections
	end

	if player.Character then
		characterAdded(player.Character) -- inferred equivalent call
	end

	table.insert(connections, player.CharacterAdded:Connect(characterAdded))
	table.insert(connections, player.CharacterRemoving:Connect(characterRemoving))
end

local function playerRemoving(player)
	local v4 = v3[player]

	if v4 then
		for _, connection in ipairs(v4) do
			connection:Disconnect()
		end

		v3[player] = nil
	end

	if player.Character then
		characterRemoving(player.Character) -- inferred equivalent call
	end
end

for _, v4 in ipairs(Players:GetPlayers()) do
	task.spawn(playerAdded, v4)
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)