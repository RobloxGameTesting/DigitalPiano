local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local v = {}
local v2 = 0.55
local color = Color3.fromHSV(v2, 1, 1)
local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })
local object3 = setmetatable({}, { __mode = "k" })

local function addEvent(list, p, p2, p3) -- 3 equivalent calls inferred from this helper
	table.insert(list, {
		note = math.clamp(math.floor(p + 0.5), 1, 88),
		at = math.max(0, p2),
		hold = math.max(0.12, p3)
	})
end

local function addChord(result, list, p, p2, value)
	local v3 = value or 0

	for i, item in ipairs(list) do
		addEvent(result, item, p + (i - 1) * v3, p2) -- inferred equivalent call
	end
end

local function buildSongPattern()
	local v3 = {
		{
			bass = 16,
			chord = { 40, 44, 47, 52 },
			lead = { 64, 59, 56, 52 }
		},
		{
			bass = 23,
			chord = { 35, 42, 47, 54 },
			lead = { 61, 59, 54, 50 }
		},
		{
			bass = 28,
			chord = { 40, 47, 52, 56 },
			lead = { 64, 68, 71, 76 }
		},
		{
			bass = 21,
			chord = { 33, 40, 45, 49 },
			lead = { 57, 61, 64, 69 }
		}
	}
	local total = 0
	local result = {}

	for _ = 1, 2 do
		for _, v4 in ipairs(v3) do
			table.insert(result, {
				note = math.clamp(math.floor(v4.bass + 0.5), 1, 88),
				at = math.max(0, total),
				hold = 1.05
			})
			local v5 = v4.bass + 12
			local v6 = total + 0.36
			table.insert(result, {
				note = math.clamp(math.floor(v5 + 0.5), 1, 88),
				at = math.max(0, v6),
				hold = 0.55
			})

			addChord(result, v4.chord, total + 0.02, 0.78, 0.025)

			for i, v7 in ipairs(v4.lead) do
				local v8 = total + 0.18 + (i - 1) * 0.18
				table.insert(result, {
					note = math.clamp(math.floor(v7 + 0.5), 1, 88),
					at = math.max(0, v8),
					hold = 0.42
				})
			end

			addChord(result, { v4.chord[2] + 12, v4.chord[3] + 12, v4.chord[4] + 12 }, total + 0.92, 0.5, 0.035)
			total += 1.28
		end
	end

	local v4 = total + 0.15

	for i = 0, 43 do
		local v5 = (i * 5 + 17 - 1) % 88 + 1
		local v6 = v4 + i * 0.115
		addEvent(result, (i * 7 + 40 - 1) % 88 + 1, v6, i % 3 * 0.04 + 0.36) -- inferred equivalent call

		if i % 2 == 0 then
			local v7 = v6 + 0.045
			table.insert(result, {
				note = math.clamp(math.floor(v5 + 0.5), 1, 88),
				at = math.max(0, v7),
				hold = 0.42
			})
		end

		if i % 8 == 0 then
			addChord(result, { math.max(1, v5 - 12), v5, (math.min(88, v5 + 12)) }, v6 + 0.02, 0.5, 0.02)
		end
	end

	local v5 = v4 + 5.0600000000000005 + 0.35

	for i = 0, 87 do
		local v6 = (i * 7 + 1 - 1) % 88 + 1
		local v7 = v5 + i * 0.082
		addEvent(result, v6, v7, i % 5 * 0.025 + 0.26) -- inferred equivalent call

		if i % 11 ~= 0 then
			continue
		end

		local v8 = math.clamp(v6 + 24, 1, 88)
		local v9 = v7 + 0.035
		table.insert(result, {
			note = math.clamp(math.floor(v8 + 0.5), 1, 88),
			at = math.max(0, v9),
			hold = 0.34
		})
	end

	local v6 = v5 + 7.216 + 0.55

	for _, v7 in ipairs({
		{ 16, 28, 40, 52, 64, 76, 88 },
		{ 11, 23, 35, 47, 59, 71, 83 },
		{ 4, 16, 28, 40, 52, 64, 76 },
		{ 1, 13, 25, 37, 49, 61, 73, 85 }
	}) do
		addChord(result, v7, v6, 0.9, 0.025)
		v6 += 0.46
	end

	addChord(result, {
		1,
		8,
		16,
		28,
		40,
		52,
		64,
		76,
		88
	}, v6 + 0.15, 1.35, 0.018)
	local maxValue = 0

	for _, v7 in ipairs(result) do
		maxValue = math.max(maxValue, v7.at + v7.hold)
	end

	return result, maxValue
end

local songPattern, v3 = buildSongPattern()

local function getAdvertiseModel() -- 1 equivalent call inferred from this helper
	local npc = Workspace:FindFirstChild("NPC")
	return npc and npc:FindFirstChild("RainbowVisualizerAdvertise") or nil
end

local function getPlayableKeyContainer(instance) -- 1 equivalent call inferred from this helper
	local keys = instance and instance:FindFirstChild("Keys")

	if keys then
		return keys:FindFirstChild("Keys") or keys
	end

	return nil
end

local function collectPartsByNumber(instance)
	local partsByPianoKeyNumber = {}

	if not instance then
		return partsByPianoKeyNumber
	end

	for _, part in ipairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		local pianoKeyNumber = math.floor(tonumber(part:GetAttribute("PianoKeyNumber")) or tonumber(part.Name) or 0)

		if pianoKeyNumber > 0 then
			partsByPianoKeyNumber[pianoKeyNumber] = part
		end
	end

	return partsByPianoKeyNumber
end

local function flattenToWorldPlane(rightVector, p) -- 2 equivalent calls inferred from this helper
	local v4 = rightVector - Vector3.new(0, 1, 0) * rightVector:Dot(Vector3.new(0, 1, 0))
	return if v4.Magnitude > 0.0001 then v4.Unit else p
end

local function getTileCFrame(anchor, height, raised) -- 1 equivalent call inferred from this helper
	local v4 = flattenToWorldPlane(anchor.CFrame.RightVector, Vector3.new(1, 0, 0)) -- inferred equivalent call
	local v5 = anchor.Position + Vector3.new(0, 1, 0) * (anchor.Size.Y / 2) + Vector3.new(0, 1, 0) * (0.1 + raised + height / 2)
	return CFrame.fromMatrix(v5, v4, Vector3.new(0, 1, 0))
end

local function setPassivePartFlags(part)
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	pcall(function()
		part.CanTouch = false
	end)
	pcall(function()
		part.CanQuery = false
	end)
end

local function getPreviewParent() -- 1 equivalent call inferred from this helper
	return Workspace.CurrentCamera or Workspace
end

local function resetPreviewFolder(instance)
	local rainbowVisualizerPreview_Client = (instance:FindFirstChild("ActiveNotes") or instance):FindFirstChild("RainbowVisualizerPreview_Client")

	if rainbowVisualizerPreview_Client then
		rainbowVisualizerPreview_Client:Destroy()
	end

	local previewParent = getPreviewParent() -- inferred equivalent call
	local rainbowVisualizerAdvertiseSynthPreview_Client = previewParent:FindFirstChild("RainbowVisualizerAdvertiseSynthPreview_Client")

	if rainbowVisualizerAdvertiseSynthPreview_Client then
		rainbowVisualizerAdvertiseSynthPreview_Client:ClearAllChildren()
		return rainbowVisualizerAdvertiseSynthPreview_Client
	end

	local rainbowVisualizerAdvertiseSynthPreview_Client2 = Instance.new("Folder")
	rainbowVisualizerAdvertiseSynthPreview_Client2.Name = "RainbowVisualizerAdvertiseSynthPreview_Client"
	rainbowVisualizerAdvertiseSynthPreview_Client2.Parent = previewParent

	return rainbowVisualizerAdvertiseSynthPreview_Client2
end

local function setTileColor(instance, color2) -- 2 equivalent calls inferred from this helper
	instance.Color = color2
	local pointLight = instance:FindFirstChildOfClass("PointLight")

	if pointLight then
		pointLight.Color = color2
	end
end

local function makeBillboardRainbowSequence(p)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(p % 1, 1, 1)),
		ColorSequenceKeypoint.new(0.16, Color3.fromHSV((p + 0.16) % 1, 1, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV((p + 0.33) % 1, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV((p + 0.5) % 1, 1, 1)),
		ColorSequenceKeypoint.new(0.66, Color3.fromHSV((p + 0.66) % 1, 1, 1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV((p + 0.83) % 1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(p % 1, 1, 1))
	})
end

local function updateBillboardRainbow(instance, now)
	local billboardGui = instance:FindFirstChild("BillboardGui")

	if not (billboardGui and billboardGui:IsA("BillboardGui")) then
		return
	end

	local textLabel = billboardGui:FindFirstChildWhichIsA("TextLabel", true)

	if not textLabel then
		return
	end

	textLabel.Text = "RAINBOW VISUALIZER"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0

	local rainbowTextGradient = textLabel:FindFirstChild("RainbowTextGradient")

	if rainbowTextGradient and rainbowTextGradient:IsA("UIGradient") then
		rainbowTextGradient.Enabled = true
		rainbowTextGradient.Color = makeBillboardRainbowSequence(v2)
		rainbowTextGradient.Offset = Vector2.new(math.sin(now * 1.35) * 0.25, 0)
		rainbowTextGradient.Rotation = 0
	end
end

local function createSynthTile(instance, note, parent)
	local part = Instance.new("Part")
	part.Name = "RainbowSynthesiaTile_" .. tostring(note)
	setPassivePartFlags(part)
	part.Material = Enum.Material.Neon
	part.Transparency = 1
	part.Size = Vector3.new(instance.Size.X, 0.1, instance.Size.Z)
	local v4 = flattenToWorldPlane(instance.CFrame.RightVector, Vector3.new(1, 0, 0)) -- inferred equivalent call
	local v5 = instance.Position + Vector3.new(0, 1, 0) * (instance.Size.Y / 2) + Vector3.new(0, 0.15, 0)
	part.CFrame = CFrame.fromMatrix(v5, v4, Vector3.new(0, 1, 0))
	setTileColor(part, color) -- inferred equivalent call
	part.Parent = parent

	local previewGlow = Instance.new("PointLight")
	previewGlow.Name = "PreviewGlow"
	previewGlow.Brightness = 0.3
	previewGlow.Range = 5
	previewGlow.Shadows = false
	previewGlow.Color = color
	previewGlow.Parent = part

	local synthTile = {
		part = part,
		anchor = instance,
		note = note,
		height = 0.1,
		raised = 0,
		age = 0,
		holding = true,
		floating = false,
		maxWipeHeight = 0.1,
		releaseAt = 0
	}

	v[part] = synthTile
	return synthTile
end

local function destroyActiveTile(instance) -- 2 equivalent calls inferred from this helper
	v[instance] = nil

	if instance and instance.Parent then
		instance:Destroy()
	end
end

local function isBlackKey(instance)
	local isBlackKey2 = instance:GetAttribute("IsBlackKey")

	if typeof(isBlackKey2) == "boolean" then
		return isBlackKey2
	end

	local isBlack = instance:GetAttribute("IsBlack")

	if typeof(isBlack) == "boolean" then
		return isBlack
	end

	local v4 = (math.floor(tonumber(instance:GetAttribute("PianoKeyNumber")) or tonumber(instance.Name) or 1) - 1) % 12 + 1
	return v4 == 2 or v4 == 5 or v4 == 7 or v4 == 10 or v4 == 12
end

local function pressPhysicalKey(instance, duration)
	if not (instance and instance.Parent) then
		return
	end

	local original = object[instance]

	if not original then
		original = {
			Color = instance.Color,
			Material = instance.Material,
			CFrame = instance.CFrame
		}
		object[instance] = original
	end

	local token = (object2[instance] or 0) + 1
	object2[instance] = token
	instance.Material = Enum.Material.Neon
	instance.Color = color
	instance.CFrame = original.CFrame * (isBlackKey(instance) and CFrame.new(0, -0.028, 0) or CFrame.new(0, -0.033, 0)) * CFrame.Angles(0.05235987755982989, 0, 0)
	object3[instance] = { token = token, original = original }

	task.delay(duration, function()
		if object2[instance] ~= token or not instance.Parent then
			return
		end

		object2[instance] = nil
		object3[instance] = nil
		instance.Material = original.Material
		instance.Color = original.Color
		instance.CFrame = original.CFrame
	end)
end

local function updatePressedKeys()
	for k, v4 in pairs(object3) do
		if k.Parent and object2[k] == v4.token then
			k.Material = Enum.Material.Neon
			k.Color = color
		else
			object3[k] = nil
		end
	end
end

local function playNote(note, p, p2, p3, parent)
	local anchor = p2[note]

	if anchor and anchor.Parent then
		local synthTile = createSynthTile(anchor, note, parent)
		synthTile.releaseAt = os.clock() + p
		pressPhysicalKey(p3[note], p)
	end
end

local function updateTiles(dt)
	for k, v4 in pairs(v) do
		if k and k.Parent then
			if v4.anchor and v4.anchor.Parent then
				v4.age += dt
				setTileColor(k, color) -- inferred equivalent call

				if v4.holding and os.clock() >= v4.releaseAt then
					v4.holding = false
					v4.floating = true
					v4.maxWipeHeight = v4.height
				end

				if v4.holding then
					v4.height = math.min(6.2, v4.height + 5 * dt)
					k.Transparency = math.max(0.15, 1 - v4.age / 0.08)
				elseif v4.floating then
					local v5 = math.max(0, 6.2 - (v4.raised + v4.height))
					local v6 = math.min(5 * dt, v5)
					v4.raised += v6

					if v5 <= 0.01 or v5 <= v6 then
						v4.floating = false
						v4.maxWipeHeight = v4.height
					end
				else
					v4.height = math.max(0, v4.height - 10 * dt)
					v4.raised = 6.2 - v4.height

					if v4.maxWipeHeight > 0 then
						k.Transparency = math.clamp(0.15 + 0.85 * (1 - v4.height / v4.maxWipeHeight), 0.15, 1)
					end

					if v4.height <= 0.02 then
						v[k] = nil
						k:Destroy()
						continue
					end
				end

				k.Size = Vector3.new(v4.anchor.Size.X, v4.height, v4.anchor.Size.Z)
				k.CFrame = getTileCFrame(v4.anchor, v4.height, v4.raised) -- inferred equivalent call
			else
				destroyActiveTile(k) -- inferred equivalent call
			end
		else
			v[k] = nil
		end
	end
end

local function runPreview(advertiseModel)
	advertiseModel:SetAttribute("GamePassKey", "RainbowVisualizer")
	advertiseModel:SetAttribute("UseDefaultSynthesia", true)
	advertiseModel:SetAttribute("RainbowActive", true)
	advertiseModel:SetAttribute("RainbowOwnerUserId", 0)
	advertiseModel:SetAttribute("RainbowPreviewSilent", true)
	advertiseModel:SetAttribute("RainbowPreviewUsesDirectSynthFolder", true)
	advertiseModel:SetAttribute("RainbowPreviewSongSeconds", v3)

	local parent = resetPreviewFolder(advertiseModel)
	local v4 = true
	local ancestryChangedConnection = advertiseModel.AncestryChanged:Connect(function()
		if not advertiseModel:IsDescendantOf(Workspace) then
			v4 = false
		end
	end)
	local heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		if not v4 then
			return
		end

		v2 = (v2 + dt * 0.12) % 1
		color = Color3.fromHSV(v2, 1, 1)

		if advertiseModel.Parent then
			advertiseModel:SetAttribute("VizColor", color)
		end

		updateTiles(dt)
		updatePressedKeys()
		updateBillboardRainbow(advertiseModel, os.clock())
	end)

	while v4 and advertiseModel.Parent do
		local synth = advertiseModel:FindFirstChild("Synth")
		local playableKeyContainer = getPlayableKeyContainer(advertiseModel) -- inferred equivalent call
		local v5 = collectPartsByNumber(synth)
		local v6 = collectPartsByNumber(playableKeyContainer)

		if v5[1] and v5[88] and v6[1] and v6[88] then
			for _, v7 in ipairs(songPattern) do
				local v8 = v7
				task.delay(v7.at, function()
					if v4 and advertiseModel.Parent and parent.Parent then
						local note = v8.note
						local hold = v8.hold
						local anchor = v5[note]

						if anchor then
							if not anchor.Parent then
								return
							end

							local synthTile = createSynthTile(anchor, note, parent)
							synthTile.releaseAt = os.clock() + hold
							pressPhysicalKey(v6[note], hold)
						end
					end
				end)
			end

			local v7 = os.clock() + v3 + 0.75

			while v4 and advertiseModel.Parent and os.clock() < v7 do
				task.wait(0.1)
			end
		else
			local v7 = os.clock() + 1

			while v4 and advertiseModel.Parent and os.clock() < v7 do
				task.wait(0.1)
			end
		end
	end

	v4 = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
	end

	if ancestryChangedConnection then
		ancestryChangedConnection:Disconnect()
	end

	for k in pairs(v) do
		destroyActiveTile(k) -- inferred equivalent call
	end

	table.clear(v)

	if parent and parent.Parent then
		parent:Destroy()
	end
end

while true do
	local advertiseModel = getAdvertiseModel() -- inferred equivalent call

	if advertiseModel then
		runPreview(advertiseModel)
	end

	task.wait(1)
end