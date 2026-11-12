local HttpService = game:GetService("HttpService")

local v = {
	"Reverb",
	"Equalizer",
	"Echo",
	"Chorus",
	"Flange",
	"Tremolo",
	"Distortion",
	"Compressor"
}

local set = {}
local SoundEffects = {}

for _, v2 in ipairs(v) do
	set[v2] = true
end

local v2 = {
	Reverb = {
		ClassName = "ReverbSoundEffect",
		Settings = {
			Decay = {
				Property = "DecayTime",
				Min = 0.1,
				Max = 20,
				Default = 1.5,
				Step = 0.1
			},
			Density = {
				Property = "Density",
				Min = 0,
				Max = 1,
				Default = 0.5,
				Step = 0.01
			},
			Diffusion = {
				Property = "Diffusion",
				Min = 0,
				Max = 1,
				Default = 0.75,
				Step = 0.01
			},
			Dry = {
				Property = "DryLevel",
				Min = -80,
				Max = 10,
				Default = 0,
				Step = 0.5
			},
			Wet = {
				Property = "WetLevel",
				Min = -80,
				Max = 10,
				Default = -12,
				Step = 0.5
			}
		}
	},
	Equalizer = {
		ClassName = "EqualizerSoundEffect",
		Settings = {
			High = {
				Property = "HighGain",
				Min = -20,
				Max = 10,
				Default = 0,
				Step = 0.5
			},
			Mid = {
				Property = "MidGain",
				Min = -20,
				Max = 10,
				Default = 0,
				Step = 0.5
			},
			Low = {
				Property = "LowGain",
				Min = -20,
				Max = 10,
				Default = 0,
				Step = 0.5
			}
		}
	},
	Echo = {
		ClassName = "EchoSoundEffect",
		Settings = {
			Delay = {
				Property = "Delay",
				Min = 0.01,
				Max = 5,
				Default = 0.25,
				Step = 0.01
			},
			Feedback = {
				Property = "Feedback",
				Min = 0,
				Max = 0.8,
				Default = 0.35,
				Step = 0.01
			},
			Dry = {
				Property = "DryLevel",
				Min = -80,
				Max = 10,
				Default = 0,
				Step = 0.5
			},
			Wet = {
				Property = "WetLevel",
				Min = -80,
				Max = 10,
				Default = -12,
				Step = 0.5
			}
		}
	},
	Chorus = {
		ClassName = "ChorusSoundEffect",
		Settings = {
			Depth = {
				Property = "Depth",
				Min = 0,
				Max = 1,
				Default = 0.35,
				Step = 0.01
			},
			Mix = {
				Property = "Mix",
				Min = 0,
				Max = 1,
				Default = 0.35,
				Step = 0.01
			},
			Rate = {
				Property = "Rate",
				Min = 0,
				Max = 20,
				Default = 1,
				Step = 0.1
			}
		}
	},
	Flange = {
		ClassName = "FlangeSoundEffect",
		Settings = {
			Depth = {
				Property = "Depth",
				Min = 0,
				Max = 1,
				Default = 0.35,
				Step = 0.01
			},
			Mix = {
				Property = "Mix",
				Min = 0,
				Max = 1,
				Default = 0.35,
				Step = 0.01
			},
			Rate = {
				Property = "Rate",
				Min = 0,
				Max = 20,
				Default = 1,
				Step = 0.1
			}
		}
	},
	Tremolo = {
		ClassName = "TremoloSoundEffect",
		Settings = {
			Depth = {
				Property = "Depth",
				Min = 0,
				Max = 1,
				Default = 0.45,
				Step = 0.01
			},
			Duty = {
				Property = "Duty",
				Min = 0,
				Max = 1,
				Default = 0.5,
				Step = 0.01
			},
			Frequency = {
				Property = "Frequency",
				Min = 0.1,
				Max = 20,
				Default = 4,
				Step = 0.1
			}
		}
	},
	Distortion = {
		ClassName = "DistortionSoundEffect",
		Settings = {
			Level = {
				Property = "Level",
				Min = 0,
				Max = 1,
				Default = 0.15,
				Step = 0.01
			}
		}
	},
	Compressor = {
		ClassName = "CompressorSoundEffect",
		Settings = {
			Threshold = {
				Property = "Threshold",
				Min = -80,
				Max = 0,
				Default = -18,
				Step = 1
			},
			Ratio = {
				Property = "Ratio",
				Min = 1,
				Max = 50,
				Default = 3,
				Step = 0.5
			},
			Gain = {
				Property = "GainMakeup",
				Min = -30,
				Max = 30,
				Default = 0,
				Step = 0.5
			}
		}
	}
}
local function deepCopy(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in pairs(items) do
		result[deepCopy(k)] = deepCopy(item)
	end

	return result
end

local function clampNumber(p, p2, min, max) -- 3 equivalent calls inferred from this helper
	local v3 = tonumber(p)

	if v3 then
		if v3 ~= v3 then
			v3 = p2
		end
	else
		v3 = p2
	end

	return (math.clamp(v3, min, max))
end

local function roundToStep(p, step) -- 3 equivalent calls inferred from this helper
	local v3 = tonumber(step) or 0

	if v3 <= 0 then
		return p
	end

	return math.floor(p / v3 + 0.5) * v3
end

local function getDefaultPresets()
	local defaultPresets = {}

	for _, v3 in ipairs(v) do
		defaultPresets[v3] = "Off"
	end

	return defaultPresets
end

local function getDefaultCustomEnabled() -- 1 equivalent call inferred from this helper
	local defaultCustomEnabled = {}

	for _, v3 in ipairs(v) do
		defaultCustomEnabled[v3] = false
	end

	return defaultCustomEnabled
end

local function getDefaultCustomValues()
	local defaultCustomValues = {}

	for _, v3 in ipairs(v) do
		defaultCustomValues[v3] = {}
		local v4 = v2[v3]

		if not (v4 and v4.Settings) then
			continue
		end

		for k, setting in pairs(v4.Settings) do
			defaultCustomValues[v3][k] = setting.Default
		end
	end

	return defaultCustomValues
end

local presets3 = {}

local v3 = {
	Version = 1,
	Power = false,
	SelectedEffect = "Reverb",
	Pitch = 1,
	Wet = 1,
	Presets = 0,
	CustomEnabled = 0,
	Custom = 0
}
local v4 = {
	Reverb = {
		Off = false,
		Room = {
			ClassName = "ReverbSoundEffect",
			Properties = {
				DecayTime = 1.2,
				Density = 0.45,
				Diffusion = 0.6,
				DryLevel = 0,
				WetLevel = -14
			}
		},
		Hall = {
			ClassName = "ReverbSoundEffect",
			Properties = {
				DecayTime = 2.4,
				Density = 0.7,
				Diffusion = 0.8,
				DryLevel = 0,
				WetLevel = -10
			}
		},
		Concert = {
			ClassName = "ReverbSoundEffect",
			Properties = {
				DecayTime = 3,
				Density = 0.85,
				Diffusion = 0.9,
				DryLevel = 0,
				WetLevel = -8
			}
		},
		Cave = {
			ClassName = "ReverbSoundEffect",
			Properties = {
				DecayTime = 5.5,
				Density = 0.9,
				Diffusion = 0.65,
				DryLevel = 0,
				WetLevel = -6
			}
		},
		Hangar = {
			ClassName = "ReverbSoundEffect",
			Properties = {
				DecayTime = 7.5,
				Density = 0.55,
				Diffusion = 0.85,
				DryLevel = 0,
				WetLevel = -5
			}
		}
	},
	Equalizer = {
		Off = false,
		Bright = {
			ClassName = "EqualizerSoundEffect",
			Properties = { HighGain = 4, MidGain = 1, LowGain = -1 }
		},
		Warm = {
			ClassName = "EqualizerSoundEffect",
			Properties = { HighGain = -1, MidGain = 0.5, LowGain = 4 }
		},
		Bass = {
			ClassName = "EqualizerSoundEffect",
			Properties = { HighGain = -3, MidGain = -1, LowGain = 8 }
		},
		Radio = {
			ClassName = "EqualizerSoundEffect",
			Properties = { HighGain = -8, MidGain = 4, LowGain = -8 }
		},
		Muffled = {
			ClassName = "EqualizerSoundEffect",
			Properties = { HighGain = -12, MidGain = -3, LowGain = 2 }
		}
	},
	Echo = {
		Off = false,
		Short = {
			ClassName = "EchoSoundEffect",
			Properties = { Delay = 0.12, Feedback = 0.25, DryLevel = 0, WetLevel = -14 }
		},
		Slow = {
			ClassName = "EchoSoundEffect",
			Properties = { Delay = 0.55, Feedback = 0.35, DryLevel = 0, WetLevel = -10 }
		},
		Fast = {
			ClassName = "EchoSoundEffect",
			Properties = { Delay = 0.18, Feedback = 0.5, DryLevel = 0, WetLevel = -9 }
		},
		Wide = {
			ClassName = "EchoSoundEffect",
			Properties = { Delay = 0.35, Feedback = 0.65, DryLevel = 0, WetLevel = -8 }
		}
	},
	Chorus = {
		Off = false,
		Soft = {
			ClassName = "ChorusSoundEffect",
			Properties = { Depth = 0.25, Mix = 0.25, Rate = 0.7 }
		},
		Dreamy = {
			ClassName = "ChorusSoundEffect",
			Properties = { Depth = 0.6, Mix = 0.45, Rate = 0.85 }
		},
		Thick = {
			ClassName = "ChorusSoundEffect",
			Properties = { Depth = 0.75, Mix = 0.65, Rate = 1.35 }
		},
		Vintage = {
			ClassName = "ChorusSoundEffect",
			Properties = { Depth = 0.4, Mix = 0.55, Rate = 0.35 }
		}
	},
	Flange = {
		Off = false,
		Light = {
			ClassName = "FlangeSoundEffect",
			Properties = { Depth = 0.25, Mix = 0.25, Rate = 0.8 }
		},
		Heavy = {
			ClassName = "FlangeSoundEffect",
			Properties = { Depth = 0.7, Mix = 0.65, Rate = 1.6 }
		},
		Metallic = {
			ClassName = "FlangeSoundEffect",
			Properties = { Depth = 0.95, Mix = 0.7, Rate = 2.5 }
		}
	},
	Tremolo = {
		Off = false,
		Pulse = {
			ClassName = "TremoloSoundEffect",
			Properties = { Depth = 0.45, Duty = 0.5, Frequency = 4 }
		},
		Slow = {
			ClassName = "TremoloSoundEffect",
			Properties = { Depth = 0.55, Duty = 0.5, Frequency = 0.8 }
		},
		Fast = {
			ClassName = "TremoloSoundEffect",
			Properties = { Depth = 0.7, Duty = 0.45, Frequency = 8 }
		}
	},
	Distortion = {
		Off = false,
		Light = {
			ClassName = "DistortionSoundEffect",
			Properties = { Level = 0.12 }
		},
		Crunch = {
			ClassName = "DistortionSoundEffect",
			Properties = { Level = 0.3 }
		},
		Broken = {
			ClassName = "DistortionSoundEffect",
			Properties = { Level = 0.55 }
		}
	},
	Compressor = {
		Off = false,
		Soft = {
			ClassName = "CompressorSoundEffect",
			Properties = {
				Attack = 0.01,
				Release = 0.18,
				Threshold = -18,
				Ratio = 2,
				GainMakeup = 1
			}
		},
		Tight = {
			ClassName = "CompressorSoundEffect",
			Properties = {
				Attack = 0.005,
				Release = 0.1,
				Threshold = -22,
				Ratio = 3,
				GainMakeup = 2
			}
		},
		Loud = {
			ClassName = "CompressorSoundEffect",
			Properties = {
				Attack = 0.003,
				Release = 0.08,
				Threshold = -26,
				Ratio = 5,
				GainMakeup = 4
			}
		}
	}
}

for _, v5 in ipairs(v) do
	presets3[v5] = "Off"
end

v3.Presets = presets3
v3.CustomEnabled = getDefaultCustomEnabled() -- inferred equivalent call
v3.Custom = getDefaultCustomValues()

local function isValidEffect(value): boolean -- 2 equivalent calls inferred from this helper
	return type(value) == "string" and set[value] == true
end

local function normalizePreset(p, value) -- 1 equivalent call inferred from this helper
	local v5 = v4[p]

	if not v5 then
		return "Off"
	end

	local v6 = tostring(value or "Off")
	return if v5[v6] == nil then "Off" else v6
end

local function normalizeCustom(p, p2)
	local v5 = v2[p]
	local custom = {}
	local v6 = type(p2) == "table" and p2 or {}

	if not v5 or type(v5.Settings) ~= "table" then
		return custom
	end

	for k, setting in pairs(v5.Settings) do
		custom[k] = roundToStep(clampNumber(v6[k], setting.Default, setting.Min, setting.Max), setting.Step) -- inferred equivalent call
	end

	return custom
end

local function trimWhitespace(value) -- 1 equivalent call inferred from this helper
	return tostring(value or ""):gsub("[%c]", " "):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s%s+", " ")
end

local function sanitizeUserPresetName(name) -- 1 equivalent call inferred from this helper
	local v5 = trimWhitespace(name) -- inferred equivalent call
	return (v5 == "" and "Untitled Preset" or v5):sub(1, 32)
end

local function sanitizeUserPresetId(id, p)
	local v5 = (tostring(id or ""):match("^%s*(.-)%s*$") or ""):gsub("[^%w_%-]", "")

	if v5 == "" then
		v5 = "preset_" .. tostring((math.max(1, (math.floor(tonumber(p) or 1)))))
	end

	return v5:sub(1, 64)
end

local function normalizeTimestamp(p, value) -- 2 equivalent calls inferred from this helper
	return (math.max(0, (math.floor(tonumber(p) or value or 0))))
end

function SoundEffects.GetDefaultState()
	return (deepCopy(v3))
end

function SoundEffects.GetEffectOrder()
	return (deepCopy(v))
end

function SoundEffects.GetCustomDefinitions(value)
	if isValidEffect(value) then -- inferred equivalent call
		return (deepCopy(v2[value]))
	end

	return nil
end

function SoundEffects.NormalizeState(p)
	local v5 = type(p) == "table" and p or {}
	local selectedEffect = tostring(v5.SelectedEffect or v3.SelectedEffect)

	if not isValidEffect(selectedEffect) then -- inferred equivalent call
		selectedEffect = v3.SelectedEffect
	end

	local state = {
		Version = 1,
		Power = v5.Power == true,
		SelectedEffect = selectedEffect,
		Pitch = roundToStep(clampNumber(v5.Pitch, v3.Pitch, 0.5, 2), 0.01), -- inferred equivalent call
		Wet = roundToStep(clampNumber(v5.Wet, v3.Wet, 0, 1), 0.01), -- inferred equivalent call
		Presets = {},
		CustomEnabled = {},
		Custom = {}
	}

	local presets = type(v5.Presets) == "table" and v5.Presets or {}
	local customEnabled = type(v5.CustomEnabled) == "table" and v5.CustomEnabled or {}
	local custom = type(v5.Custom) == "table" and v5.Custom or {}

	for _, v6 in ipairs(v) do
		local presets2 = state.Presets
		presets2[v6] = normalizePreset(v6, presets[v6]) -- inferred equivalent call
		state.CustomEnabled[v6] = customEnabled[v6] == true
		state.Custom[v6] = normalizeCustom(v6, custom[v6])
	end

	return state
end

function SoundEffects.GetUserPresetLimits()
	return { MaxPresets = 20, MaxNameLength = 32, MaxIdLength = 64, MaxExportLength = 12000 }
end

function SoundEffects.NormalizeUserPreset(data, p)
	if type(data) ~= "table" then
		return nil
	end

	local now = os.time()
	local state = data.State or data.SoundEffects or data.Effects or data
	local timestamp = normalizeTimestamp(data.CreatedAt or data.createdAt, now) -- inferred equivalent call
	local timestamp2 = normalizeTimestamp(data.UpdatedAt or data.updatedAt, timestamp) -- inferred equivalent call

	return {
		Version = 1,
		Id = sanitizeUserPresetId(data.Id or data.id, p),
		Name = sanitizeUserPresetName(data.Name or data.name), -- inferred equivalent call
		State = SoundEffects.NormalizeState(state),
		CreatedAt = timestamp,
		UpdatedAt = math.max(timestamp, timestamp2)
	}
end

function SoundEffects.CreateUserPreset(name, state)
	local now = os.time()
	return SoundEffects.NormalizeUserPreset({
		Id = HttpService:GenerateGUID(false),
		Name = name,
		State = state,
		CreatedAt = now,
		UpdatedAt = now
	}, 1)
end

function SoundEffects.NormalizeUserPresets(p)
	local v5 = type(p) == "table" and p or {}
	local userPresets = {}
	local set2 = {}

	for i, v6 in ipairs(v5) do
		if #userPresets >= 20 then
			break
		end

		local userPreset = SoundEffects.NormalizeUserPreset(v6, i)

		if not userPreset then
			continue
		end

		local id = userPreset.Id
		local id2 = id
		local v7 = 2

		while set2[id2] do
			id2 = (id .. "_" .. tostring(v7)):sub(1, 64)
			v7 += 1
		end

		userPreset.Id = id2
		set2[id2] = true
		table.insert(userPresets, userPreset)
	end

	return userPresets
end

function SoundEffects.EncodeUserPreset(p)
	local userPreset = SoundEffects.NormalizeUserPreset(p, 1)

	if not userPreset then
		return ""
	end

	local success, result = pcall(function()
		return HttpService:JSONEncode(userPreset)
	end)

	if success and type(result) == "string" and #result <= 12000 then
		return result
	end

	return ""
end

function SoundEffects.DecodeUserPreset(value)
	if type(value) == "table" then
		return SoundEffects.NormalizeUserPreset(value, 1)
	end

	if type(value) ~= "string" or value == "" or #value > 12000 then
		return nil
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(value)
	end)

	if success and type(result) == "table" then
		return SoundEffects.NormalizeUserPreset(result, 1)
	end

	return nil
end

function SoundEffects.EncodeState(p)
	local state = SoundEffects.NormalizeState(p)
	local success, result = pcall(function()
		return HttpService:JSONEncode(state)
	end)

	return if success and type(result) == "string" then result else "{}"
end

function SoundEffects.DecodeState(value)
	if type(value) == "table" then
		return SoundEffects.NormalizeState(value)
	end

	if type(value) ~= "string" or value == "" then
		return SoundEffects.GetDefaultState()
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(value)
	end)

	if success and type(result) == "table" then
		return SoundEffects.NormalizeState(result)
	end

	return SoundEffects.GetDefaultState()
end

local function copySpec(p, instance)
	if type(instance) == "table" then
		return {
			Name = "Piano" .. tostring(p),
			ClassName = instance.ClassName,
			Properties = deepCopy(instance.Properties or {})
		}
	end

	return nil
end

local function buildCustomSpec(p, p2)
	local v5 = v2[p]

	if not v5 then
		return nil
	end

	local properties = {}

	for k, v6 in pairs(v5.Settings or {}) do
		properties[v6.Property] = p2[k]
	end

	return {
		Name = "Piano" .. tostring(p),
		ClassName = v5.ClassName,
		Properties = properties
	}
end

local function applyWet(p, p2, wet)
	if not p2 or type(p2.Properties) ~= "table" or wet <= 0 then
		return nil
	end

	local properties = p2.Properties

	if properties.WetLevel ~= nil then
		properties.WetLevel = math.clamp((tonumber(properties.WetLevel) or 0) - (1 - wet) * 36, -80, 10)
	end

	if properties.Mix ~= nil then
		properties.Mix = math.clamp((tonumber(properties.Mix) or 0) * wet, 0, 1)
	end

	if p == "Tremolo" and properties.Depth ~= nil then
		properties.Depth = math.clamp((tonumber(properties.Depth) or 0) * wet, 0, 1)
	end

	if p == "Distortion" and properties.Level ~= nil then
		properties.Level = math.clamp((tonumber(properties.Level) or 0) * wet, 0, 1)
	end

	if p == "Equalizer" then
		properties.HighGain = (tonumber(properties.HighGain) or 0) * wet
		properties.MidGain = (tonumber(properties.MidGain) or 0) * wet
		properties.LowGain = (tonumber(properties.LowGain) or 0) * wet
	end

	if p == "Compressor" and properties.GainMakeup ~= nil then
		properties.GainMakeup = (tonumber(properties.GainMakeup) or 0) * wet
	end

	return p2
end

function SoundEffects.BuildSoundEffectSpecs(p)
	local state = SoundEffects.NormalizeState(p)
	local soundEffectSpecs = {}

	if state.Power ~= true then
		return soundEffectSpecs
	end

	for _, v5 in ipairs(v) do
		local v6

		if state.CustomEnabled[v5] == true then
			v6 = buildCustomSpec(v5, state.Custom[v5])
		else
			v6 = copySpec(v5, v4[v5] and v4[v5][state.Presets[v5]])
		end

		local v7 = applyWet(v5, v6, state.Wet)

		if v7 then
			table.insert(soundEffectSpecs, v7)
		end
	end

	if math.abs(state.Pitch - 1) > 0.001 then
		table.insert(soundEffectSpecs, {
			Name = "PianoPitch",
			ClassName = "PitchShiftSoundEffect",
			Properties = { Octave = state.Pitch }
		})
	end

	return soundEffectSpecs
end

return SoundEffects