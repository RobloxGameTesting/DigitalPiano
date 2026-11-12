local RunService = game:GetService("RunService")

local CommunityRefreshController = {}
CommunityRefreshController.__index = CommunityRefreshController

local v = { Community = true, Favorites = true, Reports = true, Hidden = true }

local v2 = { MIDI = true, Reports = true, Hidden = true }

local v3 = { Blocked = true }

function CommunityRefreshController:_ensureRefreshIcon()
	local button = self.Button
	local refreshIcon = button:FindFirstChild("RefreshIcon")

	if refreshIcon and not refreshIcon:IsA("ImageLabel") then
		refreshIcon:Destroy()
		refreshIcon = nil
	end

	if not refreshIcon then
		refreshIcon = Instance.new("ImageLabel")
		refreshIcon.Name = "RefreshIcon"
		refreshIcon.BackgroundTransparency = 1
		refreshIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		refreshIcon.Position = UDim2.fromScale(0.5, 0.5)
		refreshIcon.Size = UDim2.new(0, 20, 0, 20)
		refreshIcon.ScaleType = Enum.ScaleType.Fit
		refreshIcon.ZIndex = button.ZIndex + 1
		refreshIcon.Parent = button
	end

	local image = button.Image

	if image and image ~= "" then
		refreshIcon.Image = image
	end

	refreshIcon.ImageColor3 = button.ImageColor3
	refreshIcon.ImageTransparency = button.ImageTransparency
	refreshIcon.Visible = true
	refreshIcon.Rotation = 0

	button.Image = ""
	button.ImageTransparency = 1
	button.Rotation = 0
	return refreshIcon
end

function CommunityRefreshController:_startIdleSpin()
	if self._spinConnection then
		return
	end

	self._spinConnection = RunService.RenderStepped:Connect(function(dt)
		local button = self.Button

		if button and button.Parent and button.Rotation ~= 0 then
			button.Rotation = 0
		end

		local refreshIcon = self.RefreshIcon

		if refreshIcon and refreshIcon.Parent then
			if
				self._fastSpinActive
				or self.IsRefreshing
				or self.Refreshing
				or self.IsBusy
				or self.Busy
				or self.Loading
			then
				if button and button.Parent and button.Rotation ~= 0 then
					button.Rotation = 0
				end
			else
				local idleSpinDegreesPerSecond = tonumber(self.IdleSpinDegreesPerSecond) or 0

				if idleSpinDegreesPerSecond <= 0 then
					return
				end

				refreshIcon.Rotation = (refreshIcon.Rotation + idleSpinDegreesPerSecond * dt) % 360
			end
		elseif self._spinConnection then
			self._spinConnection:Disconnect()
			self._spinConnection = nil
		end
	end)
end

function CommunityRefreshController.new(data)
	assert(type(data) == "table", "CommunityRefreshController.new requires options")
	assert(data.Button and data.Button:IsA("ImageButton"), "CommunityRefreshController requires an ImageButton")
	assert(type(data.RefreshSheets) == "function", "CommunityRefreshController requires RefreshSheets")
	assert(type(data.RefreshMidi) == "function", "CommunityRefreshController requires RefreshMidi")
	assert(type(data.RefreshBlocked) == "function", "CommunityRefreshController requires RefreshBlocked")

	local object = setmetatable({}, CommunityRefreshController)
	object.Button = data.Button
	object.RefreshIcon = object:_ensureRefreshIcon()
	object.IdleSpinDegreesPerSecond = math.max(0, tonumber(data.IdleSpinDegreesPerSecond) or 28)
	object._spinConnection = nil
	object._fastSpinActive = false
	object:_startIdleSpin()
	object.RefreshSheets = data.RefreshSheets
	object.RefreshMidi = data.RefreshMidi
	object.RefreshBlocked = data.RefreshBlocked
	object.CooldownSeconds = math.max(1, tonumber(data.CooldownSeconds) or 5)
	object.StaleSeconds = math.max(object.CooldownSeconds, tonumber(data.StaleSeconds) or 25)
	object.Mode = "Community"
	object.LastRefreshAt = -1e999
	object.LastLoadedAt = { Sheets = 0, Midi = 0, Blocked = 0 }

	object.Active = { Sheets = false, Midi = false, Blocked = false }

	object.SpinToken = 0

	object.Button.Activated:Connect(function()
		object:RefreshCurrentMode()
	end)
	object:UpdateButton()
	return object
end

function CommunityRefreshController:ModeUsesSheets(p): boolean
	return v[tostring(p or self.Mode)] == true
end

function CommunityRefreshController:ModeUsesMidi(p): boolean
	return v2[tostring(p or self.Mode)] == true
end

function CommunityRefreshController:ModeUsesBlocked(p): boolean
	return v3[tostring(p or self.Mode)] == true
end

function CommunityRefreshController.IsStale(p, p2): boolean
	local v4 = tonumber(p.LastLoadedAt[p2]) or 0
	return v4 <= 0 or os.clock() - v4 >= p.StaleSeconds
end

function CommunityRefreshController:MarkLoaded(p)
	self.LastLoadedAt[p] = os.clock()
	self:UpdateButton()
end

function CommunityRefreshController:Begin(p)
	self.LastRefreshAt = os.clock()
	self.Active[p] = true
	self:UpdateButton()
	self:StartSpin()
	task.delay(self.CooldownSeconds, function()
		self:UpdateButton()
	end)
end

function CommunityRefreshController:Finish(p)
	self.Active[p] = false
	self:UpdateButton()
end

function CommunityRefreshController:SetMode(value)
	self.Mode = tostring(value or "Community")
	self:UpdateButton()
end

function CommunityRefreshController:UpdateButton()
	local visible = self:ModeUsesSheets() or self:ModeUsesMidi() or self:ModeUsesBlocked()
	local sheets = self:ModeUsesSheets() and self.Active.Sheets
		or self:ModeUsesMidi() and self.Active.Midi
		or self:ModeUsesBlocked() and self.Active.Blocked
	local v4 = math.max(0, self.CooldownSeconds - (os.clock() - self.LastRefreshAt))
	local v5 = visible and not sheets and v4 <= 0

	self.Button.Visible = visible
	self.Button.Interactable = v5
	self.Button.Selectable = v5
	self.Button.BackgroundColor3 = v5 and Color3.fromRGB(39, 43, 55) or Color3.fromRGB(31, 34, 44)

	if self.RefreshIcon then
		self.RefreshIcon.ImageColor3 = v5 and Color3.fromRGB(190, 198, 214) or Color3.fromRGB(104, 111, 128)
	end

	self.Button:SetAttribute("CooldownRemaining", (math.ceil(v4)))
end

function CommunityRefreshController:StartSpin()
	self.SpinToken += 1
	local spinToken = self.SpinToken
	task.spawn(function()
		while spinToken == self.SpinToken and (self.Active.Sheets or self.Active.Midi or self.Active.Blocked) do
			local refreshIcon = self.RefreshIcon or self:_ensureRefreshIcon()
			self.Button.Rotation = 0
			refreshIcon.Rotation = (refreshIcon.Rotation + 24) % 360
			task.wait(0.06)
		end

		if spinToken == self.SpinToken then
			self.Button.Rotation = 0

			if self.RefreshIcon then
				self.RefreshIcon.Rotation = 0
			end

			self:UpdateButton()
		end
	end)
end

function CommunityRefreshController:RefreshCurrentMode()
	if os.clock() - self.LastRefreshAt < self.CooldownSeconds then
		self:UpdateButton()
		return
	end

	self.LastRefreshAt = os.clock()
	self:UpdateButton()

	if self:ModeUsesSheets() then
		self.RefreshSheets()
	end

	if self:ModeUsesMidi() then
		self.RefreshMidi()
	end

	if self:ModeUsesBlocked() then
		self.RefreshBlocked()
	end
end

return CommunityRefreshController