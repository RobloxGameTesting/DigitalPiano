local HDAdminMain = _G.HDAdminMain
local settings = HDAdminMain.settings

local screenGuiSet = {}
local v = {}
local v2 = {}

local tweenInfo = TweenInfo.new(0.7)

local ClientCommands = {
	ping = {
		Function = function(_, _)
			local lastTime = tick()
			HDAdminMain.signals.GetPing:InvokeServer(math.random(1, 1000))
			local v3 = math.floor((tick() - lastTime) / 2 * 1000 * 1000 + 0.5) / 1000
			HDAdminMain:GetModule("Notices"):Notice("Notice", HDAdminMain.hdAdminCoreName, "Your ping is " .. v3 .. "!")
		end
	},
	blur = {
		Function = function(_, list)
			HDAdminMain.blur.Size = list[2] == 0 and 20 or list[2] or 20
		end,
		UnFunction = function(_, _)
			HDAdminMain.blur.Size = 0
		end
	},
	showGuis = {
		Function = function(_, _)
			for k, _ in pairs(screenGuiSet) do
				k.Enabled = true
			end

			screenGuiSet = {}
		end
	},
	hideGuis = {
		Function = function(_, _)
			for _, screenGui in pairs(HDAdminMain.playerGui:GetChildren()) do
				if not (screenGui:IsA("ScreenGui") and screenGui.Name ~= "Chat" and screenGui.Name ~= "HDAdminInterface") then
					continue
				end

				if screenGui.Enabled == true then
					screenGuiSet[screenGui] = true
				end

				screenGui.Enabled = false
			end
		end
	},
	view = {
		Function = function(p, list, state)
			local item = list[1]
			local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid(item)
			local clientViewingId = math.random(1, 1000000)
			state.clientViewingId = clientViewingId

			if item == p then
				state.UnFunction(p, list, state)
			elseif humanoid then
				local v3 = math.random(1, 1000000)
				item:SetAttribute("HDViewingId", v3)
				HDAdminMain:GetModule("cf"):SetCameraSubject(humanoid)
				item:GetPropertyChangedSignal("Parent"):Once(function()
					if clientViewingId ~= state.clientViewingId then
						return
					end

					if item:GetAttribute("HDViewingId") == v3 then
						state.UnFunction(p, list, state)
					end
				end)
				item.CharacterAdded:Once(function()
					if clientViewingId ~= state.clientViewingId then
						return
					end

					if not item.Character then
						item.CharacterAdded:Wait()
					end

					task.wait()
					state.Function(p, list, state)
				end)
			end
		end,
		UnFunction = function(p, _, p2)
			local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid(p)

			if humanoid then
				HDAdminMain:GetModule("cf"):SetCameraSubject(humanoid)
				p2.clientViewingId = nil
			end
		end
	},
	nightVision = {
		Function = function(_, _)
			for _, child in pairs(HDAdminMain.players:GetChildren()) do
				local head = HDAdminMain:GetModule("cf"):GetHead(child)

				if not (child.Name ~= HDAdminMain.player.Name and head) then
					continue
				end

				for _, part in pairs(child.Character:GetChildren()) do
					if not (part:IsA("BasePart") and part:FindFirstChild("HDNightVision") == nil) then
						continue
					end

					for i = 1, 6 do
						local hdAdminNightVision = HDAdminMain.client.Assets.NightVision:Clone()
						hdAdminNightVision.Parent = part
						hdAdminNightVision.Face = i - 1
						hdAdminNightVision.Name = "HDAdminNightVision"
					end
				end

				local hdAdminNightVision = HDAdminMain.client.Assets.Nickname:Clone()
				hdAdminNightVision.TextLabel.Text = child.Name
				hdAdminNightVision.Parent = head
				hdAdminNightVision.Name = "HDAdminNightVision"
			end
		end,
		UnFunction = function(_, _)
			for _, child in pairs(HDAdminMain.players:GetChildren()) do
				if not child.Character then
					continue
				end

				for _, descendant in pairs(child.Character:GetDescendants()) do
					if descendant.Name == "HDAdminNightVision" then
						descendant:Destroy()
					end
				end
			end
		end
	},
	cmdbar = {
		Function = function(_, _)
			HDAdminMain:GetModule("CmdBar"):OpenCmdBar()
		end
	},
	cmdbar2 = {
		Function = function(_, _)
			HDAdminMain:GetModule("cf"):CreateNewCommandMenu("cmdbar2", {}, 2)
		end
	},
	laserEyes = {
		DisplayLaser = function(instance, enabled)
			local leftBeam = instance and instance:FindFirstChild("LeftBeam")

			if leftBeam then
				leftBeam.Enabled = enabled
				instance.RightBeam.Enabled = enabled
				instance.MidAttachment.GlowHit.Enabled = enabled
			end
		end,
		Activate = function(p)
			local name = p.Name
			local head = HDAdminMain:GetModule("cf"):GetHead()
			local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid()
			local hrp = HDAdminMain:GetModule("cf"):GetHRP()

			if head and humanoid and HDAdminMain.mouseDown then
				local hdLaserTarget = head.Parent:FindFirstChild("HDLaserTarget")
				local neck = HDAdminMain:GetModule("cf"):GetNeck()

				local v3 = humanoid.RigType == Enum.HumanoidRigType.R6

				head.Parent.PrimaryPart = hrp

				if neck and hdLaserTarget then
					local v4 = tick() - 1
					local module = HDAdminMain:GetModule("cf")
					local neckOffset = module:GetNeckOffset(neck)
					local primaryPart = head.Parent.PrimaryPart

					local y = neckOffset.Position.Y

					local fire = hdLaserTarget.MidAttachment2.Fire
					local sparks = hdLaserTarget.MidAttachment.Sparks
					local sizzle = HDAdminMain.audio.Sizzle
					local sizzle2 = HDAdminMain.audio.Sizzle2
					sizzle:Play()
					p.DisplayLaser(hdLaserTarget, true)
					local v5 = false
					local v6 = 0

					repeat
						local mousePoint, v7 = HDAdminMain:GetModule("cf"):GetMousePoint(HDAdminMain.lastHitPosition)
						local cframe = CFrame.new(v7, head.Position)
						local distanceFromCharacter = HDAdminMain.player:DistanceFromCharacter(cframe.p)
						local v8

						if distanceFromCharacter > 30 then
							cframe *= CFrame.new(0, 0, 30 - distanceFromCharacter)
							v8 = true
						else
							v8 = false
						end

						hdLaserTarget.CFrame = cframe
						local position = head.Position
						local position2 = hdLaserTarget.Position
						local unit = (Vector3.new(position2.X, position.Y, position2.Z) - head.Position).Unit

						if head.Parent.PrimaryPart == nil then
							head.Parent.PrimaryPart = head.parent.HumanoidRootPart
						end

						local cframe2 = CFrame.new(Vector3.new(), primaryPart.CFrame:VectorToObjectSpace(unit))
						local v9

						if v3 then
							v9 = cframe2 * CFrame.new(0, 1, 0) * CFrame.fromEulerAnglesXYZ(
								1.5707963267948966,
								3.141592653589793,
								0
							)
						else
							v9 = cframe2 * CFrame.new(0, v6, 0)
						end

						if not v5 then
							v6 -= v9.Position.Y - y
							v9 *= CFrame.new(0, v6, 0)
							v5 = true
						end

						module:SetNeckOffset(neck, v9)

						if v4 < tick() - 0.6 then
							v4 = tick()
							HDAdminMain:GetModule("cf"):ReplicateEffect(p.Name, { cframe, v9 })
						end

						if
							mousePoint
							and not v8
							and (mousePoint.Parent:FindFirstChild("Humanoid") or mousePoint.Name == "Handle")
						then
							fire.Enabled = true
							sparks.Enabled = true

							if not sizzle2.Playing then
								sizzle2:Play()
							end
						else
							fire.Enabled = false
							sparks.Enabled = false

							if sizzle2.Playing then
								sizzle2:Stop()
							end
						end

						wait()
					until not (HDAdminMain.mouseDown and HDAdminMain.commandsActive[name] and head and head.Parent and neck)

					module:SetNeckOffset(neck, neckOffset)
					p.DisplayLaser(hdLaserTarget, false)
					fire.Enabled = false
					sparks.Enabled = false
					sizzle:Stop()
					sizzle2:Stop()
				end
			end

			HDAdminMain.commandsActive[name] = nil
		end,
		ReplicationEffect = function(p, list, p2)
			local item = list[1]
			local item2 = list[2]

			local head = HDAdminMain:GetModule("cf"):GetHead(p)

			if head then
				local hdLaserTarget = head.Parent:FindFirstChild("HDLaserTarget")
				local neck = HDAdminMain:GetModule("cf"):GetNeck(p)
				local module = HDAdminMain:GetModule("cf")

				if hdLaserTarget and neck then
					if v[p] then
						v[p] += 1
					else
						v[p] = 1
						v2[p] = module:GetNeckOffset(neck)
						local v3 = math.random(10, 40) - 15
						hdLaserTarget.CFrame = item * CFrame.new(0, 0, v3)
						module:SetNeckOffset(neck, item2)
						hdLaserTarget.MidAttachment.GlowHit.Rate = 50
						p2.DisplayLaser(hdLaserTarget, true)
					end

					HDAdminMain.tweenService:Create(hdLaserTarget, tweenInfo, { CFrame = item }):Play()
					module:TweenNeckOffset(neck, item2, tweenInfo)
					wait(0.7)
					v[p] -= 1

					if v[p] <= 0 then
						p2.DisplayLaser(hdLaserTarget, false)
						local v3 = v2[p]
						module:SetNeckOffset(neck, v3)
						task.delay(0.1, function()
							module:SetNeckOffset(neck, v3)
						end)
						v2[p] = nil
						v[p] = nil
					end
				end
			end
		end
	},
	warp = {
		Function = function(_, _)
			local total = 0.995
			local v3 = -0.005

			repeat
				HDAdminMain.runService.RenderStepped:Wait()

				if total < 0.005 then
					total = 0.005
					v3 = 0.005
				elseif total > 1 then
					total = 1
					v3 = -0.005
				end

				HDAdminMain.camera.CFrame = HDAdminMain.camera.CFrame * CFrame.new(0, 0, 0, total, 0, 0, 0, total, 0, 0, 0, 1)
				total += v3
			until total > 1
		end
	},
	fly = {
		Activate = function(p)
			HDAdminMain:GetModule("FlyCommand"):Fly(p.Name)
		end
	},
	fly2 = {
		Activate = function(p)
			HDAdminMain:GetModule("FlyCommand"):Fly(p.Name)
		end
	},
	noclip = {
		Activate = function(p)
			local name = p.Name
			local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid()
			local hrp = HDAdminMain:GetModule("cf"):GetHRP()

			if humanoid and hrp then
				local lastTime = tick()
				hrp.Anchored = true
				humanoid.PlatformStand = true

				repeat
					wait()
					local v3 = tick() - lastTime
					local unit = (HDAdminMain.camera.Focus.p - HDAdminMain.camera.CFrame.p).unit
					local nextMovement = HDAdminMain:GetModule("cf"):GetNextMovement(
						v3,
						HDAdminMain.commandSpeeds[name]
					)
					local position = hrp.Position
					hrp.CFrame = CFrame.new(position, position + unit) * nextMovement
					lastTime = tick()
				until not HDAdminMain.commandsActive[name]

				if hrp and humanoid then
					hrp.Anchored = false
					hrp.Velocity = Vector3.new()
					humanoid.PlatformStand = false
				end
			end
		end
	},
	noclip2 = {
		Activate = function(p)
			HDAdminMain:GetModule("FlyCommand"):Fly(p.Name, true)
		end
	},
	clip = {
		Function = function(_, _, _)
			HDAdminMain:GetModule("cf"):DeactivateCommand("noclip")
		end
	},
	boing = {
		ExpandTime = 4,
		ExpandAmount = 3,
		EndBoing = {},
		Function = function(p, list, data)
			local item = list[1]
			local head = HDAdminMain:GetModule("cf"):GetHead(item)
			local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid(item)
			local mesh = head and humanoid and not data.UnFunction(p, list, data) and head:FindFirstChild("Mesh")

			if mesh then
				local character = item.Character
				local accessories = {}

				for _, accessory in pairs(character:GetChildren()) do
					if not accessory:IsA("Accessory") then
						continue
					end

					table.insert(accessories, accessory)
					accessory.Parent = nil
				end

				local scale = mesh.Scale
				HDAdminMain.tweenService:Create(
					mesh,
					TweenInfo.new(data.ExpandTime, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
					{
						Scale = Vector3.new(scale.X, scale.Y * data.ExpandAmount, scale.Z)
					}
				):Play()

				local bindableEvent = Instance.new("BindableEvent")
				data.EndBoing[item] = bindableEvent
				HDAdminMain:GetModule("cf"):WaitForEvent(bindableEvent, humanoid.Died, item.CharacterAdded)
				data.EndBoing[item] = nil
				bindableEvent:Destroy()

				if mesh then
					local v3 = HDAdminMain.tweenService:Create(
						mesh,
						TweenInfo.new(2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
						{ Scale = scale }
					)
					v3:Play()
					v3.Completed:Wait()
				end

				for _, v3 in pairs(accessories) do
					if character then
						v3.Parent = character
					else
						v3:Destroy()
					end
				end
			end
		end,
		UnFunction = function(_, list, p)
			local item = list[1]
			local v3 = p.EndBoing[item]

			if not v3 then
				return
			end

			v3:Fire()
			return true
		end
	}
}

for k, v3 in pairs(ClientCommands) do
	v3.Name = k
end

return ClientCommands