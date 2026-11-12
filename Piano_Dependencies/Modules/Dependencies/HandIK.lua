local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local HandIK = {}

local v = {}
local cleanupCharacter

local function homeCF(cframe, p) -- 3 equivalent calls inferred from this helper
	return cframe * CFrame.new(p and Vector3.new(0.25, -0.55, -0.7) or Vector3.new(-0.25, -0.55, -0.7))
end

local function cancelTween(object) -- 7 equivalent calls inferred from this helper
	if object and object.PlaybackState == Enum.PlaybackState.Playing then
		object:Cancel()
	end
end

local function makeTarget(name) -- 2 equivalent calls inferred from this helper
	local part = Instance.new("Part")
	part.Name = name
	part.Size = Vector3.new(0.05, 0.05, 0.05)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Parent = workspace
	return part
end

local function makeIK(name, parent, chainRoot, endEffector, target) -- 2 equivalent calls inferred from this helper
	local ikControl = Instance.new("IKControl")
	local position = Enum.IKControlType.Position
	ikControl.Name = name
	ikControl.Type = position
	ikControl.ChainRoot = chainRoot
	ikControl.EndEffector = endEffector
	ikControl.Target = target
	ikControl.Priority = 2
	ikControl.Weight = 1
	ikControl.Parent = parent
	return ikControl
end

local function ensureIK(instance)
	if v[instance] then
		return v[instance]
	end

	if not instance:FindFirstChildOfClass("Humanoid") then
		return nil
	end

	local rightUpperArm = instance:FindFirstChild("RightUpperArm")
	local rightHand = instance:FindFirstChild("RightHand")
	local leftUpperArm = instance:FindFirstChild("LeftUpperArm")
	local leftHand = instance:FindFirstChild("LeftHand")

	if not (rightUpperArm and rightHand and leftUpperArm and leftHand) then
		return nil
	end

	local v2 = {
		right = {
			baseCF = nil,
			downCF = nil,
			holding = false,
			note = nil,
			seq = 0,
			pressTween = nil,
			liftTween = nil
		},
		left = {
			baseCF = nil,
			downCF = nil,
			holding = false,
			note = nil,
			seq = 0,
			pressTween = nil,
			liftTween = nil
		}
	}
	local target = makeTarget("RightHandTarget") -- inferred equivalent call
	local target2 = makeTarget("LeftHandTarget") -- inferred equivalent call
	local ik = makeIK("RightArmIK", instance, rightUpperArm, rightHand, target) -- inferred equivalent call
	local ik2 = makeIK("LeftArmIK", instance, leftUpperArm, leftHand, target2) -- inferred equivalent call
	v2.rightTarget = target
	v2.leftTarget = target2
	v2.rightIK = ik
	v2.leftIK = ik2

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		target.CFrame = humanoidRootPart.CFrame * CFrame.new(Vector3.new(0.25, -0.55, -0.7))
		target2.CFrame = homeCF(humanoidRootPart.CFrame) -- inferred equivalent call
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter then
		v2.enabledConnection = playerFromCharacter:GetAttributeChangedSignal("HandIKEnabled"):Connect(function()
			if playerFromCharacter:GetAttribute("HandIKEnabled") == false and cleanupCharacter then
				cleanupCharacter(instance)
			end
		end)
	end

	v[instance] = v2
	return v2
end

local function frontOfKeyCF(instance) -- 1 equivalent call inferred from this helper
	local upVector = instance.CFrame.UpVector
	local lookVector = instance.CFrame.LookVector

	return (CFrame.new(instance.Position + upVector * (instance.Size.Y / 2 + 0.02) + lookVector * (instance.Size.Z / 2 + 0.18)))
end

local function handStateFor(p, p2) -- 2 equivalent calls inferred from this helper
	return p2 and p.right or p.left
end

cleanupCharacter = function(p)
	local v2 = v[p]

	if not v2 then
		return
	end

	for _, v3 in ipairs({ v2.right, v2.left }) do
		cancelTween(v3.pressTween) -- inferred equivalent call
		cancelTween(v3.liftTween) -- inferred equivalent call
	end

	if v2.enabledConnection then
		v2.enabledConnection:Disconnect()
		v2.enabledConnection = nil
	end

	if v2.rightIK then
		v2.rightIK:Destroy()
	end

	if v2.leftIK then
		v2.leftIK:Destroy()
	end

	if v2.rightTarget then
		v2.rightTarget:Destroy()
	end

	if v2.leftTarget then
		v2.leftTarget:Destroy()
	end

	v[p] = nil
end

local function findPianoFromInstance(instance)
	if not instance then
		return nil
	end

	local v2 = instance:FindFirstAncestorOfClass("Model")

	while v2 do
		if v2:FindFirstChild("Keys") and v2:FindFirstChild("SeatOccupant") then
			return v2
		end

		v2 = v2.Parent
	end

	return nil
end

local function findPianoFromCharacter(character) -- 1 equivalent call inferred from this helper
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local seatPart = humanoid and humanoid.SeatPart
	return findPianoFromInstance(seatPart)
end

local function shouldSkipHandIK(character, p): boolean
	local playerFromCharacter = character and Players:GetPlayerFromCharacter(character)

	if playerFromCharacter and playerFromCharacter:GetAttribute("HandIKEnabled") == false then
		return true
	end

	local v2 = findPianoFromInstance(p) or findPianoFromCharacter(character) -- inferred equivalent call

	if v2 then
		return v2:GetAttribute("DisableHandIK") == true or v2:GetAttribute("UseHandIK") == false
	end

	return false
end

function HandIK.PressKey(parent, instance, note)
	if not (parent and instance) then
		return
	end

	if shouldSkipHandIK(parent, instance) then
		cleanupCharacter(parent)
		return
	end

	local ik = ensureIK(parent)

	if not ik then
		return
	end

	local v2 = (note or 100) >= 44
	local rightTarget = v2 and ik.rightTarget or ik.leftTarget
	local v3 = handStateFor(ik, v2) -- inferred equivalent call
	v3.seq = (v3.seq or 0) + 1
	local _seq = v3.seq
	cancelTween(v3.pressTween) -- inferred equivalent call
	cancelTween(v3.liftTween) -- inferred equivalent call
	v3.pressTween = nil
	v3.liftTween = nil
	local v4 = frontOfKeyCF(instance) -- inferred equivalent call
	local v5 = v4 * CFrame.new(0, -0.5, 0)

	v3.baseCF = v4
	v3.downCF = v5
	v3.holding = true
	v3.note = note

	rightTarget.CFrame = v4

	rightTarget.CFrame = v5

	if (not v3.holding or v3.note ~= note) and v3.baseCF then
		rightTarget.CFrame = v3.baseCF
	end
end

function HandIK.ReleaseKey(p, value)
	local v2 = v[p]

	if not v2 then
		return
	end

	local v3 = (value or 100) >= 44
	local rightTarget = v3 and v2.rightTarget or v2.leftTarget
	local v4 = handStateFor(v2, v3) -- inferred equivalent call

	if v4.note ~= value then
		return
	end

	v4.holding = false

	cancelTween(v4.pressTween) -- inferred equivalent call
	v4.pressTween = nil

	if v4.baseCF and rightTarget then
		v4.seq = (v4.seq or 0) + 1

		rightTarget.CFrame = v4.baseCF
	end
end

function HandIK.ToHome(instance)
	if shouldSkipHandIK(instance, nil) then
		cleanupCharacter(instance)
		return
	end

	local ik = ensureIK(instance)

	if not ik then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local cframe = homeCF(humanoidRootPart.CFrame, true) -- inferred equivalent call
	local cframe2 = homeCF(humanoidRootPart.CFrame, false) -- inferred equivalent call

	for _, v2 in ipairs({ ik.right, ik.left }) do
		cancelTween(v2.pressTween) -- inferred equivalent call
		cancelTween(v2.liftTween) -- inferred equivalent call
		v2.pressTween = nil
		v2.liftTween = nil
		v2.holding = false
		v2.note = nil
		v2.seq = (v2.seq or 0) + 1
	end

	TweenService:Create(ik.rightTarget, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = cframe
	}):Play()
	TweenService:Create(ik.leftTarget, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		CFrame = cframe2
	}):Play()
end

function HandIK.OnLeave(_) end

function HandIK.Cleanup(p)
	cleanupCharacter(p)
end

return HandIK