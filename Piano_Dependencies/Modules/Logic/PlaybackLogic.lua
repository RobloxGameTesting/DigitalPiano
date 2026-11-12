local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
return {
	Play = function(p, data)
		if p and p.Notes then
			local v = {
				IsRunning = true,
				IsPaused = false,
				PauseStartTime = 0,
				TotalPausedTime = 0,
				HeldNotes = {},
				Stop = function(p2)
					p2.IsRunning = false

					for k, heldNote in pairs(p2.HeldNotes) do
						if data.onNoteRelease then
							data.onNoteRelease(k, heldNote.velocity, heldNote.transposition, heldNote.sustainPacket)
						end
					end

					p2.HeldNotes = {}
				end,
				Pause = function(state)
					if not state.IsPaused then
						state.IsPaused = true
						state.PauseStartTime = tick()

						for k, heldNote in pairs(state.HeldNotes) do
							if data.onNoteRelease then
								data.onNoteRelease(k, heldNote.velocity, heldNote.transposition, heldNote.sustainPacket)
							end
						end

						state.HeldNotes = {}
					end
				end,
				Resume = function(state)
					if state.IsPaused then
						state.IsPaused = false
						state.TotalPausedTime += tick() - state.PauseStartTime
					end
				end
			}

			task.spawn(function()
				local lastTime = tick()
				local v2 = 1

				while v2 <= #p.Notes and v.IsRunning do
					if v.IsPaused then
						task.wait(0.01)
					else
						local note = p.Notes[v2]

						if tick() - lastTime - v.TotalPausedTime >= note.Timestamp then
							if note.Action == "Press" and data.onNotePress then
								data.onNotePress(note.NoteNumber, note.Velocity, note.Transposition, note.SustainPacket)

								v.HeldNotes[note.NoteNumber] = {
									velocity = note.Velocity,
									transposition = note.Transposition,
									sustainPacket = note.SustainPacket
								}
							elseif note.Action == "Release" and data.onNoteRelease then
								data.onNoteRelease(
									note.NoteNumber,
									note.Velocity,
									note.Transposition,
									note.SustainPacket
								)

								v.HeldNotes[note.NoteNumber] = nil
							elseif note.Action == "SustainToggle" and data.onSustainToggle then
								data.onSustainToggle(note.SustainEnabled)
							end

							v2 += 1
						else
							task.wait(0.01)
						end
					end
				end

				if v.IsRunning and data.onComplete then
					data.onComplete()
				end
			end)

			return v
		end

		ClientDebugConfig.Warn("[PlaybackLogic] Invalid recording")
		return nil
	end
}