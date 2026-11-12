local PianoVisualization = {}

game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local v = Color3.fromRGB(255, 255, 255)

local v2 = 5
local v3 = 10
local v4 = 10

local object = setmetatable({}, { __mode = "k" })
local v5 = { maxKeyDepth = 0 }

local v6 = -0.2
local v7 = -0.2

local v8 = {}
local count = 0

local heartbeatConnection = nil

local object2 = setmetatable({}, { __mode = "k" })
local object3 = setmetatable({}, { __mode = "k" })
local object4 = setmetatable({}, { __mode = "k" })

local function isRainbowActiveForPerformer(instance, p): boolean
	if
		not instance
		or instance:GetAttribute("UseDefaultSynthesia") ~= true
		or instance:GetAttribute("RainbowActive") ~= true
		or object2[instance] == nil
	then
		return false
	end

	local rainbowOwnerUserId = tonumber(instance:GetAttribute("RainbowOwnerUserId")) or 0

	return not (rainbowOwnerUserId > 0) or p ~= nil and p.UserId == rainbowOwnerUserId
end

local CurrentCamera = workspace.CurrentCamera
local instances = table.create(128)
local v9 = table.create(128)

local function getKeyColorsForPiano(p, p2)
	local selected = p and object2[p]

	if isRainbowActiveForPerformer(p, p2) and selected then
		return selected, selected
	end

	local v10 = p and object3[p]

	if v10 then
		return v10.White or selected or v, v10.Black or selected or v
	end

	if selected then
		return selected, selected
	end

	return v, v
end

local function repaintActiveVisualizations(model)
	for _, v10 in pairs(v8) do
		if not (v10.part and v10.part.Parent and (not model or v10.piano == model)) then
			continue
		end

		local piano = v10.piano
		local performerPlayer = v10.performerPlayer
		local v11 = piano and object2[piano]
		local color, v12

		if isRainbowActiveForPerformer(piano, performerPlayer) and v11 then
			color = v11
			v12 = color
		else
			local v13 = piano and object3[piano]

			if v13 then
				v12 = v13.White or v11 or v
				color = v13.Black

				if not color then
					color = if v11 then v11 else v
				end
			elseif v11 then
				color = v11
				v12 = color
			else
				v12 = v
				color = v
			end
		end

		local rainbowActiveForPerformer = isRainbowActiveForPerformer(v10.piano, v10.performerPlayer)

		if v10.keyColors and not rainbowActiveForPerformer then
			if typeof(v10.keyColors.White) == "Color3" then
				v12 = v10.keyColors.White
			end

			if typeof(v10.keyColors.Black) == "Color3" then
				color = v10.keyColors.Black
			end
		end

		color = v10.isWhiteKey and v12 or color
		v10.part.Color = color

		local pointLight = v10.part:FindFirstChildOfClass("PointLight")

		if pointLight then
			pointLight.Color = color
		end
	end
end

local function getColorForPiano(model) -- 1 equivalent call inferred from this helper
	local v10 = model and object2[model]
	local v11

	if
		model
		and model:GetAttribute("UseDefaultSynthesia") == true
		and model:GetAttribute("RainbowActive") == true
		and object2[model] ~= nil
	then
		v11 = not ((tonumber(model:GetAttribute("RainbowOwnerUserId")) or 0) > 0)
	else
		v11 = false
	end

	if v11 and v10 then
		return v10
	end

	local v12 = model and object3[model]
	local v13

	if v12 then
		v13 = v12.White or v10 or v

		if v12.Black or v10 then
		end
	else
		return if v10 then v10 else v
	end

	return v13
end

local function getPart()
	local v10 = table.remove(instances)

	if v10 then
		v10.Transparency = 0.15
		v10.Anchored = true
		v10.CanCollide = false
		v10.Material = Enum.Material.Neon
		v10.CastShadow = false

		return v10
	else
		local noteVisualization = Instance.new("Part")
		noteVisualization.Name = "NoteVisualization"
		noteVisualization.Anchored = true
		noteVisualization.CanCollide = false
		noteVisualization.Material = Enum.Material.Neon
		noteVisualization.Transparency = 0.15
		noteVisualization.Locked = true
		noteVisualization.CastShadow = false
		noteVisualization.TopSurface = Enum.SurfaceType.Smooth
		noteVisualization.BottomSurface = Enum.SurfaceType.Smooth
		return noteVisualization
	end
end

local function getLight()
	local v10 = table.remove(v9)

	if v10 then
		v10.Brightness = 0.3
		v10.Range = 3
		v10.Shadows = false
		return v10
	else
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 0.3
		pointLight.Range = 3
		pointLight.Shadows = false
		return pointLight
	end
end

local function recycleLight(pointLight) -- 1 equivalent call inferred from this helper
	if not pointLight then
		return
	end

	pointLight.Brightness = 0
	pointLight.Parent = nil
	table.insert(v9, pointLight)
end

local function recyclePart(part) -- 2 equivalent calls inferred from this helper
	if not part then
		return
	end

	local pointLight = part:FindFirstChildOfClass("PointLight")

	if pointLight then
		recycleLight(pointLight) -- inferred equivalent call
	end

	part.Size = Vector3.new(0.001, 0.001, 0.001)
	part.Transparency = 1
	part.Parent = nil
	table.insert(instances, part)
end

local function findPianoFromKey(instance)
	if not instance then
		return nil
	end

	local v10 = instance:FindFirstAncestorOfClass("Model")
	local v11 = nil

	while v10 do
		if v10:FindFirstChild("Keys") then
			if v10:FindFirstChild("SeatOccupant") and v10:FindFirstChild("Scripts") then
				return v10
			end

			v11 = v11 or v10
		end

		v10 = v10.Parent
	end

	return v11
end

local function isSynthAnchor(part) -- 4 equivalent calls inferred from this helper
	local v10

	if part == nil then
		return false
	end

	v10 = part:IsA("BasePart")

	if v10 then
		if part.Parent == nil then
			return false
		end

		return part.Parent.Name == "Synth"
	end

	return v10
end

local function getPlayableKeyContainer(instance) -- 2 equivalent calls inferred from this helper
	local keys = instance and instance:FindFirstChild("Keys")

	if keys then
		return keys:FindFirstChild("Keys") or keys
	end

	return nil
end

local function getNumericBaseParts(instance)
	local parts = {}

	if instance then
		for _, part in ipairs(instance:GetChildren()) do
			if part:IsA("BasePart") and tonumber(part.Name) then
				table.insert(parts, part)
			end
		end
	end

	table.sort(parts, function(a, b): boolean
		return tonumber(a.Name) < tonumber(b.Name)
	end)

	return parts
end

local function rebuildSynthKeyCache(instance)
	if not instance then
		return nil
	end

	local synth = instance:FindFirstChild("Synth")
	local playableKeyContainer = getPlayableKeyContainer(instance) -- inferred equivalent call

	if not (synth and playableKeyContainer) then
		return nil
	end

	local v10 = {
		synthFolder = synth,
		keyContainer = playableKeyContainer,
		byKey = setmetatable({}, { __mode = "k" })
	}

	local numericBaseParts = getNumericBaseParts(playableKeyContainer)
	local numericBaseParts2 = getNumericBaseParts(synth)

	for i, numericBasePart in ipairs(numericBaseParts) do
		local part = synth:FindFirstChild((tostring(i)))

		if not (part and part:IsA("BasePart")) then
			part = numericBaseParts2[i]
		end

		if part and part:IsA("BasePart") then
			v10.byKey[numericBasePart] = part
		end
	end

	object4[instance] = v10
	return v10
end

local function getSynthAnchorForKey(pianoFromKey, part)
	if not part then
		return nil
	end

	if isSynthAnchor(part) then -- inferred equivalent call
		return part
	end

	if not pianoFromKey then
		return nil
	end

	local synth = pianoFromKey:FindFirstChild("Synth")

	if not synth then
		return nil
	end

	local playableKeyContainer = getPlayableKeyContainer(pianoFromKey) -- inferred equivalent call
	local v10 = object4[pianoFromKey]

	if not v10 or v10.synthFolder ~= synth or v10.keyContainer ~= playableKeyContainer then
		v10 = rebuildSynthKeyCache(pianoFromKey)
	end

	local selected = v10 and v10.byKey[part]

	if selected and selected.Parent then
		return selected
	end

	local part2 = synth:FindFirstChild(part.Name)
	return if part2 and part2:IsA("BasePart") then part2 else nil
end

local function isWhite(instance): boolean
	if instance:GetAttribute("IsBlack") ~= nil then
		return not instance:GetAttribute("IsBlack")
	end

	if CollectionService:HasTag(instance, "BlackKey") then
		return false
	end

	local name = tonumber(instance.Name)

	if name then
		local v10 = (name - 1) % 12 + 1

		return v10 ~= 2 and v10 ~= 5 and v10 ~= 7 and v10 ~= 10 and v10 ~= 12
	end

	local name2 = string.upper(instance.Name)
	return string.find(name2, "#", 1, true) == nil
end

local function getInitialSizeForKey(p) -- 1 equivalent call inferred from this helper
	if isWhite(p) then
		return Vector3.new(0.001, 0.1, 0.116)
	end

	return Vector3.new(0.001, 0.1, 0.08)
end

local function getColorForPianoKey(p, p2, p3, p4)
	local rainbowActiveForPerformer = isRainbowActiveForPerformer(p, p4)

	if p3 and not rainbowActiveForPerformer then
		local white = isWhite(p2) and p3.White or p3.Black

		if typeof(white) == "Color3" then
			return white
		end
	end

	local v10 = p and object2[p]
	local v11, v12

	if isRainbowActiveForPerformer(p, p4) and v10 then
		v11 = v10
		v12 = v11
	else
		local v13 = p and object3[p]

		if v13 then
			v12 = v13.White or v10 or v
			v11 = v13.Black

			if not v11 then
				v11 = if v10 then v10 else v
			end
		elseif v10 then
			v11 = v10
			v12 = v11
		else
			v12 = v
			v11 = v
		end
	end

	return isWhite(p2) and v12 or v11
end

local function isOtherPlayerPiano(instance): boolean
	if not (RunService:IsClient() and instance) then
		return false
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local seatOccupant = instance:FindFirstChild("SeatOccupant")
	local value = seatOccupant and seatOccupant:IsA("ObjectValue") and seatOccupant.Value

	if not value then
		return false
	end

	local character = localPlayer.Character
	return not (character and value:IsDescendantOf(character))
end

local function shouldUseDefaultSynthesia(instance): boolean
	if
		instance
		and (instance:GetAttribute("UseDefaultSynthesia") == false or instance:GetAttribute("UseLegacySideVisualization") == true)
	then
		return false
	end

	local localPlayer = RunService:IsClient() and Players.LocalPlayer

	if not localPlayer then
		return true
	end

	if localPlayer:GetAttribute("OtherPlayerTileEffectsEnabled") == false and isOtherPlayerPiano(instance) then
		return false
	end

	return localPlayer:GetAttribute("DefaultSynthesiaEnabled") ~= false
end

local function getPianoPerformerPlayer(instance, player)
	if player and player:IsA("Player") then
		return player
	end

	if not instance then
		return nil
	end

	local seatOccupant = instance:FindFirstChild("SeatOccupant")
	local value = seatOccupant and seatOccupant:IsA("ObjectValue") and seatOccupant.Value

	if not value then
		return nil
	end

	if value:IsA("Player") then
		return value
	end

	if value:IsA("Model") then
		return Players:GetPlayerFromCharacter(value)
	end

	local model = value:FindFirstAncestorOfClass("Model")
	return model and Players:GetPlayerFromCharacter(model) or nil
end

local function shouldUseHeartParticleEffect(pianoFromKey, p): boolean
	if not (RunService:IsClient() and shouldUseDefaultSynthesia(pianoFromKey)) then
		return false
	end

	local pianoPerformerPlayer = getPianoPerformerPlayer(pianoFromKey, p)

	if not pianoPerformerPlayer then
		return false
	end

	return pianoPerformerPlayer:GetAttribute("HeartParticleEffectUnlocked") == true
		and pianoPerformerPlayer:GetAttribute("HeartParticleEffectEnabled") ~= false
end

local function flattenToWorldPlane(vector: Vector3, vector3: Vector3) -- 6 equivalent calls inferred from this helper
	local v10 = vector - Vector3.new(0, 1, 0) * vector:Dot(Vector3.new(0, 1, 0))
	return if v10.Magnitude > 0.0001 then v10.Unit else vector3
end

local function getAlignmentForPiano(p)
	if not p then
		return v5
	end

	local v10 = object[p]

	if not v10 then
		v10 = { maxKeyDepth = 0 }
		object[p] = v10
	end

	return v10
end

local function getKeyAxes(instance)
	local cframe = instance.CFrame

	if isSynthAnchor(instance) then -- inferred equivalent call
		return
			flattenToWorldPlane(cframe.RightVector, Vector3.new(1, 0, 0)), -- inferred equivalent call
			flattenToWorldPlane(cframe.LookVector, cframe.LookVector), -- inferred equivalent call
			instance.Size.X,
			instance.Size.Z
	elseif instance.Size.X > instance.Size.Z then
		return
			flattenToWorldPlane(cframe.LookVector, Vector3.new(1, 0, 0)), -- inferred equivalent call
			flattenToWorldPlane(cframe.RightVector, cframe.RightVector), -- inferred equivalent call
			instance.Size.Z,
			instance.Size.X
	else
		return
			flattenToWorldPlane(cframe.RightVector, Vector3.new(1, 0, 0)), -- inferred equivalent call
			flattenToWorldPlane(cframe.LookVector, cframe.LookVector), -- inferred equivalent call
			instance.Size.X,
			instance.Size.Z
	end
end

local function getSurfaceAnchor(part, p)
	local v10 = p or v5

	if isSynthAnchor(part) then -- inferred equivalent call
		return part.Position + Vector3.new(0, 1, 0) * (part.Size.Y / 2)
	end

	local white = isWhite(part)

	if white and not v10.whiteKeyTopY then
		v10.whiteKeyTopY = part.Position.Y + part.Size.Y / 2
	elseif not (white or v10.blackKeyTopY) then
		v10.blackKeyTopY = part.Position.Y + part.Size.Y / 2
	end

	local whiteKeyTopY = v10.whiteKeyTopY or part.Position.Y + part.Size.Y / 2
	local v11 = white and v6 or v7
	local _, v12 = getKeyAxes(part)
	local v13 = part.Position + v12 * ((v10.maxKeyDepth or 0) / 2 + v11)
	return (Vector3.new(v13.X, whiteKeyTopY, v13.Z))
end

local function createVisualizationPart(part, p: number, vector3: Vector3, pianoFromKey, p2, p3, p4)
	local part2 = getPart()
	part2.Name = "NoteVisualization_" .. tostring(p)
	part2.Anchored = true
	part2.CanCollide = false
	part2.Material = Enum.Material.Neon
	part2.Transparency = 0.2
	local colorForPianoKey = getColorForPianoKey(pianoFromKey, part, p3, p4)
	part2.Color = colorForPianoKey
	part2.Parent = workspace.CurrentCamera or CurrentCamera or workspace
	local v10 = table.remove(v9) or Instance.new("PointLight")
	v10.Brightness = 0.3
	v10.Range = 3
	v10.Shadows = false

	v10.Color = colorForPianoKey
	v10.Parent = part2

	local keyAxes, _, v11, v12 = getKeyAxes(part)
	local v13 = isSynthAnchor(part) and v12 or vector3.Z -- inferred equivalent call
	local vector3_2 = Vector3.new(v11, vector3.Y, v13)

	local surfaceAnchor = getSurfaceAnchor(part, p2)

	local v14 = surfaceAnchor + Vector3.new(0, 1, 0) * (vector3_2.Y / 2 + 0.1)
	part2.Size = vector3_2
	part2.CFrame = CFrame.fromMatrix(v14, keyAxes, Vector3.new(0, 1, 0))

	return part2, vector3_2, surfaceAnchor, keyAxes, Vector3.new(0, 1, 0)
end

local function createHeartParticleEffect(p, p2: number, pianoFromKey, p3, p4, p5)
	local surfaceAnchor = getSurfaceAnchor(p, p3)
	local part = Instance.new("Part")
	part.Name = "HeartParticleVisualization_" .. tostring(p2)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.15, 0.15, 0.15)
	part.CFrame = CFrame.new(surfaceAnchor + Vector3.new(0, 0.3, 0))
	part.Parent = workspace.CurrentCamera or CurrentCamera or workspace

	local heartParticleAttachment = Instance.new("Attachment")
	heartParticleAttachment.Name = "HeartParticleAttachment"
	heartParticleAttachment.Parent = part

	local heartParticleEmitter = Instance.new("ParticleEmitter")
	heartParticleEmitter.Name = "HeartParticleEmitter"
	heartParticleEmitter.Texture = "rbxassetid://36721240"
	heartParticleEmitter.Rate = 0
	heartParticleEmitter.Lifetime = NumberRange.new(0.7, 1.05)
	heartParticleEmitter.Speed = NumberRange.new(2.5, 4.25)
	heartParticleEmitter.SpreadAngle = Vector2.new(24, 24)
	heartParticleEmitter.Rotation = NumberRange.new(-25, 25)
	heartParticleEmitter.RotSpeed = NumberRange.new(-45, 45)
	heartParticleEmitter.Acceleration = Vector3.new(0, 2.5, 0)
	heartParticleEmitter.LightEmission = 0.55
	heartParticleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.26),
		NumberSequenceKeypoint.new(0.4, 0.42),
		NumberSequenceKeypoint.new(1, 0.05)
	})

	heartParticleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.75, 0.15),
		NumberSequenceKeypoint.new(1, 1)
	})

	local colorForPianoKey = getColorForPianoKey(pianoFromKey, p, p4, p5)
	heartParticleEmitter.Color = ColorSequence.new(colorForPianoKey, Color3.fromRGB(255, 145, 190))
	heartParticleEmitter.Parent = heartParticleAttachment
	heartParticleEmitter:Emit(isWhite(p) and 12 or 9)
	Debris:AddItem(part, 2)
end

local function ensureSharedHeartbeat() -- 1 equivalent call inferred from this helper
	if heartbeatConnection then
		return
	end

	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if next(v8) == nil then
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end
		else
			for k, v10 in pairs(v8) do
				local part = v10.part

				if part and part.Parent then
					v10.elapsed += dt

					if v10.isGrowing then
						v10.currentHeight = math.min(v10.currentHeight + v2 * dt, v3)
						part.Size = Vector3.new(v10.initialSize.X, v10.currentHeight, v10.initialSize.Z)

						if v10.elapsed < 0.08 then
							part.Transparency = 1 - 0.85 * (v10.elapsed / 0.08)
						else
							part.Transparency = 0.15
						end

						local pointLight = part:FindFirstChildOfClass("PointLight")

						if pointLight and v10.elapsed < 0.5 then
							pointLight.Brightness = 0.3 * (1 - v10.elapsed / 0.5)
						elseif pointLight then
							pointLight.Brightness = 0
						end

						local v11 = v10.baseCenter + v10.baseUp * (0.1 + v10.currentHeight / 2)
						part.CFrame = CFrame.fromMatrix(v11, v10.baseRight, v10.baseUp)
					elseif not v10.isGrowing then
						local v11 = v10.baseCenter + v10.baseUp * (v3 + 0.1)

						if v10.isFloating then
							local v12 = part.CFrame.Position + v10.baseUp * (v10.currentHeight / 2)
							local vector = v11 - v12
							local v13 = math.min(v2 * dt, (math.max(0, vector:Dot(v10.baseUp))))
							local v14 = v12 + v10.baseUp * v13

							local v15 = v14 - v10.baseUp * (v10.currentHeight / 2)
							part.Size = Vector3.new(v10.initialSize.X, v10.currentHeight, v10.initialSize.Z)
							part.CFrame = CFrame.fromMatrix(v15, v10.baseRight, v10.baseUp)

							if (v14 - v11).Magnitude <= 0.01 then
								v10.isFloating = false
								v10.maxWipeHeight = v10.currentHeight
							end
						else
							v10.currentHeight = math.max(0, v10.currentHeight - v4 * dt)

							if v10.maxWipeHeight and v10.maxWipeHeight > 0 then
								part.Transparency = 0.15 + 0.85 * (1 - v10.currentHeight / v10.maxWipeHeight)
							end

							if v10.currentHeight <= 0.0005 then
								recyclePart(part) -- inferred equivalent call
								v8[k] = nil
							else
								local v12 = v11 - v10.baseUp * (v10.currentHeight / 2)
								part.Size = Vector3.new(v10.initialSize.X, v10.currentHeight, v10.initialSize.Z)
								part.CFrame = CFrame.fromMatrix(v12, v10.baseRight, v10.baseUp)
							end
						end
					end
				else
					if v10.connection then
						v10.connection:Disconnect()
					end

					v8[k] = nil
				end
			end
		end
	end)
end

local function finishAndWipe(p: number) -- 2 equivalent calls inferred from this helper
	local v10 = v8[p]

	if not v10 then
		return
	end

	v10.isGrowing = false
	v10.isFloating = true
	v10.maxWipeHeight = v10.currentHeight
end

function PianoVisualization.StartVisualization(pianoKey, noteNumber: number, value: number?, performerPlayer, keyColors)
	if not pianoKey then
		return nil
	end

	local pianoFromKey = findPianoFromKey(pianoKey)
	local visualizationKey = getSynthAnchorForKey(pianoFromKey, pianoKey) or pianoKey
	local v10

	if pianoFromKey then
		v10 = object[pianoFromKey]

		if not v10 then
			v10 = { maxKeyDepth = 0 }
			object[pianoFromKey] = v10
		end
	else
		v10 = v5
	end

	local _, _, _, v11 = getKeyAxes(visualizationKey)
	v10.maxKeyDepth = math.max(v10.maxKeyDepth or 0, v11)

	count += 1
	local v12 = count

	if not shouldUseDefaultSynthesia(pianoFromKey) then
		return nil
	end

	if shouldUseHeartParticleEffect(pianoFromKey, performerPlayer) then
		createHeartParticleEffect(visualizationKey, noteNumber, pianoFromKey, v10, keyColors, performerPlayer)
		return nil
	end

	local visualizationPart, initialSize, baseCenter, baseRight, baseUp = createVisualizationPart(
		visualizationKey,
		noteNumber,
		getInitialSizeForKey(visualizationKey), -- inferred equivalent call
		pianoFromKey,
		v10,
		keyColors,
		performerPlayer
	)

	v8[v12] = {
		part = visualizationPart,
		connection = nil,
		noteNumber = noteNumber,
		timestamp = os.clock(),
		pianoKey = pianoKey,
		visualizationKey = visualizationKey,
		initialSize = initialSize,
		baseCenter = baseCenter,
		baseRight = baseRight,
		baseUp = baseUp,
		piano = pianoFromKey,
		performerPlayer = performerPlayer,
		keyColors = keyColors,
		isWhiteKey = isWhite(visualizationKey),
		currentHeight = initialSize.Y,
		elapsed = 0,
		isGrowing = true,
		isFloating = false,
		maxWipeHeight = nil
	}
	ensureSharedHeartbeat() -- inferred equivalent call
	task.delay(value or 5, function()
		local v13 = v8[v12]

		if not v13 then
			return
		end

		if v13.part and v13.part.Parent then
			finishAndWipe(v12) -- inferred equivalent call
		end
	end)

	return v12
end

function PianoVisualization.EndVisualization(p: number)
	local v10 = -1e999
	local v11 = nil

	for k, v12 in pairs(v8) do
		if not (v12.noteNumber == p and v10 < v12.timestamp) then
			continue
		end

		v10 = v12.timestamp
		v11 = k
	end

	if not v11 then
		return
	end

	local v12 = v8[v11]

	if v12.part and v12.part.Parent then
		finishAndWipe(v11) -- inferred equivalent call
	end
end

function PianoVisualization.CleanupAll()
	for _, v10 in pairs(v8) do
		if v10.part and v10.part.Parent then
			recyclePart(v10.part) -- inferred equivalent call
		end
	end

	v8 = {}

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

function PianoVisualization.FadeAllVisualizations()
	for _, v10 in pairs(v8) do
		if not v10.isGrowing then
			continue
		end

		v10.isGrowing = false
		v10.isFloating = true
		v10.maxWipeHeight = v10.currentHeight
	end
end

function PianoVisualization.FadeOtherPlayerVisualizations()
	for _, v10 in pairs(v8) do
		if not (v10.isGrowing and isOtherPlayerPiano(v10.piano)) then
			continue
		end

		v10.isGrowing = false
		v10.isFloating = true
		v10.maxWipeHeight = v10.currentHeight
	end
end

function PianoVisualization.SetVisualizerColor(color: Color3, model)
	if model and model:IsA("Model") then
		object2[model] = color

		if model:GetAttribute("RainbowActive") == true then
			repaintActiveVisualizations(model)
		elseif object3[model] then
			repaintActiveVisualizations(model)
		else
			PianoVisualization.SetVisualizerKeyColors(color, color, model)
		end
	else
		v = color
		PianoVisualization.SetVisualizerKeyColors(color, color, model)
	end
end

function PianoVisualization.SetVisualizerKeyColors(white: Color3?, color: Color3?, model)
	if model and model:IsA("Model") then
		local v10 = object3[model]
		local black = object2[model] or v

		if typeof(white) ~= "Color3" or not white then
			if v10 then
				white = v10.White or black
			else
				white = black
			end
		end

		black = typeof(color) == "Color3" and color or v10 and v10.Black or black
		object3[model] = { White = white, Black = black }
	elseif typeof(white) == "Color3" and typeof(color) == "Color3" and white == color then
		v = white
	end

	repaintActiveVisualizations(model)
end

function PianoVisualization.SetGrowthSpeed(p: number)
	v2 = p
end

function PianoVisualization.SetMaxHeight(p: number)
	v3 = p
end

function PianoVisualization.SetDepthOffset(p: number)
	warn("[NoteVisualizer] SetDepthOffset() sets BOTH white & black. Use SetDepthOffsetWhite/Black.")
	v6 = p
	v7 = p
end

function PianoVisualization.SetDepthOffsetWhite(p: number)
	v6 = p
end

function PianoVisualization.SetDepthOffsetBlack(p: number)
	v7 = p
end

function PianoVisualization.SetWipeSpeed(p: number)
	v4 = p
end

function PianoVisualization.GetVisualizerColor(model)
	if not (model and model:IsA("Model")) then
		return v
	end

	return getColorForPiano(model) -- inferred equivalent call
end

function PianoVisualization.GetVisualizationData(p: number)
	return v8[p]
end

return PianoVisualization