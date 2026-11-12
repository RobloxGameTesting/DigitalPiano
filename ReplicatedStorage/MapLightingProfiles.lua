local MapLightingProfiles = {}

local function c(p, p2, p3) -- 80 equivalent calls inferred from this helper
	return Color3.fromRGB(p, p2, p3)
end

local function profile(p)
	return p
end

MapLightingProfiles.Default = {
	Lighting = {
		Ambient = c(46, 50, 61), -- inferred equivalent call
		Brightness = 2.4,
		ColorShift_Bottom = c(0, 0, 0), -- inferred equivalent call
		ColorShift_Top = c(255, 244, 229), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(78, 84, 95), -- inferred equivalent call
		ShadowSoftness = 0.35,
		ClockTime = 18.2,
		ExposureCompensation = 0.05,
		FogColor = c(194, 210, 235), -- inferred equivalent call
		FogStart = 90,
		FogEnd = 760
	},
	Atmosphere = {
		Density = 0.36,
		Offset = 0.18,
		Color = c(197, 226, 240), -- inferred equivalent call
		Decay = c(156, 123, 205), -- inferred equivalent call
		Glare = 0.12,
		Haze = 1.45
	},
	Bloom = { Enabled = true, Intensity = 0.22, Size = 28, Threshold = 1.35 },
	SunRays = { Enabled = true, Intensity = 0.035, Spread = 0.75 },
	ColorCorrection = {
		Enabled = true,
		Brightness = 0.015,
		Contrast = 0.025,
		Saturation = 0.06,
		TintColor = c(255, 248, 238) -- inferred equivalent call
	}
}

local default = MapLightingProfiles.Default
local v = {
	Lighting = {
		Ambient = c(58, 58, 66), -- inferred equivalent call
		Brightness = 2.15,
		ColorShift_Bottom = c(0, 0, 0), -- inferred equivalent call
		ColorShift_Top = c(244, 241, 232), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(82, 82, 88), -- inferred equivalent call
		ShadowSoftness = 0.45,
		ClockTime = 12.2,
		ExposureCompensation = 0.02,
		FogColor = c(210, 212, 218), -- inferred equivalent call
		FogStart = 110,
		FogEnd = 900
	},
	Atmosphere = {
		Density = 0.28,
		Offset = 0.08,
		Color = c(225, 226, 232), -- inferred equivalent call
		Decay = c(156, 160, 172), -- inferred equivalent call
		Glare = 0.04,
		Haze = 0.9
	},
	Bloom = { Enabled = true, Intensity = 0.14, Size = 24, Threshold = 1.55 },
	SunRays = { Enabled = true, Intensity = 0.018, Spread = 0.7 },
	ColorCorrection = {
		Enabled = true,
		Brightness = 0,
		Contrast = 0.02,
		Saturation = 0.02,
		TintColor = c(255, 255, 250) -- inferred equivalent call
	}
}

local v2 = {
	Lighting = {
		Ambient = c(82, 105, 132), -- inferred equivalent call
		Brightness = 2.05,
		ColorShift_Bottom = c(12, 22, 36), -- inferred equivalent call
		ColorShift_Top = c(196, 226, 255), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(112, 134, 156), -- inferred equivalent call
		ShadowSoftness = 0.28,
		ClockTime = 10.1,
		ExposureCompensation = 0.04,
		FogColor = c(210, 232, 245), -- inferred equivalent call
		FogStart = 60,
		FogEnd = 560
	},
	Atmosphere = {
		Density = 0.42,
		Offset = 0.12,
		Color = c(214, 238, 250), -- inferred equivalent call
		Decay = c(115, 150, 190), -- inferred equivalent call
		Glare = 0.06,
		Haze = 2
	},
	Bloom = { Enabled = true, Intensity = 0.18, Size = 30, Threshold = 1.45 },
	SunRays = { Enabled = true, Intensity = 0.02, Spread = 0.9 },
	ColorCorrection = {
		Enabled = true,
		Brightness = 0.005,
		Contrast = 0.04,
		Saturation = 0.04,
		TintColor = c(232, 246, 255) -- inferred equivalent call
	}
}

local v3 = {
	Lighting = {
		Ambient = c(116, 82, 64), -- inferred equivalent call
		Brightness = 2.2,
		ColorShift_Bottom = c(55, 32, 24), -- inferred equivalent call
		ColorShift_Top = c(255, 184, 118), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(111, 80, 66), -- inferred equivalent call
		ShadowSoftness = 0.55,
		ClockTime = 16.65,
		ExposureCompensation = 0.04,
		FogColor = c(255, 202, 154), -- inferred equivalent call
		FogStart = 80,
		FogEnd = 680
	},
	Atmosphere = {
		Density = 0.38,
		Offset = 0.1,
		Color = c(255, 210, 164), -- inferred equivalent call
		Decay = c(172, 93, 92), -- inferred equivalent call
		Glare = 0.18,
		Haze = 1.5
	},
	Bloom = { Enabled = true, Intensity = 0.2, Size = 30, Threshold = 1.35 },
	SunRays = { Enabled = true, Intensity = 0.04, Spread = 0.82 },
	ColorCorrection = {
		Enabled = true,
		Brightness = 0.015,
		Contrast = 0.035,
		Saturation = 0.09,
		TintColor = c(255, 232, 207) -- inferred equivalent call
	}
}

local v4 = {
	Lighting = {
		Ambient = c(112, 94, 132), -- inferred equivalent call
		Brightness = 2.15,
		ColorShift_Bottom = c(32, 20, 42), -- inferred equivalent call
		ColorShift_Top = c(255, 204, 229), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(135, 113, 146), -- inferred equivalent call
		ShadowSoftness = 0.42,
		ClockTime = 8.6,
		ExposureCompensation = 0.03,
		FogColor = c(255, 216, 234), -- inferred equivalent call
		FogStart = 70,
		FogEnd = 620
	},
	Atmosphere = {
		Density = 0.4,
		Offset = 0.14,
		Color = c(255, 222, 238), -- inferred equivalent call
		Decay = c(177, 132, 205), -- inferred equivalent call
		Glare = 0.1,
		Haze = 1.85
	},
	Bloom = { Enabled = true, Intensity = 0.24, Size = 32, Threshold = 1.3 },
	SunRays = { Enabled = true, Intensity = 0.028, Spread = 0.86 },
	ColorCorrection = {
		Enabled = true,
		Brightness = 0.012,
		Contrast = 0.02,
		Saturation = 0.08,
		TintColor = c(255, 235, 246) -- inferred equivalent call
	}
}

local v5 = {
	Lighting = {
		Ambient = c(78, 112, 128), -- inferred equivalent call
		Brightness = 2.55,
		ColorShift_Bottom = c(0, 25, 34), -- inferred equivalent call
		ColorShift_Top = c(255, 239, 196), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(104, 139, 146), -- inferred equivalent call
		ShadowSoftness = 0.32,
		ClockTime = 13.2,
		ExposureCompensation = 0.03,
		FogColor = c(199, 239, 242), -- inferred equivalent call
		FogStart = 120,
		FogEnd = 850
	},
	Atmosphere = {
		Density = 0.26,
		Offset = 0.12,
		Color = c(199, 239, 242), -- inferred equivalent call
		Decay = c(88, 165, 181), -- inferred equivalent call
		Glare = 0.18,
		Haze = 0.9
	},
	Bloom = { Enabled = true, Intensity = 0.18, Size = 28, Threshold = 1.42 },
	SunRays = { Enabled = true, Intensity = 0.045, Spread = 0.65 },
	ColorCorrection = {
		Enabled = true,
		Brightness = 0.01,
		Contrast = 0.025,
		Saturation = 0.1,
		TintColor = c(247, 255, 244) -- inferred equivalent call
	}
}

local rainfall = {
	Lighting = {
		Ambient = c(57, 69, 82), -- inferred equivalent call
		Brightness = 1.25,
		ColorShift_Bottom = c(11, 16, 23), -- inferred equivalent call
		ColorShift_Top = c(122, 145, 170), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(64, 78, 92), -- inferred equivalent call
		ShadowSoftness = 0.65,
		ClockTime = 11,
		ExposureCompensation = -0.03,
		FogColor = c(128, 145, 160), -- inferred equivalent call
		FogStart = 55,
		FogEnd = 360
	},
	Atmosphere = {
		Density = 0.52,
		Offset = 0.04,
		Color = c(142, 158, 174), -- inferred equivalent call
		Decay = c(68, 82, 98), -- inferred equivalent call
		Glare = 0.02,
		Haze = 2.5
	},
	Bloom = { Enabled = true, Intensity = 0.08, Size = 20, Threshold = 1.8 },
	SunRays = { Enabled = false, Intensity = 0, Spread = 0.55 },
	ColorCorrection = {
		Enabled = true,
		Brightness = -0.015,
		Contrast = 0.02,
		Saturation = -0.08,
		TintColor = c(222, 233, 244) -- inferred equivalent call
	}
}

local gaster = {
	Lighting = {
		Ambient = c(18, 18, 27), -- inferred equivalent call
		Brightness = 0.85,
		ColorShift_Bottom = c(0, 0, 0), -- inferred equivalent call
		ColorShift_Top = c(76, 88, 130), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(20, 24, 34), -- inferred equivalent call
		ShadowSoftness = 0.75,
		ClockTime = 0.2,
		ExposureCompensation = -0.08,
		FogColor = c(13, 15, 25), -- inferred equivalent call
		FogStart = 25,
		FogEnd = 230
	},
	Atmosphere = {
		Density = 0.58,
		Offset = 0.02,
		Color = c(44, 48, 72), -- inferred equivalent call
		Decay = c(8, 10, 18), -- inferred equivalent call
		Glare = 0,
		Haze = 2.6
	},
	Bloom = { Enabled = true, Intensity = 0.16, Size = 25, Threshold = 1.65 },
	SunRays = { Enabled = false, Intensity = 0, Spread = 0.5 },
	ColorCorrection = {
		Enabled = true,
		Brightness = -0.025,
		Contrast = 0.06,
		Saturation = -0.12,
		TintColor = c(205, 215, 255) -- inferred equivalent call
	}
}

local v6 = {
	Lighting = {
		Ambient = c(28, 32, 52), -- inferred equivalent call
		Brightness = 1.35,
		ColorShift_Bottom = c(0, 0, 0), -- inferred equivalent call
		ColorShift_Top = c(86, 197, 255), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(32, 36, 56), -- inferred equivalent call
		ShadowSoftness = 0.5,
		ClockTime = 19.4,
		ExposureCompensation = 0,
		FogColor = c(24, 28, 48), -- inferred equivalent call
		FogStart = 70,
		FogEnd = 520
	},
	Atmosphere = {
		Density = 0.36,
		Offset = 0.08,
		Color = c(72, 104, 150), -- inferred equivalent call
		Decay = c(36, 25, 74), -- inferred equivalent call
		Glare = 0.05,
		Haze = 1.4
	},
	Bloom = { Enabled = true, Intensity = 0.42, Size = 36, Threshold = 1.08 },
	SunRays = { Enabled = false, Intensity = 0, Spread = 0.5 },
	ColorCorrection = {
		Enabled = true,
		Brightness = 0.005,
		Contrast = 0.08,
		Saturation = 0.2,
		TintColor = c(230, 242, 255) -- inferred equivalent call
	}
}

local v7 = {
	Lighting = {
		Ambient = c(72, 100, 70), -- inferred equivalent call
		Brightness = 2,
		ColorShift_Bottom = c(18, 40, 22), -- inferred equivalent call
		ColorShift_Top = c(204, 255, 172), -- inferred equivalent call
		GlobalShadows = true,
		OutdoorAmbient = c(74, 104, 78), -- inferred equivalent call
		ShadowSoftness = 0.38,
		ClockTime = 10.7,
		ExposureCompensation = 0.02,
		FogColor = c(201, 230, 190), -- inferred equivalent call
		FogStart = 75,
		FogEnd = 630
	},
	Atmosphere = {
		Density = 0.38,
		Offset = 0.1,
		Color = c(214, 239, 198), -- inferred equivalent call
		Decay = c(78, 123, 82), -- inferred equivalent call
		Glare = 0.06,
		Haze = 1.55
	},
	Bloom = { Enabled = true, Intensity = 0.18, Size = 30, Threshold = 1.45 },
	SunRays = { Enabled = true, Intensity = 0.03, Spread = 0.78 },
	ColorCorrection = {
		Enabled = true,
		Brightness = 0.008,
		Contrast = 0.025,
		Saturation = 0.08,
		TintColor = c(239, 255, 232) -- inferred equivalent call
	}
}

MapLightingProfiles.ById = {
	lobby = default,
	auditorium = v,
	competition = v,
	credits = v,
	ivory = v,
	pianopiano = v,
	tylerspiano = v,
	duet = v,
	["duck-duet"] = v3,
	duetcylinder = v4,
	icefishing = v2,
	alpinemelody = v2,
	snowfall = v2,
	autumn = v3,
	sunset = v3,
	musicbox = v3,
	blossom = v4,
	bubblegum = v3,
	cat = v4,
	beach = v5,
	["lakeside-piano"] = v5,
	rainfall = rainfall,
	gaster = gaster,
	leaf = v7,
	saintpatrick = v7,
	musictheory = v7,
	barsynth = v6,
	["c-synth"] = v6,
	["com-keys"] = v6,
	comet = v6,
	synthesia = v6,
	["wavev-2"] = v6,
	abstract = v6
}

function MapLightingProfiles.Get(value)
	local lower = tostring(value or ""):lower()
	return MapLightingProfiles.ById[lower] or MapLightingProfiles.Default
end

return MapLightingProfiles