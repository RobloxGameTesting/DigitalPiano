local ReplicatedStorage = game:GetService("ReplicatedStorage")

local mainModule = ReplicatedStorage:WaitForChild("Services"):WaitForChild("Packeting"):WaitForChild("MainModule")
local module = require(mainModule)

return {
	["NoteSimple"] = module(
		"PianoNoteSimple",
		module.NumberS8,
		module.NumberU8,
		module.NumberS8,
		module.Boolean8,
		module.Any,
		module.NumberS8,
		module.Boolean8,
		module.Any,
		module.Any,
		module.Any
	),
	PerformerVolume = module("PianoPerformerVolume", module.NumberU8),
	NoteEvent = module(
		"PianoNoteEvent",
		module.NumberS8,
		module.String,
		module.NumberF16,
		module.NumberF16,
		module.NumberF16,
		module.Boolean8,
		module.NumberF16,
		module.NumberF16,
		module.Any
	),
	SustainRelease = module("PianoSustainRelease", module.Any, module.NumberF16),
	FinishNonSustainedNotes = module("PianoFinishNonSustainedNotes", module.NumberF16),
	Animation = module("PianoAnimation", module.NumberS8, module.Boolean8),
	NotePlayed = module("PianoNotePlayed"),
	VisualizerControl = module("PianoVisualizerControl", module.String, module.Any, module.Any),
	BatchNotes = module("PianoBatchNotes", {
		{
			Note = module.NumberS8,
			SoundId = module.String,
			Volume = module.NumberF16,
			TimePosition = module.NumberF16,
			Pitch = module.NumberF16,
			SustainPacket = module.Boolean8,
			NoteLifeTime = module.NumberF16,
			Fadeout = module.NumberF16
		}
	}),
	SessionCleanup = module("PianoSessionCleanup", module.Any, module.NumberU32)
}