local MerchBooth = script:FindFirstAncestor("MerchBooth")

local t = require(MerchBooth.Packages.t)
local Cryo = require(MerchBooth.Packages.Cryo)
local Rodux = require(MerchBooth.Packages.Rodux)
local setConfig = require(MerchBooth.Actions.setConfig)
local resetConfig = require(MerchBooth.Actions.resetConfig)
local ParticleEmitter = MerchBooth.ParticleEmitter

local v = {
	backgroundColor = Color3.fromRGB(0, 0, 0),
	scrollBarColor = Color3.fromRGB(255, 255, 255),
	cornerRadius = UDim.new(0, 16),
	cornerRadiusSmall = UDim.new(0, 8),
	textSize = 14,
	textFont = Enum.Font.Gotham,
	textColor = Color3.fromRGB(255, 255, 255),
	secondaryTextColor = Color3.fromRGB(153, 153, 158),
	headerTextSize = 18,
	headerFont = Enum.Font.GothamMedium,
	titleTextSize = 28,
	titleFont = Enum.Font.GothamBold,
	buttonColor = Color3.fromRGB(255, 255, 255),
	buttonTextColor = Color3.fromRGB(0, 0, 0),
	secondaryButtonColor = Color3.fromRGB(34, 34, 34),
	secondaryButtonTextColor = Color3.fromRGB(255, 255, 255),
	inactiveButtonColor = Color3.fromRGB(153, 153, 158),
	inactiveButtonTextColor = Color3.fromRGB(255, 255, 255),
	proximityButtonActivationDistance = 10,
	proximityButtonExclusivity = Enum.ProximityPromptExclusivity.OnePerButton,
	proximityButtonOffset = Vector2.new(0, 0),
	proximityButtonRequiresLineOfSight = false,
	proximityButtonPulseCount = 3,
	particleEmitterTemplate = ParticleEmitter,
	useFilters = true,
	disableCharacterMovement = false,
	hideOtherUis = true,
	closeWhenFarFromPrompt = true
}

local strictInterface = t.strictInterface({
	backgroundColor = t.Color3,
	scrollBarColor = t.Color3,
	cornerRadius = t.UDim,
	cornerRadiusSmall = t.UDim,
	textSize = t.number,
	textFont = t.union(t.enum(Enum.Font), t.number),
	textColor = t.Color3,
	headerTextSize = t.number,
	headerFont = t.union(t.enum(Enum.Font), t.number),
	titleTextSize = t.number,
	titleFont = t.union(t.enum(Enum.Font), t.number),
	secondaryTextColor = t.Color3,
	buttonColor = t.Color3,
	buttonTextColor = t.Color3,
	secondaryButtonColor = t.Color3,
	secondaryButtonTextColor = t.Color3,
	inactiveButtonColor = t.Color3,
	inactiveButtonTextColor = t.Color3,
	proximityButtonActivationDistance = t.number,
	proximityButtonExclusivity = t.union(t.enum(Enum.ProximityPromptExclusivity), t.number),
	proximityButtonOffset = t.Vector2,
	proximityButtonRequiresLineOfSight = t.boolean,
	proximityButtonPulseCount = t.number,
	particleEmitterTemplate = t.instanceIsA("ParticleEmitter"),
	useFilters = t.boolean,
	disableCharacterMovement = t.boolean,
	hideOtherUis = t.boolean,
	closeWhenFarFromPrompt = t.boolean
})

return (Rodux.createReducer(v, {
	[setConfig.name] = function(p, p2)
		local joined = Cryo.Dictionary.join(p, p2.config)

		local v2, v3 = strictInterface(joined)
		assert(v2, "Bad configuration table passed to MerchBooth.configure: " .. (v3 or ""))

		return joined
	end,
	[resetConfig.name] = function()
		return v
	end
}))