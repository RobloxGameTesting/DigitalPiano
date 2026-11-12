local ReplicatedStorage = game:GetService("ReplicatedStorage")

local pianoOnFireEffect = ReplicatedStorage:WaitForChild("Items"):WaitForChild("PianoOnFireEffect")

local PianoOnFireVfxBuilder = {
	EffectItemId = "EffectPianoOnFire",
	DefaultFolderName = "PianoOnFireVFX",
	CenterGlowTemplateName = "CenterGlowTemplate",
	CenterGlowAttachmentName = "Part.b224",
	CenterGlowOriginalSize = 7
}

local v = {
	"BodyTop_Flames",
	"Keyboard_Flames",
	"FrontFace_Flames",
	"LeftEnd_Flames",
	"RightEnd_Flames"
}

local function clamp(p, p2, p3) -- 10 equivalent calls inferred from this helper
	if p < p2 then
		return p2
	end

	return if p3 < p then p3 else p
end

local function scaleNumberSequence(size, scale)
	local keypoints = size.Keypoints
	local numberSequenceKeypoints = table.create(#keypoints)

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * scale,
			keypoint.Envelope * scale
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function isDescendantOfNamed(instance, p): boolean
	while instance do
		if p[instance.Name] then
			return true
		end

		instance = instance.Parent
	end

	return false
end

local function collectBaseParts(part, callback)
	local parts = {}

	if part:IsA("BasePart") and (not callback or callback(part)) then
		table.insert(parts, part)
	end

	for _, part2 in ipairs(part:GetDescendants()) do
		if part2:IsA("BasePart") and (not callback or callback(part2)) then
			table.insert(parts, part2)
		end
	end

	return parts
end

local function orientedBoundsFromParts(list, p)
	if #list == 0 then
		return nil, nil
	end

	local cframe = p or CFrame.new()
	local v2 = Vector3.new(1e999, 1e999, 1e999)
	local v3 = Vector3.new(-1e999, -1e999, -1e999)

	for _, item in ipairs(list) do
		local v4 = item.Size * 0.5
		local v5 = {
			Vector3.new(-v4.X, -v4.Y, -v4.Z),
			Vector3.new(-v4.X, -v4.Y, v4.Z),
			Vector3.new(-v4.X, v4.Y, -v4.Z),
			Vector3.new(-v4.X, v4.Y, v4.Z),
			Vector3.new(v4.X, -v4.Y, -v4.Z),
			Vector3.new(v4.X, -v4.Y, v4.Z),
			Vector3.new(v4.X, v4.Y, -v4.Z),
			(Vector3.new(v4.X, v4.Y, v4.Z))
		}

		for _, v6 in ipairs(v5) do
			local pointToObjectSpace = cframe:PointToObjectSpace(item.CFrame:PointToWorldSpace(v6))
			v2 = Vector3.new(
				math.min(v2.X, pointToObjectSpace.X),
				math.min(v2.Y, pointToObjectSpace.Y),
				(math.min(v2.Z, pointToObjectSpace.Z))
			)

			v3 = Vector3.new(
				math.max(v3.X, pointToObjectSpace.X),
				math.max(v3.Y, pointToObjectSpace.Y),
				(math.max(v3.Z, pointToObjectSpace.Z))
			)
		end
	end

	local v4 = (v2 + v3) * 0.5
	local v5 = v3 - v2
	return cframe * CFrame.new(v4), v5
end

local function getBounds(part, pivot, callback)
	if not part then
		return nil, nil
	end

	if part:IsA("BasePart") and (not callback or callback(part)) then
		return part.CFrame, part.Size
	end

	return orientedBoundsFromParts(collectBaseParts(part, callback), pivot)
end

local function findKeysBounds(instance)
	local keys = instance:FindFirstChild("Keys") or instance:FindFirstChild("Keys", true)

	if not keys then
		return nil, nil
	end

	local keyBox = keys:FindFirstChild("KeyBox", true)

	if keyBox and keyBox:IsA("BasePart") then
		return keyBox.CFrame, keyBox.Size
	end

	return getBounds(keys, instance:GetPivot())
end

local function findBodyBounds(instance)
	local pianoColor = instance:FindFirstChild("PianoColor", true)

	if pianoColor then
		local pivot, v2 = instance:GetPivot()
		local v3, v4

		if pianoColor then
			if pianoColor:IsA("BasePart") and (not v2 or v2(pianoColor)) then
				v3 = pianoColor.CFrame
				v4 = pianoColor.Size
			else
				v3, v4 = orientedBoundsFromParts(collectBaseParts(pianoColor, v2), pivot)
			end
		end

		if v3 and v4 then
			return v3, v4
		end
	end

	local piano = instance:FindFirstChild("Piano")

	if piano then
		local pivot, v2 = instance:GetPivot()
		local v3, v4

		if piano then
			if piano:IsA("BasePart") and (not v2 or v2(piano)) then
				v3 = piano.CFrame
				v4 = piano.Size
			else
				v3, v4 = orientedBoundsFromParts(collectBaseParts(piano, v2), pivot)
			end
		end

		if v3 and v4 then
			return v3, v4
		end
	end

	local v2 = {
		Keys = true,
		Bench = true,
		Seat = true,
		Seat2 = true,
		SeatOccupant = true,
		SeatOccupants = true,
		Zone = true,
		ActiveNotes = true,
		Cameras = true,
		Scripts = true,
		PianoOnFireVFX = true,
		LocalPianoOnFireShopPreview = true
	}

	return orientedBoundsFromParts(collectBaseParts(instance, function(instance2): boolean
		if instance2:IsA("Seat") or instance2:IsA("VehicleSeat") then
			return false
		end

		local v3

		while true do
			if not instance2 then
				v3 = false
				break
			end

			if v2[instance2.Name] then
				v3 = true
				break
			end

			instance2 = instance2.Parent
		end

		return not v3
	end), instance:GetPivot())
end

local function addSpec(list, name, cframe, data)
	if cframe and data and data.X > 0.05 and data.Y > 0.02 and data.Z > 0.05 then
		local v2 = {
			Name = name,
			CFrame = cframe,
			Size = Vector3.new(clamp(data.X, 0.3, 10), clamp(data.Y, 0.05, 6), clamp(data.Z, 0.08, 10)) -- inferred equivalent call
		}
		table.insert(list, v2)
	end
end

local function getAnchorSpecs(part)
	local pianoEffectAnchors = part:FindFirstChild("PianoEffectAnchors")

	if not pianoEffectAnchors then
		return nil
	end

	local v2 = {}

	for _, childName in ipairs(v) do
		local instance = pianoEffectAnchors:FindFirstChild(childName)

		if not instance then
			continue
		end

		if instance:IsA("BasePart") then
			addSpec(v2, childName, instance.CFrame, instance.Size)
		elseif instance:IsA("Attachment") then
			local vector3 = Vector3.new(
				tonumber(instance:GetAttribute("SizeX")) or 2,
				tonumber(instance:GetAttribute("SizeY")) or 0.08,
				tonumber(instance:GetAttribute("SizeZ")) or 2
			)

			addSpec(v2, childName, instance.WorldCFrame, vector3)
		end
	end

	return if #v2 > 0 then v2 else nil
end

local function buildPadSpecs(part)
	local anchorSpecs = getAnchorSpecs(part)

	if anchorSpecs then
		return anchorSpecs
	end

	local v2 = {}
	local keysBounds, v3 = findKeysBounds(part)
	local bodyBounds, v4 = findBodyBounds(part)

	if bodyBounds and v4 then
		addSpec(
			v2,
			"BodyTop_Flames",
			bodyBounds * CFrame.new(0, v4.Y * 0.5 + 0.08, 0),
			Vector3.new(v4.X * 0.86, 0.08, v4.Z * 0.82)
		)

		local v5 = "Z"
		local v6

		if keysBounds then
			local pointToObjectSpace = bodyBounds:PointToObjectSpace(keysBounds.Position)

			if math.abs(pointToObjectSpace.X) > math.abs(pointToObjectSpace.Z) then
				v6 = pointToObjectSpace.X >= 0 and 1 or -1
				v5 = "X"
			else
				v6 = pointToObjectSpace.Z >= 0 and 1 or -1
			end
		else
			v6 = -1
		end

		if v5 == "X" then
			addSpec(
				v2,
				"FrontFace_Flames",
				bodyBounds * CFrame.new(v6 * (v4.X * 0.5 + 0.05), 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0),
				Vector3.new(v4.Z * 0.82, v4.Y * 0.72, 0.08)
			)
			addSpec(
				v2,
				"LeftEnd_Flames",
				bodyBounds * CFrame.new(0, 0, v4.Z * 0.5 + 0.05),
				Vector3.new(v4.X * 0.58, v4.Y * 0.66, 0.08)
			)
			addSpec(
				v2,
				"RightEnd_Flames",
				bodyBounds * CFrame.new(0, 0, -(v4.Z * 0.5 + 0.05)),
				Vector3.new(v4.X * 0.58, v4.Y * 0.66, 0.08)
			)
		else
			addSpec(
				v2,
				"FrontFace_Flames",
				bodyBounds * CFrame.new(0, 0, v6 * (v4.Z * 0.5 + 0.05)),
				Vector3.new(v4.X * 0.82, v4.Y * 0.72, 0.08)
			)
			addSpec(
				v2,
				"LeftEnd_Flames",
				bodyBounds * CFrame.new(v4.X * 0.5 + 0.05, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0),
				Vector3.new(v4.Z * 0.58, v4.Y * 0.66, 0.08)
			)
			addSpec(
				v2,
				"RightEnd_Flames",
				bodyBounds * CFrame.new(-(v4.X * 0.5 + 0.05), 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0),
				Vector3.new(v4.Z * 0.58, v4.Y * 0.66, 0.08)
			)
		end
	end

	if keysBounds and v3 then
		addSpec(v2, "Keyboard_Flames", keysBounds * CFrame.new(0, v3.Y * 0.5 + 0.07, 0), Vector3.new(v3.X, 0.08, v3.Z))
	end

	if #v2 ~= 0 then
		return v2
	end

	local pivot, v5 = part:GetPivot()
	local v6, v7

	if part then
		if part:IsA("BasePart") and (not v5 or v5(part)) then
			v6 = part.CFrame
			v7 = part.Size
		else
			v6, v7 = orientedBoundsFromParts(collectBaseParts(part, v5), pivot)
		end
	end

	if v6 and v7 then
		addSpec(
			v2,
			"BodyTop_Flames",
			v6 * CFrame.new(0, v7.Y * 0.5 + 0.08, 0),
			Vector3.new(v7.X * 0.75, 0.08, v7.Z * 0.75)
		)
	end

	return v2
end

local function buildCenterGlowSpec(instance)
	local pianoEffectAnchors = instance:FindFirstChild("PianoEffectAnchors")
	local centerGlow = pianoEffectAnchors
		and (pianoEffectAnchors:FindFirstChild("CenterGlow") or pianoEffectAnchors:FindFirstChild(PianoOnFireVfxBuilder.CenterGlowAttachmentName))

	if centerGlow then
		local glowScale = tonumber(centerGlow:GetAttribute("GlowScale")) or 1

		if centerGlow:IsA("Attachment") then
			return { CFrame = centerGlow.WorldCFrame, Scale = clamp(glowScale, 0.45, 2.5) } -- inferred equivalent call
		end

		if centerGlow:IsA("BasePart") then
			local v2 = math.max(
				centerGlow.Size.X,
				centerGlow.Size.Y,
				centerGlow.Size.Z,
				PianoOnFireVfxBuilder.CenterGlowOriginalSize
			)
			return {
				CFrame = centerGlow.CFrame,
				Scale = clamp(glowScale * v2 / PianoOnFireVfxBuilder.CenterGlowOriginalSize, 0.45, 2.5) -- inferred equivalent call
			}
		end
	end

	local keysBounds, v2 = findKeysBounds(instance)
	local bodyBounds, v3 = findBodyBounds(instance)
	local v4 = bodyBounds or keysBounds

	if not v4 then
		return nil
	end

	local v5 = Vector3.new(0, 0, 0)

	if bodyBounds and v3 then
		v5 = Vector3.new(0, v3.Y * 0.2, 0)

		if keysBounds then
			local pointToObjectSpace = bodyBounds:PointToObjectSpace(keysBounds.Position)

			local v6 = clamp(pointToObjectSpace.X * 0.35, -v3.X * 0.25, v3.X * 0.25) -- inferred equivalent call
			local v7 = v3.Y * 0.2
			v5 = Vector3.new(v6, v7, clamp(pointToObjectSpace.Z * 0.35, -v3.Z * 0.25, v3.Z * 0.25)) -- inferred equivalent call
		end
	elseif keysBounds and v2 then
		v5 = Vector3.new(0, v2.Y * 0.5 + 0.1, 0)
	end

	local centerGlowOriginalSize = PianoOnFireVfxBuilder.CenterGlowOriginalSize

	if v3 then
		centerGlowOriginalSize = math.max(centerGlowOriginalSize, v3.X * 0.7, v3.Z * 0.9)
	end

	if v2 then
		centerGlowOriginalSize = math.max(centerGlowOriginalSize, v2.X * 0.85, v2.Z * 2)
	end

	local v6 = clamp(centerGlowOriginalSize, 4.5, 14) -- inferred equivalent call
	return {
		CFrame = v4 * CFrame.new(v5),
		Scale = clamp(v6 / PianoOnFireVfxBuilder.CenterGlowOriginalSize, 0.65, 2) -- inferred equivalent call
	}
end

local function setVfxEnabled(folder)
	if folder:IsA("ParticleEmitter") then
		folder.Enabled = true
	elseif folder:IsA("Light") then
		folder.Enabled = true
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = true
		elseif descendant:IsA("Light") then
			descendant.Enabled = true
		end
	end
end

local function getTemplatePart(childName)
	local part = pianoOnFireEffect:FindFirstChild(childName)

	if part and part:IsA("BasePart") then
		return part
	end

	for _, part2 in ipairs(pianoOnFireEffect:GetChildren()) do
		if part2:IsA("BasePart") then
			return part2
		end
	end

	return nil
end

local function addFallbackVfx(parent)
	local fallbackFlames = Instance.new("ParticleEmitter")
	fallbackFlames.Name = "FallbackFlames"
	fallbackFlames.Color = ColorSequence.new(Color3.fromRGB(255, 226, 98), Color3.fromRGB(255, 76, 18))
	fallbackFlames.LightEmission = 0.75
	fallbackFlames.Lifetime = NumberRange.new(0.5, 1)
	fallbackFlames.Rate = 55
	fallbackFlames.Speed = NumberRange.new(1.3, 4)
	fallbackFlames.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(0.45, 1),
		NumberSequenceKeypoint.new(1, 0.1)
	})

	fallbackFlames.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 1)
	})

	fallbackFlames.Parent = parent

	local fallbackGlow = Instance.new("PointLight")
	fallbackGlow.Name = "FallbackGlow"
	fallbackGlow.Color = Color3.fromRGB(255, 111, 32)
	fallbackGlow.Brightness = 2
	fallbackGlow.Range = 7
	fallbackGlow.Parent = parent
end

local function copyTemplateVfx(name, part)
	local templatePart = getTemplatePart(name)

	if not templatePart then
		addFallbackVfx(part)
		return
	end

	local v2 = false

	for _, child in ipairs(templatePart:GetChildren()) do
		local clone = child:Clone()
		setVfxEnabled(clone)
		clone.Parent = part
		v2 = true
	end

	if not v2 then
		addFallbackVfx(part)
	end
end

local function getCenterGlowTemplateAttachment() -- 1 equivalent call inferred from this helper
	local child = pianoOnFireEffect:FindFirstChild(PianoOnFireVfxBuilder.CenterGlowTemplateName)
	local attachment = child and child:FindFirstChild(PianoOnFireVfxBuilder.CenterGlowAttachmentName)
		or pianoOnFireEffect:FindFirstChild(PianoOnFireVfxBuilder.CenterGlowAttachmentName, true)

	if attachment and attachment:IsA("Attachment") then
		return attachment
	end

	return nil
end

local function createCenterGlow(folder, parent)
	local centerGlowTemplateAttachment = getCenterGlowTemplateAttachment() -- inferred equivalent call
	local v2 = centerGlowTemplateAttachment and buildCenterGlowSpec(parent)

	if not (centerGlowTemplateAttachment and v2) then
		return
	end

	local centerGlow_Partb224 = Instance.new("Part")
	centerGlow_Partb224.Name = "CenterGlow_Part.b224"
	centerGlow_Partb224.Anchored = true
	centerGlow_Partb224.CanCollide = false
	centerGlow_Partb224.CanTouch = false
	centerGlow_Partb224.CanQuery = false
	centerGlow_Partb224.Massless = true
	centerGlow_Partb224.Transparency = 1
	centerGlow_Partb224.Size = Vector3.new(0.2, 0.2, 0.2)
	centerGlow_Partb224.CFrame = v2.CFrame
	centerGlow_Partb224.Parent = folder

	local clone = centerGlowTemplateAttachment:Clone()
	clone.Name = PianoOnFireVfxBuilder.CenterGlowAttachmentName
	clone.CFrame = CFrame.new()
	clone.Parent = centerGlow_Partb224

	for _, emitter in ipairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		emitter.Size = scaleNumberSequence(emitter.Size, v2.Scale)
	end

	local centerGlowLight = Instance.new("PointLight")
	centerGlowLight.Name = "CenterGlowLight"
	centerGlowLight.Color = Color3.fromRGB(255, 94, 0)
	centerGlowLight.Brightness = 1.2
	centerGlowLight.Range = clamp(PianoOnFireVfxBuilder.CenterGlowOriginalSize * v2.Scale * 1.35, 7, 18) -- inferred equivalent call
	centerGlowLight.Parent = centerGlow_Partb224
end

function PianoOnFireVfxBuilder.IsSupportedPiano(model)
	return model and model:IsA("Model") and model:GetAttribute("UseDefaultSynthesia") == true
end

function PianoOnFireVfxBuilder.DestroyEffect(instance, p)
	if not instance then
		return
	end

	local child = instance:FindFirstChild(p or PianoOnFireVfxBuilder.DefaultFolderName)

	if child then
		child:Destroy()
	end
end

function PianoOnFireVfxBuilder.CreateEffectFolder(parent, options)
	if not PianoOnFireVfxBuilder.IsSupportedPiano(parent) then
		return nil
	end

	local v2 = options or {}
	local folderName = v2.FolderName or PianoOnFireVfxBuilder.DefaultFolderName
	PianoOnFireVfxBuilder.DestroyEffect(parent, folderName)

	local padSpecs = buildPadSpecs(parent)

	if #padSpecs == 0 then
		return nil
	end

	local folder = Instance.new("Folder")
	folder.Name = folderName
	folder:SetAttribute("EffectItemId", v2.EffectItemId or PianoOnFireVfxBuilder.EffectItemId)
	folder:SetAttribute("SourceTemplate", "ReplicatedStorage.Items.PianoOnFireEffect")
	folder:SetAttribute("UsesPartB224GlowAttachment", true)
	folder:SetAttribute("CenterGlowMode", "SingleScaledCenter")

	if v2.IsLocalPreview == true then
		folder:SetAttribute("IsLocalPreview", true)
	end

	if v2.Owner and v2.Owner.UserId then
		folder:SetAttribute("ActiveOwnerUserId", v2.Owner.UserId)
	elseif typeof(v2.OwnerUserId) == "number" then
		folder:SetAttribute("ActiveOwnerUserId", v2.OwnerUserId)
	end

	folder.Parent = parent

	for _, padSpec in ipairs(padSpecs) do
		local part = Instance.new("Part")
		part.Name = padSpec.Name
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		part.Transparency = 1
		part.Size = padSpec.Size
		part.CFrame = padSpec.CFrame
		part.Parent = folder
		copyTemplateVfx(padSpec.Name, part)
	end

	createCenterGlow(folder, parent)

	return folder
end

return PianoOnFireVfxBuilder