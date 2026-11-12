local Constants = {}
Constants.TextSize = 16
Constants.Font = Enum.Font.Gotham

Constants.HeaderTextSize = Constants.TextSize * 1.25
Constants.HeaderFont = Enum.Font.GothamBold

Constants.LineHeight = 1.25

Constants.Padding = UDim.new(0, Constants.TextSize)
Constants.PaddingSmall = UDim.new(0, Constants.TextSize / 2)
Constants.PaddingMicro = UDim.new(0, Constants.TextSize / 3)
Constants.PaddingLarge = UDim.new(0, Constants.TextSize * 2)

Constants.White = Color3.fromRGB(255, 255, 255)
Constants.Black = Color3.fromRGB(0, 0, 0)
Constants.Dark = Color3.fromRGB(34, 34, 34)
Constants.Grey = Color3.fromRGB(56, 56, 56)
Constants.Faded = Color3.fromRGB(153, 153, 158)

Constants.Springs = {
	Default = { frequency = 1, dampingRatio = 1 },
	Bouncy = { frequency = 2.5, dampingRatio = 0.65 },
	Zippy = { frequency = 3, dampingRatio = 1 }
}

Constants.DeviceInputTypePatterns = {
	Computer = { "Mouse*", "Keyboard" },
	Mobile = { "Touch" },
	Gamepad = { "Gamepad*" }
}

return Constants