local Chat = game:GetService("Chat")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")

local Cryo = require(ExperienceComponents.Parent.Cryo)

local v = { "PlayerList", "Health", "Backpack", "Chat", "EmotesMenu", "SelfView", "Captures" }

local GuiController = {}
GuiController.__index = GuiController

function GuiController.new(options)
	local v2 = {
		Chat = Chat,
		StarterGui = StarterGui,
		UserInputService = UserInputService,
		player = Players.LocalPlayer,
		whitelist = options or {},
		disabledGuis = {},
		disabledCoreGuis = {}
	}

	setmetatable(v2, GuiController)

	return v2
end

function GuiController:enable()
	for _, v2 in ipairs(self.disabledGuis) do
		v2.Enabled = true
	end

	self.disabledGuis = {}

	for _, v2 in ipairs(self.disabledCoreGuis) do
		self:setCoreGuiEnabledSafe(v2, true)
	end

	self.disabledCoreGuis = {}

	if self.UserInputService.TouchEnabled then
		local v2

		if self.mobileTouchGuiEnabled then
			v2 = self.mobileTouchGuiEnabled
		else
			v2 = self:getMobileTouchGuiEnabled()
		end

		self:setMobileTouchGuiEnabled(v2)
	end

	local v2

	if self.bubbleChatEnabled then
		v2 = self.bubbleChatEnabled
	else
		v2 = self:getBubbleChatEnabled()
	end

	self:setBubbleChatEnabled(v2)
end

function GuiController:disable()
	self.disabledGuis = self:getOtherScreenGuis()

	for _, v2 in ipairs(self.disabledGuis) do
		v2.Enabled = false
	end

	self.disabledCoreGuis = self:getShownCoreGuis()

	for _, v2 in ipairs(self.disabledCoreGuis) do
		self:setCoreGuiEnabledSafe(v2, false)
	end

	if self.UserInputService.TouchEnabled then
		self.mobileTouchGuiEnabled = self:getMobileTouchGuiEnabled()
		self:setMobileTouchGuiEnabled(false)
	end

	if self.Chat.BubbleChatEnabled then
		self.bubbleChatEnabled = self:getBubbleChatEnabled()
		self:setBubbleChatEnabled(false)
	end
end

function GuiController:getBubbleChatEnabled()
	return Chat.BubbleChatEnabled
end

function GuiController:setBubbleChatEnabled(bubbleChatEnabled: boolean)
	Chat.BubbleChatEnabled = bubbleChatEnabled
end

function GuiController:getMobileTouchGuiEnabled(): boolean
	return not self.UserInputService.ModalEnabled
end

function GuiController:setMobileTouchGuiEnabled(flag: boolean)
	self.UserInputService.ModalEnabled = not flag

	self:setPlayerControlsEnabled(flag)
end

function GuiController:setPlayerControlsEnabled(flag: boolean)
	local playerControls = self:_getPlayerControls()

	if playerControls then
		if flag then
			playerControls:Enable()
		else
			playerControls:Disable()
		end
	end
end

function GuiController:_getPlayerControls()
	if not self._playerControls then
		pcall(function()
			local v2 = self
			local PlayerModule = require(self.player.PlayerScripts.PlayerModule)
			v2._playerControls = PlayerModule:GetControls()
		end)
	end

	return self._playerControls
end

function GuiController:getOtherScreenGuis()
	return (Cryo.List.filter(self.player.PlayerGui:GetDescendants(), function(screenGui)
		local v2 = false

		for _, v3 in ipairs(self.whitelist) do
			if v3:getValue() == screenGui then
				v2 = true
				break
			end
		end

		local v3 = screenGui:IsA("ScreenGui") and screenGui.Enabled

		if v3 then
			if screenGui.Name == "ShopGiftNotifications" or screenGui.Name == "CurrencyGui" then
				return false
			end

			return not v2
		end

		return v3
	end))
end

function GuiController:getSupportedCoreGuiTypes()
	local supportedCoreGuiTypes = {}

	for _, v2 in ipairs(v) do
		local v3 = Enum.CoreGuiType[v2]

		if v3 then
			table.insert(supportedCoreGuiTypes, v3)
		end
	end

	return supportedCoreGuiTypes
end

function GuiController:setCoreGuiEnabledSafe(p, flag: boolean)
	return (pcall(function()
		self.StarterGui:SetCoreGuiEnabled(p, flag)
	end))
end

function GuiController:getShownCoreGuis()
	local shownCoreGuis = {}

	for _, v2 in ipairs(self:getSupportedCoreGuiTypes()) do
		local success, result = pcall(function()
			return self.StarterGui:GetCoreGuiEnabled(v2)
		end)

		if success and result == true then
			table.insert(shownCoreGuis, v2)
		end
	end

	return shownCoreGuis
end

return GuiController