local MarketplaceService = game:GetService("MarketplaceService")
local AdService = game:GetService("AdService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
local assets = require(MerchBooth.assets)
local styles = require(MerchBooth.styles)
local enums = require(MerchBooth.enums)
require(MerchBooth.types)
local ExternalEventConnection = require(MerchBooth.Packages.ExternalEventConnection)
local setMerchBoothFocused = require(MerchBooth.Actions.setMerchBoothFocused)
local setEquipModalVisible = require(MerchBooth.Actions.setEquipModalVisible)
local updateItemInfo = require(MerchBooth.Actions.updateItemInfo)
require(MerchBooth.Reducers.reducer)
local getTextFromMode = require(MerchBooth.Modules.getTextFromMode)
local getButtonModeAsync = require(MerchBooth.Modules.getButtonModeAsync)
local formatProductTypeString = require(MerchBooth.Modules.formatProductTypeString)
local SelectableTextLabel = require(script.Parent.Generic.SelectableTextLabel)
local BackButton = require(script.Parent.BackButton)

local ItemEquipped = MerchBooth.Remote.ItemEquipped
local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
local spendCurrency = remotes:WaitForChild("SpendCurrency")
local giftShopItem = remotes:WaitForChild("GiftShopItem")
local beginGamepassGift = remotes:WaitForChild("BeginGamepassGift")
local beginDeveloperProductGift = remotes:WaitForChild("BeginDeveloperProductGift")
local cancelPendingProductGift = remotes:WaitForChild("CancelPendingProductGift")
local canPurchaseDeveloperProduct = remotes:WaitForChild("CanPurchaseDeveloperProduct")
local checkGamepassEntitlement = remotes:WaitForChild("CheckGamepassEntitlement")
local showRewardedAd = remotes:WaitForChild("ShowRewardedAd")
local OfflineGiftPanelToggle = ReplicatedStorage:FindFirstChild("OfflineGiftPanelToggle")
local SoundFX = ReplicatedStorage:WaitForChild("SoundFX")
local Error = SoundFX:FindFirstChild("Error")

local function formatNotesAmount(p)
	local v = tostring((math.max(0, (math.floor(tonumber(p) or 0)))))

	repeat
		local v2
		v, v2 = v:gsub("^(%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local function playPurchaseErrorSound() -- 1 equivalent call inferred from this helper
	if Error and Error:IsA("Sound") then
		local clone = Error:Clone()
		clone.Parent = SoundFX
		clone:Play()
		Debris:AddItem(clone, (math.max(1, clone.TimeLength + 0.25)))
	end
end

local function notifyPurchaseBlocked(value) -- 3 equivalent calls inferred from this helper
	local text = tostring(value or "This product is not available right now.")
	playPurchaseErrorSound() -- inferred equivalent call
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Recording Storage",
			Text = text,
			Duration = 4
		})
	end)
end

local extended = Roact.Component:extend("ItemDetail")

extended.defaultProps = {
	Players = Players,
	MarketplaceService = MarketplaceService,
	RunService = RunService
}

function extended:init()
	self.pendingNotesProductId = nil
	self.pendingNotesProductName = nil

	self:setState({
		primaryButtonMode = enums.PrimaryButtonModes.Loading,
		giftMode = false,
		selectedGiftUserId = nil,
		giftMessage = "",
		pendingGiftProductId = nil,
		pendingNotesProductId = nil,
		pendingNotesProductName = nil,
		notesConfirmationVisible = false
	})

	function self.showShopNotification(title: string, body: string, p)
		local props = self.props
		local v = type(p) == "table" and p or {}
		local v2 = {
			Title = title,
			Body = body,
			Sound = v.Sound,
			IsError = v.IsError == true
		}

		local v3 = rawget(_G, "ShopNotifications")

		if type(v3) == "table" and type(v3.ShowPurchaseThanks) == "function" then
			v3.ShowPurchaseThanks(v2)
			return
		end

		local localPlayer = props.Players.LocalPlayer
		local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
		local shopGiftNotifications = playerGui and playerGui:FindFirstChild("ShopGiftNotifications")
		local showPurchaseThanks = shopGiftNotifications and shopGiftNotifications:FindFirstChild("ShowPurchaseThanks")

		if showPurchaseThanks and showPurchaseThanks:IsA("BindableEvent") then
			showPurchaseThanks:Fire(v2)
		end
	end

	function self.showPurchaseThanks()
		local props = self.props
		local title = tostring(props.itemInfo and props.itemInfo.title or "your purchase")
		self.showShopNotification("Thank you!", "Thanks for supporting the game with " .. title .. ".")
	end

	function self.showNotesPurchaseComplete()
		local props = self.props
		local title = tostring(props.itemInfo and props.itemInfo.title or "your item")
		self.showShopNotification("Purchase complete", "You successfully bought " .. title .. ".")
	end

	function self.showNotesGiftSent()
		local props = self.props
		local title = tostring(props.itemInfo and props.itemInfo.title or "your gift")
		self.showShopNotification("Gift sent", "You successfully gifted " .. title .. ".")
	end

	function self.updateItemOwnership(_, _, p)
		local props = self.props
		props.setMerchBoothFocused(true)

		if p then
			if props.itemInfo.productType == Enum.InfoType.Asset then
				props.showEquipModal()
				props.setItemOwned(props.itemInfo.assetId)
				self:setState({ primaryButtonMode = enums.PrimaryButtonModes.CanEquip })
			elseif props.itemInfo.productType == Enum.InfoType.GamePass then
				props.toggleOverlay(false)
				props.setItemOwned(props.itemInfo.assetId)
				self.showPurchaseThanks()
				self:setState({ primaryButtonMode = enums.PrimaryButtonModes.Owned })
			elseif props.itemInfo.productType == Enum.InfoType.Product then
				props.toggleOverlay(false)
				self.showPurchaseThanks()
			end
		else
			self.props.toggleOverlay(false)
		end
	end

	function self.toggleGiftMode()
		self:setState(function(p)
			return {
				giftMode = not p.giftMode,
				selectedGiftUserId = nil,
				giftMessage = "",
				pendingGiftProductId = nil,
				notesConfirmationVisible = false
			}
		end)
	end

	function self.selectGiftRecipient(selectedGiftUserId: number)
		return function()
			self:setState({ selectedGiftUserId = selectedGiftUserId, giftMessage = "" })
		end
	end

	function self.openOfflineGiftPanel()
		local props = self.props

		if OfflineGiftPanelToggle and OfflineGiftPanelToggle:IsA("BindableEvent") then
			OfflineGiftPanelToggle:Fire({
				itemTitle = tostring(props.itemInfo and props.itemInfo.title or "this item"),
				assetId = props.itemInfo and props.itemInfo.assetId,
				purchaseKind = props.itemInfo and props.itemInfo.purchaseKind
			})

			self:setState({ giftMessage = "Global gift panel opened." })
		else
			self:setState({ giftMessage = "Global gift panel is not installed." })
		end
	end

	function self.sendGift()
		local props = self.props
		local selectedGiftUserId = self.state.selectedGiftUserId

		if not selectedGiftUserId then
			self:setState({ giftMessage = "Choose a player." })
			return
		end

		self:setState({ primaryButtonMode = enums.PrimaryButtonModes.Loading })

		if props.itemInfo.purchaseKind == "Gamepass" or props.itemInfo.purchaseKind == "DeveloperProduct" then
			local localPlayer = props.Players.LocalPlayer
			local success, result, v, v2 = pcall(function()
				if props.itemInfo.purchaseKind == "Gamepass" then
					return beginGamepassGift:InvokeServer(selectedGiftUserId, props.itemInfo.assetId)
				end

				return beginDeveloperProductGift:InvokeServer(selectedGiftUserId, props.itemInfo.assetId)
			end)
			local primaryButtonMode

			if props.itemInfo.isOwned then
				primaryButtonMode = enums.PrimaryButtonModes.Owned
			else
				primaryButtonMode = enums.PrimaryButtonModes.Purchase
			end

			local giftMessage = result and "Complete the Robux prompt." or "Gift failed."

			if v then
				giftMessage = tostring(v)
			elseif not success then
				giftMessage = tostring(result)
			end

			local v3 = tonumber(v2) or 0
			local pendingGiftProductId

			if v3 > 0 then
				pendingGiftProductId = v3
			end

			self:setState({
				primaryButtonMode = primaryButtonMode,
				giftMessage = giftMessage,
				pendingGiftProductId = pendingGiftProductId
			})

			if success and result and localPlayer and v3 > 0 then
				local success2, result2 = pcall(function()
					props.MarketplaceService:PromptProductPurchase(localPlayer, v3)
				end)

				if success2 then
					props.setMerchBoothFocused(false)
					props.toggleOverlay(true)
				else
					cancelPendingProductGift:FireServer(v3)
					self:setState({ giftMessage = tostring(result2), pendingGiftProductId = nil })
					props.setMerchBoothFocused(true)
					props.toggleOverlay(false)
				end
			end
		else
			local pianoItemId = props.itemInfo and props.itemInfo.pianoItemId

			if type(pianoItemId) == "string" then
				local success, result, v = pcall(function()
					return giftShopItem:InvokeServer(selectedGiftUserId, pianoItemId)
				end)
				local primaryButtonMode

				if props.itemInfo.isOwned then
					primaryButtonMode = enums.PrimaryButtonModes.Owned
				else
					primaryButtonMode = enums.PrimaryButtonModes.Purchase
				end

				local giftMessage = result and "Gift sent." or "Gift failed."

				if v then
					giftMessage = tostring(v)
				elseif not success then
					giftMessage = tostring(result)
				end

				if success and result then
					self.showNotesGiftSent()
				end

				self:setState({ primaryButtonMode = primaryButtonMode, giftMessage = giftMessage })
			else
				local primaryButtonMode

				if props.itemInfo.isOwned then
					primaryButtonMode = enums.PrimaryButtonModes.Owned
				else
					primaryButtonMode = enums.PrimaryButtonModes.Purchase
				end

				self:setState({
					primaryButtonMode = primaryButtonMode,
					giftMessage = "This item cannot be gifted."
				})
			end
		end
	end

	function self.showNotesConfirmation()
		self:setState({ giftMessage = "", notesConfirmationVisible = true })
	end

	function self.cancelNotesConfirmation()
		self:setState({ notesConfirmationVisible = false })
	end

	function self.confirmNotesPurchase()
		self:setState({ notesConfirmationVisible = false })

		self.promptPurchase()
	end

	function self.promptPurchase()
		local props = self.props
		local localPlayer = props.Players.LocalPlayer

		if not (localPlayer and props.itemInfo.offSale ~= true) then
			return
		end

		if
			(props.itemInfo.purchaseKind == "ProfileStore" or props.itemInfo.purchaseKind == "Gamepass" or props.itemInfo.purchaseKind == "DeveloperProduct")
			and self.state.giftMode
		then
			self.sendGift()
		elseif props.itemInfo.purchaseKind == "RewardedAd" then
			self:setState({ primaryButtonMode = enums.PrimaryButtonModes.Loading, giftMessage = "" })

			if math.floor(tonumber(props.itemInfo.rewardedAdProductId) or 0) > 0 then
				local success, result = pcall(function()
					return AdService:GetAdAvailabilityNowAsync(Enum.AdFormat.RewardedVideo)
				end)

				if success and result == false then
					self.showShopNotification(
						"Ad unavailable",
						"No rewarded video is available right now. Try again later.",
						{ Sound = "Error", IsError = true }
					)

					self:setState({
						primaryButtonMode = enums.PrimaryButtonModes.Purchase,
						giftMessage = "No rewarded video is available right now. Try again later."
					})

					return
				end
			end

			local success, result = pcall(function()
				return showRewardedAd:InvokeServer(props.itemInfo.rewardedAdKey or "Notes")
			end)

			local giftMessage = "Rewarded ad could not be shown. Try again later."

			if success and type(result) == "table" then
				giftMessage = tostring(result.Message or giftMessage)
			elseif not success then
				giftMessage = tostring(result)
			end

			if success and type(result) == "table" and result.Ok == true then
				self.showShopNotification("Rewarded Ad", giftMessage)
			else
				self.showShopNotification("Ad unavailable", giftMessage, {
					Sound = "Error",
					IsError = true
				})
			end

			self:setState({
				primaryButtonMode = enums.PrimaryButtonModes.Purchase,
				giftMessage = giftMessage
			})
		elseif props.itemInfo.purchaseKind == "ProfileStore" then
			local pianoItemId = props.itemInfo.pianoItemId

			if type(pianoItemId) ~= "string" then
				warn("[MerchBooth] Custom shop item is missing pianoItemId")
				return
			end

			self:setState({ primaryButtonMode = enums.PrimaryButtonModes.Loading })
			local success, result, v, v2 = pcall(function()
				return spendCurrency:InvokeServer(pianoItemId)
			end)

			if success and result then
				props.setItemOwned(props.itemInfo.assetId)

				if tostring(v or "") ~= "Owned" then
					self.showNotesPurchaseComplete()
				end

				self:setState({ primaryButtonMode = enums.PrimaryButtonModes.Owned })
			else
				if success then
					result = v
				end

				local v3 = tostring(result)

				if not success or type(v2) ~= "table" then
					v2 = nil
				end

				if v2 and v2.Code == "NotEnoughNotes" then
					local suggestedProduct

					if type(v2.SuggestedProduct) == "table" then
						suggestedProduct = v2.SuggestedProduct
					end

					local productId = suggestedProduct and math.floor(tonumber(suggestedProduct.ProductId) or 0) or 0
					local v4 = suggestedProduct and math.max(0, (math.floor(tonumber(suggestedProduct.Notes) or 0)))
						or 0
					local pendingNotesProductName = suggestedProduct
						and tostring(suggestedProduct.Name or "Notes Pack")
						or "Notes Pack"

					if v4 > 0 then
						pendingNotesProductName = formatNotesAmount(v4) .. " Notes pack"
					end

					if productId > 0 then
						local giftMessage = v3 .. " Opening " .. pendingNotesProductName .. "."
						self.pendingNotesProductId = productId
						self.pendingNotesProductName = pendingNotesProductName
						self.showShopNotification("Need more Notes", giftMessage)
						self:setState({
							primaryButtonMode = enums.PrimaryButtonModes.Purchase,
							giftMessage = giftMessage,
							pendingNotesProductId = productId,
							pendingNotesProductName = pendingNotesProductName
						})

						local success2, result2 = pcall(function()
							props.MarketplaceService:PromptProductPurchase(localPlayer, productId)
						end)

						if success2 then
							props.setMerchBoothFocused(false)
							props.toggleOverlay(true)
							return
						else
							local giftMessage2 = "Could not open Notes purchase. " .. tostring(result2)
							warn("[MerchBooth] Notes upsell prompt failed:", result2)
							self.showShopNotification("Purchase failed", giftMessage2, {
								Sound = "Error",
								IsError = true
							})

							self.pendingNotesProductId = nil
							self.pendingNotesProductName = nil
							self:setState({
								giftMessage = giftMessage2,
								pendingNotesProductId = nil,
								pendingNotesProductName = nil
							})

							return
						end
					else
						v3 ..= " No Notes pack is configured yet."
					end
				end

				warn("[MerchBooth] Custom purchase failed:", v3)
				self.showShopNotification("Purchase failed", v3, { Sound = "Error", IsError = true })

				self:setState({ primaryButtonMode = enums.PrimaryButtonModes.Purchase })
			end
		else
			if props.itemInfo.productType == Enum.InfoType.Product then
				local success, result, v = pcall(function()
					return canPurchaseDeveloperProduct:InvokeServer(props.itemInfo.assetId)
				end)

				if not success or result ~= true then
					local giftMessage = not success and "Purchase check failed. Try again."
						or tostring(v or "This product is not available right now.")
					notifyPurchaseBlocked(giftMessage) -- inferred equivalent call
					self:setState({
						primaryButtonMode = enums.PrimaryButtonModes.Purchase,
						giftMessage = giftMessage
					})

					return
				end
			end

			if props.itemInfo.productType == Enum.InfoType.GamePass then
				local success, result = pcall(function()
					return checkGamepassEntitlement:InvokeServer(props.itemInfo.assetId)
				end)

				if success and result == true then
					notifyPurchaseBlocked("You already own this, or a gift for it is being delivered.") -- inferred equivalent call
					props.setItemOwned(props.itemInfo.assetId)
					self:setState({
						primaryButtonMode = enums.PrimaryButtonModes.Owned,
						giftMessage = "You already own this, or a gift for it is being delivered."
					})

					return
				elseif not success then
					notifyPurchaseBlocked("Purchase check failed. Try again.") -- inferred equivalent call
					self:setState({
						primaryButtonMode = enums.PrimaryButtonModes.Purchase,
						giftMessage = "Purchase check failed. Try again."
					})

					return
				end
			end

			local success, result = pcall(function()
				if props.itemInfo.productType == Enum.InfoType.Asset then
					props.MarketplaceService:PromptPurchase(localPlayer, props.itemInfo.assetId, false)
				elseif props.itemInfo.productType == Enum.InfoType.GamePass then
					props.MarketplaceService:PromptGamePassPurchase(localPlayer, props.itemInfo.assetId)
				elseif props.itemInfo.productType == Enum.InfoType.Product then
					props.MarketplaceService:PromptProductPurchase(localPlayer, props.itemInfo.assetId)
				end
			end)

			if success then
				props.setMerchBoothFocused(false)
				props.toggleOverlay(true)
			else
				warn("[MerchBooth] Purchase prompt failed:", result)
				props.setMerchBoothFocused(true)
				props.toggleOverlay(false)
				self:setState({
					primaryButtonMode = enums.PrimaryButtonModes.Purchase,
					giftMessage = tostring(result)
				})
			end
		end
	end

	function self.onPrimaryAction()
		local primaryButtonMode = self.state.primaryButtonMode

		if
			self.state.giftMode
			and (self.props.itemInfo.purchaseKind == "ProfileStore" or self.props.itemInfo.purchaseKind == "Gamepass" or self.props.itemInfo.purchaseKind == "DeveloperProduct")
		then
			if self.props.itemInfo.purchaseKind == "ProfileStore" then
				self.showNotesConfirmation()
			else
				self.sendGift()
			end
		elseif primaryButtonMode == enums.PrimaryButtonModes.Purchase then
			if self.props.itemInfo.purchaseKind == "ProfileStore" then
				self.showNotesConfirmation()
			else
				self.promptPurchase()
			end
		else
			if primaryButtonMode == enums.PrimaryButtonModes.OffSale then
				return
			end

			if primaryButtonMode == enums.PrimaryButtonModes.CanEquip then
				ItemEquipped:FireServer(self.props.itemInfo.assetId, self.props.itemInfo.assetType)
				self:setState({ primaryButtonMode = enums.PrimaryButtonModes.Equipped })
			end
		end
	end
end

function extended:render()
	local props = self.props
	local state = self.state

	local productType = props.itemInfo.productType
	local assetType = props.itemInfo.assetType
	local v = props.itemInfo.displayType

	if not v then
		if productType == Enum.InfoType.Asset and assetType then
			v = assetType.Name
		else
			v = productType.Name
		end
	end

	local text = formatProductTypeString(v)

	local v2 = not props.itemInfo.hideExperienceOnlyWarning
		and (props.itemInfo.productType == Enum.InfoType.GamePass or props.itemInfo.productType == Enum.InfoType.Product)
	local giftProductId = tonumber(props.itemInfo.giftProductId) or 0
	local v3 = props.itemInfo.purchaseKind == "Gamepass" and giftProductId > 0
		or props.itemInfo.purchaseKind == "DeveloperProduct"
	local v4 = v3 and state.giftMode == true
	local v5

	if props.itemInfo.purchaseKind == "ProfileStore" then
		v5 = state.notesConfirmationVisible == true
	else
		v5 = false
	end

	local priceText = props.itemInfo.priceText or tostring(props.itemInfo.price or 0) .. " Notes"
	local text2

	if v4 then
		text2 = "Gift " .. props.itemInfo.title .. " for " .. priceText .. "?"
	else
		text2 = "Buy " .. props.itemInfo.title .. " for " .. priceText .. "?"
	end

	local v6 = (props.itemInfo.purchaseKind == "Gamepass" or props.itemInfo.purchaseKind == "DeveloperProduct")
		and "with Robux"
		or props.itemInfo.priceText
		or tostring(props.itemInfo.price or 0) .. " Notes"
	local existingText

	if type(props.itemInfo.existingText) == "string" and props.itemInfo.existingText ~= "" then
		existingText = props.itemInfo.existingText
	end

	local existingTextColor = props.itemInfo.existingTextColor or props.config.secondaryTextColor
	local text3

	if v4 then
		text3 = not state.selectedGiftUserId and "Select Player" or "Gift " .. v6
	elseif state.primaryButtonMode == enums.PrimaryButtonModes.Purchase and props.itemInfo.priceText then
		text3 = props.itemInfo.priceText
	else
		text3 = getTextFromMode(state.primaryButtonMode, props.itemInfo.price)
	end

	local priceIcon

	if not (v4 or state.primaryButtonMode ~= enums.PrimaryButtonModes.Purchase or not (props.itemInfo.price > 0) or props.itemInfo.priceIcon == false) then
		priceIcon = props.itemInfo.priceIcon or assets.Robux
	end

	local v7 = v5 and 3 or 2

	if v3 and not v5 then
		v7 += 1
	end

	if v4 and not v5 then
		v7 += props.itemInfo.purchaseKind == "Gamepass" and 3 or 2
	end

	local isEnabled

	if v4 then
		if state.selectedGiftUserId == nil then
			isEnabled = false
		else
			isEnabled = state.primaryButtonMode ~= enums.PrimaryButtonModes.Loading
		end
	elseif
		state.primaryButtonMode == enums.PrimaryButtonModes.Equipped
		or state.primaryButtonMode == enums.PrimaryButtonModes.Owned
	then
		isEnabled = false
	else
		isEnabled = state.primaryButtonMode ~= enums.PrimaryButtonModes.OffSale
	end

	local children = {}
	local count = 0

	if v4 then
		for _, v8 in ipairs(props.Players:GetPlayers()) do
			if v8 == props.Players.LocalPlayer then
				continue
			end

			count += 1
			local v9 = state.selectedGiftUserId == v8.UserId
			local v10 = "Player" .. tostring(v8.UserId)
			local createElement = Roact.createElement
			local v11 = {}
			v11.LayoutOrder = count
			v11.Size = UDim2.fromOffset(132, 30)
			local backgroundColor

			if v9 then
				backgroundColor = props.config.buttonColor
			else
				backgroundColor = props.config.secondaryButtonColor
			end

			v11.BackgroundColor3 = backgroundColor
			v11.BorderSizePixel = 0
			v11.Text = v8.DisplayName
			local textColor

			if v9 then
				textColor = props.config.buttonTextColor
			else
				textColor = props.config.secondaryButtonTextColor
			end

			v11.TextColor3 = textColor
			v11.TextSize = props.config.textSize
			v11.Font = props.config.headerFont
			v11.TextTruncate = Enum.TextTruncate.AtEnd
			v11.AutoButtonColor = true
			v11[Roact.Event.Activated] = self.selectGiftRecipient(v8.UserId)
			children[v10] = createElement("TextButton", v11, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = props.config.cornerRadiusSmall
				})
			})
		end
	end

	local createElement = Roact.createElement
	local v8 = { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }

	local children2 = {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			[Roact.Change.AbsoluteContentSize] = self.onAbsoluteContentSizeChanged
		}),
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.Padding,
			PaddingRight = styles.Padding,
			PaddingBottom = styles.Padding,
			PaddingLeft = styles.Padding
		}),
		PromptPurchaseEventConnection = Roact.createElement(ExternalEventConnection, {
			event = props.MarketplaceService.PromptPurchaseFinished,
			callback = self.updateItemOwnership
		}),
		PromptGamePassPurchaseEventConnection = Roact.createElement(ExternalEventConnection, {
			event = props.MarketplaceService.PromptGamePassPurchaseFinished,
			callback = self.updateItemOwnership
		}),
		PromptProductPurchaseEventConnection = Roact.createElement(ExternalEventConnection, {
			event = props.MarketplaceService.PromptProductPurchaseFinished,
			callback = function(_, p, p2)
				local v9 = math.floor(tonumber(p) or 0)
				local pendingNotesProductId = math.floor(tonumber(self.pendingNotesProductId or state.pendingNotesProductId) or 0)
				local v10

				if pendingNotesProductId > 0 then
					v10 = v9 == pendingNotesProductId
				else
					v10 = false
				end

				local v11

				if state.giftMode == true then
					v11 = props.itemInfo.purchaseKind == "Gamepass" or props.itemInfo.purchaseKind == "DeveloperProduct"
				else
					v11 = false
				end

				if props.itemInfo.productType == Enum.InfoType.Product or v11 or v10 then
					props.setMerchBoothFocused(true)
					props.toggleOverlay(false)
				end

				if v10 then
					local title = tostring(props.itemInfo and props.itemInfo.title or "this item")
					local pendingNotesProductName = tostring(self.pendingNotesProductName or state.pendingNotesProductName or "Notes pack")
					self.pendingNotesProductId = nil
					self.pendingNotesProductName = nil

					if p2 then
						self.showShopNotification(
							"Notes added",
							pendingNotesProductName .. " purchase complete. Tap Buy again to get " .. title .. "."
						)
					end

					local primaryButtonMode

					if props.itemInfo.isOwned then
						primaryButtonMode = enums.PrimaryButtonModes.Owned
					else
						primaryButtonMode = enums.PrimaryButtonModes.Purchase
					end

					self:setState({
						primaryButtonMode = primaryButtonMode,
						giftMessage = p2 and "Notes added. Tap Buy again." or "Notes purchase cancelled.",
						pendingNotesProductId = nil,
						pendingNotesProductName = nil
					})
				else
					if p2 then
						self.showPurchaseThanks()
					end

					if v11 then
						if not p2 then
							cancelPendingProductGift:FireServer(p or state.pendingGiftProductId)
						end

						local primaryButtonMode

						if props.itemInfo.isOwned then
							primaryButtonMode = enums.PrimaryButtonModes.Owned
						else
							primaryButtonMode = enums.PrimaryButtonModes.Purchase
						end

						self:setState({
							primaryButtonMode = primaryButtonMode,
							giftMessage = p2 and "Gift sent." or "Gift cancelled.",
							pendingGiftProductId = nil
						})
					end
				end
			end
		}),
		BackButton = not props.itemInfo.hiddenFromCatalog and Roact.createElement(BackButton, {
			layoutOrder = 1,
			size = UDim2.new(1, 0, 0, 48),
			text = "Back to catalog"
		}),
		Separator = props.itemInfo.hiddenFromCatalog and Roact.createElement("Frame", {
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 48),
			BackgroundTransparency = 1
		}),
		Info = Roact.createElement(ExperienceComponents.ScrollingFrame, {
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 1, v7 * -48),
			ScrollingEnabled = not props.isOverlayActive,
			ScrollBarImageColor3 = props.config.scrollBarColor
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = styles.Padding
			}),
			ItemType = Roact.createElement(SelectableTextLabel, {
				LayoutOrder = 1,
				Text = text,
				TextColor3 = props.config.secondaryTextColor,
				LineHeight = 0.5,
				TextSize = props.config.textSize,
				Font = props.config.textFont
			}),
			Name = Roact.createElement(ExperienceComponents.TextLabel, {
				LayoutOrder = 2,
				Text = props.itemInfo.title,
				TextSize = props.config.titleTextSize,
				Font = props.config.titleFont,
				AutoLocalize = false,
				TextColor3 = props.config.textColor
			}),
			Creator = props.itemInfo.creatorName and Roact.createElement(ExperienceComponents.TextLabel, {
				LayoutOrder = 3,
				Text = ("By %s%s"):format(
					props.itemInfo.creatorType == Enum.CreatorType.Group and "" or "@",
					props.itemInfo.creatorName
				),
				TextColor3 = props.config.textColor,
				TextSize = props.config.textSize,
				Font = props.config.textFont
			}),
			ExistingCount = existingText and Roact.createElement(SelectableTextLabel, {
				LayoutOrder = 4,
				Text = existingText,
				AutoLocalize = false,
				TextSize = props.config.textSize,
				Font = props.config.headerFont,
				TextColor3 = existingTextColor
			}),
			Description = Roact.createElement(SelectableTextLabel, {
				LayoutOrder = 5,
				Text = props.itemInfo.description,
				AutoLocalize = false,
				TextSize = props.config.textSize,
				Font = props.config.textFont,
				TextColor3 = props.config.textColor
			}),
			ExperienceOnlyWarning = v2 and Roact.createElement(ExperienceComponents.TextLabel, {
				LayoutOrder = 6,
				Text = "⚠ Item can only be used in this experience",
				TextColor3 = props.config.secondaryTextColor,
				TextSize = props.config.textSize,
				Font = props.config.textFont
			}),
			Spacer = Roact.createElement("Frame", { LayoutOrder = 7, BackgroundTransparency = 1 })
		}),
		GiftToggle = 0,
		GiftRecipients = 0,
		OfflineGiftPanelToggle = 0,
		GiftMessage = 0,
		NotesConfirmationMessage = 0,
		NotesConfirmationActions = 0,
		PrimaryAction = 0
	}

	local giftToggle = v3 and not v5

	if giftToggle then
		local createElement2 = Roact.createElement
		local primaryButton = ExperienceComponents.PrimaryButton
		local v9 = {
			layoutOrder = 3,
			size = UDim2.new(1, 0, 0, 48),
			text = v4 and "Gifting: On" or "Gift",
			isEnabled = true,
			onActivated = self.toggleGiftMode,
			isGamepadSelection = false,
			isLoading = false,
			allowHoverState = not props.isOverlayActive,
			automaticSize = Enum.AutomaticSize.None,
			backgroundColor = 0,
			inactiveBackgroundColor = 0,
			contentColor = 0,
			inactiveContentColor = 0,
			textSize = 0,
			cornerRadius = 0,
			font = 0
		}
		local backgroundColor

		if v4 then
			backgroundColor = props.config.buttonColor
		else
			backgroundColor = props.config.secondaryButtonColor
		end

		v9.backgroundColor = backgroundColor
		v9.inactiveBackgroundColor = props.config.inactiveButtonColor
		v9.contentColor = props.config.buttonTextColor
		v9.inactiveContentColor = props.config.inactiveButtonTextColor
		v9.textSize = props.config.textSize
		v9.cornerRadius = props.config.cornerRadiusSmall
		v9.font = props.config.headerFont
		giftToggle = createElement2(primaryButton, v9)
	end

	children2.GiftToggle = giftToggle

	local giftRecipients = v4 and not v5

	if giftRecipients then
		giftRecipients = Roact.createElement(
			"Frame",
			{ LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 },
			{
				Empty = count <= 0 and Roact.createElement(ExperienceComponents.TextLabel, {
					Text = "No players online",
					TextColor3 = props.config.secondaryTextColor,
					TextSize = props.config.textSize,
					Font = props.config.textFont
				}),
				Players = count > 0 and Roact.createElement("ScrollingFrame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 0,
					ScrollingDirection = Enum.ScrollingDirection.X,
					AutomaticCanvasSize = Enum.AutomaticSize.X,
					CanvasSize = UDim2.fromScale(0, 0)
				}, {
					Layout = Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = styles.PaddingMicro
					}),
					Recipients = Roact.createFragment(children)
				})
			}
		)
	end

	children2.GiftRecipients = giftRecipients
	local offlineGiftPanelToggle

	if v4 then
		if props.itemInfo.purchaseKind == "Gamepass" then
			offlineGiftPanelToggle = not v5 and Roact.createElement(ExperienceComponents.PrimaryButton, {
				layoutOrder = 5,
				size = UDim2.new(1, 0, 0, 48),
				text = "Open global gift panel",
				isEnabled = true,
				onActivated = self.openOfflineGiftPanel,
				isGamepadSelection = false,
				isLoading = false,
				allowHoverState = not props.isOverlayActive,
				automaticSize = Enum.AutomaticSize.None,
				backgroundColor = props.config.secondaryButtonColor,
				inactiveBackgroundColor = props.config.inactiveButtonColor,
				contentColor = props.config.secondaryButtonTextColor,
				inactiveContentColor = props.config.inactiveButtonTextColor,
				textSize = props.config.textSize,
				cornerRadius = props.config.cornerRadiusSmall,
				font = props.config.headerFont
			})
		else
			offlineGiftPanelToggle = false
		end
	else
		offlineGiftPanelToggle = v4
	end

	children2.OfflineGiftPanelToggle = offlineGiftPanelToggle

	children2.GiftMessage = v4 and not v5 and Roact.createElement(ExperienceComponents.TextLabel, {
		LayoutOrder = 6,
		Text = state.giftMessage or "",
		TextColor3 = props.config.secondaryTextColor,
		TextSize = props.config.textSize,
		Font = props.config.textFont
	})

	children2.NotesConfirmationMessage = v5 and Roact.createElement(ExperienceComponents.TextLabel, {
		LayoutOrder = 4,
		Size = UDim2.new(1, 0, 0, 32),
		Text = text2,
		TextColor3 = props.config.textColor,
		TextSize = props.config.textSize,
		Font = props.config.headerFont,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center
	})

	children2.NotesConfirmationActions = v5
		and Roact.createElement(
			"Frame",
			{ LayoutOrder = 5, Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 },
			{
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = styles.PaddingMicro
				}),
				Cancel = Roact.createElement(ExperienceComponents.PrimaryButton, {
					layoutOrder = 1,
					size = UDim2.new(0.5, -styles.PaddingMicro.Offset / 2, 1, 0),
					text = "Cancel",
					isEnabled = true,
					onActivated = self.cancelNotesConfirmation,
					isGamepadSelection = false,
					isLoading = false,
					allowHoverState = not props.isOverlayActive,
					automaticSize = Enum.AutomaticSize.None,
					backgroundColor = props.config.secondaryButtonColor,
					inactiveBackgroundColor = props.config.inactiveButtonColor,
					contentColor = props.config.secondaryButtonTextColor,
					inactiveContentColor = props.config.inactiveButtonTextColor,
					textSize = props.config.textSize,
					cornerRadius = props.config.cornerRadiusSmall,
					font = props.config.headerFont
				}),
				Confirm = Roact.createElement(ExperienceComponents.PrimaryButton, {
					layoutOrder = 2,
					size = UDim2.new(0.5, -styles.PaddingMicro.Offset / 2, 1, 0),
					text = "Confirm",
					isEnabled = true,
					onActivated = self.confirmNotesPurchase,
					isGamepadSelection = true,
					isLoading = false,
					allowHoverState = not props.isOverlayActive,
					automaticSize = Enum.AutomaticSize.None,
					backgroundColor = props.config.buttonColor,
					inactiveBackgroundColor = props.config.inactiveButtonColor,
					contentColor = props.config.buttonTextColor,
					inactiveContentColor = props.config.inactiveButtonTextColor,
					textSize = props.config.textSize,
					cornerRadius = props.config.cornerRadiusSmall,
					font = props.config.headerFont
				})
			}
		)

	children2.PrimaryAction = not v5 and Roact.createElement(ExperienceComponents.PrimaryButton, {
		layoutOrder = 7,
		size = UDim2.new(1, 0, 0, 48),
		text = text3,
		icon = priceIcon,
		isEnabled = isEnabled,
		onActivated = self.onPrimaryAction,
		isGamepadSelection = true,
		isLoading = state.primaryButtonMode == enums.PrimaryButtonModes.Loading,
		allowHoverState = not props.isOverlayActive,
		automaticSize = Enum.AutomaticSize.None,
		backgroundColor = props.config.buttonColor,
		inactiveBackgroundColor = props.config.inactiveButtonColor,
		contentColor = props.config.buttonTextColor,
		inactiveContentColor = props.config.inactiveButtonTextColor,
		textSize = props.config.textSize,
		cornerRadius = props.config.cornerRadiusSmall,
		font = props.config.headerFont
	})
	return createElement("Frame", v8, children2)
end

function extended.didMount(object)
	local props = object.props

	task.spawn(function()
		local localPlayer = props.Players.LocalPlayer

		object:setState({
			primaryButtonMode = getButtonModeAsync()(localPlayer, props.itemInfo)
		})
	end)
end

local function mapStateToProps(p)
	return { config = p.config }
end

local function mapDispatchToProps(callback)
	return {
		showEquipModal = function()
			callback(setEquipModalVisible(true))
		end,
		setItemOwned = function(p: number)
			callback(updateItemInfo(tostring(p), { isOwned = true }))
		end,
		setMerchBoothFocused = function(flag: boolean)
			callback(setMerchBoothFocused(flag))
		end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(extended)