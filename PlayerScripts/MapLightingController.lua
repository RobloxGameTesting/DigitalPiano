local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local MapLightingProfiles = require(ReplicatedStorage2:WaitForChild("MapLightingProfiles"))
local MapElevatorTeleportResult = ReplicatedStorage2:WaitForChild("MapElevatorTeleportResult")

local tweenInfo = TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {}
local v2 = nil

local v3 = { FogStart = 0, FogEnd = 1000000 }

local v4 = { Density = 0, Offset = 0, Glare = 0, Haze = 0 }

local v5 = {
	Bloom = { ClassName = "BloomEffect", PreferredName = "Bloom" },
	SunRays = { ClassName = "SunRaysEffect", PreferredName = "SunRays" },
	Atmosphere = { ClassName = "Atmosphere", PreferredName = "Atmosphere" },
	DepthOfField = { ClassName = "DepthOfFieldEffect", PreferredName = "DepthOfField" },
	ColorCorrection = {
		ClassName = "ColorCorrectionEffect",
		PreferredName = "MapElevatorColorCorrection"
	}
}

local function getLightingEffects(className, preferredName)
	local lightingEffects = {}
	local child = Lighting:FindFirstChild(preferredName)

	if child and child:IsA(className) then
		table.insert(lightingEffects, child)
	end

	for _, child2 in ipairs(Lighting:GetChildren()) do
		if child2:IsA(className) and child2 ~= child then
			table.insert(lightingEffects, child2)
		end
	end

	if #lightingEffects ~= 0 then
		return lightingEffects
	end

	local instance = Instance.new(className)
	instance.Name = preferredName
	instance.Parent = Lighting
	table.insert(lightingEffects, instance)

	return lightingEffects
end

local v6 = { Enabled = false, FarIntensity = 0, NearIntensity = 0 }

local function cancelTween(instance) -- 1 equivalent call inferred from this helper
	local v7 = v[instance]

	if v7 then
		v7:Cancel()
		v[instance] = nil
	end
end

local function applyProperties(instance, items, p)
	if not (instance and items) then
		return
	end

	cancelTween(instance) -- inferred equivalent call
	local v7 = {}

	for k, item in pairs(items) do
		local success, result = pcall(function()
			return instance[k]
		end)

		if not (success and typeof(result) == typeof(item)) then
			continue
		end

		if typeof(item) == "number" or typeof(item) == "Color3" or typeof(item) == "Vector3" then
			v7[k] = item
		else
			pcall(function()
				instance[k] = item
			end)
		end
	end

	if next(v7) then
		if p then
			for k, v8 in pairs(v7) do
				pcall(function()
					instance[k] = v8
				end)
			end
		else
			local tween = TweenService:Create(instance, tweenInfo, v7)
			v[instance] = tween
			tween.Completed:Connect(function()
				if v[instance] == tween then
					v[instance] = nil
				end
			end)
			tween:Play()
		end
	end
end

local function applyEffectProperties(instance, p, p2)
	for _, v7 in ipairs(getLightingEffects(instance.ClassName, instance.PreferredName)) do
		applyProperties(v7, p, p2)
	end
end

local function mapAtmosphereEnabled(): boolean -- 1 equivalent call inferred from this helper
	return LocalPlayer:GetAttribute("MapAtmosphereEnabled") == true
end

local function customLightingEnabled(): boolean -- 2 equivalent calls inferred from this helper
	return LocalPlayer:GetAttribute("CustomLightingEnabled") == true
end

local function getDestinationFallback()
	return v2 or LocalPlayer:GetAttribute("MapElevatorLastDestination") or "lobby"
end

local CustomLightingChanged = ReplicatedStorage2:FindFirstChild("CustomLightingChanged")

if not CustomLightingChanged then
	CustomLightingChanged = Instance.new("BindableEvent")
	CustomLightingChanged.Name = "CustomLightingChanged"
	CustomLightingChanged.Parent = ReplicatedStorage2
end

local function applyDestinationLighting(p, p2)
	v2 = p

	if customLightingEnabled() then -- inferred equivalent call
		return
	end

	local v7 = MapLightingProfiles.Get(p)
	applyProperties(Lighting, v7.Lighting, p2)

	if mapAtmosphereEnabled() then -- inferred equivalent call
		applyEffectProperties(v5.Atmosphere, v7.Atmosphere, p2)
	else
		applyProperties(Lighting, v3, p2)
		applyEffectProperties(v5.Atmosphere, v4, p2)
	end

	applyEffectProperties(v5.DepthOfField, v6, p2)
	applyEffectProperties(v5.Bloom, v7.Bloom, p2)
	applyEffectProperties(v5.SunRays, v7.SunRays, p2)
	applyEffectProperties(v5.ColorCorrection, v7.ColorCorrection, p2)
end

MapElevatorTeleportResult.OnClientEvent:Connect(function(p, _, p2)
	if p and p2 then
		applyDestinationLighting(p2, false)
	end
end)

LocalPlayer.CharacterAdded:Connect(function()
	task.delay(0.25, function()
		applyDestinationLighting("lobby", false)
	end)
end)

LocalPlayer:GetAttributeChangedSignal("MapAtmosphereEnabled"):Connect(function()
	applyDestinationLighting(v2 or LocalPlayer:GetAttribute("MapElevatorLastDestination") or "lobby", false)
end)

LocalPlayer:GetAttributeChangedSignal("CustomLightingEnabled"):Connect(function()
	if not customLightingEnabled() then -- inferred equivalent call
		applyDestinationLighting(v2 or LocalPlayer:GetAttribute("MapElevatorLastDestination") or "lobby", false)
	end
end)

CustomLightingChanged.Event:Connect(function(p)
	if p ~= true then
		applyDestinationLighting(v2 or LocalPlayer:GetAttribute("MapElevatorLastDestination") or "lobby", false)
	end
end)

applyDestinationLighting(LocalPlayer:GetAttribute("MapElevatorLastDestination") or "lobby", true)

ClientDebugConfig.Print("[MapLightingController] Initialized")