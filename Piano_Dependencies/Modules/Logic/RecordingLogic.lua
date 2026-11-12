local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

local flag = false
local v = nil
local lastTime = 0
local v2 = {}
local v3 = {}
local fileNumber = 1
local RecordingLogic = {}

function RecordingLogic.IsRecording()
	return flag
end

function RecordingLogic.StartRecording(): boolean
	if flag then
		return false
	end

	flag = true
	lastTime = tick()
	v2 = {}
	v = { Notes = {}, StartTime = lastTime, UniqueNotesSet = {} }

	return true
end

function RecordingLogic.StopRecording()
	if not flag then
		return nil
	end

	for k, v4 in pairs(v2) do
		if v4 and v4.pressTime and v4.velocity then
			local now = tick()
			local timestamp = now - lastTime
			local duration = now - v4.pressTime

			table.insert(v.Notes, {
				Timestamp = timestamp,
				NoteNumber = k,
				Velocity = v4.velocity,
				Transposition = v4.transposition or 0,
				SustainPacket = v4.sustain or false,
				Duration = duration,
				Action = "Release"
			})
		else
			ClientDebugConfig.Warn("[RecordingLogic] Invalid note data for note", k, "during StopRecording")
		end
	end

	flag = false
	local duration = tick() - lastTime
	local count = 0

	for _ in pairs(v.UniqueNotesSet) do
		count += 1
	end

	local now = os.time()
	local v4 = os.date("*t", now)
	local recordedDateLocal = string.format(
		"%02d/%02d/%02d %02d:%02d:%02d",
		v4.day,
		v4.month,
		v4.year % 100,
		v4.hour,
		v4.min,
		v4.sec
	)
	local count2 = 0

	for _, note in ipairs(v.Notes) do
		if note.Action == "Press" then
			count2 += 1
		end
	end

	local v5 = {
		FileName = string.format("Recording #%d", fileNumber),
		Notes = v.Notes,
		Duration = duration,
		RecordedDate = now,
		RecordedDateLocal = recordedDateLocal,
		TotalNotes = count2,
		TotalEvents = #v.Notes,
		UniqueNotes = count,
		FileNumber = fileNumber,
		IsSaved = false
	}

	table.insert(v3, v5)
	fileNumber += 1

	v = nil
	lastTime = 0
	v2 = {}

	return v5
end

function RecordingLogic.RecordNotePress(noteNumber, velocity, transposition, p)
	if not (flag and noteNumber) then
		return
	end

	local now = tick()
	local timestamp = now - lastTime

	v2[noteNumber] = {
		pressTime = now,
		velocity = velocity,
		transposition = transposition,
		sustain = p
	}

	v.UniqueNotesSet[noteNumber] = true

	table.insert(v.Notes, {
		Timestamp = timestamp,
		NoteNumber = noteNumber,
		Velocity = velocity,
		Transposition = transposition,
		SustainPacket = p,
		Duration = 0,
		Action = "Press"
	})
end

function RecordingLogic.RecordNoteRelease(noteNumber, velocity, transposition, sustainPacket)
	if not (flag and noteNumber) then
		return
	end

	local now = tick()
	local timestamp = now - lastTime
	local duration

	if v2[noteNumber] then
		duration = now - v2[noteNumber].pressTime
		v2[noteNumber] = nil
	else
		duration = 0
	end

	table.insert(v.Notes, {
		Timestamp = timestamp,
		NoteNumber = noteNumber,
		Velocity = velocity,
		Transposition = transposition,
		SustainPacket = sustainPacket,
		Duration = duration,
		Action = "Release"
	})
end

function RecordingLogic.RecordSustainToggle(sustainEnabled)
	if not flag then
		return
	end

	local timestamp = tick() - lastTime

	table.insert(v.Notes, {
		Timestamp = timestamp,
		Action = "SustainToggle",
		SustainEnabled = sustainEnabled
	})
end

function RecordingLogic.GetLatestRecording()
	return v3[#v3]
end

function RecordingLogic.ClearLocalCache()
	v3 = {}
end

function RecordingLogic.GetRecordingStats(data)
	if not data then
		return nil
	end

	local count = 0
	local count2 = 0

	for _, note in ipairs(data.Notes) do
		if note.Action == "Press" then
			count2 += 1
		elseif note.Action == "Release" then
			count += 1
		end
	end

	return {
		TotalEvents = #data.Notes,
		Presses = count2,
		Releases = count,
		Duration = data.Duration,
		UniqueNotes = data.UniqueNotes
	}
end

function RecordingLogic.InitializeFileNumber(list)
	if list and #list ~= 0 then
		local v4 = 0

		for _, item in ipairs(list) do
			if item.FileNumber and v4 < item.FileNumber then
				v4 = item.FileNumber
			end

			if not item.FileName then
				continue
			end

			local v5 = string.match(item.FileName, "Recording #(%d+)")

			if not v5 then
				continue
			end

			local v6 = tonumber(v5)

			if v6 and v4 < v6 then
				v4 = v6
			end
		end

		local v5 = v4 + 1

		if fileNumber < v5 then
			fileNumber = v5
		end
	elseif fileNumber <= 1 then
		fileNumber = 1
	end
end

return RecordingLogic