local HDAdminMain = _G.HDAdminMain

local function setCollisionGroupRecursive(folder, p)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			HDAdminMain.physicsService:SetPartCollisionGroup(part, p)
		end
	end
end

return {
	Fly = function(_, p, p2)
		local v = p == "fly2" and "Sit" or "PlatformStand"

		local hrp = HDAdminMain:GetModule("cf"):GetHRP()
		local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid()

		if hrp and humanoid then
			local hdAdminFlyForce = Instance.new("BodyPosition")
			hdAdminFlyForce.MaxForce = Vector3.new(1e999, 1e999, 1e999)
			hdAdminFlyForce.Position = hrp.Position + Vector3.new(0, 4, 0)
			hdAdminFlyForce.Name = "HDAdminFlyForce"
			hdAdminFlyForce.Parent = hrp
			local hdAdminFlyGyro = Instance.new("BodyGyro")
			hdAdminFlyGyro.D = 50
			hdAdminFlyGyro.MaxTorque = Vector3.new(1e999, 1e999, 1e999)

			if p2 then
				hdAdminFlyGyro.P = 2000
			else
				hdAdminFlyGyro.P = 200
			end

			hdAdminFlyGyro.Name = "HDAdminFlyGyro"
			hdAdminFlyGyro.CFrame = hrp.CFrame
			hdAdminFlyGyro.Parent = hrp

			local v2 = 0

			local count = 0

			if p2 then
				setCollisionGroupRecursive(workspace, "Group1")
				setCollisionGroupRecursive(HDAdminMain.player.Character, "Group2")
			end

			local lastTime = tick()
			local position = hrp.Position

			repeat
				local v3 = tick() - lastTime
				local unit = (HDAdminMain.camera.Focus.p - HDAdminMain.camera.CFrame.p).unit
				local commandSpeed = HDAdminMain.commandSpeeds[p]
				local nextMovement, v4 = HDAdminMain:GetModule("cf"):GetNextMovement(v3, commandSpeed * 10)
				local position2 = hrp.Position
				local v5 = CFrame.new(position2, position2 + unit) * nextMovement
				local v6 = 750 + commandSpeed * 0.2

				if p2 then
					v6 /= 2
				end

				local v7

				if nextMovement.p == Vector3.new() then
					count += 1
					v7 = 1

					if (hrp.Position - position).magnitude > 6 and count >= 4 then
						hdAdminFlyForce.Position = hrp.Position
					end
				else
					hdAdminFlyForce.D = v6
					v7 = v2 + 1
					hdAdminFlyForce.Position = v5.p
					count = 0
				end

				v2 = math.abs(v7) > 25 and 25 or v7

				if hdAdminFlyForce.D == v6 then
					local _ = v2 * v4.X * -0.5
					local v8 = p2 and 0 or v2 * v4.Z
					hdAdminFlyGyro.CFrame = v5 * CFrame.Angles(math.rad(v8), 0, 0)
				end

				lastTime = tick()
				position = hrp.Position
				humanoid[v] = true
				wait()
			until not (HDAdminMain.commandsActive[p] and humanoid and hrp)

			hdAdminFlyForce:Destroy()
			hdAdminFlyGyro:Destroy()

			if humanoid then
				humanoid[v] = false
			end

			if p2 then
				setCollisionGroupRecursive(workspace, "Group3")
			end
		end

		HDAdminMain.commandsActive[p] = nil
	end
}