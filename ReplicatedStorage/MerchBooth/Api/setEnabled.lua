local LocalizationService = game:GetService("LocalizationService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
local t = require(MerchBooth.Packages.t)
local App = require(MerchBooth.Components.App)
local getCurrentDevice = require(MerchBooth.Modules.getCurrentDevice)
local uiStatesEvents = require(MerchBooth.Api.uiStatesEvents)
local itemEvents = require(MerchBooth.Api.itemEvents)
require(MerchBooth.Reducers.reducer)
local setMerchBoothVisible = require(MerchBooth.Actions.setMerchBoothVisible)
local setItemInfo = require(MerchBooth.Actions.setItemInfo)
local setMerchBoothEnabled = require(MerchBooth.Actions.setMerchBoothEnabled)
local updateItemInfo = require(MerchBooth.Actions.updateItemInfo)
local addProximityButton = require(MerchBooth.Actions.addProximityButton)
local removeProximityButton = require(MerchBooth.Actions.removeProximityButton)
local setDevice = require(MerchBooth.Actions.setDevice)
require(MerchBooth.types)

local InitialLoadData = MerchBooth.Remote.InitialLoadData

return function(store)
	local localPlayer = Players.LocalPlayer

	local element = Roact.createElement(RoactRodux.StoreProvider, { store = store }, { Roact.createElement(App) })

	local v = nil
	local v2 = {}

	local function onItemInfoReceived(p: string, p2)
		store:dispatch(setItemInfo(p, p2))

		local isOwned = false

		if p2.productType == Enum.InfoType.Asset then
			pcall(function()
				isOwned = MarketplaceService:PlayerOwnsAsset(localPlayer, p)
			end)
		elseif p2.productType == Enum.InfoType.GamePass then
			pcall(function()
				isOwned = MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, p)
			end)
		end

		store:dispatch(updateItemInfo(p, { isOwned = isOwned }))

		if LocalizationService.RobloxLocaleId ~= "en-us" then
			task.spawn(function()
				local productInfo = MarketplaceService:GetProductInfo(tonumber(p), p2.productType)
				store:dispatch(updateItemInfo(p, {
					title = productInfo.Name,
					description = productInfo.Description
				}))
			end)
		end
	end

	local function setCurrentDevice() -- 1 equivalent call inferred from this helper
		store:dispatch(setDevice((getCurrentDevice(UserInputService:GetLastInputType()))))
	end

	local function setEnabled(flag: boolean, p, p2, p3, p4)
		assert(RunService:IsClient(), "MerchBooth.setEnabled must be called on the client")
		assert(t.boolean(flag), "Bad argument #1 to MerchBooth.setEnabled: expected a boolean")

		local isMerchBoothEnabled = store:getState().ui.isMerchBoothEnabled

		if isMerchBoothEnabled == flag then
			warn(string.format(
				"Calling MerchBooth.setEnabled(%s), but it is already %s",
				tostring(flag),
				isMerchBoothEnabled and "enabled" or "disabled"
			))

			return
		end

		store:dispatch(setMerchBoothEnabled(flag))
		store:flush()

		if flag then
			v2.uiStateEvents = uiStatesEvents.connect(store)

			v2.itemEvents = itemEvents.connect(store, function(p5)
				return p5.server.itemInfo
			end)

			local playerGui = localPlayer:WaitForChild("PlayerGui")
			v = Roact.mount(element, playerGui)

			local v3 = p or MerchBooth.Remote.SetItemInfo
			local v4 = p2 or MerchBooth.Remote.AddProximityButton
			local v5 = p3 or MerchBooth.Remote.RemoveProximityButton
			local v6 = p4 or MerchBooth.Remote.PlayParticleEmitter

			v2.setItemInfoConnection = v3.OnClientEvent:Connect(function(p5)
				onItemInfoReceived(p5.itemId, p5.info)
			end)

			v2.addProximityConnection = v4.OnClientEvent:Connect(function(p5, p6)
				store:dispatch(addProximityButton(p5, p6))
			end)

			v2.removeProximityConnection = v5.OnClientEvent:Connect(function(p5)
				store:dispatch(removeProximityButton(p5))
			end)

			v2.initialLoadEventConnection = InitialLoadData.OnClientEvent:Connect(function(items, list)
				for k, item in pairs(items) do
					onItemInfoReceived(k, item)
				end

				for _, item in ipairs(list) do
					store:dispatch(addProximityButton(item[2], item[1]))
				end
			end)

			v2.characterAddedConnection = localPlayer.CharacterAdded:Connect(function()
				store:dispatch(setMerchBoothVisible(false))
			end)

			v2.playParticleEmitterConnection = v6.OnClientEvent:Connect(function()
				local clone = store:getState().config.particleEmitterTemplate:Clone()
				clone.Parent = localPlayer.Character.Humanoid.RootPart
				clone:Emit(15)

				task.wait()

				if clone.Parent then
					clone.Enabled = false
				end

				task.wait(4)

				if clone.Parent then
					clone:Destroy()
				end
			end)

			v2.lastInputTypeChangedConnection = UserInputService.LastInputTypeChanged:Connect(setCurrentDevice)
			setCurrentDevice() -- inferred equivalent call
		else
			if v then
				store:dispatch(setMerchBoothVisible(false))
				store:flush()
				Roact.unmount(v)
				v = nil
			end

			for _, connection in pairs(v2) do
				if typeof(connection) == "table" then
					connection:disconnect()
				else
					connection:Disconnect()
				end
			end
		end
	end

	return setEnabled
end