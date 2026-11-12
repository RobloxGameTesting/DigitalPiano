local InputHandler = {}

local HDAdminMain = _G.HDAdminMain

local MouseMovement = Enum.UserInputType.MouseMovement
local MouseButton1 = Enum.UserInputType.MouseButton1
local Touch = Enum.UserInputType.Touch

HDAdminMain.chatting = false
HDAdminMain.userInputService.TextBoxFocused:connect(function()
	HDAdminMain.chatting = true
end)
HDAdminMain.userInputService.TextBoxFocusReleased:connect(function()
	HDAdminMain.chatting = false
end)
local TextChatService = game:GetService("TextChatService")
local chatInputBarConfiguration = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")

if chatInputBarConfiguration then
	chatInputBarConfiguration:GetPropertyChangedSignal("IsFocused"):Connect(function()
		HDAdminMain.chatting = chatInputBarConfiguration.IsFocused
	end)
end

local v = { HDAdminMain.gui.MainFrame }
local v2 = nil
local position = nil
local position2 = nil
local alsoDragMainFrame = nil
local function dragFrame(input, state)
	local v3 = input.Position - position
	state.Position = UDim2.new(
		position2.X.Scale,
		position2.X.Offset + v3.X,
		position2.Y.Scale,
		position2.Y.Offset + v3.Y
	)

	if state.AbsolutePosition.Y < -80 then
		state.Position += UDim2.new(0, 0, 0, -state.AbsolutePosition.Y)
	end

	if alsoDragMainFrame then
		HDAdminMain.gui.MainFrame.Position = state.Position
	end
end
function InputHandler:MakeFrameDraggable(instance)
	local dragBar = instance.DragBar;
	(dragBar:FindFirstChild("Drag") or dragBar).InputBegan:Connect(function(input)
		if input.UserInputType == MouseButton1 or input.UserInputType == Touch then
			v2 = instance
			position = input.Position
			position2 = instance.Position
			alsoDragMainFrame = instance:GetAttribute("AlsoDragMainFrame")
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					v2 = nil
				end
			end)
		end
	end)
end

for _, v3 in pairs(v) do
	InputHandler:MakeFrameDraggable(v3)
end

local v3 = { "laserEyes" }
local function checkPressFunctions(position3)
	HDAdminMain.lastHitPosition = position3

	for _, v4 in pairs(v3) do
		HDAdminMain:GetModule("cf"):ActivateClientCommand(v4)
	end
end

HDAdminMain.userInputService.InputChanged:Connect(function(input, gameProcessed)
	if
		(input.UserInputType == MouseMovement or input.UserInputType == Touch)
		and (not gameProcessed or v2)
		and HDAdminMain.mouseDown
		and ((HDAdminMain.lastHitPosition - input.Position).magnitude < 150 or HDAdminMain.device ~= "Mobile")
	then
		if v2 then
			dragFrame(input, v2)
		end

		checkPressFunctions(input.Position)
	end
end)

local cmdBar = HDAdminMain.gui.CmdBar
local textBox = cmdBar.SearchFrame.TextBox
local set = {
	[Enum.KeyCode.Left] = true,
	[Enum.KeyCode.Right] = true,
	[Enum.KeyCode.Up] = true,
	[Enum.KeyCode.Down] = true
}
local v4 = {
	[Enum.KeyCode.Left] = "Left",
	[Enum.KeyCode.Right] = "Right",
	[Enum.KeyCode.Up] = "Forwards",
	[Enum.KeyCode.Down] = "Backwards",
	[Enum.KeyCode.A] = "Left",
	[Enum.KeyCode.D] = "Right",
	[Enum.KeyCode.W] = "Forwards",
	[Enum.KeyCode.S] = "Backwards",
	[Enum.KeyCode.Space] = "Up",
	[Enum.KeyCode.R] = "Up",
	[Enum.KeyCode.Q] = "Down",
	[Enum.KeyCode.LeftControl] = "Down",
	[Enum.KeyCode.F] = "Down"
}
HDAdminMain.movementKeysPressed = {}
HDAdminMain.userInputService.InputBegan:Connect(function(input, gameProcessed)
	if
		(input.UserInputType == MouseButton1 or input.UserInputType == Touch)
		and (not gameProcessed or v2)
		and not HDAdminMain.mouseDown
	then
		HDAdminMain.mouseDown = true
		checkPressFunctions(input.Position)
	elseif not HDAdminMain.chatting or cmdBar.Visible and #textBox.Text < 2 then
		local v5 = v4[input.KeyCode]

		if v5 then
			table.insert(HDAdminMain.movementKeysPressed, v5)
		elseif input.KeyCode == Enum.KeyCode.E then
			for k, _ in pairs(HDAdminMain.commandSpeeds) do
				if HDAdminMain.commandsActive[k] then
					HDAdminMain:GetModule("cf"):EndCommand(k)
				else
					HDAdminMain:GetModule("cf"):ActivateClientCommand(k)
				end
			end
		elseif input.KeyCode == Enum.KeyCode.Quote or input.KeyCode == Enum.KeyCode.Semicolon then
			HDAdminMain:GetModule("CmdBar"):ToggleBar(input.KeyCode)
		end
	end

	if set[input.KeyCode] then
		HDAdminMain:GetModule("CmdBar"):PressedArrowKey(input.KeyCode)
	end
end)
HDAdminMain.userInputService.InputEnded:Connect(function(input, _)
	local v5 = v4[input.KeyCode]

	if input.UserInputType == MouseButton1 or input.UserInputType == Touch then
		HDAdminMain.mouseDown = false
	elseif v5 then
		for k, v6 in pairs(HDAdminMain.movementKeysPressed) do
			if v6 == v5 then
				table.remove(HDAdminMain.movementKeysPressed, k)
			end
		end
	end
end)

local humanoid = (HDAdminMain.player.Character or HDAdminMain.player.CharacterAdded:Wait()):WaitForChild("Humanoid")
local module = HDAdminMain:GetModule("Events")

if HDAdminMain.device ~= "Computer" then
	module:New("DoubleJumped", humanoid).Event:Connect(function()
		for k, _ in pairs(HDAdminMain.commandSpeeds) do
			if HDAdminMain.commandsActive[k] then
				HDAdminMain:GetModule("cf"):EndCommand(k)
			else
				HDAdminMain:GetModule("cf"):ActivateClientCommand(k)
			end
		end
	end)
end

return InputHandler