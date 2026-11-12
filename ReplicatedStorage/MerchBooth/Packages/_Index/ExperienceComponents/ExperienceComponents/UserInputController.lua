local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local UserInputController = {}
UserInputController.__index = UserInputController

function UserInputController.new()
	local v = {
		UserInputService = UserInputService,
		ContextActionService = ContextActionService,
		player = Players.LocalPlayer,
		disabled = false
	}

	setmetatable(v, UserInputController)

	v.mobileTouchGuiEnabled = v:getMobileTouchGuiEnabled()
	v.playerControlEnabled = v:getPlayerControlsEnabled()

	return v
end

function UserInputController.getActionName(_): string
	return "FREEZE"
end

function UserInputController:enable()
	self.ContextActionService:UnbindAction("FREEZE")

	if self.UserInputService.TouchEnabled then
		self:setMobileTouchGuiEnabled(self.mobileTouchGuiEnabled)
	else
		self:setPlayerControlsEnabled(self.playerControlEnabled)
	end

	self.disabled = false
end

function UserInputController:disable()
	if self.disabled then
		return
	end

	self.disabled = true

	self.ContextActionService:BindAction("FREEZE", function()
		return Enum.ContextActionResult.Sink
	end, false, table.unpack(Enum.PlayerActions:GetEnumItems()))

	self.playerControlEnabled = self:getPlayerControlsEnabled()

	if not self.UserInputService.TouchEnabled then
		self:setPlayerControlsEnabled(false)

		return
	end

	self.mobileTouchGuiEnabled = self:getMobileTouchGuiEnabled()
	self:setMobileTouchGuiEnabled(false)
end

function UserInputController:getMobileTouchGuiEnabled(): boolean
	return not self.UserInputService.ModalEnabled
end

function UserInputController:setMobileTouchGuiEnabled(flag: boolean)
	self.UserInputService.ModalEnabled = not flag

	self:setPlayerControlsEnabled(flag)
end

function UserInputController:getPlayerControlsEnabled()
	local playerControls = self:_getPlayerControls()
	local activeController = playerControls and playerControls:GetActiveController()

	if activeController then
		return activeController.enabled
	end
end

function UserInputController:setPlayerControlsEnabled(flag: boolean)
	local playerControls = self:_getPlayerControls()

	if playerControls then
		if flag then
			playerControls:Enable()
		else
			playerControls:Disable()
		end
	end
end

function UserInputController:_getPlayerControls()
	if not self._playerControls then
		pcall(function()
			local v = self
			local PlayerModule = require(self.player.PlayerScripts.PlayerModule)
			v._playerControls = PlayerModule:GetControls()
		end)
	end

	return self._playerControls
end

return UserInputController