local HDAdminMain = _G.HDAdminMain

local messageContainer = Instance.new("Folder")
messageContainer.Name = "MessageContainer"
messageContainer.Parent = HDAdminMain.gui
local Messages = {}

for _, name in pairs({ "Messages", "Hints" }) do
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Name = name

	if name == "Hints" then
		local uiListLayout = Instance.new("UIListLayout")
		uiListLayout.Parent = frame
	end

	frame.Parent = messageContainer
end

local function getTargetProp(guiObject) -- 4 equivalent calls inferred from this helper
	if guiObject:IsA("Frame") then
		return "BackgroundTransparency"
	end

	if guiObject:IsA("TextLabel") then
		return "TextTransparency"
	end

	if guiObject:IsA("ImageLabel") then
		return "ImageTransparency"
	end
end

local function displayMessages(items, p, duration)
	for _, frame in pairs(items) do
		local v = frame:IsA("Frame") and p < 0.35 and 0.35 or p

		local v2 = { [getTargetProp(frame)] = v } -- inferred equivalent call
		HDAdminMain.tweenService:Create(frame, TweenInfo.new(duration), v2):Play()
	end

	wait(duration)
end

local function getMessageAppearOrder(clone)
	return {
		{ clone.Bg },
		{ clone.Title, clone.SubTitle, clone.Pic },
		{ clone.Desc }
	}
end

function Messages.Message(_, list)
	local messages = messageContainer.Messages

	local item = list[1]
	local item2 = list[2]
	local item3 = list[3]
	local item4 = list[4]
	local item5 = list[5]
	local item6 = list[6]

	local clone = HDAdminMain.templates.Message:Clone()

	for _, child in pairs(clone:GetChildren()) do
		child[getTargetProp(child)] = 1 -- inferred equivalent call
	end

	clone.Visible = true

	if item2 == "Countdown" then
		local v = { clone.Bg, clone.Title, clone.Desc }
		clone.Title.Text = "Countdown"
		clone.Title.TextColor3 = Color3.fromRGB(200, 200, 200)
		clone.Desc.TextColor3 = item6
		clone.Parent = messages
		spawn(function()
			displayMessages(v, 0, 0.4)
		end)

		for i = 1, item5 do
			clone.Desc.Text = item5 + 1 - i
			wait(1)
		end

		displayMessages(v, 1, 0.4)
	else
		clone.Title.Text = item3
		clone.SubTitle.Text = item3
		clone.Desc.Text = item5
		clone.Desc.TextColor3 = item6

		if item2 == "Server" or item == nil then
			clone.Pic.Visible = false
			clone.SubTitle.Visible = false
		else
			local textSize = HDAdminMain.textService:GetTextSize(
				item3,
				clone.Title.TextSize,
				clone.Title.Font,
				Vector2.new(0, 0)
			)
			clone.Pic.Position = UDim2.new(0.5, -(textSize.X / 2 + 75))
			clone.Pic.Image = HDAdminMain:GetModule("cf"):GetUserImage(item.UserId)
			clone.SubTitle.Text = item4
		end

		clone.Parent = messages

		local messageAppearOrder = getMessageAppearOrder(clone)

		for i = 1, #messageAppearOrder do
			displayMessages(messageAppearOrder[i], 0, 0.4)
		end

		wait(HDAdminMain:GetModule("cf"):GetMessageTime(item5))

		for i = 1, #messageAppearOrder do
			displayMessages(messageAppearOrder[#messageAppearOrder + 1 - i], 1, 0.4)
		end
	end

	clone:Destroy()
end

function Messages.Hint(_, list)
	local hints = messageContainer.Hints

	local item = list[1]
	local item2 = list[2]
	local item3 = list[3]

	local clone = HDAdminMain.templates.Hint:Clone()
	local children = {}

	for _, child in pairs(clone:GetChildren()) do
		child[getTargetProp(child)] = 1 -- inferred equivalent call
		table.insert(children, child)
	end

	clone.Desc.Text = item2
	clone.Desc.TextColor3 = item3
	clone.Parent = hints
	clone.Visible = true

	if item == "Countdown" then
		spawn(function()
			displayMessages(children, 0, 0.6)
		end)

		for i = 1, item2 do
			clone.Desc.Text = item2 + 1 - i
			wait(1)
		end
	else
		clone.Desc.Text = item2
		clone.Desc.TextColor3 = item3
		clone.Parent = hints

		displayMessages(children, 0, 0.6)
		wait(HDAdminMain:GetModule("cf"):GetMessageTime(item2))
	end

	displayMessages(children, 1, 0.6)

	clone:Destroy()
end

function Messages.GlobalAnnouncement(_, data)
	local messages = messageContainer.Messages

	local clone = HDAdminMain.templates.GlobalAnnouncement:Clone()
	local displayFrom = data.DisplayFrom

	for _, child in pairs(clone:GetChildren()) do
		child[getTargetProp(child)] = 1 -- inferred equivalent call
	end

	clone.Visible = true
	clone.Title.Text = data.Title
	clone.Pic.Visible = displayFrom
	clone.SubTitle.Visible = displayFrom
	local textSize = HDAdminMain.textService:GetTextSize(
		clone.SubTitle.Text,
		clone.SubTitle.TextSize,
		clone.SubTitle.Font,
		Vector2.new(0, 0)
	)
	clone.Pic.Position = UDim2.new(0.5, -(textSize.X / 2 + 30), 0, 60)

	if displayFrom then
		clone.Pic.Image = HDAdminMain:GetModule("cf"):GetUserImage(data.SenderId)
		clone.SubTitle.Text = "From " .. data.SenderName
	end

	clone.Desc.TextColor3 = Color3.new(data.Color[1], data.Color[2], data.Color[3])
	clone.Desc.Text = data.Message
	clone.Parent = messages

	local messageAppearOrder = getMessageAppearOrder(clone)

	for i = 1, #messageAppearOrder do
		displayMessages(messageAppearOrder[i], 0, 0.4)
	end

	wait(HDAdminMain:GetModule("cf"):GetMessageTime(data.Message) * 1.5)

	for i = 1, #messageAppearOrder do
		displayMessages(messageAppearOrder[#messageAppearOrder + 1 - i], 1, 0.4)
	end

	clone:Destroy()
end

function Messages.ClearMessageContainer(_)
	for _, child in pairs(messageContainer:GetChildren()) do
		for _, frame in pairs(child:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end
	end
end

return Messages