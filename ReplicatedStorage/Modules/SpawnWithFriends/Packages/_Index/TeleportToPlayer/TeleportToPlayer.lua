local Players = game:GetService("Players")

local TeleportToPlayer = {}

function TeleportToPlayer.getCharacterTeleportPoint(instance, p: number)
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance and instance:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return
	end

	local characters = { instance }

	for _, child in ipairs(Players:GetChildren()) do
		table.insert(characters, child.Character)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = characters

	for i = 1, 10 do
		local v = humanoidRootPart.CFrame * CFrame.Angles(0, 6.283185307179586 * (i / 10), 0)

		if workspace:Raycast(humanoidRootPart.Position, v.LookVector * 5, raycastParams) then
			continue
		end

		local v2 = v + v.LookVector * p

		local raycastResult = workspace:Raycast(v2.Position, Vector3.new(0, -100, 0), raycastParams)
		local position = raycastResult and raycastResult.Position

		if position then
			local vector3 = Vector3.new(humanoidRootPart.CFrame.X, position.Y, humanoidRootPart.CFrame.Z)
			return CFrame.lookAt(position, vector3)
		end
	end
end

function TeleportToPlayer.teleport(player, player2, value: number): boolean
	local characterTeleportPoint = TeleportToPlayer.getCharacterTeleportPoint(player2.Character, value or 5)

	if not (characterTeleportPoint and TeleportToPlayer.validate(player, player2, characterTeleportPoint)) then
		return false
	end

	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")

	if not (humanoidRootPart and humanoid) then
		return false
	end

	if humanoid.Sit then
		humanoid.Sit = false
		humanoid.Seated:Wait()
	end

	local v = humanoid.HipHeight + humanoidRootPart.Size.Y / 2

	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		local leftLeg = humanoid.Parent:FindFirstChild("Left Leg") or humanoid.Parent:FindFirstChild("Right Leg")

		if leftLeg then
			v += leftLeg.Size.Y
		end
	end

	humanoidRootPart.CFrame = characterTeleportPoint + Vector3.new(0, v, 0)
	return true
end

function TeleportToPlayer.validate(_, _, _: CFrame): boolean
	return true
end

function TeleportToPlayer.setTeleportationValidator(validate)
	assert(typeof(validate) == "function", "setTeleportationValidator expects a function as its first argument")
	TeleportToPlayer.validate = validate
end

return TeleportToPlayer