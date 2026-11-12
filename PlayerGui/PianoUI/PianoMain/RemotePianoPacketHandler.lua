local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function getRemotePianoAudioKey(value, value2, value3) -- 1 equivalent call inferred from this helper
	return string.format("remote:%s:%s:%s", tostring(value or 0), tostring(value2 or 0), (tostring(value3 or "nil")))
end

local function getRemotePianoAudioPrefix(value, value2) -- 1 equivalent call inferred from this helper
	return string.format("remote:%s:%s:", tostring(value or 0), (tostring(value2 or 0)))
end

local function getRemotePianoSessionKey(value, value2) -- 1 equivalent call inferred from this helper
	return string.format("%s:%s", tostring(value or 0), (tostring(value2 or 0)))
end

return {
	Initialize = function(options)
		local v = options or {}

		local pianoPackets = v.PianoPackets
		local localPlayer = v.LocalPlayer
		local logic_Piano = v.Logic_Piano
		local logic_UI = v.Logic_UI
		local pianoVisualization = v.PianoVisualization
		local visualSettingHelpers = v.VisualSettingHelpers
		local dependence_PlayerVariables = v.Dependence_PlayerVariables
		local dependence_Soundfonts = v.Dependence_Soundfonts
		local dependence_SoundEffects = v.Dependence_SoundEffects
		local pianoPractice = v.PianoPractice

		local function getCurrentHumanoid() -- 2 equivalent calls inferred from this helper
			return v.GetCurrentHumanoid and v.GetCurrentHumanoid() or nil
		end

		local function getCurrentPianoModel() -- 2 equivalent calls inferred from this helper
			return v.GetCurrentPianoModel and v.GetCurrentPianoModel() or nil
		end

		local function getViewingPianoModel() -- 4 equivalent calls inferred from this helper
			return v.GetViewingPianoModel and v.GetViewingPianoModel() or nil
		end

		local function setViewingPianoModel(p) -- 3 equivalent calls inferred from this helper
			if v.SetViewingPianoModel then
				v.SetViewingPianoModel(p)
			end
		end

		local function isPianoControlsVisible() -- 2 equivalent calls inferred from this helper
			return v.IsPianoControlsVisible and v.IsPianoControlsVisible() or false
		end

		local function isPracticeActive() -- 3 equivalent calls inferred from this helper
			return pianoPractice and pianoPractice.Active == true
		end

		local function getOtherPianoVolumeMultiplier() -- 2 equivalent calls inferred from this helper
			return v.GetOtherPianoVolumeMultiplier and v.GetOtherPianoVolumeMultiplier() or 1
		end

		local function getLocalVolume()
			return v.GetLocalVolume and v.GetLocalVolume() or 100
		end

		local function getPerformerVolume(playerByUserId) -- 1 equivalent call inferred from this helper
			local pianoPerformerVolume = playerByUserId
				and tonumber(playerByUserId:GetAttribute("PianoPerformerVolume"))

			if pianoPerformerVolume then
				return (math.clamp(math.floor(pianoPerformerVolume + 0.5), 10, 200))
			end

			return 100
		end

		local function getPlayerSoundEffects(playerByUserId) -- 1 equivalent call inferred from this helper
			return dependence_SoundEffects.DecodeState(playerByUserId:GetAttribute("PianoSoundEffects"))
		end

		local object = setmetatable({}, { __mode = "k" })

		local function getLocalRootPart() -- 1 equivalent call inferred from this helper
			local character = localPlayer and localPlayer.Character
			return character and character:FindFirstChild("HumanoidRootPart") or nil
		end

		local function isLocalPlayerInsideZonePart(part): boolean
			if not (part and part:IsA("BasePart")) then
				return true
			end

			local localRootPart = getLocalRootPart() -- inferred equivalent call

			if not localRootPart then
				return false
			end

			local pointToObjectSpace = part.CFrame:PointToObjectSpace(localRootPart.Position)
			local v2 = part.Size * 0.5
			return math.abs(pointToObjectSpace.X) <= v2.X
				and math.abs(pointToObjectSpace.Y) <= v2.Y
				and math.abs(pointToObjectSpace.Z) <= v2.Z
		end

		local function cleanupRemotePianoAudio(performerUserId, sessionId) -- 3 equivalent calls inferred from this helper
			if logic_Piano.ServerStopNotesByPrefix then
				logic_Piano.ServerStopNotesByPrefix(getRemotePianoAudioPrefix(performerUserId, sessionId), 0.08) -- inferred equivalent call
			end

			if logic_Piano.ResetPianoSoundGroup then
				logic_Piano.ResetPianoSoundGroup(performerUserId)
			end
		end

		local function getMutedPianoAttributeName(p) -- 1 equivalent call inferred from this helper
			return "MutedPianoUser_" .. tostring((math.floor(tonumber(p) or 0)))
		end

		local function isPerformerPianoMuted(value): boolean -- 1 equivalent call inferred from this helper
			return localPlayer:GetAttribute(getMutedPianoAttributeName(value)) == true -- inferred equivalent call
		end

		local function cleanupRemotePerformerAudio(value) -- 1 equivalent call inferred from this helper
			if logic_Piano.ServerStopNotesByPrefix then
				logic_Piano.ServerStopNotesByPrefix("remote:" .. tostring(value or 0) .. ":", 0.08)
			end

			if logic_Piano.ResetPianoSoundGroup then
				logic_Piano.ResetPianoSoundGroup(value)
			end
		end

		local function cleanupZoneAudio(p, p2)
			if not p then
				return
			end

			for k, session in pairs(p.Sessions) do
				if not (p2 == nil or session.SessionId == p2) then
					continue
				end

				cleanupRemotePianoAudio(session.PerformerUserId, session.SessionId) -- inferred equivalent call
				p.Sessions[k] = nil
			end
		end

		local function updatePianoZoneState(instance, state): boolean
			if not state then
				return true
			end

			if instance and instance.Parent ~= nil then
				local zonePart = state.ZonePart

				if not zonePart or zonePart.Parent == nil then
					zonePart = instance:FindFirstChild("Zone")
					state.ZonePart = zonePart
				end

				local inside = state.Inside == true
				local localPlayerInsideZonePart = isLocalPlayerInsideZonePart(zonePart)
				state.Inside = localPlayerInsideZonePart

				if inside and not localPlayerInsideZonePart and state then
					for k, session in pairs(state.Sessions) do
						cleanupRemotePianoAudio(session.PerformerUserId, session.SessionId) -- inferred equivalent call
						state.Sessions[k] = nil
					end
				end

				return true
			end

			if state then
				for k, session in pairs(state.Sessions) do
					cleanupRemotePianoAudio(session.PerformerUserId, session.SessionId) -- inferred equivalent call
					state.Sessions[k] = nil
				end
			end

			return false
		end

		local function updateAllPianoZoneStates()
			for k, v2 in pairs(object) do
				if not updatePianoZoneState(k, v2) then
					object[k] = nil
				end
			end
		end

		local total = 0
		RunService.Heartbeat:Connect(function(dt)
			total += tonumber(dt) or 0

			if total < 0.15 then
				return
			end

			total = 0
			updateAllPianoZoneStates()
		end)

		local function getPianoZoneState(model)
			if not (model and model:IsA("Model")) then
				return nil
			end

			local v2 = object[model]

			if v2 then
				updatePianoZoneState(model, v2)
				return v2
			end

			local v3 = { ZonePart = model:FindFirstChild("Zone"), Inside = true, Sessions = {} }

			object[model] = v3
			updatePianoZoneState(model, v3)
			return v3
		end

		local function registerRemotePianoSession(model, performerUserId, value) -- 1 equivalent call inferred from this helper
			local pianoZoneState = getPianoZoneState(model)

			if pianoZoneState then
				pianoZoneState.Sessions[getRemotePianoSessionKey(performerUserId, value)] = { -- inferred equivalent call
					PerformerUserId = performerUserId,
					SessionId = value
				}
			end

			return pianoZoneState
		end

		if not (pianoPackets and localPlayer and logic_Piano and logic_UI and pianoVisualization and visualSettingHelpers and dependence_PlayerVariables and dependence_Soundfonts and dependence_SoundEffects) then
			ClientDebugConfig.Warn("[RemotePianoPacketHandler] Missing required context; remote piano packets were not initialized")
			return
		end

		pianoPackets.NoteSimple.OnClientEvent:Connect(function(p, p2, p3, p4, value, p5, p6, value2, value3, p7, value4, p8, p9)
			if not value2 or type(value2) ~= "number" then
				return
			end

			local v2 = typeof(value4) == "number" and value4 or p3
			local playerByUserId = Players:GetPlayerByUserId(value2)

			if not playerByUserId or playerByUserId == localPlayer then
				return
			end

			local character = playerByUserId.Character

			if not character then
				return
			end

			local humanoid = character:FindFirstChild("Humanoid")

			if not (humanoid and humanoid.SeatPart) then
				return
			end

			local model = v.GetPianoModel and v.GetPianoModel(humanoid.SeatPart)

			if not (model and model:IsA("Model")) then
				return
			end

			local currentHumanoid = getCurrentHumanoid() -- inferred equivalent call
			local v3 = currentHumanoid and currentHumanoid.SeatPart and isPianoControlsVisible() -- inferred equivalent call
			local practiceActive = isPracticeActive() -- inferred equivalent call
			local sessionId = model:GetAttribute("SessionId") or 0

			if not value3 or value3 ~= sessionId then
				return
			end

			local remotePianoAudioKey = getRemotePianoAudioKey(value2, value3, value) -- inferred equivalent call

			if isPerformerPianoMuted(value2) then -- inferred equivalent call
				if p6 then
					cleanupRemotePerformerAudio(value2) -- inferred equivalent call
				else
					logic_Piano.ServerFinishNonSustainNote(remotePianoAudioKey, 0.08)
				end
			else
				local viewingPianoModel = getViewingPianoModel() -- inferred equivalent call

				if not practiceActive and viewingPianoModel ~= model then
					if viewingPianoModel and v.CleanupViewedPiano then
						v.CleanupViewedPiano(viewingPianoModel)
					end

					setViewingPianoModel(model) -- inferred equivalent call

					if v.ClearAllPianoKeyHighlights then
						v.ClearAllPianoKeyHighlights()
					end

					ClientDebugConfig.Print("[PianoMain] Cleared UI visuals when switching viewing target")
					visualSettingHelpers.ApplySynthesiaColorsFromPlayer(playerByUserId, model)
				end

				local playerSoundEffects = getPlayerSoundEffects(playerByUserId) -- inferred equivalent call
				local v4 = p7 or dependence_PlayerVariables.Current_SoundfontID
				local dependence_Soundfont = dependence_Soundfonts[v4]

				if not dependence_Soundfont then
					return
				end

				local pianoZoneState = registerRemotePianoSession(model, value2, value3) -- inferred equivalent call

				if pianoZoneState and pianoZoneState.Inside ~= true then
					if not p6 then
						logic_Piano.ServerFinishNonSustainNote(remotePianoAudioKey, dependence_Soundfont.Fadeout or 1)
					end
				elseif p6 then
					if v.PrewarmCurrentSoundfont then
						v.PrewarmCurrentSoundfont(v4)
					end

					local packetType = dependence_Soundfont.PacketType
					local otherPianoVolumeMultiplier = getOtherPianoVolumeMultiplier() -- inferred equivalent call

					if packetType and otherPianoVolumeMultiplier > 0 then
						logic_Piano[packetType](
							p,
							dependence_Soundfont.AssetIds,
							dependence_Soundfont.Offset,
							dependence_Soundfont.MaxLifetime,
							dependence_Soundfont.Fadeout,
							p3,
							packetType,
							p4,
							false,
							p2,
							getPerformerVolume(playerByUserId) * otherPianoVolumeMultiplier, -- inferred equivalent call
							dependence_Soundfont.VolumeModifier,
							remotePianoAudioKey,
							true,
							playerSoundEffects,
							value2
						)
					end

					if not v3 and not practiceActive and v.GetActiveKeysFrame then
						logic_UI.PlayNote(v.GetActiveKeysFrame(), p)
					end

					if not practiceActive then
						if playerByUserId:GetAttribute("DefaultSynthesiaEnabled") ~= false and v.StartVisualization then
							v.StartVisualization(p, model, playerByUserId)
						end

						visualSettingHelpers.AnimatePianoModelKey(model, p5, true, playerByUserId, v2, p8, p9)

						if v.PianoSimRunCustomVisualEffect then
							v.PianoSimRunCustomVisualEffect(model, p, true, playerByUserId)
						end
					end
				else
					if not v3 and not practiceActive and v.GetActiveKeysFrame then
						logic_UI.FinishNote(v.GetActiveKeysFrame(), p)
					end

					logic_Piano.ServerFinishNonSustainNote(
						remotePianoAudioKey,
						dependence_Soundfont and dependence_Soundfont.Fadeout or 1
					)

					if not practiceActive then
						if v.EndVisualization then
							v.EndVisualization(p, model)
						end

						visualSettingHelpers.AnimatePianoModelKey(model, p5, false, playerByUserId, v2, p8, p9)

						if v.PianoSimRunCustomVisualEffect then
							v.PianoSimRunCustomVisualEffect(model, p, false, playerByUserId)
						end
					end
				end
			end
		end)

		pianoPackets.NoteEvent.OnClientEvent:Connect(function(p, p2, p3, p4, p5, p6, p7, p8, p9)
			local otherPianoVolumeMultiplier = getOtherPianoVolumeMultiplier() -- inferred equivalent call

			if otherPianoVolumeMultiplier <= 0 then
				return
			end

			logic_Piano.PlayServerNote(p, p2, p3 * otherPianoVolumeMultiplier, p4, p5, p6, p7, p8, p9)
		end)

		pianoPackets.SustainRelease.OnClientEvent:Connect(function(p, p2)
			if p ~= "__PianoSustainOn" then
				logic_Piano.ServerFinishNonSustainNote(p, p2)
			elseif logic_Piano.ServerUpdateSustainState then
				logic_Piano.ServerUpdateSustainState(true, p2)
			end
		end)

		pianoPackets.FinishNonSustainedNotes.OnClientEvent:Connect(function(p)
			if logic_Piano.ServerUpdateSustainState then
				logic_Piano.ServerUpdateSustainState(false, p)
			else
				logic_Piano.ServerFadeoutAllSustainedNotes(p)
			end
		end)

		pianoPackets.VisualizerControl.OnClientEvent:Connect(function(p, p2, p3, p4)
			if isPracticeActive() then -- inferred equivalent call
				return
			end

			local currentHumanoid = getCurrentHumanoid() -- inferred equivalent call
			local v2 = currentHumanoid and currentHumanoid.SeatPart and isPianoControlsVisible() -- inferred equivalent call
			local v3 = nil
			local v4 = nil
			local v5 = nil
			local v6 = nil

			if p == "setColor" then
				v4 = p2
				v6 = p4
				v3 = p3
			elseif p == "rainbow" then
				v5 = p3
				v6 = p4
				v3 = p2
			end

			if v3 and v6 and v6 ~= (v3:GetAttribute("SessionId") or 0) then
				return
			end

			if v2 then
				if v3 ~= getCurrentPianoModel() then -- inferred equivalent call
					return
				end
			else
				local viewingPianoModel = getViewingPianoModel() -- inferred equivalent call

				if v3 and v3 ~= viewingPianoModel then
					if viewingPianoModel and v.CleanupViewedPiano then
						v.CleanupViewedPiano(viewingPianoModel)
					end

					setViewingPianoModel(v3) -- inferred equivalent call
				end
			end

			if p == "setColor" and v4 then
				local v7 = v2 and getCurrentPianoModel() or getViewingPianoModel() -- inferred equivalent call
				pianoVisualization.SetVisualizerColor(v4, v7)

				if v7 then
					v7:SetAttribute("VizColor", v4)
				end
			elseif p == "rainbow" and v5 ~= nil and v3 then
				v3:SetAttribute("RainbowActive", v5 and true or false)
			end
		end)

		pianoPackets.SessionCleanup.OnClientEvent:Connect(function(model, p)
			if isPracticeActive() then -- inferred equivalent call
				logic_Piano.ServerFadeoutAllSustainedNotes(1)
				return
			end

			if not (model and model:IsA("Model")) then
				return
			end

			cleanupZoneAudio(object[model], p)

			if v.CleanupViewedPiano then
				v.CleanupViewedPiano(model)
			end

			if getViewingPianoModel() == model then -- inferred equivalent call
				setViewingPianoModel(nil) -- inferred equivalent call
			end

			ClientDebugConfig.Print("[Piano] Cleaned up viewed piano for", model.Name, "session:", p)
		end)
	end
}