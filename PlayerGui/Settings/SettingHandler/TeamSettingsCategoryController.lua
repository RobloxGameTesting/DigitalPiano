local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local TeamSettingsCategoryController = {}
TeamSettingsCategoryController.__index = TeamSettingsCategoryController

local color = Color3.fromRGB(45, 118, 235)
local color2 = Color3.fromRGB(34, 39, 44)
local color3 = Color3.fromRGB(160, 166, 180)

local function ensureCorner(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	local uiCorner = guiObject:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, p)
	uiCorner.Parent = guiObject
end

local function clearList(list)
	if not list then
		return
	end

	for _, uiListLayout in ipairs(list:GetChildren()) do
		if not uiListLayout:IsA("UIListLayout") then
			uiListLayout:Destroy()
		end
	end
end

local function getRemotes()
	local success, result = pcall(function()
		local piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)
		return piano_Dependencies and piano_Dependencies:WaitForChild("Remotes", 10)
	end)

	return success and result or nil
end

local success, result = pcall(function()
	return ReplicatedStorage:WaitForChild("SoundFX", 5)
end)
local clickSound

if success and result then
	clickSound = result:FindFirstChild("ClickSound")
else
	clickSound = nil
end

local function safeClick() -- 3 equivalent calls inferred from this helper
	if clickSound then
		pcall(function()
			clickSound:Play()
		end)
	end
end

local function createSettingRow(parent, p, value, layoutOrder)
	local name = tostring(p):gsub("%s+", "") .. "Row"
	local parent2 = parent:FindFirstChild(name)

	if not parent2 then
		parent2 = Instance.new("Frame")
		parent2.Name = name
		parent2.Parent = parent
	end

	parent2.LayoutOrder = layoutOrder
	parent2.Size = UDim2.new(1, -8, 0, 58)
	parent2.BackgroundColor3 = Color3.fromRGB(36, 41, 46)
	parent2.BorderSizePixel = 0
	ensureCorner(parent2, 8)

	local label = parent2:FindFirstChild("Label") or Instance.new("TextLabel")
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0, 0.5)
	label.Position = UDim2.new(0, 14, 0.5, value and -8 or 0)
	label.Size = UDim2.new(1, -160, 0, 22)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = tostring(p)
	label.TextColor3 = Color3.fromRGB(240, 242, 246)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = parent2

	local description = parent2:FindFirstChild("Description") or Instance.new("TextLabel")
	description.Name = "Description"
	description.AnchorPoint = Vector2.new(0, 0.5)
	description.Position = UDim2.new(0, 14, 0.5, 13)
	description.Size = UDim2.new(1, -160, 0, 18)
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.Gotham
	description.Text = value or ""
	description.TextColor3 = Color3.fromRGB(160, 166, 180)
	description.TextSize = 12
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextTruncate = Enum.TextTruncate.AtEnd
	description.Visible = value ~= nil and value ~= ""
	description.Parent = parent2

	return parent2
end

local function createActionButton(settingRow, value)
	local action = settingRow:FindFirstChild("Action") or Instance.new("TextButton")
	action.Name = "Action"
	action.AnchorPoint = Vector2.new(1, 0.5)
	action.Position = UDim2.new(1, -12, 0.5, 0)
	action.Size = UDim2.new(0, 118, 0, 34)
	action.BackgroundColor3 = color
	action.BorderSizePixel = 0
	action.AutoButtonColor = true
	action.Font = Enum.Font.GothamBold
	action.Text = tostring(value or "")
	action.TextColor3 = Color3.fromRGB(255, 255, 255)
	action.TextSize = 13
	action.Parent = settingRow
	ensureCorner(action, 8)
	return action
end

function TeamSettingsCategoryController.new(p)
	local localPlayer = Players.LocalPlayer
	local center = p.Parent:WaitForChild("Settings"):WaitForChild("Center")
	local body = center:WaitForChild("Body")
	local sideBar = center:WaitForChild("SideBar")
	local categoryScroll = sideBar:FindFirstChild("CategoryScroll") or sideBar
	local general = body:WaitForChild("General")
	local list = general:WaitForChild("List")
	local reset = general:WaitForChild("Reset")
	local privacy = categoryScroll:FindFirstChild("Privacy") or sideBar:WaitForChild("Privacy")
	local team = localPlayer.Team

	local object = setmetatable({}, TeamSettingsCategoryController)
	object.LocalPlayer = localPlayer
	object.Body = body
	object.SideBar = sideBar
	object.CategoryContainer = categoryScroll
	object.GeneralFrame = general
	object.BaseList = list
	object.BaseReset = reset
	object.Frame = body:FindFirstChild("Teams")
	object.Sidebar = categoryScroll:FindFirstChild("Teams") or sideBar:FindFirstChild("Teams")
	object.Button = nil
	object.List = nil
	object.ResetButton = nil
	object.GetTeamOptions = nil
	object.SetTeamPreference = nil
	object.Preference = tostring(localPlayer:GetAttribute("TeamPreference") or "Default")
	object.Payload = {
		Preference = object.Preference,
		DefaultTeamName = tostring(localPlayer:GetAttribute("DefaultTeamName") or ""),
		CurrentTeamName = team and team.Name or "Guest",
		CurrentTeamColor = team and team.TeamColor.Color or color3,
		Options = {}
	}

	object.RequestInFlight = false

	if not object.Frame then
		object.Frame = general:Clone()
		object.Frame.Name = "Teams"
		object.Frame.Visible = false
		object.Frame.Parent = body
		clearList(object.Frame:FindFirstChild("List"))
	end

	if object.Sidebar then
		if object.Sidebar.Parent ~= categoryScroll and categoryScroll:IsDescendantOf(sideBar) then
			object.Sidebar.Parent = categoryScroll
		end
	else
		object.Sidebar = privacy:Clone()
		object.Sidebar.Name = "Teams"

		for _, teams in ipairs(object.Sidebar:GetChildren()) do
			if not teams:IsA("TextLabel") then
				continue
			end

			teams.Name = "Teams"
			teams.Text = "Teams"
		end

		object.Sidebar.Parent = categoryScroll
	end

	object.List = object.Frame:WaitForChild("List")
	object.ResetButton = object.Frame:WaitForChild("Reset")
	object.Button = object.Sidebar:WaitForChild("Active")
	object.Sidebar.LayoutOrder = 5
	object.Sidebar.Visible = true
	ensureCorner(object.Sidebar, 8)

	local textLabel = object.Sidebar:FindFirstChildWhichIsA("TextLabel")

	if textLabel then
		textLabel.AnchorPoint = Vector2.new(0, 0)
		textLabel.Position = UDim2.new(0, 12, 0, 0)
		textLabel.Size = UDim2.new(1, -24, 1, 0)
		textLabel.Text = "Teams"
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextYAlignment = Enum.TextYAlignment.Center
		textLabel.TextWrapped = true
		textLabel.TextScaled = true
		textLabel.TextTruncate = Enum.TextTruncate.None
		local uiTextSizeConstraint = textLabel:FindFirstChildOfClass("UITextSizeConstraint")
			or Instance.new("UITextSizeConstraint")
		uiTextSizeConstraint.MinTextSize = 12
		uiTextSizeConstraint.MaxTextSize = 22
		uiTextSizeConstraint.Parent = textLabel
	end

	local success2, result2 = pcall(function()
		local piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)
		return piano_Dependencies and piano_Dependencies:WaitForChild("Remotes", 10)
	end)
	local v = success2 and result2 or nil

	if v then
		object.GetTeamOptions = v:FindFirstChild("GetTeamOptions") or v:WaitForChild("GetTeamOptions", 5)
		object.SetTeamPreference = v:FindFirstChild("SetTeamPreference") or v:WaitForChild("SetTeamPreference", 5)
	end

	return object
end

function TeamSettingsCategoryController.NormalizeLayout(data)
	data.Frame.AnchorPoint = data.GeneralFrame.AnchorPoint
	data.Frame.Position = data.GeneralFrame.Position
	data.Frame.Size = data.GeneralFrame.Size
	data.Frame.BackgroundColor3 = data.GeneralFrame.BackgroundColor3
	data.Frame.BackgroundTransparency = data.GeneralFrame.BackgroundTransparency
	data.Frame.BorderSizePixel = data.GeneralFrame.BorderSizePixel

	data.List.AnchorPoint = data.BaseList.AnchorPoint
	data.List.Position = data.BaseList.Position
	data.List.Size = UDim2.new(1, 0, 1, -54)
	data.List.BackgroundColor3 = data.BaseList.BackgroundColor3
	data.List.BackgroundTransparency = data.BaseList.BackgroundTransparency
	data.List.BorderSizePixel = data.BaseList.BorderSizePixel
	data.List.AutomaticCanvasSize = Enum.AutomaticSize.Y
	data.List.CanvasSize = UDim2.new(0, 0, 0, 0)
	data.List.ScrollBarThickness = 4
	local uiPadding = data.List:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
	uiPadding.Name = "UIPadding"
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.Parent = data.List
	ensureCorner(data.Frame, 8)
	ensureCorner(data.List, 8)

	data.ResetButton.AnchorPoint = Vector2.new(0, 1)
	data.ResetButton.Position = UDim2.new(0, 0, 1, -2)
	data.ResetButton.Size = UDim2.new(1, 0, 0, 36)
	data.ResetButton.Text = "Reset Team"
	ensureCorner(data.ResetButton, 8)
end

function TeamSettingsCategoryController.SetActive(p, p2)
	p.Frame.Visible = p2 == true
	p.Sidebar.BackgroundColor3 = p2 and color or color2
end

function TeamSettingsCategoryController.ConnectButton(p, onMouseButton1Click)
	if p.Button then
		p.Button.MouseButton1Click:Connect(onMouseButton1Click)
	end
end

function TeamSettingsCategoryController:_notify(value, value2, p)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = tostring(value or "Settings"),
			Text = tostring(value2 or ""),
			Duration = tonumber(p) or 3
		})
	end)
end

function TeamSettingsCategoryController:_applyPayload(payload)
	if typeof(payload) ~= "table" then
		return
	end

	self.Payload = payload
	self.Payload.Options = typeof(payload.Options) == "table" and payload.Options or {}
	self.Preference = tostring(payload.Preference or "Default")
	self.LocalPlayer:SetAttribute("TeamPreference", self.Preference)

	if typeof(payload.DefaultTeamName) == "string" then
		self.LocalPlayer:SetAttribute("DefaultTeamName", payload.DefaultTeamName)
	end

	if typeof(payload.CurrentTeamName) == "string" then
		self.LocalPlayer:SetAttribute("EffectiveTeamName", payload.CurrentTeamName)
	end
end

function TeamSettingsCategoryController:_addSwatch(parent, p)
	local teamSwatch = parent:FindFirstChild("TeamSwatch") or Instance.new("Frame")
	teamSwatch.Name = "TeamSwatch"
	teamSwatch.AnchorPoint = Vector2.new(0, 0.5)
	teamSwatch.Position = UDim2.new(0, 14, 0.5, 0)
	teamSwatch.Size = UDim2.new(0, 18, 0, 18)
	teamSwatch.BackgroundColor3 = typeof(p) == "Color3" and p or color3
	teamSwatch.BorderSizePixel = 0
	teamSwatch.Parent = parent
	ensureCorner(teamSwatch, 5)

	local label = parent:FindFirstChild("Label")

	if label then
		label.Position = UDim2.new(0, 44, 0.5, -8)
		label.Size = UDim2.new(1, -190, 0, 22)
	end

	local description = parent:FindFirstChild("Description")

	if description then
		description.Position = UDim2.new(0, 44, 0.5, 13)
		description.Size = UDim2.new(1, -190, 0, 18)
	end
end

function TeamSettingsCategoryController:_clearRows()
	for _, frame in ipairs(self.List:GetChildren()) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

function TeamSettingsCategoryController:_description(p)
	if p.IsDefault == true then
		local defaultTeamName = tostring(self.Payload.DefaultTeamName or "")

		if defaultTeamName ~= "" then
			return "Automatic role: " .. defaultTeamName .. "."
		end
	end

	return (tostring(p.Description or "Available to your account."))
end

function TeamSettingsCategoryController:Render()
	self:_clearRows()

	local options = self.Payload.Options or {}

	if #options == 0 then
		local actionButton = createActionButton(
			createSettingRow(
				self.List,
				"Team Options",
				self.GetTeamOptions and "Loading available teams." or "Team settings are unavailable right now.",
				2
			),
			self.GetTeamOptions and "Refresh" or "Unavailable"
		)
		actionButton.BackgroundColor3 = self.GetTeamOptions and color or color2
		actionButton.AutoButtonColor = self.GetTeamOptions ~= nil
		actionButton.Active = self.GetTeamOptions ~= nil

		if self.GetTeamOptions then
			actionButton.MouseButton1Click:Connect(function()
				safeClick() -- inferred equivalent call
				self:Refresh(true)
			end)
		end
	else
		for i, option in ipairs(options) do
			local name = tostring(option.Name or "")
			local v = option.IsSelected == true or name == self.Preference
			local settingRow = createSettingRow(
				self.List,
				tostring(option.DisplayName or name),
				self:_description(option),
				i + 10
			)
			self:_addSwatch(settingRow, option.Color)
			local actionButton = createActionButton(settingRow, v and "Selected" or "Use")
			actionButton.BackgroundColor3 = v and color2 or color
			actionButton.AutoButtonColor = not v
			actionButton.Active = true
			actionButton.MouseButton1Click:Connect(function()
				if v or name == "" or self.RequestInFlight then
					return
				end

				safeClick() -- inferred equivalent call
				self:SetPreference(name)
			end)
		end
	end
end

function TeamSettingsCategoryController:Refresh(p)
	if not self.GetTeamOptions then
		local success2, result2 = pcall(function()
			local piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 10)
			return piano_Dependencies and piano_Dependencies:WaitForChild("Remotes", 10)
		end)
		local v = success2 and result2 or nil

		if v then
			self.GetTeamOptions = v:FindFirstChild("GetTeamOptions") or v:WaitForChild("GetTeamOptions", 5)
			self.SetTeamPreference = v:FindFirstChild("SetTeamPreference") or v:WaitForChild("SetTeamPreference", 5)
		end
	end

	if not self.GetTeamOptions then
		self:Render()
		return
	end

	local success2, result2 = pcall(function()
		return self.GetTeamOptions:InvokeServer()
	end)

	if success2 and typeof(result2) == "table" then
		self:_applyPayload(result2)
		self:Render()
	elseif p then
		self:_notify("Teams", "Team options could not be loaded right now.", 3)
	end
end

function TeamSettingsCategoryController:SetPreference(p, p2)
	if self.RequestInFlight or not self.SetTeamPreference then
		return
	end

	self.RequestInFlight = true
	local success2, result2, v, v2 = pcall(function()
		return self.SetTeamPreference:InvokeServer(p)
	end)

	self.RequestInFlight = false

	if success2 and typeof(v2) == "table" then
		self:_applyPayload(v2)
		self:Render()
	end

	if success2 and result2 == true then
		if not p2 then
			self:_notify("Team Updated", tostring(v or "Team preference saved."), 3)
		end
	else
		self:_notify(
			"Team Unavailable",
			success2 and tostring(v or "You cannot use that team.") or "Please try again in a moment.",
			4
		)
	end
end

function TeamSettingsCategoryController:Reset(p)
	self:SetPreference("Default", p)
end

function TeamSettingsCategoryController:ApplyUserSettings(p, p2)
	if typeof(p) ~= "table" or typeof(p.TeamPreference) ~= "string" then
		return
	end

	self.Preference = p.TeamPreference
	self.Payload.Preference = self.Preference
	self.LocalPlayer:SetAttribute("TeamPreference", self.Preference)

	if p2 then
		task.defer(function()
			self:Refresh()
		end)
	else
		self:Render()
	end
end

function TeamSettingsCategoryController:Initialize()
	local v = self.List:FindFirstChildOfClass("UIListLayout")

	if not v then
		v = Instance.new("UIListLayout")
		v.Parent = self.List
	end

	v.SortOrder = Enum.SortOrder.LayoutOrder
	v.Padding = UDim.new(0, 8)

	self.ResetButton.MouseButton1Click:Connect(function()
		safeClick() -- inferred equivalent call
		self:Reset()
	end)

	self:Render()
	task.spawn(function()
		self:Refresh()
	end)
end

return TeamSettingsCategoryController