local function isKeyboard(p): boolean
	return p == Enum.UserInputType.Keyboard or p == Enum.UserInputType.TextInput
end

return isKeyboard