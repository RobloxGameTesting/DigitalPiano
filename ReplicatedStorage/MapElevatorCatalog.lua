local Workspace = game:GetService("Workspace")

local MapElevatorCatalog = {}

local v = {
	Lobby = {
		title = "Lobby",
		subtitle = "The main game lobby and elevator hub.",
		category = "Featured",
		icon = "LB",
		color = Color3.fromRGB(120, 210, 255),
		previewName = "Lobby",
		featured = true
	},
	Abstract = {
		title = "Abstract Piano",
		subtitle = "A randomized abstract piano space.",
		category = "Visual",
		icon = "AB",
		color = Color3.fromRGB(251, 113, 133),
		previewName = "Abstract"
	},
	Auditorium = {
		title = "Piano Auditorium",
		subtitle = "Practice songs with friends or compose your own music.",
		category = "Featured",
		icon = "AU",
		color = Color3.fromRGB(120, 210, 255),
		previewName = "PAuditorium",
		featured = true
	},
	Autumn = {
		title = "Autumn Piano",
		subtitle = "A warm fall-themed piano map.",
		category = "Featured",
		icon = "AU",
		color = Color3.fromRGB(251, 146, 60),
		previewName = "Autumn"
	},
	AlpineMelody = {
		title = "Yet Another Low Poly",
		subtitle = "A piano nestled among snow-dusted peaks.",
		category = "Featured",
		icon = "AM",
		color = Color3.fromRGB(147, 197, 253),
		previewName = "AlpineMelody",
		featured = true
	},
	Beach = {
		title = "Beach Piano",
		subtitle = "A relaxing seaside piano atmosphere.",
		category = "Featured",
		icon = "BE",
		color = Color3.fromRGB(45, 212, 191),
		previewName = "Beach"
	},
	Blossom = {
		title = "Blossom Piano",
		subtitle = "A cherry blossom piano map.",
		category = "Featured",
		icon = "BL",
		color = Color3.fromRGB(244, 114, 182),
		previewName = "Blossom"
	},
	Bubblegum = {
		title = "Bubblegum Piano",
		subtitle = "A bright bubblegum themed piano.",
		category = "Featured",
		icon = "BG",
		color = Color3.fromRGB(244, 114, 182),
		previewName = "Bubblegum"
	},
	["C.Synth"] = {
		title = "Circle Synthesizer",
		subtitle = "An electronic visualizer-style piano.",
		category = "Visual",
		icon = "CS",
		color = Color3.fromRGB(168, 85, 247),
		previewName = "Synth"
	},
	Cat = {
		title = "Cat Piano",
		subtitle = "Cats bob along to your tune.",
		category = "Featured",
		icon = "CT",
		color = Color3.fromRGB(244, 114, 182),
		previewName = "CatPiano"
	},
	["Com.Keys"] = {
		title = "Computer Keys",
		subtitle = "A keyboard-themed visual piano.",
		category = "Visual",
		icon = "CK",
		color = Color3.fromRGB(96, 165, 250),
		previewName = "ComKeys"
	},
	Comet = {
		title = "Comet Piano",
		subtitle = "A meteor shower-themed piano.",
		category = "Visual",
		icon = "CM",
		color = Color3.fromRGB(251, 191, 36),
		previewName = "Comet"
	},
	Competition = {
		title = "Competition Piano",
		subtitle = "Head-to-head performance piano area.",
		category = "Featured",
		icon = "CP",
		color = Color3.fromRGB(248, 113, 113),
		previewName = "Competition"
	},
	Credits = {
		title = "Credits and Appreciation",
		subtitle = "Developer credits and appreciation area.",
		category = "Featured",
		icon = "CR",
		color = Color3.fromRGB(203, 213, 225),
		previewName = "Credits"
	},
	["Duck Duet"] = {
		title = "Duck Duet",
		subtitle = "A cheerful warm yellow duet room.",
		category = "Classic",
		icon = "DD",
		color = Color3.fromRGB(250, 204, 21),
		previewName = "DuckDuet"
	},
	Duet = {
		title = "Duet Pianos",
		subtitle = "Play in parallel with a partner.",
		category = "Classic",
		icon = "DU",
		color = Color3.fromRGB(196, 181, 253),
		previewName = "Duet"
	},
	DuetCylinder = {
		title = "Duet Cylinder Pianos",
		subtitle = "Pink and blue duet cylinder pianos.",
		category = "Classic",
		icon = "DC",
		color = Color3.fromRGB(244, 114, 182),
		previewName = "DuetC"
	},
	SaintPatrick = {
		title = "Paddy's Day",
		subtitle = "Clovers, gold, and Irish charm.",
		category = "Featured",
		icon = "SP",
		color = Color3.fromRGB(52, 211, 153),
		previewName = "SaintPatrick"
	},
	Gaster = {
		title = "Gaster",
		subtitle = "A dark themed piano map.",
		category = "Featured",
		icon = "GA",
		color = Color3.fromRGB(156, 163, 175),
		previewName = "Gaster"
	},
	Ivory = {
		title = "Ivory Piano",
		subtitle = "A classic upright piano.",
		category = "Classic",
		icon = "IV",
		color = Color3.fromRGB(226, 232, 240),
		previewName = "Ivory"
	},
	["LakeSide Piano"] = {
		title = "LakeSide Piano",
		subtitle = "Outdoor piano near a lake.",
		category = "Featured",
		icon = "LS",
		color = Color3.fromRGB(125, 211, 252),
		previewName = "LakeSide"
	},
	Leaf = {
		title = "Leaf Piano",
		subtitle = "A leaf-themed piano map.",
		category = "Featured",
		icon = "LF",
		color = Color3.fromRGB(163, 230, 53),
		previewName = "Leaf"
	},
	MusicTheory = {
		title = "Music Theory",
		subtitle = "A digital staff inspired piano space.",
		category = "Featured",
		icon = "MT",
		color = Color3.fromRGB(52, 211, 153),
		previewName = "Theory"
	},
	Rainfall = {
		title = "Rainfall Piano",
		subtitle = "A rainy spring themed piano.",
		category = "Featured",
		icon = "RF",
		color = Color3.fromRGB(96, 165, 250),
		previewName = "Rainfall"
	},
	Sunset = {
		title = "Sunset Piano",
		subtitle = "Japanese themed sunset piano.",
		category = "Featured",
		icon = "SS",
		color = Color3.fromRGB(251, 146, 60),
		previewName = "SunsetPiano"
	},
	Snowfall = {
		title = "Snowfall Piano",
		subtitle = "A snowy particle themed piano.",
		category = "Featured",
		icon = "SN",
		color = Color3.fromRGB(186, 230, 253),
		previewName = "Snow"
	},
	Synthesia = {
		title = "Synthesia",
		subtitle = "Classic visualizer piano map.",
		category = "Visual",
		icon = "SY",
		color = Color3.fromRGB(120, 210, 255),
		previewName = "Synthesia"
	},
	TylersPiano = {
		title = "Tyler's Piano",
		subtitle = "A classic upright piano.",
		category = "Classic",
		icon = "TY",
		color = Color3.fromRGB(203, 213, 225),
		previewName = "Upright"
	},
	["WaveV.2"] = {
		title = "Wave Piano V2",
		subtitle = "Wave themed visual piano.",
		category = "Visual",
		icon = "WV",
		color = Color3.fromRGB(94, 234, 212),
		previewName = "Wave"
	},
	MusicBox = {
		title = "Music Box",
		subtitle = "A self-winding music box piano.",
		category = "Visual",
		icon = "MB",
		color = Color3.fromRGB(250, 204, 21),
		previewName = "MusicBox"
	},
	BarSynth = {
		title = "Bar Synthesizer",
		subtitle = "A flat bar-style visualizer piano.",
		category = "Visual",
		icon = "BS",
		color = Color3.fromRGB(251, 191, 36),
		previewName = "BarSynth"
	},
	["SynthesiaV.2"] = {
		title = "Synthesia V2",
		subtitle = "Large visual piano stage for performance playback.",
		category = "Featured",
		icon = "S2",
		color = Color3.fromRGB(120, 210, 255),
		previewName = "Synthesia",
		featured = true
	},
	WaveV2Piano = {
		title = "Wave V2",
		subtitle = "Wave themed piano map with an elevated stage.",
		category = "Featured",
		icon = "WV",
		color = Color3.fromRGB(94, 234, 212),
		previewName = "Wave",
		featured = true
	},
	SheetPiano = {
		title = "Sheet Piano",
		subtitle = "Sheet-focused piano area for practicing scripts.",
		category = "Featured",
		icon = "SH",
		color = Color3.fromRGB(52, 211, 153),
		previewName = "Theory",
		featured = true
	},
	IceFishing = {
		title = "Ice Fishing",
		subtitle = "Cold themed map with multiple pianos.",
		category = "Featured",
		icon = "IF",
		color = Color3.fromRGB(147, 197, 253),
		previewName = "IceFishing",
		featured = true
	},
	BarVisualizer = {
		title = "Bar Visualizer",
		subtitle = "Visualizer stage for high-energy performances.",
		category = "Visual",
		icon = "BV",
		color = Color3.fromRGB(251, 191, 36),
		previewName = "BarSynth",
		featured = true
	},
	NCSVisualizerPiano = {
		title = "NCS Visualizer",
		subtitle = "Visualizer piano map with a clean stage setup.",
		category = "Visual",
		icon = "NC",
		color = Color3.fromRGB(168, 85, 247)
	},
	GasterPiano = {
		title = "Gaster Piano",
		subtitle = "Dark themed piano map.",
		category = "Featured",
		icon = "GA",
		color = Color3.fromRGB(156, 163, 175),
		previewName = "Gaster"
	},
	CatPiano = {
		title = "Cat Piano",
		subtitle = "Cat themed piano area.",
		category = "Featured",
		icon = "CT",
		color = Color3.fromRGB(244, 114, 182),
		previewName = "CatPiano",
		featured = true
	},
	PianoPiano = {
		title = "Piano Piano",
		subtitle = "Classic piano map for simple playing.",
		category = "Classic",
		icon = "PP",
		color = Color3.fromRGB(203, 213, 225),
		previewName = "PPiano"
	},
	SidePartPiano = {
		title = "Side Part Piano",
		subtitle = "Classic side-part piano setup.",
		category = "Classic",
		icon = "SP",
		color = Color3.fromRGB(186, 230, 253)
	},
	AbstractPiano = {
		title = "Abstract Piano",
		subtitle = "Floating abstract stage area.",
		category = "Visual",
		icon = "AB",
		color = Color3.fromRGB(251, 113, 133),
		previewName = "Abstract"
	},
	DuetBluePiano = {
		title = "Duet Blue",
		subtitle = "Blue duet piano station.",
		category = "Classic",
		icon = "DB",
		color = Color3.fromRGB(96, 165, 250)
	},
	DuetPinkPiano = {
		title = "Duet Pink",
		subtitle = "Pink duet piano station.",
		category = "Classic",
		icon = "DP",
		color = Color3.fromRGB(244, 114, 182)
	},
	["Duet Piano"] = {
		title = "Duet Piano",
		subtitle = "Two-player piano station.",
		category = "Classic",
		icon = "DU",
		color = Color3.fromRGB(196, 181, 253)
	}
}

local function sanitize(name)
	local v2 = tostring(name or ""):lower():gsub("[^%w]+", "-"):gsub("^-+", ""):gsub("-+$", "")
	return v2 == "" and "destination" or v2
end

local function prettifyName(name)
	local v2 = tostring(name or "Map")
	local match = v2:match("^angelkireina's grand(%d*)$")

	if match == nil then
		return (v2:gsub("_", " "):gsub("([a-z])([A-Z])", "%1 %2"):gsub("V(%d)", "V%1"):gsub("Piano$", " Piano"):gsub(
			"%s+",
			" "
		))
	elseif match == "" then
		return "Grand Hall"
	end

	return "Grand Hall " .. match
end

local function initials(title)
	local v2 = ""

	for k in tostring(title or ""):gmatch("%w+") do
		v2 ..= k:sub(1, 1):upper()

		if #v2 >= 2 then
			break
		end
	end

	return (v2 == "" or not v2) and "MP" or v2
end

local function getSpawnLocationCFrame() -- 1 equivalent call inferred from this helper
	local spawnLocation = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)

	if spawnLocation then
		return spawnLocation.CFrame * CFrame.new(0, 5, 0)
	end

	return CFrame.new(0, 8, 0)
end

local function firstBasePart(folder)
	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			return part
		end
	end

	return nil
end

local function getBounds(instance)
	if instance:IsA("Model") then
		local success, result, v2 = pcall(function()
			return instance:GetBoundingBox()
		end)

		if success and result and v2 then
			return result, v2
		end

		local success2, result2 = pcall(function()
			return instance:GetPivot()
		end)

		if success2 and result2 then
			return result2, Vector3.new(18, 8, 18)
		end
	else
		if instance:IsA("BasePart") then
			return instance.CFrame, instance.Size
		end

		local v2 = instance:IsA("Folder") and firstBasePart(instance)

		if v2 then
			return v2.CFrame, v2.Size
		end
	end

	return nil, nil
end

local function destinationCFrame(instance)
	local bounds, v2 = getBounds(instance)

	if not bounds then
		return nil
	end

	local v3 = math.clamp((v2 and math.max(v2.X, v2.Z) or 20) * 0.5 + 12, 16, 46)
	local v4 = math.clamp((v2 and v2.Y * 0.5 or 5) + 5, 6, 22)
	local v5 = bounds.Position - bounds.LookVector * v3 + Vector3.new(0, v4, 0)
	return CFrame.lookAt(v5, bounds.Position)
end

local function categoryFor(name, p)
	if p and p.category then
		return p.category
	end

	local lower = name:lower()

	if lower:find("grand", 1, true) then
		return "Grand"
	end

	if lower:find("visual", 1, true) or lower:find("abstract", 1, true) then
		return "Visual"
	end

	return "Classic"
end

local function destinationFromInstance(child)
	local cframe = destinationCFrame(child)

	if not cframe then
		return nil
	end

	local v2 = v[child.Name]
	local title = v2 and v2.title or prettifyName(child.Name)
	local category = categoryFor(child.Name, v2)
	local color = v2 and v2.color
		or category == "Grand" and Color3.fromRGB(250, 204, 21)
		or Color3.fromRGB(120, 210, 255)
	return {
		id = sanitize(child.Name),
		name = child.Name,
		title = title,
		subtitle = v2 and v2.subtitle or "Teleport near " .. title .. ".",
		category = category,
		icon = v2 and v2.icon or initials(title),
		color = color,
		featured = v2 and v2.featured == true and true or false,
		previewImage = v2 and v2.previewName and "rbxgameasset://Images/" .. v2.previewName or nil,
		previewPath = child:GetFullName(),
		cframe = cframe,
		position = cframe.Position,
		sourcePath = child:GetFullName(),
		sourceType = "PianoFallback"
	}
end

local function destinationFromElevator(child)
	local floor = child:FindFirstChild("Floor", true)

	if not (floor and floor:IsA("BasePart")) then
		return nil
	end

	local v2 = v[child.Name]
	local title = v2 and v2.title or prettifyName(child.Name)
	local category = categoryFor(child.Name, v2)
	local color = v2 and v2.color
		or category == "Grand" and Color3.fromRGB(250, 204, 21)
		or Color3.fromRGB(120, 210, 255)
	return {
		id = sanitize(child.Name),
		name = child.Name,
		title = title,
		subtitle = v2 and v2.subtitle or "Teleport to the " .. title .. " elevator floor.",
		category = category,
		icon = v2 and v2.icon or initials(title),
		color = color,
		featured = (child.Name == "Lobby" or v2 and v2.featured == true) and true or false,
		previewImage = v2 and v2.previewName and "rbxgameasset://Images/" .. v2.previewName or nil,
		previewPath = child:GetFullName(),
		cframe = floor.CFrame * CFrame.new(0, 5, 0),
		position = floor.Position,
		zoneCFrame = floor.CFrame,
		zoneSize = floor.Size,
		sourcePath = floor:GetFullName(),
		sourceType = "ElevatorFloor"
	}
end

local function addLobbySpawn(list)
	local spawnLocationCFrame = getSpawnLocationCFrame() -- inferred equivalent call
	table.insert(list, {
		id = "lobby-spawn",
		name = "Lobby Spawn",
		title = "Lobby Spawn",
		subtitle = "Return to the main spawn.",
		category = "Featured",
		icon = "LB",
		color = Color3.fromRGB(56, 189, 248),
		featured = true,
		cframe = spawnLocationCFrame,
		position = spawnLocationCFrame.Position,
		sourcePath = "Workspace.SpawnLocation",
		sourceType = "SpawnFallback"
	})
end

local function sortKey(data)
	return
		tostring(data.title or data.name or data.id or ""):lower(),
		tostring(data.name or data.id or ""):lower(),
		(tostring(data.id or ""):lower())
end

local function sortDestinations(list)
	table.sort(list, function(a, b): boolean
		local v2, v3, v4 = sortKey(a)
		local v5, v6, v7 = sortKey(b)

		if v2 ~= v5 then
			return v2 < v5
		end

		if v3 == v6 then
			return v4 < v7
		end

		return v3 < v6
	end)
end

function MapElevatorCatalog.GetDestinations()
	local destinations = {}
	local elevators = Workspace:FindFirstChild("Elevators")
	local flag = false
	local v2 = false

	if elevators then
		for _, child in ipairs(elevators:GetChildren()) do
			local v3 = destinationFromElevator(child)

			if not v3 then
				continue
			end

			v2 = child.Name == "Lobby" or v2

			table.insert(destinations, v3)
			flag = true
		end
	end

	local function fn(p, p2): boolean
		local v3, v4, v5 = sortKey(p)
		local v6, v7, v8 = sortKey(p2)

		if v3 ~= v6 then
			return v3 < v6
		end

		if v4 == v7 then
			return v5 < v8
		end

		return v4 < v7
	end

	if flag then
		if not v2 then
			addLobbySpawn(destinations)
		end

		table.sort(destinations, fn)

		return destinations
	else
		addLobbySpawn(destinations)
		local pianos = Workspace:FindFirstChild("Pianos")

		if pianos then
			for _, child in ipairs(pianos:GetChildren()) do
				local v3 = destinationFromInstance(child)

				if v3 then
					table.insert(destinations, v3)
				end
			end
		end

		table.sort(destinations, fn)

		return destinations
	end
end

function MapElevatorCatalog.GetById(value)
	local v2 = tostring(value or "")

	for _, v3 in ipairs(MapElevatorCatalog.GetDestinations()) do
		if v3.id == v2 then
			return v3
		end
	end

	return nil
end

return MapElevatorCatalog