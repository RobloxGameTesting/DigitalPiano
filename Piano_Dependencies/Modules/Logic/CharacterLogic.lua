local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local v = {}
local v2 = nil

local function currentCamera() -- 4 equivalent calls inferred from this helper
	CurrentCamera = Workspace.CurrentCamera or CurrentCamera
	return CurrentCamera
end

local function getCameraTargetCFrame(instance) -- 1 equivalent call inferred from this helper
	if not instance then
		return nil
	end

	if instance:IsA("BasePart") or instance:IsA("Camera") then
		return instance.CFrame
	end

	if instance:IsA("Attachment") then
		return instance.WorldCFrame
	end

	return nil
end

local function headOf(p) -- 1 equivalent call inferred from this helper
	return p and p.Parent and p.Parent:FindFirstChild("Head")
end

local function seatOf(p)
	if not p then
		return nil
	end

	return if p.SeatPart then p.SeatPart else nil
end

local function pianoFromSeat(model)
	if not model then
		return nil
	end

	local count = 0

	while model and count < 6 do
		if model:IsA("Model") and (model.Name:lower():find("piano") or model:FindFirstChild("PianoUI")) then
			return model
		end

		count += 1
		model = model.Parent
	end

	return nil
end

local function keyboardPart(folder)
	if not folder then
		return nil
	end

	for _, childName in ipairs({ "Keyboard", "Keys", "PianoKeys", "Keybed", "KeyBoard" }) do
		local part = folder:FindFirstChild(childName, true)

		if part and part:IsA("BasePart") then
			return part
		end
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") and part.Name:lower():find("key") then
			return part
		end
	end

	return nil
end

local function getFreeCameraCFrame(cameraSubject)
	local v3 = headOf(cameraSubject) -- inferred equivalent call

	if not v3 then
		return nil
	end

	local position = (v3.CFrame * CFrame.new(0.7, 1.1, 2.2)).Position
	local seatPart

	if cameraSubject and cameraSubject.SeatPart then
		seatPart = cameraSubject.SeatPart
	end

	local part = keyboardPart(pianoFromSeat(seatPart))
	local v4

	if part and part:IsA("BasePart") then
		v4 = part.Position + Vector3.new(0, -0.35, 0)
	elseif seatPart then
		v4 = seatPart.Position + seatPart.CFrame.LookVector * 3 + Vector3.new(0, -0.35, 0)
	else
		v4 = v3.Position + v3.CFrame.LookVector * 3 + Vector3.new(0, -0.35, 0)
	end

	return CFrame.new(position, v4)
end

local function enableCustomCamera(p, cameraSubject) -- 2 equivalent calls inferred from this helper
	LocalPlayer.CameraMode = Enum.CameraMode.Classic
	LocalPlayer.CameraMinZoomDistance = 3
	LocalPlayer.CameraMaxZoomDistance = 20
	p.CameraType = Enum.CameraType.Custom
	p.CameraSubject = cameraSubject
end

local function applyFreeCamera(cameraSubject, flag: boolean, value: number?, cframe: CFrame?): boolean
	local CurrentCamera2 = currentCamera() -- inferred equivalent call

	if not (CurrentCamera2 and cameraSubject) then
		return false
	end

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	if typeof(cframe) ~= "CFrame" or not cframe then
		if flag then
			cframe = getFreeCameraCFrame(cameraSubject) or nil
		else
			cframe = nil
		end
	end

	local v3 = typeof(value) == "number" and value or 0

	if cframe and v3 > 0 then
		LocalPlayer.CameraMode = Enum.CameraMode.Classic
		LocalPlayer.CameraMinZoomDistance = 3
		LocalPlayer.CameraMaxZoomDistance = 20
		CurrentCamera2.CameraType = Enum.CameraType.Scriptable
		CurrentCamera2.CameraSubject = nil

		local tween = TweenService:Create(
			CurrentCamera2,
			TweenInfo.new(v3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = cframe }
		)

		v2 = tween
		tween.Completed:Connect(function()
			if v2 == tween then
				v2 = nil

				if cameraSubject and cameraSubject.Parent then
					enableCustomCamera(CurrentCamera2, cameraSubject) -- inferred equivalent call
				end
			end
		end)
		tween:Play()
		return true
	end

	if cframe then
		CurrentCamera2.CFrame = cframe
	end

	enableCustomCamera(CurrentCamera2, cameraSubject) -- inferred equivalent call
	return true
end

local CharacterLogic = {}

function CharacterLogic.AddCamera(p)
	local CurrentCamera2 = currentCamera() -- inferred equivalent call

	if not CurrentCamera2 then
		return
	end

	v = {
		mode = LocalPlayer.CameraMode,
		minZoom = LocalPlayer.CameraMinZoomDistance,
		maxZoom = LocalPlayer.CameraMaxZoomDistance,
		type = CurrentCamera2.CameraType,
		subject = CurrentCamera2.CameraSubject,
		cf = CurrentCamera2.CFrame
	}

	applyFreeCamera(p, true)
	ClientDebugConfig.Print("[CharacterLogic] Free camera enabled; piano NOT modified.")
end

function CharacterLogic.UseFreeCamera(cameraSubject, flag: boolean?, p: number?, cframe: CFrame?)
	return applyFreeCamera(cameraSubject, flag ~= false, p, cframe)
end

function CharacterLogic.SetScriptedCamera(instance, value: number?): boolean
	local CurrentCamera2 = currentCamera() -- inferred equivalent call
	local cameraTargetCFrame = getCameraTargetCFrame(instance) -- inferred equivalent call

	if not (CurrentCamera2 and cameraTargetCFrame) then
		return false
	end

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	LocalPlayer.CameraMode = Enum.CameraMode.Classic
	LocalPlayer.CameraMinZoomDistance = 3
	LocalPlayer.CameraMaxZoomDistance = 20
	CurrentCamera2.CameraType = Enum.CameraType.Scriptable
	CurrentCamera2.CameraSubject = nil

	local v3 = typeof(value) == "number" and value or 0.35

	if v3 > 0 then
		local tween = TweenService:Create(
			CurrentCamera2,
			TweenInfo.new(v3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = cameraTargetCFrame }
		)

		v2 = tween
		tween.Completed:Connect(function()
			if v2 == tween then
				v2 = nil
			end
		end)
		tween:Play()
	else
		CurrentCamera2.CFrame = cameraTargetCFrame
	end

	return true
end

function CharacterLogic.RevokeCamera()
	local CurrentCamera2 = currentCamera() -- inferred equivalent call

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	if v.mode then
		LocalPlayer.CameraMode = v.mode
	end

	if v.minZoom then
		LocalPlayer.CameraMinZoomDistance = v.minZoom
	end

	if v.maxZoom then
		LocalPlayer.CameraMaxZoomDistance = v.maxZoom
	end

	if CurrentCamera2 then
		CurrentCamera2.CameraType = v.type or Enum.CameraType.Custom
		CurrentCamera2.CameraSubject = v.subject

		if v.cf then
			CurrentCamera2.CFrame = v.cf
		end
	end

	ClientDebugConfig.Print("[CharacterLogic] Camera restored; piano untouched.")
end

return CharacterLogic