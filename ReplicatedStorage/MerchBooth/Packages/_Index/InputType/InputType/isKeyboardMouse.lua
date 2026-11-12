local isKeyboard = require(script.Parent.isKeyboard)
local isMouse = require(script.Parent.isMouse)

local function isKeyboardMouse(p)
	return isMouse(p) or isKeyboard(p)
end

return isKeyboardMouse