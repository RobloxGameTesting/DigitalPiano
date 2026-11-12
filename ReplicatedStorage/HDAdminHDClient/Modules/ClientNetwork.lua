local HDAdminMain = _G.HDAdminMain

local customTopBar = HDAdminMain.gui.CustomTopBar
local flag = true

for _, child in pairs(HDAdminMain.signals:GetChildren()) do
	if child:IsA("RemoteEvent") then
		child.OnClientEvent:Connect(function(list)
			if not HDAdminMain.initialized then
				HDAdminMain.client.Signals.Initialized.Event:Wait()
			end

			if child.Name == "ChangeStat" then
				local item = list[1]
				local item2 = list[2]
				HDAdminMain.pdata[item] = item2
			elseif child.Name == "InsertStat" then
				local item = list[1]
				local item2 = list[2]
				table.insert(HDAdminMain.pdata[item], item2)
			elseif child.Name == "RemoveStat" then
				local item = list[1]
				local item2 = list[2]

				for k, v in pairs(HDAdminMain.pdata[item]) do
					if tostring(v) == tostring(item2) then
						table.remove(HDAdminMain.pdata[item], k)
						return
					end
				end
			elseif child.Name == "BecomeControlled" then
				local item = list[1]
				local player = HDAdminMain.player
				local playerScripts = player.PlayerScripts
				local PlayerModule = require(playerScripts:WaitForChild("PlayerModule", 3))
				local controls = PlayerModule and PlayerModule:GetControls()
				local character = player.Character
				local animate = character and character:FindFirstChild("Animate")

				if controls then
					if item then
						if animate then
							animate.Enabled = false
						end

						controls:Disable()
					else
						controls:Enable()

						if animate then
							animate.Enabled = true
						end
					end
				end
			elseif child.Name == "ViewPlayer" then
				local item = list[1]
				local humanoid = HDAdminMain:GetModule("cf"):GetHumanoid(item)

				if humanoid then
					HDAdminMain:GetModule("cf"):SetCameraSubject(humanoid)
				end

				local character = HDAdminMain.player.Character
				local animate = character and character:FindFirstChild("Animate")

				if animate then
					animate.Enabled = false
					task.wait()
					animate.Enabled = true
				end
			elseif child.Name == "SetResetButtonCallbackEnabled" then
				local StarterGui = game:GetService("StarterGui")
				local RunService = game:GetService("RunService")

				for _ = 1, 100 do
					if pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", list) then
						return
					end

					RunService.Heartbeat:Wait()
				end
			elseif child.Name == "JoinGroup" then
				local item = list[1]
				local item2 = list[2]
				local GroupService = game:GetService("GroupService")
				HDAdminMain:GetModule("Notices"):Notice("Notice", HDAdminMain.hdAdminCoreName, item2)
				local success, result = pcall(function()
					return GroupService:PromptJoinAsync(item)
				end)

				if success and result ~= Enum.GroupMembershipStatus.None then
					HDAdminMain.signals.JoinGroup:FireServer()
					HDAdminMain:GetModule("Notices"):Notice(
						"Notice",
						HDAdminMain.hdAdminCoreName,
						"Successfully joined!"
					)
				end
			elseif child.Name == "UndoCommand" then
				HDAdminMain:GetModule("PageCommands"):UpdateRunCommandIndicator(unpack(list))
			elseif child.Name == "ForceBubbleChat" then
				local item = list[1]
				local character = item and item.Character
				local item2 = list[2]

				if character and item2 then
					HDAdminMain.textChatService:DisplayBubble(character, item2)
				end
			elseif child.Name == "SystemMessage" then
				HDAdminMain.textChatService:WaitForChild("TextChannels").RBXGeneral:DisplaySystemMessage(list)
			elseif child.Name == "Notice" or child.Name == "Error" then
				HDAdminMain:GetModule("Notices"):Notice(child.Name, list[1], list[2], list[3])
			elseif child.Name == "ShowPage" then
				local item = list[1]
				local item2 = list[2]
				HDAdminMain:GetModule("GUIs"):ShowSpecificPage(item, item2, nil, nil, nil, flag)

				if flag then
					flag = false
				end
			elseif child.Name == "UpdateIceBlock" then
				local item = list[1]
				local item2 = list[2]

				if item and item2 then
					item.CFrame = item2.CFrame * CFrame.new(0, 0.8, 0)
				end
			elseif child.Name == "ShowCommands" then
				HDAdminMain:GetModule("PageCommands"):SetSearchText(list[1])
				task.wait()
				HDAdminMain:GetModule("GUIs"):ShowSpecificPage("Commands", "Commands", list[2], nil, list[3])
			elseif child.Name == "ShowBannedUser" then
				HDAdminMain:GetModule("GUIs"):ShowSpecificPage("Moderation", "Banland")

				if type(list) == "table" then
					HDAdminMain:GetModule("cf"):ShowBannedUser(list)
				end
			elseif child.Name == "SetCameraSubject" then
				HDAdminMain:GetModule("cf"):SetCameraSubject(list)
			elseif child.Name == "ChartsHttpNotice" then
				if list == true then
					HDAdminMain:GetModule("Notices"):Notice(
						"Notice",
						HDAdminMain.hdAdminCoreName,
						"Your game was successfully added to the HD Admin Charts!"
					)
				else
					HDAdminMain:GetModule("Notices"):Notice(
						"Error",
						HDAdminMain.hdAdminCoreName,
						"HttpService disabled: Unable to join HD Admin Charts. Click to add.",
						{
							"CallFunctionOnClick",
							function()
								HDAdminMain:GetModule("cf"):CreateNewCommandMenu("purchase", nil, 15)
							end
						}
					)
				end
			elseif child.Name == "Clear" then
				HDAdminMain:GetModule("Messages"):ClearMessageContainer()
			elseif child.Name == "ShowWarning" then
				HDAdminMain:GetModule("cf"):ShowWarning(list)
			elseif child.Name == "UpdateBanland" then
				HDAdminMain:GetModule("PageModeration"):CreateBanland()
			elseif child.Name == "Message" then
				HDAdminMain:GetModule("Messages"):Message(list)
			elseif child.Name == "Hint" then
				HDAdminMain:GetModule("Messages"):Hint(list)
			elseif child.Name == "GlobalAnnouncement" then
				HDAdminMain:GetModule("Messages"):GlobalAnnouncement(list)
			elseif child.Name == "SetCoreGuiEnabled" then
				HDAdminMain.starterGui:SetCoreGuiEnabled(Enum.CoreGuiType[list[1]], list[2])
			elseif child.Name == "CreateLog" then
				HDAdminMain:GetModule("cf"):CreateNewCommandMenu(list[1], list[2], 5)
			elseif child.Name == "CreateAlert" then
				HDAdminMain:GetModule("cf"):CreateNewCommandMenu("alert", list, 8, true)
			elseif child.Name == "PromptGamepass" then
				HDAdminMain:GetModule("cf"):PromptGamepass(HDAdminMain.player, list)
			elseif child.Name == "UpdatePageBoostStatus" then
				HDAdminMain:GetModule("PageBooster"):UpdateBoostStatus(list[1], list[2])
			elseif child.Name == "CheckOffer" then
				if HDAdminMain.pdata.Rank < 4 or list then
					HDAdminMain:GetModule("PageBooster"):CheckOffer(list)
				end
			elseif child.Name == "CreateBanMenu" then
				HDAdminMain:GetModule("cf"):CreateNewCommandMenu("banMenu", list, 6)
			elseif child.Name == "CreateEmotesMenu" then
				HDAdminMain:GetModule("cf"):CreateNewCommandMenu("emotes", nil, 16)
			elseif child.Name == "CreatePollMenu" then
				HDAdminMain:GetModule("cf"):CreateNewCommandMenu("pollMenu", list, 9)
			elseif child.Name == "CreateMenu" then
				HDAdminMain:GetModule("cf"):CreateNewCommandMenu(list.MenuName, list.Data, list.TemplateId)
			elseif child.Name == "CreateCommandMenu" then
				local item = list[1]
				local item2 = list[2]
				local item3 = list[3]
				HDAdminMain:GetModule("cf"):CreateNewCommandMenu(item, item2, item3)
			elseif child.Name == "RankChanged" then
				HDAdminMain:GetModule("cf"):RankChangedUpdater()
			elseif child.Name == "PlaySoundInstance" then
				if list then
					list:Play()
				end
			elseif child.Name == "AddEmoteDetail" then
				local emotes = HDAdminMain:GetModule("cf"):GetEmotes()

				local id = list.id
				local v = tostring(id)
				local v2 = false

				for _, emote in emotes do
					if tostring(emote.id) == v then
						v2 = true
						break
					end
				end

				if not v2 then
					table.insert(emotes, list)
				end

				HDAdminMain:GetModule("cf"):RegisterEmoteId(id)
			elseif child.Name == "ExecuteClientCommand" then
				local item = list[1]
				local item2 = list[2]
				local item3 = list[3]
				local v = list[4].UnFunction and "UnFunction" or "Function"

				local v2 = HDAdminMain:GetModule("ClientCommands")[item3]

				local v3 = v2 and v2[v]

				if v3 then
					v3(item, item2, v2)
				end
			elseif child.Name == "ReplicationEffectClientCommand" then
				local item = list[1]
				local item2 = list[2]
				local item3 = list[3]
				local v = HDAdminMain:GetModule("ClientCommands")[item]

				local replicationEffect = v and v.ReplicationEffect

				if replicationEffect then
					replicationEffect(item2, item3, v)
				end
			elseif child.Name == "ActivateClientCommand" then
				local item = list[1]
				local item2 = list[2]
				local item3 = list[3]
				local v

				if item2 then
					if item2.Speed ~= 0 then
						v = item2.Speed or nil
					end
				else
					v = item2
				end

				if v then
					HDAdminMain.commandSpeeds[item] = v
					local commandMenufly = HDAdminMain.gui:FindFirstChild("CommandMenufly")
					HDAdminMain:GetModule("cf"):DestroyCommandMenuFrame(commandMenufly)
				end

				if HDAdminMain.commandSpeeds[item] then
					for k, _ in pairs(HDAdminMain.commandSpeeds) do
						if k ~= item then
							HDAdminMain:GetModule("cf"):DeactivateCommand(k)
						end
					end
				end

				HDAdminMain.commandsAllowedToUse[item] = true
				HDAdminMain:GetModule("cf"):ActivateClientCommand(item, item2)
				local v2 = nil
				local v3 = nil

				for k, v4 in pairs(HDAdminMain.commandsWithMenus) do
					v2 = v4[item]

					if v2 then
						v3 = tonumber(k:match("%d+"))
						break
					end
				end

				if v2 then
					HDAdminMain:GetModule("cf"):CreateNewCommandMenu(item, v2, v3, nil, item3)
				end
			else
				if child.Name == "DeactivateClientCommand" then
					HDAdminMain:GetModule("cf"):DeactivateCommand(list[1])
					return
				end

				if child.Name == "FadeInIcon" then
					return
				end

				if child.Name == "ChangeMainVariable" then
					HDAdminMain[list[1]] = list
				elseif child.Name == "BindAudioEmitter" then
					local item = list[1]
					local item2 = list[2]

					if not item then
						return
					end

					local hdAudioListener = Instance.new("AudioListener")
					hdAudioListener.Name = "HDAudioListener"
					hdAudioListener.Parent = workspace.Camera
					local audioDeviceOutput = Instance.new("AudioDeviceOutput")
					audioDeviceOutput.Parent = hdAudioListener
					local wire = Instance.new("Wire")
					wire.Parent = audioDeviceOutput
					wire.SourceInstance = hdAudioListener
					wire.TargetInstance = audioDeviceOutput
					local wire2 = Instance.new("Wire")
					wire2.Parent = hdAudioListener
					wire2.SourceInstance = hdAudioListener
					wire2.TargetInstance = item
					local flag2 = false
					local function cleanup()
						if flag2 then
							return
						end

						flag2 = true
						hdAudioListener:Destroy()
					end
					item.Destroying:Once(cleanup)
					item2:Play()
					item2.Ended:Once(cleanup)
				end
			end
		end)
	elseif child:IsA("RemoteFunction") then
		child.OnClientInvoke = function(p)
			if not HDAdminMain.initialized then
				HDAdminMain.client.Signals.Initialized.Event:Wait()
			end

			if child.Name == "GetLocalDate" then
				return os.date("*t", p)
			end
		end
	end
end

return {}