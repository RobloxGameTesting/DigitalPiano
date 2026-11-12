local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Cryo = require(MerchBooth.Packages.Cryo)
local Rodux = require(MerchBooth.Packages.Rodux)
local enums = require(MerchBooth.enums)
local setControls = require(MerchBooth.Actions.setControls)

local v = {
	[enums.Controls.ProximityPrompts] = {
		keyboard = Enum.KeyCode.E,
		gamepad = Enum.KeyCode.ButtonY
	},
	[enums.Controls.OpenMerchBooth] = { gamepad = Enum.KeyCode.ButtonY },
	[enums.Controls.CloseMerchBooth] = { gamepad = Enum.KeyCode.ButtonB },
	[enums.Controls.Filter] = { gamepad = Enum.KeyCode.ButtonX }
}

return (Rodux.createReducer(v, {
	[setControls.name] = function(p, p2)
		assert(p[p2.name], ("A control named %q does not exist and could not be set"):format(p2.name))
		assert(
			p2.keyCodes.keyboard or p2.keyCodes.gamepad,
			"A control must have a KeyCode defined for at least one of the keys 'gamepad' or 'keyboard'"
		)

		return Cryo.Dictionary.join(p, { [p2.name] = p2.keyCodes })
	end
}))