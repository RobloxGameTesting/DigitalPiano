local ByteRealm = require(script.ByteRealm)

local byte = string.byte
local sub = string.sub
local find = string.find
local split = string.split

local pow = math.pow
local floor = math.floor
local abs = math.abs

local insert = table.insert
local clone = table.clone
local pack = table.pack
local concat = table.concat

local instructionEventData = {
	SystemExclusive = { "Text" },
	TuneRequest = {},
	SongSelect = {},
	SongPosition = { "LSB", "MSB" },
	SequencerSpecific = { "Text" },
	KeySignature = { "Signature", "RelativeKey" },
	TimeSignature = { "Numerator", "Denominator", "ClockInMetronome", "Notated32ndNotesInQuarter" },
	SMPTEOffset = { "Hours", "Minutes", "Seconds", "Frames", "FractionalFrames" },
	SetTempo = { "Tempo" },
	SetSequenceNumber = { "SequenceNumber" },
	EndOfTrack = {},
	ChannelPrefix = { "Channel" },
	TextEvent = { "Text" },
	CopyrightText = { "Text" },
	TrackName = { "Text" },
	InstrumentName = { "Text" },
	Lyric = { "Text" },
	Marker = { "Text" },
	CuePoint = { "Text" },
	NoteOn = { "Channel", "NoteNumber", "Velocity" },
	NoteOff = { "Channel", "NoteNumber", "Velocity" },
	AfterTouchPoly = { "NoteNumber", "Touch" },
	ProgramChange = { "Channel", "PatchNumber" },
	ControlChange = { "ControllerNumber", "ControlChange" },
	AfterTouchChannel = { "Pressure" },
	PitchWheel = { "PitchBendLSB", "PitchBendMSB" }
}
local InteractiveMidi = {}

local references = {}
local classes = {}

local instructionEventBytes = {
	F7 = {
		"SystemExclusive",
		{ "LENGTH" }
	},
	F6 = { "TuneRequest", {} },
	F3 = { "SongSelect", {} },
	F2 = {
		"SongPosition",
		{ 2, 2 }
	},
	F0 = {
		"SystemExclusive",
		{ "LENGTH" }
	},
	["7F"] = {
		"SequencerSpecific",
		{ "LENGTH" }
	},
	["59"] = {
		"KeySignature",
		{ 2, 2 }
	},
	["58"] = {
		"TimeSignature",
		{ 2, 2, 2, 2 }
	},
	["54"] = {
		"SMPTEOffset",
		{ 2, 2, 2, 2, 2 }
	},
	["51"] = {
		"SetTempo",
		{ 6 }
	},
	["00"] = {
		"SetSequenceNumber",
		{ 2 }
	},
	["2F"] = { "EndOfTrack", {} },
	["20"] = {
		"ChannelPrefix",
		{ 2 }
	},
	["21"] = {
		"CopyrightText",
		{ "LENGTH" }
	},
	["01"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["02"] = {
		"CopyrightText",
		{ "LENGTH" }
	},
	["03"] = {
		"TrackName",
		{ "LENGTH" }
	},
	["04"] = {
		"InstrumentName",
		{ "LENGTH" }
	},
	["05"] = {
		"Lyric",
		{ "LENGTH" }
	},
	["06"] = {
		"Marker",
		{ "LENGTH" }
	},
	["07"] = {
		"CuePoint",
		{ "LENGTH" }
	},
	["08"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["09"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["0A"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["0B"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["0C"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["0D"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["0E"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["0F"] = {
		"TextEvent",
		{ "LENGTH" }
	},
	["9"] = {
		"NoteOn",
		{ 2, 2 }
	},
	["8"] = {
		"NoteOff",
		{ 2, 2 }
	},
	A = {
		"AfterTouchPoly",
		{ 2, 2 }
	},
	B = {
		"ControlChange",
		{ 2, 2 }
	},
	C = {
		"ProgramChange",
		{ 2 }
	},
	D = {
		"AfterTouchChannel",
		{ 2 }
	},
	E = {
		"PitchWheel",
		{ 2, 2 }
	}
}

for k, list in next, instructionEventData do
	insert(list, 1, "DeltaTime")
	insert(list, 1, "TrackNumber")
end

InteractiveMidi.References = references

local function fn(list, ...)
	insert(list, ...)
	return list
end

local function fn2(...)
	local v = pack(...)
	v.n = nil
	return v
end

function references.FormatEvent(p: string, p2, p3: number)
	local result

	if instructionEventData[p] then
		local v = instructionEventData[p]
		local v2 = fn(clone(p2), 1, p3)
		result = {}

		for k, v3 in next, v do
			result[v3] = v2[k]
		end

		if not result then
			result = p2
		end
	else
		result = p2
	end

	return result
end

references.Classes = classes
references.InstructionEventData = instructionEventData
references.InstructionEventBytes = instructionEventBytes

function references.TempoTimeConstant(p, p2)
	if p2 == p then
		return 1
	end

	return p / p2
end

function references.TempoToBeatsPerMinute(p)
	return 60000000 / p
end

references.BeatsPerMinuteToTempo = references.TempoToBeatsPerMinute

function references.TicksToSeconds(p, p2, p3)
	return p * p2 / (p3 * 1000000)
end

function references.SecondsToTicks(p, p2, p3)
	return p * (p3 * 1000000) / p2
end

function references.NoteNumberToPitch(p: number, p2: number)
	return pow(2, (p + p2) / 12) * 13.75 / 440 * 8
end

function references.NoteNumberToNoteName(p)
	local v = floor((p - 12) / 12)
	return ({
		"C",
		"C#",
		"D",
		"D#",
		"E",
		"F",
		"F#",
		"G",
		"G#",
		"A",
		"A#",
		"B"
	})[(p - 12) % 12 + 1], v
end

function classes.Player()
	local songLength = {
		IsPlayer = true,
		IsPlaying = false,
		TimePosition = 0,
		LastTimePosition = 0,
		TempoTimePosition = 0,
		TempoTimeConstant = 1,
		Loop = false,
		TimeMultiplier = 1,
		SyncingThreshold = 1,
		TimeLength = 0,
		Tempo = references.BeatsPerMinuteToTempo(120),
		IsTempoSet = false,
		Memory = {},
		Events = {},
		EndOfTracks = {},
		InstructionProgress = {},
		InstructionCursor = {},
		Heartbeat = nil,
		SyncingDifference = 0,
		Syncing = nil,
		Loaded = nil
	}

	function songLength:GetSongLength()
		local loaded = songLength.Loaded

		if not loaded or loaded.ParseType ~= "Summation" then
			return songLength
		end

		local v = songLength.Tempo
		local timeLength = 0

		for k, instruction in next, loaded.Instructions do
			local v2 = 0
			local total = 0

			for k2, v3 in next, instruction do
				total += (v3[2] - v2) * v / (loaded.Header.PulsesPerQuarter * 1000000)
				v2 = v3[2]

				if v3[1] == "SetTempo" then
					v = v3[3]
				end
			end

			if timeLength < total then
				timeLength = total
			end
		end

		songLength.TimeLength = timeLength

		return songLength
	end

	local fn3

	function songLength:Load(loaded)
		if loaded.IsParser then
			songLength.Loaded = loaded
		end

		songLength:GetSongLength()

		if fn3 then
			fn3(loaded)

			if loaded.PlaybackTimeLength and loaded.PlaybackTimeLength > 0 then
				songLength.TimeLength = loaded.PlaybackTimeLength
			end
		end

		return songLength
	end

	function songLength:FireEvent(p, ...)
		if songLength.Events[p] then
			task.spawn(songLength.Events[p], ...)
		end

		return songLength
	end

	function songLength:SetTempo(tempo)
		if not songLength.IsTempoSet then
			songLength.Tempo = tempo
		end

		local loaded = songLength.Loaded
		local timePosition = songLength.TimePosition
		local v = references.SecondsToTicks(timePosition, songLength.Tempo, loaded.Header.PulsesPerQuarter) * tempo / (loaded.Header.PulsesPerQuarter * 1000000)
		songLength.TempoTimeConstant *= v == timePosition and 1 or timePosition / v
		songLength.Tempo = tempo
		songLength.TempoTimePosition = timePosition * songLength.TempoTimeConstant ^ (-1) - timePosition
		return songLength
	end

	local function buildTempoMap(state)
		local v = {
			{
				Tick = 0,
				Tempo = references.BeatsPerMinuteToTempo(120)
			}
		}

		for k, list in next, state.Instructions do
			for i, item in ipairs(list) do
				if item[1] == "SetTempo" then
					table.insert(v, { Tick = item[2], Tempo = item[3] })
				end
			end
		end

		table.sort(v, function(a, b): boolean
			return a.Tick < b.Tick
		end)

		local tempoMap = {}

		for i, v2 in ipairs(v) do
			local tempo = tempoMap[#tempoMap]

			if tempo and tempo.Tick == v2.Tick then
				tempo.Tempo = v2.Tempo
			else
				table.insert(tempoMap, v2)
			end
		end

		return tempoMap
	end

	local function ticksToSeconds(p, tempoMap, pulsesPerQuarter)
		local tempo = tempoMap[1].Tempo
		local v = 0
		local total = 0

		for i = 2, #tempoMap do
			local item = tempoMap[i]

			if p <= item.Tick then
				break
			end

			total += (item.Tick - v) * tempo / (pulsesPerQuarter * 1000000)
			v = item.Tick
			tempo = item.Tempo
		end

		return total + (p - v) * tempo / (pulsesPerQuarter * 1000000)
	end

	fn3 = function(loaded)
		if not loaded or loaded.ParseType ~= "Summation" then
			return
		end

		local pulsesPerQuarter = loaded.Header and loaded.Header.PulsesPerQuarter

		if not pulsesPerQuarter or pulsesPerQuarter == 0 then
			return
		end

		local tempoMap = buildTempoMap(loaded)
		local playbackTimeLength = 0
		local playbackTimes = {}

		for k, list in next, loaded.Instructions do
			local v = {}

			for i, item in ipairs(list) do
				local v2 = ticksToSeconds(item[2], tempoMap, pulsesPerQuarter)
				v[i] = v2

				if playbackTimeLength < v2 then
					playbackTimeLength = v2
				end
			end

			playbackTimes[k] = v
		end

		loaded.PlaybackTimes = playbackTimes
		loaded.PlaybackTimeLength = playbackTimeLength
	end

	local function usesPlaybackTimes(p) -- 2 equivalent calls inferred from this helper
		return p and p.PlaybackTimes ~= nil
	end

	local function getInstructionTime(p, k, p2, list) -- 2 equivalent calls inferred from this helper
		local playbackTimes = p.PlaybackTimes
		local v = playbackTimes and playbackTimes[k]

		if v and v[p2] then
			return v[p2]
		end

		return list[2] * songLength.Tempo / (p.Header.PulsesPerQuarter * 1000000)
	end

	local function getSchedulerTime(p, p2) -- 3 equivalent calls inferred from this helper
		if usesPlaybackTimes(p) then -- inferred equivalent call
			return p2
		end

		return p2 + songLength.TempoTimePosition
	end

	local function rebuildInstructionCursors(p)
		table.clear(songLength.EndOfTracks)
		table.clear(songLength.InstructionProgress)
		table.clear(songLength.InstructionCursor)

		if not p or p.ParseType ~= "Summation" then
			return
		end

		local schedulerTime = getSchedulerTime(p, songLength.TimePosition) -- inferred equivalent call

		for k, instruction in next, p.Instructions do
			local v = 1

			while v <= #instruction do
				if schedulerTime <= getInstructionTime(p, k, v, instruction[v]) then -- inferred equivalent call
					break
				end

				v += 1
			end

			songLength.InstructionCursor[k] = v
			songLength.InstructionProgress[k] = v - 1
		end
	end

	function songLength:HeartbeatStep(p, p2)
		local syncingDifference = songLength.Syncing and songLength.Syncing.TimePosition - songLength.TimePosition

		if syncingDifference then
			if (syncingDifference and abs(syncingDifference)) > songLength.SyncingThreshold then
				songLength.TimePosition = songLength.Syncing.TimePosition
				songLength.LastTimePosition = songLength.Syncing.LastTimePosition
				rebuildInstructionCursors(p)
				songLength:FireEvent("SyncingCorrecting", { SyncingDifference = syncingDifference })
			end

			songLength.SyncingDifference = syncingDifference
		end

		songLength.LastTimePosition = songLength.TimePosition
		songLength.TimePosition += p2 * songLength.TimeMultiplier

		for k, instruction in next, p.Instructions do
			if not songLength.InstructionProgress[k] then
				songLength.InstructionProgress[k] = 0
			end

			local v = songLength.InstructionCursor[k] or songLength.InstructionProgress[k] + 1

			while v <= #instruction do
				local v2 = instruction[v]
				local instructionTime = getInstructionTime(p, k, v, v2) -- inferred equivalent call

				if getSchedulerTime(p, songLength.TimePosition) < instructionTime then -- inferred equivalent call
					break
				end

				if getSchedulerTime(p, songLength.LastTimePosition) <= instructionTime then -- inferred equivalent call
					if v < songLength.InstructionProgress[k] then
						songLength:FireEvent("Error", {
							TrackNumber = k,
							Message = `Instruction #{v} jumped backwards.`,
							Code = 4
						})
					elseif songLength.InstructionProgress[k] + 1 < v then
						songLength:FireEvent("Error", {
							TrackNumber = k,
							Message = `Instruction #{v} jumped forwards.`,
							Code = 5
						})
					end

					if v2[1] == "SetTempo" then
						if usesPlaybackTimes(p) then -- inferred equivalent call
							songLength.Tempo = v2[3]
						else
							songLength:SetTempo(v2[3])
						end

						if not songLength.IsTempoSet then
							songLength.IsTempoSet = v2[3]
						end
					elseif v2[1] == "EndOfTrack" and not table.find(songLength.EndOfTracks, k) then
						table.insert(songLength.EndOfTracks, k)
					end

					local v3 = v2[1]
					local v4 = fn2(unpack(v2, 2))
					local v5

					if instructionEventData[v3] then
						local v6 = instructionEventData[v3]
						local v7 = fn(clone(v4), 1, k)
						v5 = {}

						for k2, v8 in next, v6 do
							v5[v8] = v7[k2]
						end

						if not v5 then
							v5 = v4
						end
					else
						v5 = v4
					end

					v5.Instruction = v2[1]

					songLength:FireEvent(v2[1], v5)
					songLength:FireEvent("OnInstruction", v5)
				end

				songLength.InstructionProgress[k] = v
				v += 1
			end

			songLength.InstructionCursor[k] = v
		end

		local displayedDuration = songLength.DisplayedDuration or songLength.TimeLength

		if
			#songLength.EndOfTracks ~= #p.Instructions
			and not (displayedDuration > 0 and displayedDuration < songLength.TimePosition)
		then
			songLength:FireEvent("Stepped")

			return songLength
		end

		if not songLength.Loop then
			return songLength:Stop()
		end

		songLength:FireEvent("Looping")
		songLength:SetTimePosition(0)
		songLength:Play()
	end

	function songLength:SetTimePosition(p: number)
		songLength.TimePosition = p
		songLength.LastTimePosition = p
		rebuildInstructionCursors(songLength.Loaded)
		return songLength
	end

	function songLength.Sync(p, syncing)
		if not songLength.IsPlayer then
			return songLength
		end

		songLength.Syncing = syncing

		for k, v in next, syncing do
			if table.find({ "Heartbeat", "Events" }, k) or typeof(v) == "function" then
				continue
			end

			songLength[k] = v
		end

		if songLength.IsPlaying then
			songLength:Play()
		end

		return songLength
	end

	function songLength.Desync(p)
		songLength.Syncing = nil
		songLength.SyncingDifference = 0
		return songLength
	end

	function songLength:Stop()
		if songLength.Heartbeat then
			songLength:FireEvent("Stopped")
		end

		songLength.IsPlaying = false
		songLength:Pause()
		table.clear(songLength.EndOfTracks)
		table.clear(songLength.InstructionProgress)
		table.clear(songLength.InstructionCursor)
		songLength.IsTempoSet = false
		songLength.Tempo = references.BeatsPerMinuteToTempo(120)
		songLength.TimePosition = 0
		songLength.LastTimePosition = 0
		songLength.TempoTimePosition = 0
		songLength.TempoTimeConstant = 1
	end

	function songLength:Pause()
		songLength.IsPlaying = false

		if songLength.Heartbeat then
			songLength:FireEvent("Paused")
			songLength.Heartbeat:Disconnect()
			songLength.Heartbeat = nil
		end
	end

	function songLength:Play()
		local loaded = songLength.Loaded

		if loaded.ParseType == "Default" or loaded.ParseType ~= "Summation" then
			return songLength
		end

		songLength.IsPlaying = true

		if songLength.Heartbeat then
			songLength.Heartbeat:Disconnect()
		end

		local v = songLength
		local RunService = game:GetService("RunService")
		v.Heartbeat = RunService.Heartbeat:Connect(function(dt)
			songLength:HeartbeatStep(loaded, dt)
		end)

		songLength:FireEvent("Playing")

		return songLength
	end

	return songLength
end

function classes.Parser()
	local v = {
		IsParser = true,
		WaitEvery = false,
		WaitTime = 0,
		Tracks = 0,
		Instructions = 0,
		Events = 0
	}

	v.Tracks = {}
	v.Instructions = {}
	v.Events = {}

	function v:Load(p)
		v = setmetatable(v, { __index = p })
		return v
	end

	function v.Parse(p, value: string)
		local hex = v.Raw.Hex

		v.ParseType = value or "Default"
		local v2 = 0

		for i = 1, v.Header.NumberOfTracks do
			local v3
			v3, v2 = find(hex, "4D54726B", v2)
			_ = v3

			if v2 then
				local tracks = v.Tracks
				local v4 = v2 + 1
				local v5 = v2 + 1
				local v6 = v2 + 8
				fn(tracks, { v4, tonumber(sub(hex, v5, v6), 16), 8, {} })
			else
				error(`Number of Tracks did not match decimal of Bytes on TrackData, ended at Track #{i}`)
			end
		end

		local function FireEvent(p2: string, p3) -- 5 equivalent calls inferred from this helper
			if v.Events[p2] then
				if instructionEventData[p2] then
					local event = v.Events[p2]
					local v3

					if instructionEventData[p2] then
						local v4 = instructionEventData[p2]
						local v5 = fn(clone(p3), 1, nil)
						v3 = {}

						for k, v6 in next, v4 do
							v3[v6] = v5[k]
						end

						if not v3 then
							v3 = p3
						end
					else
						v3 = p3
					end

					task.spawn(event, v3)
				else
					task.spawn(v.Events[p2], p3)
				end
			end
		end

		for k, track in next, v.Tracks do
			v.Instructions[k] = {}

			if value == "Summation" then
				track.DeltaSummation = 0
			end
		end

		local v3 = {}
		local count = 0

		while true do
			local flag = true

			for k, track in next, v.Tracks do
				if not v3[k] then
					v3[k] = -1
				end

				if track[4].EndOfTrack or track[4].Exit then
					continue
				end

				local v4 = track[1] + track[3]
				local pointer = v4
				local v5 = 0
				flag = false
				local v6

				while true do
					local v7 = v4 + 1
					local v8 = tonumber(sub(hex, v4, v7), 16)
					v6 = v5 + v8 % 128

					if v8 < 127.5 then
						pointer = v4 + 2
						break
					end

					if #hex <= v4 then
						v6 = 0

						local v9 = {
							TrackNumber = k,
							Message = `No end of Delta-Time found {sub(hex, pointer, pointer + 1)}`,
							Pointer = pointer,
							SurroundingBytes = sub(hex, pointer - 6, pointer + 3),
							Code = 3
						}

						if not v.Events.Error then
							break
						end

						if not instructionEventData.Error then
							task.spawn(v.Events.Error, v9)
							break
						end

						local err = v.Events.Error
						local v10

						if instructionEventData.Error then
							local err2 = instructionEventData.Error
							local v11 = fn(clone(v9), 1, nil)
							v10 = {}

							for k2, v12 in next, err2 do
								v10[v12] = v11[k2]
							end

							if not v10 then
								v10 = v9
							end
						else
							v10 = v9
						end

						task.spawn(err, v10)
						break
					end

					v4 += 2
					v5 = v6 * 128
				end

				if value == "Summation" then
					track.DeltaSummation += v6

					v6 = track.DeltaSummation
				end

				local v7 = sub(hex, pointer, pointer + 1)
				local v8 = tonumber(v7, 16)

				if not v8 then
					track[4].EndOfTrack = true
				end

				local waitEvery = v.WaitEvery

				if waitEvery then
					count += 1

					if count % waitEvery == 0 then
						task.wait(v.WaitTime)
					end
				end

				local pointer2 = pointer + 2

				if v7 == "FF" then
					local v9 = sub(hex, pointer2, pointer2 + 1)
					local v10 = pointer2 + 2

					local v11 = v10 + 1
					local v12 = tonumber(sub(hex, v10, v11), 16)

					local v13 = instructionEventBytes[v9]

					if v13 then
						local total = 2
						local v14 = {}

						for k2, v15 in next, v13[2] do
							if v15 == "LENGTH" then
								v15 = v12 * 2 + 2
							end

							local v16 = v10 + total
							local v17 = v10 + (total + (v15 - 1))
							table.insert(v14, (tonumber(sub(hex, v16, v17), 16)))
							total += v15
						end

						local v15 = { v13[1], v6, unpack(v14) }
						fn(v.Instructions[k], v15)
						FireEvent(v13[1], v15) -- inferred equivalent call

						if v9 == "2F" then
							track[4].EndOfTrack = true
						end

						pointer2 = v10 + (v12 * 2 + 2)
					else
						local pointer3 = v10 - 2
						FireEvent("Error", { -- inferred equivalent call
							TrackNumber = k,
							Message = `Unknown Meta-Event {v9}`,
							Pointer = pointer3,
							SurroundingBytes = sub(hex, pointer3 - 6, pointer3 + 3),
							Code = 0
						})
						break
					end
				else
					local v9 = v3[k]

					if v8 < 240 then
						if v8 and v8 % 256 > 127 then
							v3[k] = v7
							v9 = v3[k]
						else
							pointer2 -= 2

							if v3[k] == -1 then
								fn(v.Instructions[k], { "EndOfTrack", 0 })
								FireEvent("Error", { -- inferred equivalent call
									TrackNumber = k,
									Message = `Running Status not set {v3[k]}`,
									Pointer = pointer2,
									SurroundingBytes = sub(hex, pointer2 - 6, pointer2 + 3),
									Code = 2
								})

								track[4].Exit = true
								break
							end
						end
					else
						v9 = v7
					end

					local v10, v11 = unpack(split(v9, ""))

					local v12 = instructionEventBytes[v10] or instructionEventBytes[v9]

					if v12 then
						local v13 = pointer2 + 1
						local v14 = tonumber(sub(hex, pointer2, v13), 16)
						local total = 0
						local v15 = {}

						for k2, v16 in next, v12[2] do
							if v16 == "LENGTH" then
								v16 = v14 * 2 + 2
							end

							local v17 = pointer2 + total
							local v18 = pointer2 + (total + (v16 - 1))
							table.insert(v15, (tonumber(sub(hex, v17, v18), 16)))
							total += v16
						end

						local v16 = { v12[1], v6, tonumber(v11, 16), unpack(v15) }
						fn(v.Instructions[k], v16)
						FireEvent(v12[1], v16) -- inferred equivalent call

						pointer2 += total
					else
						FireEvent("Error", { -- inferred equivalent call
							TrackNumber = k,
							Message = `Unknown Byte {v9}`,
							Pointer = pointer2,
							SurroundingBytes = sub(hex, pointer2 - 6, pointer2 + 3),
							Code = 1
						})
					end
				end

				track[3] = pointer2 - track[1]
			end

			if flag then
				return v
			end
		end
	end

	return v
end

function classes.Midi()
	return (setmetatable({ IsMidi = true, Raw = {}, Header = {} }, { __index = InteractiveMidi }))
end

function classes.Binder()
	local v = { IsBinder = true, BindingOrder = {} }

	function v.Bind(p, ...)
		v.BindingOrder = { ... }
		return v
	end

	function v:Load(p)
		if not v.BindingOrder[1] then
			return v
		end

		local v2 = v.BindingOrder[1]:Load(p)

		for k, list in next, v.BindingOrder, 1 do
			if list[1] then
				v2 = list[1]:Load(v2)[list[2]](list[1], unpack(list, 3))
			else
				v2 = list:Load(v2)
			end
		end

		return v
	end

	return v
end

function classes.Notator()
	local v = {
		IsNotator = true,
		Instruments = {
			Piano = { SoundId = "rbxassetid://5924276201", Offset = -42 },
			Tuba = { SoundId = "rbxassetid://1846986991", Offset = -42 },
			Recorder = { SoundId = "rbxassetid://75338648", Offset = -42 }
		},
		Percussion = {
			[35] = "rbxassetid://31173820",
			[36] = "rbxassetid://31173820",
			[82] = "rbxassetid://31173898",
			[62] = "rbxassetid://57802212",
			[63] = "rbxassetid://57802212",
			[64] = "rbxassetid://57802134",
			[60] = "rbxassetid://57802055",
			[61] = "rbxassetid://57801983",
			[45] = "rbxassetid://31173881",
			[47] = "rbxassetid://31173863",
			[48] = "rbxassetid://31173863",
			[50] = "rbxassetid://31173844",
			[56] = "rbxassetid://9120917609",
			[49] = "rbxassetid://31173771",
			[51] = "rbxassetid://31173898",
			[57] = "rbxassetid://31173771",
			[59] = "rbxassetid://31173898",
			[42] = "rbxassetid://4702649974",
			[44] = "rbxassetid://4702649717",
			[46] = "rbxassetid://4702649315",
			[78] = "rbxassetid://7430849680",
			[79] = "rbxassetid://7430849680",
			[38] = "rbxassetid://31173799",
			[40] = "rbxassetid://31173799",
			[80] = "rbxassetid://6732342375",
			[81] = "rbxassetid://6732342375",
			[76] = "rbxassetid://9120917978",
			[77] = "rbxassetid://9120917605"
		}
	}

	function v.AddInstruments(p, items)
		for k, item in next, items do
			v.Instruments[k] = item
		end

		return v
	end

	function v:IsPercussion(p)
		return v.Percussion[p]
	end

	function v.CreateSound(p, p2: string, data)
		local v2 = data.CheckForPercussion and v:IsPercussion(data.NoteNumber)

		local instrument = v.Instruments[p2]

		local sound = Instance.new("Sound")
		sound.Name = concat(fn2(references.NoteNumberToNoteName(data.NoteNumber), ""))
		sound.SoundId = v2 or instrument.SoundId
		sound.PlaybackSpeed = v2 and 1
			or references.NoteNumberToPitch(data.NoteNumber, data.Offset or instrument.Offset)
		sound.Volume = data.Velocity / 127
		return sound
	end

	return v
end

function classes.Visualizer()
	local v = { IsVisualizer = true }

	function v.Basic(p, data)
		local noteNumberToNoteName = InteractiveMidi.References.NoteNumberToNoteName(data.NoteNumber)

		local part = Instance.new("Part")
		part.Anchored = true
		part.Massless = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CFrame = data.CenterCFrame * CFrame.new((data.NoteNumber - 60) * data.Size, 0, 0)
		part.Size = Vector3.new(find(noteNumberToNoteName, "#") and data.Sharp or data.C, data.Length, data.Z) * data.Size

		local result = { IsBlockData = true, NoteLetter = noteNumberToNoteName, Block = part }

		function result:Stop()
			result.StopThread = true

			if result.MoveThread then
				coroutine.close(result.MoveThread)
				result.MoveThread = nil
			end

			return result
		end

		function result.SmoothHide(p2, duration)
			local TweenService = game:GetService("TweenService")
			TweenService:Create(part, TweenInfo.new(duration), { Transparency = 1 }):Play()
			return result
		end

		function result.SmoothVisibility(p2, duration)
			part.Transparency = 1
			local TweenService = game:GetService("TweenService")
			TweenService:Create(part, TweenInfo.new(duration), { Transparency = 0 }):Play()
			return result
		end

		function result.StopGrow(p2)
			result.Grow = false
			return result
		end

		function result.MoveUp(p2, height, p3, grow)
			result:Stop()
			result.MoveThread = task.spawn(function()
				result.MovingStart = part.CFrame
				result.Height = height
				result.TweenTime = p3 * 2
				result.TimeElapsed = 0
				result.LastBlockTime = 0
				result.BlockTime = 0
				result.StopThread = false
				result.Grow = grow

				while result.TimeElapsed < result.TweenTime do
					result.LastBlockTime = result.BlockTime
					local v2 = task.wait()
					result.BlockTime += v2
					result.TimeElapsed += v2

					local v3 = result.Height * (result.BlockTime / result.TweenTime)
					local v4 = result.Height * (result.TimeElapsed / result.TweenTime)
					part.CFrame = result.MovingStart * CFrame.new(0, v3 + v4, 0)

					if not result.Grow then
						continue
					end

					local v5 = result.Height * (result.TimeElapsed / result.TweenTime)
					part.Size = part.Size * Vector3.new(1, 0, 1) + Vector3.new(0, 1, 0) * v5 * 2
					result.BlockTime = result.LastBlockTime
				end
			end)

			return result
		end

		part.Destroying:Once(result.Stop)

		return result
	end

	return v
end

function InteractiveMidi.new(...)
	local v = {}

	for k, v2 in next, { ... } do
		if v2 and classes[v2] then
			fn(v, classes[v2]())
		else
			local v3 = ""

			for k2, v4 in next, classes do
				v3 ..= k2 .. ", "
			end

			local v4 = sub(v3, 1, #v3 - 2)

			error(`{v2} is an Invalid Midi Class. Classes: [{v4}] EX: InteractiveMidi.new("Midi")`)
		end
	end

	return unpack(v)
end

function InteractiveMidi:Load(value)
	assert(value, "Buffer is nil or false.")
	assert(typeof(value) == "string", `Invalid Buffer Type got {typeof(value)} expected string`)

	local hex = ByteRealm:ToHex(value)
	self.Raw.Hex = hex

	local header = ByteRealm:GetHeader(value)
	assert(header == "MThd", `Invalid Header got {header} expected MThd`)

	assert(
		ByteRealm:HexToDecimal((sub(hex, 10, 16))) == 6,
		"Most significant byte of MThd header chunk length is not 6"
	)

	self.Header.Format = ByteRealm:HexToDecimal((sub(hex, 18, 20)))
	self.Header.NumberOfTracks = ByteRealm:HexToDecimal((sub(hex, 22, 24)))
	self.Header.PulsesPerQuarter = ByteRealm:HexToDecimal((sub(hex, 26, 28)))

	return self
end

return InteractiveMidi